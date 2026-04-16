# Handoff: Three-Recipe-Type Architecture Complete

**Date:** 2026-04-14
**Status:** All 6 handoff priorities from `gooseforge-complete-next-steps.md` are done. Architecture is fully wired end-to-end.
**Repo:** https://github.com/AI-Foundry-Core/Goose Wizard (private)
**Prior handoff:** `handoffs/gooseforge-complete-next-steps.md`

---

## What Was Done This Session

### 1. Pipeline Forge (replaces Team Forge)

Redesigned Team Forge as Pipeline Forge — thinks in stages/patterns instead of team roles. Key design decisions validated by 2 subagent reviews:
- Pipeline framing > team framing (developers think in pipelines, not teams)
- Pattern recognition surfaced explicitly (offers known Stage 2-3 patterns)
- 6 discovery questions (added "what data passes between steps?")
- Composition limit: max 2 known patterns per pipeline
- Safety rails required phase (not optional)
- Save location asked before generating (fixes path validation bug from Team Forge)

Files: `recipes/graduated/pipeline-forge.yaml` (new), `recipes/graduated/team-forge.yaml` (deleted)

### 2. Full Three-Recipe-Type Conversion (all 26 modules)

Every module converted from two-mode pattern to three recipe types:

**Agent primitives created (29 in `recipes/agents/`):**
- Stage 1: bug-fix, test-writer, code-review, refactor
- Stage 2: builder, independent-tester, review-gate, spec-first
- Stage 3: spec-writer, escalation-routing
- Stage 4: idea-to-spec, spec-decomposition, spec-review, spec-to-pipeline
- Stage 5: eval-foundation, eval-design, eval-layers, eval-gate, eval-isolation, eval-ratchet
- Stage 6: continuous-dev, cycle-review
- Stage 7: metrics-dashboard, pipeline-self-edit, skill-evolution
- System: check-progress, graduate-module
- GooseForge: recipe-forge, recipe-validate

**Training recipes rewritten (27 in `recipes/shared/`):**
- All titles end with "(Training)"
- All call agent primitives via `sub_recipes:`
- All have 6 behavioral rules in instructions, full teaching flow in prompt
- All have graduation wired in (see below)

**Graduated coordinators (5 in `recipes/graduated/`):**
- build-then-test, three-agent-pipeline, parallel-reviewers (multi-agent modules)
- recipe-forge, pipeline-forge (GooseForge)
- Single-agent modules don't need graduated recipes — the primitive IS the graduated version

**Architecture rule:** Stage 1 + most Stage 4-7 = 2 files (primitive + training). Stage 2-3 multi-agent = 3 files (primitives + training + graduated coordinator).

### 3. Gateway (Start Here)

Rewrote `00-start-here.yaml` as a gateway that:
- Calls `check-progress` sub-recipe to read progression state
- Handles 3 states: new_user, in_progress, all_complete
- Directs developer to open the next training recipe by name
- Removed inline Module 1 script (lives in `01-see-what-ai-can-do.yaml`)

### 4. Graduation Automation

Created `graduate-module` agent primitive and wired it into all 25 training recipes:
- Every training recipe calls `graduate-module` after state update
- Graduation checks `graduated/` first (multi-agent), falls back to `agents/` (single-agent)
- Validates module_number matches module_name in progression.json
- Guards against graduating modules 00 or 01

### 5. Documentation Updates

- **CLAUDE.md**: Current Work section updated, agents/ listing (29 files), graduated/ listing (5 files), stale references removed
- **Module designer skill** (`teaching/meta/module-designer/SKILL.md`): "Two Artifacts" → "Three Recipe Types", all stale terms replaced, runtime flow diagram updated
- **Reference files**: `goose-recipe-format.md` and `example-module.md` rewritten for new architecture
- **Teaching scripts**: bug-fix.teach.md and test-writer.teach.md Recipe Reveal sections updated to point to agent primitives

### 6. Bug Fixes

- `recipe-forge.yaml`: Fixed literal `{{ param }}` / `{{ var }}` in instructions (Goose parsed as real variables)
- `escalation-analyzer.yaml` → renamed to `escalation-routing.yaml` (slug mismatch with training recipe)
- `skill-evolution.yaml`: Fixed classification taxonomy (INSTRUCTION_FIX/UNCLEAR → GAP/VAGUE/MISSING/OUTDATED/NOT_INSTRUCTION)
- Removed 15 stale `# recipes/stage-N/` path comments from training recipes

### 7. GitHub Repo

Created private repo at https://github.com/AI-Foundry-Core/Goose Wizard. All work pushed to main.

---

## Review Results (4 rounds, 14 subagent reviews total)

All findings resolved. Final verification: both Claude and Codex confirmed all 7 prior findings FIXED.

---

## What Needs Doing Next

### Priority 1: Test in Real Goose

Nothing has been validated in the actual Goose runtime yet. Run at least:
- `00-start-here.yaml` → verify check-progress works
- `02-bug-fix.yaml` → verify sub-recipe call to agents/bug-fix works
- `06-build-then-test.yaml` → verify multi-agent sub-recipe chain works
- Graduation → verify graduate-module copies files correctly

### Priority 2: Teaching Script Quality Audit

`bug-fix.teach.md` and `test-writer.teach.md` are detailed (200+ lines each). The Stage 2-7 teaching scripts may be stubs from the overnight pipeline. Audit which ones are production-ready vs need fleshing out.

### Priority 3: Setup Script Update

`install/setup-goose.ps1` still references old `recipes/stage-N/` directory structure. Needs updating for:
- `recipes/shared/` as GOOSE_RECIPE_PATH
- `recipes/agents/` and `recipes/graduated/` excluded from path
- New file count (29 agents, 27 shared, 5 graduated)

### Priority 4: Progression.json Schema Validation

Verify `.goose/state/progression.json` has correct slugs for all 26 modules. Graduation depends on slug matching — if progression.json says "bug-fix" but the agent primitive is named differently, graduation fails.

### Priority 5: Stage 3 GooseForge Integration

Original Priority 4 from prior handoff — adapt Stage 3 training recipes to use GooseForge discovery + research during exercises. Deferred because architecture work took priority.

---

## Key Files to Read

| File | Why |
|------|-----|
| `CLAUDE.md` | Updated source of truth — current work, project structure, key decisions |
| `recipes/agents/bug-fix.yaml` | Reference agent primitive pattern |
| `recipes/shared/02-bug-fix.yaml` | Reference training recipe pattern (with graduation) |
| `recipes/graduated/build-then-test.yaml` | Reference graduated coordinator pattern |
| `recipes/graduated/pipeline-forge.yaml` | Pipeline Forge (new this session) |
| `recipes/agents/graduate-module.yaml` | Graduation automation |
| `recipes/agents/check-progress.yaml` | Gateway progress checker |
| `teaching/meta/module-designer/SKILL.md` | Updated module design skill |

## Key Design Constraints (don't forget these)

1. **Sub-recipes are non-interactive** — run and return results. All developer interaction stays in the training/graduated recipe.
2. **GOOSE_RECIPE_PATH does NOT recurse** — only `recipes/shared/` is scanned. agents/ and graduated/ are invisible.
3. **Instructions are short, prompt is the work** — ~6 rules in instructions, teaching flow in prompt.
4. **Template syntax is `{{ param }}` only** — no conditionals, no filters, no dots.
5. **Opus required** — Sonnet skips detailed instructions.
6. **Single-agent modules graduate via primitive** — no separate graduated recipe needed.
7. **Multi-agent modules graduate via coordinator** — the graduated/ recipe composes primitives.
8. **Graduation is wired but not tested** — the sub-recipe call exists in every training recipe, but it's never been run through Goose.
