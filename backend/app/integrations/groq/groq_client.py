from app.core.config import settings


def get_groq_client():
    if not settings.GROQ_API_KEY:
        raise RuntimeError("GROQ_API_KEY is not configured")

    try:
        from groq import Groq
    except ImportError as exc:
        raise RuntimeError(
            "groq package is not installed. Install backend requirements first."
        ) from exc

    return Groq(api_key=settings.GROQ_API_KEY)


def generate_groq_response(
    messages: list[dict],
    *,
    temperature: float = 0.2,
    max_tokens: int = 700,
) -> str:
    client = get_groq_client()

    completion = client.chat.completions.create(
        model=settings.GROQ_CHAT_MODEL,
        messages=messages,
        temperature=temperature,
        max_completion_tokens=max_tokens,
    )

    return completion.choices[0].message.content or ""
