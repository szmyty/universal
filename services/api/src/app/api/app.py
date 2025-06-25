from fastapi import FastAPI
from fastapi.responses import JSONResponse
from fastapi.utils import generate_unique_id
from structlog import BoundLogger

from app.api.api import router as api_router
from app.api.middleware import add_middlewares
from app.core.settings import get_settings, Settings
from app.core.logging import get_logger
from app.core.lifecycle import startup, shutdown
from app.core.exceptions import add_exception_handlers

from contextlib import asynccontextmanager
from typing import AsyncGenerator


def create_app() -> FastAPI:
    """Create and configure an instance of the FastAPI application."""
    settings: Settings = get_settings()
    log: BoundLogger = get_logger()

    @asynccontextmanager
    async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
        await startup(app, log)
        yield
        await shutdown(app, log)

    app = FastAPI(
        debug=settings.debug,
        title=settings.project_name,
        version=settings.version,
        description=settings.description,
        openapi_url="/openapi.json",
        docs_url="/docs",
        redoc_url="/redoc",
        swagger_ui_oauth2_redirect_url="/docs/oauth2-redirect",
        default_response_class=JSONResponse,
        generate_unique_id_function=generate_unique_id,
        terms_of_service=settings.terms_of_service,
        contact=settings.contact,
        license_info=settings.license_info,
        root_path=settings.api_prefix,
        root_path_in_servers=True,
        lifespan=lifespan,
        separate_input_output_schemas=True,
    )

    if settings.keycloak.enabled:
        from app.auth.keycloak import add_keycloak
        add_keycloak(app)

    add_middlewares(app)
    add_exception_handlers(app)
    app.include_router(api_router)

    return app
