from __future__ import annotations

from piccolo_api.rate_limiting.middleware import RateLimitProvider

class NoOpLimitProvider(RateLimitProvider):
    """A no-op rate limit provider that does nothing."""
    def increment(self, identifier: str)  -> None:
        """No-op increment method."""
        pass  # no-op
