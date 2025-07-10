from __future__ import annotations

import json
from typing import Any

from starlette.requests import Request
from starlette.types import ASGIApp, Receive, Scope, Send, Message
from app.core.settings import Settings, get_settings
from structlog import BoundLogger, get_logger

logger: BoundLogger = get_logger()


class LoggingMiddleware:
    """Middleware to log HTTP requests and responses."""

    def __init__(self: LoggingMiddleware, app: ASGIApp) -> None:
        """Initialize the middleware with the ASGI application and settings."""
        self.app = app
        self.settings: Settings = get_settings()

    async def __call__(self: LoggingMiddleware, scope: Scope, receive: Receive, send: Send) -> None:
        """Intercept requests and log data."""
        if scope["type"] != "http" or not self.settings.log_requests:
            await self.app(scope, receive, send)
            return

        request = Request(scope)

        # Clone the body from receive() so we can read it here and again later
        body: bytes = b""

        async def inner_receive() -> Message:
            nonlocal body
            message = await receive()
            if message["type"] == "http.request":
                body += message.get("body", b"")
            return message

        async def send_wrapper(message: Message) -> None:
            """Log response status."""
            if message["type"] == "http.response.start":
                status: Any | str = message.get("status", "unknown")
                logger.info("response", status_code=status)
            await send(message)

        # Log incoming request
        try:
            parsed_body: str | dict[str, Any] = body.decode("utf-8")
            parsed_body = json.loads(parsed_body)
        except Exception:
            parsed_body = body.decode("utf-8", errors="replace")

        logger.info(
            "request",
            method=request.method,
            url=str(request.url),
            headers=dict(request.headers),
            body=parsed_body,
        )

        await self.app(scope, inner_receive, send_wrapper)
