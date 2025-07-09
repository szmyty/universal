from fastapi import APIRouter, Depends

from app.auth.oidc_user import OIDCUser, map_oidc_user

router = APIRouter()

@router.get("/me", response_model=OIDCUser)
async def read_user(user: OIDCUser = Depends(map_oidc_user)) -> OIDCUser:
    """Get the current user's profile."""
    return user
