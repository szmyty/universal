from __future__ import annotations

from functools import lru_cache

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application configuration."""

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
    DEBUG: bool = Field(False, description="Enable debug mode")

    # Keycloak settings
    KEYCLOAK_HOSTNAME: str = Field("keycloak", env="KEYCLOAK_HOSTNAME", description="Keycloak hostname")
    KEYCLOAK_HTTP_PORT: int = Field(8080, env="KEYCLOAK_HTTP_PORT", description="Keycloak HTTP port")
    KEYCLOAK_HTTPS_PORT: int = Field(8443, env="KEYCLOAK_HTTPS_PORT", description="Keycloak HTTPS port")
    KEYCLOAK_REALM: str = Field("universal", env="KEYCLOAK_REALM", description="Keycloak realm name")
    KEYCLOAK_HTTP_RELATIVE_PATH: str = Field(
        "/auth", description="Relative path for Keycloak HTTP access")

    # Postgres settings
    DATABASE_HOSTNAME: str = Field(..., env="DATABASE_HOSTNAME", description="Postgres hostname")
    DATABASE_PORT: int = Field(5432, env="DATABASE_PORT", description="Postgres port")
    DATABASE_USER: str = Field("postgres", env="POSTGRES_USER", description="Postgres user")
    DATABASE_PASSWORD: SecretStr = Field(
        ..., env="POSTGRES_PASSWORD", description="Postgres password"
    )
    DATABASE_NAME: str = Field(..., env="POSTGRES_DB", description="Postgres database name")

    LOG_LEVEL: str = Field("INFO", description="Logging level")
    LOG_FILE: str = Field("logs/app.log", description="Path to the log file")
    LOG_JSON: bool = Field(False, description="Enable JSON logging")

    @property
    def database_url(self) -> str:
        """Return the SQLAlchemy database URL."""
        return (
            f"postgresql+asyncpg://{self.DB_USER}:{self.DB_PASSWORD}@"
            f"{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
        )

    @property
    def keycloak_url(self: Settings) -> str:
        """Return the Keycloak URL."""
        pass


@lru_cache()
def get_settings() -> Settings:
    """Return a cached ``Settings`` instance."""
    return Settings()
