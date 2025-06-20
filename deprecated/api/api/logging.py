import logging
from logging.handlers import RotatingFileHandler
import os
import asyncio
import structlog

from .config import get_config

log = structlog.get_logger(__name__)


def setup_logging() -> None:
    """Configure structlog and standard logging based on settings."""
    cfg = get_config()
    level = getattr(logging, cfg.LOG_LEVEL.upper(), logging.INFO)

    os.makedirs(os.path.dirname(cfg.LOG_FILE), exist_ok=True)

    handlers: list[logging.Handler] = []
    console_handler = logging.StreamHandler()
    handlers.append(console_handler)

    file_handler = RotatingFileHandler(
        cfg.LOG_FILE, maxBytes=10_000_000, backupCount=5
    )
    handlers.append(file_handler)

    error_handler = RotatingFileHandler(
        os.path.join(os.path.dirname(cfg.LOG_FILE), "error.log"),
        maxBytes=10_000_000,
        backupCount=5,
    )
    error_handler.setLevel(logging.ERROR)
    handlers.append(error_handler)

    logging.basicConfig(level=level, handlers=handlers, format="%(message)s")

    processors = [
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
    ]
    if cfg.LOG_JSON:
        processors.append(structlog.processors.JSONRenderer())
    else:
        processors.append(structlog.dev.ConsoleRenderer())

    structlog.configure(
        processors=processors,
        wrapper_class=structlog.make_filtering_bound_logger(level),
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )

    log.info("Logging configured", level=cfg.LOG_LEVEL, json=cfg.LOG_JSON, file=cfg.LOG_FILE)


def catch_and_log_exceptions(func):
    """Decorator to catch exceptions and log them."""
    if asyncio.iscoroutinefunction(func):
        async def wrapper(*args, **kwargs):
            try:
                return await func(*args, **kwargs)
            except Exception:
                log.exception("Unhandled exception")
                raise
        return wrapper

    def sync_wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception:
            log.exception("Unhandled exception")
            raise
    return sync_wrapper
