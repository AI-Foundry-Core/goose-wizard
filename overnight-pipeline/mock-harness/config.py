"""Configuration dataclasses for the mock training harness."""

from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional
import json


@dataclass
class EdgeCaseTrigger:
    interaction: int
    edge_case: str


@dataclass
class SessionConfig:
    recipe: str
    persona_name: str
    persona_text: str
    edge_cases: dict[int, str] = field(default_factory=dict)
    max_interactions: int = 15
    wait_timeout_seconds: float = 8.0
    session_timeout_seconds: float = 600.0


@dataclass
class RunConfig:
    recipes: list[str]
    personas: list[str]  # "all" or specific names
    edge_case_schedule: dict  # recipe -> persona -> EdgeCaseTrigger
    parallel_workers: int = 3
    max_interactions: int = 15
    wait_timeout_seconds: float = 8.0
    session_timeout_seconds: float = 600.0
    target_codebase_template: str = "install/project-template"
    output_dir: str = "overnight-pipeline/results"

    @classmethod
    def from_file(cls, path: Path) -> "RunConfig":
        data = json.loads(path.read_text(encoding="utf-8"))
        return cls(**data)


@dataclass
class SessionResult:
    recipe: str
    persona: str
    status: str  # "pass", "fail", "error", "timeout"
    interaction_count: int = 0
    duration_seconds: float = 0.0
    progression_updated: bool = False
    graduation_succeeded: bool = False
    errors: list[str] = field(default_factory=list)
    transcript_path: Optional[str] = None
    eval_dimensions: dict = field(default_factory=dict)


# Root of the goose-wizard repo
GOOSE_WIZARD_ROOT = Path(__file__).resolve().parent.parent.parent
