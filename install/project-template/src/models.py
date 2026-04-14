"""Task data models."""

import json
from datetime import datetime
from pathlib import Path

DATA_FILE = Path(__file__).parent.parent / "data" / "tasks.json"


class Task:
    def __init__(self, title, description="", priority="medium", status="todo"):
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.created_at = datetime.now().isoformat()
        self.completed_at = None

    def to_dict(self):
        return {
            "title": self.title,
            "description": self.description,
            "priority": self.priority,
            "status": self.status,
            "created_at": self.created_at,
            "completed_at": self.completed_at,
        }

    @classmethod
    def from_dict(cls, data):
        task = cls(
            title=data["title"],
            description=data.get("description", ""),
            priority=data.get("priority", "medium"),
            status=data.get("status", "todo"),
        )
        task.created_at = data.get("created_at", datetime.now().isoformat())
        task.completed_at = data.get("completed_at")
        return task

    def complete(self):
        self.status = "done"
        self.completed_at = datetime.now().isoformat()


class TaskStore:
    def __init__(self, path=None):
        self.path = path or DATA_FILE
        self.tasks = []
        self._load()

    def _load(self):
        if self.path.exists():
            with open(self.path, "r") as f:
                data = json.load(f)
                self.tasks = [Task.from_dict(t) for t in data]

    def _save(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.path, "w") as f:
            json.dump([t.to_dict() for t in self.tasks], f, indent=2)

    def add(self, task):
        self.tasks.append(task)
        self._save()
        return len(self.tasks) - 1

    def get(self, index):
        return self.tasks[index]

    def list_all(self):
        return self.tasks

    def list_by_status(self, status):
        return [t for t in self.tasks if t.status == status]

    def list_by_priority(self, priority):
        return [t for t in self.tasks if t.priority == priority]

    def complete_task(self, index):
        task = self.tasks[index]
        task.complete()
        self._save()

    def delete_task(self, index):
        self.tasks.pop(index)
        self._save()

    def search(self, query):
        query = query.lower()
        results = []
        for task in self.tasks:
            if query in task.title or query in task.description:
                results.append(task)
        return results

    def get_stats(self):
        total = len(self.tasks)
        done = len([t for t in self.tasks if t.status == "done"])
        in_progress = len([t for t in self.tasks if t.status == "in_progress"])
        todo = total - done - in_progress
        return {
            "total": total,
            "done": done,
            "in_progress": in_progress,
            "todo": todo,
            "completion_rate": done / total if total else 0,
        }
