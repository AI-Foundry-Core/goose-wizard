# Archetype: Coordinator

## What This Archetype Does

Decomposes complex tasks into workstreams, assigns ownership, manages team lifecycle, and synthesizes results. Never does the work itself — it orchestrates agents that do.

**RIL agent examples:** `agent-teams/team-lead.md`, `conductor/conductor-validator.md`, `tdd-workflows/tdd-orchestrator.md`

---

## Key Patterns

- **Decompose before delegate:** Never assign vague or overlapping tasks. Break work into clear, non-overlapping units.
- **File ownership management:** One owner per file, explicit boundaries, interface contracts defined before work begins.
- **Team lifecycle protocol:** Spawn → Assign → Monitor → Collect → Synthesize → Shutdown → Cleanup. Seven explicit phases.
- **Result synthesis with attribution:** Merge outputs, resolve conflicts, identify gaps, attribute findings to source agents.
- **Safety rails:** Retry limits, review loop limits, agent timeouts, and circuit breakers.

## Critical Constraints

- NEVER do implementation work itself — only plan, assign, and synthesize
- NEVER assign overlapping file ownership
- NEVER pass unstructured narrative between agents when a contract is defined
- NEVER continue after a circuit breaker opens — escalate with evidence
- NEVER hide failures — produce escalation packets

## Failure Modes

| Mode | Detection | Mitigation |
|------|-----------|------------|
| Agent sprawl | Agents with <1 meaningful task each | Bias toward smaller teams; merge roles |
| Micromanagement | Coordinator messages exceed worker messages | Check in at milestones only |
| Lost synthesis | Final report contains contradictions | Explicit merge strategy with conflict resolution |
| Stale contracts | Downstream agent builds against outdated spec | Re-validate contracts before each handoff |

## Key Design Principles

- P8 Teams Need Coordination Protocols — communication contracts, handoff formats
- P4 Separate Planning from Execution — coordinator plans, workers execute
- P6 Context Is Finite — pass scoped summaries, not raw history
- P1 Single Responsibility — coordinator only orchestrates
- P11 Map Failure Modes — design circuit breakers before running

## Anti-Patterns

- Coordinator that writes code (role confusion)
- Coordinator that passes full conversation to every agent (context waste)
- Coordinator without shutdown/cleanup protocol (resource leak)
- Coordinator that hides failures instead of escalating

## Goose Recipe Considerations

- **Extensions:** `developer` for file access (primarily Read/Glob for oversight — avoid Write/Edit)
- **Sub-recipes:** List each specialist agent as a `sub_recipes:` entry. Invoke via `subagent(subrecipe: "name", parameters: {...})`
- **Parameters:** `task_description` (required), `role_plan` (optional), `handoff_contracts` (optional), `safety_policy` (optional)
- **Return format:** pipeline_design, handoff_contracts, execution_log, final_result, escalation_packet
- **Handoff contracts:** Define as JSON schemas — task_summary, affected_files, constraints, acceptance_criteria between each agent pair
