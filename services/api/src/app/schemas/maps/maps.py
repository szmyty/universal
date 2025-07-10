from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.auth.oidc_user import OIDCUser


class MapBase(BaseModel):
    """Shared fields for creating or reading a map."""

    name: str = Field(..., examples=["My Map"])
    description: str = Field(..., examples=["My map description"])
    state: str = Field(..., examples=["{...}"])


class MapCreate(MapBase):
    """Schema for creating a new map."""
    pass


class MapUpdate(BaseModel):
    """Schema for updating a map."""
    name: str
    description: str
    state: str


class MapRead(MapBase):
    """Schema for reading a map (includes metadata)."""

    id: int
    user_id: str
    user: OIDCUser
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

class MapSave(MapBase):
    """Model for creating or updating a map."""
    id: int | None = None
