from sqlalchemy import Column, Integer, String, Float, DateTime, ARRAY
from sqlalchemy.sql import func
from models.base import Base

class Post(Base):
    __tablename__ = "posts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    username = Column(String)
    content = Column(String)
    media_url = Column(String, nullable=True)
    tags = Column(ARRAY(String), default=[])
    likes = Column(Integer, default=0)
    tips = Column(Float, default=0.0)
    created_at = Column(DateTime, server_default=func.now())