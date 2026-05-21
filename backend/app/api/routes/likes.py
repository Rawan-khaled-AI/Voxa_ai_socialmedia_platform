from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.routes.auth import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.services.like_service import toggle_like

router = APIRouter(
    prefix="/likes",
    tags=["Likes"],
)


@router.post("/post/{post_id}")
def like_or_unlike_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = toggle_like(
        db=db,
        user_id=current_user.id,
        post_id=post_id,
    )

    if result is None:
        raise HTTPException(
            status_code=404,
            detail="Post not found",
        )

    return result