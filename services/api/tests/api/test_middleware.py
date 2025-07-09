from __future__ import annotations
import asyncio

import pytest
from fastapi import FastAPI, Request
from httpx import ASGITransport, AsyncClient, Response
from starlette.responses import JSONResponse
from piccolo_api.rate_limiting.middleware import InMemoryLimitProvider
from piccolo_api.rate_limiting.middleware import RateLimitingMiddleware

from app.api.middleware import add_middlewares
from app.core.settings import Settings
from app.extensions.body_size_middleware import BodySizeLimitMiddleware
from app.extensions.rate_limiting_middleware import NoOpLimitProvider

@pytest.fixture
def test_app(settings: Settings) -> FastAPI:
    """Fixture for a FastAPI app with all middlewares applied."""
    app = FastAPI()
    add_middlewares(app)

    @app.get("/test")
    async def test_route() -> JSONResponse:  # type: ignore
        """A simple test route to verify middleware functionality."""
        return JSONResponse({"message": "ok"})

    @app.post("/test")
    async def test_post_route() -> JSONResponse:  # type: ignore
        """A test POST route to verify CSRF and other middleware."""
        return JSONResponse({"message": "POST OK"})

    @app.get("/cors-test")
    async def cors_test() -> JSONResponse:  # type: ignore
        """A test route to verify CORS middleware."""
        return JSONResponse({"message": "CORS OK"})

    return app

@pytest.fixture
def isolated_rate_limited_app() -> FastAPI:
    """Fixture for a FastAPI app with isolated rate limiting middleware."""
    limiter = InMemoryLimitProvider(limit=2, timespan=1, block_duration=2)

    app = FastAPI()
    app.add_middleware(RateLimitingMiddleware, provider=limiter)

    @app.get("/ratelimit-test")
    async def ratelimit_test()  -> JSONResponse: # type: ignore
        """A test route to verify rate limiting functionality."""
        return JSONResponse({"message": "allowed"})

    return app

@pytest.fixture
def no_op_rate_limit_app() -> FastAPI:
    """Fixture for a FastAPI app with no-op rate limiting middleware."""
    app = FastAPI()
    app.add_middleware(RateLimitingMiddleware, provider=NoOpLimitProvider())

    @app.get("/ratelimit-test")
    async def ratelimit_test()  -> JSONResponse: # type: ignore
        """A test route to verify no-op rate limiting functionality."""
        return JSONResponse({"message": "still allowed"})

    return app

@pytest.fixture
def body_limited_app() -> FastAPI:
    """Fixture for a FastAPI app with body size limit middleware."""
    app = FastAPI()
    app.add_middleware(BodySizeLimitMiddleware, max_body_size=100)  # 100 bytes

    @app.post("/upload")
    async def upload(request: Request) -> JSONResponse:   # type: ignore
        """A test route to verify body size limit functionality."""
        data = await request.body()
        return JSONResponse({"length": len(data)})

    return app

@pytest.mark.anyio
class TestMiddleware:
    """Middleware test suite (AAA pattern)."""
    async def test_x_service_header_present(self: TestMiddleware, test_app: FastAPI) -> None:
        """Test that the x-service header is present and correctly formatted."""
        # Arrange
        transport = ASGITransport(app=test_app)

        # Act
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp: Response = await client.get("/test")

        # Assert
        assert resp.status_code == 200
        assert "x-service" in resp.headers
        assert resp.headers["x-service"].startswith("api@") or resp.headers["x-service"].startswith("your-project-name@")

    async def test_process_time_and_trace_id_headers(self: TestMiddleware, test_app: FastAPI) -> None:
        """Test that process time and trace ID headers are present and valid."""
        # Arrange
        transport = ASGITransport(app=test_app)

        # Act
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp: Response = await client.get("/test")

        # Assert
        assert resp.status_code == 200
        assert "x-process-time" in resp.headers
        assert "x-trace-id" in resp.headers
        assert float(resp.headers["x-process-time"]) >= 0.0
        assert len(resp.headers["x-trace-id"]) > 0

    async def test_cors_allows_matching_origin(self: TestMiddleware, test_app: FastAPI) -> None:
        """Test that CORS allows requests from a matching origin."""
        # Arrange
        transport = ASGITransport(app=test_app)

        # Act
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp: Response = await client.options(
                "/cors-test",
                headers={
                    "Origin": "http://localhost:3000",
                    "Access-Control-Request-Method": "GET"
                }
            )

        # Assert
        assert resp.status_code == 200
        assert resp.headers.get("access-control-allow-origin") == "http://localhost:3000"

    async def test_correlation_id_echo_and_generate(self: TestMiddleware, test_app: FastAPI) -> None:
        """Test that correlation ID is echoed back or generated if not provided."""
        transport = ASGITransport(app=test_app)
        custom_id = "test-correlation-id-123"

        async with AsyncClient(transport=transport, base_url="http://test") as client:
            # Act & Assert - custom correlation ID
            resp: Response = await client.get("/test", headers={"X-Correlation-ID": custom_id})
            assert resp.status_code == 200
            assert resp.headers.get("x-correlation-id") == custom_id

            # Act & Assert - generated correlation ID
            resp2: Response = await client.get("/test")
            assert resp2.status_code == 200
            auto_id = resp2.headers.get("x-correlation-id")
            assert auto_id is not None and auto_id != custom_id and len(auto_id) > 0

    async def test_csp_header_injected(self: TestMiddleware, test_app: FastAPI) -> None:
        """Test that Content Security Policy (CSP) header is injected."""
        # Arrange
        transport = ASGITransport(app=test_app)

        # Act
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp: Response = await client.get("/test")

        # Assert
        assert resp.status_code == 200
        assert "content-security-policy" in resp.headers
        assert "default-src" in resp.headers["content-security-policy"]

    async def test_csrf_cookie_and_header_validation(self: TestMiddleware, test_app: FastAPI) -> None:
        """Test CSRF cookie and header validation."""
        transport = ASGITransport(app=test_app)

        async with AsyncClient(transport=transport, base_url="http://test") as client:
            # Arrange - GET to receive CSRF cookie
            get_resp: Response = await client.get("/test")
            assert get_resp.status_code == 200
            token = get_resp.cookies["csrftoken"]
            client.cookies.set("csrftoken", token)

            # Act & Assert - valid CSRF header
            post_resp_ok: Response = await client.post("/test", headers={"X-CSRFToken": token})
            assert post_resp_ok.status_code == 200
            assert post_resp_ok.json()["message"] == "POST OK"

            # Act & Assert - missing header
            client.cookies.set("csrftoken", token)
            post_resp_missing: Response = await client.post("/test")
            assert post_resp_missing.status_code == 403
            assert "csrf token" in post_resp_missing.text.lower()

            # Act & Assert - mismatched token
            client.cookies.set("csrftoken", token)
            post_resp_mismatch: Response = await client.post("/test", headers={"X-CSRFToken": "invalid-token"})
            assert post_resp_mismatch.status_code == 403
            assert "doesn't match the cookie" in post_resp_mismatch.text.lower()

    async def test_rate_limit_resets_cleanly(self: TestMiddleware, isolated_rate_limited_app: FastAPI) -> None:
        """Test that rate limiting resets cleanly after the block duration."""
        # Arrange
        transport = ASGITransport(app=isolated_rate_limited_app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            # Act - trigger block
            r1 = await client.get("/ratelimit-test")
            r2 = await client.get("/ratelimit-test")
            r3 = await client.get("/ratelimit-test")  # expect 429

            # Assert block
            assert r1.status_code == 200
            assert r2.status_code == 200
            assert r3.status_code == 429

            # Wait for window reset
            await asyncio.sleep(2.5)

            # Retry
            r4 = await client.get("/ratelimit-test")
            assert r4.status_code == 200
            assert r4.json()["message"] == "allowed"

    async def test_noop_rate_limit_does_not_block(self: TestMiddleware, no_op_rate_limit_app: FastAPI) -> None:
        """Test that no-op rate limiting does not block requests."""
        # Arrange
        transport = ASGITransport(app=no_op_rate_limit_app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            # Act - hammer the endpoint
            responses = [await client.get("/ratelimit-test") for _ in range(10)]

        # Assert - all succeed
        assert all(r.status_code == 200 for r in responses)
        assert all(r.json()["message"] == "still allowed" for r in responses)

    async def test_body_too_large_returns_413(self: TestMiddleware, body_limited_app: FastAPI) -> None:
        """Test that request body larger than limit returns 413 status code."""
        # Arrange
        transport = ASGITransport(app=body_limited_app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            body = b"x" * 200  # 200 > 100

            # Act
            response = await client.post("/upload", content=body)

            # Assert
            assert response.status_code == 413
            assert response.json()["detail"] == "Request body too large."
