from __future__ import annotations

from time import perf_counter
from uuid import uuid4
from starlette.types import ASGIApp, Receive, Scope, Send, Message
from starlette.requests import Request
from starlette.datastructures import MutableHeaders

from structlog import BoundLogger
from structlog.contextvars import bind_contextvars, clear_contextvars

from app.core.logging import get_logger
from app.core.settings import Settings, get_settings

log: BoundLogger = get_logger()

class ProcessTimeMiddleware:
    """Middleware to measure and log the processing time of each request."""
    def __init__(self: ProcessTimeMiddleware, app: ASGIApp) -> None:
        """Initialize the middleware with the ASGI application and settings."""
        self.app = app
        self.settings: Settings = get_settings()

    async def __call__(self: ProcessTimeMiddleware, scope: Scope, receive: Receive, send: Send) -> None:
        """Measure and log the processing time of each request."""
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        clear_contextvars()
        trace_id = str(uuid4())
        start: float = perf_counter()

        request = Request(scope)
        bind_contextvars(
            trace_id=trace_id,
            method=request.method,
            path=request.url.path,
            client_ip=request.client.host if request.client else None,
            service=self.settings.project_name,
            version=self.settings.version,
        )

        async def send_wrapper(message: Message) -> None:
            """Send wrapper to add processing time and trace ID to response headers."""
            if message["type"] == "http.response.start":
                duration: float = perf_counter() - start
                headers = MutableHeaders(scope=message)
                headers["X-Process-Time"] = f"{duration:.4f}"
                headers["X-Trace-Id"] = trace_id

                log.debug(
                    "✅ Request completed",
                    trace_id=trace_id,
                    method=request.method,
                    path=request.url.path,
                    status_code=message["status"],
                    duration=duration,
                )
            await send(message)

        await self.app(scope, receive, send_wrapper)
