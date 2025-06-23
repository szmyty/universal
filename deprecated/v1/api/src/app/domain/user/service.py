from .model import User


def create_user(user_id: str, preferred_username: str | None, email: str | None) -> User:
    """Instantiate a new ``User`` domain object."""
    return User(id=user_id, preferred_username=preferred_username, email=email)
