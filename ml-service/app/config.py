import os


class Settings:
    PORT: int = int(os.getenv("PORT", "8001"))
    HOST: str = os.getenv("HOST", "0.0.0.0")
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "info")
    MIN_DATA_POINTS: int = int(os.getenv("MIN_DATA_POINTS", "7"))
    DEFAULT_FORECAST_DAYS: int = int(os.getenv("DEFAULT_FORECAST_DAYS", "30"))
    SAFETY_BUFFER_PERCENT: float = float(os.getenv("SAFETY_BUFFER_PERCENT", "0.1"))


settings = Settings()
