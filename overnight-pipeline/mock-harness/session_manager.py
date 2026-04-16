"""Manages isolated temp directories for mock training sessions."""

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

try:
    from .config import GOOSE_WIZARD_ROOT
except ImportError:
    from config import GOOSE_WIZARD_ROOT


class SessionEnvironment:
    """An isolated environment for one mock training session.

    Creates a temp directory tree that mimics what a real user has:
      temp_root/
        goose-wizard/           # Mock ~/goose-wizard with fresh state
          progression.json
          user_config.json
        target-codebase/        # Copy of project template, git-initialized
    """

    def __init__(self, recipe: str, persona_name: str):
        self.recipe = recipe
        self.persona_name = persona_name
        self._temp_dir = tempfile.mkdtemp(
            prefix=f"gw-mock-{persona_name}-"
        )
        self.root = Path(self._temp_dir)
        self.mock_goose_wizard = self.root / "goose-wizard"
        self.target_codebase = self.root / "target-codebase"
        self._setup_done = False

    def setup(self):
        """Create the isolated directory tree."""
        self.mock_goose_wizard.mkdir(parents=True)
        self.target_codebase.mkdir(parents=True)

        # Copy fresh progression.json
        src_progression = (
            GOOSE_WIZARD_ROOT
            / "install"
            / "project-template"
            / ".goose"
            / "state"
            / "progression.json"
        )
        if src_progression.exists():
            shutil.copy2(src_progression, self.mock_goose_wizard / "progression.json")

        # Write user_config.json pointing to the target codebase
        config_path = self.mock_goose_wizard / "user_config.json"
        config_path.write_text(
            f'{{\n'
            f'  "target_codebase_path": "{self.target_codebase.as_posix()}",\n'
            f'  "captured_at": "2026-01-01T00:00:00Z"\n'
            f'}}\n',
            encoding="utf-8",
        )

        # Copy the project template as the target codebase
        template_dir = GOOSE_WIZARD_ROOT / "install" / "project-template"
        if template_dir.exists():
            shutil.copytree(template_dir, self.target_codebase, dirs_exist_ok=True)

        # Initialize git in the target codebase (recipes expect git)
        subprocess.run(
            ["git", "init"],
            cwd=str(self.target_codebase),
            capture_output=True,
        )
        subprocess.run(
            ["git", "add", "."],
            cwd=str(self.target_codebase),
            capture_output=True,
        )
        subprocess.run(
            ["git", "commit", "-m", "Initial commit"],
            cwd=str(self.target_codebase),
            capture_output=True,
            env={**os.environ, "GIT_AUTHOR_NAME": "Test", "GIT_AUTHOR_EMAIL": "test@test.com",
                 "GIT_COMMITTER_NAME": "Test", "GIT_COMMITTER_EMAIL": "test@test.com"},
        )

        self._setup_done = True

    def get_env(self) -> dict:
        """Return environment variables for subprocesses in this session.

        Overrides HOME/USERPROFILE so ~/goose-wizard/ resolves to mock dir.
        """
        env = os.environ.copy()
        env["USERPROFILE"] = str(self.root)  # Windows
        env["HOME"] = str(self.root)  # Unix
        # Keep GOOSE_RECIPE_PATH pointing to real recipes
        env["GOOSE_RECIPE_PATH"] = str(GOOSE_WIZARD_ROOT / "recipes" / "shared")
        return env

    def get_progression(self) -> dict:
        """Read the mock progression.json after a session completes."""
        import json
        prog_path = self.mock_goose_wizard / "progression.json"
        if prog_path.exists():
            return json.loads(prog_path.read_text(encoding="utf-8"))
        return {}

    def cleanup(self):
        """Remove the temp directory tree."""
        shutil.rmtree(self._temp_dir, ignore_errors=True)

    def __enter__(self):
        self.setup()
        return self

    def __exit__(self, *args):
        self.cleanup()
