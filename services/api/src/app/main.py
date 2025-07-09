from fastapi import FastAPI
from app.api.app import create_app

app: FastAPI = create_app()

@app.get("/")
def ping() -> dict[str, str]:
    return {"ping": "pong"}
