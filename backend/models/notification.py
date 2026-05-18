from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from models.base import Base

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    username = Column(String)
    type = Column(String)  # like, comment, follow, prayer
    message = Column(String)
    read = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())