from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from models.base import get_db
from models.user import User
from models.post import Post
from dotenv import load_dotenv
import stripe
import os

load_dotenv(dotenv_path='/workspaces/EraApp/backend/.env')
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")

router = APIRouter()

class TipRequest(BaseModel):
    amount: int  # in cents (500 = $5.00)
    post_id: int
    tipper_username: str

class SubscribeRequest(BaseModel):
    creator_id: int
    subscriber_username: str

@router.post("/tip")
def tip_creator(request: TipRequest, db: Session = Depends(get_db)):
    """Send a tip to a creator via Stripe."""
    post = db.query(Post).filter(Post.id == request.post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    # Create Stripe payment intent
    intent = stripe.PaymentIntent.create(
        amount=request.amount,
        currency="usd",
        metadata={
            "post_id": request.post_id,
            "tipper": request.tipper_username,
            "creator": post.username
        }
    )

    # Update post tips
    post.tips += request.amount / 100
    db.commit()

    return {
        "client_secret": intent.client_secret,
        "amount": request.amount / 100,
        "creator": post.username,
        "message": f"Tip of ${request.amount / 100} sent to {post.username}!"
    }

@router.get("/creator/{username}/earnings")
def get_earnings(username: str, db: Session = Depends(get_db)):
    """Get total tips earned by a creator."""
    posts = db.query(Post).filter(Post.username == username).all()
    total = sum(p.tips for p in posts)
    return {
        "username": username,
        "total_earnings": total,
        "post_count": len(posts)
    }