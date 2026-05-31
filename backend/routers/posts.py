from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from models.base import get_db
from models.post import Post
from typing import Optional
from collections import Counter
import re

router = APIRouter()

class PostCreate(BaseModel):
    user_id: int
    username: str
    content: str
    media_url: Optional[str] = None
    tags: Optional[list[str]] = []
    vibe: Optional[str] = None

@router.get("/vibe/{vibe_name}")
def get_posts_by_vibe(vibe_name: str, db: Session = Depends(get_db)):
    """Get posts filtered by vibe."""
    return db.query(Post).filter(
        Post.vibe == vibe_name
    ).order_by(Post.created_at.desc()).all()

@router.get("/")
def get_posts(db: Session = Depends(get_db)):
    return db.query(Post).order_by(Post.created_at.desc()).all()

@router.post("/")
def create_post(post: PostCreate, db: Session = Depends(get_db)):
    new_post = Post(**post.dict())
    db.add(new_post)
    db.commit()
    db.refresh(new_post)
    return new_post

@router.get("/trending")
def get_trending(db: Session = Depends(get_db)):
    """Get trending hashtags from posts."""
    posts = db.query(Post).all()
    all_tags = []
    for post in posts:
        hashtags = re.findall(r'#\w+', post.content or '')
        all_tags.extend([tag.lower() for tag in hashtags])
        if post.tags:
            all_tags.extend([f'#{tag.lower()}' for tag in post.tags])
    counts = Counter(all_tags)
    trending = [
        {'tag': tag, 'posts': f'{count}'}
        for tag, count in counts.most_common(10)
    ]
    return trending

@router.delete("/{post_id}")
def delete_post(post_id: int, db: Session = Depends(get_db)):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    db.delete(post)
    db.commit()
    return {"message": "Post deleted"}

@router.get("/{post_id}")
def get_post(post_id: int, db: Session = Depends(get_db)):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    return post

@router.post("/{post_id}/like")
def like_post(post_id: int, db: Session = Depends(get_db)):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    post.likes += 1
    db.commit()
    db.refresh(post)
    return post

@router.get("/moments/")
def get_moments(db: Session = Depends(get_db)):
    from datetime import datetime, timedelta
    cutoff = datetime.utcnow() - timedelta(hours=24)
    moments = db.query(Post).filter(
        Post.is_moment == True,
        Post.created_at >= cutoff
    ).order_by(Post.created_at.desc()).all()
    return moments

@router.get("/feed/")
def get_feed(db: Session = Depends(get_db)):
    posts = db.query(Post).filter(
        Post.is_moment == False
    ).order_by(Post.created_at.desc()).all()
    return posts
