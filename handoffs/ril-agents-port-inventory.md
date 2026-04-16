# RIL Agents Port — Inventory

**Date:** 2026-04-14
**Status:** Inventory complete. **12 leaf files to port.** Under the 30-file threshold, so proceeding is safe if you approve.
**Task:** Eliminate goose-wizard's runtime dependency on `~/ClaudeInfra/ril-agents/` by porting every referenced agent into the repo.

---

## Summary

- **12 unique agent `.md` files** are referenced by specific path in `recipes/` and `teaching/`.
- **All 12 are self-contained** — no transitive deps on skills, references, or other files.
- **3 files are misreferenced** in current recipes (point to non-existent paths). Need to correct during port.
- **3 open-ended search references** exist (search whole plugin tree, not a specific file). These need different handling — remove or replace with local references.
- **1 whole-plugin reference** (`plugins/conductor/`) in `continuous-dev.yaml`. Conductor is 30+ files. Options below.

---

## Directly-referenced agent files (12)

| # | Current Path in Recipe | Actual File Location | Referenced By | Lines | Notes |
|---|------------------------|----------------------|---------------|-------|-------|
| 1 | `error-debugging/agents/debugger.md` | ✓ same | `recipes/agents/bug-fix.yaml` | 33 | |
| 2 | `error-debugging/agents/error-detective.md` | ✓ same | `recipes/agents/bug-fix.yaml` | 35 | |
| 3 | `observability-monitoring/agents/post-mortem.md` | ❌ actually `product-evaluation/agents/post-mortem.md` | `cycle-review.yaml`, `eval-foundation.yaml`, `eval-ratchet.yaml`, `eval-gate.yaml` | ~? | Misreferenced; fix during port |
| 4 | `observability-monitoring/agents/product-evaluation.md` | ❌ actually `product-evaluation/agents/product-evaluation.md` | `eval-design.yaml`, `eval-foundation.yaml`, `eval-isolation.yaml`, `eval-layers.yaml`, `eval-ratchet.yaml`, `eval-gate.yaml` | 72 | Misreferenced; fix during port |
| 5 | `comprehensive-review/agents/code-reviewer.md` | ✓ same | `code-review.yaml`, `review-gate.yaml` | 171 | |
| 6 | `comprehensive-review/agents/architect-review.md` | ✓ same | `code-review.yaml` | 161 | |
| 7 | `product-planning/agents/prd-development.md` | ✓ same | `idea-to-spec.yaml`, `spec-to-pipeline.yaml` | 74 | |
| 8 | `unit-testing/agents/test-automator.md` | ✓ same | `test-writer.yaml`, `independent-tester.yaml` | 220 | |
| 9 | `code-refactoring/agents/legacy-modernizer.md` | ✓ same | `refactor.yaml` | 35 | |
| 10 | `product-specification/agents/feature-spec.md` | ✓ same | `spec-to-pipeline.yaml`, `spec-decomposition.yaml` | 77 | |
| 11 | `product-specification/agents/acceptance-criteria.md` | ✓ same | `spec-decomposition.yaml` | 75 | |
| 12 | `agent-orchestration/agents/tutorial-engineer.md` | ❌ actually `code-documentation/agents/tutorial-engineer.md` (also exists at `documentation-generation/`) | `skill-evolution.yaml` | ~? | Misreferenced; two candidates — pick `code-documentation/` (same content per glob) |

Also referenced once:
- `product-evaluation/agents/product-evaluation.md` (✓ correct path) in `spec-review.yaml` — same file as #4.

**Total unique files: 12** (#4 and `spec-review.yaml`'s reference are the same file).

---

## Open-ended search references (3 — require different handling)

These are not specific file references — they tell the agent to search the whole RIL tree. They can't be "ported" in the same sense. Options for each:

| Reference | Referenced By | Current Intent | Proposed Action |
|-----------|---------------|----------------|-----------------|
| `~/ClaudeInfra/ril-agents/plugins/agent-teams/` | `recipes/graduated/pipeline-forge.yaml:106` | Search for pipeline patterns | Replace with pointer to `recipes/forge-references/` (local pattern library we already have) |
| `~/ClaudeInfra/ril-agents/plugins/` | `recipes/graduated/recipe-forge.yaml:92` | Search for similar existing agents | Replace with pointer to `recipes/ported-agents/` (the new local tree) + `recipes/forge-references/` |
| `~/ClaudeInfra/ril-agents/plugins/conductor/` | `recipes/agents/continuous-dev.yaml:39` | Reference the whole conductor plugin for continuous dev patterns | **Needs decision** — see below |

---

## Conductor plugin (`~/ClaudeInfra/ril-agents/plugins/conductor/`)

Conductor is a 30+ file plugin. Contents:
- 1 agent (`conductor-validator.md`)
- 6 commands (`implement.md`, `manage.md`, `new-track.md`, `revert.md`, `setup.md`, `status.md`)
- 3 skills (context-driven-development, track-management, workflow-patterns — each with SKILL.md and references)
- 11 templates (code styleguides, product, tech-stack, track-plan, etc.)
- 1 README

Referenced by `continuous-dev.yaml:39` with description "Stage 6 reference for continuous dev patterns" — but that single line is vague. The entire conductor plugin is probably too large to port wholesale, and we're not even sure which pieces `continuous-dev.yaml` actually relies on.

**Three options — need your call:**

### Option A — Port nothing; remove the reference
Change `continuous-dev.yaml:39` to remove the `~/ClaudeInfra/ril-agents/plugins/conductor/` mention. The agent primitive already has its own instructions; conductor was only an inspiration pointer.
- **Pros:** Simplest. Clean break. True portability.
- **Cons:** Loses the "look at this for patterns" nudge. May reduce quality of agent output on first runs.

### Option B — Port just the README and 3 SKILL.md files
Port `conductor/README.md` and the 3 skill index files into `recipes/ported-agents/conductor/` as inspiration docs. Drop the commands, templates, and sub-references.
- **Pros:** Preserves the spirit of the reference without wholesale adoption. ~4 files added.
- **Cons:** Partial port; still feels like a loose end.

### Option C — Port all 30+ files
One-for-one port of the whole conductor plugin.
- **Pros:** Most faithful to the "nothing missing" principle.
- **Cons:** Doubles the port work. Most of those files (templates, commands) aren't recipe-shaped — they're markdown docs. Significant time investment to port something we may not need.

**My recommendation: Option A.** Conductor is cited once as a vague pattern pointer; there's no specific behavior that depends on it. If a future Stage 6 module needs a specific conductor pattern, we port it then.

---

## Missing files (fix during port)

The RIL agents tree does NOT contain these at the paths our recipes specify:
1. `observability-monitoring/agents/post-mortem.md` → actual path: `product-evaluation/agents/post-mortem.md`
2. `observability-monitoring/agents/product-evaluation.md` → actual path: `product-evaluation/agents/product-evaluation.md`
3. `agent-orchestration/agents/tutorial-engineer.md` → actual paths: `code-documentation/agents/tutorial-engineer.md` or `documentation-generation/agents/tutorial-engineer.md`

During the port, I will:
- Pull content from the ACTUAL location
- Name the ported YAML based on the agent's real plugin home
- Update the recipe path references accordingly

---

## Proposed layout

```
recipes/ported-agents/
├── error-debugging/
│   ├── debugger.yaml
│   └── error-detective.yaml
├── product-evaluation/
│   ├── post-mortem.yaml
│   └── product-evaluation.yaml
├── comprehensive-review/
│   ├── code-reviewer.yaml
│   └── architect-review.yaml
├── product-planning/
│   └── prd-development.yaml
├── unit-testing/
│   └── test-automator.yaml
├── code-refactoring/
│   └── legacy-modernizer.yaml
├── product-specification/
│   ├── feature-spec.yaml
│   └── acceptance-criteria.yaml
└── code-documentation/
    └── tutorial-engineer.yaml
```

12 YAML files, organized by original plugin. No skills directory needed (none of the 12 agents reference sibling skills).

---

## Port mechanics

Each `.md` agent has this shape:

```markdown
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior.
model: sonnet
---

You are an expert debugger...

When invoked:
1. Capture error message...
```

Mapping to Goose recipe YAML:
- `name` → recipe `title` (formatted)
- `description` → recipe `description`
- `model` → ignored (Goose handles model config at platform level)
- Body → recipe `prompt` (with light reformatting for the "agent primitive" convention: short `instructions` with NEVER rules, rest in `prompt`)

These become agent primitives — non-interactive, callable as sub-recipes. They go under `ported-agents/` (not `agents/`) to distinguish lineage.

---

## Files that will be modified

### Recipe YAMLs (15 files in `recipes/`)
- `recipes/agents/bug-fix.yaml`
- `recipes/agents/test-writer.yaml`
- `recipes/agents/code-review.yaml`
- `recipes/agents/refactor.yaml`
- `recipes/agents/review-gate.yaml`
- `recipes/agents/independent-tester.yaml`
- `recipes/agents/eval-foundation.yaml`
- `recipes/agents/eval-design.yaml`
- `recipes/agents/eval-layers.yaml`
- `recipes/agents/eval-gate.yaml`
- `recipes/agents/eval-isolation.yaml`
- `recipes/agents/eval-ratchet.yaml`
- `recipes/agents/cycle-review.yaml`
- `recipes/agents/continuous-dev.yaml`
- `recipes/agents/idea-to-spec.yaml`
- `recipes/agents/spec-decomposition.yaml`
- `recipes/agents/spec-review.yaml`
- `recipes/agents/spec-to-pipeline.yaml`
- `recipes/agents/skill-evolution.yaml`
- `recipes/graduated/pipeline-forge.yaml`
- `recipes/graduated/recipe-forge.yaml`

### Reference/teaching docs (3+ files)
- `recipes/forge-references/validation-checklist.md` — update RIL agent path check
- `recipes/TWO-MODE-PATTERN.md` — marked SUPERSEDED but still has references
- `teaching/meta/module-designer/SKILL.md`
- `teaching/meta/module-designer/references/ril-agents-map.md`
- `teaching/meta/module-designer/references/goose-recipe-format.md`

### High-level docs (to rewrite as lineage, not runtime)
- `CLAUDE.md` — update "RIL Agents" section to describe as inspiration
- `REFERENCES.md`
- `HOW_GOOSE_WORKS.md`
- `ideas/syllabus.md` (may contain references)

---

## Plan of commits (in stages as requested)

1. **Inventory commit** — this doc only.
2. **Port commit** — create `recipes/ported-agents/` with all 12 YAMLs.
3. **Rewire commit** — update all recipe/teaching/doc references from `~/ClaudeInfra/ril-agents/...` to `recipes/ported-agents/...`.
4. **Doc update commit** — update CLAUDE.md, REFERENCES.md, HOW_GOOSE_WORKS.md to reflect lineage status.
5. **Verification commit** — final grep + validation results documented in `handoffs/ril-agents-port-complete.md`.

---

## Awaiting decision

1. **Option A/B/C for the conductor plugin** — default to A unless told otherwise.
2. **Approval to proceed** — under the 30-leaf threshold, so the rubric allows continuation, but confirming you want this done now.
