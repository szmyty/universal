from sqlalchemy import Column, String
from sqlalchemy.orm import relationship

from .base import Base

USERS_TABLE_NAME = "users"

class User(Base):
    """User account information."""

    __tablename__ = USERS_TABLE_NAME

    id = Column(String, primary_key=True)
    preferred_username = Column(String, nullable=True)
    email = Column(String, nullable=True)

    messages = relationship("Message", back_populates="user", cascade="all, delete-orphan")
    map_states = relationship("MapState", back_populates="user", cascade="all, delete-orphan")
