from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from structlog import BoundLogger

from app.auth.oidc_user import OIDCUser, map_oidc_user
from app.db.session import get_async_session
from app.schemas.maps import MapCreate, MapRead, MapUpdate
from app.services.maps_service import MapService
from app.infrastructure.maps.dao import MapDAO
from app.infrastructure.maps.repository import SqlAlchemyMapRepository
from app.core.logging import get_logger

log: BoundLogger = get_logger()

router = APIRouter(prefix="/maps", tags=["Maps"])


def get_map_service(
    session: AsyncSession = Depends(get_async_session),
) -> MapService:
    """Dependency injection for MapService."""
    dao = MapDAO(session)
    repo = SqlAlchemyMapRepository(dao)
    return MapService(repo)


@router.post("/", response_model=MapRead, status_code=status.HTTP_201_CREATED)
async def create_map(
    payload: MapCreate,
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> MapRead:
    """Create a new map associated with the current user."""
    created = await service.create(user_id=user.sub, payload=payload)
    created.user = user
    log.info("Created map", map_id=created.id, user_id=user.sub)
    return MapRead.model_validate(created)


@router.get("/", response_model=list[MapRead])
async def list_all_maps(
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> list[MapRead]:
    """List all maps (admin-only)."""
    if "admin" not in (user.roles or []):
        raise HTTPException(status_code=403, detail="Admin privileges required")

    maps = await service.list()
    for m in maps:
        m.user = user
    return [MapRead.model_validate(m) for m in maps]


@router.get("/me", response_model=list[MapRead])
async def list_my_maps(
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> list[MapRead]:
    """List all maps owned by the current user."""
    maps = await service.list_by_user(user.sub)
    for m in maps:
        m.user = user
    return [MapRead.model_validate(m) for m in maps]


@router.get("/by/{user_id}", response_model=list[MapRead])
async def list_maps_by_user_id(
    user_id: str,
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> list[MapRead]:
    """List all maps owned by a specific user (admin-only)."""
    if "admin" not in (user.roles or []):
        raise HTTPException(status_code=403, detail="Admin privileges required")

    maps = await service.list_by_user(user_id)
    for m in maps:
        m.user = user
    return [MapRead.model_validate(m) for m in maps]


@router.get("/{map_id}", response_model=MapRead)
async def get_map(
    map_id: int,
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> MapRead:
    """Get a single map by ID (must own or be admin)."""
    m = await service.get(map_id)
    if not m:
        raise HTTPException(status_code=404, detail="Map not found")

    if m.user_id != user.sub and "admin" not in (user.roles or []):
        raise HTTPException(status_code=403, detail="Not authorized to access this map")

    m.user = user
    return MapRead.model_validate(m)


@router.put("/{map_id}", response_model=MapRead)
async def update_map(
    map_id: int,
    payload: MapUpdate,
    user: OIDCUser = Depends(map_oidc_user),
    service: MapService = Depends(get_map_service),
) -> MapRead:
    """Update a map (must own or be admin)."""
    m = await service.get(map_id)
    if not m:
        raise HTTPException(status_code=404, detail="Map not found")

    if m.user_id != user.sub and "admin" not in (user.roles or []):
        raise HTTPException(status_code=403, detail="Not authorized to update this map")

    updated = await service.update(map_id, payload)
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
    m = await service.get(map_id)
    if not m:
        raise HTTPException(status_code=404, detail="Map not found")

    if m.user_id != user.sub and "admin" not in (user.roles or []):
        raise HTTPException(status_code=403, detail="Not authorized to delete this map")

    m.user = user
    await service.delete(map_id)
    log.info("Deleted map", map_id=map_id, user_id=user.sub)
    return MapRead.model_validate(m)
