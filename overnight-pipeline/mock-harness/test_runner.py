"""Mock training session orchestrator.

Spawns a Goose teacher recipe interactively, uses a mock-student recipe
to generate responses, and feeds them back. Collects transcripts, verifies
progression updates, and reports pass/fail.

Usage:
    python -m overnight-pipeline.mock-harness.test_runner --recipe 02-bug-fix --persona priya_eager
    python -m overnight-pipeline.mock-harness.test_runner --config overnight-pipeline/run_config.json
    python -m overnight-pipeline.mock-harness.test_runner --dry-run
"""

import argparse
import json
import subprocess
import sys
import time
from concurrent.futures import ProcessPoolExecutor, as_completed
from datetime import datetime, timezone
from pathlib import Path

# Allow running as a standalone script from any directory
_HARNESS_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(_HARNESS_DIR))

from config import GOOSE_WIZARD_ROOT, RunConfig, SessionConfig, SessionResult
from session_manager import SessionEnvironment
from student_caller import call_mock_student
from transcript_writer import TranscriptWriter
from wait_detector import WaitDetector


def load_personas() -> dict[str, str]:
    """Parse personas.md into a dict of name -> full persona text.

    Handles headers like: ## 1. Priya — Eager/Over-Accepting
    Produces keys like: priya
    """
    personas_file = GOOSE_WIZARD_ROOT / "overnight-pipeline" / "personas.md"
    text = personas_file.read_text(encoding="utf-8")

    personas = {}
    current_name = None
    current_lines = []

    for line in text.split("\n"):
        # Match persona headers: "## 1. Priya — Eager/Over-Accepting"
        if line.startswith("## ") and "\u2014" in line:
            if current_name:
                personas[current_name] = "\n".join(current_lines).strip()
            # Extract name from between "." and "—"
            header = line[3:].strip()
            parts = header.split("\u2014")  # em-dash
            name_part = parts[0].strip()
            # Remove leading number: "1. Priya" -> "Priya"
            if ". " in name_part:
                name_part = name_part.split(". ", 1)[1]
            current_name = name_part.strip().lower()
            current_lines = [line]
        elif current_name is not None:
            current_lines.append(line)

    if current_name:
        personas[current_name] = "\n".join(current_lines).strip()

    return personas


def run_single_session(config: SessionConfig) -> SessionResult:
    """Run one mock training session and return the result."""
    start_time = time.time()

    with SessionEnvironment(config.recipe, config.persona_name) as env:
        # Resolve recipe path
        recipe_name = config.recipe
        if not recipe_name.endswith(".yaml"):
            recipe_name = recipe_name + ".yaml"

        # Spawn teacher process with stream-json for turn detection
        teacher_proc = subprocess.Popen(
            [
                "goose", "run",
                "--recipe", recipe_name,
                "--interactive",
                "--no-session",
                "--output-format", "stream-json",
                "--max-turns", "30",
            ],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=str(env.target_codebase),
            env=env.get_env(),
            text=True,
            bufsize=1,
        )

        # Set up output collection
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S")
        output_dir = (
            GOOSE_WIZARD_ROOT
            / "overnight-pipeline"
            / "results"
            / timestamp
            / f"{config.recipe}-{config.persona_name}"
        )
        transcript = TranscriptWriter(output_dir, config.recipe, config.persona_name)
        detector = WaitDetector(teacher_proc.stdout, safety_timeout=config.session_timeout_seconds)

        conversation_history = ""
        interaction = 0
        errors = []

        try:
            while interaction < config.max_interactions:
                # Collect teacher output until "complete" event (turn done)
                teacher_output, finished = detector.collect_until_turn_complete()

                if teacher_output.strip():
                    transcript.add_teacher(teacher_output)
                    conversation_history += f"TEACHER: {teacher_output}\n\n"

                if finished:
                    break  # Teacher process exited

                # Get student response
                edge_case = config.edge_cases.get(interaction, "")
                try:
                    student_response = call_mock_student(
                        persona_text=config.persona_text,
                        conversation_history=conversation_history,
                        teacher_message=teacher_output,
                        context_dir=output_dir,
                        edge_case=edge_case,
                        interaction_number=interaction + 1,
                        total_estimate=config.max_interactions,
                    )
                except Exception as e:
                    errors.append(f"Student call failed at interaction {interaction}: {e}")
                    student_response = "yes"  # Fallback to keep session alive

                # Feed student response to teacher
                transcript.add_student(student_response)
                conversation_history += f"STUDENT: {student_response}\n\n"

                try:
                    teacher_proc.stdin.write(student_response + "\n")
                    teacher_proc.stdin.flush()
                except BrokenPipeError:
                    break  # Teacher exited

                interaction += 1

        except Exception as e:
            errors.append(f"Session error: {e}")
        finally:
            # Clean up teacher process
            if teacher_proc.poll() is None:
                teacher_proc.terminate()
                try:
                    teacher_proc.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    teacher_proc.kill()

        # Collect results
        duration = time.time() - start_time
        transcript_path = transcript.write()
        eval_results = transcript.extract_eval_results()

        # Check progression update
        progression = env.get_progression()
        progression_updated = False
        if progression and "sequence" in progression:
            for entry in progression["sequence"]:
                if entry.get("status") == "complete":
                    progression_updated = True
                    break

        # Save progression snapshot
        output_dir.mkdir(parents=True, exist_ok=True)
        (output_dir / "progression.json").write_text(
            json.dumps(progression, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

        # Save summary
        result = SessionResult(
            recipe=config.recipe,
            persona=config.persona_name,
            status="pass" if progression_updated and not errors else "fail",
            interaction_count=interaction,
            duration_seconds=round(duration, 1),
            progression_updated=progression_updated,
            graduation_succeeded=False,  # TODO: check if recipe file was replaced
            errors=errors,
            transcript_path=str(transcript_path),
            eval_dimensions=eval_results,
        )

        (output_dir / "summary.json").write_text(
            json.dumps(vars(result), indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

        return result


def build_test_matrix(
    recipes: list[str],
    persona_filter: list[str],
    edge_schedule: dict,
    max_interactions: int,
    wait_timeout: float,
) -> list[SessionConfig]:
    """Build the cross-product of recipes × personas."""
    all_personas = load_personas()

    if "all" in persona_filter:
        selected = all_personas
    else:
        selected = {k: v for k, v in all_personas.items() if k in persona_filter}

    if not selected:
        print(f"WARNING: No personas matched filter {persona_filter}")
        print(f"Available: {list(all_personas.keys())}")
        return []

    matrix = []
    for recipe in recipes:
        for name, text in selected.items():
            edge_cases = {}
            recipe_schedule = edge_schedule.get(recipe, {})
            if name in recipe_schedule:
                trigger = recipe_schedule[name]
                edge_cases[trigger["interaction"]] = trigger["edge_case"]

            matrix.append(SessionConfig(
                recipe=recipe,
                persona_name=name,
                persona_text=text,
                edge_cases=edge_cases,
                max_interactions=max_interactions,
                wait_timeout_seconds=wait_timeout,
            ))

    return matrix


def main():
    parser = argparse.ArgumentParser(description="Mock training session harness")
    parser.add_argument("--recipe", help="Single recipe to test (e.g., 02-bug-fix)")
    parser.add_argument("--persona", help="Single persona to use (e.g., priya_eager)")
    parser.add_argument("--config", help="Path to run_config.json")
    parser.add_argument("--workers", type=int, default=1, help="Parallel workers")
    parser.add_argument("--dry-run", action="store_true", help="Show test matrix without running")
    args = parser.parse_args()

    # Build config
    if args.config:
        run_config = RunConfig.from_file(Path(args.config))
    else:
        run_config = RunConfig(
            recipes=[args.recipe or "02-bug-fix"],
            personas=[args.persona or "all"],
            edge_case_schedule={},
            parallel_workers=args.workers,
        )

    # Build test matrix
    matrix = build_test_matrix(
        recipes=run_config.recipes,
        persona_filter=run_config.personas,
        edge_schedule=run_config.edge_case_schedule,
        max_interactions=run_config.max_interactions,
        wait_timeout=run_config.wait_timeout_seconds,
    )

    if not matrix:
        print("No sessions to run.")
        return

    if args.dry_run:
        print(f"Test matrix: {len(matrix)} sessions")
        for cfg in matrix:
            edge = f" [edge: {cfg.edge_cases}]" if cfg.edge_cases else ""
            print(f"  {cfg.recipe} × {cfg.persona_name}{edge}")
        return

    print(f"Running {len(matrix)} sessions with {run_config.parallel_workers} workers...")

    if run_config.parallel_workers <= 1:
        results = [run_single_session(cfg) for cfg in matrix]
    else:
        results = []
        with ProcessPoolExecutor(max_workers=run_config.parallel_workers) as executor:
            futures = {executor.submit(run_single_session, cfg): cfg for cfg in matrix}
            for future in as_completed(futures):
                cfg = futures[future]
                try:
                    result = future.result(timeout=run_config.session_timeout_seconds)
                    results.append(result)
                    status_icon = "✓" if result.status == "pass" else "✗"
                    print(f"  {status_icon} {result.recipe} × {result.persona}: "
                          f"{result.status} ({result.interaction_count} turns, {result.duration_seconds}s)")
                except Exception as e:
                    results.append(SessionResult(
                        recipe=cfg.recipe, persona=cfg.persona_name,
                        status="error", errors=[str(e)],
                    ))
                    print(f"  ✗ {cfg.recipe} × {cfg.persona_name}: error — {e}")

    # Print summary
    passed = sum(1 for r in results if r.status == "pass")
    failed = sum(1 for r in results if r.status == "fail")
    errored = sum(1 for r in results if r.status == "error")

    print(f"\n{'='*50}")
    print(f"Results: {passed} passed, {failed} failed, {errored} errors")
    if failed + errored > 0:
        print("\nFailures:")
        for r in results:
            if r.status != "pass":
                print(f"  {r.recipe} × {r.persona}: {r.status}")
                for err in r.errors:
                    print(f"    {err}")


if __name__ == "__main__":
    main()
