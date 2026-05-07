from fastapi import APIRouter, Header, Query

from app.core.response import success_response
from app.core.security import authenticated_user_from_authorization
from app.services.education_service import EducationService

router = APIRouter()
_service = EducationService()


@router.get("/health")
def education_health():
    return success_response("Education routes ready")


@router.get("")
def list_education(
    authorization: str | None = Header(default=None),
    user_id: str | None = Query(default=None),
):
    authenticated_user = authenticated_user_from_authorization(authorization)
    result = _service.list_education_modules(
        user_id=authenticated_user.id if authenticated_user is not None else user_id,
    )
    return success_response(
        "Education modules loaded",
        result.model_dump(mode="json"),
    )
