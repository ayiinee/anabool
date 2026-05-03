from fastapi import APIRouter
from app.core.response import success_response
from app.services.chat_service import mock_start_chat_from_scan

router = APIRouter()


@router.get("/health")
def chat_health():
    return success_response("Chat routes ready")


@router.post("/from-scan/{scan_id}")
def start_chat_from_scan(scan_id: str):
    result = mock_start_chat_from_scan(scan_id)
    return success_response("Chat session created from scan", result)