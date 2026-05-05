from fastapi import APIRouter, HTTPException
from app.core.response import success_response
from app.db.schemas.chat_schema import SendChatMessageRequest, StartChatSessionRequest
from app.services.chat_service import (
    send_chat_message,
    start_chat_from_scan_session,
    start_consultation_chat,
)

router = APIRouter()


@router.get("/health")
def chat_health():
    return success_response("Chat routes ready")


@router.post("/from-scan/{scan_id}")
def start_chat_from_scan(scan_id: str):
    result = start_chat_from_scan_session(scan_id)
    return success_response("Chat session created from scan", result)


@router.post("/sessions")
def start_chat_session(request: StartChatSessionRequest | None = None):
    if request is not None and request.scan_id:
        result = start_chat_from_scan_session(request.scan_id)
        return success_response("Chat session created from scan", result)

    result = start_consultation_chat()
    return success_response(
        "Ask Ana consultation session created",
        result.model_dump(mode="json"),
    )


@router.post("/{session_id}/messages")
def create_chat_message(session_id: str, request: SendChatMessageRequest):
    try:
        result = send_chat_message(session_id, request.content)
    except KeyError as error:
        raise HTTPException(status_code=404, detail="Chat session not found") from error

    return success_response("Ask Ana response created", result.model_dump(mode="json"))
