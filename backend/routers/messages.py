from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from models.base import get_db
from models.message import Message
from sqlalchemy import or_, and_

router = APIRouter()

class MessageCreate(BaseModel):
    sender_id: int
    receiver_id: int
    sender_username: str
    receiver_username: str
    content: str

@router.post("/")
def send_message(message: MessageCreate, db: Session = Depends(get_db)):
    new_message = Message(**message.dict())
    db.add(new_message)
    db.commit()
    db.refresh(new_message)
    return new_message

@router.get("/conversation/{user1}/{user2}")
def get_conversation(user1: str, user2: str, db: Session = Depends(get_db)):
    messages = db.query(Message).filter(
        or_(
            and_(Message.sender_username == user1, Message.receiver_username == user2),
            and_(Message.sender_username == user2, Message.receiver_username == user1)
        )
    ).order_by(Message.created_at.asc()).all()
    return messages

@router.get("/inbox/{username}")
def get_inbox(username: str, db: Session = Depends(get_db)):
    """Get list of unique conversations for a user."""
    messages = db.query(Message).filter(
        or_(
            Message.sender_username == username,
            Message.receiver_username == username
        )
    ).order_by(Message.created_at.desc()).all()
    
    # Get unique conversations
    seen = set()
    conversations = []
    for msg in messages:
        other = msg.receiver_username if msg.sender_username == username else msg.sender_username
        if other not in seen:
            seen.add(other)
            conversations.append({
                "username": other,
                "last_message": msg.content,
                "created_at": msg.created_at
            })
    return conversations