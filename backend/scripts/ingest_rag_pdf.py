import argparse
import json
import sys
import time
from pathlib import Path

from pypdf import PdfReader

ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.append(str(ROOT_DIR))

from app.ai.rag.chunking import split_text_into_chunks
from app.ai.rag.embedding_client import embed_text
from app.integrations.supabase.supabase_client import get_supabase_service_client


def execute_with_retry(request_builder, *, retries: int = 3, delay_seconds: float = 1.0):
    last_error: Exception | None = None
    for _attempt in range(retries):
        try:
            return request_builder.execute()
        except Exception as exc:
            last_error = exc
            time.sleep(delay_seconds)

    raise last_error


def extract_pdf_text(pdf_path: Path) -> str:
    reader = PdfReader(str(pdf_path))
    pages: list[str] = []

    for index, page in enumerate(reader.pages, start=1):
        text = page.extract_text() or ""
        text = text.strip()

        if text:
            pages.append(f"[Page {index}]\n{text}")

    return "\n\n".join(pages)


def upsert_document(
    *,
    title: str,
    source_type: str,
    content_url: str | None,
) -> str:
    supabase = get_supabase_service_client()
    if supabase is None:
        raise RuntimeError("Supabase service client is not configured")

    existing = (
        execute_with_retry(
            supabase.table("rag_documents")
            .select("id")
            .eq("title", title)
            .limit(1)
        )
    )
    if existing.data:
        document_id = existing.data[0]["id"]
        execute_with_retry(
            supabase.table("rag_documents").update(
                {
                    "source_type": source_type,
                    "content_url": content_url,
                    "is_active": True,
                }
            ).eq("id", document_id)
        )
        return document_id

    response = execute_with_retry(
        supabase.table("rag_documents")
        .insert(
            {
                "title": title,
                "source_type": source_type,
                "content_url": content_url,
                "is_active": True,
            }
        )
    )

    return response.data[0]["id"]


def upsert_chunk(
    *,
    document_id: str,
    chunk_index: int,
    content: str,
    embedding: list[float],
    metadata: dict,
) -> None:
    supabase = get_supabase_service_client()
    if supabase is None:
        raise RuntimeError("Supabase service client is not configured")

    existing = (
        execute_with_retry(
            supabase.table("rag_chunks")
            .select("id")
            .eq("document_id", document_id)
            .eq("chunk_index", chunk_index)
            .limit(1)
        )
    )
    payload = {
        "document_id": document_id,
        "chunk_index": chunk_index,
        "content": content,
        "embedding": embedding,
        "metadata": metadata,
    }

    if existing.data:
        execute_with_retry(
            supabase.table("rag_chunks").update(payload).eq("id", existing.data[0]["id"])
        )
        return

    execute_with_retry(supabase.table("rag_chunks").insert(payload))


def ingest_pdf(
    *,
    pdf_path: Path,
    title: str,
    source_type: str,
    content_url: str | None,
    metadata: dict,
) -> None:
    if not pdf_path.exists():
        raise FileNotFoundError(f"PDF file not found: {pdf_path}")

    text = extract_pdf_text(pdf_path)

    if not text:
        raise RuntimeError(f"No text extracted from PDF: {pdf_path}")

    document_id = upsert_document(
        title=title,
        source_type=source_type,
        content_url=content_url,
    )

    chunks = split_text_into_chunks(
        text,
        max_chars=900,
        overlap_chars=120,
        base_metadata={
            **metadata,
            "document_title": title,
            "source_type": source_type,
        },
    )

    for chunk in chunks:
        print(f"Embedding chunk {chunk.chunk_index}/{len(chunks)}")

        embedding = embed_text(
            chunk.content,
            is_query=False,
        )

        upsert_chunk(
            document_id=document_id,
            chunk_index=chunk.chunk_index,
            content=chunk.content,
            embedding=embedding,
            metadata=chunk.metadata,
        )

    print(f"Done. Ingested {len(chunks)} chunks for document: {title}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pdf", required=True)
    parser.add_argument("--title", required=True)
    parser.add_argument("--source-type", default="module")
    parser.add_argument("--content-url", default=None)
    parser.add_argument("--metadata", default="{}")

    args = parser.parse_args()

    ingest_pdf(
        pdf_path=Path(args.pdf),
        title=args.title,
        source_type=args.source_type,
        content_url=args.content_url,
        metadata=json.loads(args.metadata),
    )


if __name__ == "__main__":
    main()
