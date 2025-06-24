from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from piccolo_api.csrf.middleware import CSRFMiddleware

from app.extensions.csp_middleware import CSPMiddleware
from app.extensions.powered_by_middleware import PoweredByMiddleware
from app.extensions.process_time_middleware import ProcessTimeMiddleware
from app.extensions.correlation_id_middleware import CorrelationIdMiddleware
from app.core.settings import Settings, get_settings

def add_middlewares(app: FastAPI) -> None:
    """Add middlewares to the FastAPI application."""
    settings: Settings = get_settings()

    app.add_middleware(ProcessTimeMiddleware)
    app.add_middleware(PoweredByMiddleware)
    app.add_middleware(CorrelationIdMiddleware)

    app.add_middleware(
        GZipMiddleware,
        minimum_size=1000,
        compresslevel=5
    )

    # Example: allowed_hosts=["example.com", "*.example.com"]
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=["*"]
    )

    # Add CORS middleware
    # https://fastapi.tiangolo.com/tutorial/cors/
    app.add_middleware(
        CORSMiddleware,
        allow_origin_regex=settings.cors_origin_regex,
        allow_credentials=settings.cors_allow_credentials,
        allow_methods=settings.cors_allow_methods_list,
        allow_headers=settings.cors_allow_headers_list,
        max_age=600,
    )

    if settings.https_redirect:
        app.add_middleware(HTTPSRedirectMiddleware)

    app.add_middleware(CSPMiddleware)

    # Add CSRF protection middleware
    app.add_middleware(
        CSRFMiddleware,
        allowed_hosts=[settings.fqdn],           # Only required for HTTPS
        cookie_name="csrftoken",                 # Default name
        header_name="X-CSRFToken",               # Matches frontend JS libs
        allow_form_param=False,                  # Enable if posting forms
        allow_header_param=True,                 # Needed for JS/AJAX
        max_age=31536000,                        # 1 year (optional)
    )
