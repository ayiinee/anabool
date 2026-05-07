from __future__ import annotations

from typing import Any

from app.integrations.supabase.supabase_client import get_supabase_service_client


class PickupRepository:
    def __init__(self):
        self._client = get_supabase_service_client()

    @property
    def is_available(self) -> bool:
        return self._client is not None

    # ── Packages ──────────────────────────────────────────────────────────

    def list_packages(
        self,
        *,
        pickup_type: str | None = None,
        active_only: bool = True,
    ) -> list[dict]:
        if self._client is None:
            return []

        query = self._client.table("pickup_packages").select("*")
        if active_only:
            query = query.eq("is_active", True)
        if pickup_type:
            query = query.eq("pickup_type", pickup_type)

        response = query.order("price_idr").execute()
        return response.data or []

    def package_exists(self, package_id: str) -> bool:
        if self._client is None:
            return False

        response = (
            self._client.table("pickup_packages")
            .select("id")
            .eq("id", package_id)
            .eq("is_active", True)
            .limit(1)
            .execute()
        )
        return bool(response.data)

    # ── Orders ────────────────────────────────────────────────────────────

    def create_order(self, *, payload: dict) -> dict:
        if self._client is None:
            raise RuntimeError("Supabase client is not configured.")

        response = self._client.table("pickup_orders").insert(payload).execute()
        order = response.data[0]

        # Create initial status log
        self._client.table("pickup_status_logs").insert({
            "pickup_order_id": order["id"],
            "status": "pending",
            "note": "Pesanan dibuat",
        }).execute()

        return order

    def get_order(self, order_id: str) -> dict | None:
        if self._client is None:
            return None

        response = (
            self._client.table("pickup_orders")
            .select("*")
            .eq("id", order_id)
            .limit(1)
            .execute()
        )
        if not response.data:
            return None

        order = response.data[0]
        order["status_logs"] = self._fetch_status_logs(order_id)
        order["package"] = self._fetch_package(order.get("package_id"))
        order["courier"] = self._fetch_courier(order.get("courier_id"))
        return order

    def list_orders_by_user(self, user_id: str, *, limit: int = 20) -> list[dict]:
        if self._client is None:
            return []

        response = (
            self._client.table("pickup_orders")
            .select("*")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(limit)
            .execute()
        )
        orders = response.data or []
        for order in orders:
            order["package"] = self._fetch_package(order.get("package_id"))
        return orders

    def update_order_status(self, order_id: str, status: str, note: str | None = None) -> dict:
        if self._client is None:
            raise RuntimeError("Supabase client is not configured.")

        self._client.table("pickup_orders").update({"status": status}).eq(
            "id", order_id
        ).execute()

        self._client.table("pickup_status_logs").insert({
            "pickup_order_id": order_id,
            "status": status,
            "note": note,
        }).execute()

        return self.get_order(order_id) or {}

    def set_order_meowpoints(self, *, order_id: str, points: int) -> None:
        if self._client is None:
            return

        self._client.table("pickup_orders").update(
            {"meowpoints_earned": max(points, 0)}
        ).eq("id", order_id).execute()

    # ── Couriers ──────────────────────────────────────────────────────────

    def list_available_couriers(self) -> list[dict]:
        if self._client is None:
            return []

        response = (
            self._client.table("couriers")
            .select("*")
            .eq("is_available", True)
            .execute()
        )
        couriers = response.data or []

        user_ids = {str(c["user_id"]) for c in couriers if c.get("user_id")}
        users_by_id = self._fetch_users(user_ids)
        for courier in couriers:
            user = users_by_id.get(str(courier.get("user_id")), {})
            courier["display_name"] = user.get("display_name")
            courier["avatar_url"] = user.get("avatar_url")
        return couriers

    # ── Helpers ────────────────────────────────────────────────────────────

    def _fetch_status_logs(self, order_id: str) -> list[dict]:
        if self._client is None:
            return []

        response = (
            self._client.table("pickup_status_logs")
            .select("*")
            .eq("pickup_order_id", order_id)
            .order("created_at")
            .execute()
        )
        return response.data or []

    def _fetch_package(self, package_id: str | None) -> dict | None:
        if self._client is None or not package_id:
            return None

        response = (
            self._client.table("pickup_packages")
            .select("*")
            .eq("id", package_id)
            .limit(1)
            .execute()
        )
        return response.data[0] if response.data else None

    def _fetch_courier(self, courier_id: str | None) -> dict | None:
        if self._client is None or not courier_id:
            return None

        response = (
            self._client.table("couriers")
            .select("*")
            .eq("id", courier_id)
            .limit(1)
            .execute()
        )
        if not response.data:
            return None

        courier = response.data[0]
        users = self._fetch_users({str(courier.get("user_id", ""))})
        user = users.get(str(courier.get("user_id")), {})
        courier["display_name"] = user.get("display_name")
        courier["avatar_url"] = user.get("avatar_url")
        return courier

    def _fetch_users(self, user_ids: set[str]) -> dict[str, dict]:
        if self._client is None or not user_ids:
            return {}

        response = (
            self._client.table("users")
            .select("id,display_name,avatar_url,phone_number")
            .in_("id", list(user_ids))
            .execute()
        )
        return {str(row["id"]): row for row in response.data or []}
