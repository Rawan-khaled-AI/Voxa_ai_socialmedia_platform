from datetime import datetime
from pydantic import BaseModel

from app.schemas.user import UserResponse


class CommentCreate(BaseModel):
    post_id: int
    text: str


class CommentResponse(BaseModel):
    id: int
    text: str
    user_id: int
    post_id: int
    created_at: datetime
    user: UserResponse

    model_config = {
        "from_attributes": True
    }