from fastapi import UploadFile


async def mock_process_scan(file: UploadFile) -> dict:
    return {
        "filename": file.filename,
        "scan_status": "detected",
        "detected_class": "soft_poop",
        "confidence_score": 0.91,
        "risk_level": "medium",
        "message": "Mock CNN berhasil mendeteksi kondisi feses/litter.",
        "next_action_cards": [
            {
                "card_type": "pickup",
                "title": "Pick Up",
                "description": "Jadwalkan penjemputan limbah kucing.",
                "cta_label": "Jadwalkan Pick-up",
                "target_route": "/pickup/map",
            },
            {
                "card_type": "process",
                "title": "Olah",
                "description": "Lihat cara mengolah limbah dengan aman.",
                "cta_label": "Lihat Cara Olah",
                "target_route": "/modules/process",
            },
            {
                "card_type": "dispose",
                "title": "Buang",
                "description": "Lihat panduan pembuangan yang benar.",
                "cta_label": "Lihat Cara Buang",
                "target_route": "/modules/dispose",
            },
        ],
    }