from __future__ import annotations
from typing import Any, Dict

import pytest
from fastapi import FastAPI
from httpx import AsyncClient, Response, ASGITransport

from app.api.routes.profile import router as profile_router

KEYCLOAK_BASE_URL = "http://localhost:8085/auth"
REALM = "development"
CLIENT_ID = "development"
CLIENT_SECRET = "your-client-secret-here"
USERNAME = "root.smith"
PASSWORD = "Root123!"

@pytest.fixture(scope="session")
def access_token() -> str:
    token_url = f"{KEYCLOAK_BASE_URL}/realms/{REALM}/protocol/openid-connect/token"
    data = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "password",
        "username": USERNAME,
        "password": PASSWORD,
    }
    r = requests.post(token_url, data=data)
    r.raise_for_status()
    return r.json()["access_token"]

@pytest.fixture
def test_app_real_oidc() -> FastAPI:
    """Use the real OIDC mapping logic (no mock override)."""
    app = FastAPI()
    app.include_router(profile_router)
    return app

@pytest.mark.anyio
class TestKeycloakIntegration:
    async def test_me_with_real_keycloak_user(self, test_app_real_oidc: FastAPI, access_token: str) -> None:
        """Hit /me with a real Keycloak-issued token."""
        transport = ASGITransport(app=test_app_real_oidc)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp: Response = await client.get(
                "/me", headers={"Authorization": f"Bearer {access_token}"}
            )

        assert resp.status_code == 200
        data: Dict[str, Any] = resp.json()

        # Assertions based on actual Keycloak data
        assert data["email"] == "root@universal.dev"
        assert data["preferred_username"] == "root.smith"
        assert "roles" in data
        assert data["sub"]
