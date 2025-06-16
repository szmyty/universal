from sqlalchemy import Column, Integer, String, Text, DataTime, func, ForeignKey
from sqlalchemy.orm import relationship

from .base import Base
from .user import USERS_TABLE_NAME

MESSAGES_TABLE_NAME = "messages"

class Message(Base):
    __tablename__ = MESSAGES_TABLE_NAME

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey(f'{USERS_TABLE_NAME}.id'), nullable=False)
    message = Column(Text, nullable=False)
    created_at = Column(DataTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(
        DataTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )

    user = relationship("User", back_populates="messages")

    def __repr__(self):
        return f"<Message(id={self.id}, user_id={self.user_id}, content={self.content[:20]}, timestamp={self.timestamp})>"
