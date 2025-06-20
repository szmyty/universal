from pydantic import BaseModel


class MessageCreate(BaseModel):
    user_id: str
    message: str


class MessageRead(BaseModel):
    id: int
    user_id: str
    message: str
