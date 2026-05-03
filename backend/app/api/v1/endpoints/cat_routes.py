from fastapi import APIRouter
from app.core.response import success_response

router = APIRouter()


@router.get("/health")
def cat_health():
    return success_response("Cat routes ready")