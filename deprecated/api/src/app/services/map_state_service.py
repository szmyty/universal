from sqlalchemy.ext.asyncio import AsyncSession

from ..infrastructure.user.repository import UserRepository
from ..infrastructure.map_state.repository import MapStateRepository
from ..domain.map_state import service as domain_service


class MapStateService:
    def __init__(self, session: AsyncSession):
        self.user_repo = UserRepository(session)
        self.repo = MapStateRepository(session)

    async def create(self, user_id: str, state: dict):
        user = await self.user_repo.get(user_id)
        if not user:
            return None
        obj = await self.repo.create(user, state)
        return domain_service.create_map_state(obj.id, obj.user_id, obj.state)

    async def list_all(self):
        objs = await self.repo.list_all()
        return [domain_service.create_map_state(o.id, o.user_id, o.state) for o in objs]
