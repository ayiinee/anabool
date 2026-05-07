from __future__ import annotations

from typing import Any

from app.integrations.supabase.supabase_client import get_supabase_service_client


class RewardRepository:
    def __init__(self):
        self._client = get_supabase_service_client()

    def get_user_balance(self, user_id: str) -> int:
        if self._client is None:
            return 0

        response = (
            self._client.table("users")
            .select("meowpoints_balance")
            .eq("id", user_id)
            .limit(1)
            .execute()
        )
        if not response.data:
            return 0
        return int(response.data[0].get("meowpoints_balance") or 0)

    def set_user_balance(self, *, user_id: str, balance: int) -> None:
        if self._client is None:
            return

        self._client.table("users").update(
            {"meowpoints_balance": max(balance, 0)}
        ).eq("id", user_id).execute()

    def ledger_entry_exists(
        self,
        *,
        user_id: str,
        source_type: str,
        source_id: str,
    ) -> bool:
        if self._client is None:
            return False

        response = (
            self._client.table("meowpoints_ledger")
            .select("id")
            .eq("user_id", user_id)
            .eq("source_type", source_type)
            .eq("source_id", source_id)
            .limit(1)
            .execute()
        )
        return bool(response.data)

    def insert_ledger_entry(
        self,
        *,
        user_id: str,
        delta: int,
        reason: str,
        source_type: str,
        source_id: str,
    ) -> dict[str, Any]:
        if self._client is None:
            return {}

        response = (
            self._client.table("meowpoints_ledger")
            .insert(
                {
                    "user_id": user_id,
                    "delta": delta,
                    "reason": reason,
                    "source_type": source_type,
                    "source_id": source_id,
                }
            )
            .execute()
        )
        return response.data[0] if response.data else {}

    def list_ledger(self, *, user_id: str, limit: int = 20) -> list[dict[str, Any]]:
        if self._client is None:
            return []

        response = (
            self._client.table("meowpoints_ledger")
            .select("*")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(limit)
            .execute()
        )
        return response.data or []
