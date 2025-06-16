from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

from .config import get_config
from .models import Base
import structlog

log = structlog.get_logger(__name__)


def get_database_url() -> str:
    """Construct the database connection URL from configuration."""
    cfg = get_config()
    return (
        f"postgresql+asyncpg://{cfg.db_user}:{cfg.db_password}@"
        f"{cfg.db_host}:{cfg.db_port}/{cfg.db_name}"
    )


engine = create_async_engine(get_database_url(), future=True, echo=False)

async_session = async_sessionmaker(engine, expire_on_commit=False)


async def get_session() -> AsyncSession:
    """Yield an ``AsyncSession`` instance scoped to a single request."""
    async with async_session() as session:
        yield session
