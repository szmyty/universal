from fastapi import APIRouter

from app.api.routes import healthcheck, maps, messages, profile

router = APIRouter()
router.include_router(healthcheck.router, tags=["Healthcheck"])
router.include_router(messages.router, tags=["Messages"])
router.include_router(profile.router, tags=["Profile"])
router.include_router(maps.router, tags=["Maps"])
