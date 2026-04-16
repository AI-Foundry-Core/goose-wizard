"""Calls the mock-student Goose recipe to generate one student response."""

import subprocess
from pathlib import Path

try:
    from .config import GOOSE_WIZARD_ROOT
except ImportError:
    from config import GOOSE_WIZARD_ROOT


def call_mock_student(
    persona_text: str,
    conversation_history: str,
    teacher_message: str,
    context_dir: Path,
    edge_case: str = "",
    interaction_number: int = 1,
    total_estimate: int = 8,
    timeout: float = 120.0,
) -> str:
    """Call the mock-student recipe and return the student's response.

    Writes context to a temp file (avoids shell escaping issues with
    long text in --params) and passes the file path to the recipe.
    """
    # Write context to a file the student recipe will read
    context_file = context_dir / "student_context.md"
    context_file.write_text(
        f"# PERSONA\n{persona_text}\n\n"
        f"# CONVERSATION HISTORY\n{conversation_history}\n\n"
        f"# TEACHER'S LATEST MESSAGE\n{teacher_message}\n\n"
        f"# EDGE CASE\n{edge_case or 'None'}\n\n"
        f"# INTERACTION NUMBER\n{interaction_number}\n\n"
        f"# TOTAL ESTIMATE\n{total_estimate}\n",
        encoding="utf-8",
    )

    recipe_path = GOOSE_WIZARD_ROOT / "overnight-pipeline" / "mock-student.yaml"

    result = subprocess.run(
        [
            "goose",
            "run",
            "--recipe",
            str(recipe_path),
            "--no-session",
            "--quiet",
            f"--params=context_file={context_file.as_posix()}",
        ],
        capture_output=True,
        text=True,
        timeout=timeout,
        cwd=str(GOOSE_WIZARD_ROOT),
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"Mock student failed (rc={result.returncode}): {result.stderr[:500]}"
        )

    return result.stdout.strip()
