from fastapi import APIRouter
from app.core.response import success_response

router = APIRouter()


@router.get("/health")
def module_health():
    return success_response("Module routes ready")