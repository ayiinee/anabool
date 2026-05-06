from typing import Any

from pydantic import BaseModel, Field


class ModuleProgress(BaseModel):
    current_step_order: int = 0
    completed_steps: int = 0
    total_steps: int = 0
    progress_pct: float = 0.0
    is_completed: bool = False
    points_claimed: bool = False
    can_complete: bool = False


class ModuleSummary(BaseModel):
    id: str
    slug: str
    category: str
    poop_type: str | None = None
    title: str
    summary: str
    overview: Any = Field(default_factory=dict)
    thumbnail_url: str | None = None
    reward_points: int = 0
    estimated_duration_minutes: int = 0
    route: str
    progress: ModuleProgress


class ModuleStep(BaseModel):
    id: str
    step_order: int
    step_key: str
    title: str
    instruction: str
    image_url: str | None = None
    video_url: str | None = None
    safety_note: str | None = None
    meowpoints_granted: int = 0
    is_completed: bool = False
    is_locked: bool = False


class ModuleDetail(ModuleSummary):
    steps: list[ModuleStep] = Field(default_factory=list)


class ModuleCatalog(BaseModel):
    modules: list[ModuleSummary] = Field(default_factory=list)


class ModuleStepCompleteResult(BaseModel):
    module_id: str
    step_id: str
    step_order: int
    progress: ModuleProgress
    points_awarded: int = 0


class ModuleCompleteResult(BaseModel):
    module_id: str
    progress: ModuleProgress
    points_awarded: int = 0
    meowpoints_balance: int | None = None
