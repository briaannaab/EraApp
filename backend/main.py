from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from routers import posts
from routers import users
from routers import ai
from models.base import Base, engine
from models import user, post
from routers import payments
import os

load_dotenv(dotenv_path='/workspaces/EraApp/backend/.env')

app = FastAPI(title="Era API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"status": "ok", "app": "Era"}

app.include_router(posts.router, prefix="/posts", tags=["posts"])
app.include_router(users.router, prefix="/users", tags=["users"])
app.include_router(ai.router, prefix="/ai", tags=["ai"])
app.include_router(payments.router, prefix="/payments", tags=["payments"])

Base.metadata.create_all(bind=engine)