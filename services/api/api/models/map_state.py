from sqlalchemy import Column, Integer, JSON, DateTime, func, ForeignKey, String
from sqlalchemy.orm import relationship

from .base import Base
from .user import USERS_TABLE_NAME

MAP_STATES_TABLE_NAME = "map_states"

class MapState(Base):
    """Persisted map state for a user."""

    __tablename__ = MAP_STATES_TABLE_NAME

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey(f"{USERS_TABLE_NAME}.id"), nullable=False)
    state = Column(JSON, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

    user = relationship("User", back_populates="map_states")
