import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.ai.rag.chunking import split_text_into_chunks


def test_split_text_into_chunks_preserves_order_and_overlap():
    text = (
        "Paragraf pertama membahas toxoplasma dan kebersihan dasar litter box.\n\n"
        "Paragraf kedua menjelaskan pentingnya sarung tangan dan kantong tertutup.\n\n"
        "Paragraf ketiga menekankan kapan perlu konsultasi ke dokter hewan."
    )

    chunks = split_text_into_chunks(
        text,
        max_chars=110,
        overlap_chars=30,
        base_metadata={"document_title": "Modul 1"},
    )

    assert len(chunks) >= 2
    assert chunks[0].chunk_index == 0
    assert chunks[0].metadata["document_title"] == "Modul 1"
    assert "Paragraf pertama" in chunks[0].content
    assert any("sarung tangan" in chunk.content for chunk in chunks[1:])
