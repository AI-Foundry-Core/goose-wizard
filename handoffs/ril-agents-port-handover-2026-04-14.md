# Handover: RIL Agents Port — Ready to Execute

**Date:** 2026-04-14
**Status:** Inventory complete and approved. Plan locked. Ready for port execution (stages 2-5).
**Prior inventory:** `handoffs/ril-agents-port-inventory.md` (committed at `b7436e4`)

---

## The one-line goal

Port every RIL-agents file currently referenced by goose-wizard into the goose-wizard repo itself, so goose-wizard stops depending on `~/ClaudeInfra/ril-agents/` at runtime. RIL-agents becomes lineage/inspiration, not a live reference. **Do NOT modify `~/ClaudeInfra/ril-agents/` — it's read-only and other systems depend on it.**

---

## What was decided this session

1. **Scope:** 12 agent `.md` files to port one-for-one → 12 YAML files + 1 new digest doc for conductor patterns = **13 total files to create**.
2. **Layout:** Everything goes under `recipes/ported-agents/<plugin>/<name>.yaml`.
3. **Conductor handling:** Don't port the 30+ file conductor plugin. Instead, write ONE digest doc (`recipes/ported-agents/conductor/continuous-dev-patterns.md`, ~100-200 lines) that captures the patterns relevant to `continuous-dev.yaml`, written in goose-wizard's voice, derived from conductor's three skills.
4. **Misreferences:** Three current recipe paths point to files that don't exist at that path. Fix during port:
   - `observability-monitoring/agents/post-mortem.md` → actually at `product-evaluation/agents/post-mortem.md`
   - `observability-monitoring/agents/product-evaluation.md` → actually at `product-evaluation/agents/product-evaluation.md`
   - `agent-orchestration/agents/tutorial-engineer.md` → use `code-documentation/agents/tutorial-engineer.md`
5. **Open-ended searches:** `pipeline-forge.yaml` and `recipe-forge.yaml` have lines that tell the agent to "search `~/ClaudeInfra/ril-agents/plugins/`" for patterns. Replace with local references (`recipes/forge-references/` and `recipes/ported-agents/`).

---

## The 12 agent files to port

Source path → ported destination:

| # | Source (read-only) | Ported destination |
|---|---|---|
| 1 | `~/ClaudeInfra/ril-agents/plugins/error-debugging/agents/debugger.md` | `recipes/ported-agents/error-debugging/debugger.yaml` |
| 2 | `~/ClaudeInfra/ril-agents/plugins/error-debugging/agents/error-detective.md` | `recipes/ported-agents/error-debugging/error-detective.yaml` |
| 3 | `~/ClaudeInfra/ril-agents/plugins/product-evaluation/agents/post-mortem.md` | `recipes/ported-agents/product-evaluation/post-mortem.yaml` |
| 4 | `~/ClaudeInfra/ril-agents/plugins/product-evaluation/agents/product-evaluation.md` | `recipes/ported-agents/product-evaluation/product-evaluation.yaml` |
| 5 | `~/ClaudeInfra/ril-agents/plugins/comprehensive-review/agents/code-reviewer.md` | `recipes/ported-agents/comprehensive-review/code-reviewer.yaml` |
| 6 | `~/ClaudeInfra/ril-agents/plugins/comprehensive-review/agents/architect-review.md` | `recipes/ported-agents/comprehensive-review/architect-review.yaml` |
| 7 | `~/ClaudeInfra/ril-agents/plugins/product-planning/agents/prd-development.md` | `recipes/ported-agents/product-planning/prd-development.yaml` |
| 8 | `~/ClaudeInfra/ril-agents/plugins/unit-testing/agents/test-automator.md` | `recipes/ported-agents/unit-testing/test-automator.yaml` |
| 9 | `~/ClaudeInfra/ril-agents/plugins/code-refactoring/agents/legacy-modernizer.md` | `recipes/ported-agents/code-refactoring/legacy-modernizer.yaml` |
| 10 | `~/ClaudeInfra/ril-agents/plugins/product-specification/agents/feature-spec.md` | `recipes/ported-agents/product-specification/feature-spec.yaml` |
| 11 | `~/ClaudeInfra/ril-agents/plugins/product-specification/agents/acceptance-criteria.md` | `recipes/ported-agents/product-specification/acceptance-criteria.yaml` |
| 12 | `~/ClaudeInfra/ril-agents/plugins/code-documentation/agents/tutorial-engineer.md` | `recipes/ported-agents/code-documentation/tutorial-engineer.yaml` |

**Plus 1 new file:** `recipes/ported-agents/conductor/continuous-dev-patterns.md` (digest, not a direct port).

Lines vary 33-220 per source. All 12 source files are self-contained — no transitive deps on skills or other files.

---

## Port mechanics (per agent)

Each source `.md` has this shape:

```markdown
---
name: debugger
description: Debugging specialist for errors, test failures...
model: sonnet
---

You are an expert debugger specializing in root cause analysis.

When invoked:
1. Capture error message...

Debugging process:
- Analyze error messages and logs
...
```

Map to Goose recipe YAML:

```yaml
version: 1.0.0
title: "Debugger Agent"
description: "Debugging specialist for errors, test failures, and unexpected behavior."

parameters: []  # or inferred from source if relevant

instructions: |
  You are a debugging specialist. [Short version of the original intro.]

  ## Constraints
  IMPORTANT:
  - NEVER [3+ specific don'ts extracted from source]

  ## Process
  [Steps from source]

  ## Return
  [Structured outputs based on source]

extensions:
  - type: builtin
    name: developer

prompt: |
  [The operational content — the "You are an expert debugger..." body]
```

**Rules:**
- Preserve identity, directives, tool focus, evaluation criteria faithfully
- Don't "improve" behavior during the port — separate change
- Each ported YAML must pass `recipes/forge-references/validation-checklist.md` (37 checks)
- YAML frontmatter `model: sonnet` is ignored (Goose handles models at platform level)
- Keep the files short — the original `.md` files are lean, the ports should be too

---

## Files that need rewiring after port

### 21 recipe YAMLs (change `~/ClaudeInfra/ril-agents/...` paths to `recipes/ported-agents/...`)

- `recipes/agents/bug-fix.yaml` (uses debugger, error-detective)
- `recipes/agents/test-writer.yaml` (uses test-automator)
- `recipes/agents/code-review.yaml` (uses code-reviewer, architect-review)
- `recipes/agents/refactor.yaml` (uses legacy-modernizer)
- `recipes/agents/review-gate.yaml` (uses code-reviewer)
- `recipes/agents/independent-tester.yaml` (uses test-automator)
- `recipes/agents/eval-foundation.yaml` (uses product-evaluation, post-mortem) — fix misreference
- `recipes/agents/eval-design.yaml` (uses product-evaluation) — fix misreference
- `recipes/agents/eval-layers.yaml` (uses product-evaluation) — fix misreference
- `recipes/agents/eval-gate.yaml` (uses product-evaluation, post-mortem) — fix misreference
- `recipes/agents/eval-isolation.yaml` (uses product-evaluation) — fix misreference
- `recipes/agents/eval-ratchet.yaml` (uses product-evaluation, post-mortem) — fix misreference
- `recipes/agents/cycle-review.yaml` (uses post-mortem) — fix misreference
- `recipes/agents/continuous-dev.yaml` (uses conductor digest — new local path)
- `recipes/agents/idea-to-spec.yaml` (uses prd-development)
- `recipes/agents/spec-decomposition.yaml` (uses feature-spec, acceptance-criteria)
- `recipes/agents/spec-review.yaml` (uses product-evaluation)
- `recipes/agents/spec-to-pipeline.yaml` (uses prd-development, feature-spec)
- `recipes/agents/skill-evolution.yaml` (uses tutorial-engineer) — fix misreference
- `recipes/graduated/pipeline-forge.yaml` — replace "search `agent-teams/`" with pointer to `recipes/forge-references/`
- `recipes/graduated/recipe-forge.yaml` — replace "search `plugins/`" with pointer to `recipes/ported-agents/` and `recipes/forge-references/`

### 3 teaching/reference docs

- `recipes/forge-references/validation-checklist.md` — line 54 says "Any `~/ClaudeInfra/ril-agents/` references point to agents that exist." Update to check local `recipes/ported-agents/` paths.
- `teaching/meta/module-designer/SKILL.md` — line 78 mentions `~/ClaudeInfra/ril-agents/`. Update to `recipes/ported-agents/`.
- `teaching/meta/module-designer/references/ril-agents-map.md` — whole file references external paths. Rewrite to point at `recipes/ported-agents/`. Consider renaming to `ported-agents-map.md`.
- `teaching/meta/module-designer/references/goose-recipe-format.md` — line 29 has a sample path pointing at `~/ClaudeInfra/ril-agents/plugins/[domain]/agents/[agent].md`. Update to `recipes/ported-agents/[plugin]/[agent].yaml`.
- `recipes/TWO-MODE-PATTERN.md` — lines 92, 115 reference the external path. File is marked SUPERSEDED but still has references. Either leave (it's historical) or update for consistency — flag in the completion handoff either way.

### High-level docs (rewrite to describe RIL-agents as lineage, not runtime)

- `CLAUDE.md` — line citing `~/ClaudeInfra/ril-agents/` in "Cross-Project References" section. Update to say RIL-agents was the inspiration; the ported versions are in `recipes/ported-agents/`.
- `REFERENCES.md` — check for any runtime references
- `HOW_GOOSE_WORKS.md` — check for any runtime references
- `ideas/syllabus.md` — check for any runtime references

---

## Commit staging (don't batch)

1. **Stage 1 — Inventory** — ALREADY DONE (`b7436e4`). File: `handoffs/ril-agents-port-inventory.md`.
2. **Stage 2 — Port** — create all 12 YAML files + 1 conductor digest. Commit: `Port 12 RIL agents and conductor digest into recipes/ported-agents/`.
3. **Stage 3 — Rewire** — update all 21 recipe YAMLs + 4 teaching/reference docs. Commit: `Rewire all recipes to use local recipes/ported-agents/ paths`.
4. **Stage 4 — Top-level docs** — update CLAUDE.md, REFERENCES.md, HOW_GOOSE_WORKS.md. Commit: `Reframe RIL-agents as lineage, not runtime reference`.
5. **Stage 5 — Verify & completion handoff** — run grep, validate, write `handoffs/ril-agents-port-complete.md`. Commit: `RIL-agents port complete: zero runtime dependencies`.

---

## Verification (stage 5)

1. **Grep check** — `grep -r "ClaudeInfra/ril-agents"` across the goose-wizard repo should return zero matches in `recipes/`, `teaching/`, `CLAUDE.md`, `REFERENCES.md`, `HOW_GOOSE_WORKS.md`. Historical references in `handoffs/` and `overnight-pipeline/runs/*/transcripts/` can stay — flag them in the completion handoff.
2. **Validation** — every ported YAML passes the 37-check list at `recipes/forge-references/validation-checklist.md`. For each of the 12 ported agents + updated rewire recipes, run validation (ideally `goose recipe validate <path>`; if Goose can't run in the harness, self-check against the list).
3. **Completion handoff** — write `handoffs/ril-agents-port-complete.md` with:
   - List of files created (expect 13)
   - List of files modified (expect ~26)
   - Grep verification output (before/after counts)
   - Validation results (pass/fail per file)
   - Anything that had to deviate from this plan

---

## Hard constraints

- **Read-only:** do NOT modify anything in `~/ClaudeInfra/ril-agents/`. Other systems depend on it.
- **One-for-one:** don't merge, refactor, or consolidate agents during the port. One source `.md` → one ported `.yaml`. The conductor digest is the ONLY exception, because we decided it's a derivative reconstruction, not a port.
- **No silent inventions:** if a source agent references something missing, stop and flag it in the completion handoff, don't fabricate content.
- **Commit in stages** — five distinct commits per the staging above, not one mega-commit.

---

## Prior session context (for the fresh session to pick up cleanly)

- Main branch is `main`. Last commits before this handover:
  - `b7436e4` — Inventory
  - `673bbdf` — single source of truth for target codebase (user_config.json)
- goose-wizard uses a three-recipe architecture: `recipes/shared/` (training, visible), `recipes/agents/` (primitives, sub-recipes), `recipes/graduated/` (coordinators, unlocked post-completion). Ported agents go under a NEW directory `recipes/ported-agents/` which is neither on GOOSE_RECIPE_PATH nor in the graduation chain — they're referenced by absolute relative path from other recipes.
- There's a branch-switching linter quirk in this environment — if a commit lands on a feature branch instead of main, do `git checkout main && git merge <branch> --ff-only && git push origin main` and move on. Don't force-push anything.
- The `.goose/state/user_config.json` file (introduced earlier today) captures the target codebase path. Not relevant to this port but good to know it exists.

---

## Prompt for tomorrow (paste into fresh Claude Code session)

See adjacent file: `handoffs/ril-agents-port-kickoff-prompt.md`.
