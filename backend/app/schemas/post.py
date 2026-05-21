from pydantic import BaseModel
from typing import Optional


class PostCreate(BaseModel):
    text: Optional[str] = None
    image_url: Optional[str] = None
    audio_url: Optional[str] = None


class PostUser(BaseModel):
    id: int
    name: str
    profile_image_url: Optional[str] = None

    model_config = {"from_attributes": True}


class PostResponse(BaseModel):
    id: int

    text: Optional[str] = None
    image_url: Optional[str] = None
    audio_url: Optional[str] = None

    user_id: int
    user: PostUser

    likes_count: int = 0
    comments_count: int = 0
    is_liked: bool = False

    model_config = {"from_attributes": True}