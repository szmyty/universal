import uvicorn
from .logging import setup_logging

if __name__ == "__main__":
    setup_logging()
    uvicorn.run(
        "services.api.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_config=None,
    )
