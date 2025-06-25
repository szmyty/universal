from __future__ import annotations

from datetime import datetime, timezone
from app.domain.health.enums import HealthStatus
from app.domain.health.models import HealthCheck
from app.domain.health.interfaces import HealthCheckRepository
from app.infrastructure.health.dao import HealthDAO

class DefaultHealthCheckRepository(HealthCheckRepository):
    async def check_health(self: DefaultHealthCheckRepository) -> HealthCheck:
        return HealthCheck(
            status=HealthStatus.HEALTHY,
            timestamp=datetime.now(timezone.utc),
            details={"database": "healthy"}
        )

class DatabaseHealthCheckRepository(HealthCheckRepository):
    def __init__(self: DatabaseHealthCheckRepository, dao: HealthDAO) -> None:
        self.dao: HealthDAO = dao

    async def check_health(self: DatabaseHealthCheckRepository) -> HealthCheck:
        db_healthy: bool = await self.dao.ping()
        return HealthCheck(
            status=HealthStatus.HEALTHY if db_healthy else HealthStatus.UNHEALTHY,
            timestamp=datetime.now(timezone.utc),
            details={"database": "healthy" if db_healthy else "unhealthy"}
        )
