from fastapi import APIRouter, Header, Query

from app.core.exceptions import AppException
from app.core.response import success_response
from app.core.security import authenticated_user_from_authorization
from app.db.schemas.pickup_schema import PickupOrderCreateRequest
from app.services.pickup_service import PickupService

router = APIRouter()
_service = PickupService()


@router.get("/health")
def pickup_health():
    return success_response("Pickup routes ready")


@router.get("/packages")
def list_packages(pickup_type: str | None = Query(default=None)):
    return success_response(
        "Pickup packages loaded",
        _service.list_packages(pickup_type=pickup_type),
    )


@router.post("/orders")
def create_order(
    request: PickupOrderCreateRequest,
    authorization: str | None = Header(default=None),
):
    authenticated_user = authenticated_user_from_authorization(authorization)
    user_id = authenticated_user.id if authenticated_user is not None else request.user_id
    if user_id is None:
        raise AppException("Login dibutuhkan untuk membuat pesanan pickup.", status_code=401)

    order = _service.create_order(user_id=user_id, request=request)
    return success_response("Pesanan pickup dibuat", order)


@router.get("/orders/{order_id}")
def get_order(order_id: str):
    return success_response("Pesanan pickup dimuat", _service.get_order(order_id=order_id))


@router.patch("/orders/{order_id}/status")
def update_order_status(
    order_id: str,
    status: str,
    note: str | None = None,
):
    order = _service.update_order_status(order_id=order_id, status=status, note=note)
    return success_response("Status pickup diperbarui", order)
