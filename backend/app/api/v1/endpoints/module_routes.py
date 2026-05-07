from fastapi import APIRouter, Header, Query

from app.core.response import success_response
from app.core.security import authenticated_user_from_authorization
from app.services.module_service import ModuleService

router = APIRouter()
_service = ModuleService()


@router.get("/health")
def education_health():
    return success_response("Education routes ready")


@router.get("")
def list_modules(
    authorization: str | None = Header(default=None),
    user_id: str | None = Query(default=None),
):
    authenticated_user = authenticated_user_from_authorization(authorization)
    result = _service.list_modules(
        user_id=authenticated_user.id if authenticated_user is not None else user_id,
    )
    return success_response(
        "Modules loaded",
        result.model_dump(mode="json"),
    )
