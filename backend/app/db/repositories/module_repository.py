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
