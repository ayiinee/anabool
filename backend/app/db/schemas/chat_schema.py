from datetime import datetime

from pydantic import BaseModel, Field


class ChatCtaCard(BaseModel):
    card_type: str
    title: str
    description: str
    cta_label: str
    target_route: str | None = None
    payload: dict = Field(default_factory=dict)
    display_order: int = 0


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
    detected_class: str | None = None
    confidence_score: float | None = None
    risk_level: str | None = None
    filename: str | None = None
    # MVP placeholder until all chat routes require Firebase auth.
    user_id: str | None = None


class SendChatMessageRequest(BaseModel):
    content: str
