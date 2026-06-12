from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.api.routes.auth import router as auth_router
from app.api.routes.posts import router as posts_router
from app.api.routes.upload import router as upload_router
from app.api.routes.users import router as users_router
from app.api.routes.comments import router as comments_router
from app.api.routes.likes import router as likes_router
from app.api.routes.follows import router as follows_router
from app.api.routes.notifications import router as notifications_router

from app.core.config import settings

from app.models import (
    post,
    user,
    comment,
    like,
    follow,
    notification,
    password_reset_code,
)

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
    return {
        "message": "VOXA backend is running",
    }


@app.get("/health")
def health_check():
    return {
        "status": "ok",
    }


app.include_router(auth_router)
app.include_router(posts_router)
app.include_router(upload_router)
app.include_router(users_router)
app.include_router(comments_router)
app.include_router(likes_router)
app.include_router(follows_router)
app.include_router(notifications_router)

app.mount(
    "/uploads",
    StaticFiles(directory="uploads"),
    name="uploads",
)