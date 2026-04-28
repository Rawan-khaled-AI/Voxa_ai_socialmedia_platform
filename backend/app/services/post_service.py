from sqlalchemy.orm import Session

from app.models.post import Post


def create_post(
    db: Session,
    user_id: int,
    text: str | None = None,
    image_url: str | None = None,
    audio_url: str | None = None,
):
    post = Post(
        text=text,
        image_url=image_url,
        audio_url=audio_url,
        user_id=user_id,
    )
    db.add(post)
    db.commit()
    db.refresh(post)
    return post


def get_all_posts(db: Session):
    return db.query(Post).order_by(Post.id.desc()).all()