from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from .core.config import get_config
from .database.database import get_session, init_db
from .database.dao import UserDAO, MessageDAO
from .database.dao import MapStateDAO
from pydantic import BaseModel

cfg = get_config()
app = FastAPI(title=cfg.PROJECT_NAME, description=cfg.DESCRIPTION, version=cfg.VERSION)


class UserCreate(BaseModel):
    id: str
    preferred_username: str | None = None
    email: str | None = None


class MessageCreate(BaseModel):
    user_id: str
    message: str


@app.on_event("startup")
async def on_startup() -> None:
    await init_db()


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/users")
async def create_user(payload: UserCreate, session: AsyncSession = Depends(get_session)):
    dao = UserDAO(session)
    user = await dao.get_or_create(payload.id, payload.preferred_username, payload.email)
    return {"id": user.id, "preferred_username": user.preferred_username, "email": user.email}


@app.post("/messages")
async def create_message(payload: MessageCreate, session: AsyncSession = Depends(get_session)):
    user = await UserDAO(session).get(payload.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="user not found")
    msg = await MessageDAO(session).create(user, payload.message)
    return {"id": msg.id, "user_id": msg.user_id, "message": msg.message}


@app.get("/messages")
async def list_messages(session: AsyncSession = Depends(get_session)):
    msgs = await MessageDAO(session).list_all()
    return [
        {"id": m.id, "user_id": m.user_id, "message": m.message}
        for m in msgs
    ]
