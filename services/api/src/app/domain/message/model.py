from dataclasses import dataclass

@dataclass
class Message:
    """Domain model for a user message."""

    id: int
    user_id: str
    message: str
