from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_NAME: str = "ANABOOL"
    APP_ENV: str = "development"
    APP_DEBUG: bool = True

    API_V1_PREFIX: str = "/api/v1"

    BACKEND_HOST: str = "0.0.0.0"
    BACKEND_PORT: int = 8000

    FRONTEND_ORIGIN: str = "http://localhost:3000"

    SUPABASE_URL: str = ""
    SUPABASE_ANON_KEY: str = ""
    SUPABASE_SERVICE_ROLE_KEY: str = ""
    SUPABASE_PASSWORD: str = ""

    DATABASE_URL: str = ""

    FIREBASE_PROJECT_ID: str = ""
    FIREBASE_CLIENT_EMAIL: str = ""
    FIREBASE_PRIVATE_KEY: str = ""

    GROQ_API_KEY: str = ""
    GROQ_CHAT_MODEL: str = "meta-llama/llama-4-scout-17b-16e-instruct"

    EMBEDDING_PROVIDER: str = "hash"
    EMBEDDING_MODEL_NAME: str = "intfloat/multilingual-e5-small"
    EMBEDDING_DIMENSION: int = 384
    EMBEDDING_CACHE_DIR: str = ".cache/huggingface"

    OSRM_BASE_URL: str = "https://router.project-osrm.org"

    CNN_MODEL_PATH: str = "../ai-model/cnn/models/anabool_cnn_model.h5"
    CNN_CONFIDENCE_THRESHOLD: float = 0.70

    ROBOFLOW_API_URL: str = "https://serverless.roboflow.com"
    ROBOFLOW_API_KEY: str = ""
    ROBOFLOW_MODEL_ID: str = "pet-poop-classifier/1"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
