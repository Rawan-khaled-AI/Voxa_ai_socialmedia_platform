from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.auth import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.post import PostCreate, PostResponse
from app.services.post_service import create_post, get_all_posts

router = APIRouter(prefix="/posts", tags=["Posts"])


@router.post("/", response_model=PostResponse)
def create_new_post(
    data: PostCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not data.text and not data.image_url and not data.audio_url:
        raise HTTPException(
            status_code=400,
            detail="Post must contain text, image, or audio",
        )

    return create_post(
        db=db,
        user_id=current_user.id,
        text=data.text,
        image_url=data.image_url,
        audio_url=data.audio_url,
    )


@router.get("/", response_model=List[PostResponse])
def get_posts(db: Session = Depends(get_db)):
    return get_all_posts(db)