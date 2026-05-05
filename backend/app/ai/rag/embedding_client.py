from functools import lru_cache
import hashlib
import math
from pathlib import Path
import re
from typing import Any

from app.core.config import settings
from app.core.exceptions import AppException


@lru_cache
def get_embedding_model() -> Any:
    if settings.EMBEDDING_PROVIDER != "local":
        raise AppException(
            f"Unsupported embedding provider: {settings.EMBEDDING_PROVIDER}",
            status_code=503,
        )

    try:
        from sentence_transformers import SentenceTransformer
    except ImportError as exc:
        raise AppException(
            "sentence-transformers is not installed. Install backend requirements first.",
            status_code=503,
        ) from exc

    cache_dir = _resolve_embedding_cache_dir()
    cache_dir.mkdir(parents=True, exist_ok=True)

    return SentenceTransformer(
        settings.EMBEDDING_MODEL_NAME,
        cache_folder=str(cache_dir),
    )


def embed_text(text: str, *, is_query: bool = False) -> list[float]:
    cleaned_text = text.strip()

    if not cleaned_text:
        raise ValueError("Cannot embed empty text")

    prefix = _resolve_prefix(is_query=is_query)
    input_text = prefix + cleaned_text

    if settings.EMBEDDING_PROVIDER == "hash":
        return _embed_with_hash(input_text)

    try:
        model = get_embedding_model()
    except AppException:
        return _embed_with_hash(input_text)

    vector = model.encode(
        input_text,
        normalize_embeddings=True,
    )

    return vector.tolist()


def _resolve_prefix(*, is_query: bool) -> str:
    model_name = settings.EMBEDDING_MODEL_NAME.lower()
    if "e5" not in model_name:
        return ""

    return "query: " if is_query else "passage: "


def _resolve_embedding_cache_dir() -> Path:
    cache_dir = Path(settings.EMBEDDING_CACHE_DIR)
    if cache_dir.is_absolute():
        return cache_dir

    backend_dir = Path(__file__).resolve().parents[3]
    return backend_dir / cache_dir


def _embed_with_hash(text: str) -> list[float]:
    dimension = settings.EMBEDDING_DIMENSION
    vector = [0.0] * dimension
    tokens = re.findall(r"\w+", text.lower())
    if not tokens:
        tokens = [text.lower()]

    for token in tokens:
        digest = hashlib.blake2b(token.encode("utf-8"), digest_size=16).digest()
        primary_index = int.from_bytes(digest[:4], "little") % dimension
        secondary_index = int.from_bytes(digest[4:8], "little") % dimension
        primary_sign = 1.0 if digest[8] % 2 == 0 else -1.0
        secondary_sign = 1.0 if digest[9] % 2 == 0 else -1.0

        vector[primary_index] += primary_sign
        vector[secondary_index] += 0.5 * secondary_sign

    norm = math.sqrt(sum(value * value for value in vector))
    if norm == 0:
        return vector

    return [value / norm for value in vector]
