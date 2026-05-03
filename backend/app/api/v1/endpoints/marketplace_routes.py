from fastapi import APIRouter
from app.core.response import success_response

router = APIRouter()


@router.get("/health")
def marketplace_health():
    return success_response("Marketplace routes ready")