from fastapi import APIRouter
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
import os

load_dotenv(dotenv_path='/workspaces/EraApp/backend/.env')


router = APIRouter()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

class CaptionRequest(BaseModel):
    content: str
    tags: list[str] = []
    tone: str = "authentic"  # authentic, hype, professional, casual

class CaptionResponse(BaseModel):
    caption: str
    hashtags: list[str]

@router.post("/caption")
def generate_caption(request: CaptionRequest):
    """Generate an AI caption for a post."""
    prompt = f"""You are a social media assistant for Era, a creator-first platform.
Generate a {request.tone} caption for this content: "{request.content}"
Tags/topics: {', '.join(request.tags)}

Return JSON with:
- caption: a punchy, engaging caption (max 150 chars)
- hashtags: list of 5 relevant hashtags without the # symbol

Return only valid JSON, no other text."""

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=300,
        temperature=0.8
    )

    import json
    result = json.loads(response.choices[0].message.content)
    return result

