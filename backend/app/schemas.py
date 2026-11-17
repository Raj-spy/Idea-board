from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.models import MAX_IDEA_LENGTH


class IdeaCreate(BaseModel):
    content: str = Field(min_length=1, max_length=MAX_IDEA_LENGTH)

    @field_validator("content", mode="before")
    @classmethod
    def trim_and_validate_content(cls, value: object) -> object:
        if isinstance(value, str):
            if len(value) > MAX_IDEA_LENGTH:
                raise ValueError(f"Idea content must be at most {MAX_IDEA_LENGTH} characters")
            value = value.strip()
            if not value:
                raise ValueError("Idea content must not be blank")
        return value


class IdeaRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    content: str
    created_at: datetime
