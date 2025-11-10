from fastapi import FastAPI

app = FastAPI(title="Wexploria API", version="0.1.0")

@app.get("/")
def read_root():
    return {"message": "Bienvenue sur l’API Wexploria 🚀"}
