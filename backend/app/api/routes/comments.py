import os
from typing import List, Optional
from uuid import uuid4

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.api.routes.auth import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.comment import CommentResponse
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

UPLOAD_DIR = "uploads/comments"
os.makedirs(UPLOAD_DIR, exist_ok=True)


async def save_comment_file(
    file: UploadFile,
    folder: str,
) -> str:
    ext = os.path.splitext(file.filename or "")[1]
    filename = f"{uuid4().hex}{ext}"
    folder_path = os.path.join(UPLOAD_DIR, folder)
    os.makedirs(folder_path, exist_ok=True)

    file_path = os.path.join(folder_path, filename)

    content = await file.read()

    with open(file_path, "wb") as buffer:
        buffer.write(content)

    return f"/uploads/comments/{folder}/{filename}"


@router.post("/")
async def add_comment(
    post_id: int = Form(...),
    text: str = Form(""),
    image: Optional[UploadFile] = File(None),
    audio: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    image_url = None
    audio_url = None

    if image is not None:
        image_url = await save_comment_file(
            image,
            "images",
        )

    if audio is not None:
        audio_url = await save_comment_file(
            audio,
            "audio",
        )

    comment = create_comment(
        db=db,
        user_id=current_user.id,
        post_id=post_id,
        text=text,
        image_url=image_url,
        audio_url=audio_url,
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
            post_id=post_id,
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