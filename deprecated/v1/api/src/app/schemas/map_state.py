from pydantic import BaseModel
from typing import Any


class MapStateCreate(BaseModel):
    user_id: str
    state: dict[str, Any]


class MapStateRead(BaseModel):
    id: int
    user_id: str
    state: dict[str, Any]
