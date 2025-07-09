from __future__ import annotations
from typing import Sequence

from app.db.entities.map import Map
from app.domain.maps.models import MapDomain
from app.domain.maps.interfaces import MapRepository
from app.infrastructure.maps.dao import MapDAO
from app.schemas.maps import MapCreate, MapUpdate


class SqlAlchemyMapRepository(MapRepository):
    """SQLAlchemy implementation of MapRepository."""

    def __init__(self: SqlAlchemyMapRepository, dao: MapDAO) -> None:
        """Initialize the repository with a MapDAO instance."""
        self.dao: MapDAO = dao

    async def create(
        self: SqlAlchemyMapRepository,
        user_id: str,
        name: str,
        description: str,
        state: str,
    ) -> MapDomain:
        """Create a new map in the database."""
        db_obj: Map = await self.dao.create(
            user_id,
            MapCreate(name=name, description=description, state=state),
        )
        return MapDomain.from_entity(db_obj)

    async def get(self: SqlAlchemyMapRepository, id: int) -> MapDomain | None:
        """Retrieve a map by its ID."""
        db_obj: Map | None = await self.dao.get(id)
        return MapDomain.from_entity(db_obj) if db_obj else None

    async def list(self: SqlAlchemyMapRepository) -> list[MapDomain]:
        """Return all maps."""
        return [MapDomain.from_entity(m) for m in await self.dao.list()]

    async def update(
        self: SqlAlchemyMapRepository,
        id: int,
        name: str,
        description: str,
        state: str,
    ) -> MapDomain | None:
        """Update a map's fields by ID."""
        db_obj: Map | None = await self.dao.update(
            id,
            MapUpdate(name=name, description=description, state=state),
        )
        return MapDomain.from_entity(db_obj) if db_obj else None

    async def delete(self: SqlAlchemyMapRepository, id: int) -> bool:
        """Delete a map by ID."""
        return await self.dao.delete(id)

    async def list_by_user(self: SqlAlchemyMapRepository, user_id: str) -> list[MapDomain]:
        """Return all maps for a specific user."""
        db_objs: Sequence[Map] = await self.dao.list_by_user(user_id)
        return [MapDomain.from_entity(m) for m in db_objs]
