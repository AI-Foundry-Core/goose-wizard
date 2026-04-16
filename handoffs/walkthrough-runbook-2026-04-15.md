# Walkthrough Runbook — Phase B Validation

**Date:** 2026-04-15
**Status:** Phase B pushed to origin/main (commits 1002697..0bc4ac8). Static code-path review complete. Interactive walkthrough is your turn.
**Prior handoff:** `handoffs/phase-b-deferred-items-complete-2026-04-15.md`

---

## Decisions Doni made this session

1. **Push first, then pick a work stream.** Pushed Phase B's 9 unpushed commits to origin/main before any other work.
2. **Picked Option A — real-project walkthrough.** Curriculum integration (Option B) and the 4 deferred follow-ups (Option C) are explicitly punted to a later session.

(No design decisions this session — all in the prior handoff.)

---

## What I ran (autonomous static walkthrough)

I cannot drive `goose run --interactive` end-to-end from this harness — every prompt would block on your typing. So I did the next-best thing: walked the YAML by hand against the test-plan paths and looked for things a static review would catch but the agent might still mis-execute at runtime.

### Files traced

- `recipes/agents/config/ensure-config.yaml` (legacy-migration branch, lines 73-118)
- `recipes/shared/setup-config.yaml` (PENDING KIND CONFIRMATION + PROJECT.JSON REPAIR + FIRST RUN, lines 96-235)
- `recipes/shared/conductor-setup.yaml` (status routing, kind gate, live gate, Step 7 belt-and-suspenders, all 283 lines)
- `recipes/shared/conductor-implement.yaml` (approval string, Step 0a kind gate, all 183 lines)
- `recipes/shared/conductor-new-track.yaml` (brief retry loop + post-loop routing, all 217 lines)
- `recipes/shared/conductor-revert.yaml` (typed revert string)
- `recipes/shared/conductor-manage.yaml` (per-action typed confirmations)
- `recipes/agents/conductor/track-create.yaml` (atomic 14-step process + concurrent-writer guard, all 215 lines)
- `recipes/agents/conductor/checkpoint-verify.yaml` (read-only — confirmed no live-gate needed)
- All 4 `recipes/agents/conductor/context-write-*.yaml` (live-gate parity)
- `recipes/agents/conductor/track-task-execute.yaml`, `revert-by-unit.yaml` (gate parity)
- `recipes/RECIPE-PREAMBLE.md` (backup rotation convention)
- `teaching/meta/module-designer/references/progression-format.md` vs `install/project-template/.goose/state/progression.json` (schema reconcile)

### What checked out cleanly

- **Backup format consistent across 8 writers** — all use `<file>.bak.<YYYYMMDDTHHMMSSZ>` in the same directory, never overwrite, never numeric. setup-config, ensure-config (user.json), conductor-setup (tracks.md Step 5), track-create (tracks.md Step 8), 4 context-write-*.
- **Live gate enforced on all 7 mutating primitives** — track-create, track-task-execute, revert-by-unit, 4 context-write-*. Each has both `live_confirmation_required` and `kind_unconfirmed` returns. checkpoint-verify is read-only and correctly exempt.
- **All 4 mutating facilitators have byte-for-byte typed confirmations** — conductor-setup (`setup conductor <id>`), conductor-implement (`implement <track_id>`), conductor-new-track (`new-track <id>`), conductor-revert (target-specific revert string), conductor-manage (per-action: `archive <id>`, `restore <id>`, `delete <id>`, `rename <old> to <new>`).
- **conductor-implement approval string is locked to literal ASCII `approved`** — lines 157-167. Explicitly enumerates `approve`, `yes`, `ok`, `APPROVED`, typos as failures.
- **ensure-config legacy migration writes the stub project.json correctly** — `kind: "unknown"`, `needs_kind_confirmation: true`, `created_via: "legacy_user_config_migration"`. Matches conductor-config-design.md.
- **conductor-setup Step 0 kind gate** — routes to setup-config (NOT proceeds) when kind is unknown. Stops cleanly, gives user the exact command to run.
- **setup-config PENDING KIND CONFIRMATION branch** — runs BEFORE the main menu (Step 0 detection at line 84), atomically resolves to sandbox/live, REMOVES the flag (not "set to false"), updates both project.json and user.json index entry.
- **Progression schema doc matches seed template** — flat `sequence` array, 26 entries, no nested dimensions. The Series 4 fix held.

### Soft friction point (not fixing, documenting)

- **conductor-new-track Step 6 post-loop status handling is incomplete.** Line 156 says "Break on any status other than `brief_too_vague`," but the explicit post-loop branches only cover `ok`, `id_collision`, `write_failed`, and the `rollback_incomplete` escalation. The other 4 possible statuses from `track_create` — `config_unresolved`, `kind_unconfirmed`, `live_confirmation_required`, `not_initialized` — fall through to whatever the agent decides to do. In normal flow Step 0/0a catches all of them first, so they only matter on race conditions (state changes mid-recipe). Not a blocker; the agent will surface the status to the user, just without a documented routing branch. **If you hit one of these in the walkthrough, that's the cleanup pass.**

### What I did NOT verify

- The `developer` extension's actual file-read/write semantics on Windows path conventions (forward vs back slash mixing in canonical paths). The recipes say "canonicalize," but exactly how Goose's developer extension behaves with `~` expansion on Windows is something only a live run will tell you.
- The `subagent(...)` invocation syntax actually parses what the recipe expects. I'm trusting the existing recipe convention.
- Whether `Test-Path` calls in setup-config's belt-and-suspenders Step 7 actually run through PowerShell or get translated into a Bash equivalent under the developer extension on Windows.

These are the things that will probably surface as friction.

---

## Runbook — exact commands to execute in order

All commands assume CWD = `C:/Users/donid/ClaudeProjects/goose-wizard` (the repo root). Run each in a fresh terminal.

### Pre-flight

```bash
goose --version  # confirms 1.30.0 or later
ls ~/.goose-wizard/  # should NOT exist for a clean first-run test
```

If `~/.goose-wizard/` exists from prior testing and you want a clean slate:

```bash
mv ~/.goose-wizard ~/.goose-wizard.backup-$(date -u +%Y%m%dT%H%M%SZ)
```

### Test 1 — Clean first-run flow (no legacy state)

```bash
# Confirm clean: no rilgoose dir, no legacy state in current target
ls ~/.goose-wizard/  # expect "No such file"
ls .goose/state/  # expect either nothing or just progression.json
```

```bash
# Step 1: setup-config first run
goose run --recipe recipes/shared/setup-config.yaml --interactive
```

Expected: FIRST RUN branch fires. Asks 7 questions in sequence (name, role, path, id, kind, language, test_command).

For the path question, point at any small project — e.g. `C:/Users/donid/ClaudeProjects/General` or a throwaway test repo.

For the kind question:
- Type `sandbox` — should accept.
- Type `live` — should ask "Type 'yes, live' to proceed."

After completion:
```bash
ls ~/.goose-wizard/  # expect: user.json
cat ~/.goose-wizard/user.json  # spot check schema
ls <project_path>/.goose/conductor/  # expect: project.json
cat <project_path>/.goose/conductor/project.json  # kind matches what you picked, conductor_initialized: false
```

```bash
# Step 2: conductor-setup
goose run --recipe recipes/shared/conductor-setup.yaml --interactive
```

Expected: Walks through product/tech-stack/workflow/tracks/styleguide questions. At the end, project.json's `conductor_initialized` flips to `true` and 4 artifacts (product.md, tech-stack.md, workflow.md, tracks.md) plus a styleguide exist.

```bash
# Verify
ls <project_path>/.goose/conductor/
# expect: product.md, tech-stack.md, workflow.md, tracks.md, project.json, setup_state.json, code_styleguides/
cat <project_path>/.goose/conductor/project.json | grep conductor_initialized  # expect: true
```

```bash
# Step 3: conductor-new-track
goose run --recipe recipes/shared/conductor-new-track.yaml --interactive
```

For the brief, give a deliberately vague answer first ("make it better") to test the 3-retry cap. Expected: each retry asks for refinement; on retry 3, recipe surfaces the "we've tried 3 refinements" message and stops.

Then run again with a real brief to actually create a track.

```bash
# Verify
ls <project_path>/.goose/conductor/tracks/  # expect: <track_id>/
cat <project_path>/.goose/conductor/tracks/<track_id>/spec.md | head -20
ls <project_path>/.goose/conductor/tracks.md.bak.*  # expect at least one .bak from the registry write
```

```bash
# Step 4: conductor-implement — go through ONE task minimum
goose run --recipe recipes/shared/conductor-implement.yaml --interactive --params track_id=<track_id>
```

Run through tasks until you hit the checkpoint approval prompt.

**Critical test:** at the approval prompt, try in order:
1. `APPROVE` (uppercase) → should fail, treated as issue list
2. `approved.` (with period) → should fail
3. `yes` → should fail
4. `approve` (missing 'd') → should fail
5. `approved` (literal) → should pass and create the checkpoint commit

If anything other than #5 advances the phase, that's a bug — file it.

### Test 2 — Stage 0 → conductor bridge (the high-value test)

```bash
# Clean slate
mv ~/.goose-wizard ~/.goose-wizard.backup-bridge-$(date -u +%Y%m%dT%H%M%SZ)
```

Plant a legacy `user_config.json`. Pick a target path (e.g. `C:/Users/donid/ClaudeProjects/General` again).

```bash
mkdir -p <target_path>/.goose/state/
```

Then write `<target_path>/.goose/state/user_config.json` containing:
```json
{
  "target_codebase_path": "<target_path>",
  "captured_at": "2026-04-15T17:30:42Z"
}
```

```bash
# Verify clean
ls ~/.goose-wizard/  # expect: No such file
ls <target_path>/.goose/conductor/  # expect: No such file
cat <target_path>/.goose/state/user_config.json  # planted file
```

```bash
# Step 1: conductor-setup hits the kind gate
cd <target_path>  # so the legacy file is in CWD/.goose/state/
goose run --recipe C:/Users/donid/ClaudeProjects/goose-wizard/recipes/shared/conductor-setup.yaml --interactive
```

Expected:
- ensure-config migrates: writes `~/.goose-wizard/user.json` AND stubs `<target_path>/.goose/conductor/project.json` with `kind: "unknown"`, `needs_kind_confirmation: true`, `created_via: "legacy_user_config_migration"`.
- conductor-setup hits kind gate (lines 86-100), tells user to run setup-config, **stops without writing any conductor artifacts**.

```bash
# Verify ensure-config did its job
cat ~/.goose-wizard/user.json  # expect projects[0].kind: "unknown", needs_kind_confirmation: true
cat <target_path>/.goose/conductor/project.json  # expect kind: "unknown", needs_kind_confirmation: true, created_via: "legacy_user_config_migration"
ls <target_path>/.goose/conductor/  # expect ONLY project.json (no product.md, no tracks.md)
ls <target_path>/.goose/state/user_config.json.migrated  # expect: exists (legacy file renamed)
```

```bash
# Step 2: setup-config PENDING KIND CONFIRMATION branch
cd C:/Users/donid/ClaudeProjects/goose-wizard  # back to repo root
goose run --recipe recipes/shared/setup-config.yaml --interactive
```

Expected: runs the PENDING KIND CONFIRMATION branch (lines 97-144), asks for sandbox/live, accepts byte-for-byte. Pick `sandbox`.

```bash
# Verify the resolution
cat <target_path>/.goose/conductor/project.json  # expect kind: "sandbox", NO needs_kind_confirmation key (deleted, not set to false)
cat ~/.goose-wizard/user.json  # expect projects[0].kind: "sandbox", NO needs_kind_confirmation key
```

```bash
# Step 3: re-run conductor-setup, should now proceed
cd <target_path>
goose run --recipe C:/Users/donid/ClaudeProjects/goose-wizard/recipes/shared/conductor-setup.yaml --interactive
```

Should run the full setup flow this time.

### Test 3 — Live project gate

```bash
# Manually mutate project.json to live (simulates user picking live)
# Edit <target_path>/.goose/conductor/project.json: change "kind": "sandbox" to "kind": "live"
```

Then:

```bash
goose run --recipe recipes/shared/conductor-new-track.yaml --interactive --params project_id=<project_id>
```

Expected: Step 0a fires, asks `Type exactly 'new-track <project_id>' to proceed`. Try:
- `yes` → cancel
- `new-track` (without project id) → cancel
- `NEW-TRACK <project_id>` → cancel (case-mismatch)
- `new-track <project_id>` exactly → proceed

Same drill for `conductor-setup` and `conductor-implement`.

### Test 4 — Backup rotation format

After running setup-config a second time on an existing project (e.g. the `modify project` branch on user.json), check:

```bash
ls ~/.goose-wizard/user.json.bak.*
# Expect: filename matches user.json.bak.YYYYMMDDTHHMMSSZ — compact, no hyphens or colons
# Example: user.json.bak.20260415T173042Z
```

If you see hyphens (`2026-04-15T17:30:42Z`), or a `.bak.1`/`.bak.2` style, that's a bug.

After multiple writes, expect MULTIPLE .bak files (timestamps make each unique — never overwrites).

### Test 5 — Concurrent-writer guard (hard to trigger; optional)

Open two terminals, both at the same target. Start two `conductor-new-track` invocations near-simultaneously (you'll have to type fast on the second one to overlap). When the second one hits step 8 in track-create, it should detect tracks.md changed under it and return `tracks_md_changed_under_us` inside `write_failed`.

Don't worry if you can't reproduce — it's defense-in-depth.

---

## After the walkthrough

Capture friction in `handoffs/walkthrough-findings-2026-04-15.md` (create new). Each finding gets:
- What you ran
- What you expected
- What happened
- Which file/line is responsible

Bucket by:
- **A — broken** (recipe doesn't do what it says): fix in same session if small.
- **B — friction** (works but UX is awkward): log, decide later.
- **C — design gap** (recipe is ambiguous): log for a curriculum / design pass.

Then push the findings doc + any inline fixes.

---

## What's still deferred after this session

Same 4 items from the prior handoff:
1. teach-wrapper / training-module per-dimension writes vs new progression schema
2. graduate-module modules_completed / current_module recompute (doc clarification or explicit step)
3. track-create concurrent-writer guard upgrade from detect-and-abort to real lock
4. Stage 6 conductor foregrounding in 22-continuous-dev.yaml and 23-cycle-review.yaml

Plus the curriculum integration (Option B from this session's prompt), which is its own dedicated session.
