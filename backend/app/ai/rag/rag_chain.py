from app.ai.rag.context_builder import build_scan_context
from app.ai.rag.knowledge_loader import load_fallback_knowledge
from app.ai.rag.prompt_templates import build_ana_system_prompt, build_ana_user_prompt
from app.ai.rag.retriever import RetrievalResult, retrieve_relevant_knowledge
from app.core.config import settings
from app.core.exceptions import AppException
from app.integrations.groq.groq_client import generate_groq_response


def generate_ana_response(
    user_message: str,
    *,
    user_profile: dict | None = None,
    scan_result: dict | None = None,
    metadata_filter: dict | None = None,
) -> dict:
    retrieval_result = _retrieve_context(
        user_message,
        metadata_filter=metadata_filter,
    )
    fallback_knowledge = load_fallback_knowledge(
        (scan_result or {}).get("detected_class"),
    )
    context = _build_combined_context(
        retrieval_result=retrieval_result,
        scan_result=scan_result,
        user_profile=user_profile,
        fallback_knowledge=fallback_knowledge,
    )

    answer: str
    provider = "fallback"

    if settings.GROQ_API_KEY:
        try:
            answer = generate_groq_response(
                [
                    {"role": "system", "content": build_ana_system_prompt()},
                    {
                        "role": "user",
                        "content": build_ana_user_prompt(
                            context=context,
                            user_message=user_message,
                        ),
                    },
                ]
            ).strip()
            provider = "groq"
        except Exception:
            answer = _build_grounded_fallback_answer(
                user_message=user_message,
                retrieval_result=retrieval_result,
                fallback_knowledge=fallback_knowledge,
                scan_result=scan_result,
                user_profile=user_profile,
            )
    else:
        answer = _build_grounded_fallback_answer(
            user_message=user_message,
            retrieval_result=retrieval_result,
            fallback_knowledge=fallback_knowledge,
            scan_result=scan_result,
            user_profile=user_profile,
        )

    return {
        "answer": answer,
        "provider": provider,
        "sources": retrieval_result.source_titles(),
        "retrieved_chunks": len(retrieval_result.chunks),
        "used_rag": retrieval_result.has_matches,
    }


def _retrieve_context(
    user_message: str,
    *,
    metadata_filter: dict | None = None,
) -> RetrievalResult:
    try:
        return retrieve_relevant_knowledge(
            user_message,
            match_count=4,
            match_threshold=None,
            metadata_filter=metadata_filter,
        )
    except AppException:
        return RetrievalResult(query=user_message, chunks=[])


def _build_combined_context(
    *,
    retrieval_result: RetrievalResult,
    scan_result: dict | None,
    user_profile: dict | None,
    fallback_knowledge: list[dict[str, str]],
) -> str:
    sections: list[str] = []

    if scan_result:
        sections.append("KONTEKS SCAN\n" + build_scan_context(scan_result, user_profile))

    if retrieval_result.has_matches:
        sections.append("KONTEKS RAG\n" + retrieval_result.build_context_block())
    else:
        fallback_text = "\n\n".join(
            f"- {item['title']}: {item['content']}" for item in fallback_knowledge
        )
        sections.append("KONTEKS CADANGAN\n" + fallback_text)

    return "\n\n".join(sections).strip()


def _build_grounded_fallback_answer(
    *,
    user_message: str,
    retrieval_result: RetrievalResult,
    fallback_knowledge: list[dict[str, str]],
    scan_result: dict | None,
    user_profile: dict | None,
) -> str:
    reference_lines: list[str] = []
    if retrieval_result.has_matches:
        for chunk in retrieval_result.chunks[:2]:
            reference_lines.append(f"- {chunk.title}: {chunk.content}")
    else:
        for item in fallback_knowledge[:2]:
            reference_lines.append(f"- {item['title']}: {item['content']}")

    risk_note = ""
    risk_group = (user_profile or {}).get("risk_group")
    if (user_profile or {}).get("safety_mode") or risk_group in {"pregnant", "low_immunity"}:
        risk_note = (
            "Karena safety mode atau kelompok risiko aktif, sebaiknya hindari kontak langsung "
            "dengan feses dan gunakan bantuan orang lain bila memungkinkan. "
        )

    scan_note = ""
    if scan_result:
        detected_class = scan_result.get("detected_class", "unknown")
        risk_level = scan_result.get("risk_level", "unknown")
        scan_note = (
            f"Hasil scan saat ini memberi indikasi awal kelas {detected_class} dengan tingkat risiko {risk_level}. "
        )

    references = "\n".join(reference_lines)
    return (
        f"{scan_note}{risk_note}"
        "Berdasarkan konteks yang tersedia, ini masih bersifat edukatif dan bukan diagnosis pasti. "
        f"Untuk pertanyaan '{user_message}', prioritas utamanya adalah menjaga kebersihan litter box, "
        "mengurangi kontak langsung dengan limbah, memakai sarung tangan atau sekop khusus, dan "
        "membuang limbah dalam kantong tertutup. Jika ada darah, diare lebih dari 24 jam, muntah berulang, "
        "lemas, tidak mau makan, kesulitan buang air, atau tanda dehidrasi, konsultasikan ke dokter hewan.\n\n"
        f"Rujukan yang dipakai:\n{references}"
    )
