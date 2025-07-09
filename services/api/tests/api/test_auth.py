from __future__ import annotations

import pytest
import requests
import jwt
from httpx import AsyncClient, ASGITransport, Response
from typing import Any, Dict
from fastapi import FastAPI

from app.api.routes.profile import router as profile_router


# === Keycloak config ===
KEYCLOAK_URL = "https://localhost:8085/auth"
REALM = "development"
CLIENT_ID = "development"
CLIENT_SECRET = "your-client-secret"
USERNAME = "root.smith"
PASSWORD = "Root123!"


def simulate_apache_headers_from_token(token: str) -> Dict[str, str]:
    """Decode the JWT and simulate Apache header injection."""
    decoded: Dict[str, Any] = jwt.decode(token, options={"verify_signature": False})

    print("\n🔓 Decoded Token Claims:")
    for k, v in decoded.items():
        print(f"  {k}: {v}")

    return {
        "X-Remote-User": decoded.get("preferred_username", decoded.get("sub", "")),
        "X-Email": decoded.get("email", ""),
        "X-Name": decoded.get("name", ""),
        "X-Given-Name": decoded.get("given_name", ""),
        "X-Family-Name": decoded.get("family_name", ""),
        "X-Locale": decoded.get("locale", "en"),
        "X-Picture": decoded.get("picture", ""),
        "X-Roles": ",".join(decoded.get("realm_access", {}).get("roles", [])),
        "X-Groups": ",".join(decoded.get("groups", [])),
        "Authorization": f"Bearer {token}",
    }


@pytest.fixture(scope="session")
def access_token() -> str:
    """Get a real token from Keycloak using password grant."""
    token_url = f"{KEYCLOAK_URL}/realms/{REALM}/protocol/openid-connect/token"
    data = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "password",
        "username": USERNAME,
        "password": PASSWORD,
    }
    response = requests.post(token_url, data=data, verify=False)
    response.raise_for_status()
    token = response.json()["access_token"]
    print("\n✅ Access token obtained successfully.")
    return token


@pytest.fixture
def test_app_simulating_apache() -> FastAPI:
    """Create a FastAPI app without Apache but mimicking its behavior."""
    app = FastAPI()
    app.include_router(profile_router)
    return app


@pytest.mark.anyio
class TestMeWithApacheHeaders:
    """Integration-style test using real token and simulated Apache headers."""

    async def test_me_with_real_token_and_headers(
        self: TestMeWithApacheHeaders,
        test_app_simulating_apache: FastAPI,
        access_token: str
    ) -> None:
        headers: Dict[str, str] = simulate_apache_headers_from_token(access_token)

        transport = ASGITransport(app=test_app_simulating_apache)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp: Response = await client.get("/me", headers=headers)

        print("\n📥 Response JSON:")
        print(resp.json())

        assert resp.status_code == 200
        data: Dict[str, Any] = resp.json()

        assert data["sub"] == headers["X-Remote-User"]
        assert data["email"] == headers["X-Email"]
        assert "roles" in data
