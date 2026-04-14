# Handoff: Two-Mode Recipe System + Goose App Setup

**Date:** 2026-04-13
**Status:** Core architecture implemented. Docs and cleanup remaining.
**Plan file:** `~/.claude/plans/velvet-mixing-pnueli.md` (full design with 4-agent review feedback)

---

## What Was Done This Session

### 1. Diagnosed ACP context pollution
The Claude ACP adapter uses `preset: "claude_code"` and `settingSources: ["user", "project", "local"]` (hardcoded in `acp-agent.js` lines 1007-1038). Every Goose recipe session loads the user's CLAUDE.md, memory, and learnings. Confirmed by running Stage 0 recipe — it read CLAUDE.md's "never simulate" rule and refused to run.

### 2. Designed and implemented two-mode recipe system
Every recipe has two modes based on `.goose/state/progression.json`:
- **TEACHING MODE** (first use): Isolation preamble ignores CLAUDE.md/AGENTS.md. Reads teaching script. Guides developer. Updates progression.
- **WORKING MODE** (after training): Standard instructions. CLAUDE.md loads normally.

### 3. Created gateway recipe
`recipes/shared/00-start-here.yaml` — "★ START HERE — Goose Training"
- Reads progression, shows progress, runs next module's teaching flow
- Zero parameters, one click
- Becomes a dashboard after all 26 modules complete
- Contains full curriculum mapping (26 modules, teaching script paths)

### 4. Restructured recipe directories
```
recipes/
├── shared/          ← 27 recipes (gateway + 26 modules), deployed to all users
│   ├── 00-start-here.yaml       "★ START HERE — Goose Training"
│   ├── 01-see-what-ai-can-do.yaml
│   ├── 02-bug-fix.yaml          (template for two-mode pattern)
│   ├── 03-test-writer.yaml
│   └── ...through 26-skill-evolution.yaml
├── local/           ← 6 pipeline recipes, personal/testing only
│   ├── apply-fixes.yaml
│   └── ...5 more pipeline recipes
└── stage-0/ through stage-7/    ← OLD directories, files copied but not deleted yet
```

### 5. Updated progression.json schema
New schema with sequence array: module numbers, concept IDs, stage numbers, recipe names, per-module status. Located at `.goose/state/progression.json`.

### 6. Goose config updates
- Enabled extensions: memory, chatrecall, orchestrator
- GOOSE_RECIPE_PATH: `recipes/shared;recipes/local` (persistent user env var)

### 7. Confirmed Goose app sort order
**Hardcoded in Rust source** (`recipe_utils.rs`): `sort_by(|a, b| b.last_modified.cmp(&a.last_modified))` — newest modified first. No configurable sort option. The gateway recipe must be touched last after any batch update.

### 8. 4-agent review completed
2 Claude agents + 2 Codex agents reviewed the plan. Key findings incorporated:
- Async eval is broken (Goose #7364) → use synchronous delegate()
- App shows `title` not filename → numbered filenames for CLI only, clean titles for app
- Setup script has bugs (here-string, no exit codes, overwrites paths)
- Preamble wording too broad → "follow files explicitly referenced by this recipe"

---

## What Still Needs Doing

### Priority 1: Before testing
- [ ] **Remove old `recipes/stage-N/` directories** — files already copied to `shared/`, old dirs are dead weight
- [ ] **Update CLAUDE.md** — project structure section is wrong (still shows stage-N layout)
- [ ] **Fix REFERENCES.md** — recipe template still has `input_type: text` (invalid), needs two-mode example
- [ ] **Fix setup-goose.ps1** — here-string syntax error, no $LASTEXITCODE check, overwrites existing GOOSE_RECIPE_PATH without merging, add --IncludeLocal flag, touch gateway as final step
- [ ] **Write `recipes/TWO-MODE-PATTERN.md`** — documents the two-mode pattern for future recipe authors (replaces RECIPE-PREAMBLE.md)

### Priority 2: Before pilot
- [ ] **Test gateway recipe end-to-end** — open Goose app, click ★ START HERE, verify it reads progression, enters teaching mode for Stage 0
- [ ] **Test individual recipe two-mode** — click Bug Fix directly, verify it enters teaching mode (concept 1.1 not complete), then set 1.1 to complete and verify working mode
- [ ] **Add deprecation note to teach-wrapper.yaml** — logic now inlined in each recipe
- [ ] **Verify sort order in app** — confirm ★ START HERE appears at top after restart
- [ ] **Delete `recipes/RECIPE-PREAMBLE.md`** — replaced by TWO-MODE-PATTERN.md

### Nice to have
- [ ] Contribute upstream: `pinned: true` field in recipe YAML schema for sort priority
- [ ] Investigate Goose recipe categories/groups for visual separation in app

---

## Key Design Decisions

| Decision | Why |
|----------|-----|
| One recipe, two modes | Zero user choices. Developer clicks "Bug Fix" — it teaches or works based on state |
| All 27 recipes visible from day 1 | Full list signals "serious training system" to skeptical devs |
| Can't skip training | progression.json controls mode. Manual JSON editing is the escape hatch |
| Shared/local split | Shared = team-deployed. Local = personal sandbox |
| Synchronous eval | Async unreliable per Goose #7364 |
| Titles clean, filenames numbered | App shows titles. Filenames control CLI/filesystem order |
| Touch gateway last | App sorts by modification date. Gateway must be newest file |

## Key Files

| File | Purpose |
|------|---------|
| `recipes/shared/00-start-here.yaml` | Gateway recipe — start here |
| `recipes/shared/02-bug-fix.yaml` | Template for two-mode pattern |
| `.goose/state/progression.json` | Progression state (new schema) |
| `~/.claude/plans/velvet-mixing-pnueli.md` | Full plan with reviewer feedback |
| `LEARNINGS.md` | All technical findings from this session |
| `handoffs/two-mode-recipes.md` | This file |

## Design Constraints (from Doni)

1. **Idiot-proof.** Zero friction. ANY choice or config and we lose people.
2. **Tutorial is mandatory but invisible.** Tool teaches on first use, not a separate course.
3. **Works at scale.** Hundreds of users, every time, no exceptions.
4. **Clear progression.** Developer always knows what to do next.
