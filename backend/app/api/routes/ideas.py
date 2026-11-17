import logging

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Idea
from app.schemas import IdeaCreate, IdeaRead

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/ideas", tags=["ideas"])


@router.get("", response_model=list[IdeaRead])
def list_ideas(db: Session = Depends(get_db)) -> list[Idea]:
    try:
        return list(db.scalars(select(Idea).order_by(Idea.created_at.desc(), Idea.id.desc())))
    except SQLAlchemyError as exc:
        logger.exception(
            "Could not retrieve ideas",
            extra={"event": "ideas_list_failed", "error_type": type(exc).__name__},
        )
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Ideas are temporarily unavailable",
        ) from exc


@router.post("", response_model=IdeaRead, status_code=status.HTTP_201_CREATED)
def create_idea(payload: IdeaCreate, db: Session = Depends(get_db)) -> Idea:
    idea = Idea(content=payload.content)
    try:
        db.add(idea)
        db.commit()
        db.refresh(idea)
    except SQLAlchemyError as exc:
        db.rollback()
        logger.exception(
            "Could not create idea",
            extra={"event": "idea_create_failed", "error_type": type(exc).__name__},
        )
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Idea could not be saved",
        ) from exc

    return idea
