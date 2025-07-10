from __future__ import annotations
from typing import Sequence

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from structlog import BoundLogger
from starlette import status

from app.auth.oidc_user import OIDCUser, map_oidc_user
from app.db.session import get_async_session
from app.domain.maps.models import MapDomain
from app.schemas.maps import MapRead, MapSave
from app.services.maps_service import MapService
from app.infrastructure.maps.dao import MapDAO
from app.infrastructure.maps.repository import SqlAlchemyMapRepository
from app.core.logging import get_logger

log: BoundLogger = get_logger()

# Prefix for all map-related API endpoints
MAPS_API_PREFIX: str = "/maps"

# Create the API router for maps
router = APIRouter(prefix=MAPS_API_PREFIX, tags=["Maps"])

def get_map_service(
    session: AsyncSession = Depends(get_async_session),
) -> MapService:
    """Dependency injection for MapService."""
    dao = MapDAO(session)
    repo = SqlAlchemyMapRepository(dao)
    return MapService(repo)

from fastapi.responses import JSONResponse

@router.post("/", response_model=MapRead)
async def save_map(
    payload: MapSave,
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> JSONResponse:
    """
    Create or update a map depending on whether `id` is provided.
    Returns 201 for new maps, 200 for updates.
    """
    if payload.id:
        existing: MapDomain | None = await service.get(payload.id)
        if existing is None:
            raise HTTPException(404, "Map not found")
        if existing.user_id != user.sub:
            raise HTTPException(403, "Not authorized to modify this map")

        updated: MapDomain | None = await service.update(payload.id, payload)
        if updated is None:
            raise HTTPException(500, "Failed to update map")
        updated.user = user
        return JSONResponse(
            status_code=status.HTTP_200_OK,
            content=MapRead.model_validate(updated).model_dump(mode="json"),
        )

    created: MapDomain = await service.create(user.sub, payload)
    created.user = user
    return JSONResponse(
        status_code=status.HTTP_201_CREATED,
        content=MapRead.model_validate(created).model_dump(mode="json"),
    )


@router.get("/", response_model=list[MapRead])
async def list_all_maps(
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> list[MapRead]:
    """List all maps (admin-only)."""
    if "admin" not in (user.roles or []):
        raise HTTPException(status_code=403, detail="Admin privileges required")

    maps: Sequence[MapDomain] = await service.list()
    for map in maps:
        map.user = user
    return [MapRead.model_validate(map) for map in maps]


@router.get("/me", response_model=list[MapRead])
async def list_my_maps(
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> list[MapRead]:
    """List all maps owned by the current user."""
    maps: Sequence[MapDomain] = await service.list_by_user(user.sub)
    for map in maps:
        map.user = user
    return [MapRead.model_validate(map) for map in maps]


@router.get("/by/{user_id}", response_model=list[MapRead])
async def list_maps_by_user_id(
    user_id: str,
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> list[MapRead]:
    """List all maps owned by a specific user (admin-only)."""
    if "admin" not in (user.roles or []):
        raise HTTPException(status_code=403, detail="Admin privileges required")

    maps: Sequence[MapDomain] = await service.list_by_user(user_id)
    for map in maps:
        map.user = user
    return [MapRead.model_validate(map) for map in maps]


@router.get("/{map_id}", response_model=MapRead)
async def get_map(
    map_id: int,
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> MapRead:
    """Get a single map by ID (must own or be admin)."""
    map: MapDomain | None = await service.get(map_id)
    if not map:
        raise HTTPException(status_code=404, detail="Map not found")

    if map.user_id != user.sub and "admin" not in (user.roles or []):
        raise HTTPException(status_code=403, detail="Not authorized to access this map")

    map.user = user
    return MapRead.model_validate(map)


@router.put("/{map_id}", response_model=MapRead)
async def update_map(
    map_id: int,
    payload: MapSave,
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> MapRead:
    """Update a map (must own or be admin)."""
    map: MapDomain | None = await service.get(map_id)
    if not map:
        raise HTTPException(status_code=404, detail="Map not found")

    if map.user_id != user.sub and "admin" not in (user.roles or []):
        raise HTTPException(status_code=403, detail="Not authorized to update this map")

    updated: MapDomain | None = await service.update(map_id, payload)
    if updated:
        updated.user = user
    return MapRead.model_validate(updated)


@router.delete("/{map_id}", response_model=MapRead)
async def delete_map(
    map_id: int,
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> MapRead:
    """Delete a map (must own or be admin)."""
    map: MapDomain | None = await service.get(map_id)
    if not map:
        raise HTTPException(status_code=404, detail="Map not found")

    if map.user_id != user.sub and "admin" not in (user.roles or []):
        raise HTTPException(status_code=403, detail="Not authorized to delete this map")

    map.user = user
    await service.delete(map_id)
    log.info("Deleted map", map_id=map_id, user_id=user.sub)
    return MapRead.model_validate(map)
