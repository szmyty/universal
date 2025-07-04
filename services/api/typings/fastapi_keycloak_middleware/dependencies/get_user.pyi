"""
This type stub file was generated by pyright.
"""

from typing import Any
from fastapi import Request

"""
This module contains a helper function that can be used as FastAPI dependency
to easily retrieve the user object
"""
async def get_user(request: Request) -> Any | None:
    """
    This function can be used as FastAPI dependency
    to easily retrieve the user object
    """
    ...
