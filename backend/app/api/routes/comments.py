from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.routes.auth import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.comment import CommentCreate, CommentResponse
from app.services.comment_service import (
    create_comment,
    delete_comment,
    get_post_comments,
    get_post_comments_count,
)

router = APIRouter(
    prefix="/comments",
    tags=["Comments"],
)


@router.post("/")
def add_comment(
    data: CommentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    comment = create_comment(
        db=db,
        user_id=current_user.id,
        post_id=data.post_id,
        text=data.text,
    )

    if comment is None:
        raise HTTPException(
            status_code=404,
            detail="Post not found",
        )

    return {
        "comment": CommentResponse.model_validate(comment),
        "comments_count": get_post_comments_count(
            db=db,
            post_id=data.post_id,
        ),
        "message": "Comment created successfully",
    }


@router.get("/post/{post_id}", response_model=List[CommentResponse])
def get_comments(
    post_id: int,
    db: Session = Depends(get_db),
):
    return get_post_comments(
        db=db,
        post_id=post_id,
    )


@router.delete("/{comment_id}")
def remove_comment(
    comment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = delete_comment(
        db=db,
        comment_id=comment_id,
        user_id=current_user.id,
    )

    if result == "not_found":
        raise HTTPException(
            status_code=404,
            detail="Comment not found",
        )

    if result == "forbidden":
        raise HTTPException(
            status_code=403,
            detail="You can delete only your own comments",
        )

    return {
        "message": "Comment deleted successfully",
        "comments_count": result["comments_count"],
    }