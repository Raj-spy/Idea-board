import logging

from sqlalchemy.exc import SQLAlchemyError

from app.database import Base, engine
from app import models  # noqa: F401

logger = logging.getLogger(__name__)


def initialize_database() -> None:
    try:
        Base.metadata.create_all(bind=engine)
    except SQLAlchemyError:
        logger.exception(
            "Database schema initialization failed",
            extra={"event": "database_initialization_failed"},
        )
        raise
    logger.info("Database schema initialized", extra={"event": "database_initialized"})


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    initialize_database()
