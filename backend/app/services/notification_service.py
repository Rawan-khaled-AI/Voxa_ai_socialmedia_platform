from sqlalchemy.orm import Session, joinedload

from app.models.notification import Notification


def create_notification(
    db: Session,
    user_id: int,
    notification_type: str,
    actor_id: int | None = None,
    post_id: int | None = None,
):
    if actor_id is not None and actor_id == user_id:
        return None

    notification = Notification(
        user_id=user_id,
        actor_id=actor_id,
        post_id=post_id,
        type=notification_type,
    )

    db.add(notification)
    db.commit()
    db.refresh(notification)

    return notification


def get_user_notifications(
    db: Session,
    user_id: int,
):
    return (
        db.query(Notification)
        .options(
            joinedload(Notification.actor),
            joinedload(Notification.post),
        )
        .filter(Notification.user_id == user_id)
        .order_by(Notification.id.desc())
        .all()
    )


def mark_notification_as_read(
    db: Session,
    notification_id: int,
    user_id: int,
):
    notification = (
        db.query(Notification)
        .filter(
            Notification.id == notification_id,
            Notification.user_id == user_id,
        )
        .first()
    )

    if not notification:
        return None

    notification.is_read = True

    db.commit()
    db.refresh(notification)

    return notification