from fastapi import APIRouter, File, UploadFile
from app.core.response import success_response
from app.services.scan_service import process_scan as process_scan_service

router = APIRouter()


@router.get("/health")
def scan_health():
    return success_response("Scan routes ready")


@router.post("/process")
async def process_scan(file: UploadFile = File(...)):
    result = await process_scan_service(file)
    return success_response("Scan processed successfully", result)
