from .model import MapState
from typing import Any


def create_map_state(state_id: int, user_id: str, state: dict[str, Any]) -> MapState:
    """Instantiate a ``MapState`` domain object."""
    return MapState(id=state_id, user_id=user_id, state=state)
