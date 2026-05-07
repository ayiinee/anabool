import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.ai.rag.chunking import split_text_into_chunks
from app.ai.rag.retriever import RetrievalResult, RetrievedChunk


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


def test_generate_ana_response_bypasses_rag_for_greeting(monkeypatch):
    from app.ai.rag import rag_chain

    def fail_retrieval(*_args, **_kwargs):
        raise AssertionError("retrieval should be bypassed for greetings")

    monkeypatch.setattr(rag_chain, "retrieve_relevant_knowledge", fail_retrieval)

    result = rag_chain.generate_ana_response("halo")

    assert result["used_rag"] is False
    assert result["retrieved_chunks"] == 0
    assert result["sources"] == []
    assert "Sumber rujukan" not in result["answer"]


def test_generate_ana_response_routes_process_query_to_module_7(monkeypatch):
    from app.ai.rag import rag_chain

    captured = {}

    def fake_retrieval(query, *, match_count, match_threshold, metadata_filter):
        captured["query"] = query
        captured["metadata_filter"] = metadata_filter
        return RetrievalResult(
            query=query,
            chunks=[
                RetrievedChunk(
                    chunk_id="chunk-1",
                    document_id="doc-7",
                    title="Modul 7",
                    content="Materi Modul 7 tentang pengolahan limbah menjadi pupuk.",
                    metadata={"document_title": "Modul 7"},
                    similarity=0.9,
                )
            ],
        )

    monkeypatch.setattr(rag_chain.settings, "GROQ_API_KEY", "")
    monkeypatch.setattr(rag_chain, "retrieve_relevant_knowledge", fake_retrieval)

    result = rag_chain.generate_ana_response("cara membuat pupuk dari kotoran kucing")

    assert captured["query"] == "cara membuat pupuk dan mengolah limbah kucing yang aman"
    assert captured["metadata_filter"]["source_type"] == "module"
    assert captured["metadata_filter"]["document_title"].startswith("Modul 7")
    assert result["used_rag"] is True
    assert result["append_source_footer"] is False
    assert result["answer"].endswith("Untuk informasi lebih lanjut, silakan baca Modul 7")


def test_generate_ana_response_routes_dispose_trigger_to_module_4(monkeypatch):
    from app.ai.rag import rag_chain

    captured = {}

    def fake_retrieval(query, *, match_count, match_threshold, metadata_filter):
        captured["query"] = query
        captured["metadata_filter"] = metadata_filter
        return RetrievalResult(
            query=query,
            chunks=[
                RetrievedChunk(
                    chunk_id="chunk-1",
                    document_id="doc-4",
                    title="Modul 4",
                    content="Materi Modul 4 tentang protokol membuang kotoran kucing.",
                    metadata={"document_title": "Modul 4"},
                    similarity=0.9,
                )
            ],
        )

    monkeypatch.setattr(rag_chain.settings, "GROQ_API_KEY", "")
    monkeypatch.setattr(rag_chain, "retrieve_relevant_knowledge", fake_retrieval)

    result = rag_chain.generate_ana_response("Saya memilih Buang.", trigger_action="dispose")

    assert captured["query"] == "cara membuang kotoran kucing yang baik dan aman"
    assert captured["metadata_filter"]["source_type"] == "module"
    assert captured["metadata_filter"]["document_title"].startswith("Modul 4")
    assert result["used_rag"] is True
    assert result["append_source_footer"] is False
    assert result["answer"].endswith("Untuk informasi lebih lanjut, silakan baca Modul 4")
