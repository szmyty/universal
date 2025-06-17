class UserError(Exception):
    """Base class for user-related domain errors."""


class UserNotFound(UserError):
    """Raised when a user cannot be located."""
