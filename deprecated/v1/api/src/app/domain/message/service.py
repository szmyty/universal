from .model import Message


def create_message(msg_id: int, user_id: str, message: str) -> Message:
    """Instantiate a ``Message`` domain object."""
    return Message(id=msg_id, user_id=user_id, message=message)
