from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from models.base import get_db
from models.notification import Notification

router = APIRouter()

@router.get("/{username}")
def get_notifications(username: str, db: Session = Depends(get_db)):
    return db.query(Notification).filter(
        Notification.username == username
    ).order_by(Notification.created_at.desc()).all()

@router.post("/{notification_id}/read")
def mark_read(notification_id: int, db: Session = Depends(get_db)):
    notif = db.query(Notification).filter(Notification.id == notification_id).first()
    if notif:
        notif.read = True
        db.commit()
    return {"message": "Marked as read"}

@router.post("/mark-all-read/{username}")
def mark_all_read(username: str, db: Session = Depends(get_db)):
    db.query(Notification).filter(
        Notification.username == username,
        Notification.read == False
    ).update({"read": True})
    db.commit()
    return {"message": "All marked as read"}