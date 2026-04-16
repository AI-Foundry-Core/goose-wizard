# Conductor — Context-Driven Development (Port)

> **Lineage:** Ported faithfully from
> `~/ClaudeInfra/ril-agents/plugins/conductor/` (wshobson's Claude-Code port
> of Google's Gemini-CLI Conductor extension). The port preserves the full
> Context-Driven Development philosophy and Track workflow while replacing
> the `/conductor:*` slash-command interface with goose-wizard-native Goose
> recipes. Do not modify the lineage source — it is read-only reference.

Conductor transforms an agentic runtime into a project-management tool by
implementing **Context-Driven Development**. It enforces a structured
workflow: **Context → Spec & Plan → Implement**.

## Philosophy

By treating context as a managed artifact alongside code, teams establish a
persistent, project-aware foundation for all AI interactions. The system
maintains:

- **Product vision** as living documentation
- **Technical decisions** as structured artifacts
- **Work units (tracks)** with specifications and phased plans
- **TDD workflow** with verification checkpoints

## Features

- **Specification & Planning**: Generate detailed specs and actionable task plans before implementation
- **Context Management**: Maintain style guides, tech stack preferences, and product goals
- **Safe Iteration**: Review plans before code generation, keeping humans in control
- **Team Collaboration**: Project-level context documents become shared foundations
- **Project Intelligence**: Handles both greenfield (new) and brownfield (existing) projects
- **Semantic Reversion**: Git-aware revert by logical work units (tracks, phases, tasks)
- **State Persistence**: Resume setup across multiple sessions

## Commands (in the lineage source) → Recipes (in goose-wizard)

| Lineage command         | goose-wizard equivalent                             |
| ----------------------- | --------------------------------------------------- |
| `/conductor:setup`      | `recipes/shared/conductor.yaml` (setup mode)        |
| `/conductor:new-track`  | `recipes/shared/conductor.yaml` (new track mode)    |
| `/conductor:implement`  | `recipes/shared/conductor.yaml` (implement mode)    |
| `/conductor:status`     | `recipes/shared/conductor.yaml` (status mode)       |
| `/conductor:revert`     | `recipes/shared/conductor.yaml` (revert mode)       |
| `/conductor:manage`     | `recipes/shared/conductor.yaml` (manage mode)       |

All six lineage commands are now handled by a single `conductor.yaml`
recipe with mode routing. It delegates file operations to leaf
primitives under `recipes/agents/conductor/` and reads skill files
from `recipes/conductor-skills/` on demand.

## Generated Artifacts (goose-wizard location)

Conductor artifacts live at `<target>/.goose/conductor/` — per-project,
gitignore-recommended:

```
<target>/.goose/conductor/
├── index.md              # Navigation hub
├── product.md            # Product vision & goals
├── product-guidelines.md # Standards & messaging
├── tech-stack.md         # Technology preferences
├── workflow.md           # Development practices (TDD, commits)
├── tracks.md             # Master track registry
├── setup_state.json      # Resumable setup state
├── code_styleguides/     # Language-specific conventions
└── tracks/
    ├── _archive/         # Archived tracks
    └── <track-id>/
        ├── spec.md       # Requirements specification
        ├── plan.md       # Phased task breakdown
        ├── metadata.json # Track metadata
        └── index.md      # Track navigation
```

Note the lineage source places artifacts directly at the repo's
`conductor/` directory. goose-wizard moves them under `.goose/conductor/`
so the target repo's root stays clean and so Conductor artifacts sit
alongside the rest of Goose's per-project state.

## Workflow

### 1. Setup (conductor.yaml — setup mode)

Interactive initialization that creates foundational project documentation:

- Detects greenfield vs brownfield projects
- Asks sequential questions about product, tech stack, workflow preferences
- Generates style guides for selected languages
- Creates tracks registry

### 2. Create Track (conductor.yaml — new track mode)

Start a new feature or bug fix:

- Interactive Q&A to gather requirements
- Generates detailed specification (spec.md)
- Creates phased implementation plan (plan.md)
- Registers track in tracks.md

### 3. Implement (conductor.yaml — implement mode)

Execute the plan systematically:

- Follows TDD red-green-refactor cycle
- Updates task status markers
- Includes manual verification checkpoints
- Synchronizes documentation on completion

### 4. Monitor (conductor.yaml — status mode)

View project progress:

- Current phase and task
- Completion percentage
- Identified blockers

### 5. Revert (conductor.yaml — revert mode)

Undo work by logical unit:

- Select track, phase, or task to revert
- Git-aware: finds all associated commits
- Requires confirmation before execution

### 6. Manage (conductor.yaml — manage mode)

Manage track lifecycle:

- Archive completed tracks with reason tracking
- Restore archived tracks to active state
- Delete tracks permanently (with safeguards)
- Rename track IDs with reference updates
- Cleanup orphaned artifacts and stale tracks

## Acknowledgments

Ported from [Conductor for Claude Code](https://github.com/wshobson/agents)
by [@wshobson](https://github.com/wshobson), which in turn adapts
[Conductor](https://github.com/gemini-cli-extensions/conductor) by Google,
originally developed for Gemini CLI.

## License

Apache License 2.0 — See the
[original project](https://github.com/gemini-cli-extensions/conductor)
for license details.
