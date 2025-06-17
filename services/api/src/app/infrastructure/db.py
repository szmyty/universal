from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

from ..settings import get_settings
from .user.repository import Base

settings = get_settings()

engine = create_async_engine(settings.DATABASE_URL, future=True, echo=False)
async_session = async_sessionmaker(engine, expire_on_commit=False)


async def init_db() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
