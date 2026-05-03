from fastapi import APIRouter
from app.core.response import success_response

router = APIRouter()


@router.get("/health")
def notification_health():
    return success_response("Notification routes ready")