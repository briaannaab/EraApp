from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import text
from models.base import get_db
from typing import Optional

router = APIRouter()

class ReportCreate(BaseModel):
    reporter_username: str
    reported_username: Optional[str] = None
    post_id: Optional[int] = None
    reason: str
    description: Optional[str] = ""

@router.post("/")
def create_report(report: ReportCreate, db: Session = Depends(get_db)):
    db.execute(
        text("""INSERT INTO reports 
            (reporter_username, reported_username, post_id, reason, description)
            VALUES (:reporter, :reported, :post_id, :reason, :description)"""),
        {
            "reporter": report.reporter_username,
            "reported": report.reported_username,
            "post_id": report.post_id,
            "reason": report.reason,
            "description": report.description,
        }
    )
    db.commit()
    return {"message": "Report submitted successfully"}

@router.get("/")
def get_reports(db: Session = Depends(get_db)):
    result = db.execute(text("SELECT * FROM reports ORDER BY created_at DESC")).fetchall()
    return [dict(r._mapping) for r in result]

@router.post("/{report_id}/resolve")
def resolve_report(report_id: int, db: Session = Depends(get_db)):
    db.execute(
        text("UPDATE reports SET status = 'resolved' WHERE id = :id"),
        {"id": report_id}
    )
    db.commit()
    return {"message": "Report resolved"}

@router.post("/{report_id}/dismiss")
def dismiss_report(report_id: int, db: Session = Depends(get_db)):
    db.execute(
        text("UPDATE reports SET status = 'dismissed' WHERE id = :id"),
        {"id": report_id}
    )
    db.commit()
    return {"message": "Report dismissed"}
