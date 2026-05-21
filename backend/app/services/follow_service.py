from sqlalchemy.orm import Session

from app.models.follow import Follow
from app.models.user import User
from app.services.notification_service import create_notification


def toggle_follow(
    db: Session,
    follower_id: int,
    following_id: int,
):
    if follower_id == following_id:
        return "self_follow"

    user_to_follow = (
        db.query(User)
        .filter(User.id == following_id)
        .first()
    )

    if not user_to_follow:
        return None

    existing_follow = (
        db.query(Follow)
        .filter(
            Follow.follower_id == follower_id,
            Follow.following_id == following_id,
        )
        .first()
    )

    if existing_follow:
        db.delete(existing_follow)
        db.commit()

        return {
            "following": False,
            "message": "User unfollowed successfully",
        }

    follow = Follow(
        follower_id=follower_id,
        following_id=following_id,
    )

    db.add(follow)
    db.commit()

    create_notification(
        db=db,
        user_id=following_id,
        actor_id=follower_id,
        notification_type="follow",
    )

    return {
        "following": True,
        "message": "User followed successfully",
    }


def get_followers_count(
    db: Session,
    user_id: int,
):
    return (
        db.query(Follow)
        .filter(Follow.following_id == user_id)
        .count()
    )


def get_following_count(
    db: Session,
    user_id: int,
):
    return (
        db.query(Follow)
        .filter(Follow.follower_id == user_id)
        .count()
    )


def is_following_user(
    db: Session,
    follower_id: int,
    following_id: int,
):
    return (
        db.query(Follow)
        .filter(
            Follow.follower_id == follower_id,
            Follow.following_id == following_id,
        )
        .first()
        is not None
    )