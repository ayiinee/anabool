from dataclasses import dataclass


@dataclass(slots=True)
class TextChunk:
    chunk_index: int
    content: str
    metadata: dict


def split_text_into_chunks(
    text: str,
    *,
    max_chars: int = 900,
    overlap_chars: int = 120,
    base_metadata: dict | None = None,
) -> list[TextChunk]:
    cleaned_text = text.strip()
    if not cleaned_text:
        return []

    if max_chars <= 0:
        raise ValueError("max_chars must be greater than zero")

    if overlap_chars < 0:
        raise ValueError("overlap_chars cannot be negative")

    base_metadata = base_metadata or {}
    paragraphs = [paragraph.strip() for paragraph in cleaned_text.split("\n\n") if paragraph.strip()]

    chunks: list[TextChunk] = []
    current_parts: list[str] = []
    current_length = 0

    for paragraph in paragraphs:
        paragraph_length = len(paragraph)
        separator_length = 2 if current_parts else 0

        if current_parts and current_length + separator_length + paragraph_length > max_chars:
            chunks.append(
                _build_chunk(
                    chunk_index=len(chunks),
                    parts=current_parts,
                    base_metadata=base_metadata,
                )
            )
            current_parts = _carry_overlap_parts(current_parts, overlap_chars)
            current_length = _joined_length(current_parts)

        if paragraph_length > max_chars:
            if current_parts:
                chunks.append(
                    _build_chunk(
                        chunk_index=len(chunks),
                        parts=current_parts,
                        base_metadata=base_metadata,
                    )
                )
                current_parts = []
                current_length = 0

            for piece in _split_long_paragraph(paragraph, max_chars=max_chars, overlap_chars=overlap_chars):
                chunks.append(
                    _build_chunk(
                        chunk_index=len(chunks),
                        parts=[piece],
                        base_metadata=base_metadata,
                    )
                )
            continue

        current_parts.append(paragraph)
        current_length = _joined_length(current_parts)

    if current_parts:
        chunks.append(
            _build_chunk(
                chunk_index=len(chunks),
                parts=current_parts,
                base_metadata=base_metadata,
            )
        )

    return chunks


def _build_chunk(*, chunk_index: int, parts: list[str], base_metadata: dict) -> TextChunk:
    content = "\n\n".join(parts).strip()
    metadata = dict(base_metadata)
    metadata["chunk_index"] = chunk_index
    metadata["char_count"] = len(content)
    metadata["preview"] = content[:160]
    return TextChunk(
        chunk_index=chunk_index,
        content=content,
        metadata=metadata,
    )


def _carry_overlap_parts(parts: list[str], overlap_chars: int) -> list[str]:
    if overlap_chars == 0 or not parts:
        return []

    kept_parts: list[str] = []
    collected_length = 0

    for paragraph in reversed(parts):
        kept_parts.insert(0, paragraph)
        collected_length = _joined_length(kept_parts)
        if collected_length >= overlap_chars:
            break

    return kept_parts


def _split_long_paragraph(paragraph: str, *, max_chars: int, overlap_chars: int) -> list[str]:
    words = paragraph.split()
    if not words:
        return []

    pieces: list[str] = []
    current_words: list[str] = []

    for word in words:
        candidate_words = [*current_words, word]
        if current_words and len(" ".join(candidate_words)) > max_chars:
            pieces.append(" ".join(current_words))
            current_words = _carry_overlap_words(current_words, overlap_chars)
        current_words.append(word)

    if current_words:
        pieces.append(" ".join(current_words))

    return pieces


def _carry_overlap_words(words: list[str], overlap_chars: int) -> list[str]:
    if overlap_chars == 0 or not words:
        return []

    kept_words: list[str] = []
    for word in reversed(words):
        kept_words.insert(0, word)
        if len(" ".join(kept_words)) >= overlap_chars:
            break

    return kept_words


def _joined_length(parts: list[str]) -> int:
    return len("\n\n".join(parts))
