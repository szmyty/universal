from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ...deps import get_db
from ...services.user_service import UserService
from ...schemas.user import UserCreate, UserRead

router = APIRouter()


@router.post("/users", response_model=UserRead)
async def create_user(payload: UserCreate, session: AsyncSession = Depends(get_db)):
    svc = UserService(session)
    user = await svc.get_or_create(payload.id, payload.preferred_username, payload.email)
    return UserRead.model_validate(user.__dict__)
