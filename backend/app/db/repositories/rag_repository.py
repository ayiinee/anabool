import time
from typing import Any

from app.ai.rag.embedding_client import embed_text
from app.core.config import settings
from app.core.exceptions import AppException
from app.integrations.supabase.supabase_client import get_supabase_service_client


def match_rag_chunks(
    query: str,
    *,
    match_count: int = 4,
    match_threshold: float = 0.05,
    metadata_filter: dict[str, Any] | None = None,
) -> list[dict[str, Any]]:
    supabase = get_supabase_service_client()
    if supabase is None:
        raise AppException("Supabase service client is not configured.", status_code=503)

    query_embedding = embed_text(query, is_query=True)
    payload = {
        "query_embedding": _serialize_vector(query_embedding),
        "match_threshold": match_threshold,
        "match_count": match_count,
        "filter": metadata_filter or {},
    }

    last_error: Exception | None = None
    for _attempt in range(3):
        try:
            response = supabase.rpc("match_rag_chunks", payload).execute()
            return list(response.data or [])
        except Exception as exc:
            last_error = exc
            time.sleep(1)

    raise AppException(
        f"RAG retrieval query failed: {last_error}",
        status_code=502,
    ) from last_error


def get_rag_status() -> dict[str, int]:
    supabase = get_supabase_service_client()
    if supabase is None:
        raise AppException("Supabase service client is not configured.", status_code=503)

    try:
        document_result = supabase.table("rag_documents").select("id", count="exact").limit(1).execute()
        chunk_result = supabase.table("rag_chunks").select("id", count="exact").limit(1).execute()
    except Exception as exc:
        raise AppException(
            f"Failed to read RAG status from Supabase: {exc}",
            status_code=502,
        ) from exc

    return {
        "document_count": int(document_result.count or 0),
        "chunk_count": int(chunk_result.count or 0),
        "embedding_dimension": settings.EMBEDDING_DIMENSION,
    }


def _serialize_vector(values: list[float]) -> str:
    return "[" + ",".join(f"{value:.8f}" for value in values) + "]"
