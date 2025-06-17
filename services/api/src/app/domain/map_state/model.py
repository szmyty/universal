from dataclasses import dataclass
from typing import Any

@dataclass
class MapState:
    """Persisted map state for a user."""

    id: int
    user_id: str
    state: dict[str, Any]
