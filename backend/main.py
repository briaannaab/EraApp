from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from routers import posts, users, ai, payments, media, auth, comments, messages, notifications, reports
from models.base import Base, engine
from models import user, post, comment, message, notification
import os

load_dotenv(dotenv_path='/workspaces/EraApp/backend/.env')

app = FastAPI(title="Era API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"status": "ok", "app": "Era"}

app.include_router(posts.router, prefix="/posts", tags=["posts"])
app.include_router(users.router, prefix="/users", tags=["users"])
app.include_router(ai.router, prefix="/ai", tags=["ai"])
app.include_router(payments.router, prefix="/payments", tags=["payments"])
app.include_router(media.router, prefix="/media", tags=["media"])
app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(comments.router, prefix="/comments", tags=["comments"])
app.include_router(messages.router, prefix="/messages", tags=["messages"])
app.include_router(notifications.router, prefix="/notifications", tags=["notifications"])
app.include_router(reports.router, prefix="/reports", tags=["reports"])

Base.metadata.create_all(bind=engine)
