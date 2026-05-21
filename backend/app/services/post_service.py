from sqlalchemy.orm import Session, joinedload

from app.models.post import Post
from app.services.like_service import (
    get_post_likes_count,
    has_user_liked_post,
)
from app.services.comment_service import get_post_comments_count


def build_post_response(
    db: Session,
    post: Post,
    current_user_id: int | None = None,
):
    return {
        "id": post.id,
        "text": post.text,
        "image_url": post.image_url,
        "audio_url": post.audio_url,
        "user_id": post.user_id,
        "user": post.user,
        "likes_count": get_post_likes_count(db, post.id),
        "comments_count": get_post_comments_count(db, post.id),
        "is_liked": (
            has_user_liked_post(db, current_user_id, post.id)
            if current_user_id is not None
            else False
        ),
    }


def create_post(
    db: Session,
    user_id: int,
    text: str | None = None,
    image_url: str | None = None,
    audio_url: str | None = None,
):
    post = Post(
        text=text,
        image_url=image_url,
        audio_url=audio_url,
        user_id=user_id,
    )

    db.add(post)
    db.commit()
    db.refresh(post)

    post = (
        db.query(Post)
        .options(joinedload(Post.user))
        .filter(Post.id == post.id)
        .first()
    )

    return build_post_response(
        db=db,
        post=post,
        current_user_id=user_id,
    )


def get_all_posts(
    db: Session,
    current_user_id: int | None = None,
):
    posts = (
        db.query(Post)
        .options(joinedload(Post.user))
        .order_by(Post.id.desc())
        .all()
    )

    return [
        build_post_response(
            db=db,
            post=post,
            current_user_id=current_user_id,
        )
        for post in posts
    ]
    
def get_user_posts(
    db: Session,
    user_id: int,
    current_user_id: int | None = None,
):
    posts = (
        db.query(Post)
        .options(joinedload(Post.user))
        .filter(Post.user_id == user_id)
        .order_by(Post.id.desc())
        .all()
    )

    return [
        build_post_response(
            db=db,
            post=post,
            current_user_id=current_user_id,
        )
        for post in posts
    ]