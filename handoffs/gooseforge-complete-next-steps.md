# Handoff: GooseForge Complete — Next Steps

**Date:** 2026-04-14
**Status:** GooseForge reference library and recipes complete. Three-recipe-type architecture designed but not yet applied to existing 26 module recipes.
**Prior handoff:** `handoffs/gooseforge-and-recipe-architecture.md`

---

## What Was Done This Session

### 1. Three-Recipe-Type Architecture (major design pivot)

Replaced the "two-mode pattern" (teaching + working in one file) with three separate recipe types:

- **Agent primitives** (`recipes/agents/`) — Clean, non-interactive workers. Called as sub-recipes. Not in GOOSE_RECIPE_PATH, invisible to developers.
- **Training recipes** (`recipes/shared/`) — Interactive facilitators labeled "(Training)". Talk to developer, narrate delegation ("I'm calling our bug-hunting specialist"), call primitives as sub-recipes.
- **Graduated recipes** (`recipes/graduated/`) — Daily-use versions. When a developer completes a training module, the graduated recipe REPLACES the training recipe in shared/. "(Training)" label disappears.

**Key decisions (confirmed by Doni):**
- Gateway (START HERE) uses check-progress sub-recipe, directs developer to open next training recipe
- Graduated recipes REPLACE training recipes (not alongside)
- Training: "1.1 Bug Fix (Training)" → Graduated: "Bug Fix"

### 2. GooseForge — Recipe Design System (port from SubagentForge)

SubagentForge (`~/ClaudeProjects/SubagentForge/`) concepts forked and adapted for Goose. Output is Goose recipe YAML (not SubagentForge's `.agent.yaml`). Key innovation: **Research phase** — before designing, the forge classifies the agent archetype, searches RIL agents for similar patterns, and loads best practices.

**Forge process:** Discovery (9 questions) → Research (archetype + RIL agents + best practices) → Design (call forge primitive) → Validate (37 checks + 6 quality detectors)

### 3. Syllabus Updated

Major updates to `ideas/syllabus.md`:
- Architecture diagram: Training Recipe → Agent Primitive → Eval → Graduation
- New section: "Recipe Architecture" (folder structure, three patterns)
- New section: "What Developers See in the Goose App" (dynamic recipe list)
- Stage 1 description: updated for training recipe + agent primitive flow
- Stage 3 description: completely rewritten to integrate GooseForge
- Bridge to Stage 2: mentions recipe list changes
- RIL Agents table: references agent primitives
- Binary-signals decision: marked superseded
- 7 new Decision Log entries (three recipe types, graduation, naming, invisible primitives, gateway dispatch, GooseForge, CourseForge update)

### 4. Plan Updated

`.claude/plans/logical-baking-lake.md` — full implementation plan with 5 phases.

---

## Files Created This Session

### GooseForge Reference Library (`recipes/forge-references/`)

| File | Contents |
|------|----------|
| `design-principles.md` | 16 principles (12 core + 4 Goose-specific) adapted from SubagentForge's 18 |
| `canonical-recipe-structure.md` | 10-section canonical directive mapped to Goose YAML with concrete template + YAML generation rules |
| `archetype-reviewer.md` | Patterns from RIL code-reviewer, team-reviewer, security-auditor. Constraints, failure modes, anti-patterns. |
| `archetype-builder.md` | Patterns from RIL team-implementer, legacy-modernizer. File ownership, phase workflow. |
| `archetype-coordinator.md` | Patterns from RIL team-lead, conductor-validator. Decompose-before-delegate, lifecycle protocol. |
| `archetype-evaluator.md` | Patterns from RIL product-evaluation, post-mortem. Gap taxonomy, cycle-aware tracking. |
| `archetype-investigator.md` | Patterns from RIL debugger, error-detective. Hypothesis-driven, evidence chains. |
| `anti-patterns.md` | 6 universal + 15 archetype-specific anti-patterns + 10 YAML generation pitfalls |
| `validation-checklist.md` | 37-item Goose-adapted validation checklist + 6 quality detectors (Ghost User, Fog, Accountability, Scope Creep, Trust Mismatch, Intent Gap) |

### GooseForge Recipes

| File | Type | What It Does |
|------|------|-------------|
| `recipes/agents/recipe-forge.yaml` | Agent primitive | Non-interactive: structured inputs + research context → recipe YAML |
| `recipes/agents/recipe-validate.yaml` | Agent primitive | Non-interactive: recipe file → validation report (37 checks + 6 detectors) |
| `recipes/graduated/recipe-forge.yaml` | Graduated | Interactive: Discovery (9 Qs) → Research (archetype + RIL + best practices) → Design (calls forge primitive) → Validate → Save |
| `recipes/graduated/team-forge.yaml` | Graduated | Interactive: Team discovery → Contract design → Research → Design specialists → Design coordinator → Validate all → Save |

### New Directories Created

- `recipes/agents/` — agent primitives (not in GOOSE_RECIPE_PATH)
- `recipes/graduated/` — graduated recipes (promoted to shared/ on completion)
- `recipes/forge-references/` — GooseForge reference library

---

## What Needs Doing Next

### Priority 1: Apply Three-Recipe-Type Architecture to Existing Modules

The 26 existing module recipes in `recipes/shared/` still use the old two-mode pattern. Each one needs to be split:

**For each Stage 0-1 module (6 recipes):**
1. Extract the WORKING MODE section → `recipes/agents/<name>.yaml` (agent primitive)
2. Rewrite the recipe in shared/ as a training wrapper that calls the primitive via `sub_recipes:`
3. Create a graduated version in `recipes/graduated/<name>.yaml`

**Modules to convert (Stage 0-1):**
- `01-see-what-ai-can-do.yaml` — Stage 0 is special (scripted, code work stays inline, no separate primitive needed)
- `02-bug-fix.yaml` → primitive: `agents/bug-fix.yaml`
- `03-test-writer.yaml` → primitive: `agents/test-writer.yaml`
- `04-code-review.yaml` → primitive: `agents/code-review.yaml`
- `05-refactor.yaml` → primitive: `agents/refactor.yaml`

**For Stage 2+ modules (20 recipes):**
- Same pattern but graduated recipes may be significantly different from primitives (multi-agent workflows)
- Stage 3 modules (09, 10, 11) need GooseForge integration in their training recipes

### Priority 2: Rewrite 00-start-here.yaml as Gateway

- Add `sub_recipes:` with `check-progress` agent
- Create `recipes/agents/check-progress.yaml` utility
- Gateway reads progress, directs developer to next training recipe by name
- Remove inline Module 1 script (that content lives in 01-see-what-ai-can-do.yaml)

### Priority 3: Create Graduate-Module Automation

- Create `recipes/agents/graduate-module.yaml`
- Copies graduated recipe from `recipes/graduated/` to `recipes/shared/`
- Removes the training version
- Called by each training recipe on module completion

### Priority 4: Adapt Stage 3 Modules for GooseForge

- Update training recipes for 09, 10, 11 to use GooseForge discovery + research during exercises
- Update agent primitives to accept structured agent definitions as input (not hard-coded roles)
- Teaching scripts need updating to incorporate forge concepts

### Priority 5: Update Module Designer Skill

`teaching/meta/module-designer/SKILL.md` still references old two-artifact model. Update to three-recipe-type architecture.

### Priority 6: Update CLAUDE.md

Project structure section needs:
- `recipes/agents/` — agent primitives
- `recipes/graduated/` — graduated recipes
- `recipes/forge-references/` — GooseForge reference library

---

## Key Files to Read (for continuing this work)

| File | Why |
|------|-----|
| `ideas/syllabus.md` | Source of truth — all design decisions, updated this session |
| `.claude/plans/logical-baking-lake.md` | Implementation plan with all phases |
| `handoffs/gooseforge-and-recipe-architecture.md` | Earlier handoff from same session (more detail on research findings) |
| `recipes/forge-references/canonical-recipe-structure.md` | Template for how new recipes should be structured |
| `recipes/forge-references/validation-checklist.md` | Quality bar for all recipes |
| `recipes/shared/02-bug-fix.yaml` | Example of current two-mode recipe (needs conversion) |
| `recipes/graduated/recipe-forge.yaml` | Example of the new graduated recipe pattern |
| `HOW_GOOSE_WORKS.md` | Goose sub-recipe mechanics, validation rules |

## Key Design Constraints (don't forget these)

1. **Sub-recipes are non-interactive** — they run and return results. All developer interaction stays in the training/graduated recipe.
2. **GOOSE_RECIPE_PATH does NOT recurse** — only explicitly listed directories are scanned. agents/ and graduated/ stay invisible by design.
3. **Instructions are short, prompt is the work** — Goose's system.md buries long instructions. Keep instructions to ~6 behavioral rules.
4. **Template syntax is `{{ param }}` only** — no conditionals, no filters, no dots.
5. **Opus required** — Sonnet ignores detailed recipe instructions (skips acts, invents content). GOOSE_MODEL must be opus.
