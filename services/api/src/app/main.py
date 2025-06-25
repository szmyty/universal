from app.api.app import create_app

app = create_app()

@app.get("/")
def ping():
    return {"ping": "pong"}
