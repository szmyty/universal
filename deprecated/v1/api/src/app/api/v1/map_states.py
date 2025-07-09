from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from ...deps import get_db
from ...services.map_state_service import MapStateService
from ...schemas.map_state import MapStateCreate, MapStateRead

router = APIRouter()


@router.post("/maps", response_model=MapStateRead)
async def create_map_state(payload: MapStateCreate, session: AsyncSession = Depends(get_db)):
    svc = MapStateService(session)
    state = await svc.create(payload.user_id, payload.state)
    if not state:
        raise HTTPException(status_code=404, detail="user not found")
    return MapStateRead.model_validate(state.__dict__)


@router.get("/maps", response_model=list[MapStateRead])
async def list_map_states(session: AsyncSession = Depends(get_db)):
    svc = MapStateService(session)
    states = await svc.list_all()
    return [MapStateRead.model_validate(s.__dict__) for s in states]
