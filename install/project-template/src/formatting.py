"""Output formatting utilities for the task tracker.

This module has some code quality issues that make it a good candidate
for code review and refactoring exercises.
"""


def format_task_table(tasks):
    """Format tasks as a text table."""
    if not tasks:
        return "No tasks."

    # Build header
    header = "| # | Status | Priority | Title |"
    separator = "|---|--------|----------|-------|"
    rows = [header, separator]

    for i, task in enumerate(tasks):
        # Duplicate logic from cli.py — could be shared
        status_icon = {"todo": "TODO", "in_progress": "WIP", "done": "DONE"}
        icon = status_icon.get(task.status, "???")
        priority_label = {"high": "HIGH", "medium": "MED", "low": "LOW"}
        pri = priority_label.get(task.priority, "???")
        rows.append(f"| {i} | {icon} | {pri} | {task.title} |")

    return "\n".join(rows)


def format_task_detail(task):
    """Format a single task with full details."""
    lines = []
    lines.append(f"Title: {task.title}")
    lines.append(f"Status: {task.status}")
    lines.append(f"Priority: {task.priority}")
    if task.description:
        lines.append(f"Description: {task.description}")
    lines.append(f"Created: {task.created_at}")
    if task.completed_at:
        lines.append(f"Completed: {task.completed_at}")
    return "\n".join(lines)


def format_stats_report(stats):
    """Format stats as a report. Has a bug with percentage formatting."""
    report = []
    report.append("=== Task Statistics ===")
    report.append(f"Total tasks: {stats['total']}")
    report.append(f"Completed:   {stats['done']}")
    report.append(f"In Progress: {stats['in_progress']}")
    report.append(f"Todo:        {stats['todo']}")
    report.append("")

    # Bug: doesn't handle zero total correctly in the bar
    pct = int(stats["completion_rate"] * 100)
    bar_filled = "#" * pct
    bar_empty = "-" * (100 - pct)
    report.append(f"Progress: [{bar_filled}{bar_empty}] {pct}%")

    return "\n".join(report)


def colorize(text, color):
    """Add ANSI color to text. Doesn't check if terminal supports it."""
    colors = {
        "red": "\033[91m",
        "green": "\033[92m",
        "yellow": "\033[93m",
        "blue": "\033[94m",
        "reset": "\033[0m",
    }
    if color in colors:
        return f"{colors[color]}{text}{colors['reset']}"
    return text


def truncate(text, max_length=50):
    """Truncate text with ellipsis. Has an off-by-one."""
    if len(text) <= max_length:
        return text
    return text[:max_length - 2] + ".."
