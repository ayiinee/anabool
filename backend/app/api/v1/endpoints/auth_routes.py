from fastapi import APIRouter
from app.core.response import success_response
from app.db.schemas.user_schema import AuthSyncRequest
from app.services.auth_service import sync_user

router = APIRouter()


@router.get("/health")
def auth_health():
    return success_response("Auth routes ready")


@router.post("/sync-user")
def sync_authenticated_user(payload: AuthSyncRequest):
    result = sync_user(
        id_token=payload.id_token,
        mode=payload.mode,
        display_name=payload.display_name,
        photo_url=payload.photo_url,
    )
    return success_response(
        "User berhasil disinkronkan.",
        result.model_dump(),
    )
