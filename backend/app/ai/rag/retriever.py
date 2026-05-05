from dataclasses import dataclass, field
from typing import Any

from app.core.config import settings
from app.db.repositories.rag_repository import match_rag_chunks


@dataclass(slots=True)
class RetrievedChunk:
    chunk_id: str
    document_id: str
    title: str
    content: str
    metadata: dict[str, Any]
    similarity: float


@dataclass(slots=True)
class RetrievalResult:
    query: str
    chunks: list[RetrievedChunk] = field(default_factory=list)

    @property
    def has_matches(self) -> bool:
        return bool(self.chunks)

    def build_context_block(self) -> str:
        if not self.chunks:
            return ""

        sections: list[str] = []
        for index, chunk in enumerate(self.chunks, start=1):
            sections.append(
                "\n".join(
                    [
                        f"[Sumber {index}] {chunk.title}",
                        f"Similarity: {chunk.similarity:.3f}",
                        chunk.content,
                    ]
                )
            )

        return "\n\n".join(sections)

    def source_titles(self) -> list[str]:
        ordered_titles: list[str] = []
        seen_titles: set[str] = set()
        for chunk in self.chunks:
            if chunk.title in seen_titles:
                continue
            seen_titles.add(chunk.title)
            ordered_titles.append(chunk.title)
        return ordered_titles


def retrieve_relevant_knowledge(
    query: str,
    *,
    match_count: int = 4,
    match_threshold: float | None = None,
    metadata_filter: dict[str, Any] | None = None,
) -> RetrievalResult:
    resolved_match_threshold = match_threshold
    if resolved_match_threshold is None:
        resolved_match_threshold = 0.05 if settings.EMBEDDING_PROVIDER == "hash" else 0.45

    rows = match_rag_chunks(
        query,
        match_count=match_count,
        match_threshold=resolved_match_threshold,
        metadata_filter=metadata_filter,
    )

    chunks = [
        RetrievedChunk(
            chunk_id=str(row["chunk_id"]),
            document_id=str(row["document_id"]),
            title=str(row["title"]),
            content=str(row["content"]),
            metadata=dict(row.get("metadata") or {}),
            similarity=float(row.get("similarity") or 0.0),
        )
        for row in rows
    ]

    return RetrievalResult(query=query, chunks=chunks)
