from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from models.base import Base

class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, index=True)
    user_id = Column(Integer, index=True)
    username = Column(String)
    content = Column(String)
    likes = Column(Integer, default=0)
    parent_id = Column(Integer, nullable=True)
    created_at = Column(DateTime, server_default=func.now())