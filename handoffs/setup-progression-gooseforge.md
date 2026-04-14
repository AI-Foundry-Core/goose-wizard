# Handoff: Setup Script, Progression Validation, GooseForge Integration

**Date:** 2026-04-14
**Status:** All three priorities complete with 4-subagent reviews per change set.
**Prior handoff:** `handoffs/three-recipe-architecture-complete.md`

---

## What Was Done This Session

### 1. Setup Script Update (install/setup-goose.ps1)

Updated for the three-recipe-type architecture:
- **Added agents/ and graduated/ validation** — script now validates all three directories exist, not just shared/. Exits with error if agents/ or graduated/ are missing.
- **Added file counts** — shows count for each directory (29 agents, 27 shared, 5 graduated)
- **Added sanity checks** — warns if counts are below expected (28/5/26 thresholds)
- **Added .goose/state/ creation** — ensures progression state directory exists
- **Updated summary output** — explains the three-recipe architecture to the user
- **Updated CLI example** — `goose run --recipe start-here` instead of `see-what-ai-can-do`

**Bug fixes from 4-subagent review (2 Claude + 2 Codex):**
- Fixed `Select-String` without `(?m)` flag — used `$Matches[1]` from `-match` operator instead
- Fixed `Join-Path` with 3 arguments — PS 5.1 only supports 2, used nested calls
- Fixed em dashes in error messages — replaced with ASCII hyphens for PS 5.1 compatibility
- Fixed `$extraPaths` array context — wrapped in `@()` to force array type
- Tightened sanity check thresholds to match messages (28/5/26, not 25/3/20)
- Reused `$gatewayPath` variable instead of creating duplicate `$gatewayRecipe`

**Pre-existing issues noted (not fixed — existed before this session):**
- Here-string CRLF/LF sensitivity in ACP Patch 4 (thinking tokens)
- `$ErrorActionPreference = "Stop"` can terminate on native command stderr
- No backup of acp-agent.js before patching
- Hardcoded npm module path instead of deriving from `Get-Command`

### 2. Progression.json Schema Validation

**Slug validation: ALL 25 modules pass.** Every training recipe's module_number and module_name matches progression.json. Every graduation source exists. Every target file exists.

**Concept numbering: FIXED across all stages.** Teaching scripts used skill-based sub-concepts (e.g., 4.1+4.2 per module) while progression.json uses module-based concepts (one per module). This would have caused State Update sections to write eval ratings to wrong concept entries.

Fixed 20+ teaching scripts across stages 2-7:
- **Stage 2:** build-then-test (2.1+2.2 → 2.1), review-gate (2.3 → 2.2), spec-first (2.4 → 2.3)
- **Stage 3:** three-agent-pipeline (3.1-3.3 → 3.1), parallel-reviewers (3.4-3.5 → 3.2), escalation-routing (prereqs fixed)
- **Stage 4:** idea-to-spec (4.1+4.2 → 4.1), spec-decomposition (4.3+4.4 → 4.2), spec-review (4.5+4.6 → 4.3), spec-to-pipeline (completion check 4.1-4.6 → 4.1-4.4)
- **Stage 5:** eval-design (5.4 → 5.2), eval-layers (5.2 → 5.3), eval-gate (5.6 → 5.4), eval-ratchet (5.3 → 5.6)
- **Stage 6:** cycle-review (6.1-6.3 → 6.2), continuous-dev (6.4-6.6 → 6.1)
- **Stage 7:** metrics-dashboard (7.4 → 7.1), pipeline-self-edit (7.3+7.5 → 7.2), skill-evolution (7.1+7.2 → 7.3)

All file headers, setup checks, state updates, and stage completion checks now match progression.json.

### 3. Stage 3 GooseForge Integration

Added GOOSEFORGE CONNECTION sections to all 3 Stage 3 modules — both training recipes and teaching scripts:

- **09-three-agent-pipeline** → connects to Pipeline Forge. Shows how Pipeline Forge's Pattern Matching (Phase 2) would recognize the three-agent-pipeline pattern. Offers to try Pipeline Forge on a variation.
- **10-parallel-reviewers** → connects to Recipe Forge. Shows how Recipe Forge designs custom reviewer layers (different archetypes, different focus areas). Offers to try designing a custom review layer.
- **11-escalation-routing** → connects to Pipeline Forge. Shows how Pipeline Forge's coordinator design (Phase 7) automatically includes circuit breakers and escalation routing. Offers to try designing a new pipeline with built-in safety.

Also split the collapsed "EVAL + RECIPE REVEAL + STATE UPDATE + BRIDGE" section headers in recipes 10 and 11 into separate labeled blocks for consistency with recipe 09.

---

## Review Results (12 subagent reviews total)

| Priority | Claude Reviews | Codex Reviews | Issues Found | Issues Fixed |
|----------|---------------|---------------|-------------|-------------|
| Setup Script | 2 (both complete) | 2 (1 complete, 1 timeout) | 8 actionable | 6 fixed, 2 pre-existing |
| Progression | 2 (both complete) | 1 (complete) | 5 remaining bugs + stale teacher-instructions.md | All fixed |
| GooseForge | 2 (both complete) | 1 (complete) | 3 issues | 2 fixed, 1 design note |

**Additional fixes from final Codex review:**
- Fixed "open from recipe list" wording — graduated recipes aren't on GOOSE_RECIPE_PATH, changed to CLI commands (`goose run --recipe recipes/graduated/...`)
- Fixed stale concept references in `teaching/meta/teacher-instructions.md` (checkpoints 2.2→2.1, 2.4→2.3, 3.5→3.3, 4.2→4.1, 4.5→4.3)
- **Design note:** GooseForge integration is post-coaching (show the tool after the exercise), not during-exercise (use the tool as part of the exercise). The post-coaching approach is pedagogically sound (learn by hand first, then see the tool), but differs from the original priority wording.

---

## What Needs Doing Next

### Priority 1: Test in Real Goose (carried from prior handoff)
Same priority — nothing has been validated in the actual Goose runtime yet.

### Priority 2: Teaching Script Quality Audit (carried from prior handoff)
Headers and concept numbering are now correct. Content quality still needs auditing — Stage 2-7 scripts may have stub-quality content from the overnight pipeline.

### Priority 3: Pre-existing Setup Script Issues
From the Codex review — not fixed because they're pre-existing, not from our changes:
- Here-string CRLF/LF mismatch in Patch 4 (may silently fail)
- `$ErrorActionPreference = "Stop"` with native commands (can terminate on stderr)
- No backup of acp-agent.js before applying 5 patches
- Hardcoded npm module path

### Priority 4: Stage 0 Sub-Concept Numbering
Codex flagged that Stage 0 teaching acts use concepts 0.1-0.5 but progression.json only has one Stage 0 module (concept 0.1). This may be intentional (acts are sub-parts of one module) but should be verified.

---

## Key Files Changed

| File | What Changed |
|------|-------------|
| `install/setup-goose.ps1` | Added agents/graduated validation, fixed PS 5.1 bugs |
| `recipes/shared/09-three-agent-pipeline.yaml` | Added GOOSEFORGE CONNECTION section |
| `recipes/shared/10-parallel-reviewers.yaml` | Added GOOSEFORGE CONNECTION, split section headers |
| `recipes/shared/11-escalation-routing.yaml` | Added GOOSEFORGE CONNECTION, split section headers |
| `teaching/stage-2/*.teach.md` (3 files) | Fixed concept numbering in headers, setup, state updates |
| `teaching/stage-3/*.teach.md` (3 files) | Fixed concept numbering, added GooseForge Connection |
| `teaching/stage-4/*.teach.md` (4 files) | Fixed concept numbering, stage completion checks |
| `teaching/stage-5/*.teach.md` (4 files) | Fixed concept numbering in headers, setup, state updates |
| `teaching/stage-6/*.teach.md` (2 files) | Fixed concept numbering in headers, setup, state updates |
| `teaching/stage-7/*.teach.md` (3 files) | Fixed concept numbering in headers, setup, state updates |
| `LEARNINGS.md` | Added session findings |
