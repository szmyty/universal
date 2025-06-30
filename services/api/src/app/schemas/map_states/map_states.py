from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field

from app.auth.oidc_user import OIDCUser


class MapStateBase(BaseModel):
    """Base model for map states."""

    name: str = Field(..., examples=["My Map"])
    description: str = Field(..., examples=["My map description"])
    state: str = Field(..., examples=["{...}"])


class MapStateCreate(MapStateBase):
    """Model for creating a map state."""

    pass


class MapStateUpdate(BaseModel):
    """Model for updating a map state."""

    name: str
    description: str
    state: str


class MapStateRead(MapStateBase):
    """Model for reading a map state."""

    id: int
    user_id: str
    user: OIDCUser
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
