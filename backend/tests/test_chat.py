import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_start_session_returns_welcome_and_cta_cards():
    response = client.post("/api/v1/chats/sessions", json={})

    assert response.status_code == 200
    body = response.json()
    assert body["success"] is True

    session = body["data"]
    assert session["session_type"] == "consultation"
    assert session["assistant_name"] == "Si Ana"
    assert session["id"]
    assert any(message["message_type"] == "cta_cards" for message in session["messages"])

    cta_message = next(
        message for message in session["messages"] if message["message_type"] == "cta_cards"
    )
    assert [card["card_type"] for card in cta_message["cards"]] == [
        "pickup",
        "process",
        "dispose",
    ]


def test_topic_answers_are_guarded():
    session_id = _start_session_id()
    topics = [
        "Bagaimana cara membersihkan litter box?",
        "Bagaimana packing limbahnya?",
        "Apakah ada risiko toksoplasma untuk ibu hamil?",
        "Kapan harus ke dokter hewan?",
        "Saya pilih Pick Up",
        "Saya mau Olah limbah",
        "Bagaimana cara Buang yang aman?",
    ]

    for question in topics:
        response = client.post(
            f"/api/v1/chats/{session_id}/messages",
            json={"content": question},
        )
        assert response.status_code == 200
        answer = _latest_assistant_text(response.json()["data"])
        _assert_guardrails(answer)


def test_unsafe_medical_question_does_not_return_diagnosis_or_prescription():
    session_id = _start_session_id()

    response = client.post(
        f"/api/v1/chats/{session_id}/messages",
        json={"content": "Diagnosis penyakitnya apa dan obat apa yang harus diberikan?"},
    )

    assert response.status_code == 200
    answer = _latest_assistant_text(response.json()["data"])
    lowered = answer.lower()
    assert "tidak memberi diagnosis pasti" in lowered
    assert "tidak meresepkan obat" in lowered
    assert "tidak membuat klaim deteksi parasit" in lowered
    assert "berikan metronidazole" not in lowered
    assert "resep" not in lowered.replace("tidak meresepkan obat", "")
    _assert_guardrails(answer)


def test_unknown_question_returns_safe_fallback():
    session_id = _start_session_id()

    response = client.post(
        f"/api/v1/chats/{session_id}/messages",
        json={"content": "Apa warna pasir yang paling lucu?"},
    )

    assert response.status_code == 200
    answer = _latest_assistant_text(response.json()["data"])
    assert "belum bisa menangkap pertanyaan" in answer.lower()
    _assert_guardrails(answer)


def _start_session_id() -> str:
    response = client.post("/api/v1/chats/sessions", json={})
    assert response.status_code == 200
    return response.json()["data"]["id"]


def _latest_assistant_text(session: dict) -> str:
    assistant_texts = [
        message["content"]
        for message in session["messages"]
        if message["role"] == "assistant" and message["message_type"] == "text"
    ]
    assert assistant_texts
    return assistant_texts[-1]


def _assert_guardrails(answer: str):
    lowered = answer.lower()
    assert "tidak memberi diagnosis pasti" in lowered
    assert "tidak meresepkan obat" in lowered
    assert "tidak membuat klaim deteksi parasit" in lowered
    assert "sarung tangan" in lowered
    assert "red flags" in lowered
    assert "dokter hewan" in lowered
    assert "jangan flush" in lowered
    assert "toilet" in lowered
