from typing import Any

from app.core.exceptions import AppException
from app.db.repositories.module_repository import ModuleRepository


_module_repository = ModuleRepository()

_CATEGORY = {
    "id": "rag-modules",
    "name": "Materi RAG",
    "slug": "rag-modules",
}


def get_module_catalog() -> dict[str, Any]:
    documents = _module_repository.list_rag_modules()
    contents = [_document_to_content(document) for document in documents]

    return {
        "categories": [_CATEGORY],
        "contents": contents,
        "progress": [],
    }


def get_module_detail(module_id: str) -> dict[str, Any]:
    document = _module_repository.get_rag_module(module_id)
    if document is None:
        raise AppException("Modul tidak ditemukan.", status_code=404)

    chunks = _module_repository.list_rag_chunks(module_id)
    return _document_to_content(document, chunks=chunks)


def complete_module(module_id: str) -> dict[str, Any]:
    document = _module_repository.get_rag_module(module_id)
    if document is None:
        raise AppException("Modul tidak ditemukan.", status_code=404)

    # MVP placeholder: user-specific module progress will be persisted after
    # Firebase user context is required on module endpoints.
    return {
        "content_id": module_id,
        "progress_pct": 100,
        "is_completed": True,
    }


def _document_to_content(
    document: dict[str, Any],
    *,
    chunks: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    title = str(document.get("title") or "Modul ANABOOL")
    module_number = _extract_module_number(title)
    body = _build_body(chunks or [])
    summary = _build_summary(title, body, chunks or [])

    return {
        "id": str(document["id"]),
        "category_id": _CATEGORY["id"],
        "category_slug": _CATEGORY["slug"],
        "title": title,
        "summary": summary,
        "body": body or summary,
        "thumbnail_asset": _thumbnail_for_module(module_number),
        "reward_points": 70 + (module_number * 5),
        "duration_minutes": max(5, min(12, 5 + module_number)),
        "is_featured": module_number in {1, 4},
        "source_type": document.get("source_type"),
        "content_url": document.get("content_url"),
    }


def _build_body(chunks: list[dict[str, Any]]) -> str:
    content_parts = [
        str(chunk.get("content") or "").strip()
        for chunk in chunks
        if str(chunk.get("content") or "").strip()
    ]
    return "\n\n".join(content_parts)


def _build_summary(
    title: str,
    body: str,
    chunks: list[dict[str, Any]],
) -> str:
    for chunk in chunks:
        metadata = chunk.get("metadata") or {}
        preview = str(metadata.get("preview") or "").strip()
        if preview:
            return _clean_summary(preview)

    if body:
        return _clean_summary(body)

    return f"Materi pembelajaran ANABOOL dari {title}."


def _clean_summary(value: str) -> str:
    normalized = " ".join(value.replace("\n", " ").split())
    if len(normalized) <= 150:
        return normalized
    return f"{normalized[:147].rstrip()}..."


def _extract_module_number(title: str) -> int:
    parts = title.replace("-", " ").split()
    for index, part in enumerate(parts):
        if part.lower() == "modul" and index + 1 < len(parts):
            try:
                return int(parts[index + 1])
            except ValueError:
                return 1
    return 1


def _thumbnail_for_module(module_number: int) -> str:
    if module_number % 2 == 0:
        return "assets/images/education/modul-image2.png"
    return "assets/images/education/modul-image.png"
