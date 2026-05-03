from fastapi import APIRouter
from app.core.response import success_response

router = APIRouter()


@router.get("/health")
def education_health():
    return success_response("Education routes ready")