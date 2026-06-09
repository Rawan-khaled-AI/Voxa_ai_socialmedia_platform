from sqlalchemy.orm import Session, joinedload

from app.models.post import Post
from app.services.like_service import (
    get_post_likes_count,
    has_user_liked_post,
)
from app.services.comment_service import get_post_comments_count


def _build_original_post_response(post: Post):
    if not post:
        return None

    return {
        "id": post.id,
        "text": post.text,
        "image_url": post.image_url,
        "audio_url": post.audio_url,
        "user_id": post.user_id,
        "user": post.user,
    }


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
        "repost_of_post_id": post.repost_of_post_id,
        "original_post": _build_original_post_response(
            post.original_post,
        )
        if post.repost_of_post_id
        else None,
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
        .options(
            joinedload(Post.user),
            joinedload(Post.original_post).joinedload(Post.user),
        )
        .filter(Post.id == post.id)
        .first()
    )

    return build_post_response(
        db=db,
        post=post,
        current_user_id=user_id,
    )


def create_repost(
    db: Session,
    user_id: int,
    post_id: int,
):
    original_post = (
        db.query(Post)
        .filter(Post.id == post_id)
        .first()
    )

    if not original_post:
        return None

    if original_post.user_id == user_id:
        return "own_post"

    existing_repost = (
        db.query(Post)
        .filter(
            Post.user_id == user_id,
            Post.repost_of_post_id == post_id,
        )
        .first()
    )

    if existing_repost:
        return "already_reposted"

    repost = Post(
        text=None,
        image_url=None,
        audio_url=None,
        user_id=user_id,
        repost_of_post_id=post_id,
    )

    db.add(repost)
    db.commit()
    db.refresh(repost)

    repost = (
        db.query(Post)
        .options(
            joinedload(Post.user),
            joinedload(Post.original_post).joinedload(Post.user),
        )
        .filter(Post.id == repost.id)
        .first()
    )

    return build_post_response(
        db=db,
        post=repost,
        current_user_id=user_id,
    )


def get_all_posts(
    db: Session,
    current_user_id: int | None = None,
):
    posts = (
        db.query(Post)
        .options(
            joinedload(Post.user),
            joinedload(Post.original_post).joinedload(Post.user),
        )
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
        .options(
            joinedload(Post.user),
            joinedload(Post.original_post).joinedload(Post.user),
        )
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


def get_post_by_id(
    db: Session,
    post_id: int,
    current_user_id: int | None = None,
):
    post = (
        db.query(Post)
        .options(
            joinedload(Post.user),
            joinedload(Post.original_post).joinedload(Post.user),
        )
        .filter(Post.id == post_id)
        .first()
    )

    if not post:
        return None

    return build_post_response(
        db=db,
        post=post,
        current_user_id=current_user_id,
    )