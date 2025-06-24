from __future__ import annotations
from typing import Optional

from starlette.types import ASGIApp, Scope, Receive, Send, Message
from starlette.datastructures import MutableHeaders

from app.security.csp import CSPStrategy, get_csp_strategy


class CSPMiddleware:
    """Adds Content Security Policy headers to the response based on the selected strategy."""
    def __init__(self: CSPMiddleware, app: ASGIApp, strategy: Optional[CSPStrategy] = None) -> None:
        """Initialize the middleware with the ASGI app and an optional CSP strategy."""
        self.app: ASGIApp = app
        self.strategy: CSPStrategy = strategy or get_csp_strategy()
        self.policy: str = self.strategy.get_config().build_policy()

    async def __call__(self: CSPMiddleware, scope: Scope, receive: Receive, send: Send) -> None:
        """ASGI application callable."""
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        async def send_wrapper(message: Message) -> None:
            """Wrap the send function to modify the response headers."""
            if message["type"] == "http.response.start":
                headers = MutableHeaders(scope=message)
                headers["Content-Security-Policy"] = self.policy
            await send(message)

        await self.app(scope, receive, send_wrapper)
