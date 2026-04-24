from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

router = APIRouter()

users = []

class UserCreate(BaseModel):
    username: str
    email: str
    bio: Optional[str] = None
    is_creator: bool = False

@router.get("/")
def get_users():
    return users

@router.post("/")
def create_user(user: UserCreate):
    new_user = {
        "id": len(users) + 1,
        **user.dict(),
        "followers": 0,
        "following": 0,
        "tips_received": 0.0,
        "created_at": datetime.utcnow().isoformat()
    }
    users.append(new_user)
    return new_user

@router.get("/{user_id}")
def get_user(user_id: int):
    user = next((u for u in users if u["id"] == user_id), None)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/{user_id}/follow")
def follow_user(user_id: int):
    user = next((u for u in users if u["id"] == user_id), None)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user["followers"] += 1
    return user