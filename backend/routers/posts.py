from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
from typing import Optional


router = APIRouter()

# Temporary in-memory store until we wire up the DB
posts = []

class PostCreate(BaseModel):
    user_id: str
    username: str
    content: str
    media_url: Optional[str] = None
    tags: Optional[list[str]] = []

class Post(BaseModel):
    id: int
    user_id: str
    username: str
    content: str
    media_url: Optional[str] = None
    tags: list[str] = []
    likes: int = 0
    tips: float = 0.0
    created_at: datetime

@router.get("/")
def get_posts():
    """Get all posts in chronological order."""
    return sorted(posts, key=lambda p: p["created_at"], reverse=True)

@router.post("/")
def create_post(post: PostCreate):
    """Create a new post."""
    new_post = {
        "id": len(posts) + 1,
        **post.dict(),
        "likes": 0,
        "tips": 0.0,
        "created_at": datetime.utcnow().isoformat()
    }
    posts.append(new_post)
    return new_post

@router.get("/{post_id}")
def get_post(post_id: int):
    """Get a single post by ID."""
    post = next((p for p in posts if p["id"] == post_id), None)
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    return post

@router.post("/{post_id}/like")
def like_post(post_id: int):
    """Like a post."""
    post = next((p for p in posts if p["id"] == post_id), None)
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    post["likes"] += 1
    return post