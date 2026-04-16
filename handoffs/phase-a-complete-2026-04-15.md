# Phase A Complete — Per-User Progression + Conductor as Native Goose

**Date:** 2026-04-15
**Status:** Phase A shipped. 7 commits on origin/main (push pending). Curriculum integration (Phase B) and continuous-dev refactor (Phase C) deferred.
**Prior handover:** `ril-agents-port-complete-and-next-steps-2026-04-15.md`

---

## Part 1 — What shipped

### Stage 1.5a: per-user progression — **DONE** (commit fbca70f)

- `recipes/agents/progression/migrate-progression.yaml`: one-shot idempotent migration from `.goose/state/progression.json` to `~/.rilgoose/progression.json`. Atomic tmp + rename; legacy file gets `.migrated` breadcrumb.
- `recipes/RECIPE-PREAMBLE.md`: documents the PROGRESSION STATE STANZA (canonical text + when/how to embed it).
- `recipes/agents/check-progress.yaml`, `graduate-module.yaml`: read canonical per-user path with one-time migration fallback. Never write to legacy.
- `recipes/shared/01-26`: PROGRESSION STATE stanza inserted after the ISOLATION preamble in every stage recipe; legacy path swapped to canonical.
- Teaching scripts (`teaching/**/*.teach.md`) + module-designer references: paths swapped; progression-format.md rewritten around the canonical location.
- `install/setup-goose.ps1`: creates `~/.rilgoose/`, recursively counts agent primitives so nested subdirs (progression, config, conductor) show up.

### Conductor reference docs — **DONE** (commit 4b71ad0)

Faithful port from `~/ClaudeInfra/ril-agents/plugins/conductor/`:
- `recipes/ported-agents/conductor/README.md` (overview + slash-command → recipe mapping)
- `recipes/ported-agents/conductor/skills/{context-driven-development,track-management,workflow-patterns}.md`
- `recipes/ported-agents/conductor/references/artifact-templates.md`
Frontmatter stripped, bodies preserved verbatim.

### Config layer — **DONE** (commit 5a75481)

- `recipes/agents/config/ensure-config.yaml`: read-only resolver. Migrates legacy `.goose/state/user_config.json` once. Canonicalizes paths. Returns structured status codes.
- `recipes/shared/setup-config.yaml`: interactive facilitator. First-run + add/modify/set-default branches. Atomic writes with backup. `kind: live` requires typed confirmation.
- `ideas/conductor-config-design.md`: locked decisions, schemas (user.json, project.json), ensure-config → caller contract.

### 9 conductor agent primitives — **DONE** (commit ff95c33)

`recipes/agents/conductor/`:
- context-validate, context-write-product, context-write-tech-stack, context-write-workflow, context-write-styleguide
- track-create, track-task-execute, checkpoint-verify, revert-by-unit

All follow Role → Constraints → Failure Modes → Process → Return. All accept optional `project_id`. All resolve via the `ensure_config` sub-recipe.

### 6 conductor working recipes — **DONE** (commit c9320c0)

`recipes/shared/`:
- conductor-setup, conductor-new-track, conductor-implement, conductor-status, conductor-revert, conductor-manage

Interactive facilitators that delegate to the agent primitives.

### Multi-subagent review + fixes — **DONE** (commit 43bae3e)

Spun up 4 reviewers (2 Claude Agents + 2 Codex). Aggregated findings; fixed blockers and high-value warnings:

1. RECIPE-PREAMBLE.md: added "Conductor Project-State Reads" carve-out (the design-doc-flagged risk that was unfixed).
2. Migration semantics: contradictory "move ... then rename" wording fixed across 26 stage recipes + check-progress + graduate-module. Now actually idempotent ("COPY ... then rename .migrated").
3. setup-config first-run: writes top-level `last_active` so headless conductor recipes resolve cleanly.
4. ensure-config: clarified `last_active` is a SUGGESTION; added single-project fallback with `auto_selected: true` and `resolved_via` field.
5. conductor-revert confirmation: target-specific typed string (`revert <track_id> [task|phase ...]`), matching the delete pattern in conductor-manage.
6. conductor-setup `.gitignore` recommendation: ALL projects (not just live).
7. conductor-setup tracks.md write: atomic tmp + timestamped backup + rename.

---

## Part 2 — Deferred to Phase B / Phase C

The four reviewers surfaced these. None are blockers for what's shipped, but they should be fixed before Phase B's curriculum integration touches the conductor recipes in earnest.

| # | Item | Source | Recommended fix |
|---|---|---|---|
| 1 | `kind: live` guards in mutating primitives | Claude Agent #1 | Add `live_confirmed: bool` parameter to track-task-execute, revert-by-unit, context-write-*. Refuse `live` projects without it. |
| 2 | `config_unresolved` status not enumerated in conductor primitive Returns | Claude Agent #1 | Add `config_unresolved` to each primitive's status list with a nested `config_status` field carrying the underlying ensure_config status. |
| 3 | track-create tracks.md append atomicity | Claude Agent #1 | Stage tracks.md.tmp alongside the track files; rename atomically OR define explicit rollback (which files get unlinked, in what order, what if rollback itself fails). |
| 4 | git notes over-promise in track-task-execute | Claude Agent #1 | Downgrade git notes from a Process step to best-effort + add `notes_attached: bool` + `notes_attach_failed` status code. |
| 5 | Status-routing tables in each conductor recipe Step 0 | Claude Agent #2 | Right now all 6 collapse 9 statuses to "surface and stop." Add a routing table mirroring `ideas/conductor-config-design.md`'s contract table — `legacy_ambiguous` and `no_user_config` should explicitly direct the user to `setup-config`; `duplicate_projects` should surface the duplicate list before any other action; etc. |
| 6 | conductor-implement checkpoint approval string | Claude Agent #2 | Tighten "approved" to "type exactly 'approved'" so model interpretation can't broaden. |
| 7 | conductor-new-track `brief_too_vague` retry loop | Claude Agent #2 | Cap retries (3); explicitly pass the refined `requirements_brief` on each retry. |
| 8 | conductor-setup file-existence re-check before flipping `conductor_initialized` | Claude Agent #2 | Add an explicit Test-Path check on the four core artifacts before flipping the flag, independent of context-validate. |
| 9 | Backup rotation scheme | Claude Agent #1 | Pick one scheme (`<file>.bak.<ISO 8601 timestamp>` already used in conductor-setup tracks.md fix) and document in RECIPE-PREAMBLE.md or canonical-recipe-structure.md so all writers cite it. |
| 10 | Baseline ambiguity in checkpoint-verify + revert-by-unit | Claude Agent #1 | Define exact fallback for "if last_checkpoint_sha is empty" (e.g., "use the first commit reachable from HEAD whose message matches `^docs: start task`"). |
| 11 | Freshness 90-day rule in context-validate | Claude Agent #1 | Drop the time-based heuristic; keep only concrete-signal rules. |
| 12 | Progression schema mismatch | Codex progression | The actual seeded `.goose/state/progression.json` uses a top-level `sequence` array; `progression-format.md` documents nested `stages`/`concepts`. Reconcile (probably update progression-format.md to match the real sequence schema since `graduate-module` indexes that array). |
| 13 | Stage 0 user_config legacy → conductor project.json bridge | Codex progression | A user who completes Start Here (which writes legacy `.goose/state/user_config.json`) and then runs `conductor-setup` gets `project_json_missing` because ensure-config's migration only seeds `user.json`, not `project.json`. Either (a) extend ensure-config's migration to also stub `project.json` with `needs_kind_confirmation: true`, or (b) make conductor-setup's status-routing branch run setup-config when it sees `project_json_missing`. |
| 14 | First conductor implementation walkthrough on a real project | n/a | Phase B should pick a small real project, run setup-config → conductor-setup → conductor-new-track → conductor-implement end-to-end, and capture the friction. Many of the above warnings will sort themselves out under contact with reality. |

---

## Part 3 — Suggested kickoff prompt for the next session

Copy everything between the dashed lines into a fresh Claude Code session in `<PROJECTS>\goose-wizard`.

---

Continue from Phase A completion. This session's job is **Phase B — wire conductor into the curriculum + run the first end-to-end real-project walkthrough**.

**Read these first, in order:**
1. `handoffs/phase-a-complete-2026-04-15.md` — what shipped, what's deferred (Part 2 has 14 items; pick a subset based on what comes up in the walkthrough).
2. `ideas/conductor-config-design.md` — locked decisions + schemas.
3. `ideas/syllabus.md` — Stage 2 / Stage 4 / Stage 5 / Stage 6 sections (where conductor wires in).
4. `recipes/ported-agents/conductor/README.md` — to internalize the workflow Conductor enables.

**Phase B work (Doni's call — pick one to start):**

**Option B1 — Real-project walkthrough first (recommended).** Pick a small real codebase (goose-wizard itself works). Run:
- `goose run --recipe recipes/shared/setup-config.yaml --interactive`
- `goose run --recipe recipes/shared/conductor-setup.yaml --interactive`
- `goose run --recipe recipes/shared/conductor-new-track.yaml --interactive`
- `goose run --recipe recipes/shared/conductor-implement.yaml --interactive --params track_id=<the one you just made>`

Capture the friction. Many of the 14 deferred items in the Phase A handoff will surface naturally. Fix the ones that bite immediately; punt the rest.

**Option B2 — Curriculum integration.** Wire conductor recipes into:
- Stage 2 training recipe: introduce conductor-setup and one conductor-new-track / conductor-implement cycle as the "you've outgrown one-off prompts" moment.
- Stage 4 spec recipes: store the spec output as `tracks/<id>/spec.md` instead of free-floating files.
- Stage 5 eval recipes: hook checkpoint-verify into the eval-gate workflow.

**Option B3 — Knock out deferred items 1, 2, 5 from the Phase A handoff** (the ones most likely to bite Phase B): kind:live guards, config_unresolved enumeration, status-routing tables in conductor recipes' Step 0.

**Hard constraints (unchanged from Phase A):**
- `~/ClaudeInfra/ril-agents/` is READ-ONLY.
- Conductor artifacts go in `<target>/.goose/conductor/`, NOT in target repo root.
- `project.json` is authoritative; `user.json.projects[]` is just an index.
- CWD is always goose-wizard repo root. Target accessed by absolute path.
- Use `~/.rilgoose/` NOT `~/.goose/rilgoose/`.

Report back with what you ran, what broke, what you fixed, and which of the Phase A deferred items you addressed.

---

That's the kickoff prompt.

---

## Part 4 — Commits this session

```
fbca70f Stage 1.5a: Migrate progression to per-user state
4b71ad0 Port conductor reference docs into recipes/ported-agents/conductor/
5a75481 Add unified config recipe + multi-project support
ff95c33 Add 9 conductor agent primitives
c9320c0 Add 6 conductor working recipes
43bae3e Phase A review fixes: blocker patches from 4-subagent review
```

Plus this handoff.

All on `main`. Push pending — confirm with Doni before pushing.
