from sqlalchemy import Column, Integer, String, Boolean, Float, DateTime
from sqlalchemy.sql import func
from models.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String, nullable=False, default="")
    bio = Column(String, nullable=True)
    is_creator = Column(Boolean, default=False)
    is_creator_subscription = Column(Boolean, default=False)
    subscription_price = Column(Float, default=0.0)
    followers = Column(Integer, default=0)
    following = Column(Integer, default=0)
    tips_received = Column(Float, default=0.0)
    created_at = Column(DateTime, server_default=func.now())
    voice_bio_url = Column(String, nullable=True)
    profile_picture_url = Column(String, nullable=True)
    aura_theme = Column(String, default='default')
    aura_color = Column(String, nullable=True)