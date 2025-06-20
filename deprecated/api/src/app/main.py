from fastapi import FastAPI

from .settings import get_settings
from .infrastructure.db import init_db
from .api.v1 import users, messages, map_states


settings = get_settings()
app = FastAPI(title=settings.PROJECT_NAME, description=settings.DESCRIPTION, version=settings.VERSION)

app.include_router(users.router)
app.include_router(messages.router)
app.include_router(map_states.router)


@app.on_event("startup")
async def on_startup() -> None:
    await init_db()


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
