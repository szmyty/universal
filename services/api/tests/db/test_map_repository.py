from __future__ import annotations

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.maps.models import MapDomain
from app.infrastructure.maps.dao import MapDAO
from app.infrastructure.maps.repository import SqlAlchemyMapRepository

@pytest.mark.anyio
@pytest.mark.unit
@pytest.mark.maps
class TestSqlMapRepository:
    """Unit tests for SqlAlchemyMapStateRepository."""

    async def test_create_and_get(self: TestSqlMapRepository, db_session: AsyncSession) -> None:
        """Test creating and fetching a map."""
        dao = MapDAO(db_session)
        repo = SqlAlchemyMapRepository(dao)
        created: MapDomain = await repo.create(
            "user-1", "Map1", "d", "{}"
        )
        fetched: MapDomain | None = await repo.get(created.id)
        assert fetched is not None
        assert fetched.id == created.id
        assert fetched.name == "Map1"

    async def test_list_returns_all(self: TestSqlMapRepository, db_session: AsyncSession) -> None:
        """Test listing all maps."""
        dao = MapDAO(db_session)
        repo = SqlAlchemyMapRepository(dao)
        await repo.create("u1", "A", "d1", "{}")
        await repo.create("u2", "B", "d2", "{}")
        states: list[MapDomain] = await repo.list()
        assert len(states) == 2

    async def test_update(self: TestSqlMapRepository, db_session: AsyncSession) -> None:
        """Test updating an existing map."""
        dao = MapDAO(db_session)
        repo = SqlAlchemyMapRepository(dao)
        ms: MapDomain = await repo.create("u", "orig", "d1", "{}")
        updated: MapDomain | None = await repo.update(ms.id, "new", "d2", "{1}")
        assert updated is not None
        assert updated.name == "new"
        assert updated.state == "{1}"

    async def test_delete(self: TestSqlMapRepository, db_session: AsyncSession) -> None:
        """Test deleting an existing map."""
        dao = MapDAO(db_session)
        repo = SqlAlchemyMapRepository(dao)
        ms: MapDomain = await repo.create("u", "del", "d3", "{}")
        deleted: bool = await repo.delete(ms.id)
        refetched: MapDomain | None = await repo.get(ms.id)
        assert deleted is True
        assert refetched is None

    async def test_delete_nonexistent(self: TestSqlMapRepository, db_session: AsyncSession) -> None:
        """Test deleting a non-existent map."""
        dao = MapDAO(db_session)
        repo = SqlAlchemyMapRepository(dao)
        result: bool = await repo.delete(99999)
        assert result is False
