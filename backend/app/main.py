from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.core.config import settings
from app.core.exceptions import register_exception_handlers


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.APP_NAME,
        debug=settings.APP_DEBUG,
        version="0.1.0",
        description="ANABOOL Backend API - FastAPI service for CV scan, chatbot Ana, pickup, marketplace, rewards, and impact.",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    register_exception_handlers(app)

    app.include_router(api_router, prefix=settings.API_V1_PREFIX)

    @app.get("/")
    def root():
        return {
            "success": True,
            "message": "ANABOOL Backend is running",
            "data": {
                "app": settings.APP_NAME,
                "env": settings.APP_ENV,
                "docs": "/docs",
                "api_prefix": settings.API_V1_PREFIX,
            },
        }

    @app.get("/health")
    def health_check():
        return {
            "success": True,
            "message": "Service healthy",
            "data": None,
        }

    return app


app = create_app()