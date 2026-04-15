# Phase B Deferred Items Complete — Ready for Walkthrough

**Date:** 2026-04-15
**Status:** All 13 of the Phase A deferred items knocked out across 4 review-gated series. 8 commits on `main`, not yet pushed. Item #14 (real-project walkthrough) is your turn.
**Prior handoff:** `handoffs/phase-a-complete-2026-04-15.md`

---

## Commits this session

```
1002697  Phase B Series 1: conductor primitive hardening
01034d8  Series 1 review patches: converged findings from 2-subagent review
c5fc587  Phase B Series 2: status-routing + confirmations in working recipes
88e3e0c  Series 2 review patches
8312ab5  Phase B Series 3: atomicity + backup rotation convention
9ffeec5  Series 3 review patches
8a39b86  Phase B Series 4: progression schema reconcile + Stage 0 bridge
10944b0  Series 4 review patches
```

Plus this handoff. All on `main`. Push pending — I pushed Phase A already (at the top of this session), so only these 8 commits are unpushed.

---

## Series-by-series summary

Each series was built, committed, then reviewed by 1 Claude Agent + 1 Codex in parallel. Converged blockers from each review were patched in a follow-up commit before moving on.

### Series 1 — conductor primitive hardening (items 1, 2, 4, 10, 11)

- `live_confirmed` guard added to 6 mutating primitives. Refuses `kind: live` without typed caller confirmation.
- `config_unresolved` status enumerated in all 9 conductor primitives' Returns with nested `config_status` field.
- Git notes in `track-task-execute` downgraded from mandatory to best-effort. Returns `status: "ok"` with `notes_attached: false` on failure — no separate failure status.
- Explicit baseline fallback in `checkpoint-verify` and `revert-by-unit` when `last_checkpoint_sha` is empty. Matches on commit subject (where the producer writes track_id).
- Dropped 90-day mtime-based freshness rule in `context-validate`. Concrete signals only.
- Review patches: removed dead `project_unusable` status (unreachable), fixed `notes_attach_failed` semantics, fixed baseline matcher, added `live_confirmed` to `track-create` for parity.

### Series 2 — status-routing + confirmations in working recipes (items 5, 6, 7, 8 + Series 1 caller gap)

- 9-row status-routing table at Step 0 of all 6 conductor working recipes. Each of ensure_config's statuses maps to an explicit user-facing action — no more "surface and stop" catch-alls.
- Live-project confirmation gate (Step 0a) in the 4 mutating facilitators. Typed action-specific strings: `setup conductor <id>`, `implement <track_id>`, `new-track <id>`, revert's existing revert-string.
- `conductor-implement` checkpoint approval tightened to literal `approved` byte-for-byte. No more `APPROVE`, `yes`, `ok`, typos.
- `conductor-new-track` brief refinement loop capped at 3 retries with replacement (not concatenation) of the brief. Empty / identical replies don't consume retry slots.
- `conductor-setup` Step 7 belt-and-suspenders: explicit Test-Path check on 4 core artifacts before flipping `conductor_initialized`.
- Review patches: `conductor-manage` archive/restore/rename now require typed confirmations (previously only `delete` did, despite Step 0a claim). Routing `project_json_missing` → `setup-config` (not `conductor-setup`, which itself refuses on that status per the design doc).

### Series 3 — atomicity + backup rotation convention (items 3, 9)

- Canonical Backup Rotation Convention added to `RECIPE-PREAMBLE.md`. Format: `<file>.bak.<UTC compact timestamp YYYYMMDDTHHMMSSZ>` in the same directory. Defines write sequence, failure semantics, cleanup rules.
- `track-create` Process rewritten as a 14-step sequence with explicit rollback order. Staging dir is a sibling of `tracks/` (same filesystem, atomic renames). tracks.md backed up BEFORE track dir creation. `write_failed` return leaves filesystem in exactly one of two states — pre-call or fully committed.
- Added `tracks_md_backup_path` and `rollback_incomplete` return fields.
- Review patches: fixed spec/example inconsistency (compact format everywhere). Propagated convention to every writer it claimed to govern — `setup-config`, `ensure-config` migration, all 4 `context-write-*`. Added concurrent-writer guard (step 8 re-reads tracks.md, aborts with `tracks_md_changed_under_us` on drift). Moved metadata timestamp generation into the staged file (eliminates post-commit mutation). `conductor-new-track` now surfaces `rollback_incomplete` with manual recovery steps.

### Series 4 — progression schema + Stage 0 bridge (items 12, 13)

- `progression-format.md` rewritten to match the real schema — flat `sequence` array of 26 entries, matching the seed template and what `graduate-module` / `check-progress` actually read. The old nested `stages[].concepts[].dimensions[]` structure was never implemented.
- ensure-config legacy migration now ALSO stubs a minimal `project.json` alongside `user.json`. Stub carries `kind: "unknown"`, `needs_kind_confirmation: true`, `created_via: "legacy_user_config_migration"`. Existing project.json is preserved.
- Review patches, three converged blockers:
  - **setup-config got an explicit PENDING KIND CONFIRMATION branch** that runs before the main menu, walks the user through sandbox/live selection, atomically writes project.json + updates user.json index, removes the flag.
  - **All 6 mutating primitives now refuse `kind: "unknown"`** with new `status: kind_unconfirmed`. Closes the CLI-direct bypass.
  - **conductor-config-design.md schema updated** with the new transient fields.
- Also added PROJECT.JSON REPAIR branch to setup-config for users who migrated under an older version (pre-stub) or deleted their project.json.

---

## Test plan for your walkthrough (item #14)

The whole point of the walkthrough is to find what the reviewers couldn't. Some paths to probe:

### First-run flow (clean slate)

1. Start with no `~/.rilgoose/` and no legacy `user_config.json`.
2. `goose run --recipe recipes/shared/setup-config.yaml --interactive` — FIRST RUN branch. Should collect name / path / id / kind / language / test_command.
3. `goose run --recipe recipes/shared/conductor-setup.yaml --interactive` — kind is real (sandbox/live), so no bridging needed. Should walk through product / tech-stack / workflow / tracks / styleguide.
4. `goose run --recipe recipes/shared/conductor-new-track.yaml --interactive` — collects brief, authors track. Test the 3-retry cap by giving a deliberately vague brief.
5. `goose run --recipe recipes/shared/conductor-implement.yaml --interactive --params track_id=<id>` — runs 11-step TDD lifecycle. Exit at the checkpoint approval prompt and try `APPROVE`, `approved.`, `yes` — they should all fail. Only literal `approved` passes.

### Stage 0 → conductor bridge (the interesting one)

1. Simulate Start Here: write `.goose/state/user_config.json` with `target_codebase_path` + `captured_at`, nothing in `~/.rilgoose/`.
2. `goose run --recipe recipes/shared/conductor-setup.yaml --interactive` — ensure-config migrates, creates user.json + stub project.json, conductor-setup hits the kind gate and routes you to setup-config.
3. `goose run --recipe recipes/shared/setup-config.yaml --interactive` — PENDING KIND CONFIRMATION branch should fire. Pick `sandbox`. It should write project.json with real kind, update user.json's index entry, remove the flag entirely (not just set it to false).
4. Back to conductor-setup — now proceeds normally.

### Live project gate

Create a project with `kind: live` in project.json, then:
- `conductor-setup` should require typed `setup conductor <id>`.
- `conductor-new-track` should require `new-track <id>`.
- `conductor-implement` should require `implement <track_id>`, then propagate `live_confirmed: true` to every `task_execute` call.

### Concurrent writers (track-create race)

Harder to trigger manually, but: start two `conductor-new-track` invocations at once. The second should hit `tracks_md_changed_under_us` in the step 8 check.

### Backup rotation

After any write to an existing file, check the same directory for `<file>.bak.<YYYYMMDDTHHMMSSZ>`. Format should be `20260415T173042Z` style (compact, no hyphens or colons). Running setup again should produce a second `.bak` with a new timestamp — never overwrite the first.

---

## Deferred for a follow-up (not blockers for Phase B)

1. **teach-wrapper / training module writes to progression.json.** Codex P2 in Series 4 flagged that `teaching/meta/teach-wrapper.yaml:112` and some training modules (e.g., `02-bug-fix.yaml:140`) instruct writes of per-dimension ratings into `progression.json`. The new `progression-format.md` says there are no dimensions fields. teach-wrapper is explicitly DEPRECATED per CLAUDE.md, but the module-side writes need reconciliation — either extend the schema to include optional dimensions, or refactor the modules to write dimensions to a separate artifact. Out of Phase B scope. Worth a dedicated pass once the walkthrough has shown what actually gets written in practice.

2. **graduate-module counter recompute.** `modules_completed` and `current_module` are documented as "derived — recompute on every write," but `graduate-module.yaml` doesn't currently show that recompute step. Claude W4 in Series 4. Either clarify the doc to say the training recipe owns the recompute, or add it explicitly to graduate-module's Process. Low-risk, low-urgency.

3. **W1 from Series 3 — cross-process locking for shared files.** The concurrent-writer guard I added in track-create (step 8 byte-compare) is a detect-and-abort, not a lock. If someone hits it often enough, a real lock file would be the fix. Only worth doing if the walkthrough shows concurrency is a real problem (it probably isn't for single-developer flows).

4. **Curriculum integration (Option B2 from the Phase A handoff).** Stages 2/4/5 still need to be wired to invoke the conductor recipes as the "you've outgrown one-off prompts" moment. That was the original Option B2; we did Option B3-plus-deferred-items. The placement map I shared at the start of this session (end of Stage 3 → introduce conductor; Stage 4 → artifact integration; Stage 5 → checkpoint-verify hook; Stage 6 → foreground) is the design. Writing the curriculum edits is its own session.

---

## Known-unknowns before you run the walkthrough

- **I did not run `goose run` against any of the recipes.** All work is recipe-YAML text changes plus cross-recipe consistency. Agent-interpretation at runtime might differ from what the prose asks for — especially for the byte-for-byte match requirements, the atomic write sequences, and the rollback conditions. The walkthrough will surface anything a static review missed.
- **Subagent param plumbing uses `<placeholder>` substitution inside prompt strings**, which relies on the facilitator LLM substituting the resolved value at runtime (not on Goose's `{{ }}` parameter interpolation). This is existing convention, not a Phase B change, but flagging because it's brittle.
- **The `live_confirmed` thread runs through 6 primitives + 4 facilitators + setup-config + a schema doc.** A lot of surface area. The review converged on the main issues, but real runtime is the real test.

---

## What to do next session

Pick one:

1. **Push Phase B and run the walkthrough.** `git push origin main`, then go through the test plan above. Capture friction. Fix what bites immediately; log the rest.
2. **Start curriculum integration (Option B2).** Wire conductor into Stages 2/4/5 per the placement map at the top of this session.
3. **Clear the 4 deferred follow-ups** (teach-wrapper reconciliation, graduate-module recompute, locking upgrade, Stage 6 conductor foregrounding).

Option 1 is the fastest path to validating that all this actually works end-to-end.
