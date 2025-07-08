import os
import pytest
import requests

@pytest.mark.integration
@pytest.mark.auth
class TestRealKeycloakAuth:
    """Integration test hitting real Keycloak and API instance"""

    def get_token(self) -> str:
        """Authenticate against Keycloak and get a bearer token."""
        keycloak_url = os.getenv("KEYCLOAK_URL", "http://localhost:8080")
        realm = os.getenv("KEYCLOAK_REALM", "dev")
        client_id = os.getenv("KEYCLOAK_CLIENT_ID", "api")
        client_secret = os.getenv("KEYCLOAK_CLIENT_SECRET", "changeme")
        username = os.getenv("TEST_USERNAME", "testuser")
        password = os.getenv("TEST_PASSWORD", "testpass")

        token_url = f"{keycloak_url}/auth/realms/{realm}/protocol/openid-connect/token"

        data = {
            "grant_type": "password",
            "client_id": client_id,
            "client_secret": client_secret,
            "username": username,
            "password": password,
        }

        resp = requests.post(token_url, data=data)
        resp.raise_for_status()
        return resp.json()["access_token"]

    def test_real_me_endpoint(self) -> None:
        """Hit the real /me endpoint with a valid Keycloak token."""
        token = self.get_token()

        api_url = os.getenv("API_URL", "http://localhost:8000")
        resp = requests.get(
            f"{api_url}/me",
            headers={"Authorization": f"Bearer {token}"}
        )

        assert resp.status_code == 200
        data = resp.json()

        assert "email" in data
        assert "sub" in data
        assert "preferred_username" in data
        assert isinstance(data.get("roles", []), list)
