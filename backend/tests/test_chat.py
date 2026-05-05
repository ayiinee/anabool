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


def test_start_scan_session_with_user_id_persists_to_repository(monkeypatch):
    from app.services import chat_service

    repository = FakeChatRepository()
    monkeypatch.setattr(chat_service, "_chat_repository", repository)

    response = client.post(
        "/api/v1/chats/sessions",
        json={
            "scan_id": "11111111-1111-1111-1111-111111111111",
            "user_id": "22222222-2222-2222-2222-222222222222",
        },
    )

    assert response.status_code == 200
    assert repository.sessions[0]["user_id"] == "22222222-2222-2222-2222-222222222222"
    assert repository.sessions[0]["session_type"] == "scan_result"
    assert [message["message_type"] for message in repository.messages] == [
        "scan_result",
        "text",
        "cta_cards",
    ]
    assert len(repository.cards) == 3


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


class FakeChatRepository:
    def __init__(self):
        self.sessions = []
        self.messages = []
        self.cards = []

    @property
    def is_available(self):
        return True

    def find_scan_user_id(self, scan_id):
        return None

    def create_session(
        self,
        *,
        user_id,
        session_type,
        scan_session_id=None,
        initial_context=None,
    ):
        self.sessions.append(
            {
                "user_id": user_id,
                "session_type": session_type,
                "scan_session_id": scan_session_id,
                "initial_context": initial_context,
            }
        )
        return {"id": "33333333-3333-3333-3333-333333333333"}

    def create_message(
        self,
        *,
        session_id,
        role,
        message_type,
        content,
        metadata=None,
    ):
        message_id = f"44444444-4444-4444-4444-44444444444{len(self.messages)}"
        self.messages.append(
            {
                "id": message_id,
                "session_id": session_id,
                "role": role,
                "message_type": message_type,
                "content": content,
                "metadata": metadata,
            }
        )
        return {
            "id": message_id,
            "role": role,
            "message_type": message_type,
            "content": content,
            "sent_at": "2026-05-05T00:00:00+00:00",
        }

    def create_cta_cards(self, *, message_id, cards):
        self.cards.extend(cards)
        return []

    def get_session(self, session_id):
        return None
