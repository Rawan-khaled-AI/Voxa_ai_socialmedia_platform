from pydantic import BaseModel
from typing import Optional


class PostCreate(BaseModel):
    text: Optional[str] = None
    image_url: Optional[str] = None
    audio_url: Optional[str] = None


class PostResponse(BaseModel):
    id: int
    text: Optional[str] = None
    image_url: Optional[str] = None
    audio_url: Optional[str] = None
    user_id: int

    model_config = {
        "from_attributes": True
    }