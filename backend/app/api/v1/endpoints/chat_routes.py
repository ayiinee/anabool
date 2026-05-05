from fastapi import APIRouter, Header, HTTPException
from app.core.security import authenticated_user_from_authorization
from app.core.response import success_response
from app.db.schemas.chat_schema import SendChatMessageRequest, StartChatSessionRequest
from app.services.chat_service import (
    get_chat_session,
    send_chat_message,
    start_chat_from_scan_session,
    start_consultation_chat,
)

router = APIRouter()


@router.get("/health")
def chat_health():
    return success_response("Chat routes ready")


@router.post("/from-scan/{scan_id}")
def start_chat_from_scan(scan_id: str, authorization: str | None = Header(default=None)):
    result = start_chat_from_scan_session(
        scan_id,
        user_id=_resolve_user_id(authorization, None),
    )
    return success_response("Chat session created from scan", result)


@router.post("/sessions")
def start_chat_session(
    request: StartChatSessionRequest | None = None,
    authorization: str | None = Header(default=None),
):
    user_id = _resolve_user_id(
        authorization,
        request.user_id if request is not None else None,
    )
    if request is not None and request.scan_id:
        result = start_chat_from_scan_session(
            request.scan_id,
            user_id=user_id,
            detected_class=request.detected_class,
            confidence_score=request.confidence_score,
            risk_level=request.risk_level,
            filename=request.filename,
        )
        return success_response("Chat session created from scan", result)

    result = start_consultation_chat(user_id=user_id)
    return success_response(
        "Ask Ana consultation session created",
        result.model_dump(mode="json"),
    )


@router.get("/{session_id}")
def read_chat_session(session_id: str):
    try:
        result = get_chat_session(session_id)
    except KeyError as error:
        raise HTTPException(status_code=404, detail="Chat session not found") from error

    return success_response("Chat session loaded", result.model_dump(mode="json"))


@router.post("/{session_id}/messages")
def create_chat_message(session_id: str, request: SendChatMessageRequest):
    try:
        result = send_chat_message(session_id, request.content)
    except KeyError as error:
        raise HTTPException(status_code=404, detail="Chat session not found") from error

    return success_response("Ask Ana response created", result.model_dump(mode="json"))


def _resolve_user_id(authorization: str | None, request_user_id: str | None) -> str | None:
    authenticated_user = authenticated_user_from_authorization(authorization)
    if authenticated_user is not None:
        return authenticated_user.id

    # MVP placeholder for local/mobile integration before every route sends Firebase auth.
    return request_user_id
