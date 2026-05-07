from datetime import datetime, timezone
from uuid import UUID, uuid4

from app.ai.rag.rag_chain import generate_ana_response
from app.db.repositories.chat_repository import ChatRepository
from app.db.schemas.chat_schema import ChatCtaCard, ChatMessage, ChatSession


_sessions: dict[str, ChatSession] = {}
_session_context: dict[str, dict] = {}
_chat_repository = ChatRepository()

_CTA_CARDS = [
    ChatCtaCard(
        card_type="pickup",
        title="Pick Up",
        description="Panduan menyiapkan limbah kucing untuk penjemputan aman.",
        cta_label="Jadwalkan Pick-up",
        payload={"action": "select_chat_cta"},
    ),
    ChatCtaCard(
        card_type="dispose",
        title="Buang",
        description="Cara membuang limbah kucing dengan kantong tertutup.",
        cta_label="Lihat Cara Buang",
        payload={"action": "select_chat_cta"},
    ),
    ChatCtaCard(
        card_type="process",
        title="Olah",
        description="Langkah awal mengolah limbah tanpa kontak langsung.",
        cta_label="Lihat Cara Olah",
        payload={"action": "select_chat_cta"},
    ),
]

_CTA_SELECTION_RESPONSES = {
    "process": {
        "selected_label": "Olah",
        "tutorial": (
            "Boleh, kita arahkan ke Olah. Quick tips: gunakan sarung tangan dan masker, "
            "pisahkan limbah kucing dari kompos tanaman pangan, masukkan ke wadah khusus "
            "yang tertutup, lalu ikuti metode pengolahan yang memang disiapkan untuk limbah "
            "hewan. Hindari kontak langsung dan cuci alat setelah selesai."
        ),
        "module_title": "Modul Pengolahan Limbah",
        "module_category": "waste_processing",
        "target_route": "/modules/waste-processing",
    },
    "dispose": {
        "selected_label": "Buang",
        "tutorial": (
            "Siap, kita pakai alur Buang. Quick tips: ambil feses dengan sekop, masukkan "
            "ke kantong kuat, ikat rapat, lalu gunakan kantong kedua bila basah atau berbau. "
            "Buang ke tempat sampah sesuai aturan setempat, bersihkan sekop, dan cuci tangan "
            "dengan sabun."
        ),
        "module_title": "Modul Sanitasi Lingkungan",
        "module_category": "environment_sanitation",
        "target_route": "/modules/environment-sanitation",
    },
    "pickup": {
        "selected_label": "Pick Up",
        "tutorial": (
            "Oke, kita siapkan Pick Up. Quick tips: kemas limbah dalam kantong tertutup ganda, "
            "letakkan di titik ambil yang teduh, jauhkan dari anak-anak dan hewan lain, lalu "
            "pastikan area litter box tetap dibersihkan setelah limbah dipindahkan."
        ),
        "module_title": "Modul Teknik Kebersihan/Kesehatan",
        "module_category": "cleanliness_health",
        "target_route": "/modules/cleanliness-health",
    },
}

_SCAN_CLASS_EXPLANATIONS = {
    "diarrhea": (
        "Dari hasil scan, Ana melihat indikasi awal feses cenderung cair atau diare. "
        "Kondisi seperti ini bisa berkaitan dengan perubahan makanan, stres, infeksi, "
        "atau iritasi pencernaan. Pantau asupan minum dan kondisi kucing, lalu konsultasikan "
        "ke tenaga profesional jika diare berlanjut, ada darah, muntah, atau kucing tampak lemas."
    ),
    "lack_of_water": (
        "Dari hasil scan, Ana melihat indikasi awal feses tampak lebih kering atau keras. "
        "Ini bisa menjadi tanda kucing kurang cairan, pola makan kurang sesuai, atau litter box "
        "terlalu lama tidak dibersihkan. Pastikan air minum mudah dijangkau dan pantau apakah "
        "kucing mengejan saat buang air."
    ),
    "soft_poop": (
        "Dari hasil scan, Ana melihat indikasi awal feses bertekstur lebih lembek dari biasanya. "
        "Kondisi ini belum tentu berbahaya, tetapi bisa muncul saat makanan berubah, pencernaan "
        "sensitif, atau kucing sedang stres. Pantau 24 jam ke depan dan jaga kebersihan area litter."
    ),
    "normal": (
        "Dari hasil scan, Ana melihat indikasi awal feses berada dalam kondisi normal. "
        "Teksturnya terlihat cukup terbentuk sehingga risiko kebersihan harian relatif lebih mudah "
        "dikendalikan. Tetap gunakan sekop atau sarung tangan saat menangani limbah."
    ),
    "unknown": (
        "Ana belum bisa membaca kondisi feses dengan yakin dari foto ini. Pencahayaan, sudut foto, "
        "atau objek yang tertutup pasir bisa memengaruhi hasil klasifikasi. Untuk pencegahan, tetap "
        "perlakukan limbah sebagai bahan yang perlu ditangani dengan aman."
    ),
}

_GUIDELINES = {
    "cleaning": (
        "Untuk membersihkan litter box, gunakan sarung tangan sekali pakai, masker bila bau menyengat, "
        "sekop khusus, lalu cuci wadah dengan sabun dan air mengalir sebelum dikeringkan. Pakai disinfektan "
        "yang aman untuk hewan dan jauhkan kucing sampai area benar-benar kering."
    ),
    "packing": (
        "Untuk pengemasan, masukkan feses dan pasir terkontaminasi ke kantong kuat, ikat rapat, lalu masukkan "
        "ke kantong kedua bila basah atau berbau. Simpan sementara di tempat teduh, tertutup, dan jauh dari "
        "makanan, anak-anak, serta hewan lain."
    ),
    "toxoplasma": (
        "Risiko Toxoplasma lebih perlu diwaspadai oleh ibu hamil, orang dengan imun rendah, dan orang yang "
        "sering kontak langsung dengan feses. Kurangi kontak langsung, bersihkan litter box setiap hari, dan "
        "minta orang lain menangani limbah bila Anda termasuk kelompok berisiko."
    ),
    "vet": (
        "Kunjungi dokter hewan bila kucing terlihat lemas, tidak mau makan, muntah berulang, diare lebih dari "
        "24 jam, ada darah, feses hitam pekat, kesulitan buang air, atau tanda dehidrasi."
    ),
    "pickup": (
        "Untuk Pick Up, pastikan limbah sudah berada dalam kantong tertutup ganda, diberi label bila perlu, "
        "dan diletakkan di titik ambil yang teduh serta tidak mudah dijangkau anak-anak atau hewan lain."
    ),
    "process": (
        "Untuk Olah, gunakan hanya metode yang memang disiapkan untuk limbah hewan. Jangan mencampur limbah "
        "dengan kompos sayur untuk tanaman pangan, dan hindari proses yang membuat Anda menyentuh feses langsung."
    ),
    "dispose": (
        "Untuk Buang, gunakan kantong tertutup dan tempat sampah yang sesuai aturan setempat. Bersihkan sekop "
        "dan area sekitar setelahnya, lalu cuci tangan dengan sabun."
    ),
    "fallback": (
        "Aku belum bisa menangkap pertanyaan itu dengan jelas. Coba tanyakan tentang cara membersihkan, "
        "mengemas, risiko Toxoplasma, tanda perlu ke dokter hewan, Pick Up, Olah, atau Buang."
    ),
}

_GUARDRAILS = (
    "Catatan aman: aku tidak memberi diagnosis pasti, tidak meresepkan obat, dan tidak membuat klaim deteksi "
    "parasit. Selalu gunakan sarung tangan atau sekop, masukkan limbah ke kantong tertutup, bersihkan area "
    "dengan sabun atau disinfektan aman hewan, lalu cuci tangan. Red flags: segera hubungi dokter hewan bila "
    "ada darah, diare lebih dari 24 jam, muntah berulang, lemas, tidak mau makan, kesulitan buang air, atau "
    "tanda dehidrasi. Jangan flush atau membuang limbah kucing ke toilet."
)

_WELCOME_MESSAGE = (
    "Halo! Aku Ana, asisten setiamu untuk menjaga kebersihan dan kesehatan anabul kesayangan. 🐾 "
    "Aku bisa bantu kasih tips bersihin litter box, info soal risiko Toxoplasma, sampai pilihan olah "
    "limbah yang aman. Ada yang bisa Ana bantu hari ini?"
)


def start_consultation_chat(user_id: str | None = None) -> ChatSession:
    context = {
        "scan_result": None,
        "user_profile": None,
    }
    if user_id and _chat_repository.is_available:
        db_session = _chat_repository.create_session(
            user_id=user_id,
            session_type="consultation",
            initial_context=context,
        )
        welcome_message = _persist_message(
            str(db_session["id"]),
            _assistant_text(_WELCOME_MESSAGE),
        )
        session = ChatSession(
            id=str(db_session["id"]),
            session_type="consultation",
            assistant_name="Si Ana",
            messages=[welcome_message],
        )
        _cache_session(session, context)
        return session

    session = ChatSession(
        id=_new_id("chat"),
        session_type="consultation",
        assistant_name="Si Ana",
        messages=[
            _assistant_text(_WELCOME_MESSAGE),
        ],
    )
    _cache_session(session, context)
    return session


def send_chat_message(session_id: str, content: str) -> ChatSession:
    session = _sessions.get(session_id) or _load_persisted_session(session_id)
    if session is None:
        raise KeyError(session_id)

    context = _session_context.get(session_id, {})
    user_message = ChatMessage(
        id=_new_id("msg"),
        role="user",
        message_type="text",
        content=content.strip(),
        created_at=_now(),
    )
    session.messages.append(_persist_message(session.id, user_message))

    rag_result = generate_ana_response(
        content,
        user_profile=context.get("user_profile"),
        scan_result=context.get("scan_result"),
    )
    assistant_message = _assistant_text(_format_rag_answer(rag_result))
    session.messages.append(_persist_message(session.id, assistant_message))
    _cache_session(session, context)
    return session


def select_chat_cta_card(session_id: str, card_type: str) -> ChatSession:
    session = _sessions.get(session_id) or _load_persisted_session(session_id)
    if session is None:
        raise KeyError(session_id)

    normalized_card_type = card_type.strip().lower()
    response_config = _CTA_SELECTION_RESPONSES.get(normalized_card_type)
    if response_config is None:
        raise ValueError("Unknown chat CTA card type")

    context = _session_context.get(session_id, {})
    tutorial = response_config["tutorial"]
    if normalized_card_type in {"process", "dispose"}:
        rag_result = generate_ana_response(
            f"Saya memilih {response_config['selected_label']}.",
            user_profile=context.get("user_profile"),
            scan_result=context.get("scan_result"),
            trigger_action=normalized_card_type,
        )
        tutorial = _format_cta_rag_tutorial(
            rag_result=rag_result,
            module_title=response_config["module_title"],
        )

    user_message = ChatMessage(
        id=_new_id("msg"),
        role="user",
        message_type="cta_selection",
        content=f"Saya memilih {response_config['selected_label']}.",
        created_at=_now(),
    )
    assistant_message = _assistant_cta_followup(
        session_id=session.id,
        card_type=normalized_card_type,
        tutorial=tutorial,
        module_title=response_config["module_title"],
        module_category=response_config["module_category"],
        target_route=response_config["target_route"],
    )

    session.messages.append(_persist_message(session.id, user_message))
    session.messages.append(_persist_message(session.id, assistant_message))
    _cache_session(session, context)
    return session


def start_chat_from_scan_session(
    scan_id: str,
    user_id: str | None = None,
    detected_class: str | None = None,
    confidence_score: float | None = None,
    risk_level: str | None = None,
    filename: str | None = None,
) -> dict:
    resolved_user_id = user_id or _chat_repository.find_scan_user_id(scan_id)
    resolved_class = _clean_optional(detected_class) or "unknown"
    resolved_confidence = confidence_score if confidence_score is not None else 0.0
    resolved_risk = _clean_optional(risk_level) or "unknown"
    context = {
        "scan_result": {
            "scan_id": scan_id,
            "detected_class": resolved_class,
            "confidence_score": resolved_confidence,
            "risk_level": resolved_risk,
            "filename": _clean_optional(filename),
        },
        "user_profile": None,
    }
    scan_message = ChatMessage(
        id=_new_id("msg"),
        role="user",
        message_type="scan_result",
        content=_build_scan_message_content(
            detected_class=resolved_class,
            confidence_score=resolved_confidence,
            risk_level=resolved_risk,
        ),
        created_at=_now(),
    )
    explanation_message = _assistant_text(
        _build_scan_explanation_content(
            detected_class=resolved_class,
            confidence_score=resolved_confidence,
            risk_level=resolved_risk,
        )
    )
    next_step_message = _assistant_text(
        "Langkah selanjutnya mau kamu arahkan ke mana? Ana bisa bantu pilih cara penanganan "
        "yang paling sesuai dari opsi cepat di bawah ini."
    )
    cta_message = _assistant_cta_cards()

    if resolved_user_id and _chat_repository.is_available:
        db_session = _chat_repository.create_session(
            user_id=resolved_user_id,
            session_type="scan_result",
            scan_session_id=scan_id,
            initial_context=context,
        )
        session = ChatSession(
            id=str(db_session["id"]),
            session_type="scan_result",
            assistant_name="Si Ana",
            messages=[
                _persist_message(str(db_session["id"]), scan_message),
                _persist_message(str(db_session["id"]), explanation_message),
                _persist_message(str(db_session["id"]), next_step_message),
                _persist_message(str(db_session["id"]), cta_message),
            ],
        )
        _cache_session(session, context)
        result = session.model_dump(mode="json")
        result["scan_id"] = scan_id
        return result

    session = ChatSession(
        id=_new_id("chat"),
        session_type="scan_result",
        assistant_name="Si Ana",
        messages=[scan_message, explanation_message, next_step_message, cta_message],
    )
    _cache_session(session, context)

    result = session.model_dump(mode="json")
    result["scan_id"] = scan_id
    return result


def get_chat_session(session_id: str) -> ChatSession:
    session = _sessions.get(session_id) or _load_persisted_session(session_id)
    if session is None:
        raise KeyError(session_id)
    return session


def _format_rag_answer(rag_result: dict) -> str:
    answer = rag_result["answer"].strip()
    sources = rag_result.get("sources") or []
    if sources and rag_result.get("append_source_footer", True):
        answer = f"{answer}\n\nSumber rujukan: {', '.join(sources)}"
    return answer


def _format_cta_rag_tutorial(*, rag_result: dict, module_title: str) -> str:
    answer = _format_rag_answer(rag_result).strip()
    return f"Quick tips dari {module_title}:\n\n{answer}"


def _detect_topic(content: str) -> str:
    text = content.lower()
    keyword_map = {
        "pickup": ["pick up", "pickup", "jemput", "penjemputan"],
        "process": ["olah", "proses", "kompos", "mengolah"],
        "dispose": ["buang", "pembuangan", "sampah", "dispose"],
        "cleaning": ["bersih", "cuci", "clean", "litter box", "kotak pasir", "sanitasi"],
        "packing": ["kemas", "packing", "kantong", "bungkus", "simpan"],
        "toxoplasma": ["toxoplasma", "toksoplasma", "hamil", "imun", "parasite", "parasit"],
        "vet": ["dokter", "vet", "hewan", "darah", "diare", "muntah", "lemas", "makan"],
    }
    for topic, keywords in keyword_map.items():
        if any(keyword in text for keyword in keywords):
            return topic
    return "fallback"


def _assistant_text(content: str) -> ChatMessage:
    return ChatMessage(
        id=_new_id("msg"),
        role="assistant",
        message_type="text",
        content=content,
        created_at=_now(),
    )


def _assistant_cta_cards() -> ChatMessage:
    return ChatMessage(
        id=_new_id("msg"),
        role="assistant",
        message_type="cta_cards",
        content="Pilih tindakan cepat yang ingin kamu ambil.",
        cards=_CTA_CARDS,
        created_at=_now(),
    )


def _assistant_cta_followup(
    *,
    session_id: str,
    card_type: str,
    tutorial: str,
    module_title: str,
    module_category: str,
    target_route: str,
) -> ChatMessage:
    content = tutorial
    if "Untuk informasi lebih lanjut, silakan baca Modul" not in content:
        content = f"{content}\n\nKlik Pelajari Selengkapnya untuk membuka {module_title}."

    return ChatMessage(
        id=_new_id("msg"),
        role="assistant",
        message_type="cta_cards",
        content=content,
        cards=[
            ChatCtaCard(
                card_type=f"{card_type}_module",
                title=module_title,
                description="Buka modul edukasi tanpa menutup sesi chat Ana.",
                cta_label="Pelajari Selengkapnya",
                target_route=target_route,
                payload={
                    "module_category": module_category,
                    "chat_session_id": session_id,
                    "return_route": f"/chats/{session_id}",
                    "preserve_chat_session": True,
                },
            )
        ],
        created_at=_now(),
    )


def _build_scan_explanation_content(
    *,
    detected_class: str,
    confidence_score: float,
    risk_level: str,
) -> str:
    explanation = _SCAN_CLASS_EXPLANATIONS.get(
        detected_class,
        _SCAN_CLASS_EXPLANATIONS["unknown"],
    )
    readable_class = detected_class.replace("_", " ").strip() or "unknown"
    confidence_percent = round(max(0.0, min(confidence_score, 1.0)) * 100)
    return (
        f"Hasil klasifikasi menunjukkan kategori {readable_class} "
        f"dengan confidence {confidence_percent}% dan level risiko {risk_level}. "
        f"{explanation}"
    )


def _build_scan_message_content(
    *,
    detected_class: str,
    confidence_score: float,
    risk_level: str,
) -> str:
    readable_class = detected_class.replace("_", " ").strip() or "unknown"
    confidence_percent = round(max(0.0, min(confidence_score, 1.0)) * 100)
    return (
        "Aku baru saja mengirim foto scan. "
        f"Hasil klasifikasi: {readable_class} ({confidence_percent}%). "
        f"Level risiko: {risk_level}."
    )


def _clean_optional(value: str | None) -> str | None:
    if value is None:
        return None

    cleaned = value.strip()
    return cleaned or None


def _persist_message(session_id: str, message: ChatMessage) -> ChatMessage:
    if not _chat_repository.is_available or not _is_uuid(session_id):
        return message

    db_message = _chat_repository.create_message(
        session_id=session_id,
        role=message.role,
        message_type=message.message_type,
        content=message.content,
        metadata={"source": "ask_ana"},
    )
    if message.cards:
        _chat_repository.create_cta_cards(
            message_id=str(db_message["id"]),
            cards=message.cards,
        )
    return _message_from_row(db_message, message.cards)


def _load_persisted_session(session_id: str) -> ChatSession | None:
    persisted = _chat_repository.get_session(session_id)
    if persisted is None:
        return None

    context = persisted["session"].get("initial_context") or {}
    session = ChatSession(
        id=str(persisted["session"]["id"]),
        session_type=context.get("session_type", "consultation"),
        assistant_name=context.get("assistant_name", "Si Ana"),
        messages=[
            _message_from_row(
                row,
                [
                    _card_from_row(card)
                    for card in persisted["cards_by_message_id"].get(str(row["id"]), [])
                ],
            )
            for row in persisted["messages"]
        ],
    )
    _cache_session(session, context)
    return session


def _message_from_row(row: dict, cards: list[ChatCtaCard] | None = None) -> ChatMessage:
    return ChatMessage(
        id=str(row["id"]),
        role=row["role"],
        message_type=row["message_type"],
        content=row["content"],
        created_at=row.get("sent_at") or _now(),
        cards=cards or [],
    )


def _card_from_row(row: dict) -> ChatCtaCard:
    return ChatCtaCard(
        card_type=row["card_type"],
        title=row["title"],
        description=row.get("description") or "",
        cta_label=row["cta_label"],
        target_route=row.get("target_route"),
        payload=row.get("payload") or {},
        display_order=row.get("display_order", 0),
    )


def _cache_session(session: ChatSession, context: dict) -> None:
    _sessions[session.id] = session
    _session_context[session.id] = context


def _new_id(prefix: str) -> str:
    return f"{prefix}_{uuid4().hex}"


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _is_uuid(value: str) -> bool:
    try:
        UUID(str(value))
    except (TypeError, ValueError):
        return False
    return True
