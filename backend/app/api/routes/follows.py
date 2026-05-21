from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.routes.auth import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.services.follow_service import toggle_follow

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

    return result