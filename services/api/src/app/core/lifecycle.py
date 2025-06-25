import logging
from fastapi import FastAPI
from structlog import BoundLogger
from app.core.settings import get_settings
from app.db.migrations import run_migrations_async

async def startup(app: FastAPI, log: BoundLogger) -> None:
    settings = get_settings()
    log.info("🚀 Startup initiated")
    try:
        settings.print_settings_summary()
        await run_migrations_async()
        logging.getLogger("watchfiles").setLevel(logging.WARNING)
        log.info("✅ Application startup complete")
    except Exception as e:
        log.exception("🔥 Exception during startup", error=str(e))


async def shutdown(app: FastAPI, log: BoundLogger) -> None:
    log.info("🛑 Shutting down")
    log.info("🛑 Shutdown complete")
