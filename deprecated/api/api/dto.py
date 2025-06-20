from pydantic import BaseModel
from typing import Optional, Dict, Any

class UserCreate(BaseModel):
    id: str
    preferred_username: Optional[str] = None
    email: Optional[str] = None

class UserRead(BaseModel):
    id: str
    preferred_username: Optional[str] = None
    email: Optional[str] = None

class MessageCreate(BaseModel):
    user_id: str
    message: str

class MessageRead(BaseModel):
    id: int
    user_id: str
    message: str

class MapStateCreate(BaseModel):
    user_id: str
    state: Dict[str, Any]

class MapStateRead(BaseModel):
    id: int
    user_id: str
    state: Dict[str, Any]
