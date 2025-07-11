from __future__ import annotations
from typing import Any, Sequence

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from structlog import BoundLogger
from starlette import status

from app.auth.check_roles import require_roles
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
    log.info("📦 Received save_map upsert request", map_id=payload.id, user_id=user.sub)

    try:
        existing: MapDomain | None = await service.get(payload.id)

        if existing:
            log.info("🔁 Map exists, attempting update", map_id=payload.id, owner=existing.user_id)

            if existing.user_id != user.sub:
                log.warning("🚫 Unauthorized map update attempt", user_id=user.sub, owner_id=existing.user_id)
                raise HTTPException(status_code=403, detail="Not authorized to update this map")

            updated = await service.update(payload.id, payload)
            if not updated:
                log.error("❌ Update failed — service returned None", map_id=payload.id)
                raise HTTPException(status_code=500, detail="Failed to update map")

            updated.user = user
            log.info("✅ Map updated successfully", map_id=updated.id)
            return JSONResponse(
                status_code=status.HTTP_200_OK,
                content=MapRead.model_validate(updated).model_dump(mode="json"),
            )

        # Create new map with provided UUID
        log.info("📄 Map not found — creating new", map_id=payload.id)

        created: MapDomain = await service.create(user.sub, payload)
        if not created:
            log.error("❌ Map creation failed — service returned None", payload=payload.model_dump())
            raise HTTPException(status_code=500, detail="Failed to create map")

        created.user = user
        log.info("🎉 Map created successfully", map_id=created.id, user_id=user.sub)
        return JSONResponse(
            status_code=status.HTTP_201_CREATED,
            content=MapRead.model_validate(created).model_dump(mode="json"),
        )

    except HTTPException as http_err:
        log.warning("⚠️ HTTPException raised", status=http_err.status_code, detail=http_err.detail)
        raise http_err

    except Exception as unhandled:
        log.exception("🔥 Unhandled error in save_map", error=str(unhandled), map_id=payload.id)
        raise HTTPException(
            status_code=500,
            detail="An unexpected error occurred while saving the map.",
        )

@router.get("/", response_model=list[MapRead])
async def list_all_maps(
    user: OIDCUser = Depends(require_roles([])),
    service: MapService = Depends(get_map_service),
) -> list[MapRead]:
    """List all maps."""
    log.info("📥 Received list_all_maps request", user_id=user.sub)

    try:
        maps: Sequence[MapDomain] = await service.list()

        if not maps:
            log.info("📭 No maps found", user_id=user.sub)

        for map in maps:
            map.user = user

        response: list[MapRead] = [MapRead.model_validate(m) for m in maps]
        log.info("📦 Returning map list", count=len(response))
        return response

    except HTTPException as http_err:
        log.warning("⚠️ HTTPException during map listing", status=http_err.status_code, detail=http_err.detail)
        raise http_err

    except Exception as err:
        log.exception("🔥 Unhandled error during list_all_maps", error=str(err))
        raise HTTPException(status_code=500, detail="Failed to list maps due to unexpected error.")

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
    user: OIDCUser = Depends(require_roles([])),
    service: MapService = Depends(get_map_service),
) -> list[MapRead]:
    """List all maps owned by a specific user."""
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
    log.info("📥 get_map_by_id request", map_id=map_id, user_id=user.sub)

    try:
        map_: MapDomain | None = await service.get(map_id)

        if not map_:
            log.warning("❌ Map not found", map_id=map_id)
            raise HTTPException(status_code=404, detail="Map not found")

        log.info("✅ Returning map", map_id=map_id)
        return MapRead.model_validate(map_)

    except HTTPException as http_err:
        log.warning("⚠️ HTTPException in get_map_by_id", status=http_err.status_code, detail=http_err.detail)
        raise http_err

    except Exception as err:
        log.exception("🔥 Unhandled error in get_map_by_id", error=str(err), map_id=map_id)
        raise HTTPException(status_code=500, detail="Failed to retrieve map due to unexpected error.")

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
