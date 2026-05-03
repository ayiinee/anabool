from fastapi import UploadFile

from app.ai.cv.image_preprocessing import preprocess_image
from app.ai.cv.label_mapper import map_label
from app.ai.cv.model_loader import load_model


async def predict_waste_class(file: UploadFile) -> dict:
    load_model()
    image_info = await preprocess_image(file)

    # MVP placeholder.
    # Nanti diganti dengan output model CNN asli.
    mock_class_index = 2
    mapped_result = map_label(mock_class_index)

    return {
        **mapped_result,
        "confidence_score": 0.91,
        "image_info": image_info,
    }