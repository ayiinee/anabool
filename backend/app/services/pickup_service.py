from __future__ import annotations

from app.core.exceptions import AppException
from app.db.repositories.pickup_repository import PickupRepository
from app.db.schemas.pickup_schema import PickupOrderCreateRequest
from app.services.reward_service import RewardService
from app.utils.points_utils import calculate_pickup_points


class PickupService:
    def __init__(
        self,
        repository: PickupRepository | None = None,
        reward_service: RewardService | None = None,
    ):
        self._repository = repository or PickupRepository()
        self._reward_service = reward_service or RewardService()

    def list_packages(self, *, pickup_type: str | None = None) -> dict:
        return {
            "items": self._repository.list_packages(pickup_type=pickup_type),
        }

    def create_order(
        self,
        *,
        user_id: str,
        request: PickupOrderCreateRequest,
    ) -> dict:
        if not self._repository.package_exists(request.package_id):
            raise AppException("Paket pickup tidak ditemukan.", status_code=404)

        payload = request.model_dump(exclude={"user_id"}, by_alias=False)
        payload["user_id"] = user_id
        payload["status"] = "pending"
        return self._repository.create_order(payload=payload)

    def get_order(self, *, order_id: str) -> dict:
        order = self._repository.get_order(order_id)
        if order is None:
            raise AppException("Pesanan pickup tidak ditemukan.", status_code=404)
        return order

    def update_order_status(
        self,
        *,
        order_id: str,
        status: str,
        note: str | None = None,
    ) -> dict:
        order = self._repository.update_order_status(order_id, status, note)
        if not order:
            raise AppException("Pesanan pickup tidak ditemukan.", status_code=404)

        reward = {
            "points_granted": 0,
            "balance": self._reward_service.get_meowpoints_summary(
                user_id=str(order["user_id"]),
            )["balance"],
            "already_granted": False,
        }
        if status == "completed" and order.get("pickup_type") == "pupuk":
            points = calculate_pickup_points(order.get("actual_weight_g"))
            reward = self._reward_service.grant_once(
                user_id=str(order["user_id"]),
                points=points,
                reason="Pick up pupuk selesai",
                source_type="pickup_order",
                source_id=order_id,
            )
            if reward["points_granted"] > 0:
                self._repository.set_order_meowpoints(
                    order_id=order_id,
                    points=reward["points_granted"],
                )
                order["meowpoints_earned"] = reward["points_granted"]

        order["reward"] = reward
        return order
