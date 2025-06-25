
def get_class_name(cls: object) -> str:
    """Get the class name of an object or class."""
    return getattr(cls, "__name__", cls.__class__.__name__)
