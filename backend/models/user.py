from sqlalchemy import Column, Integer, String, Boolean, Float, DateTime
from sqlalchemy.sql import func
from models.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    bio = Column(String, nullable=True)
    is_creator = Column(Boolean, default=False)
    followers = Column(Integer, default=0)
    following = Column(Integer, default=0)
    tips_received = Column(Float, default=0.0)
    created_at = Column(DateTime, server_default=func.now())