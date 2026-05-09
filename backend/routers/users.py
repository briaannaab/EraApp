from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from models.base import get_db
from models.user import User
from typing import Optional
from models.post import Post

router = APIRouter()

class UserCreate(BaseModel):
    username: str
    email: str
    bio: Optional[str] = None
    is_creator: bool = False

@router.get("/")
def get_users(db: Session = Depends(get_db)):
    return db.query(User).all()

@router.post("/")
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.username == user.username).first()
    if existing:
        raise HTTPException(status_code=400, detail="Username already taken")
    new_user = User(**user.dict())
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.get("/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/{user_id}/follow")
def follow_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.followers += 1
    db.commit()
    db.refresh(user)
    return user

@router.get("/{username}/profile")
def get_profile(username: str, db: Session = Depends(get_db)):
    user =db.query(User). filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    posts = db.query(Post).filter(Post.username == username).order_by(Post.created_at.desc()).all()

    return{
    "id": user.id,
    "username": user.username,
    "bio": user.bio,
    "is_creator": user.is_creator,
    "followers": user.followers,
    "following": user.following,
    "tips_received": user.tips_received,
    "post_count": len(posts),
    "posts": posts
}