from uuid import UUID

from app.db.schemas.chat_schema import ChatCtaCard
from app.integrations.supabase.supabase_client import get_supabase_service_client


class ChatRepository:
    def __init__(self):
        self._client = get_supabase_service_client()

    @property
    def is_available(self) -> bool:
        return self._client is not None

    def find_scan_user_id(self, scan_id: str) -> str | None:
        if self._client is None or not _is_uuid(scan_id):
            return None

        response = (
            self._client.table("scan_sessions")
            .select("user_id")
            .eq("id", scan_id)
            .limit(1)
            .execute()
        )
        if not response.data:
            return None
        return str(response.data[0]["user_id"])

    def create_session(
        self,
        *,
        user_id: str,
        session_type: str,
        scan_session_id: str | None = None,
        initial_context: dict | None = None,
    ) -> dict:
        if self._client is None:
            raise RuntimeError("Supabase client is not configured.")

        payload = {
            "user_id": user_id,
            "initial_context": {
                "session_type": session_type,
                "assistant_name": "Si Ana",
                **(initial_context or {}),
            },
        }
        if scan_session_id and _is_uuid(scan_session_id):
            payload["scan_session_id"] = scan_session_id

        response = self._client.table("chat_sessions").insert(payload).execute()
        return response.data[0]

    def create_message(
        self,
        *,
        session_id: str,
        role: str,
        message_type: str,
        content: str,
        metadata: dict | None = None,
    ) -> dict:
        if self._client is None:
            raise RuntimeError("Supabase client is not configured.")

        response = (
            self._client.table("chat_messages")
            .insert(
                {
                    "session_id": session_id,
                    "role": role,
                    "message_type": message_type,
                    "content": content,
                    "metadata": metadata or {},
                }
            )
            .execute()
        )
        return response.data[0]

    def create_cta_cards(
        self,
        *,
        message_id: str,
        cards: list[ChatCtaCard],
    ) -> list[dict]:
        if self._client is None or not cards:
            return []

        payload = [
            {
                "message_id": message_id,
                "card_type": card.card_type,
                "title": card.title,
                "description": card.description,
                "cta_label": card.cta_label,
                "target_route": card.target_route,
                "payload": card.payload,
                "display_order": index,
            }
            for index, card in enumerate(cards)
        ]
        response = self._client.table("chat_cta_cards").insert(payload).execute()
        return response.data or []

    def get_session(self, session_id: str) -> dict | None:
        if self._client is None or not _is_uuid(session_id):
            return None

        session_response = (
            self._client.table("chat_sessions")
            .select("*")
            .eq("id", session_id)
            .limit(1)
            .execute()
        )
        if not session_response.data:
            return None

        messages_response = (
            self._client.table("chat_messages")
            .select("*")
            .eq("session_id", session_id)
            .order("sent_at")
            .execute()
        )
        messages = messages_response.data or []
        message_ids = [message["id"] for message in messages]
        cards_by_message_id: dict[str, list[dict]] = {}
        if message_ids:
            cards_response = (
                self._client.table("chat_cta_cards")
                .select("*")
                .in_("message_id", message_ids)
                .order("display_order")
                .execute()
            )
            for card in cards_response.data or []:
                cards_by_message_id.setdefault(str(card["message_id"]), []).append(card)

        return {
            "session": session_response.data[0],
            "messages": messages,
            "cards_by_message_id": cards_by_message_id,
        }


def _is_uuid(value: str) -> bool:
    try:
        UUID(str(value))
    except (TypeError, ValueError):
        return False
    return True
