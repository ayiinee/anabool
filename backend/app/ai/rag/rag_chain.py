from app.ai.rag.context_builder import build_scan_context
from app.ai.rag.knowledge_loader import load_fallback_knowledge
from app.ai.rag.prompt_templates import build_ana_system_prompt, build_ana_user_prompt
from app.ai.rag.retriever import RetrievalResult, retrieve_relevant_knowledge
from app.core.config import settings
from app.core.exceptions import AppException
from app.integrations.groq.groq_client import generate_groq_response


_MODULE_4_TITLE = "Modul 4 Protokol Aman Membersihkan & Membuang Kotoran Kucing"
_MODULE_7_TITLE = (
    "Modul 7 Dari Limbah Menjadi Pupuk – Circular Economy yang Aman dan Berkelanjutan"
)

_MODULE_INTENTS = {
    "dispose": {
        "title": _MODULE_4_TITLE,
        "reference": "Untuk informasi lebih lanjut, silakan baca Modul 4",
        "keywords": [
            "buang",
            "membuang",
            "pembuangan",
            "cara membuang yang baik",
            "cara buang",
            "sampah",
            "dispose",
        ],
    },
    "process": {
        "title": _MODULE_7_TITLE,
        "reference": "Untuk informasi lebih lanjut, silakan baca Modul 7",
        "keywords": [
            "olah",
            "mengolah",
            "pengolahan",
            "pupuk",
            "kompos",
            "cara membuat pupuk",
            "circular economy",
            "process",
        ],
    },
}

_DOMAIN_KEYWORDS = {
    "anabul",
    "kucing",
    "feses",
    "feces",
    "kotoran",
    "litter",
    "pasir",
    "toxoplasma",
    "toksoplasma",
    "hamil",
    "imun",
    "diare",
    "muntah",
    "darah",
    "lemas",
    "dokter",
    "hewan",
    "bersih",
    "sanitasi",
    "pickup",
    "pick up",
    "jemput",
    "buang",
    "olah",
    "pupuk",
    "kompos",
}

_GREETING_MESSAGES = {
    "hai",
    "hi",
    "halo",
    "hallo",
    "hello",
    "pagi",
    "siang",
    "sore",
    "malam",
    "selamat pagi",
    "selamat siang",
    "selamat sore",
    "selamat malam",
    "assalamualaikum",
    "assalamu alaikum",
}


def generate_ana_response(
    user_message: str,
    *,
    user_profile: dict | None = None,
    scan_result: dict | None = None,
    metadata_filter: dict | None = None,
    trigger_action: str | None = None,
) -> dict:
    routed_intent = _detect_routed_intent(user_message, trigger_action)
    if _should_bypass_retrieval(user_message, routed_intent):
        return _build_chitchat_response(user_message)

    module_reference = None
    append_source_footer = True
    if routed_intent in _MODULE_INTENTS:
        intent_config = _MODULE_INTENTS[routed_intent]
        metadata_filter = {
            **(metadata_filter or {}),
            "source_type": "module",
            "document_title": intent_config["title"],
        }
        module_reference = intent_config["reference"]
        append_source_footer = False

    retrieval_query = _build_retrieval_query(user_message, routed_intent)
    retrieval_result = _retrieve_context(
        retrieval_query,
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
                            module_reference=module_reference,
                        ),
                    },
                ]
            ).strip()
            answer = _ensure_module_reference(answer, module_reference)
            provider = "groq"
        except Exception:
            answer = _build_grounded_fallback_answer(
                user_message=user_message,
                retrieval_result=retrieval_result,
                fallback_knowledge=fallback_knowledge,
                scan_result=scan_result,
                user_profile=user_profile,
                module_reference=module_reference,
            )
    else:
        answer = _build_grounded_fallback_answer(
            user_message=user_message,
            retrieval_result=retrieval_result,
            fallback_knowledge=fallback_knowledge,
            scan_result=scan_result,
            user_profile=user_profile,
            module_reference=module_reference,
        )

    return {
        "answer": answer,
        "provider": provider,
        "sources": retrieval_result.source_titles(),
        "retrieved_chunks": len(retrieval_result.chunks),
        "used_rag": retrieval_result.has_matches,
        "append_source_footer": append_source_footer,
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
    module_reference: str | None = None,
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
    answer = (
        f"{scan_note}{risk_note}"
        "Berdasarkan konteks yang tersedia, ini masih bersifat edukatif dan bukan diagnosis pasti. "
        f"Untuk pertanyaan '{user_message}', prioritas utamanya adalah menjaga kebersihan litter box, "
        "mengurangi kontak langsung dengan limbah, memakai sarung tangan atau sekop khusus, dan "
        "membuang limbah dalam kantong tertutup. Jika ada darah, diare lebih dari 24 jam, muntah berulang, "
        "lemas, tidak mau makan, kesulitan buang air, atau tanda dehidrasi, konsultasikan ke dokter hewan.\n\n"
        f"Rujukan yang dipakai:\n{references}"
    )
    return _ensure_module_reference(answer, module_reference)


def _detect_routed_intent(user_message: str, trigger_action: str | None) -> str | None:
    normalized_trigger = (trigger_action or "").strip().lower()
    if normalized_trigger == "process":
        return "process"
    if normalized_trigger == "dispose":
        return "dispose"

    text = _normalize_text(user_message)
    for intent, config in _MODULE_INTENTS.items():
        if any(keyword in text for keyword in config["keywords"]):
            return intent
    return None


def _build_retrieval_query(user_message: str, routed_intent: str | None) -> str:
    if routed_intent == "process":
        return "cara membuat pupuk dan mengolah limbah kucing yang aman"
    if routed_intent == "dispose":
        return "cara membuang kotoran kucing yang baik dan aman"
    return user_message


def _should_bypass_retrieval(user_message: str, routed_intent: str | None) -> bool:
    if routed_intent:
        return False

    text = _normalize_text(user_message)
    if not text:
        return True
    if text in _GREETING_MESSAGES:
        return True
    if any(text.startswith(f"{greeting} ") for greeting in _GREETING_MESSAGES):
        remaining = text.split(maxsplit=1)[1] if " " in text else ""
        return len(remaining.split()) <= 2 and not _has_domain_keyword(remaining)

    words = text.split()
    if len(words) <= 2 and not _has_domain_keyword(text):
        return True
    if len(words) <= 5 and not _has_domain_keyword(text):
        return True

    return False


def _build_chitchat_response(user_message: str) -> dict:
    text = _normalize_text(user_message)
    if any(greeting in text for greeting in ["pagi", "siang", "sore", "malam"]):
        answer = (
            "Selamat juga. Ana siap bantu kalau kamu mau tanya soal kebersihan litter box, "
            "risiko Toxoplasma, atau pilihan Pick Up, Olah, dan Buang."
        )
    else:
        answer = (
            "Hai, Ana siap bantu. Kalau ada pertanyaan soal kebersihan litter box, "
            "Toxoplasma, atau pengelolaan limbah kucing, langsung tanya saja ya."
        )

    return {
        "answer": answer,
        "provider": "fallback",
        "sources": [],
        "retrieved_chunks": 0,
        "used_rag": False,
        "append_source_footer": False,
    }


def _has_domain_keyword(text: str) -> bool:
    return any(keyword in text for keyword in _DOMAIN_KEYWORDS)


def _normalize_text(value: str) -> str:
    normalized = value.lower().strip()
    for char in ",.!?;:\"'()[]{}":
        normalized = normalized.replace(char, " ")
    return " ".join(normalized.split())


def _ensure_module_reference(answer: str, module_reference: str | None) -> str:
    if not module_reference:
        return answer

    cleaned_answer = answer.strip()
    if cleaned_answer.endswith(module_reference):
        return cleaned_answer
    return f"{cleaned_answer}\n\n{module_reference}"
