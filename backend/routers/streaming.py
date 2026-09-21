from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from models.base import get_db
from models.user import User
import os
from livekit import api

router = APIRouter()

LIVEKIT_URL = os.getenv("LIVEKIT_URL")
LIVEKIT_API_KEY = os.getenv("LIVEKIT_API_KEY")
LIVEKIT_API_SECRET = os.getenv("LIVEKIT_API_SECRET")

@router.post("/stream/start/{username}")
async def start_stream(username: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Create a room token for the host
    token = api.AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET)
    token.with_identity(username)
    token.with_name(username)
    token.with_grants(api.VideoGrants(
        room_join=True,
        room=f"stream_{username}",
        can_publish=True,
        can_subscribe=True,
    ))
    
    # Mark user as live
    user.is_live = True
    db.commit()
    
    return {
        "token": token.to_jwt(),
        "url": LIVEKIT_URL,
        "room": f"stream_{username}"
    }

@router.post("/stream/stop/{username}")
async def stop_stream(username: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.is_live = False
    db.commit()
    
    return {"message": "Stream ended"}

@router.get("/stream/join/{username}")
async def join_stream(username: str, viewer: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == username).first()
    if not user or not user.is_live:
        raise HTTPException(status_code=404, detail="Stream not found or not live")
    
    # Create viewer token
    token = api.AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET)
    token.with_identity(viewer)
    token.with_name(viewer)
    token.with_grants(api.VideoGrants(
        room_join=True,
        room=f"stream_{username}",
        can_publish=False,
        can_subscribe=True,
    ))
    
    return {
        "token": token.to_jwt(),
        "url": LIVEKIT_URL,
        "room": f"stream_{username}"
    }

@router.get("/stream/live")
async def get_live_streams(db: Session = Depends(get_db)):
    live_users = db.query(User).filter(User.is_live == True).all()
    return [{"username": u.username, "profile_picture_url": u.profile_picture_url} for u in live_users]
