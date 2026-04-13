#!/usr/bin/env python3
"""
Pipeline Runner — Deterministic loop that runs Goose recipes in sequence.

Usage:
    python pipeline_runner.py <config_dir>

The config_dir must contain:
    - cycle.md    — markdown table listing recipes to run each cycle
    - state.json  — pipeline state (current_cycle, max_cycles, status)

Optional:
    - schedule.md — markdown table with per-cycle params (persona, teaching_script, etc.)

The script will:
    1. Read state.json to determine current cycle
    2. Run each recipe from cycle.md via `goose run`
    3. Check for STOP.md after each recipe
    4. Update state.json after each cycle
    5. Repeat until max_cycles or STOP.md
"""

import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


def read_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def write_json_atomic(path, data):
    """Write JSON atomically: write to .tmp then rename."""
    tmp_path = path + ".tmp"
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    os.replace(tmp_path, path)


def parse_markdown_table(path):
    """Parse a markdown table into a list of dicts. Ignores header separator row."""
    if not os.path.exists(path):
        return []
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    rows = []
    headers = None
    for line in lines:
        line = line.strip()
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.split("|")[1:-1]]
        if headers is None:
            headers = [h.lower().replace(" ", "_") for h in cells]
            continue
        if all(re.match(r"^[-:]+$", c) for c in cells):
            continue  # separator row
        row = {}
        for i, cell in enumerate(cells):
            if i < len(headers):
                row[headers[i]] = cell
        rows.append(row)
    return rows


def write_stop(config_dir, reason, stopped_by="pipeline_runner"):
    """Write STOP.md to halt the pipeline."""
    stop_path = os.path.join(config_dir, "STOP.md")
    with open(stop_path, "w", encoding="utf-8") as f:
        f.write(f"# Pipeline Stop\n")
        f.write(f"Reason: {reason}\n")
        f.write(f"Stopped by: {stopped_by}\n")
        f.write(f"Time: {datetime.now(timezone.utc).isoformat()}\n")


def log_error(cycle_dir, step, stderr):
    """Log a recipe failure."""
    error_path = os.path.join(cycle_dir, f"{step['name']}-error.md")
    with open(error_path, "w", encoding="utf-8") as f:
        f.write(f"# Error: {step['name']}\n\n")
        f.write(f"Recipe: {step['recipe']}\n")
        f.write(f"Time: {datetime.now(timezone.utc).isoformat()}\n\n")
        f.write(f"## stderr\n```\n{stderr}\n```\n")


def build_goose_command(step, config_dir, cycle_num, schedule_entry):
    """Build the goose run command with params."""
    cmd = ["goose", "run", "--recipe", step["recipe"], "--no-session", "-q"]

    # Always pass run_dir and cycle_number
    cmd.extend(["--params", f"run_dir={config_dir}"])
    cmd.extend(["--params", f"cycle_number={cycle_num}"])

    # Pass schedule entry fields as params
    for key, value in schedule_entry.items():
        if key != "cycle" and value:
            cmd.extend(["--params", f"{key}={value}"])

    return cmd


def run_pipeline(config_dir):
    config_dir = os.path.abspath(config_dir)

    # Read config files
    state_path = os.path.join(config_dir, "state.json")
    cycle_path = os.path.join(config_dir, "cycle.md")
    schedule_path = os.path.join(config_dir, "schedule.md")

    if not os.path.exists(state_path):
        print(f"Error: {state_path} not found. Copy from templates/state.json first.")
        sys.exit(1)

    if not os.path.exists(cycle_path):
        print(f"Error: {cycle_path} not found. Create a cycle.md with your recipe list.")
        sys.exit(1)

    state = read_json(state_path)
    cycle_steps = parse_markdown_table(cycle_path)
    schedule = parse_markdown_table(schedule_path)

    if not cycle_steps:
        print("Error: No steps found in cycle.md. Check the markdown table format.")
        sys.exit(1)

    max_cycles = state.get("max_cycles", 20)
    sleep_seconds = state.get("sleep_seconds", 30)

    print(f"Pipeline starting: {len(cycle_steps)} steps/cycle, max {max_cycles} cycles")
    print(f"Config dir: {config_dir}")
    print(f"Resuming from cycle {state.get('current_cycle', 1)}")
    print()

    while state.get("current_cycle", 1) <= max_cycles:
        cycle_num = state.get("current_cycle", 1)

        # Check for pre-existing stop
        if os.path.exists(os.path.join(config_dir, "STOP.md")):
            print(f"STOP.md found before cycle {cycle_num}. Halting.")
            state["status"] = "complete"
            write_json_atomic(state_path, state)
            return

        if state.get("status") == "complete":
            print("Status is 'complete'. Halting.")
            return

        # Create cycle directory
        cycle_dir = os.path.join(config_dir, f"cycle-{cycle_num}")
        os.makedirs(cycle_dir, exist_ok=True)

        # Get schedule entry for this cycle
        schedule_entry = {}
        if schedule and cycle_num - 1 < len(schedule):
            schedule_entry = schedule[cycle_num - 1]

        print(f"=== Cycle {cycle_num}/{max_cycles} ===")
        cycle_start = time.time()
        steps_completed = 0
        cycle_stopped = False

        # Run each step
        for step in cycle_steps:
            step_name = step.get("name", step.get("recipe", "unknown"))
            recipe = step.get("recipe", "")
            timeout = int(step.get("timeout", 600))

            print(f"  [{step_name}] running... ", end="", flush=True)

            cmd = build_goose_command(step, config_dir, cycle_num, schedule_entry)

            try:
                result = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    timeout=timeout,
                    cwd=config_dir,
                )

                # Save output
                output_path = os.path.join(cycle_dir, f"{step_name}-output.md")
                with open(output_path, "w", encoding="utf-8") as f:
                    f.write(result.stdout or "(no output)")

                if result.returncode != 0:
                    print(f"FAILED (exit {result.returncode})")
                    log_error(cycle_dir, {"name": step_name, "recipe": recipe}, result.stderr)
                    state["consecutive_failures"] = state.get("consecutive_failures", 0) + 1

                    if state["consecutive_failures"] >= 3:
                        print("  Circuit breaker: 3 consecutive failures. Stopping.")
                        write_stop(config_dir, "Circuit breaker: 3 consecutive failures")
                        cycle_stopped = True
                        break
                else:
                    elapsed = time.time() - cycle_start
                    print(f"OK ({elapsed:.0f}s)")
                    state["consecutive_failures"] = 0
                    steps_completed += 1

            except subprocess.TimeoutExpired:
                print(f"TIMEOUT ({timeout}s)")
                log_error(cycle_dir, {"name": step_name, "recipe": recipe}, f"Timed out after {timeout}s")
                state["consecutive_failures"] = state.get("consecutive_failures", 0) + 1

                if state["consecutive_failures"] >= 3:
                    print("  Circuit breaker: 3 consecutive failures. Stopping.")
                    write_stop(config_dir, "Circuit breaker: 3 consecutive failures")
                    cycle_stopped = True
                    break

            # Check stop after each step
            if os.path.exists(os.path.join(config_dir, "STOP.md")):
                print(f"  STOP.md detected after {step_name}. Finishing cycle.")
                cycle_stopped = True
                break

        # Record cycle
        cycle_elapsed = time.time() - cycle_start
        completed_cycles = state.get("completed_cycles", [])
        completed_cycles.append({
            "cycle": cycle_num,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "steps_completed": steps_completed,
            "steps_total": len(cycle_steps),
            "elapsed_seconds": round(cycle_elapsed),
            "schedule_entry": schedule_entry if schedule_entry else None,
        })
        state["completed_cycles"] = completed_cycles
        state["last_heartbeat"] = datetime.now(timezone.utc).isoformat()

        if cycle_stopped:
            state["status"] = "complete"
            write_json_atomic(state_path, state)
            print(f"\nPipeline stopped at cycle {cycle_num}.")
            return

        # Advance to next cycle
        state["current_cycle"] = cycle_num + 1
        write_json_atomic(state_path, state)

        print(f"  Cycle {cycle_num} complete ({cycle_elapsed:.0f}s, {steps_completed}/{len(cycle_steps)} steps)")

        # Sleep between cycles (skip if last cycle)
        if state["current_cycle"] <= max_cycles:
            print(f"  Sleeping {sleep_seconds}s...")
            time.sleep(sleep_seconds)

    # All cycles done
    state["status"] = "complete"
    write_json_atomic(state_path, state)
    total_cycles = state.get("current_cycle", 1) - 1
    print(f"\nPipeline complete. {total_cycles} cycles run.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python pipeline_runner.py <config_dir>")
        print("  config_dir must contain cycle.md and state.json")
        sys.exit(1)

    run_pipeline(sys.argv[1])
