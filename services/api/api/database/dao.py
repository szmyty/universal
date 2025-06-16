from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
import structlog

log = structlog.get_logger(__name__)

from .models import User, Message, MapState


class BaseDAO:
    def __init__(self, session: AsyncSession):
        """Store the database session for DAO operations."""
        self.session = session


class UserDAO(BaseDAO):
    async def get(self, user_id: str) -> User | None:
        """Retrieve a user by primary key."""
        return await self.session.get(User, user_id)

    async def create(
        self, user_id: str, preferred_username: str | None, email: str | None
    ) -> User:
        """Create and persist a new ``User`` record."""
        user = User(id=user_id, preferred_username=preferred_username, email=email)
        self.session.add(user)
        await self.session.flush()
        return user

    async def get_or_create(
        self, user_id: str, preferred_username: str | None, email: str | None
    ) -> User:
        """Return an existing ``User`` or create one if absent."""
        user = await self.get(user_id)
        if not user:
            user = await self.create(user_id, preferred_username, email)
        return user


class MessageDAO(BaseDAO):
    async def create(self, user: User, message: str) -> Message:
        """Create and persist a ``Message`` for the given user."""
        obj = Message(message=message, user=user)
        self.session.add(obj)
        await self.session.commit()
        await self.session.refresh(obj)
        return obj

    async def list_all(self) -> list[Message]:
        """Return all messages with their related users eagerly loaded."""
        result = await self.session.execute(
            select(Message).options(selectinload(Message.user))
        )
        return result.scalars().all()


class MapStateDAO(BaseDAO):
    async def create(self, user: User, state: dict) -> MapState:
        """Create and persist a ``MapState`` instance for the user."""
        obj = MapState(state=state, user=user)
        self.session.add(obj)
        await self.session.commit()
        await self.session.refresh(obj)
        return obj

    async def list_all(self) -> list[MapState]:
        """Return all map states with related users eagerly loaded."""
        result = await self.session.execute(
            select(MapState).options(selectinload(MapState.user))
        )
        return result.scalars().all()
