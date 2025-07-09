from __future__ import annotations

import pytest
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Sequence

from app.domain.maps.models import MapDomain
from app.services.maps_service import MapService
from app.infrastructure.maps.dao import MapDAO
from app.infrastructure.maps.repository import SqlAlchemyMapRepository
from app.schemas.maps import MapCreate, MapUpdate


@pytest.mark.anyio
@pytest.mark.unit
@pytest.mark.maps
class TestMapService:
    """Unit tests for MapStateService."""

    async def test_create_and_get(self: TestMapService, db_session: AsyncSession) -> None:
        """Test creating and fetching a map."""
        dao = MapDAO(db_session)
        repo = SqlAlchemyMapRepository(dao)
        service = MapService(repo)
        payload = MapCreate(name="Map", description="d", state="{}")
        created: MapDomain = await service.create("user", payload)
        fetched: MapDomain | None = await service.get(created.id)
        assert fetched is not None
        assert fetched.name == "Map"
        assert fetched.user_id == "user"

    async def test_list_all(self: TestMapService, db_session: AsyncSession) -> None:
        """Test listing all maps."""
        dao = MapDAO(db_session)
        repo = SqlAlchemyMapRepository(dao)
        service = MapService(repo)
        await service.create("u1", MapCreate(name="A", description="d1", state="{}"))
        await service.create("u2", MapCreate(name="B", description="d2", state="{}"))
        states: Sequence[MapDomain] = await service.list()
        assert len(states) == 2

    async def test_update(self: TestMapService, db_session: AsyncSession) -> None:
        """Test updating an existing map."""
        dao = MapDAO(db_session)
        repo = SqlAlchemyMapRepository(dao)
        service = MapService(repo)
        ms: MapDomain = await service.create(
            "u", MapCreate(name="old", description="d1", state="{}")
        )
        updated: MapDomain | None = await service.update(
            ms.id, MapUpdate(name="new", description="d2", state="{1}")
        )
        assert updated is not None
        assert updated.name == "new"

    async def test_delete(self: TestMapService, db_session: AsyncSession) -> None:
        """Test deleting an existing map."""
        dao = MapDAO(db_session)
        repo = SqlAlchemyMapRepository(dao)
        service = MapService(repo)
        ms: MapDomain = await service.create(
            "u", MapCreate(name="temp", description="d3", state="{}")
        )
        deleted: bool = await service.delete(ms.id)
        fetched: MapDomain | None = await service.get(ms.id)
        assert deleted is True
        assert fetched is None
