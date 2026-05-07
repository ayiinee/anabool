from __future__ import annotations

from app.db.repositories.reward_repository import RewardRepository


class RewardService:
    def __init__(self, repository: RewardRepository | None = None):
        self._repository = repository or RewardRepository()

    def get_meowpoints_summary(self, *, user_id: str) -> dict:
        return {
            "balance": self._repository.get_user_balance(user_id),
            "ledger": self._repository.list_ledger(user_id=user_id),
        }

    def grant_once(
        self,
        *,
        user_id: str,
        points: int,
        reason: str,
        source_type: str,
        source_id: str,
    ) -> dict:
        normalized_points = max(points, 0)
        current_balance = self._repository.get_user_balance(user_id)

        if normalized_points == 0:
            return {
                "points_granted": 0,
                "balance": current_balance,
                "already_granted": False,
            }

        if self._repository.ledger_entry_exists(
            user_id=user_id,
            source_type=source_type,
            source_id=source_id,
        ):
            return {
                "points_granted": 0,
                "balance": current_balance,
                "already_granted": True,
            }

        next_balance = current_balance + normalized_points
        self._repository.insert_ledger_entry(
            user_id=user_id,
            delta=normalized_points,
            reason=reason,
            source_type=source_type,
            source_id=source_id,
        )
        self._repository.set_user_balance(user_id=user_id, balance=next_balance)

        return {
            "points_granted": normalized_points,
            "balance": next_balance,
            "already_granted": False,
        }
