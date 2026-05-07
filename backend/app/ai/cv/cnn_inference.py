import os
import tempfile
from typing import Any

from fastapi import UploadFile
import httpx

from app.ai.cv.label_mapper import map_detected_class
from app.core.config import settings
from app.core.exceptions import AppException


async def predict_waste_class(file: UploadFile) -> dict:
    image_bytes = await file.read()
    if not image_bytes:
        raise AppException("Uploaded scan image is empty.", status_code=400)

    image_info = {
        "filename": file.filename,
        "content_type": file.content_type,
        "size_bytes": len(image_bytes),
    }

    temp_path = _write_temp_image(image_bytes, file.filename)
    try:
        roboflow_result = await _infer_with_roboflow_http(
            temp_path,
            filename=file.filename,
            content_type=file.content_type,
        )
    except AppException:
        raise
    except Exception as exc:
        raise AppException(
            f"Computer vision inference failed: {exc}",
            status_code=502,
        ) from exc
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)

    detected_label, confidence_score = _extract_prediction(roboflow_result)
    raw_detected_label = detected_label
    if confidence_score < settings.CNN_CONFIDENCE_THRESHOLD:
        detected_label = "unknown"

    mapped_result = map_detected_class(detected_label)

    return {
        **mapped_result,
        "confidence_score": confidence_score,
        "detected_visual_signs": _build_visual_signs(mapped_result["detected_class"]),
        "photo_quality": "uploaded",
        "image_info": image_info,
        "raw_detected_label": raw_detected_label,
        "roboflow": roboflow_result,
    }


async def _infer_with_roboflow_http(
    image_path: str,
    *,
    filename: str | None,
    content_type: str | None,
) -> dict[str, Any]:
    if not settings.ROBOFLOW_API_KEY:
        raise AppException("Roboflow API key is not configured.", status_code=503)

    base_url = settings.ROBOFLOW_API_URL.rstrip("/")
    model_id = settings.ROBOFLOW_MODEL_ID.strip("/")
    url = f"{base_url}/{model_id}"

    with open(image_path, "rb") as image_file:
        files = {
            "file": (
                filename or "scan.jpg",
                image_file,
                content_type or "image/jpeg",
            )
        }
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                url,
                params={"api_key": settings.ROBOFLOW_API_KEY},
                files=files,
            )

    if response.status_code >= 400:
        raise AppException(
            f"Roboflow inference failed with status {response.status_code}.",
            status_code=502,
        )

    return response.json()


def _write_temp_image(image_bytes: bytes, filename: str | None) -> str:
    _, extension = os.path.splitext(filename or "")
    suffix = extension if extension else ".jpg"

    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
        temp_file.write(image_bytes)
        return temp_file.name


def _extract_prediction(result: Any) -> tuple[str, float]:
    predictions = result.get("predictions") if isinstance(result, dict) else None

    if isinstance(predictions, list):
        best_prediction = _best_list_prediction(predictions)
        if best_prediction is not None:
            return _read_label(best_prediction), _read_confidence(best_prediction)

    if isinstance(predictions, dict):
        best_prediction = _best_dict_prediction(predictions)
        if best_prediction is not None:
            return _read_label(best_prediction), _read_confidence(best_prediction)

    if isinstance(result, dict):
        return _read_label(result), _read_confidence(result)

    return "unknown", 0.0


def _best_list_prediction(predictions: list[Any]) -> dict[str, Any] | None:
    prediction_dicts = [
        prediction for prediction in predictions if isinstance(prediction, dict)
    ]
    if not prediction_dicts:
        return None

    return max(prediction_dicts, key=_read_confidence)


def _best_dict_prediction(predictions: dict[str, Any]) -> dict[str, Any] | None:
    normalized_predictions: list[dict[str, Any]] = []
    for label, value in predictions.items():
        if isinstance(value, dict):
            normalized_predictions.append({"class": label, **value})
        elif isinstance(value, (int, float)):
            normalized_predictions.append({"class": label, "confidence": value})

    if not normalized_predictions:
        return None

    return max(normalized_predictions, key=_read_confidence)


def _read_label(prediction: dict[str, Any]) -> str:
    for key in ("class", "label", "predicted_class", "top"):
        value = prediction.get(key)
        if isinstance(value, str) and value.strip():
            return value

    predicted_classes = prediction.get("predicted_classes")
    if isinstance(predicted_classes, list) and predicted_classes:
        return str(predicted_classes[0])

    return "unknown"


def _read_confidence(prediction: dict[str, Any]) -> float:
    for key in ("confidence", "score", "probability"):
        value = prediction.get(key)
        if isinstance(value, (int, float)):
            return _normalize_confidence(float(value))
        if isinstance(value, str):
            try:
                return _normalize_confidence(float(value))
            except ValueError:
                continue

    return 0.0


def _normalize_confidence(value: float) -> float:
    if value > 1:
        value = value / 100

    return max(0.0, min(value, 1.0))


def _build_visual_signs(detected_class: str) -> list[str]:
    if detected_class == "normal":
        return ["No visible abnormal stool sign detected"]
    if detected_class == "unknown":
        return ["The model could not confidently classify the image"]

    return [f"Detected {detected_class.replace('_', ' ')} pattern"]
