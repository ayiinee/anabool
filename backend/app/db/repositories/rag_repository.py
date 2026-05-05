from typing import Any

from app.ai.rag.embedding_client import embed_text
from app.core.exceptions import AppException
from app.integrations.supabase.supabase_client import get_supabase_service_client


def get_rag_status() -> dict[str, Any]:
    client = get_supabase_service_client()
    if client is None:
        return {
            "configured": False,
            "documents": 0,
            "chunks": 0,
            "active_documents": [],
        }

    try:
        documents_response = (
            client.table("rag_documents")
            .select("id,title,is_active")
            .order("title")
            .execute()
        )
        chunks_response = client.table("rag_chunks").select("id").execute()
    except Exception as exc:
        raise AppException("Gagal membaca status RAG.", status_code=503) from exc

    documents = list(documents_response.data or [])
    chunks = list(chunks_response.data or [])

    return {
        "configured": True,
        "documents": len(documents),
        "chunks": len(chunks),
        "active_documents": [
            document["title"]
            for document in documents
            if document.get("is_active")
        ],
    }


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
                "filter": metadata_filter or {},
            },
        ).execute()
    except Exception as exc:
        raise AppException("Gagal mengambil konteks RAG.", status_code=503) from exc

    return list(response.data or [])
