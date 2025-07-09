from __future__ import annotations

import pytest
from fastapi import FastAPI
from httpx import AsyncClient, ASGITransport, Response
from sqlalchemy.ext.asyncio import AsyncSession
from starlette import status

from app.api.routes.maps import router as map_states_router, get_map_service
from app.auth.oidc_user import OIDCUser, map_oidc_user
from app.services.maps_service import MapService
from app.infrastructure.maps.dao import MapDAO
from app.infrastructure.maps.repository import SqlAlchemyMapRepository
from app.schemas.maps import MapCreate, MapRead


@pytest.fixture
def test_app(db_session: AsyncSession, test_user: OIDCUser) -> FastAPI:
    """Fixture to create a test FastAPI app with overridden dependencies for map states."""
    app = FastAPI()

    async def override_service() -> MapService:
        """Dependency override: return a MapService with SQLAlchemy repository."""
        dao = MapDAO(db_session)
        repo = SqlAlchemyMapRepository(dao)
        return MapService(repo)

    app.dependency_overrides[get_map_service] = override_service
    app.dependency_overrides[map_oidc_user] = lambda: test_user
    app.include_router(map_states_router)
    return app


@pytest.mark.anyio
@pytest.mark.unit
@pytest.mark.api
@pytest.mark.map_states
class TestMapApi:
    """API tests for map state endpoints."""

    async def test_create_and_fetch(self: TestMapApi, test_app: FastAPI) -> None:
        """Test creating a map state and fetching it by ID."""
        async with AsyncClient(
            transport=ASGITransport(app=test_app), base_url="http://test"
        ) as client:
            payload = MapCreate(name="Map", description="d", state="{}")
            create_resp: Response = await client.post(
                "/maps/", json=payload.model_dump()
            )
            assert create_resp.status_code == status.HTTP_201_CREATED
            map_state_id = create_resp.json()["id"]

            fetch_resp: Response = await client.get(f"/maps/{map_state_id}")
            assert fetch_resp.status_code == status.HTTP_200_OK
            data = fetch_resp.json()
            assert data["id"] == map_state_id
            assert data["user_id"] == "test-user-id"
            assert isinstance(MapRead.model_validate(data), MapRead)

    async def test_update(self: TestMapApi, test_app: FastAPI) -> None:
        """Test updating a map state."""
        async with AsyncClient(
            transport=ASGITransport(app=test_app), base_url="http://test"
        ) as client:
            resp = await client.post(
                "/maps/",
                json={"name": "A", "description": "d1", "state": "{}"},
            )
            map_state_id = resp.json()["id"]
            update_resp: Response = await client.put(
                f"/maps/{map_state_id}",
                json={"name": "B", "description": "d2", "state": "{1}"},
            )
            assert update_resp.status_code == status.HTTP_200_OK
            assert update_resp.json()["name"] == "B"

    async def test_list(self: TestMapApi, test_app: FastAPI) -> None:
        """Test listing all map states."""
        async with AsyncClient(
            transport=ASGITransport(app=test_app), base_url="http://test"
        ) as client:
            list_resp: Response = await client.get("/maps/")
            assert list_resp.status_code == status.HTTP_200_OK
            assert isinstance(list_resp.json(), list)

    async def test_delete(self: TestMapApi, test_app: FastAPI) -> None:
        """Test deleting a map state."""
        async with AsyncClient(
            transport=ASGITransport(app=test_app), base_url="http://test"
        ) as client:
            payload = MapCreate(name="Del", description="d3", state="{}")
            create_resp: Response = await client.post(
                "/maps/", json=payload.model_dump()
            )
            map_state_id = create_resp.json()["id"]
            delete_resp: Response = await client.delete(
                f"/maps/{map_state_id}"
            )
            assert delete_resp.status_code == status.HTTP_200_OK
            deleted = delete_resp.json()
            assert deleted["id"] == map_state_id
            assert isinstance(MapRead.model_validate(deleted), MapRead)
            fetch = await client.get(f"/maps/{map_state_id}")
            assert fetch.status_code == status.HTTP_404_NOT_FOUND
