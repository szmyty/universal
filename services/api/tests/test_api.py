import os
import asyncio

import pytest
from httpx import AsyncClient

os.environ["DB_HOST"] = ""  # force sqlite
os.environ["DB_PORT"] = ""
os.environ["DB_USER"] = ""
os.environ["DB_PASSWORD"] = ""
os.environ["DB_NAME"] = ":memory:"
os.environ["DATABASE_URL"] = "sqlite+aiosqlite:///:memory:"

from api.main import app
from api.database.database import get_session, engine, init_db


@pytest.fixture(autouse=True, scope="module")
async def prepare_db():
    await init_db()
    yield
    await engine.dispose()


@pytest.mark.asyncio
async def test_health():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        resp = await ac.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


@pytest.mark.asyncio
async def test_create_user_and_message():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        user_payload = {"id": "user1", "preferred_username": "user1", "email": "u@example.com"}
        resp = await ac.post("/users", json=user_payload)
        assert resp.status_code == 200
        resp = await ac.post("/messages", json={"user_id": "user1", "message": "hello"})
        assert resp.status_code == 200
        data = resp.json()
        assert data["message"] == "hello"
        resp = await ac.get("/messages")
        assert resp.status_code == 200
        messages = resp.json()
        assert len(messages) == 1
