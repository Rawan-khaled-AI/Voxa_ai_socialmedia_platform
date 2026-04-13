from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="VOXA Backend",
    description="Backend API for VOXA voice-based social media platform",
    version="1.0.0",
)

# Allow Flutter app to talk to backend during development
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
        "message": "VOXA backend is running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "ok"
    }


@app.get("/posts")
def get_posts():
    return {
        "posts": [
            {
                "id": 1,
                "username": "voxa",
                "text": "Welcome to VOXA",
                "image_url": None,
                "audio_url": None,
            }
        ]
    }