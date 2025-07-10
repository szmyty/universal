from fastapi import Depends, HTTPException, status
from typing import Sequence, Callable, Optional

from app.auth.oidc_user import OIDCUser, map_oidc_user

def require_roles(
    allowed_roles: Optional[Sequence[str]] = None
) -> Callable[[OIDCUser], OIDCUser]:
    """
    Dependency that checks if the user has at least one of the allowed roles.
    If allowed_roles is empty or None, access is granted to all authenticated users.
    """
    def dependency(user: OIDCUser = Depends(map_oidc_user)) -> OIDCUser:
        user_roles: list[str] = user.roles or []

        if allowed_roles and not any(role in user_roles for role in allowed_roles):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient role privileges",
            )

        return user

    return dependency
