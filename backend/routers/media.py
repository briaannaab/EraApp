from fastapi import APIRouter, UploadFile, File, HTTPException
from dotenv import load_dotenv
import cloudinary
import cloudinary.uploader
import pillow_heif 
from PIL import Image
import io
import os

load_dotenv(dotenv_path='/workspaces/EraApp/backend/.env')

pillow_heif.register_heif_opener()

cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET")
)

router = APIRouter()

@router.post("/upload/image")
async def upload_image(file: UploadFile = File(...)):
    contents = await file.read()
    
    # Convert HEIC to JPEG if needed
    if file.filename and file.filename.lower().endswith('.heic'):
        image = Image.open(io.BytesIO(contents))
        output = io.BytesIO()
        image.save(output, format='JPEG')
        contents = output.getvalue()

    result = cloudinary.uploader.upload(
        contents,
        folder="era/images",
        resource_type="auto"
    )
    return {
        "url": result["secure_url"],
        "public_id": result["public_id"],
        "width": result.get("width"),
        "height": result.get("height")
    }

@router.post("/upload/video")
async def upload_video(file: UploadFile = File(...)):
    """Upload a video to Cloudinary."""
    if not file.content_type.startswith("video/"):
        raise HTTPException(status_code=400, detail="File must be a video")
    
    contents = await file.read()
    result = cloudinary.uploader.upload(
        contents,
        folder="era/videos",
        resource_type="video"
    )
    return {
        "url": result["secure_url"],
        "public_id": result["public_id"],
        "duration": result.get("duration"),
        "format": result["format"]
    }