from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.auth import router as auth_router
from app.api.posts import router as posts_router
from app.core.config import settings
from app.models import post, user  # مهم لتسجيل المودلز مع SQLAlchemy/Alembic
from app.api.upload import router as upload_router
from fastapi.staticfiles import StaticFiles

app = FastAPI(
    title=settings.app_name,
    description="Backend API for VOXA voice-based social media platform",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"message": "VOXA backend is running"}


@app.get("/health")
def health_check():
    return {"status": "ok"}


app.include_router(auth_router)
app.include_router(posts_router)
app.include_router(upload_router)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
