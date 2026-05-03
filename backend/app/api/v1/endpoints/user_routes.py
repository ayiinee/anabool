from fastapi import APIRouter
from app.core.response import success_response

router = APIRouter()


@router.get("/health")
def user_health():
    return success_response("User routes ready")