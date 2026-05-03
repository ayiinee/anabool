from app.core.config import settings


_model = None


def load_model():
    global _model

    if _model is not None:
        return _model

    # MVP placeholder.
    # Nanti jika model CNN sudah siap, load model dari settings.CNN_MODEL_PATH.
    _model = "mock_cnn_model"

    return _model