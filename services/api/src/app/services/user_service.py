from sqlalchemy.ext.asyncio import AsyncSession

from ..infrastructure.user.repository import UserRepository
from ..domain.user import service as domain_service


class UserService:
    def __init__(self, session: AsyncSession):
        self.repo = UserRepository(session)

    async def get_or_create(self, user_id: str, preferred_username: str | None, email: str | None):
        user_orm = await self.repo.get_or_create(user_id, preferred_username, email)
        return domain_service.create_user(user_orm.id, user_orm.preferred_username, user_orm.email)
