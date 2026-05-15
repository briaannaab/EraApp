from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from models.base import Base

class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    sender_id = Column(Integer, index=True)
    receiver_id = Column(Integer, index=True)
    sender_username = Column(String)
    receiver_username = Column(String)
    content = Column(String)
    read = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())