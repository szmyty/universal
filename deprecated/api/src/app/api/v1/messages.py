from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from ...deps import get_db
from ...services.message_service import MessageService
from ...schemas.message import MessageCreate, MessageRead

router = APIRouter()


@router.post("/messages", response_model=MessageRead)
async def create_message(payload: MessageCreate, session: AsyncSession = Depends(get_db)):
    svc = MessageService(session)
    msg = await svc.create(payload.user_id, payload.message)
    if not msg:
        raise HTTPException(status_code=404, detail="user not found")
    return MessageRead.model_validate(msg.__dict__)


@router.get("/messages", response_model=list[MessageRead])
async def list_messages(session: AsyncSession = Depends(get_db)):
    svc = MessageService(session)
    msgs = await svc.list_all()
    return [MessageRead.model_validate(m.__dict__) for m in msgs]
