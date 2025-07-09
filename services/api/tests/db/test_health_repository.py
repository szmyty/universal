from __future__ import annotations
import pytest

from app.infrastructure.health.repository import DefaultHealthCheckRepository
from app.domain.health.models import HealthCheck
from app.domain.health.enums import HealthStatus

@pytest.mark.anyio
@pytest.mark.unit
@pytest.mark.health
class TestHealthRepository:
    """Unit tests for DefaultHealthCheckRepository."""

    async def test_health_repository_returns_healthy(self: TestHealthRepository) -> None:
        """Test that the health repository returns a healthy status."""
        # Arrange
        repo = DefaultHealthCheckRepository()

        # Act
        result: HealthCheck = await repo.check_health()

        # Assert
        assert isinstance(result, HealthCheck)
        assert result.status == HealthStatus.HEALTHY
        assert result.details == {"database": "healthy"}
