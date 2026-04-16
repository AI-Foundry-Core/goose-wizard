"""Writes JSONL transcripts and extracts eval results from teacher output."""

import json
import re
from datetime import datetime, timezone
from pathlib import Path


class TranscriptWriter:
    """Collects teacher/student messages and writes a JSONL transcript."""

    def __init__(self, output_dir: Path, recipe: str, persona: str):
        self.output_dir = output_dir
        self.recipe = recipe
        self.persona = persona
        self._messages: list[dict] = []
        self._interaction = 0

    def add_teacher(self, content: str):
        self._messages.append({
            "role": "teacher",
            "content": content,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "interaction": self._interaction,
        })
        self._interaction += 1

    def add_student(self, content: str):
        self._messages.append({
            "role": "student",
            "content": content,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "interaction": self._interaction,
            "persona": self.persona,
        })
        self._interaction += 1

    def write(self):
        """Write the transcript to a JSONL file."""
        self.output_dir.mkdir(parents=True, exist_ok=True)
        path = self.output_dir / "transcript.jsonl"
        with open(path, "w", encoding="utf-8") as f:
            for msg in self._messages:
                f.write(json.dumps(msg, ensure_ascii=False) + "\n")
        return path

    def extract_eval_results(self) -> dict:
        """Scan teacher messages for eval dimension JSON blocks."""
        for msg in self._messages:
            if msg["role"] != "teacher":
                continue
            # Look for JSON blocks with "dimensions" key
            json_blocks = re.findall(r"\{[^{}]*\"dimensions\"[^{}]*\[.*?\]\s*\}", msg["content"], re.DOTALL)
            for block in json_blocks:
                try:
                    parsed = json.loads(block)
                    if "dimensions" in parsed:
                        return parsed
                except json.JSONDecodeError:
                    continue
        return {}

    @property
    def interaction_count(self) -> int:
        return self._interaction
