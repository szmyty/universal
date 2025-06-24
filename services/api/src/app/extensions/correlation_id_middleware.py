from __future__ import annotations

from uuid import uuid4
from starlette.types import ASGIApp, Receive, Scope, Send, Message
from starlette.requests import Request
from starlette.datastructures import MutableHeaders
from structlog.contextvars import bind_contextvars

class CorrelationIdMiddleware:
    """Middleware to manage correlation IDs for tracing requests."""
    def __init__(
        self: CorrelationIdMiddleware,
        app: ASGIApp,
        header_name: str = "X-Correlation-ID",
        include_in_response: bool = True,
    ) -> None:
        """Initialize the middleware with app, header name, and response inclusion flag."""
        self.app = app
        self.header_name = header_name
        self.include_in_response = include_in_response

    async def __call__(self: CorrelationIdMiddleware, scope: Scope, receive: Receive, send: Send) -> None:
        """Process the request to manage correlation ID."""
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        request = Request(scope)
        correlation_id = request.headers.get(self.header_name, str(uuid4()))
        bind_contextvars(correlation_id=correlation_id)

        async def send_wrapper(message: Message) -> None:
            """Send wrapper to add correlation ID to response headers if needed."""
            if (
                self.include_in_response
                and message["type"] == "http.response.start"
            ):
                headers = MutableHeaders(scope=message)
                headers[self.header_name] = correlation_id
            await send(message)

        await self.app(scope, receive, send_wrapper)
