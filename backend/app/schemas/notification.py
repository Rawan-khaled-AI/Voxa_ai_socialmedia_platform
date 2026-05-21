from datetime import datetime
from typing import Optional

from pydantic import BaseModel

from app.schemas.user import UserResponse


class NotificationPost(BaseModel):
    id: int
    text: Optional[str] = None

    model_config = {
        "from_attributes": True
    }


class NotificationResponse(BaseModel):
    id: int
    user_id: int
    actor_id: Optional[int] = None
    post_id: Optional[int] = None
    type: str
    is_read: bool
    created_at: datetime

    actor: Optional[UserResponse] = None
    post: Optional[NotificationPost] = None

    model_config = {
        "from_attributes": True
    }