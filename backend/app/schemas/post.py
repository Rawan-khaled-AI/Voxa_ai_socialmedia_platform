from pydantic import BaseModel
from typing import Optional


class PostCreate(BaseModel):
    text: Optional[str] = None
    image_url: Optional[str] = None
    audio_url: Optional[str] = None


class RepostCreate(BaseModel):
    post_id: int


class PostUser(BaseModel):
    id: int
    name: str
    profile_image_url: Optional[str] = None

    model_config = {"from_attributes": True}


class OriginalPostResponse(BaseModel):
    id: int
    text: Optional[str] = None
    image_url: Optional[str] = None
    audio_url: Optional[str] = None
    user_id: int
    user: PostUser

    model_config = {"from_attributes": True}


class PostResponse(BaseModel):
    id: int

    text: Optional[str] = None
    image_url: Optional[str] = None
    audio_url: Optional[str] = None

    user_id: int
    user: PostUser

    repost_of_post_id: Optional[int] = None
    original_post: Optional[OriginalPostResponse] = None

    likes_count: int = 0
    comments_count: int = 0
    is_liked: bool = False

    model_config = {"from_attributes": True}