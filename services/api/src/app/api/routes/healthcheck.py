from fastapi import APIRouter, Depends
from structlog import BoundLogger

from app.core.logging import get_logger
from app.schemas.health.response import HealthCheckResponse
from app.services.health_service import HealthCheckService
from app.infrastructure.health.repository import DefaultHealthCheckRepository
from app.domain.health.models import HealthCheck

log: BoundLogger = get_logger()

router = APIRouter()

def get_healthcheck_service() -> HealthCheckService:
    repo = DefaultHealthCheckRepository()
    return HealthCheckService(repo)

@router.get("/health", response_model=HealthCheckResponse)
async def healthcheck(
    service: HealthCheckService = Depends(get_healthcheck_service),
) -> HealthCheckResponse:
    result: HealthCheck = await service.run()
    log.info("Health check result", result=result)
    return result.to_response()
