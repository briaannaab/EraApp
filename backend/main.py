from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from backend.routers import posts
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