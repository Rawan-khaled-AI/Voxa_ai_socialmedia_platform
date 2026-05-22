from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.routes.auth import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.services.follow_service import (
    get_followers_count,
    get_following_count,
    is_following_user,
    toggle_follow,
)

router = APIRouter(
    prefix="/follows",
    tags=["Follows"],
)


@router.post("/user/{user_id}")
def follow_or_unfollow_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = toggle_follow(
        db=db,
        follower_id=current_user.id,
        following_id=user_id,
    )

    if result is None:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    if result == "self_follow":
        raise HTTPException(
            status_code=400,
            detail="You cannot follow yourself",
        )

    result["followers_count"] = get_followers_count(
        db=db,
        user_id=user_id,
    )

    result["following_count"] = get_following_count(
        db=db,
        user_id=user_id,
    )

    return result


@router.get("/status/{user_id}")
def get_follow_status(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.id == user_id:
        return {
            "following": False,
            "is_my_profile": True,
            "followers_count": get_followers_count(
                db=db,
                user_id=user_id,
            ),
            "following_count": get_following_count(
                db=db,
                user_id=user_id,
            ),
        }

    user = (
        db.query(User)
        .filter(User.id == user_id)
        .first()
    )

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    return {
        "following": is_following_user(
            db=db,
            follower_id=current_user.id,
            following_id=user_id,
        ),
        "is_my_profile": False,
        "followers_count": get_followers_count(
            db=db,
            user_id=user_id,
        ),
        "following_count": get_following_count(
            db=db,
            user_id=user_id,
        ),
    }