import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.services.pickup_service import PickupService
from app.services.reward_service import RewardService


def test_grant_once_starts_from_zero_and_prevents_duplicate_source():
    repository = FakeRewardRepository()
    service = RewardService(repository)

    first = service.grant_once(
        user_id="user-1",
        points=25,
        reason="Modul selesai",
        source_type="module",
        source_id="module-1",
    )
    second = service.grant_once(
        user_id="user-1",
        points=25,
        reason="Modul selesai",
        source_type="module",
        source_id="module-1",
    )

    assert first["points_granted"] == 25
    assert first["balance"] == 25
    assert second["points_granted"] == 0
    assert second["balance"] == 25
    assert second["already_granted"] is True


def test_completed_pupuk_pickup_grants_points():
    reward_repository = FakeRewardRepository()
    pickup_repository = FakePickupRepository(
        {
            "id": "pickup-1",
            "user_id": "user-1",
            "pickup_type": "pupuk",
            "actual_weight_g": None,
            "meowpoints_earned": 0,
            "package": {"meowpoints_bonus": 3000},
        }
    )
    service = PickupService(
        pickup_repository,
        RewardService(reward_repository),
    )

    order = service.update_order_status(order_id="pickup-1", status="completed")

    assert order["reward"]["points_granted"] == 3000
    assert order["reward"]["balance"] == 3000
    assert order["meowpoints_earned"] == 3000


def test_completed_non_pupuk_pickup_does_not_grant_points():
    reward_repository = FakeRewardRepository()
    pickup_repository = FakePickupRepository(
        {
            "id": "pickup-2",
            "user_id": "user-1",
            "pickup_type": "kotoran",
            "actual_weight_g": None,
            "meowpoints_earned": 0,
        }
    )
    service = PickupService(
        pickup_repository,
        RewardService(reward_repository),
    )

    order = service.update_order_status(order_id="pickup-2", status="completed")

    assert order["reward"]["points_granted"] == 0
    assert order["reward"]["balance"] == 0
    assert order["meowpoints_earned"] == 0


class FakeRewardRepository:
    def __init__(self):
        self.balance = 0
        self.ledger = []

    def get_user_balance(self, user_id):
        return self.balance

    def set_user_balance(self, *, user_id, balance):
        self.balance = balance

    def ledger_entry_exists(self, *, user_id, source_type, source_id):
        return any(
            row["user_id"] == user_id
            and row["source_type"] == source_type
            and row["source_id"] == source_id
            for row in self.ledger
        )

    def insert_ledger_entry(self, *, user_id, delta, reason, source_type, source_id):
        row = {
            "user_id": user_id,
            "delta": delta,
            "reason": reason,
            "source_type": source_type,
            "source_id": source_id,
        }
        self.ledger.append(row)
        return row

    def list_ledger(self, *, user_id, limit=20):
        return self.ledger[:limit]


class FakePickupRepository:
    def __init__(self, order):
        self.order = dict(order)

    def list_packages(self, *, pickup_type=None):
        return []

    def package_exists(self, package_id):
        return True

    def create_order(self, *, payload):
        return payload

    def get_order(self, order_id):
        return self.order if self.order["id"] == order_id else None

    def update_order_status(self, order_id, status, note=None):
        if self.order["id"] != order_id:
            return {}
        self.order["status"] = status
        return self.order

    def set_order_meowpoints(self, *, order_id, points):
        if self.order["id"] == order_id:
            self.order["meowpoints_earned"] = points
