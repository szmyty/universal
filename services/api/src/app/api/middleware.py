from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from piccolo_api.csrf.middleware import CSRFMiddleware
from piccolo_api.rate_limiting.middleware import RateLimitingMiddleware
from structlog import BoundLogger

from app.extensions import (
    BodySizeLimitMiddleware,
    CorrelationIdMiddleware,
    LoggingMiddleware,
    PoweredByMiddleware,
    CSPMiddleware,
    ProcessTimeMiddleware
)

from app.core.settings import Settings, get_settings
from app.core.logging import get_logger
from app.utils.general import get_class_name as get_middleware_name

def add_middlewares(app: FastAPI) -> None:
    """Add middlewares to the FastAPI application, in correct order."""
    settings: Settings = get_settings()
    log: BoundLogger = get_logger()

    # Rate Limiting (first line of defense)
    app.add_middleware(RateLimitingMiddleware, provider=settings.rate_limit_provider)

    # CSRF Protection
    app.add_middleware(
        CSRFMiddleware,
        allowed_hosts=[settings.fqdn],
        cookie_name="csrftoken",
        header_name="X-CSRFToken",
        allow_form_param=False,
        allow_header_param=True,
        max_age=31536000,
    )

    # HTTPS redirect (if enabled)
    if settings.https_redirect:
        app.add_middleware(HTTPSRedirectMiddleware)

    # Trusted Host enforcement
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=["*"]  # Update in prod
    )

    # Body Size Limit
    app.add_middleware(
        BodySizeLimitMiddleware,
        max_body_size=settings.body_size_max_bytes,
    )

    # CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origin_regex=settings.cors_origin_regex,
        allow_credentials=settings.cors_allow_credentials,
        allow_methods=settings.cors_allow_methods_list,
        allow_headers=settings.cors_allow_headers_list,
        max_age=600,
    )

    # CSP
    app.add_middleware(CSPMiddleware)

    # GZip
    app.add_middleware(
        GZipMiddleware,
        minimum_size=1000,
        compresslevel=5
    )

    # Correlation ID
    app.add_middleware(CorrelationIdMiddleware)

    # Request/Response Logging
    app.add_middleware(LoggingMiddleware)

    # X-Service header
    app.add_middleware(PoweredByMiddleware)

    # Process timing (outermost layer)
    app.add_middleware(ProcessTimeMiddleware)

    # Log installed middlewares in declared order
    log.info(
        "🧩 Middleware stack initialized",
        middlewares=[get_middleware_name(middleware.cls) for middleware in app.user_middleware]
    )
    log.info("✅ All middlewares added")

    log.info("🔧 Rate limit config", provider=settings.rate_limit_provider, limit=settings.rate_limit_max_requests)
