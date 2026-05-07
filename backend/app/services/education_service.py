from __future__ import annotations

from app.db.schemas.module_schema import ModuleCatalogResult
from app.services.module_service import ModuleService


class EducationService:
    def __init__(self, module_service: ModuleService | None = None):
        self._module_service = module_service or ModuleService()

    def list_education_modules(self, *, user_id: str | None = None) -> ModuleCatalogResult:
        return self._module_service.list_modules(user_id=user_id)
