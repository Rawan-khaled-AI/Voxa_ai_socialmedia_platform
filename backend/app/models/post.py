from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from app.core.database import Base


class Post(Base):
    __tablename__ = "posts"

    id = Column(Integer, primary_key=True, index=True)

    text = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)
    audio_url = Column(String(500), nullable=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    repost_of_post_id = Column(
        Integer,
        ForeignKey("posts.id"),
        nullable=True,
    )

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False,
    )

    user = relationship("User", back_populates="posts")

    original_post = relationship(
        "Post",
        remote_side=[id],
        foreign_keys=[repost_of_post_id],
    )

    likes = relationship(
        "Like",
        back_populates="post",
        cascade="all, delete-orphan",
    )

    comments = relationship(
        "Comment",
        back_populates="post",
        cascade="all, delete-orphan",
    )