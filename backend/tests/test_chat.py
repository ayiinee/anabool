import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_start_session_returns_welcome_without_cta_cards():
    response = client.post("/api/v1/chats/sessions", json={})

    assert response.status_code == 200
    body = response.json()
    assert body["success"] is True

    session = body["data"]
    assert session["session_type"] == "consultation"
    assert session["assistant_name"] == "Si Ana"
    assert session["id"]
    assert session["messages"][0]["content"] == (
        "Halo! Aku Ana, asisten setiamu untuk menjaga kebersihan dan kesehatan anabul kesayangan. 🐾 "
        "Aku bisa bantu kasih tips bersihin litter box, info soal risiko Toxoplasma, sampai pilihan olah "
        "limbah yang aman. Ada yang bisa Ana bantu hari ini?"
    )
    assert not any(message["message_type"] == "cta_cards" for message in session["messages"])


def test_start_session_from_scan_returns_cta_cards():
    response = client.post("/api/v1/chats/sessions", json={"scan_id": "scan_test"})

    assert response.status_code == 200
    body = response.json()
    assert body["success"] is True

    session = body["data"]
    assert session["session_type"] == "scan_result"
    assert any(message["message_type"] == "scan_result" for message in session["messages"])
    assert any(message["message_type"] == "cta_cards" for message in session["messages"])


def test_send_message_uses_rag_response(monkeypatch):
    from app.services import chat_service

    monkeypatch.setattr(
        chat_service,
        "generate_ana_response",
        lambda *_args, **_kwargs: {
            "answer": "Jawaban RAG aman untuk user.",
            "provider": "fallback",
            "sources": ["Modul 1"],
            "retrieved_chunks": 2,
            "used_rag": True,
        },
    )

    session_id = _start_session_id()
    response = client.post(
        f"/api/v1/chats/{session_id}/messages",
        json={"content": "Bagaimana risiko toxoplasma?"},
    )

    assert response.status_code == 200
    answer = _latest_assistant_text(response.json()["data"])
    assert "Jawaban RAG aman untuk user." in answer
    assert "Sumber rujukan: Modul 1" in answer


def test_unknown_session_returns_404():
    response = client.post(
        "/api/v1/chats/chat_missing/messages",
        json={"content": "Halo"},
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Chat session not found"


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
