import argparse
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.append(str(ROOT_DIR))

from app.ai.rag.retriever import retrieve_relevant_knowledge
from app.db.repositories.rag_repository import get_rag_status


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("query")
    parser.add_argument("--top-k", type=int, default=4)
    parser.add_argument("--threshold", type=float, default=None)
    args = parser.parse_args()

    status = get_rag_status()
    print(f"RAG status: {status}")

    result = retrieve_relevant_knowledge(
        args.query,
        match_count=args.top_k,
        match_threshold=args.threshold,
    )

    if not result.chunks:
        print("No matching chunks found.")
        return

    for index, chunk in enumerate(result.chunks, start=1):
        print(f"\n[{index}] {chunk.title} | similarity={chunk.similarity:.3f}")
        print(chunk.content[:500])


if __name__ == "__main__":
    main()
