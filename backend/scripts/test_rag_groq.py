import argparse
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.append(str(ROOT_DIR))

from app.ai.rag.rag_chain import generate_ana_response
from app.db.repositories.rag_repository import get_rag_status


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("question")
    args = parser.parse_args()

    status = get_rag_status()
    print(f"RAG status: {status}")

    result = generate_ana_response(args.question)
    print(f"Provider: {result['provider']}")
    print(f"Used RAG: {result['used_rag']}")
    print(f"Retrieved chunks: {result['retrieved_chunks']}")
    print(f"Sources: {result['sources']}")
    print("\nAnswer:\n")
    print(result["answer"])


if __name__ == "__main__":
    main()
