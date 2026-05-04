from fastapi import APIRouter, File, UploadFile
from app.core.response import success_response
from app.services.scan_service import mock_process_scan

router = APIRouter()


@router.get("/health")
def litter_box_health():
    return success_response("Litter box routes ready")


@router.post("/process")
async def process_scan(file: UploadFile = File(...)):
    result = await mock_process_scan(file)
    return success_response("Scan processed successfully", result)
