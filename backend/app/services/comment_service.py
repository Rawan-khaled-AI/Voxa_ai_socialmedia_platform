from sqlalchemy.orm import Session, joinedload

from app.models.comment import Comment
from app.models.post import Post
from app.services.notification_service import create_notification


def get_post_comments_count(
    db: Session,
    post_id: int,
):
    return (
        db.query(Comment)
        .filter(Comment.post_id == post_id)
        .count()
    )


def create_comment(
    db: Session,
    user_id: int,
    post_id: int,
    text: str,
):
    post = db.query(Post).filter(Post.id == post_id).first()

    if not post:
        return None

    comment = Comment(
        text=text,
        user_id=user_id,
        post_id=post_id,
    )

    db.add(comment)
    db.commit()
    db.refresh(comment)

    if post.user_id != user_id:
        create_notification(
            db=db,
            user_id=post.user_id,
            actor_id=user_id,
            post_id=post_id,
            notification_type="comment",
        )

    return (
        db.query(Comment)
        .options(joinedload(Comment.user))
        .filter(Comment.id == comment.id)
        .first()
    )


def get_post_comments(
    db: Session,
    post_id: int,
):
    return (
        db.query(Comment)
        .options(joinedload(Comment.user))
        .filter(Comment.post_id == post_id)
        .order_by(Comment.id.desc())
        .all()
    )


def delete_comment(
    db: Session,
    comment_id: int,
    user_id: int,
):
    comment = (
        db.query(Comment)
        .filter(Comment.id == comment_id)
        .first()
    )

    if not comment:
        return "not_found"

    if comment.user_id != user_id:
        return "forbidden"

    post_id = comment.post_id

    db.delete(comment)
    db.commit()

    return {
        "status": "deleted",
        "post_id": post_id,
        "comments_count": get_post_comments_count(db, post_id),
    }