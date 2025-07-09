from __future__ import annotations

from typing import Sequence, Tuple

from sqlalchemy import Result, Select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.engine import ScalarResult
from sqlalchemy.future import select

from app.db.entities.map import Map
from app.schemas.maps import MapCreate, MapUpdate


class MapDAO:
    """Data Access Object (DAO) for the Map entity."""

    def __init__(self: MapDAO, session: AsyncSession) -> None:
        """Initialize the MapDAO with an async session."""
        self.session: AsyncSession = session

    async def create(self: MapDAO, user_id: str, payload: MapCreate) -> Map:
        """Insert a new map record into the database."""
        db_obj = Map(
            user_id=user_id,
            name=payload.name,
            description=payload.description,
            state=payload.state,
        )
        self.session.add(db_obj)
        await self.session.flush()       # ensures ID is generated
        await self.session.commit()      # commit the transaction
        await self.session.refresh(db_obj)  # rebind and hydrate from DB
        return db_obj

    async def get(self: MapDAO, id: int) -> Map | None:
        """Get a map by ID."""
        return await self.session.get(Map, id)

    async def list(self: MapDAO) -> Sequence[Map]:
        """Return all maps in the database."""
        stmt: Select[Tuple[Map]] = select(Map)
        result: Result[Tuple[Map]] = await self.session.execute(stmt)
        scalars: ScalarResult[Map] = result.scalars()
        return scalars.all()

    async def list_by_user(self: MapDAO, user_id: str) -> Sequence[Map]:
        """Return all maps belonging to a specific user."""
        stmt: Select[Tuple[Map]] = select(Map).where(Map.user_id == user_id)
        result: Result[Tuple[Map]] = await self.session.execute(stmt)
        scalars: ScalarResult[Map] = result.scalars()
        return scalars.all()

    async def update(self: MapDAO, id: int, payload: MapUpdate) -> Map | None:
        """Update a map by ID."""
        db_obj: Map | None = await self.get(id)
        if not db_obj:
            return None

        db_obj.name = payload.name
        db_obj.description = payload.description
        db_obj.state = payload.state

        await self.session.commit()
        await self.session.refresh(db_obj)
        return db_obj

    async def delete(self, id: int) -> bool:
        """Delete a map by ID."""
        db_obj: Map | None = await self.get(id)
        if not db_obj:
            return False

        await self.session.delete(db_obj)
        await self.session.commit()
        return True
