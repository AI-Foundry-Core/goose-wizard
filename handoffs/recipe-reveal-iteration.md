# Handoff: Recipe-Reveal Iteration — CLI Training Flow

**Date:** 2026-04-13
**Status:** Module 1 (00-start-here.yaml) working well after 4 iterations. Module 2-3 teaching scripts updated but untested.
**Prior handoff:** `handoffs/cli-training-flow.md`

---

## What Was Done This Session

### 1. Recipe-Teaching Flow Added (the design pivot)

Added recipe-reveal pattern to three files:
- **`recipes/shared/00-start-here.yaml`** — Act 0 (recipe intro) and Act 6 (recipe reveal) added to Module 1
- **`teaching/stage-1/bug-fix.teach.md`** — Recipe Reveal section added between Coaching and Bridge
- **`teaching/stage-1/test-writer.teach.md`** — Recipe Reveal section added between Enterprise Grounding and Bridge

Progressive arc:
- Module 1: "Everything runs from a recipe" (first exposure, see the YAML)
- Module 2: "See the two-mode pattern, compare to Start Here" (structural awareness)
- Module 3: "You're seeing the pattern now" (recipe literacy forming)

### 2. Goose Model Set to Opus

`GOOSE_MODEL: default` resolved to Sonnet, which ignored recipe instructions (dumped tables, skipped acts, invented content). Changed to `GOOSE_MODEL: opus` in:
- `%APPDATA%\Block\goose\config\config.yaml` (live)
- `install/setup-goose.ps1` (setup script for other users)

**This is required.** Sonnet does not follow detailed recipe instructions reliably.

### 3. Recipe Architecture Restructured

The original 00-start-here.yaml had ~200 lines in `instructions:` — the agent skimmed it and invented its own flow. Fix:

- **`instructions:`** — Shortened to ~20 lines of behavioral rules only (interactive, show work, no table, be directive, follow script, tone)
- **`prompt:`** — Contains the full act-by-act script. This is the user's first message and the last thing the agent reads before responding — it cannot be skimmed.

**Key learning: Put the script in `prompt:`, not `instructions:`.** The agent responds to the prompt directly. Instructions are system-level context that gets buried under Goose's own system.md.

### 4. Four Iterations of UX Fixes

| Issue | Fix |
|-------|-----|
| Agent showed 26-module table | "NO TABLE" rule in instructions + prompt |
| Agent said "Would you like me to..." | "BE DIRECTIVE" rule |
| Agent skipped all acts, did generic tour | Moved act script from instructions to prompt |
| Agent invented own act names | "FOLLOW THE SCRIPT" rule + exact act names in prompt |
| "Everything AI does is reversible" unclear | Changed to explain git: "All code changes go through git" |
| Agent lectured "This is the point: AI makes mistakes" | Added TONE rule: "You are a colleague, not an instructor" |
| Act 4 patronizing when dev misses bug | "Point it out directly without lecturing. Let them draw their own conclusions." |
| Act 6: agent said "delivered by prompt not YAML" | Added: "You are running inside Goose, NOT Claude Code" + must Read actual file from disk |
| Act 6: agent fabricated extension names | Must Read actual YAML, not reconstruct from memory |
| `goose recipe open` crashed desktop app | Replaced with manual steps: open Goose app, find recipe, click Edit Recipe |

### 5. Test Codebase Changed

Switched from `GooseTestProject` (toy task tracker) to `C:\Users\donid\ClaudeInfra\docunator` (real MCP server project) for more realistic testing. Set up:
- `.goose/state/progression.json` (fresh 0/26)
- `.goose/team_context.md` (project info for recipes)
- `.claude/CLAUDE.md` (minimal Goose override)

---

## Current State of 00-start-here.yaml

Working well after 4 test runs. The agent now:
- Follows the 7-act structure (Act 0-6) correctly
- Shows real code snippets with file names and line numbers
- Uses git for undo/redo
- Reads the actual recipe YAML from disk for Act 6
- Walks developer through opening recipe in desktop app manually
- Colleague tone, not instructor tone

**Remaining UX issues:**
- `--debug` flag needed to see tool call details in CLI (without it, permission prompts show but tool details are hidden)
- Goose's `system.md` still says "Use Markdown formatting" which sometimes overrides recipe formatting preferences
- Thinking blocks still visible in CLI output (Goose rendering issue, no fix available)

---

## Files Changed

| File | What Changed |
|------|-------------|
| `recipes/shared/00-start-here.yaml` | Complete rewrite — lean instructions, full act script in prompt, recipe-reveal acts |
| `teaching/stage-1/bug-fix.teach.md` | Added Recipe Reveal section between Coaching and Bridge |
| `teaching/stage-1/test-writer.teach.md` | Added Recipe Reveal section between Enterprise Grounding and Bridge |
| `install/setup-goose.ps1` | Added GOOSE_MODEL: opus setting with comment explaining why |
| `%APPDATA%\Block\goose\config\config.yaml` | GOOSE_MODEL changed from default to opus |

---

## What Needs Doing Next

### Priority 1: Test Module 1 End-to-End on Docunator

The last run on docunator wasn't completed. Reset and run through all 7 acts to verify:
- Act 6 reads the actual YAML from disk (not fabricated)
- Desktop app manual instructions work
- Progression updates correctly
- No code changes leak into docunator

Reset procedure:
1. `rm %APPDATA%\Block\goose\data\sessions\sessions.db`
2. Reset `.goose/state/progression.json` in docunator to 0/26
3. Revert any code changes: `git -C C:\Users\donid\ClaudeInfra\docunator checkout -- .`
4. Run: `cd C:\Users\donid\ClaudeInfra\docunator && goose run --recipe C:\Users\donid\ClaudeProjects\goose-wizard\recipes\shared\00-start-here.yaml --interactive`

### Priority 2: Test Module 2 (Bug Fix) with Recipe Reveal

The bug-fix.teach.md has the recipe-reveal section but hasn't been tested through Goose. Need to:
- Complete Module 1 first (or manually set progression to module 2)
- Run the bug fix recipe and verify the recipe-reveal works
- Check that it actually reads 02-bug-fix.yaml from disk and shows real snippets

### Priority 3: Test Module 3 (Test Writer) with Recipe Reveal

Same as above for test-writer.teach.md.

### Priority 4: Remaining UX Improvements

- Consider `--debug` flag in the test command for better visibility
- Investigate if `goose recipe open` can work reliably alongside CLI (the error may have been caused by having desktop already open on same project)
- The `find` command in Act 6 is Unix-style and may not work on Windows — test or replace with a Windows-compatible search

### Priority 5: Apply Same Architecture Pattern to Other Recipes

The instructions-in-prompt pattern that works for 00-start-here.yaml should be applied to 02-bug-fix.yaml and 03-test-writer.yaml if their instructions fields are also being ignored. Currently those recipes tell the agent to read external .teach.md files — test whether that indirection works or if the teaching content also needs to be in the prompt.

---

## Key Learnings (save to LEARNINGS.md)

1. **GOOSE_MODEL must be opus for recipes.** Sonnet ignores detailed recipe instructions — skips acts, invents content, dumps tables despite explicit rules against it. Opus follows the script.
2. **Put the script in `prompt:`, not `instructions:`.** The prompt is the user's first message — it's what the agent directly responds to. Instructions get buried under Goose's system.md and are treated as background context.
3. **`goose recipe open` from CLI may crash desktop app.** The backend server fails to start, possibly due to port conflict with running CLI session or existing desktop session on same project. Manual desktop instructions are more reliable.
4. **Agent fabricates file content if told to "show" without "Read".** Must explicitly say "Use the Read tool to read the actual file" or the agent will reconstruct from memory and get details wrong (extensions, field names, structure).
5. **Tone rules must be explicit.** Without "Never say 'Good eye' or 'Great job'" the agent defaults to instructor voice. The TONE rule in instructions fixed this.
