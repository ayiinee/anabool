from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


ChatRole = Literal["user", "assistant"]
ChatMessageType = Literal["text", "cta_cards", "scan_result"]
ChatSessionType = Literal["consultation", "scan_result"]
ChatCardType = Literal["pickup", "process", "dispose"]


class ChatCtaCard(BaseModel):
    card_type: ChatCardType
    title: str
    description: str
    cta_label: str


class ChatMessage(BaseModel):
    id: str
    role: ChatRole
    message_type: ChatMessageType
    content: str
    cards: list[ChatCtaCard] = Field(default_factory=list)
    created_at: datetime


class ChatSession(BaseModel):
    id: str
    session_type: ChatSessionType
    assistant_name: str
    messages: list[ChatMessage]


class StartChatSessionRequest(BaseModel):
    session_type: ChatSessionType = "consultation"
    scan_id: str | None = None


class SendChatMessageRequest(BaseModel):
    content: str = Field(min_length=1, max_length=1200)
