from datetime import datetime

from pydantic import BaseModel, Field


class ChatCtaCard(BaseModel):
    card_type: str
    title: str
    description: str
    cta_label: str


class ChatMessage(BaseModel):
    id: str
    role: str
    message_type: str
    content: str
    created_at: datetime
    cards: list[ChatCtaCard] = Field(default_factory=list)


class ChatSession(BaseModel):
    id: str
    session_type: str
    assistant_name: str
    messages: list[ChatMessage] = Field(default_factory=list)


class StartChatSessionRequest(BaseModel):
    scan_id: str | None = None


class SendChatMessageRequest(BaseModel):
    content: str

