from typing import Any

from app.ai.rag.embedding_client import embed_text
from app.core.exceptions import AppException
from app.integrations.supabase.supabase_client import get_supabase_service_client


def match_rag_chunks(
    query: str,
    *,
    match_count: int,
    match_threshold: float,
    metadata_filter: dict[str, Any] | None = None,
) -> list[dict[str, Any]]:
    client = get_supabase_service_client()
    if client is None:
        return []

    try:
        query_embedding = embed_text(query, is_query=True)
        response = client.rpc(
            "match_rag_chunks",
            {
                "query_embedding": query_embedding,
                "match_count": match_count,
                "match_threshold": match_threshold,
                "metadata_filter": metadata_filter or {},
            },
        ).execute()
    except Exception as exc:
        raise AppException("Gagal mengambil konteks RAG.", status_code=503) from exc

    return list(response.data or [])
