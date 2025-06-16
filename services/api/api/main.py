from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from .core.config import get_config
from .database.database import get_session, init_db
from .database.dao import UserDAO, MessageDAO
from .database.dao import MapStateDAO
from .dto import (
    UserCreate,
    UserRead,
    MessageCreate,
    MessageRead,
)

cfg = get_config()
app = FastAPI(title=cfg.PROJECT_NAME, description=cfg.DESCRIPTION, version=cfg.VERSION)





@app.on_event("startup")
async def on_startup() -> None:
    await init_db()


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/users", response_model=UserRead)
async def create_user(
    payload: UserCreate, session: AsyncSession = Depends(get_session)
) -> UserRead:
    dao = UserDAO(session)
    user = await dao.get_or_create(
        payload.id, payload.preferred_username, payload.email
    )
    return UserRead(
        id=user.id,
        preferred_username=user.preferred_username,
        email=user.email,
    )


@app.post("/messages", response_model=MessageRead)
async def create_message(
    payload: MessageCreate, session: AsyncSession = Depends(get_session)
) -> MessageRead:
    user = await UserDAO(session).get(payload.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="user not found")
    msg = await MessageDAO(session).create(user, payload.message)
    return MessageRead(id=msg.id, user_id=msg.user_id, message=msg.message)


@app.get("/messages", response_model=list[MessageRead])
async def list_messages(session: AsyncSession = Depends(get_session)) -> list[MessageRead]:
    msgs = await MessageDAO(session).list_all()
    return [
        MessageRead(id=m.id, user_id=m.user_id, message=m.message)
        for m in msgs
    ]
