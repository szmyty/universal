from sqlalchemy import Column, Integer, Text, DateTime, func, ForeignKey, String
from sqlalchemy.orm import relationship

from .base import Base
from .user import USERS_TABLE_NAME

MESSAGES_TABLE_NAME = "messages"

class Message(Base):
    """Message posted by a user."""

    __tablename__ = MESSAGES_TABLE_NAME

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey(f"{USERS_TABLE_NAME}.id"), nullable=False)
    message = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

    user = relationship("User", back_populates="messages")
