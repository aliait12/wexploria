from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import (
    activites_router,
    admin_router,
    auth_router,
    avis_router,
    payments_router,
    reservations_router,
    weather_router,
    ai_router
)

app = FastAPI(
    title="Wexploria API 🚀",
    description="Backend API pour la plateforme d'activités outdoor Wexploria",
    version="1.0.0"
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclusion des routers
app.include_router(auth_router.router)
app.include_router(admin_router.router)
app.include_router(activites_router.router)
app.include_router(reservations_router.router)
app.include_router(payments_router.router)
app.include_router(avis_router.router)
app.include_router(weather_router.router)
app.include_router(ai_router.router)

@app.get("/")
async def root():
    return {
        "message": "Bienvenue sur l’API Wexploria 🚀",
        "status": "online",
        "docs": "/docs"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
