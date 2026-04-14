# Handoff: GooseForge + Three-Recipe-Type Architecture

**Date:** 2026-04-13
**Status:** GooseForge reference library and recipes COMPLETE. Three-recipe-type architecture designed but not yet applied to existing modules.
**Prior handoff:** `handoffs/recipe-reveal-iteration.md`

---

## What Was Done This Session

### 1. Three-Recipe-Type Architecture (replaces two-mode pattern)

Every module now has three recipe files:
- **Agent primitives** (`recipes/agents/`) — Clean, non-interactive workers. Called as sub-recipes. Not visible to developers.
- **Training recipes** (`recipes/shared/`) — Interactive facilitators labeled "(Training)". Talk to developer, narrate delegation, call primitives as sub-recipes.
- **Graduated recipes** (`recipes/graduated/`) — Daily-use recipes. Replace training recipes on module completion.

**Key decisions (confirmed by Doni):**
- Gateway (START HERE) uses check-progress sub-recipe, directs developer to open next training recipe from Recipes list
- Graduated recipes REPLACE training recipes (not alongside)
- Training recipes labeled "(Training)" — e.g., "1.1 Bug Fix (Training)". Graduated versions just "Bug Fix"

### 2. GooseForge — Recipe Design System

SubagentForge concepts forked for Goose. NOT a two-format output — the output IS a Goose recipe YAML.

**Forge process:** Discovery → Research → Design → Validate

The Research phase is the key differentiator:
1. Classify agent archetype (reviewer, builder, coordinator, evaluator, investigator)
2. Search RIL agents (112+) for similar patterns
3. Load archetype-specific best practices from `recipes/forge-references/`
4. Surface relevant design principles and anti-patterns
5. Then design the recipe informed by research

**GooseForge recipes:**
- `agents/recipe-forge.yaml` — Primitive: structured inputs + research → recipe YAML
- `agents/recipe-validate.yaml` — Primitive: quality gate
- `graduated/recipe-forge.yaml` — Interactive daily-use tool
- `graduated/team-forge.yaml` — Design recipe teams
- `recipes/forge-references/` — Archetype best practices, design principles, anti-patterns

**Integration with curriculum:** Used as a tool during Stage 3 exercises. Graduated after Stage 3.

### 3. Syllabus Updates Made

- Architecture diagram updated (Training Recipe → Agent Primitive → Eval → Graduation)
- Agent role descriptions updated (Facilitator → Training Recipe, Code-Work Subagent → Agent Primitive, added Graduated Recipe)
- Progress Tracking updated with graduation side-effect
- Inter-stage gates updated with recipe list changes
- Stage 1 description updated with training recipe + agent primitive flow
- Bridge to Stage 2 mentions recipe list changes
- Stage 3 completely rewritten to integrate GooseForge (discovery + research process)
- RIL Agents table updated to reference agent primitives
- "What Developers See in the Goose App" section added
- Recipe Architecture section added (folder structure, patterns)
- Binary-signals decision marked as superseded by quality-ratings
- 6 new Decision Log entries (three recipe types, graduation replaces, naming convention, invisible primitives, gateway dispatch, GooseForge)

### 4. Plan Updates Made

- Folder structure updated with GooseForge files (forge-references/, graduated forge recipes)
- Phase 4 added: GooseForge adaptation (primitives, graduated, references, Stage 3 adaptations)
- Decisions section updated with Doni's confirmed answers

---

## GooseForge Port — COMPLETE

All research subagents completed. All reference files and recipes written.

### Files Created

**Reference library (`recipes/forge-references/`):**
- `design-principles.md` — 16 principles (12 core + 4 Goose-specific), adapted from SubagentForge's 18
- `canonical-recipe-structure.md` — 10-section directive mapped to Goose YAML with concrete template
- `archetype-reviewer.md` — Patterns, constraints, failure modes from RIL code-reviewer, team-reviewer, security-auditor
- `archetype-builder.md` — Patterns from RIL team-implementer, legacy-modernizer
- `archetype-coordinator.md` — Patterns from RIL team-lead, conductor-validator, tdd-orchestrator
- `archetype-evaluator.md` — Patterns from RIL product-evaluation, post-mortem
- `archetype-investigator.md` — Patterns from RIL debugger, error-detective
- `anti-patterns.md` — 6 universal + 15 archetype-specific anti-patterns + 10 YAML generation pitfalls
- `validation-checklist.md` — 37-item Goose-adapted checklist + 6 quality detectors

**Agent primitives (`recipes/agents/`):**
- `recipe-forge.yaml` — Non-interactive: structured inputs + research context → recipe YAML
- `recipe-validate.yaml` — Non-interactive: recipe file → validation report (37 checks + 6 detectors)

**Graduated recipes (`recipes/graduated/`):**
- `recipe-forge.yaml` — Interactive: Discovery (9 questions) → Research (archetype + RIL agents + best practices) → Design (call forge primitive) → Validate (call validate primitive)
- `team-forge.yaml` — Interactive: Team discovery → Contract design → Research → Design specialists → Design coordinator → Validate all

---

## What Needs Doing Next

### Priority 1 (was GooseForge Port): DONE

~~1. Write the 5 archetype reference docs~~ DONE
~~2. Write the design principles doc~~ DONE
~~3. Write the canonical recipe structure template~~ DONE
~~4. Write the anti-patterns doc~~ DONE
~~5. Write `recipes/agents/recipe-forge.yaml`~~ DONE
6. Write `recipes/agents/recipe-validate.yaml` — the validation primitive
7. Write `recipes/graduated/recipe-forge.yaml` — the interactive daily-use forge
8. Write `recipes/graduated/team-forge.yaml` — team design tool

### Priority 2: Implement Three-Recipe-Type Architecture

1. Extract agent primitives from existing module recipes (Phase 1 of plan)
2. Rewrite training recipes to call primitives as sub-recipes (Phase 2)
3. Create gateway (00-start-here.yaml) with check-progress sub-recipe
4. Create graduated recipes (Phase 3)
5. Create graduate-module.yaml automation

### Priority 3: Update Stage 3 Recipes for GooseForge

1. Adapt 09-three-agent-pipeline.yaml training recipe to use GooseForge discovery + research
2. Adapt 10-parallel-reviewers.yaml training recipe
3. Adapt 11-escalation-routing.yaml training recipe
4. Update Stage 3 agent primitives to accept structured agent definitions as input

### Priority 4: Update Module Designer Skill

`teaching/meta/module-designer/SKILL.md` still references old two-artifact model. Update to three-recipe-type architecture.

### Priority 5: Update CLAUDE.md

Project structure section needs `recipes/agents/`, `recipes/graduated/`, `recipes/forge-references/` added.

---

## Key Files Changed

| File | What Changed |
|------|-------------|
| `ideas/syllabus.md` | Major update — architecture, Stage 3, decision log, new sections |
| `.claude/plans/logical-baking-lake.md` | Full plan with GooseForge Phase 4 |

## Key Files to Read

| File | Why |
|------|-----|
| `ideas/syllabus.md` | Source of truth — all design decisions |
| `.claude/plans/logical-baking-lake.md` | Implementation plan |
| `~/ClaudeProjects/SubagentForge/docs/design-principles.md` | Source for GooseForge adaptation |
| `~/ClaudeProjects/SubagentForge/examples/code-reviewer.agent.yaml` | Reference implementation |
| `~/ClaudeProjects/SubagentForge/schemas/agent-schema-v1.yaml` | Schema to adapt |
