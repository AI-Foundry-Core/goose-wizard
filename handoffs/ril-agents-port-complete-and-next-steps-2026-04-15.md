# RIL-Agents Port Complete + Next Session Design (Conductor + Multi-Project Config)

**Date:** 2026-04-15
**Status:** RIL-agents port stages 2-4 complete. Stage 1.5a (per-user progression) deferred. Conductor work redesigned as native Goose system for next session.
**Prior handover:** `ril-agents-port-handover-2026-04-14.md` (executed with one material scope change — conductor NOT digested)

---

## Part 1 — What shipped this session

### Stage 2 (ports) — COMPLETE
Created 12 ported agents under `recipes/ported-agents/`:

| Folder | Files |
|---|---|
| error-debugging | `debugger.yaml`, `error-detective.yaml` |
| product-evaluation | `post-mortem.yaml`, `product-evaluation.yaml` |
| comprehensive-review | `code-reviewer.yaml`, `architect-review.yaml` |
| product-planning | `prd-development.yaml` |
| unit-testing | `test-automator.yaml` |
| code-refactoring | `legacy-modernizer.yaml` |
| product-specification | `feature-spec.yaml`, `acceptance-criteria.yaml` |
| code-documentation | `tutorial-engineer.yaml` |

Reviewed by 2 Claude + 2 Codex subagents. Both critical cross-cutting issues they flagged are FIXED:
1. Added `.goose/team_context.md` read to every port.
2. Moved `## Failure Modes` to appear BEFORE `## Process` per canonical structure.

Minor invented content flagged by reviewers (e.g., "atomic commits" in legacy-modernizer, severity taxonomy in code-reviewer, softened "stop if quality attributes missing" in architect-review) is defensible — documented in reviewer outputs but not blocking.

### Stage 2b (conductor) — SCOPE CHANGED
**Original plan:** Write 1 digest doc (`continuous-dev-patterns.md`) as a compression of conductor's 3 skills.

**Revised:** Do NOT digest. Conductor is being redesigned as a **native multi-recipe Goose system** for a follow-up session (see Part 2 below). Key insight: conductor's actual scope (interactive project management with humans reviewing phases) is orthogonal to `continuous-dev.yaml`'s scope (unattended overnight pipelines). The digest would have lost what makes conductor valuable AND failed to address what continuous-dev.yaml needs.

**`continuous-dev.yaml` was rewired** to point at RILGoose's own `overnight-pipeline/` docs instead — which is the actual source material for its overnight-pipeline memory/state-audit concerns.

### Stage 3 (rewire) — COMPLETE
Rewired 19 recipe YAMLs + 4 teaching/reference docs:

**Recipes in `recipes/agents/`:**
bug-fix, code-review, test-writer, independent-tester, refactor, review-gate, idea-to-spec, spec-decomposition, spec-to-pipeline, spec-review, continuous-dev, eval-foundation, eval-design, eval-layers, eval-gate, eval-isolation, eval-ratchet, cycle-review, skill-evolution.

**Recipes in `recipes/graduated/`:**
recipe-forge.yaml (search scope now `recipes/ported-agents/`), pipeline-forge.yaml (search scope now `recipes/forge-references/` + `recipes/graduated/`).

**Misreferences fixed:**
- All observability-monitoring/(product-evaluation\|post-mortem) → product-evaluation/(product-evaluation\|post-mortem) (affected 7 eval-* recipes + cycle-review)
- agent-orchestration/tutorial-engineer → code-documentation/tutorial-engineer (skill-evolution)

**Teaching/reference docs:**
- `recipes/forge-references/validation-checklist.md` line 54 — now checks `recipes/ported-agents/` paths
- `teaching/meta/module-designer/SKILL.md` line 78 — updated
- `teaching/meta/module-designer/references/goose-recipe-format.md` line 29 — updated
- `teaching/meta/module-designer/references/ril-agents-map.md` → **renamed** to `ported-agents-map.md` and rewritten. CLAUDE.md updated to match.

### Stage 4 (top-level doc reframe) — COMPLETE
Reframed RIL-agents as lineage (not runtime) in:
- `CLAUDE.md` — 3 entries updated (Core Architecture, Key Technical Decisions, Cross-Project References)
- `ideas/syllabus.md` — 4 entries updated (GooseForge Research step, full "Ported Agents Integration" section — renamed and shortened to 11 entries covering only ported agents, "Concepts Not Yet Mapped" incident-response note softened, "Decision: Use RIL Agents" rewritten as "Decision: Port RIL Agents")
- `.goose/team_context.md` — ownership-model line updated

`REFERENCES.md` and `HOW_GOOSE_WORKS.md` — no references found. No changes needed.

### Stage 5 (verify) — COMPLETE (for stages 2-4)
`grep -r "ClaudeInfra/ril-agents"` across live paths (recipes/, teaching/) returns only:
- Intentional lineage references (in `teaching/.../ported-agents-map.md` and lineage callouts in CLAUDE.md / syllabus.md)
- `recipes/TWO-MODE-PATTERN.md` lines 92, 115 — file is marked SUPERSEDED; original handover said leave or update for consistency. Chose to leave.

All `handoffs/*.md` and `overnight-pipeline/runs/*/transcripts/` references are historical and intentionally preserved.

### Stage 1.5a (progression migration) — DEFERRED
Per reviewer feedback, progression state needs to move from per-CWD (`.goose/state/progression.json`) to per-user (`~/.rilgoose/progression.json`). 86 files touch progression.json. Too broad a sweep to do safely in this session's remaining context. Decisions are locked (per-user, compat loader, migrate-on-every-entry). Next session executes.

---

## Part 2 — Conductor as a native Goose system (next-session design)

### The thesis
Conductor becomes a **multi-recipe Goose system** native to RILGoose — not a reference library, not a digest. Users invoke its recipes from the Goose recipe list. The conductor artifacts (product.md, tech-stack.md, workflow.md, tracks/*) become real files at `<target>/.goose/conductor/` that recipes read and write. Conductor sits in Stage 2 of the curriculum (earliest point where teaching structure matters), NOT at Stage 6.

### Locked decisions

| Topic | Decision |
|---|---|
| Progression state | **Per-user** at `~/.rilgoose/progression.json` |
| Conductor artifacts location | **`<target>/.goose/conductor/`** (Goose-managed, gitignored suggestion) |
| Project "kind" | **Required** — `kind: sandbox \| live` in project.json; Stage 0 refuses `live` without confirmation |
| When setup-config runs | **Only when user reaches Conductor** (Stage 2+). Early stages stay focused on doing/seeing. |
| Conductor curriculum placement | Stage 2 introduction; Stage 4 artifacts; Stage 5 gates; Stage 6 continuous-dev wraps conductor |
| `~/.goose/rilgoose/` vs `~/.rilgoose/` | **`~/.rilgoose/`** (avoid collision with Goose's own namespace) |
| CWD contract | **All recipes run from RILGoose repo root. Target accessed by absolute path.** Document in CLAUDE.md + RECIPE-PREAMBLE.md. |
| Config sub-recipe count | **Collapse to 2** — `ensure-config.yaml` (read/migrate/create) + inline picker. NOT 4 separate primitives. |
| Headless/scheduled conductor | Accepts `project_id` parameter. Interactive picker only when interactive AND no param. |
| Atomic writes | Use tmp + rename + backup pattern for config writes. |

### Recipe topology

```
recipes/shared/                        # Visible in Goose, user-invocable
├── conductor-setup.yaml               # /conductor:setup equivalent
├── conductor-new-track.yaml           # /conductor:new-track equivalent
├── conductor-implement.yaml           # /conductor:implement equivalent
├── conductor-status.yaml              # /conductor:status equivalent
├── conductor-revert.yaml              # /conductor:revert equivalent
├── conductor-manage.yaml              # /conductor:manage equivalent
└── setup-config.yaml                  # Unified config recipe (multi-project)

recipes/agents/conductor/              # Sub-recipe workers
├── context-validate.yaml              # Read conductor/*.md, check freshness
├── context-write-product.yaml         # Generate/update product.md
├── context-write-tech-stack.yaml      # Generate/update tech-stack.md
├── context-write-workflow.yaml        # Generate/update workflow.md
├── context-write-styleguide.yaml      # Generate language-specific style guide
├── track-create.yaml                  # Author spec.md + plan.md + metadata.json
├── track-task-execute.yaml            # Run 11-step TDD lifecycle for one task
├── checkpoint-verify.yaml             # Run automated gates + manual checklist
└── revert-by-unit.yaml                # Semantic git revert by track/phase/task

recipes/agents/config/
└── ensure-config.yaml                 # Single config helper (reads/migrates/creates)

recipes/agents/progression/
└── migrate-progression.yaml           # Stage 1.5a: move to per-user location

recipes/ported-agents/conductor/       # Reference docs (faithful port)
├── README.md                          # ~125 lines
├── skills/context-driven-development.md  # ~393 lines (from source)
├── skills/track-management.md         # ~593 lines
├── skills/workflow-patterns.md        # ~623 lines
└── references/artifact-templates.md   # ~154 lines
```

### Config file layout

```
~/.rilgoose/
├── user.json               # user-level data + projects[] registry
└── progression.json        # per-user career progression (Stage 1.5a)

<target>/.goose/conductor/
├── project.json            # per-project RILGoose config
├── product.md              # conductor artifact
├── tech-stack.md
├── workflow.md
├── tracks.md
├── code_styleguides/
└── tracks/<id>/{spec.md, plan.md, metadata.json, index.md}
```

**user.json schema:**
```json
{
  "schema_version": 1,
  "user": { "name": "...", "role": "...", "preferences": {...} },
  "projects": [
    {
      "id": "foo",
      "path": "C:/Users/.../foo",
      "name": "Foo App",
      "kind": "sandbox",
      "last_active": "2026-04-15T..."
    }
  ]
}
```

**project.json schema (authoritative for project settings):**
```json
{
  "schema_version": 1,
  "id": "foo",
  "name": "Foo App",
  "path": "C:/Users/.../foo",
  "kind": "sandbox",
  "language": "python",
  "test_command": "pytest",
  "conductor_initialized": true,
  "created": "...",
  "last_used": "..."
}
```

### Curriculum mapping

| Stage | Role of conductor |
|---|---|
| 0 | None. Keep clean — scripted demo, no project structure. |
| 1 | None. Single-shot tasks; no project structure yet. |
| **2** | **Introduce.** First touch: `conductor-setup.yaml` captures project context. Then `conductor-new-track.yaml`. Then `conductor-implement.yaml` for one phase. Teaches: writing things down, separated concerns, phased plans. |
| 3 | Orchestration substrate. Checkpoint-verify as gate. Track-task-execute composes builder + tester + reviewer. Teaches: multi-agent coordination through artifacts, not chat. |
| 4 | Artifact destination. PRD → product.md. Feature spec → spec.md. AC → spec.md AC section. Teaches: spec quality, kill criteria, persona decomposition. |
| 5 | Checkpoints get teeth. Add eval-gate to checkpoint-verify. Block phase advance on quality regressions. |
| 6 | **NOW Continuous Dev makes sense.** Each overnight cycle becomes a micro-track. Continuous-dev.yaml uses conductor's plan.md + SHA + checkpoint structure. Per-agent memory + shared-state audit layered ON TOP. |
| 7 | Conductor `tracks.md` feeds the curator. Cross-track patterns feed skill-evolution. |

### Build order for next session

**Phase A — Foundation (likely one full session):**
1. Stage 1.5a: port progression to per-user (migrate-progression.yaml sub-recipe + compat-loader preamble + sweep of the ~27 stage recipes + check-progress + graduate-module). Safe order: ship compat loader first, update all readers to use it, keep legacy path working during transition, THEN migrate data, THEN deprecate legacy.
2. Port 5 conductor reference docs faithfully into `recipes/ported-agents/conductor/` (~1,800 lines, lineage preserved, no loss).
3. Build `ensure-config.yaml` + `setup-config.yaml`. Migration of legacy `.goose/state/user_config.json` baked in.
4. Build 9 conductor agent primitives.
5. Build 6 conductor working recipes.

**Phase B — Curriculum integration (separate session):**
6. Wire conductor into Stage 2's training recipe (`02-bug-fix.yaml` or new `08-conductor-intro.yaml`).
7. Wire conductor artifacts into Stage 4's spec recipes.
8. Wire checkpoint-verify into Stage 5's eval recipes.

**Phase C — Continuous Dev wraps Conductor (later):**
9. Refactor `continuous-dev.yaml` to treat each overnight cycle as a micro-track using conductor structure.

### Critical risks from reviewer feedback (must honor)

- **Two sources of truth for path** — `project.json` is authoritative; `user.json.projects[]` is just the index.
- **`last_active` is default-highlighted suggestion only.** No persistent "active project" pointer.
- **Canonical path** — resolve symlinks, normalize slashes, lowercase drive letters on Windows. Dedupe by canonical path.
- **Project.json privacy** — decide committed vs gitignored; document. Default: gitignored (recommend users add `.goose/conductor/` to target repo's .gitignore).
- **RECIPE-PREAMBLE carve-out** — if conductor recipes read `<target>/.goose/conductor/*.md`, the "ignore CLAUDE.md" rule in preamble needs a carve-out for those reads.
- **Installer update** — `setup-goose.ps1` needs to create `~/.rilgoose/`. May need to count nested `recipes/agents/config/*.yaml` (currently only counts top-level).
- **Graduated recipes have no project-picker step today.** Decide: add one, or leave graduated as single-cwd tools for now.
- **Multi-user-on-one-laptop** — out of scope unless Reliance explicitly needs it. Flag.

---

## Part 3 — Kickoff prompt for the next session

Copy everything between the dashed lines into a fresh Claude Code session in `C:\Users\donid\ClaudeProjects\RILGoose`.

---

Continue from the RIL-agents port completion. This session's job is to (a) migrate RILGoose progression to per-user state, and (b) build the Conductor-as-native-Goose system.

**Read these first, in order:**
1. `handoffs/ril-agents-port-complete-and-next-steps-2026-04-15.md` — full design + locked decisions + build order
2. `CLAUDE.md` — reframed to match the ports
3. `recipes/ported-agents/` — read 2-3 ports to internalize the canonical Goose recipe structure
4. `~/ClaudeInfra/ril-agents/plugins/conductor/` — read-only; do NOT modify. Source for the conductor port.

**Execute Phase A:**

**Step 1 — Stage 1.5a (per-user progression).** 86 files reference `progression.json`. Safe order per reviewer feedback:
- Write `recipes/agents/progression/migrate-progression.yaml` — one-shot idempotent migration from `.goose/state/progression.json` to `~/.rilgoose/progression.json`.
- Write a shared preamble stanza (or update `recipes/RECIPE-PREAMBLE.md`) that every recipe's Step 0 includes: "Read `~/.rilgoose/progression.json`. If missing, check `.goose/state/progression.json` and migrate."
- Update `recipes/agents/check-progress.yaml` and `recipes/agents/graduate-module.yaml` to use the new path.
- Sweep the 27 stage recipes in `recipes/shared/` to use the new path.
- Update `install/setup-goose.ps1` to create `~/.rilgoose/` on install.
- Verify with a grep: no live recipe still reads `.goose/state/progression.json` directly; all go through the preamble stanza or have migration-compat.
- Commit: `Stage 1.5a: Migrate progression to per-user state`.

**Step 2 — Port the 5 conductor reference docs.** Faithful ports, no loss:
- `recipes/ported-agents/conductor/README.md` (from `~/ClaudeInfra/ril-agents/plugins/conductor/README.md`)
- `recipes/ported-agents/conductor/skills/context-driven-development.md` (from `skills/context-driven-development/SKILL.md`, ~393 lines)
- `recipes/ported-agents/conductor/skills/track-management.md` (from `skills/track-management/SKILL.md`, ~593 lines)
- `recipes/ported-agents/conductor/skills/workflow-patterns.md` (from `skills/workflow-patterns/SKILL.md`, ~623 lines)
- `recipes/ported-agents/conductor/references/artifact-templates.md` (from `skills/context-driven-development/references/artifact-templates.md`)
- Remove frontmatter `name:` / `version:` from top of SKILL files during port (or convert to RILGoose-style).
- Commit: `Port conductor reference docs into recipes/ported-agents/conductor/`.

**Step 3 — Build `ensure-config.yaml` + `setup-config.yaml`.**
- `recipes/agents/config/ensure-config.yaml` — read `~/.rilgoose/user.json`. If missing, trigger first-time flow. If present, return the active project's paths. Migrate legacy `.goose/state/user_config.json` if detected.
- `recipes/shared/setup-config.yaml` — the unified multi-project config recipe. First run: ask user+project questions, write user.json + project.json. Subsequent runs: show projects list, ask (add new / modify / set active). Writes use atomic tmp+rename+backup pattern.
- Write schema doc `docs/config-schema.md` (or inline in ensure-config.yaml).
- Design doc in `ideas/conductor-config-design.md` (NOT `handoffs/`).
- Commit: `Add unified config recipe + multi-project support`.

**Step 4 — Build 9 conductor agent primitives.** See Part 2 topology. Each follows canonical Goose recipe structure (Role → team_context read → Constraints → Failure Modes → Process → Return). Each accepts `project_id` (optional; defaults to active project in `user.json`). Read `recipes/ported-agents/conductor/skills/*.md` for behavior spec.

**Step 5 — Build 6 conductor working recipes.** See Part 2 topology. Each is a facilitator (interactive) that:
- Loads `ensure-config` at start
- Reads `<target>/.goose/conductor/project.json`
- Delegates to agent primitives for actual file operations
- Presents checkpoints to user for approval
- Commits with the right metadata (git notes, SHA recording in plan.md)

- Commit: `Add 6 conductor working recipes + 9 agent primitives`.

**Step 6 — Review + fix + final commit.** Spin up 4 subagents (2 Claude + 2 Codex) to stress-test the conductor system end-to-end. Fix what they find. Commit. Push.

**Hard constraints:**
- `~/ClaudeInfra/ril-agents/` is READ-ONLY. Never modify.
- Conductor artifacts go in `<target>/.goose/conductor/`, NOT in target repo root.
- `project.json` is authoritative for project settings; `user.json.projects[]` is just an index.
- CWD is always RILGoose repo root. Target accessed by absolute path.
- Canonical-path dedup required for Windows (symlinks, slashes, case).
- All config writes atomic (tmp + rename + backup).
- Headless/scheduled conductor: accept `project_id` parameter, no interactive picker in that path.
- Use `~/.rilgoose/` NOT `~/.goose/rilgoose/`.

**Curriculum integration (Phase B) is NOT in scope for this session.** Just build the foundation.

Report back with: "Phase A complete. N files created, M files modified, grep verified, all recipes pass validation." and the path to a Phase-A completion handoff doc.

---

That's the kickoff prompt.

---

## Appendix — Things NOT done this session (deliberate)

| Item | Why | Where it's tracked |
|---|---|---|
| Stage 1.5a progression migration | 86 files — too broad for remaining context | Next session Step 1 |
| Conductor digest doc | Scope changed — full native port instead | Next session Steps 2-5 |
| Multi-project config | Dependent on conductor work | Next session Step 3 |
| Curriculum integration | Saved for Phase B | Next-next session |
| Subagent reviews of Stages 3-4 | Stages 3-4 are mechanical path rewires; low risk. Stage 5 is this doc. | Skipped deliberately |
| Minor "invented content" from port reviews (e.g., code-reviewer severity taxonomy, legacy-modernizer atomic-commit constraint) | Defensible additions, not regressions. Not blocking. | Documented above; revisit if it causes issues |
| TWO-MODE-PATTERN.md lines 92/115 | File marked SUPERSEDED; original handover said leave or update for consistency. Chose leave. | n/a |
