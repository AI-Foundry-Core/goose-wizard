# Conductor: Single-Recipe + Skill-Files Architecture

**Status:** Draft v2 — reviewed by 4 subagents, findings incorporated  
**Date:** 2026-04-16  
**Replaces:** 6 separate conductor-*.yaml shared recipes

## The Problem

Conductor was ported as 6 user-facing recipes (setup, new-track, implement, status,
revert, manage) + 9 agent primitives. This splits what was originally one contextual
agent into disconnected entry points.

**What breaks:**
- Each recipe starts cold — no memory of prior conversation
- User must be the router ("which recipe do I run next?")
- Mode-switching mid-conversation is impossible
- Contradicts the teaching goal (AI holds complex workflows together)

## The Proposal

**One recipe: `conductor.yaml`** in `recipes/shared/`.  
**Skill files** in `recipes/conductor-skills/` provide deep knowledge per mode.  
**Agent primitives** in `recipes/agents/conductor/` become true leaf workers.

```
User runs: goose run --recipe conductor --interactive
          ↓
    Conductor recipe starts
          ↓
    Step 0: Resolve config via ensure_config (project_id, path, kind)
          ↓
    Step 1: Load project context (.goose/conductor/*.md + guidelines, indexes)
          ↓
    Asks: "What would you like to work on?"
          ↓
    Based on intent, reads relevant skill file(s)
          ↓
    Delegates heavy work to leaf agent primitives (passing resolved config)
          ↓
    After each delegate return: reread mutated artifacts
          ↓
    Stays in conversation — user can shift modes freely
```

## Architecture: Kernel + Skills + Leaves

The recipe is structured as three layers:

### Layer 1: Hard Invariant Kernel (always loaded, in conductor.yaml)

These rules are ALWAYS in the system prompt. They never move to skill files.

1. **Config resolution** — Accept optional `project_id` parameter. Call
   `ensure_config` sub-recipe on startup. Route structured config failures
   (unknown kind → setup-config and stop; needs_kind_confirmation → prompt).
   Pass resolved `{project_id, path, kind, project_json}` to all primitives.

2. **Kind/live safety gates** — Before ANY mutation (implementation, revert,
   manage, context-write):
   - If `kind == "sandbox"`: proceed freely
   - If `kind == "live"`: require exact typed confirmation (user must type
     the track name or operation target to confirm)
   - If `kind == "unknown"`: route to setup, do not proceed

3. **Checkpoint authority** — Phase checkpoint approval is a hard user gate.
   User must type `approved` (exact match) before phase advancement. No
   implicit approval, no "sounds good" shortcuts. Commit ownership stays
   with the user.

4. **Structured status routing** — Every delegate sub-recipe returns a
   structured result. Conductor must check the status field before proceeding:
   - `success` → continue flow
   - `failure` → show error, offer retry or alternative
   - `needs_input` → surface the question to the user
   - `partial` → show what completed, what didn't, let user decide

5. **Cache invalidation** — Cache only stable project identity (name, kind,
   path). Reread all mutable artifacts (tracks.md, metadata.json, plan.md,
   status markers) AFTER every delegate return and BEFORE any destructive
   or status decision. Never rely on stale in-memory state.

6. **Session hygiene** — At natural boundaries (after setup completes, after
   a track is fully implemented, after a revert), proactively suggest a
   session break: "Good stopping point — your state is saved. You can
   continue in a new session or keep going." When switching modes, summarize
   and release the previous skill file's detailed context rather than
   accumulating all skill files in memory.

7. **Full artifact awareness** — On startup, load the complete artifact set:
   product.md, product-guidelines.md, tech-stack.md, workflow.md,
   tracks.md, setup-state, indexes, and any language-specific style guides
   in code_styleguides/. Not a subset.

8. **Mode routing table** — Recognize intent and load the right skill file:

   | Intent | Skill File | Delegates To |
   |--------|-----------|--------------|
   | Initialize project context | setup.md | context-write-* agents |
   | Create a new track | track-management.md | track-create agent |
   | Implement tasks from a track | implementation.md | track-task-execute agent |
   | Check status / progress | status.md | (inline — no delegation needed) |
   | Verify a phase checkpoint | verification.md | checkpoint-verify agent |
   | Revert work | revert.md | revert-by-unit agent |
   | Manage tracks (archive/restore/delete/rename) | track-management.md | track-lifecycle-manage agent |
   | Update context artifacts | setup.md | context-write-* agents |

### Layer 2: Skill Files (loaded on demand, in recipes/conductor-skills/)

These are plain markdown files — detailed mode-specific knowledge the
conductor reads when the user's intent requires it. They contain HOW to do
things, never safety gates or invariants.

```
recipes/conductor-skills/
├── setup.md              # Project initialization: what to ask, what artifacts
│                         #   to create, how to validate existing context,
│                         #   artifact update triggers from context-driven-dev
├── track-management.md   # Track types, ID format, spec.md structure, plan.md
│                         #   structure, metadata.json schema, lifecycle states,
│                         #   archive/restore/delete/rename procedures
├── implementation.md     # 11-step TDD lifecycle, phase checkpoints, when to
│                         #   stop and ask for approval, commit conventions,
│                         #   bounded retries, rollback handling on failure
├── verification.md       # Checkpoint gates, coverage thresholds, lint rules,
│                         #   manual verification checklist format
├── revert.md             # Semantic revert logic, track/phase/task granularity,
│                         #   safety confirmation patterns, concurrent-writer
│                         #   protection
└── status.md             # How to read tracks.md + metadata.json, compute
                          #   completion %, identify blockers, format output
```

**Source material:** Refactored from the existing ported-agents docs
(`recipes/ported-agents/conductor/skills/`) and the current recipe instructions.
Not new content — reorganized for on-demand loading.

### Layer 3: Leaf Agent Primitives (true leaves — no sub-recipe calls)

`recipes/agents/conductor/` is refactored so primitives are **true leaf
workers**. They accept resolved config as parameters and never call
`ensure_config` or any other sub-recipe themselves.

**Breaking change from current design:** Primitives currently call
`ensure_config` internally. This must be removed — conductor.yaml resolves
config once at startup and passes `{project_id, path, kind, project_json}`
to every primitive via parameters. This eliminates the Goose no-nested-
subrecipe constraint violation.

Primitives:
- `track-create.yaml` — author spec + plan + metadata (accepts resolved config)
- `track-task-execute.yaml` — 11-step TDD for one task
- `checkpoint-verify.yaml` — automated + manual verification gates
- `context-write-product.yaml` — generate/update product.md
- `context-write-tech-stack.yaml` — generate/update tech-stack.md
- `context-write-workflow.yaml` — generate/update workflow.md
- `context-write-styleguide.yaml` — generate style guide
- `context-validate.yaml` — check artifact freshness/validity
- `revert-by-unit.yaml` — semantic git revert
- `track-lifecycle-manage.yaml` — **NEW** — archive/restore/delete/rename
  tracks (moved from inline to dedicated primitive because these ops
  mutate directories and registries)

## What Gets Deleted

The 6 separate shared recipes:
- `conductor-setup.yaml` → absorbed into conductor.yaml + setup.md skill
- `conductor-new-track.yaml` → absorbed into conductor.yaml + track-management.md skill
- `conductor-implement.yaml` → absorbed into conductor.yaml + implementation.md skill
- `conductor-status.yaml` → absorbed into conductor.yaml + status.md skill
- `conductor-revert.yaml` → absorbed into conductor.yaml + revert.md skill
- `conductor-manage.yaml` → absorbed into conductor.yaml + track-management.md skill

## What Changes in the Curriculum

**Before:** Stage 2 teaches `conductor-setup`, then `conductor-new-track`, then
`conductor-implement` as separate tools to learn.

**After:** Stage 2 teaches "Conductor" as one tool. The training recipe introduces
the developer to Conductor and lets them experience setup → track → implement as a
natural flow.

**Recipe Reveal integration:** When the training recipe reveals the conductor recipe,
it explicitly shows the kernel + skill-files + leaf-workers architecture. This becomes
a teaching moment about orchestration patterns: "See how one smart agent routes intent,
loads knowledge on demand, and delegates execution? That's the pattern."

## Trade-offs

### Advantages
- **Contextual continuity** — one session, full project awareness
- **Natural interaction** — say what you want, don't pick a recipe
- **Mode-switching** — fluid transitions without restarting
- **Simpler mental model** — "run conductor" vs "which conductor recipe?"
- **Better for teaching** — demonstrates AI holding complex workflows
- **Fewer recipes in the menu** — 1 instead of 6
- **Safety contracts centralized** — kernel has all gates in one place

### Risks and Mitigations
- **Longer base prompt** — kernel is ~200-300 lines. Mitigated by skill-file
  loading on demand (mode depth stays out of base prompt).
- **Context window pressure in long sessions** — Mitigated by session hygiene
  pattern (proactive break suggestions, skill file summarize-and-release).
- **Testing individual modes** — Agent primitives remain independently testable.
  Conductor routing can be tested by running the recipe with targeted intent
  messages. Integration testing covers mode-switching paths.
- **Manage operations are non-trivial** — Mitigated by new track-lifecycle-manage
  primitive (not inline).

## Migration Path

1. Refactor agent primitives to accept resolved config params (remove ensure_config calls)
2. Create `track-lifecycle-manage.yaml` leaf primitive
3. Write the 6 skill files from existing recipe instructions + ported-agent docs
4. Write the single conductor.yaml with hard invariant kernel
5. Test all modes through the single recipe (setup → track → implement → status → revert → manage)
6. Test mode-switching paths (start implementing, check status mid-flow, resume)
7. Test session hygiene (long session, multiple mode switches, context stays coherent)
8. Delete the 6 old shared recipes
9. Update curriculum references (syllabus, training recipes)
10. Update gateway (00-start-here.yaml) if it references conductor recipes

## Review History

### Round 1 (2026-04-16) — 4 subagents (2 Claude, 2 Codex)

**Reviewers:** Goose Recipe Mechanics, Teaching UX, Architecture, Original Fidelity

**Unanimous verdict:** Direction correct, design not implementation-ready.

**Findings incorporated in v2:**
1. Hard invariant kernel — config resolution, kind/live gates, checkpoint authority,
   structured status routing all live in conductor.yaml, never in skill files
2. Nesting violation fix — primitives become true leaves, conductor passes resolved
   config, eliminates sub-recipe-calling-sub-recipe constraint
3. Cache invalidation rules — reread after every delegate, cache only stable identity
4. Session hygiene pattern — proactive break suggestions, skill file release on mode switch
5. Manage operations — new track-lifecycle-manage primitive, not inline
6. Full artifact list — all conductor artifacts loaded on startup, not a subset
