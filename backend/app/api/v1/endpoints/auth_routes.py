from fastapi import APIRouter
from app.core.response import success_response

router = APIRouter()


@router.get("/health")
def auth_health():
    return success_response("Auth routes ready")