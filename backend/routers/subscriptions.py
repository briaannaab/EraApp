from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import text
from models.base import get_db
from models.user import User
import stripe
import os

router = APIRouter()

stripe.api_key = os.getenv('STRIPE_SECRET_KEY')

class SubscribeRequest(BaseModel):
    subscriber_id: int
    subscriber_username: str
    creator_username: str
    payment_method_id: str = None

class CreatorSetup(BaseModel):
    user_id: int
    price: float
    enable: bool

@router.post("/setup-creator")
def setup_creator(data: CreatorSetup, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == data.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_creator = True
    user.is_creator_subscription = data.enable
    user.subscription_price = data.price
    db.commit()
    return {"message": "Creator subscription setup complete"}

@router.post("/subscribe")
def subscribe(data: SubscribeRequest, db: Session = Depends(get_db)):
    creator = db.query(User).filter(User.username == data.creator_username).first()
    if not creator:
        raise HTTPException(status_code=404, detail="Creator not found")
    
    # Check if already subscribed
    existing = db.execute(
        text("SELECT * FROM subscriptions WHERE subscriber_id = :sid AND creator_username = :cun AND status = 'active'"),
        {"sid": data.subscriber_id, "cun": data.creator_username}
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Already subscribed")

    # Create Stripe payment intent
    try:
        if data.payment_method_id and stripe.api_key:
            intent = stripe.PaymentIntent.create(
                amount=int(creator.subscription_price * 100),
                currency="usd",
                payment_method=data.payment_method_id,
                confirm=True,
                automatic_payment_methods={"enabled": True, "allow_redirects": "never"},
            )
            if intent.status != 'succeeded':
                raise HTTPException(status_code=400, detail="Payment failed")
    except stripe.error.StripeError as e:
        raise HTTPException(status_code=400, detail=str(e))

    db.execute(
        text("""INSERT INTO subscriptions 
            (subscriber_id, subscriber_username, creator_id, creator_username, price)
            VALUES (:sid, :sun, :cid, :cun, :price)"""),
        {
            "sid": data.subscriber_id,
            "sun": data.subscriber_username,
            "cid": creator.id,
            "cun": data.creator_username,
            "price": creator.subscription_price,
        }
    )
    db.commit()
    return {"message": f"Subscribed to {data.creator_username}"}

@router.delete("/unsubscribe/{creator_username}/{subscriber_id}")
def unsubscribe(creator_username: str, subscriber_id: int, db: Session = Depends(get_db)):
    db.execute(
        text("UPDATE subscriptions SET status = 'cancelled' WHERE creator_username = :cun AND subscriber_id = :sid"),
        {"cun": creator_username, "sid": subscriber_id}
    )
    db.commit()
    return {"message": "Unsubscribed"}

@router.get("/check/{creator_username}/{subscriber_id}")
def check_subscription(creator_username: str, subscriber_id: int, db: Session = Depends(get_db)):
    result = db.execute(
        text("SELECT * FROM subscriptions WHERE creator_username = :cun AND subscriber_id = :sid AND status = 'active'"),
        {"cun": creator_username, "sid": subscriber_id}
    ).first()
    return {"is_subscribed": result is not None}

@router.get("/subscribers/{creator_username}")
def get_subscribers(creator_username: str, db: Session = Depends(get_db)):
    result = db.execute(
        text("SELECT COUNT(*) as count FROM subscriptions WHERE creator_username = :cun AND status = 'active'"),
        {"cun": creator_username}
    ).first()
    return {"count": result.count if result else 0}

@router.get("/creator-earnings/{creator_username}")
def get_earnings(creator_username: str, db: Session = Depends(get_db)):
    result = db.execute(
        text("SELECT SUM(price) as total FROM subscriptions WHERE creator_username = :cun AND status = 'active'"),
        {"cun": creator_username}
    ).first()
    return {"total": float(result.total or 0)}
