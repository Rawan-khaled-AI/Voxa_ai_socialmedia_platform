from sqlalchemy.orm import Session

from app.models.like import Like
from app.models.post import Post
from app.services.notification_service import create_notification


def get_post_likes_count(
    db: Session,
    post_id: int,
):
    return (
        db.query(Like)
        .filter(Like.post_id == post_id)
        .count()
    )


def has_user_liked_post(
    db: Session,
    user_id: int,
    post_id: int,
):
    return (
        db.query(Like)
        .filter(
            Like.user_id == user_id,
            Like.post_id == post_id,
        )
        .first()
        is not None
    )


def toggle_like(
    db: Session,
    user_id: int,
    post_id: int,
):
    post = db.query(Post).filter(Post.id == post_id).first()

    if not post:
        return None

    existing_like = (
        db.query(Like)
        .filter(
            Like.user_id == user_id,
            Like.post_id == post_id,
        )
        .first()
    )

    if existing_like:
        db.delete(existing_like)
        db.commit()

        return {
            "liked": False,
            "likes_count": get_post_likes_count(db, post_id),
            "message": "Post unliked successfully",
        }

    like = Like(
        user_id=user_id,
        post_id=post_id,
    )

    db.add(like)
    db.commit()

    if post.user_id != user_id:
        create_notification(
            db=db,
            user_id=post.user_id,
            actor_id=user_id,
            post_id=post_id,
            notification_type="like",
        )

    return {
        "liked": True,
        "likes_count": get_post_likes_count(db, post_id),
        "message": "Post liked successfully",
    }