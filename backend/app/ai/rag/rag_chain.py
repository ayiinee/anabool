from app.ai.rag.knowledge_loader import load_mock_knowledge


def retrieve_relevant_knowledge(detected_class: str) -> list[dict]:
    return load_mock_knowledge(detected_class)