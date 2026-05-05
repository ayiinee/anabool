import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_list_modules_maps_ingested_rag_documents(monkeypatch):
    from app.services import module_service

    monkeypatch.setattr(module_service, "_module_repository", FakeModuleRepository())

    response = client.get("/api/v1/modules")

    assert response.status_code == 200
    body = response.json()
    assert body["success"] is True
    assert body["data"]["categories"][0]["slug"] == "rag-modules"
    assert body["data"]["contents"][0]["title"] == (
        "Modul 1 Memahami Toxoplasma Gondii"
    )
    assert body["data"]["contents"][0]["category_slug"] == "rag-modules"


def test_get_module_detail_uses_rag_chunk_content(monkeypatch):
    from app.services import module_service

    monkeypatch.setattr(module_service, "_module_repository", FakeModuleRepository())

    response = client.get("/api/v1/modules/doc-1")

    assert response.status_code == 200
    content = response.json()["data"]
    assert "Toxoplasma gondii adalah parasit" in content["body"]
    assert content["summary"].startswith("Ringkasan modul dari metadata")


class FakeModuleRepository:
    def list_rag_modules(self):
        return [
            {
                "id": "doc-1",
                "title": "Modul 1 Memahami Toxoplasma Gondii",
                "source_type": "module",
                "content_url": None,
                "is_active": True,
            }
        ]

    def get_rag_module(self, module_id):
        if module_id != "doc-1":
            return None
        return self.list_rag_modules()[0]

    def list_rag_chunks(self, document_id):
        return [
            {
                "chunk_index": 0,
                "content": "Toxoplasma gondii adalah parasit yang perlu dicegah.",
                "metadata": {"preview": "Ringkasan modul dari metadata."},
            },
            {
                "chunk_index": 1,
                "content": "Gunakan sarung tangan saat membersihkan litter box.",
                "metadata": {},
            },
        ]
