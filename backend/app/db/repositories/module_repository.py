from typing import Any

from app.core.exceptions import AppException
from app.integrations.supabase.supabase_client import get_supabase_service_client


class ModuleRepository:
    @property
    def is_available(self) -> bool:
        return get_supabase_service_client() is not None

    def list_rag_modules(self) -> list[dict[str, Any]]:
        client = get_supabase_service_client()
        if client is None:
            return []

        try:
            response = (
                client.table("rag_documents")
                .select("id,title,source_type,content_url,is_active,created_at")
                .eq("source_type", "module")
                .eq("is_active", True)
                .order("title")
                .execute()
            )
        except Exception as exc:
            raise AppException("Gagal mengambil daftar modul dari Supabase.", status_code=503) from exc

        return list(response.data or [])

    def get_rag_module(self, module_id: str) -> dict[str, Any] | None:
        client = get_supabase_service_client()
        if client is None:
            return None

        try:
            response = (
                client.table("rag_documents")
                .select("id,title,source_type,content_url,is_active,created_at")
                .eq("id", module_id)
                .eq("source_type", "module")
                .eq("is_active", True)
                .limit(1)
                .execute()
            )
        except Exception as exc:
            raise AppException("Gagal mengambil detail modul dari Supabase.", status_code=503) from exc

        rows = list(response.data or [])
        return rows[0] if rows else None

    def list_rag_chunks(self, document_id: str) -> list[dict[str, Any]]:
        client = get_supabase_service_client()
        if client is None:
            return []

        try:
            response = (
                client.table("rag_chunks")
                .select("chunk_index,content,metadata")
                .eq("document_id", document_id)
                .order("chunk_index")
                .execute()
            )
        except Exception as exc:
            raise AppException("Gagal mengambil materi modul dari Supabase.", status_code=503) from exc

        return list(response.data or [])
