from fastapi import APIRouter, Header, Query

from app.core.exceptions import AppException
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


@router.post("/{module_id}/steps/{step_id}/complete")
def complete_module_step(
    module_id: str,
    step_id: str,
    authorization: str | None = Header(default=None),
):
    authenticated_user = authenticated_user_from_authorization(authorization)
    if authenticated_user is None:
        raise AppException("Login dibutuhkan untuk menyimpan progres modul.", status_code=401)

    result = _service.complete_step(
        user_id=authenticated_user.id,
        module_id=module_id,
        step_id=step_id,
    )
    return success_response("Step modul selesai", result)


@router.post("/{module_id}/complete")
def complete_module(
    module_id: str,
    authorization: str | None = Header(default=None),
):
    authenticated_user = authenticated_user_from_authorization(authorization)
    if authenticated_user is None:
        raise AppException("Login dibutuhkan untuk menyelesaikan modul.", status_code=401)

    result = _service.complete_module(
        user_id=authenticated_user.id,
        module_id=module_id,
    )
    return success_response("Modul selesai", result)
