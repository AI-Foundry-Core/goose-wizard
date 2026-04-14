"""Basic tests for the task tracker. Intentionally incomplete —
good material for the Test Writer training module."""

import json
import tempfile
from pathlib import Path
from src.models import Task, TaskStore


def test_create_task():
    task = Task("Buy groceries", description="Milk, eggs, bread")
    assert task.title == "Buy groceries"
    assert task.description == "Milk, eggs, bread"
    assert task.status == "todo"
    assert task.priority == "medium"


def test_complete_task():
    task = Task("Write report")
    task.complete()
    assert task.status == "done"
    assert task.completed_at is not None


def test_task_to_dict():
    task = Task("Test task", priority="high")
    d = task.to_dict()
    assert d["title"] == "Test task"
    assert d["priority"] == "high"
    assert d["status"] == "todo"


def test_task_from_dict():
    data = {"title": "Loaded task", "priority": "low", "status": "in_progress"}
    task = Task.from_dict(data)
    assert task.title == "Loaded task"
    assert task.priority == "low"
    assert task.status == "in_progress"


def test_store_add_and_list():
    with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as f:
        path = Path(f.name)
    try:
        store = TaskStore(path)
        store.add(Task("Task 1"))
        store.add(Task("Task 2"))
        assert len(store.list_all()) == 2
    finally:
        path.unlink(missing_ok=True)


def test_store_persistence():
    with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as f:
        path = Path(f.name)
    try:
        store = TaskStore(path)
        store.add(Task("Persistent task"))

        # Reload from disk
        store2 = TaskStore(path)
        assert len(store2.list_all()) == 1
        assert store2.list_all()[0].title == "Persistent task"
    finally:
        path.unlink(missing_ok=True)


# NOTE: Missing tests for:
# - search functionality
# - delete functionality
# - list_by_status / list_by_priority
# - get_stats
# - edge cases (empty store, invalid index, etc.)
# - formatting module (completely untested)
