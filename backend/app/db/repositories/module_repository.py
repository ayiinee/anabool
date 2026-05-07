from __future__ import annotations

from collections import defaultdict
from typing import Any

from app.integrations.supabase.supabase_client import get_supabase_service_client


class ModuleRepository:
    def __init__(self):
        self._client = get_supabase_service_client()

    @property
    def is_available(self) -> bool:
        return self._client is not None

    def list_modules(self) -> list[dict[str, Any]]:
        if self._client is None:
            return []

        response = (
            self._client.table("modules")
            .select(
                "id,category,poop_type,title,summary,content_json,slug,"
                "meowpoints_reward,estimated_duration_minutes,updated_at"
            )
            .order("updated_at", desc=True)
            .execute()
        )
        return response.data or []

    def list_steps_by_module(
        self,
        module_ids: list[str],
    ) -> dict[str, list[dict[str, Any]]]:
        if self._client is None or not module_ids:
            return {}

        response = (
            self._client.table("module_steps")
            .select(
                "id,module_id,step_order,step_key,title,instruction,image_url,"
                "video_url,safety_note,meowpoints_granted"
            )
            .in_("module_id", module_ids)
            .order("step_order")
            .execute()
        )
        grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
        for row in response.data or []:
            grouped[str(row["module_id"])].append(row)
        return dict(grouped)

    def get_module(self, module_id: str) -> dict[str, Any] | None:
        if self._client is None:
            return None

        response = (
            self._client.table("modules")
            .select(
                "id,category,poop_type,title,summary,content_json,slug,"
                "meowpoints_reward,estimated_duration_minutes,updated_at"
            )
            .eq("id", module_id)
            .limit(1)
            .execute()
        )
        return response.data[0] if response.data else None

    def get_step(self, *, module_id: str, step_id: str) -> dict[str, Any] | None:
        if self._client is None:
            return None

        response = (
            self._client.table("module_steps")
            .select("*")
            .eq("id", step_id)
            .eq("module_id", module_id)
            .limit(1)
            .execute()
        )
        return response.data[0] if response.data else None

    def mark_step_completed(
        self,
        *,
        user_id: str,
        module_id: str,
        step_id: str,
        current_step_order: int,
        progress_pct: float,
    ) -> dict[str, Any]:
        if self._client is None:
            return {}

        payload = {
            "user_id": user_id,
            "module_id": module_id,
            "step_id": step_id,
            "current_step_order": current_step_order,
            "progress_pct": progress_pct,
            "is_completed": True,
        }
        response = (
            self._client.table("user_module_progress")
            .upsert(payload, on_conflict="user_id,module_id,step_id")
            .execute()
        )
        return response.data[0] if response.data else payload

    def list_progress_by_module(
        self,
        *,
        user_id: str,
        module_ids: list[str],
    ) -> dict[str, list[dict[str, Any]]]:
        if self._client is None or not user_id or not module_ids:
            return {}

        response = (
            self._client.table("user_module_progress")
            .select("*")
            .eq("user_id", user_id)
            .in_("module_id", module_ids)
            .execute()
        )
        grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
        for row in response.data or []:
            grouped[str(row["module_id"])].append(row)
        return dict(grouped)
