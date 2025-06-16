from sqlalchemy.orm import DeclarativeBase

class Base(DeclarativeBase):
    """
    Base class for all SQLAlchemy models.
    This class uses DeclarativeBase from SQLAlchemy to define the base class for all models.
    """
    __abstract__ = True  # This ensures that SQLAlchemy does not create a table for this class
    pass
