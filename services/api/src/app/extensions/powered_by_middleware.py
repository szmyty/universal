from __future__ import annotations

from starlette.types import ASGIApp, Receive, Scope, Send, Message
from starlette.datastructures import MutableHeaders
from app.core.settings import Settings, get_settings

class PoweredByMiddleware:
    """Middleware to add X-Service header to all responses."""
    def __init__(self: PoweredByMiddleware, app: ASGIApp) -> None:
        """Initialize the middleware with the ASGI application and settings."""
        self.app = app
        self.settings: Settings = get_settings()

    async def __call__(self: PoweredByMiddleware, scope: Scope, receive: Receive, send: Send) -> None:
        """Add X-Service header to all responses."""
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        async def send_wrapper(message: Message) -> None:
            """Add X-Service header to response start messages."""
            if message["type"] == "http.response.start":
                headers = MutableHeaders(scope=message)
                print(f"{self.settings.project_name}@{self.settings.version}")
                headers["X-Service"] = f"{self.settings.project_name}@{self.settings.version}"
            await send(message)

        await self.app(scope, receive, send_wrapper)
