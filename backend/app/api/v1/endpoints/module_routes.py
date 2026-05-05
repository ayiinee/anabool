from fastapi import APIRouter

from app.core.response import success_response
from app.services import module_service

router = APIRouter()


@router.get("/health")
def module_health():
    return success_response("Module routes ready")


@router.get("")
def list_modules():
    return success_response(
        "Daftar modul berhasil diambil.",
        module_service.get_module_catalog(),
    )


@router.get("/{module_id}")
def get_module(module_id: str):
    return success_response(
        "Detail modul berhasil diambil.",
        module_service.get_module_detail(module_id),
    )


@router.post("/{module_id}/complete")
def complete_module(module_id: str):
    return success_response(
        "Modul berhasil diselesaikan.",
        module_service.complete_module(module_id),
    )
