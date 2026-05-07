from __future__ import annotations

from collections.abc import Iterable
from datetime import datetime

from pydantic import BaseModel, Field


class ModuleStep(BaseModel):
    id: str
    module_id: str
    step_order: int
    step_key: str | None = None
    title: str
    instruction: str | None = None
    image_url: str | None = None
    video_url: str | None = None
    safety_note: str | None = None
    meowpoints_granted: int = 0


class ModuleProgress(BaseModel):
    module_id: str
    user_id: str | None = None
    current_step_order: int = 0
    total_steps: int = 0
    completed_steps: int = 0
    progress_pct: float = 0.0
    is_completed: bool = False
    completed_at: datetime | None = None

    @classmethod
    def from_step_rows(
        cls,
        *,
        module_id: str,
        total_steps: int,
        progress_rows: Iterable[dict],
        step_order_by_id: dict[str, int] | None = None,
        user_id: str | None = None,
    ) -> "ModuleProgress":
        normalized_total_steps = max(total_steps, 0)
        completed_step_ids = {
            str(row["step_id"])
            for row in progress_rows
            if row.get("step_id") is not None and row.get("is_completed") is True
        }
        completed_steps = len(completed_step_ids)
        progress_pct = cls.calculate_progress_pct(
            completed_steps=completed_steps,
            total_steps=normalized_total_steps,
        )
        current_step_order = cls.resolve_current_step_order(
            completed_step_ids=completed_step_ids,
            total_steps=normalized_total_steps,
            step_order_by_id=step_order_by_id or {},
        )

        return cls(
            module_id=module_id,
            user_id=user_id,
            current_step_order=current_step_order,
            total_steps=normalized_total_steps,
            completed_steps=completed_steps,
            progress_pct=progress_pct,
            is_completed=normalized_total_steps > 0
            and completed_steps >= normalized_total_steps,
        )

    @staticmethod
    def calculate_progress_pct(*, completed_steps: int, total_steps: int) -> float:
        if total_steps <= 0:
            return 0.0

        bounded_completed = min(max(completed_steps, 0), total_steps)
        return float((bounded_completed / total_steps) * 100)

    @staticmethod
    def resolve_current_step_order(
        *,
        completed_step_ids: set[str],
        total_steps: int,
        step_order_by_id: dict[str, int],
    ) -> int:
        if total_steps <= 0:
            return 0
        if not completed_step_ids:
            return 1

        completed_orders = [
            step_order_by_id[step_id]
            for step_id in completed_step_ids
            if step_id in step_order_by_id
        ]
        if not completed_orders:
            return 1

        next_order = max(completed_orders) + 1
        return min(next_order, total_steps)


class ModuleCatalogItem(BaseModel):
    id: str
    category: str
    poop_type: str | None = None
    title: str
    summary: str
    content_json: dict = Field(default_factory=dict)
    slug: str
    meowpoints_reward: int = 0
    estimated_duration_minutes: int = 0
    updated_at: datetime | None = None
    steps: list[ModuleStep] = Field(default_factory=list)
    progress: ModuleProgress


class ModuleCatalogResult(BaseModel):
    modules: list[ModuleCatalogItem]
