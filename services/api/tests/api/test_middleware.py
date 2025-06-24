from __future__ import annotations

import pytest
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient, Response
from starlette.responses import JSONResponse

from app.api.middleware import add_middlewares
from app.core.settings import Settings

@pytest.fixture
def test_app(settings: Settings) -> FastAPI:
    """Fixture for a FastAPI app with the PoweredByMiddleware."""
    app = FastAPI()
    add_middlewares(app)

    @app.get("/test")
    async def test_route() -> JSONResponse: # type: ignore
        """A simple test route."""
        return JSONResponse({"message": "ok"})

    @app.post("/test")
    async def test_post_route() -> JSONResponse:  # type: ignore
        """A simple test POST route."""
        return JSONResponse({"message": "POST OK"})

    @app.get("/cors-test")
    async def cors_test() -> JSONResponse:  # type: ignore
        """A simple test route for CORS."""
        return JSONResponse({"message": "CORS OK"})

    return app


class TestMiddleware:
    """Test suite for the PoweredByMiddleware."""
    async def test_x_service_header_present(self: TestMiddleware, test_app: FastAPI) -> None:
        """Ensure that X-Service header is present in the response."""
        transport = ASGITransport(app=test_app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp: Response = await client.get("/test")

        assert resp.status_code == 200
        assert "x-service" in resp.headers

        header = resp.headers["x-service"]
        assert header.startswith("api@") or header.startswith("your-project-name@")

    async def test_process_time_and_trace_id_headers(self: TestMiddleware, test_app: FastAPI) -> None:
        """Ensure that X-Process-Time and X-Trace-Id headers are present."""
        transport = ASGITransport(app=test_app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp: Response = await client.get("/test")

        assert resp.status_code == 200
        assert "x-process-time" in resp.headers
        assert "x-trace-id" in resp.headers

        assert float(resp.headers["x-process-time"]) >= 0.0
        assert len(resp.headers["x-trace-id"]) > 0

    async def test_cors_allows_matching_origin(self: TestMiddleware, test_app: FastAPI) -> None:
        """Test that CORS allows requests from a matching origin (e.g. localhost:3000)."""
        transport = ASGITransport(app=test_app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp: Response = await client.options(
                "/cors-test",
                headers={
                    "Origin": "http://localhost:3000",
                    "Access-Control-Request-Method": "GET"
                }
            )

        assert resp.status_code == 200
        assert resp.headers.get("access-control-allow-origin") == "http://localhost:3000"

    async def test_correlation_id_echo_and_generate(self: TestMiddleware, test_app: FastAPI) -> None:
        """Test that CorrelationIdMiddleware echoes incoming header or generates a new one."""
        transport = ASGITransport(app=test_app)
        custom_id = "test-correlation-id-123"

        async with AsyncClient(transport=transport, base_url="http://test") as client:
            # Case 1: Provided Correlation ID is echoed back
            resp: Response = await client.get("/test", headers={"X-Correlation-ID": custom_id})
            assert resp.status_code == 200
            assert resp.headers.get("x-correlation-id") == custom_id

            # Case 2: No Correlation ID — should auto-generate
            resp2: Response = await client.get("/test")
            assert resp2.status_code == 200
            auto_id = resp2.headers.get("x-correlation-id")
            assert auto_id is not None and auto_id != custom_id and len(auto_id) > 0

    async def test_csp_header_injected(self: TestMiddleware, test_app: FastAPI) -> None:
        """Ensure that the Content-Security-Policy header is added by the middleware."""
        transport = ASGITransport(app=test_app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp: Response = await client.get("/test")

        assert resp.status_code == 200
        csp_header = resp.headers.get("content-security-policy")
        assert csp_header is not None
        assert "default-src" in csp_header

    async def test_csrf_cookie_and_header_validation(self: TestMiddleware, test_app: FastAPI) -> None:
        """Test CSRF middleware: cookie issued, header required, and validated."""
        transport = ASGITransport(app=test_app)

        async with AsyncClient(transport=transport, base_url="http://test") as client:
            # Step 1: GET to receive CSRF cookie
            get_resp: Response = await client.get("/test")
            assert get_resp.status_code == 200
            assert "csrftoken" in get_resp.cookies
            token = get_resp.cookies["csrftoken"]

            # Step 2: set cookie directly on client to avoid deprecation warning
            client.cookies.set("csrftoken", token)

            # Step 3: POST with correct CSRF token in header — should succeed
            post_resp_ok: Response = await client.post(
                "/test",
                headers={"X-CSRFToken": token},
            )
            assert post_resp_ok.status_code == 200
            assert post_resp_ok.json()["message"] == "POST OK"

            # Step 4: POST with missing token — should fail
            client.cookies.set("csrftoken", token)
            post_resp_missing: Response = await client.post("/test")
            assert post_resp_missing.status_code == 403
            assert "csrf token" in post_resp_missing.text.lower()

            # Step 5: POST with mismatched token — should fail
            client.cookies.set("csrftoken", token)
            post_resp_mismatch: Response = await client.post(
                "/test",
                headers={"X-CSRFToken": "invalid-token"},
            )
            assert post_resp_mismatch.status_code == 403
            assert "doesn't match the cookie" in post_resp_mismatch.text.lower()
