from pydantic import BaseModel
from typing import Optional


class UserCreate(BaseModel):
    id: str
    preferred_username: Optional[str] = None
    email: Optional[str] = None


class UserRead(BaseModel):
    id: str
    preferred_username: Optional[str] = None
    email: Optional[str] = None
