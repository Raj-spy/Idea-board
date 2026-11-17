from datetime import datetime, timezone

from sqlalchemy import CheckConstraint, DateTime, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base

MAX_IDEA_LENGTH = 1000


class Idea(Base):
    __tablename__ = "ideas"
    __table_args__ = (
        CheckConstraint("length(trim(content)) > 0", name="ck_ideas_content_not_blank"),
        CheckConstraint(
            f"length(content) <= {MAX_IDEA_LENGTH}",
            name="ck_ideas_content_max_length",
        ),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
    )
