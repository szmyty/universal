import os
import asyncio

import pytest
from fastapi.testclient import TestClient

os.environ["DB_HOST"] = ""  # force sqlite
os.environ["DB_PORT"] = ""
os.environ["DB_USER"] = ""
os.environ["DB_PASSWORD"] = ""
os.environ["DB_NAME"] = ":memory:"
os.environ["DATABASE_URL"] = "sqlite+aiosqlite:///:memory:"

from app.main import app
from app.infrastructure.db import async_session, engine, init_db


@pytest.fixture(autouse=True, scope="module")
async def prepare_db():
    await init_db()
    yield
    await engine.dispose()


def test_health():
    with TestClient(app) as client:
        resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


def test_create_user_and_message():
    with TestClient(app) as client:
        user_payload = {"id": "user1", "preferred_username": "user1", "email": "u@example.com"}
        resp = client.post("/users", json=user_payload)
        assert resp.status_code == 200
        resp = client.post("/messages", json={"user_id": "user1", "message": "hello"})
        assert resp.status_code == 200
        data = resp.json()
        assert data["message"] == "hello"
        resp = client.get("/messages")
        assert resp.status_code == 200
        messages = resp.json()
        assert len(messages) == 1
