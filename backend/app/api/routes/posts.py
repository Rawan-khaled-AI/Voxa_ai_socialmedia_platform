from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.api.routes.auth import get_current_user
from app.core.database import get_db
from app.models.post import Post
from app.models.user import User
from app.models.notification import Notification
from app.schemas.post import PostCreate, PostResponse, RepostCreate
from app.services.post_service import (
    build_post_response,
    create_post,
    create_repost,
    get_all_posts,
    get_post_by_id,
    get_user_posts,
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


@router.post("/repost", response_model=PostResponse)
def repost_post(
    data: RepostCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = create_repost(
        db=db,
        user_id=current_user.id,
        post_id=data.post_id,
    )

    if result is None:
        raise HTTPException(
            status_code=404,
            detail="Post not found",
        )

    if result == "own_post":
        raise HTTPException(
            status_code=400,
            detail="You cannot repost your own post",
        )

    if result == "already_reposted":
        raise HTTPException(
            status_code=400,
            detail="You already reposted this post",
        )

    return result


@router.get("/", response_model=List[PostResponse])
def get_posts(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_all_posts(
        db=db,
        current_user_id=current_user.id,
    )


@router.get("/search/", response_model=List[PostResponse])
def search_posts(
    q: str = Query(..., min_length=1),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    posts = (
        db.query(Post)
        .filter(Post.text.ilike(f"%{q}%"))
        .order_by(Post.id.desc())
        .limit(20)
        .all()
    )

    return [
        build_post_response(
            db=db,
            post=post,
            current_user_id=current_user.id,
        )
        for post in posts
    ]


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


@router.patch("/{post_id}", response_model=PostResponse)
def update_post(
    post_id: int,
    data: PostCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    post = (
        db.query(Post)
        .filter(Post.id == post_id)
        .first()
    )

    if not post:
        raise HTTPException(
            status_code=404,
            detail="Post not found",
        )

    if post.user_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can edit only your own posts",
        )

    if post.repost_of_post_id is not None:
        raise HTTPException(
            status_code=400,
            detail="Reposts cannot be edited",
        )

    if data.text is not None:
        post.text = data.text

    if data.image_url is not None:
        post.image_url = data.image_url

    if data.audio_url is not None:
        post.audio_url = data.audio_url

    if (
        not post.text and
        not post.image_url and
        not post.audio_url
    ):
        raise HTTPException(
            status_code=400,
            detail="Post must contain text, image, or audio",
        )

    db.commit()
    db.refresh(post)

    return get_post_by_id(
        db=db,
        post_id=post.id,
        current_user_id=current_user.id,
    )


@router.delete("/{post_id}")
def delete_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    post = (
        db.query(Post)
        .filter(Post.id == post_id)
        .first()
    )

    if not post:
        raise HTTPException(
            status_code=404,
            detail="Post not found",
        )

    if post.user_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can delete only your own posts",
        )
    db.query(Notification).filter(
        Notification.post_id == post_id
    ).delete(synchronize_session=False)
    db.delete(post)
    db.commit()

    return {
        "message": "Post deleted successfully",
    }


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