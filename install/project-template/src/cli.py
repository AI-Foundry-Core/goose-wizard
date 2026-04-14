"""Command-line interface for the task tracker."""

import sys
from .models import Task, TaskStore


def print_task(task, index=None):
    prefix = f"[{index}] " if index is not None else ""
    status_icon = {"todo": " ", "in_progress": "~", "done": "x"}
    icon = status_icon.get(task.status, "?")
    priority_label = {"high": "!!!", "medium": "!!", "low": "!"}
    pri = priority_label.get(task.priority, "")
    print(f"  {prefix}[{icon}] {task.title} {pri}")
    if task.description:
        print(f"       {task.description}")


def cmd_add(store, args):
    if not args:
        print("Usage: add <title> [--priority high|medium|low] [--desc description]")
        return

    title_parts = []
    priority = "medium"
    description = ""
    i = 0
    while i < len(args):
        if args[i] == "--priority" and i + 1 < len(args):
            priority = args[i + 1]
            i += 2
        elif args[i] == "--desc" and i + 1 < len(args):
            description = args[i + 1]
            i += 2
        else:
            title_parts.append(args[i])
            i += 1

    title = " ".join(title_parts)
    task = Task(title, description=description, priority=priority)
    idx = store.add(task)
    print(f"Added task [{idx}]: {title}")


def cmd_list(store, args):
    status_filter = None
    if args:
        status_filter = args[0]

    if status_filter:
        tasks = store.list_by_status(status_filter)
    else:
        tasks = store.list_all()

    if not tasks:
        print("No tasks found.")
        return

    for i, task in enumerate(tasks):
        print_task(task, i)


def cmd_done(store, args):
    if not args:
        print("Usage: done <task_number>")
        return
    try:
        index = int(args[0])
        store.complete_task(index)
        print(f"Completed task [{index}]")
    except (ValueError, IndexError):
        print(f"Invalid task number: {args[0]}")


def cmd_delete(store, args):
    if not args:
        print("Usage: delete <task_number>")
        return
    try:
        index = int(args[0])
        task = store.get(index)
        store.delete_task(index)
        print(f"Deleted: {task.title}")
    except (ValueError, IndexError):
        print(f"Invalid task number: {args[0]}")


def cmd_search(store, args):
    if not args:
        print("Usage: search <query>")
        return
    query = " ".join(args)
    results = store.search(query)
    if not results:
        print(f"No tasks matching '{query}'")
        return
    for task in results:
        print_task(task)


def cmd_stats(store, args):
    stats = store.get_stats()
    print(f"Total: {stats['total']}")
    print(f"  Todo: {stats['todo']}")
    print(f"  In Progress: {stats['in_progress']}")
    print(f"  Done: {stats['done']}")
    print(f"  Completion: {stats['completion_rate']:.0%}")


def cmd_help(store, args):
    print("Task Tracker — Commands:")
    print("  add <title> [--priority high|medium|low] [--desc text]")
    print("  list [todo|in_progress|done]")
    print("  done <number>")
    print("  delete <number>")
    print("  search <query>")
    print("  stats")
    print("  help")


COMMANDS = {
    "add": cmd_add,
    "list": cmd_list,
    "done": cmd_done,
    "delete": cmd_delete,
    "search": cmd_search,
    "stats": cmd_stats,
    "help": cmd_help,
}


def main():
    store = TaskStore()

    if len(sys.argv) < 2:
        cmd_help(store, [])
        return

    command = sys.argv[1]
    args = sys.argv[2:]

    if command in COMMANDS:
        COMMANDS[command](store, args)
    else:
        print(f"Unknown command: {command}")
        cmd_help(store, [])


if __name__ == "__main__":
    main()
