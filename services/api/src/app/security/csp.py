from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Optional, Type

from app.core.settings import get_settings

@dataclass
class CSPConfig:
    """Configuration for Content Security Policy."""
    default_src: str = "'self'"
    script_src: Optional[str] = None
    style_src: Optional[str] = None
    font_src: Optional[str] = None
    img_src: Optional[str] = None
    connect_src: Optional[str] = None
    frame_src: Optional[str] = None
    media_src: Optional[str] = None
    object_src: Optional[str] = None
    report_uri: Optional[str] = None

    def build_policy(self: CSPConfig) -> str:
        """Construct the CSP policy string from the configuration."""
        directives: list[str] = []

        def add(key: str, value: Optional[str]) -> None:
            if value is not None:
                directives.append(f"{key} {value}")

        add("default-src", self.default_src)
        add("script-src", self.script_src)
        add("style-src", self.style_src)
        add("font-src", self.font_src)
        add("img-src", self.img_src)
        add("connect-src", self.connect_src)
        add("frame-src", self.frame_src)
        add("media-src", self.media_src)
        add("object-src", self.object_src)
        add("report-uri", self.report_uri)

        return "; ".join(directives) + ";"

class CSPStrategy(ABC):
    """Abstract base class for CSP strategies."""
    @staticmethod
    @abstractmethod
    def match(env: str) -> bool:
        """Determine if this strategy matches the given environment."""
        ...

    @abstractmethod
    def get_config(self: CSPStrategy) -> CSPConfig:
        """Get the CSP configuration for this strategy."""
        ...

class DevCSPStrategy(CSPStrategy):
    """Development environment CSP strategy."""
    @staticmethod
    def match(env: str) -> bool:
        """Check if the environment is development."""
        return env.lower() == "development" or env.lower() == "dev"

    def get_config(self: DevCSPStrategy) -> CSPConfig:
        """Get the CSP configuration for development."""
        return CSPConfig(
            default_src="'self'",
            script_src="'self' 'unsafe-inline' https://cdn.jsdelivr.net",
            style_src="'self' 'unsafe-inline' https://fonts.googleapis.com",
            font_src="'self' https://fonts.gstatic.com",
            img_src="* data:",
            connect_src="*"
        )


class ProdCSPStrategy(CSPStrategy):
    """Production environment CSP strategy."""
    @staticmethod
    def match(env: str) -> bool:
        """Check if the environment is production."""
        return env.lower() == "production" or env.lower() == "prod"

    def get_config(self: ProdCSPStrategy) -> CSPConfig:
        """Get the CSP configuration for production."""
        return CSPConfig(
            default_src="'self'",
            script_src="'self'",
            style_src="'self'",
            font_src="'self'",
            img_src="'self'",
            connect_src="'self'"
        )


class DemoCSPStrategy(CSPStrategy):
    """Demo environment CSP strategy."""
    @staticmethod
    def match(env: str) -> bool:
        """Check if the environment is demo."""
        return env.lower() == "demonstration" or env.lower() == "demo"

    def get_config(self: DemoCSPStrategy) -> CSPConfig:
        """Get the CSP configuration for demo."""
        return CSPConfig(
            default_src="'self'",
            script_src="'self' 'unsafe-inline' https://cdn.jsdelivr.net",
            style_src="'self' 'unsafe-inline' https://fonts.googleapis.com",
            font_src="'self' https://fonts.gstatic.com",
            img_src="* data:",
            connect_src="*"
        )

def get_csp_strategy() -> CSPStrategy:
    """Select the appropriate CSP strategy based on the environment."""
    env: str = get_settings().environment.lower()
    strategies: list[Type[CSPStrategy]] = [
        ProdCSPStrategy,
        DemoCSPStrategy,
        DevCSPStrategy,
    ]
    for strategy_cls in strategies:
        if strategy_cls.match(env):
            return strategy_cls()
    raise RuntimeError(f"No CSP strategy found for environment: {env}")
