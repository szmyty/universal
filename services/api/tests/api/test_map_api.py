from __future__ import annotations
from typing import Any

import pytest
from fastapi import FastAPI
from httpx import AsyncClient, ASGITransport, Response
from sqlalchemy.ext.asyncio import AsyncSession
from starlette import status

from app.api.routes.maps import MAPS_API_PREFIX, router as map_states_router, get_map_service
from app.auth.oidc_user import OIDCUser, map_oidc_user
from app.services.maps_service import MapService
from app.infrastructure.maps.dao import MapDAO
from app.infrastructure.maps.repository import SqlAlchemyMapRepository
from app.schemas.maps import MapCreate, MapRead, MapSave


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
@pytest.mark.maps
class TestMapApi:
    """API tests for map state endpoints."""

    async def test_create_and_fetch(self: TestMapApi, test_app: FastAPI) -> None:
        """Test creating a map and fetching it by ID."""

        async with AsyncClient(
            transport=ASGITransport(app=test_app),
            base_url="http://test"
        ) as client:

            # ---------------------
            # ARRANGE
            # ---------------------
            payload: MapCreate = MapCreate(
                name="Map",
                description="Test map creation",
                state="{}"
            )

            # ---------------------
            # ACT – Create
            # ---------------------
            create_resp: Response = await client.post(
                f"{MAPS_API_PREFIX}/",
                json=payload.model_dump(mode="json")
            )

            # ---------------------
            # ASSERT – Create
            # ---------------------
            assert create_resp.status_code == status.HTTP_201_CREATED

            created: dict[str, Any] = create_resp.json()
            map_state_id: int = created["id"]
            assert created["name"] == payload.name
            assert created["description"] == payload.description
            assert created["user_id"] == "test-user-id"

            # ---------------------
            # ACT – Fetch
            # ---------------------
            fetch_resp: Response = await client.get(f"{MAPS_API_PREFIX}/{map_state_id}")

            # ---------------------
            # ASSERT – Fetch
            # ---------------------
            assert fetch_resp.status_code == status.HTTP_200_OK
            data: dict[str, Any] = fetch_resp.json()
            assert data["id"] == map_state_id
            assert data["name"] == payload.name
            assert data["description"] == payload.description
            assert data["user_id"] == "test-user-id"

            # ✅ Optional: strict type validation
            validated = MapRead.model_validate(data)
            assert isinstance(validated, MapRead)

    async def test_update(self: TestMapApi, test_app: FastAPI) -> None:
        """Test updating a map state."""
        async with AsyncClient(
            transport=ASGITransport(app=test_app), base_url="http://test"
        ) as client:
            resp = await client.post(
                f"{MAPS_API_PREFIX}/",
                json={"name": "A", "description": "d1", "state": "{}"},
            )
            map_state_id = resp.json()["id"]
            update_resp: Response = await client.put(
                f"{MAPS_API_PREFIX}/{map_state_id}",
                json={"name": "B", "description": "d2", "state": "{1}"},
            )
            assert update_resp.status_code == status.HTTP_200_OK
            assert update_resp.json()["name"] == "B"

    async def test_list(self: TestMapApi, test_app: FastAPI) -> None:
        """Test listing all map states."""
        async with AsyncClient(
            transport=ASGITransport(app=test_app), base_url="http://test"
        ) as client:
            list_resp: Response = await client.get(f"{MAPS_API_PREFIX}/")
            assert list_resp.status_code == status.HTTP_200_OK
            assert isinstance(list_resp.json(), list)

    async def test_delete(self: TestMapApi, test_app: FastAPI) -> None:
        """Test deleting a map state."""
        async with AsyncClient(
            transport=ASGITransport(app=test_app), base_url="http://test"
        ) as client:
            payload = MapCreate(name="Del", description="d3", state="{}")
            create_resp: Response = await client.post(
                f"{MAPS_API_PREFIX}/", json=payload.model_dump(mode="json")
            )
            map_state_id = create_resp.json()["id"]
            delete_resp: Response = await client.delete(
                f"{MAPS_API_PREFIX}/{map_state_id}"
            )
            assert delete_resp.status_code == status.HTTP_200_OK
            deleted = delete_resp.json()
            assert deleted["id"] == map_state_id
            assert isinstance(MapRead.model_validate(deleted), MapRead)
            fetch = await client.get(f"{MAPS_API_PREFIX}/{map_state_id}")
            assert fetch.status_code == status.HTTP_404_NOT_FOUND

    async def test_save_map_creates_and_updates(self: TestMapApi, test_app: FastAPI) -> None:
        """Test POST /maps behaves as create or update depending on presence of `id`."""
        client = AsyncClient(transport=ASGITransport(app=test_app), base_url="http://test")

        # Step 1: Create a map (no id)
        create_payload = {
            "name": "Test Map",
            "description": "Initial state",
            "state": "{}",
        }

        create_resp = await client.post(f"{MAPS_API_PREFIX}/", json=create_payload)
        assert create_resp.status_code == status.HTTP_201_CREATED

        created = MapRead.model_validate(create_resp.json())
        assert created.name == "Test Map"
        map_id = created.id

        # Step 2: Update that map with same ID
        update_payload = MapSave(
            id=map_id,
            name="Test Map",
            description="Updated desc",
            state='{"updated": true}',
        )

        update_resp = await client.post(f"{MAPS_API_PREFIX}/", json=update_payload.model_dump(mode="json"))
        assert update_resp.status_code == status.HTTP_200_OK

        updated = MapRead.model_validate(update_resp.json())
        assert updated.description == "Updated desc"
        assert updated.state == '{"updated": true}'
        assert updated.id == map_id

        await client.aclose()
