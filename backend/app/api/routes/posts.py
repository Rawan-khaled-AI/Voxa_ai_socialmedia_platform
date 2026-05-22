from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.routes.auth import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.post import PostCreate, PostResponse
from app.services.post_service import (
    create_post,
    get_all_posts,
    get_user_posts,
    get_post_by_id,
)

router = APIRouter(
    prefix="/posts",
    tags=["Posts"],
)


@router.post("/", response_model=PostResponse)
def create_new_post(
    data: PostCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if (
        not data.text and
        not data.image_url and
        not data.audio_url
    ):
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
def get_posts(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_all_posts(
        db=db,
        current_user_id=current_user.id,
    )


@router.get("/{post_id}", response_model=PostResponse)
def get_single_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    post = get_post_by_id(
        db=db,
        post_id=post_id,
        current_user_id=current_user.id,
    )

    if post is None:
        raise HTTPException(
            status_code=404,
            detail="Post not found",
        )

    return post


@router.get(
    "/user/{user_id}",
    response_model=List[PostResponse],
)
def get_posts_by_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_user_posts(
        db=db,
        user_id=user_id,
        current_user_id=current_user.id,
    )