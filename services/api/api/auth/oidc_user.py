from fastapi import HTTPException, Request, Depends
from pydantic import BaseModel
from fastapi_keycloak_middleware import KeycloakConfiguration, setup_keycloak_middleware, FastApiUser as KeycloakOIDCUser
from starlette.status import HTTP_401_UNAUTHORIZED
from typing import Any

class OIDCUser(BaseModel):
    sub: str
    preferred_username: str | None = None
    email: str | None = None
    given_name: str | None = None
    family_name: str | None = None
    name: str | None = None
    picture: str | None = None
    locale: str | None = None
    roles: list[str] | None = None
    groups: list[str] | None = None
    extra: dict[str, Any] | None = None

def get_oidc_user(request: Request) -> Dict[str, Any]:
    """Return raw user info extracted from middleware claims."""
    user_claims = getattr(request.state, "user", None) or request.scope.get("user")
    if not isinstance(user_claims, dict):
        raise HTTPException(status_code=401, detail="User not authenticated")
    return user_claims


async def map_oidc_user(userinfo: Dict[str, Any] = Depends(get_user)) -> OIDCUser:
    """Convert raw user info to an ``OIDCUser`` instance."""
    if not isinstance(userinfo, dict):
        raise TypeError("userinfo must be a dictionary")
    return OIDCUser.model_validate(userinfo)
