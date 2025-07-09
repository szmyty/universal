from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel

from app.auth.oidc_user import OIDCUser
from app.db.entities.map import Map

class MapDomain(BaseModel):
    """Domain model for a map object."""

    id: int
    user_id: str
    name: str
    description: str
    state: str
    user: Optional[OIDCUser] = None  # Populated post-fetch if needed
    created_at: datetime
    updated_at: datetime

    @classmethod
    def from_entity(cls: type[MapDomain], db_obj: Map) -> MapDomain:
        """Create a MapDomain from a DB entity."""
        return cls(
            id=db_obj.id,
            user_id=db_obj.user_id,
            name=db_obj.name,
            description=db_obj.description,
            state=db_obj.state,
            user=None,  # Lazy-injected from /me context
            created_at=db_obj.created_at,
            updated_at=db_obj.updated_at,
        )

    model_config = {
        "from_attributes": True,  # Enables .model_validate from SQLAlchemy object
    }
