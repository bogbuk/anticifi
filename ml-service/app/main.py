from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers.predictions import router as predictions_router
from app.routers.categorization import router as categorization_router
from app.config import settings

app = FastAPI(
    title="AnticiFi ML Service",
    description="Prediction engine for financial forecasting",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(predictions_router, prefix="/api/predict")
app.include_router(categorization_router, prefix="/api")


@app.get("/health")
async def health_check():
    return {"status": "ok", "service": "ml-service"}
