from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Sequence

from .models import MapDomain


class MapRepository(ABC):
    """Abstract repository interface for Map objects."""

    @abstractmethod
    async def create(
        self: MapRepository,
        user_id: str,
        name: str,
        description: str,
        state: str,
    ) -> MapDomain:
        """Create a new map entry."""
        ...

    @abstractmethod
    async def get(self: MapRepository, id: int) -> MapDomain | None:
        """Get a map by its ID."""
        ...

    @abstractmethod
    async def list(self: MapRepository) -> Sequence[MapDomain]:
        """List all maps (admin only)."""
        ...

    @abstractmethod
    async def list_by_user(self: MapRepository, user_id: str) -> Sequence[MapDomain]:
        """List all maps belonging to a specific user."""
        ...

    @abstractmethod
    async def update(
        self: MapRepository,
        id: int,
        name: str,
        description: str,
        state: str,
    ) -> MapDomain | None:
        """Update a map by ID."""
        ...

    @abstractmethod
    async def delete(self: MapRepository, id: int) -> bool:
        """Delete a map by ID."""
        ...
