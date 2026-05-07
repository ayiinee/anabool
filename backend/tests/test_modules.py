import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))

from fastapi.testclient import TestClient

from app.api.v1.endpoints import education_routes
from app.db.schemas.module_schema import ModuleProgress
from app.main import app
from app.services.education_service import EducationService
from app.services.module_service import ModuleService


client = TestClient(app)


def test_module_progress_uses_completed_step_count():
    progress = ModuleProgress.from_step_rows(
        module_id="module-1",
        user_id="user-1",
        total_steps=4,
        step_order_by_id={
            "step-1": 1,
            "step-2": 2,
            "step-3": 3,
            "step-4": 4,
        },
        progress_rows=[
            {"step_id": "step-1", "is_completed": True},
            {"step_id": "step-2", "is_completed": True},
            {"step_id": "step-2", "is_completed": True},
            {"step_id": "step-3", "is_completed": False},
        ],
    )

    assert progress.completed_steps == 2
    assert progress.total_steps == 4
    assert progress.progress_pct == 50.0
    assert progress.current_step_order == 3
    assert progress.is_completed is False


def test_module_progress_handles_zero_total_steps():
    progress = ModuleProgress.from_step_rows(
        module_id="module-empty",
        total_steps=0,
        step_order_by_id={},
        progress_rows=[{"step_id": "missing-step", "is_completed": True}],
    )

    assert progress.completed_steps == 1
    assert progress.total_steps == 0
    assert progress.progress_pct == 0.0
    assert progress.current_step_order == 0
    assert progress.is_completed is False


def test_education_route_returns_recalculated_progress(monkeypatch):
    repository = FakeModuleRepository()
    monkeypatch.setattr(
        education_routes,
        "_service",
        EducationService(ModuleService(repository)),
    )

    response = client.get("/api/v1/education", params={"user_id": "user-1"})

    assert response.status_code == 200
    body = response.json()
    assert body["success"] is True

    module = body["data"]["modules"][0]
    assert module["id"] == "module-1"
    assert module["progress"]["completed_steps"] == 2
    assert module["progress"]["total_steps"] == 4
    assert module["progress"]["progress_pct"] == 50.0
    assert module["progress"]["current_step_order"] == 3


class FakeModuleRepository:
    def list_modules(self):
        return [
            {
                "id": "module-1",
                "category": "safety",
                "poop_type": None,
                "title": "Memahami Toxoplasma gondii",
                "summary": "Ringkasan modul.",
                "content_json": {},
                "slug": "memahami-toxoplasma-gondii",
                "meowpoints_reward": 25,
                "estimated_duration_minutes": 8,
                "updated_at": None,
            }
        ]

    def list_steps_by_module(self, module_ids):
        return {
            "module-1": [
                self._step("step-1", 1),
                self._step("step-2", 2),
                self._step("step-3", 3),
                self._step("step-4", 4),
            ]
        }

    def list_progress_by_module(self, *, user_id, module_ids):
        return {
            "module-1": [
                {
                    "module_id": "module-1",
                    "step_id": "step-1",
                    "is_completed": True,
                },
                {
                    "module_id": "module-1",
                    "step_id": "step-2",
                    "is_completed": True,
                },
                {
                    "module_id": "module-1",
                    "step_id": "step-3",
                    "is_completed": False,
                },
            ]
        }

    def _step(self, step_id, order):
        return {
            "id": step_id,
            "module_id": "module-1",
            "step_order": order,
            "step_key": f"step-{order}",
            "title": f"Step {order}",
            "instruction": f"Instruction {order}",
            "image_url": None,
            "video_url": None,
            "safety_note": None,
            "meowpoints_granted": 0,
        }
