from fastapi import APIRouter, Header

from app.core.exceptions import AppException
from app.core.response import success_response
from app.core.security import authenticated_user_from_authorization
from app.services.reward_service import RewardService

router = APIRouter()
_service = RewardService()


@router.get("/health")
def reward_health():
    return success_response("Reward routes ready")


@router.get("/meowpoints")
def get_meowpoints(authorization: str | None = Header(default=None)):
    authenticated_user = authenticated_user_from_authorization(authorization)
    if authenticated_user is None:
        raise AppException("Login dibutuhkan untuk melihat MeowPoints.", status_code=401)

    return success_response(
        "MeowPoints loaded",
        _service.get_meowpoints_summary(user_id=authenticated_user.id),
    )
