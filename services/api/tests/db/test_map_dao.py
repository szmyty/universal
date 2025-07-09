from __future__ import annotations

import pytest
from typing import Sequence
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.entities.map import Map
from app.infrastructure.maps.dao import MapDAO
from app.schemas.maps import MapCreate, MapUpdate


@pytest.mark.anyio
@pytest.mark.unit
@pytest.mark.maps
class TestMapDAO:
    """Unit tests for MapStateDAO."""

    async def test_create_and_fetch(self: TestMapDAO, db_session: AsyncSession) -> None:
        """Test creating and fetching a map."""
        dao = MapDAO(db_session)
        payload = MapCreate(name="Test", description="d", state="{}")
        created: Map = await dao.create(user_id="user-abc", payload=payload)
        fetched: Map | None = await dao.get(created.id)
        assert created.id is not None
        assert created.name == "Test"
        assert created.state == "{}"
        assert fetched is not None
        assert fetched.id == created.id

    async def test_list_empty(self: TestMapDAO, db_session: AsyncSession) -> None:
        """Test listing maps when no maps exist."""
        dao = MapDAO(db_session)
        result: Sequence[Map] = await dao.list()
        assert result == []

    async def test_update(self: TestMapDAO, db_session: AsyncSession) -> None:
        """Test updating an existing map."""
        dao = MapDAO(db_session)
        original: Map = await dao.create(
            user_id="user",
            payload=MapCreate(name="Orig", description="d1", state="{}"),
        )
        updated: Map | None = await dao.update(
            original.id,
            MapUpdate(name="New", description="d2", state="{1}"),
        )
        assert updated is not None
        assert updated.name == "New"
        assert updated.state == "{1}"

    async def test_delete(self: TestMapDAO, db_session: AsyncSession) -> None:
        """Test deleting an existing map."""
        dao = MapDAO(db_session)
        ms: Map = await dao.create(
            user_id="u",
            payload=MapCreate(name="Del", description="d3", state="{}"),
        )
        deleted: bool = await dao.delete(ms.id)
        fetched: Map | None = await dao.get(ms.id)
        assert deleted is True
        assert fetched is None

    async def test_delete_nonexistent(self: TestMapDAO, db_session: AsyncSession) -> None:
        """Test deleting a non-existent map."""
        dao = MapDAO(db_session)
        deleted: bool = await dao.delete(9999)
        assert deleted is False
