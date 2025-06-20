from functools import lru_cache
from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application configuration."""

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", env_nested_delimiter="__")

    PROJECT_NAME: str = Field("Universal API", description="Name of the project")
    DESCRIPTION: str = Field("A universal API for various services", description="Description of the project")
    VERSION: str = Field("0.1.0", description="Version of the project")

    LOG_LEVEL: str = Field("INFO", description="Logging level")
    LOG_FILE: str = Field("logs/app.log", description="Path to the log file")
    LOG_JSON: bool = Field(False, description="Enable JSON logging")

    DB_HOST: str = Field("localhost", description="Database host")
    DB_PORT: int = Field(5432, description="Database port")
    DB_USER: str = Field("postgres", description="Database user")
    DB_PASSWORD: str = Field("postgres", description="Database password")
    DB_NAME: str = Field("universal", description="Database name")
    DATABASE_URL_OVERRIDE: str | None = Field(None, alias="DATABASE_URL")

    @property
    def DATABASE_URL(self) -> str:
        if self.DATABASE_URL_OVERRIDE:
            return self.DATABASE_URL_OVERRIDE
        return (
            f"postgresql+asyncpg://{self.DB_USER}:{self.DB_PASSWORD}@"
            f"{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
        )


@lru_cache()
def get_settings() -> Settings:
    return Settings()
