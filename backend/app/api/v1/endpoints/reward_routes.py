from fastapi import APIRouter
from app.core.response import success_response

router = APIRouter()


@router.get("/health")
def reward_health():
    return success_response("Reward routes ready")