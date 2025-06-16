from __future__ import annotations

from functools import lru_cache

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    """Configuration settings for the application."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        env_nested_delimiter="__",
    )

    PROJECT_NAME: str = Field("Universal API", description="Name of the project")
    DESCRIPTION: str = Field(
        "A universal API for various services", description="Description of the project"
    )
    VERSION: str = Field("0.1.0", description="Version of the project")

    LOG_LEVEL: str = Field("INFO", description="Logging level")
    LOG_FILE: str = Field("logs/app.log", description="Path to the log file")
    LOG_JSON: bool = Field(False, description="Enable JSON logging")

    OIDC_ISSUER: str = Field(..., description="OIDC issuer URL")
    OIDC_CLIENT_ID: str = Field(..., description="OIDC client ID")
    OIDC_CLIENT_SECRET: SecretStr = Field(..., description="OIDC client secret")
