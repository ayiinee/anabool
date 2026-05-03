from fastapi import APIRouter
from app.core.response import success_response

router = APIRouter()


@router.get("/health")
def litter_box_health():
    return success_response("Litter box routes ready")