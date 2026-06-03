from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from models.base import get_db
from models.user import User
from models.post import Post
from typing import Optional

router = APIRouter()

class UserCreate(BaseModel):
    username: str
    email: str
    bio: Optional[str] = None
    is_creator: bool = False

class UserUpdate(BaseModel):
    bio: Optional[str] = None
    voice_bio_url: Optional[str] = None

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

@router.get("/{username}/profile")
def get_profile(username: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    posts = db.query(Post).filter(Post.username == username).order_by(Post.created_at.desc()).all()
    return {
        "id": user.id,
        "username": user.username,
        "bio": user.bio,
        "is_creator": user.is_creator,
        "followers": user.followers,
        "following": user.following,
        "tips_received": user.tips_received,
        "post_count": len(posts),
        "posts": posts,
        "profile_picture_url": user.profile_picture_url,
        "voice_bio_url": user.voice_bio_url,
        "subscription_price": user.subscription_price if hasattr(user, 'subscription_price') else 0,
        "is_creator_subscription": user.is_creator_subscription if hasattr(user, 'is_creator_subscription') else False,
        "aura_theme": user.aura_theme if hasattr(user, 'aura_theme') else 'default',
        "aura_color": user.aura_color if hasattr(user, 'aura_color') else None,
    }

@router.get("/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.put("/{user_id}")
def update_user(user_id: int, data: UserUpdate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if data.bio is not None:
        user.bio = data.bio
    if data.voice_bio_url is not None:
        user.voice_bio_url = data.voice_bio_url
    db.commit()
    db.refresh(user)
    return user

@router.post("/{user_id}/follow")
def follow_user(user_id: int, follow_id: int = 1, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.followers += 1
    # also increment follower's following count
    follower = db.query(User).filter(User.id == follow_id).first()
    if follower:
        follower.following += 1
    db.commit()
    db.refresh(user)
    return user

@router.get("/{user_id}/followers")
def get_followers(user_id: int, db: Session = Depends(get_db)):
    # For now return all users as placeholder
    # In a full app you'd have a followers junction table
    return db.query(User).all()

@router.get("/{user_id}/following")
def get_following(user_id: int, db: Session = Depends(get_db)):
    return db.query(User).all()

@router.post("/{user_id}/profile-picture")
def update_profile_picture(user_id: int, url: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.profile_picture_url = url
    db.commit()
    return {"message": "Profile picture updated"}


class AuraUpdate(BaseModel):
    theme: str = 'default'
    color: str = None

@router.post("/{user_id}/aura")
def update_aura(user_id: int, data: AuraUpdate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.aura_theme = data.theme
    user.aura_color = data.color
    db.commit()
    return {"message": "Aura updated"}
