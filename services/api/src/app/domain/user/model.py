from dataclasses import dataclass
from typing import Optional

@dataclass
class User:
    """Domain model for a user account."""

    id: str
    preferred_username: Optional[str] = None
    email: Optional[str] = None
