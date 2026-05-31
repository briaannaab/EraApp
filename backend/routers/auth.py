from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from models.base import get_db
from models.user import User
from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta
from pydantic import BaseModel
from dotenv import load_dotenv
import os

load_dotenv(dotenv_path='/workspaces/EraApp/backend/.env')

SECRET_KEY = os.getenv("JWT_SECRET", "era-super-secret-key")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
router = APIRouter()

class RegisterRequest(BaseModel):
    username: str
    email: str
    password: str
    bio: str = ""
    is_creator: bool = False

class LoginRequest(BaseModel):
    username: str
    password: str

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def create_token(data: dict) -> str:
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    data.update({"exp": expire})
    return jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

@router.post("/register")
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.username == request.username).first():
        raise HTTPException(status_code=400, detail="Username already taken")
    if db.query(User).filter(User.email == request.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    user = User(
        username=request.username,
        email=request.email,
        password=hash_password(request.password),
        bio=request.bio,
        is_creator=request.is_creator
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_token({"sub": str(user.id), "username": user.username})
    return {"access_token": token, "token_type": "bearer", "user": {
        "id": user.id,
        "username": user.username,
        "email": user.email,
        "is_creator": user.is_creator
    }}

@router.post("/login")
def login(request: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == request.username).first()
    if not user or not verify_password(request.password, user.password):
        raise HTTPException(status_code=401, detail="Invalid username or password")

    token = create_token({"sub": str(user.id), "username": user.username})
    return {"access_token": token, "token_type": "bearer", "user": {
        "id": user.id,
        "username": user.username,
        "email": user.email,
        "is_creator": user.is_creator
    }}

class ResetPasswordRequest(BaseModel):
    email: str
    new_password: str

@router.post("/reset-password")
def reset_password(request: ResetPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="No account found with that email")
    user.password = hash_password(request.new_password)
    db.commit()
    return {"message": "Password reset successfully"}
