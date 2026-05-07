from __future__ import annotations

from collections.abc import Iterable

from app.core.exceptions import AppException
from app.db.repositories.module_repository import ModuleRepository
from app.db.schemas.module_schema import (
    ModuleCatalogItem,
    ModuleCatalogResult,
    ModuleProgress,
    ModuleStep,
)
from app.services.reward_service import RewardService


class ModuleService:
    def __init__(
        self,
        repository: ModuleRepository | None = None,
        reward_service: RewardService | None = None,
    ):
        self._repository = repository or ModuleRepository()
        self._reward_service = reward_service or RewardService()

    def list_modules(self, *, user_id: str | None = None) -> ModuleCatalogResult:
        module_rows = self._repository.list_modules()
        module_ids = [str(row["id"]) for row in module_rows]
        steps_by_module = self._repository.list_steps_by_module(module_ids)
        progress_by_module = (
            self._repository.list_progress_by_module(
                user_id=user_id,
                module_ids=module_ids,
            )
            if user_id
            else {}
        )

        modules = [
            self._module_from_row(
                row,
                steps=steps_by_module.get(str(row["id"]), []),
                progress_rows=progress_by_module.get(str(row["id"]), []),
                user_id=user_id,
            )
            for row in module_rows
        ]
        return ModuleCatalogResult(modules=modules)

    def complete_step(
        self,
        *,
        user_id: str,
        module_id: str,
        step_id: str,
    ) -> dict:
        module = self._repository.get_module(module_id)
        if module is None:
            raise AppException("Modul tidak ditemukan.", status_code=404)

        step = self._repository.get_step(module_id=module_id, step_id=step_id)
        if step is None:
            raise AppException("Step modul tidak ditemukan.", status_code=404)

        steps_by_module = self._repository.list_steps_by_module([module_id])
        progress_by_module = self._repository.list_progress_by_module(
            user_id=user_id,
            module_ids=[module_id],
        )
        current_steps = steps_by_module.get(module_id, [])
        current_progress = progress_by_module.get(module_id, [])
        total_steps = len(current_steps)
        completed_step_ids = {
            str(row["step_id"])
            for row in current_progress
            if row.get("step_id") is not None and row.get("is_completed") is True
        }
        completed_step_ids.add(step_id)
        progress_pct = ModuleProgress.calculate_progress_pct(
            completed_steps=len(completed_step_ids),
            total_steps=total_steps,
        )

        self._repository.mark_step_completed(
            user_id=user_id,
            module_id=module_id,
            step_id=step_id,
            current_step_order=int(step.get("step_order") or 0),
            progress_pct=progress_pct,
        )

        progress_by_module = self._repository.list_progress_by_module(
            user_id=user_id,
            module_ids=[module_id],
        )
        module_item = self._module_from_row(
            module,
            steps=current_steps,
            progress_rows=progress_by_module.get(module_id, []),
            user_id=user_id,
        )

        reward = {
            "points_granted": 0,
            "balance": self._reward_service.get_meowpoints_summary(
                user_id=user_id,
            )["balance"],
            "already_granted": False,
        }
        if module_item.progress.is_completed:
            reward = self._reward_service.grant_once(
                user_id=user_id,
                points=int(module.get("meowpoints_reward") or 0),
                reason=f"Modul selesai: {module.get('title')}",
                source_type="module",
                source_id=module_id,
            )

        return {
            "module": module_item.model_dump(mode="json"),
            "reward": reward,
        }

    def complete_module(self, *, user_id: str, module_id: str) -> dict:
        module = self._repository.get_module(module_id)
        if module is None:
            raise AppException("Modul tidak ditemukan.", status_code=404)

        steps_by_module = self._repository.list_steps_by_module([module_id])
        steps = steps_by_module.get(module_id, [])
        total_steps = len(steps)
        for step in steps:
            self._repository.mark_step_completed(
                user_id=user_id,
                module_id=module_id,
                step_id=str(step["id"]),
                current_step_order=int(step.get("step_order") or 0),
                progress_pct=100.0 if total_steps > 0 else 0.0,
            )

        reward = self._reward_service.grant_once(
            user_id=user_id,
            points=int(module.get("meowpoints_reward") or 0),
            reason=f"Modul selesai: {module.get('title')}",
            source_type="module",
            source_id=module_id,
        )
        return {
            "module_id": module_id,
            "is_completed": True,
            "completed_steps": total_steps,
            "reward": reward,
        }

    def _module_from_row(
        self,
        row: dict,
        *,
        steps: list[dict],
        progress_rows: Iterable[dict],
        user_id: str | None,
    ) -> ModuleCatalogItem:
        module_id = str(row["id"])
        step_models = [ModuleStep.model_validate(step) for step in steps]
        step_order_by_id = {step.id: step.step_order for step in step_models}
        progress = ModuleProgress.from_step_rows(
            module_id=module_id,
            user_id=user_id,
            total_steps=len(step_models),
            progress_rows=progress_rows,
            step_order_by_id=step_order_by_id,
        )

        payload = dict(row)
        payload["id"] = module_id
        payload["steps"] = step_models
        payload["progress"] = progress
        return ModuleCatalogItem.model_validate(payload)
