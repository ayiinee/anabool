from fastapi import UploadFile
from uuid import uuid4

from app.ai.cv.cnn_inference import predict_waste_class


async def process_scan(file: UploadFile) -> dict:
    prediction = await predict_waste_class(file)
    detected_class = prediction["detected_class"]
    confidence_score = prediction["confidence_score"]

    return {
        "scan_id": _new_scan_id(),
        "filename": file.filename,
        "scan_status": "detected" if detected_class != "unknown" else "needs_review",
        "detected_class": detected_class,
        "confidence_score": confidence_score,
        "risk_level": prediction["risk_level"],
        "default_action": prediction["default_action"],
        "detected_visual_signs": prediction["detected_visual_signs"],
        "photo_quality": prediction["photo_quality"],
        "raw_detected_label": prediction["raw_detected_label"],
        "message": _build_scan_message(detected_class, confidence_score),
        "next_action_cards": build_next_action_cards(prediction["default_action"]),
        "image_info": prediction["image_info"],
        "model": {
            "provider": "roboflow",
            "raw_response": prediction["roboflow"],
        },
    }


async def mock_process_scan(file: UploadFile) -> dict:
    return {
        "scan_id": _new_scan_id(),
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


def _build_scan_message(detected_class: str, confidence_score: float) -> str:
    confidence_percent = round(confidence_score * 100)
    readable_class = detected_class.replace("_", " ")

    if detected_class == "unknown":
        return "Model belum bisa mengklasifikasikan gambar dengan yakin. Coba ambil foto lebih jelas."

    return f"Model mendeteksi kondisi {readable_class} dengan confidence {confidence_percent}%."


def build_next_action_cards(default_action: str) -> list[dict]:
    cards = [
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
        {
            "card_type": "education",
            "title": "Edukasi",
            "description": "Pelajari tanda kondisi feses dan langkah perawatan.",
            "cta_label": "Buka Edukasi",
            "target_route": "/modules",
        },
    ]

    return sorted(cards, key=lambda card: card["card_type"] != default_action)


def _new_scan_id() -> str:
    return f"scan_{uuid4().hex}"
