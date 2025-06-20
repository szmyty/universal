from sqlalchemy.ext.asyncio import AsyncSession

from ..infrastructure.user.repository import UserRepository
from ..infrastructure.message.repository import MessageRepository
from ..domain.message import service as domain_service


class MessageService:
    def __init__(self, session: AsyncSession):
        self.user_repo = UserRepository(session)
        self.msg_repo = MessageRepository(session)

    async def create(self, user_id: str, message: str):
        user = await self.user_repo.get(user_id)
        if not user:
            return None
        msg = await self.msg_repo.create(user, message)
        return domain_service.create_message(msg.id, msg.user_id, msg.message)

    async def list_all(self):
        msgs = await self.msg_repo.list_all()
        return [domain_service.create_message(m.id, m.user_id, m.message) for m in msgs]
