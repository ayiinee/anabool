from __future__ import annotations

from collections.abc import Iterable

from app.db.repositories.module_repository import ModuleRepository
from app.db.schemas.module_schema import (
    ModuleCatalogItem,
    ModuleCatalogResult,
    ModuleProgress,
    ModuleStep,
)


class ModuleService:
    def __init__(self, repository: ModuleRepository | None = None):
        self._repository = repository or ModuleRepository()

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
