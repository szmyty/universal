from __future__ import annotations
from typing import Sequence

from starlette.types import ASGIApp, Scope, Receive, Send, Message
from starlette.status import HTTP_413_REQUEST_ENTITY_TOO_LARGE
from structlog import BoundLogger

from app.core.logging import get_logger

log: BoundLogger = get_logger()

class BodySizeLimitMiddleware:
    def __init__(self, app: ASGIApp, max_body_size: int, exclude_paths: Sequence[str] = ()) -> None:
        self.app = app
        self.max_body_size = max_body_size
        self.exclude_paths = set(exclude_paths)

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http" or scope["path"] in self.exclude_paths:
            await self.app(scope, receive, send)
            return

        total_size = 0
        body_too_large = False

        async def limited_receive() -> Message:
            nonlocal total_size, body_too_large
            message = await receive()

            if message["type"] == "http.request":
                chunk = message.get("body", b"")
                total_size += len(chunk)

                if total_size > self.max_body_size:
                    body_too_large = True
            return message

        # Call limited_receive to pre-buffer the body check
        while True:
            message = await limited_receive()
            if message.get("more_body") is not True or body_too_large:
                break

        if body_too_large:
            log.debug(
                "🚫 Request body too large",
                path=scope.get("path"),
                method=scope.get("method"),
                size=total_size,
                limit=self.max_body_size,
            )
            await send({
                "type": "http.response.start",
                "status": HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                "headers": [(b"content-type", b"application/json")]
            })
            await send({
                "type": "http.response.body",
                "body": b'{"detail":"Request body too large."}',
                "more_body": False
            })
            return

        # If okay, forward with the original body stream
        await self.app(scope, receive, send)
