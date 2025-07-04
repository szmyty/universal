from __future__ import annotations

import os
import platform
import getpass

from pathlib import Path
import re
from structlog import BoundLogger
from tzlocal import get_localzone_name
from functools import lru_cache
from typing import Any, List
from pydantic import BaseModel, Field, SecretStr, PostgresDsn, model_validator
from pydantic_settings import (
    BaseSettings,
    SettingsConfigDict,
    PydanticBaseSettingsSource,
    DotEnvSettingsSource,
    PyprojectTomlConfigSettingsSource,
)
from spdx_license_list import LICENSES
from piccolo_api.rate_limiting.middleware import InMemoryLimitProvider
from piccolo_api.rate_limiting.middleware import RateLimitProvider

from app.extensions.rate_limiting_middleware import NoOpLimitProvider

class KeycloakSettings(BaseModel):
    """Configuration for connecting to Keycloak OIDC server."""
    model_config = SettingsConfigDict(
        env_prefix="KEYCLOAK_",
        env_nested_delimiter="_",
    )

    enabled: bool = Field(default=False, description="Enable Keycloak authentication")
    hostname: str = Field(default="keycloak", description="Keycloak service host")
    http_port: int = Field(default=8080, description="Keycloak HTTP port")
    https_port: int = Field(default=8443, description="Keycloak HTTPS port")
    realm: str = Field(default="universal", description="Keycloak realm name")
    client_id: str = Field(default="universal-client", description="OIDC client ID")
    client_secret: SecretStr = Field(..., description="OIDC client secret")
    http_relative_path: str = Field(default="/auth", description="Base Keycloak path")
    swagger_client_id: str = Field(default="swagger-ui", description="Client ID used for Swagger UI OAuth2 authorization")
    verify_ssl: bool = Field(default=True, description="Whether to verify Keycloak's SSL certificate")

    @property
    def http_url(self: KeycloakSettings) -> str:
        return f"http://{self.hostname}:{self.http_port}{self.http_relative_path}"

    @property
    def https_url(self: KeycloakSettings) -> str:
        return f"https://{self.hostname}:{self.https_port}{self.http_relative_path}"

    @property
    def base_issuer_url(self: KeycloakSettings) -> str:
        return f"{self.https_url}/realms/{self.realm}"

    @property
    def openid_config_url(self: KeycloakSettings) -> str:
        return f"{self.base_issuer_url}/.well-known/openid-configuration"

    @property
    def token_url(self: KeycloakSettings) -> str:
        return f"{self.base_issuer_url}/protocol/openid-connect/token"

    @property
    def jwks_url(self: KeycloakSettings) -> str:
        return f"{self.base_issuer_url}/protocol/openid-connect/certs"

class DatabaseSettings(BaseModel):
    model_config = SettingsConfigDict(
        env_prefix="DATABASE_",
        env_nested_delimiter="_",
    )

    backend: str = Field("postgresql+asyncpg", description="Database engine, e.g., 'postgresql+asyncpg' or 'sqlite'")
    url: str | PostgresDsn | None = Field(
        default=None,
        description="Full database URL (overrides other fields if set)"
    )
    hostname: str = Field(
        default="localhost",
        description="Database hostname, e.g., 'localhost' or 'db'"
    )
    port: int = Field(
        default=5432,
        description="Database port, e.g., 5432 for PostgreSQL"
    )
    user: str = Field(
        default="postgres",
        description="Database username"
    )
    password: SecretStr = Field(
        default=...,
        description="Database password, should be kept secret"
    )
    name: str = Field(
        default="universal",
        description="Database name, e.g., 'universal'"
    )

    @model_validator(mode="before")
    @classmethod
    def build_url_from_components(cls: type[DatabaseSettings], values: dict[str, Any]) -> dict[str, Any]:
        # Only build if `url` is missing
            backend: str = str(values.get("backend", "postgresql+asyncpg"))

            if backend.startswith("sqlite"):
                # sqlite:///file.db or sqlite:///:memory:
                db_name: str = values.get("name", "sqlite.db")
                path: str = ":memory:" if db_name == ":memory:" else os.path.relpath(db_name)
                values["url"] = f"sqlite+aiosqlite:///{path}"
            elif backend.startswith("postgresql"):
                values["url"] = PostgresDsn.build(
                    scheme=backend,
                    username=values["user"],
                    password=values["password"].get_secret_value() if isinstance(values["password"], SecretStr) else values["password"],
                    host=values["hostname"],
                    port=int(values["port"]),
                    path=values["name"],
                )
            else:
                raise ValueError(f"Unsupported database backend: {backend}")

            return values

class SystemSettings(BaseModel):
    project_root: Path = Field(default_factory=lambda: Path(__file__).resolve().parents[3])
    shell: str = Field(default_factory=lambda: Path(os.environ.get("SHELL", "unknown")).name)
    os_name: str = Field(default_factory=platform.system)
    os_version: str = Field(default_factory=platform.version)
    python_version: str = Field(default_factory=lambda: platform.python_version())
    user: str = Field(default_factory=getpass.getuser)
    inside_container: bool = Field(default_factory=lambda: Path("/.dockerenv").exists())
    ci: bool = Field(default_factory=lambda: "CI" in os.environ)
    timezone: str = Field(default_factory=get_localzone_name)

class Settings(BaseSettings):
    project_name: str = Field(..., alias="name", description="Project name, e.g., 'Universal API'")
    version: str = Field(..., alias="version", description="Project version, e.g., '1.0.0'")
    description: str = Field(..., alias="description", description="Project description")
    environment: str = Field(default="development", alias="APP_ENV", description="Deployment environment, e.g., 'development', 'production'")
    license: str = Field(default="MIT", alias="license", description="License type, e.g., 'MIT'")
    fqdn: str = Field(default="localhost", alias="FQDN", description="Fully qualified domain name for the service")
    debug: bool = Field(default=False, alias="UI_DEBUG_MODE", description="Enable debug mode")
    log_level: str = Field(default="INFO", alias="UI_LOG_LEVEL", description="Logging level for the application")
    log_file: str = Field(default="logs/app.log", alias="UI_LOG_FILE", description="Path to the log file")
    api_prefix: str = Field(default="/api", alias="API_PREFIX", description="API URL prefix")
    cors_allow_credentials: bool = Field(default=True, alias="CORS_ALLOW_CREDENTIALS", description="Allow credentials in CORS")
    cors_allow_methods: str = Field(default="*")
    cors_allow_headers: str = Field(default="*")
    https_redirect: bool = Field(default=False, alias="HTTPS_REDIRECT", description="Redirect HTTP to HTTPS")
    rate_limit_enabled: bool = Field(default=False, description="Enable rate limiting")
    rate_limit_max_requests: int = Field(default=1000, description="Max requests in the time window")
    rate_limit_timespan: int = Field(default=300, description="Time window for rate limiting in seconds")
    rate_limit_block_duration: int = Field(default=300, description="Block duration in seconds after exceeding rate limit")
    body_size_max_bytes: int = Field(default=1_000_000_000, alias="MAX_BODY_SIZE_BYTES", description="Max request body size in bytes")

    database: DatabaseSettings
    keycloak: KeycloakSettings
    system: SystemSettings = Field(default_factory=SystemSettings)

    model_config = SettingsConfigDict(
        env_file=os.environ.get("ENV_FILE_OVERRIDE", ".env"),
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
        env_nested_max_split=1,
        env_nested_delimiter='_',
        pyproject_toml_table_header=("tool", "poetry"),
    )

    @property
    def terms_of_service(self: Settings) -> str:
        return f"https://{self.fqdn}/terms/"

    @property
    def license_info(self: Settings) -> dict[str, str]:
        from app.utils.license import get_license_info
        return get_license_info(self.license)

    @property
    def contact(self: Settings) -> dict[str, str]:
        return {
            "name": "Alan Szmyt",
            "url": f"https://{self.fqdn}/contact/",
            "email": "szmyty@gmail.com",
        }

    @property
    def cors_origin_regex(self: Settings) -> str:
        """
        Allow all ports on the current FQDN for development.
        Produces something like: r"^http://localhost:\\d+$"
        """
        escaped: str = re.escape(self.fqdn)
        return rf"^https?://{escaped}(:\d+)?$"

    @property
    def cors_allow_methods_list(self: Settings) -> List[str]:
        """Parses the CORS allow methods string into a list of methods."""
        return [method.strip() for method in self.cors_allow_methods.split(",") if method.strip()]

    @property
    def cors_allow_headers_list(self: Settings) -> List[str]:
        """Parses the CORS allow headers string into a list of headers."""
        return [header.strip() for header in self.cors_allow_headers.split(",") if header.strip()]

    @property
    def rate_limit_provider(self: Settings) -> RateLimitProvider:
        """Returns the appropriate rate limit provider based on settings."""
        if self.rate_limit_enabled:
            return InMemoryLimitProvider(
                limit=self.rate_limit_max_requests,
                timespan=self.rate_limit_timespan,
                block_duration=self.rate_limit_block_duration,
            )
        return NoOpLimitProvider()

    @classmethod
    def settings_customise_sources(
        cls: type[Settings],
        settings_cls: type[BaseSettings],
        init_settings: PydanticBaseSettingsSource,
        env_settings: PydanticBaseSettingsSource,
        dotenv_settings: PydanticBaseSettingsSource,
        file_secret_settings: PydanticBaseSettingsSource,
    ) -> tuple[PydanticBaseSettingsSource, ...]:
        override_path: str = os.environ.get("ENV_FILE_OVERRIDE", ".env")
        dotenv = DotEnvSettingsSource(
            cls,
            env_file=Path(override_path),
            env_file_encoding="utf-8",
        )
        return (
            init_settings,
            PyprojectTomlConfigSettingsSource(cls),
            env_settings,
            dotenv,
            file_secret_settings,
        )

    @model_validator(mode="after")
    def validate_license(self) -> Settings:
        """Ensure the provided license is a valid SPDX identifier."""
        if self.license not in LICENSES:
            raise ValueError(f"Invalid SPDX license ID: {self.license}")
        return self

    def print_settings_summary(self: Settings) -> None:
        """Logs a summary of the current settings, masking sensitive information."""
        from app.core.logging import get_logger
        log: BoundLogger = get_logger()
        log.info("Application Settings Summary", settings=self.model_dump())
        safe_settings: dict[str, Any | str] = {k: v if not isinstance(v, SecretStr) else "********" for k, v in self.model_dump().items()}
        for key, value in safe_settings.items():
            log.info(f"  {key}: {value}")

@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance, ensuring log directory exists."""
    settings = Settings() # type: ignore
    log_dir: Path = Path(settings.log_file).parent
    log_dir.mkdir(parents=True, exist_ok=True)
    return settings
