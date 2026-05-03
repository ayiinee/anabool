from fastapi import APIRouter
from app.core.response import success_response

router = APIRouter()


@router.get("/health")
def impact_health():
    return success_response("Impact routes ready")