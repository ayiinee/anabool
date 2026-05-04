from datetime import datetime, timezone
from uuid import uuid4

from app.db.schemas.chat_schema import ChatCtaCard, ChatMessage, ChatSession


_sessions: dict[str, ChatSession] = {}

_CTA_CARDS = [
    ChatCtaCard(
        card_type="pickup",
        title="Pick Up",
        description="Panduan menyiapkan limbah kucing untuk penjemputan aman.",
        cta_label="Jadwalkan Pick-up",
    ),
    ChatCtaCard(
        card_type="process",
        title="Olah",
        description="Langkah awal mengolah limbah tanpa kontak langsung.",
        cta_label="Lihat Cara Olah",
    ),
    ChatCtaCard(
        card_type="dispose",
        title="Buang",
        description="Cara membuang limbah kucing dengan kantong tertutup.",
        cta_label="Lihat Cara Buang",
    ),
]

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


def start_consultation_chat() -> ChatSession:
    session = ChatSession(
        id=_new_id("chat"),
        session_type="consultation",
        assistant_name="Si Ana",
        messages=[
            _assistant_text(
                "Halo, aku Si Ana. Aku bisa bantu menjelaskan pembersihan litter box, pengemasan limbah, "
                "risiko Toxoplasma, tanda perlu ke dokter hewan, dan pilihan Pick Up, Olah, atau Buang.\n\n"
                f"{_GUARDRAILS}"
            ),
            _assistant_cta_cards(),
        ],
    )
    _sessions[session.id] = session
    return session


def send_chat_message(session_id: str, content: str) -> ChatSession:
    session = _sessions.get(session_id)
    if session is None:
        raise KeyError(session_id)

    session.messages.append(
        ChatMessage(
            id=_new_id("msg"),
            role="user",
            message_type="text",
            content=content.strip(),
            created_at=_now(),
        )
    )
    session.messages.append(_assistant_text(_build_answer(content)))
    return session


def mock_start_chat_from_scan(scan_id: str) -> dict:
    session = start_consultation_chat()
    session.session_type = "scan_result"
    session.messages.insert(
        0,
        ChatMessage(
            id=_new_id("msg"),
            role="user",
            message_type="scan_result",
            content="Ini hasil scan feses/litter yang baru saja diambil.",
            created_at=_now(),
        ),
    )

    result = session.model_dump(mode="json")
    result["scan_id"] = scan_id
    return result


def _build_answer(content: str) -> str:
    topic = _detect_topic(content)
    return f"{_GUIDELINES[topic]}\n\n{_GUARDRAILS}"


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
        content="Pilih tindakan yang ingin kamu bahas.",
        cards=_CTA_CARDS,
        created_at=_now(),
    )


def _new_id(prefix: str) -> str:
    return f"{prefix}_{uuid4().hex}"


def _now() -> datetime:
    return datetime.now(timezone.utc)
