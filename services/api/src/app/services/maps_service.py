from __future__ import annotations
from typing import Sequence

from app.domain.maps.interfaces import MapRepository
from app.domain.maps.models import MapDomain
from app.schemas.maps import MapSave


class MapService:
    """Service layer for map persistence and business logic."""

    def __init__(self: MapService, repo: MapRepository) -> None:
        """Initialize the MapService with a repository."""
        self.repo: MapRepository = repo

    async def create(self: MapService, user_id: str, payload: MapSave) -> MapDomain:
        """Create a new map owned by the given user."""
        return await self.repo.create(
            user_id=user_id,
            name=payload.name,
            description=payload.description,
            state=payload.state,
        )

    async def get(self: MapService, id: int) -> MapDomain | None:
        """Retrieve a single map by ID."""
        return await self.repo.get(id)

    async def list(self: MapService) -> Sequence[MapDomain]:
        """List all maps (admin use only)."""
        return await self.repo.list()

    async def list_by_user(self: MapService, user_id: str) -> Sequence[MapDomain]:
        """List all maps owned by a given user."""
        return await self.repo.list_by_user(user_id)

    async def update(self: MapService, id: int, payload: MapSave) -> MapDomain | None:
        """Update an existing map by ID."""
        return await self.repo.update(
            id, payload.name, payload.description, payload.state
        )

    async def delete(self: MapService, id: int) -> bool:
        """Delete a map by ID."""
        return await self.repo.delete(id)
