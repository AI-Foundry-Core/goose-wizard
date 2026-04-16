# Walkthrough-Driven Teaching Fixes — 2026-04-15

**Date:** 2026-04-15
**Status:** Doni is mid-walkthrough on Stage 0 against the docunator project. This session captured friction live and shipped fixes across all 26 teaching modules. Push pending — nothing committed this session yet (everything from earlier today already pushed at 0bc4ac8).
**Prior handoffs:** `walkthrough-runbook-2026-04-15.md` (test plan), `phase-b-deferred-items-complete-2026-04-15.md` (Phase B context).

---

## Decisions Doni made this session

1. **Push Phase B first, then start the walkthrough.** Pushed 9 commits to origin/main (2912aa8..0bc4ac8) before doing any other work.
2. **Picked Option A — real-project walkthrough.** Curriculum integration (Option B) and Phase B's 4 deferred follow-ups (Option C) explicitly punted to a later session.
3. **Walkthrough target:** the docunator project at `C:\Users\donid\ClaudeInfra\docunator`, not Goose Wizard itself. Drove all friction findings.
4. **Time estimates: lower them.** Stage 0 should feel like 5-10 min, not 15-20. Underestimate to lower stakes for skeptical onboardees.
5. **Wall-of-text trim:** facilitator Say: blocks should be 1-2 sentences max when waiting for subagents. The exemplar pattern in `act-1-see-your-code.teach.md` Step 1 is the canonical reference for all other teaching scripts.
6. **Always offer an escape hatch on user picks.** Wherever the facilitator asks the developer to pick/bring/name something, also offer "or want me to pick one?" Adapted to context. Codified as Rule #9 in `module-designer/SKILL.md`.
7. **Interpret user engagement broadly.** When the facilitator asks "pick a file and ask a question," a developer who asks about a *concept* (e.g. "explain the MCP pieces") IS engaging — not deflecting. Subagent specs that hard-code `{user_specified_file}` are traps. Codified as Rule #10.
8. **End every bridge with a question.** Bridge sections must end with "Ready?" / "Want to keep going?" + a `Check: Wait for confirmation` line. Statements trail off; questions create handoffs. Codified as Rule #11.
9. **The target-propagation bug is in the recipe, not in Claude Code defaults.** Doni hypothesized Claude Code's project context was overriding Goose injections. Investigation showed the actual cause: teaching scripts use relative paths that resolve against CWD (Goose Wizard root) instead of the target codebase. Fix is in the recipes, not in moving Goose Wizard out of `~/ClaudeProjects/`.
10. **Fix tactical, not strategic.** Did not refactor Stage 0 to use `ensure-config` + `project.json` (the Phase A/B infrastructure). Kept the legacy `user_config.json` flow and just plumbed `target_codebase_path` through every subagent and sub-recipe call. The strategic ensure-config migration is deferred.

---

## What shipped this session

### Round 1 — time estimates lowered (7 edits)

Lowered scary-sounding durations across Stage 0 + teacher-instructions:
- `recipes/shared/00-start-here.yaml`: Module 1 "15-20 min" → "5-10 min"
- `teaching/stage-0/act-{1,2,4,5}.teach.md`: "~10 min" → "~5 min"
- `teaching/stage-0/act-3-undo-button.teach.md`: "~5 min" → "~2 min"
- `teaching/meta/teacher-instructions.md`: Stage 0 total "45-60 min" → "20-30 min"

Left alone: promotional "AI found your bug in 2 minutes" callouts, "killed bad idea in 10 minutes" contrasts in Stage 4, internal task-sizing hints for Stage 2 setup agents.

### Round 2 — wall-of-text trim across all 26 teach scripts (~20 edits)

Hand-edited `teaching/stage-0/act-1-see-your-code.teach.md` Step 1 as the exemplar (3-paragraph Say → 1 sentence; subagent return spec asks for sentences not paragraphs; while-waiting filler removed). Then dispatched 4 parallel Claude agents for the remaining 25 files. Many files were already tight (especially Stage 6-7 consulting-mode adaptive scripts). Edits concentrated in Stage 0 acts and Stage 1-5 framing/preview blocks.

### Round 3 — escape hatches on user picks (22 edits + 2 principle files)

Hand-edited `act-1-see-your-code.teach.md` Step 2 ("Pick any file" → "Pick any file and ask a question — or want me to pick one for you?"). Dispatched 3 parallel Claude agents for the rest. Stage 5-7 adaptive modules largely already had escape hatches via "If developer has no X" branches; Stage 0-4 needed inline offers added to initial Say: blocks.

Codified as Rule #9 in `teaching/meta/module-designer/SKILL.md` and as a "Preempt the stuck path" section in `teaching/meta/teacher-instructions.md`.

### Round 4 — interpret engagement broadly (act-1 + 2 principle files + 1 spot-fix)

`act-1-see-your-code.teach.md` Step 2 was rewritten:
- Say: "Ask me anything about your project — a file, a function, a design decision, a pattern, how a piece fits together..."
- Check: explicit "treat any substantive question as engagement; don't redirect them back to 'pick a file.'"
- Subagent spec: `{user_specified_file}` → `{user_question}`; subagent told to read whatever files are needed.

Codified as Rule #10 in SKILL.md and as an "Interpret Engagement Broadly" section in teacher-instructions.md.

Audit for similar traps elsewhere (1 Claude Explore + 1 Codex):
- Claude Explore: CLEAN across Stage 4-7.
- Codex: 3 possible-traps. Only one was load-bearing (`spec-decomposition.teach.md` delegated with unresolved `spec_path`). Fixed it inline with a "resolve spec before delegating — point me at it, or I'll scan for the latest" step.

### Round 5 — bridge CTA questions (29 edits + 2 principle files)

Hand-edited `act-1-see-your-code.teach.md` Step 3 (Bridge to Act 2) — added "Ready?" + Check line. Dispatched 3 parallel Claude agents for the rest. Every bridge across all 26 teach scripts now ends with a CTA question + Check line. Stage 7 metrics-dashboard (end-of-curriculum) got a softer reflective CTA since there's no "next module."

Codified as Rule #11 in SKILL.md and as "End Every Bridge With a Question" in teacher-instructions.md.

### Round 6 — TARGET PROPAGATION fix (in progress, ~70 files touched)

**The bug:** Teaching recipes' Step 0 reads `target_codebase_path` from `.goose/state/user_config.json` correctly. But teaching scripts then use relative paths (`.goose/team_context.md`, "find a file in the source code") that resolve against CWD = Goose Wizard repo root, not the target. The subagent reads Goose Wizard's own files and operates on Goose Wizard's source tree instead of the developer's project.

**The fix pattern:**

1. **Training recipe (`recipes/shared/NN-*.yaml`):** Add a `**CRITICAL — TARGET PROPAGATION.**` block in instructions. Defines a TARGET PROLOGUE that the facilitator must prepend to every subagent delegation: tells the subagent the target dir, says use absolute paths, says use `git -C <TARGET>`, says don't read files outside `<TARGET>/`, says interpret `.goose/team_context.md` as `<TARGET>/.goose/team_context.md`. Update the recipe's own "Read these files" list to use `<TARGET>/.goose/team_context.md`. Update every `subagent(subrecipe: ...)` call to pass `target_codebase_path: "<resolved target_codebase_path from step 0>"`.

2. **Teach script (`teaching/stage-N/*.teach.md`):** Add a `> **Path resolution note.**` header (after the title) telling the facilitator that every relative path in the script resolves against `<TARGET>/`. Update obvious literal references: `.goose/team_context.md` → `<TARGET>/.goose/team_context.md`, "scan the codebase" → "scan source code under `<TARGET>/`", `git checkout -b` → `git -C <TARGET> checkout -b`. Append `(prepend the TARGET PROLOGUE)` to every `Delegate to subagent:` block. Add `target_codebase_path: {TARGET — from the parent recipe's Step 0}` to every sub-recipe parameter block.

3. **Agent primitive (`recipes/agents/*.yaml`):** Add an optional `target_codebase_path` parameter (default empty for self-testing). Add a `**WORKING DIRECTORY.**` section to instructions explaining the contract: if non-empty, all reads/edits/tests/git operations act on `{target_codebase_path}/`; if empty, operate on CWD. Update `Read .goose/team_context.md` references to be target-aware. Update the constraint section to add "Do NOT modify files outside `{target_codebase_path}/` when target is set." Update `prompt:` to surface the target field.

4. **Graduated coordinator (`recipes/graduated/*.yaml`):** Same as agent primitive, plus pass `target_codebase_path` through to every sub-recipe call it delegates to.

**Status by stage:**

| Stage | Module #s | Status | Files touched | Done by |
|---|---|---|---|---|
| 0 | 01 | ✅ | recipe + 5 teach scripts | Me (hand) |
| 1 | 02 | ✅ | recipe + bug-fix.teach + bug-fix agent primitive | Me (hand) |
| 1 | 03-05 | ✅ | 3 recipes + 3 teach + 3 agent primitives | Agent 1 |
| 2 | 06-08 | ✅ | 3 recipes + 3 teach + 4 primitives + 1 graduated | Agent 2 |
| 3 | 09-11 | ✅ | 3 recipes + 3 teach + 3 primitives + 2 graduated | Agent 2 |
| 4-5 | 12-21 | ✅ | Module 21 (eval-ratchet) needed full plumbing; 2 teach scripts (eval-isolation, eval-ratchet) needed updates; everything else was already done by the original (rejected) agent before it errored out | Agent 3 (rejected first attempt) + Agent 3-relaunch |
| 6 | 22-23 | ✅ | 2 recipes + 2 teach + 2 primitives | Agent 4 |
| 7 | 24-26 | ✅ | 3 recipes + 3 teach + 3 primitives | Agent 4 |

**Stage 4+5 note (resolved):** First dispatch was rejected by an automated security system mid-launch — but it had completed most edits before erroring out. Relaunch found 28 of 30 files already plumbed; only `recipes/shared/21-eval-ratchet.yaml`, `teaching/stage-5/eval-isolation.teach.md`, `teaching/stage-5/eval-ratchet.teach.md`, and `recipes/agents/eval-ratchet.yaml` needed work. All done.

### Cumulative session edit count (estimate)

| Round | Edits | Files |
|---|---|---|
| 1 — time estimates | 7 | 7 |
| 2 — wall-of-text trim | ~20 | ~20 |
| 3 — escape hatches | 22 | ~22 |
| 4 — broad engagement | 4 | 3 + 2 principle |
| 5 — bridge CTAs | 29 | 26 + 2 principle |
| 6 — target propagation | ~150 (estimate, in flight) | ~70 |
| **Total** | **~230** | **~80 unique** |

Plus 3 principle files updated: `module-designer/SKILL.md` (Rules #9, #10, #11), `teacher-instructions.md` (3 new sections), `conductor-config-design.md` (untouched this session — Phase B work).

---

## What's NOT done

### From this session

1. **Stage 4+5 target propagation** — background agent in flight. Verify on next session start.
2. **Audit other modules for module-3+ caller-side bugs** that the user might hit on the docunator walkthrough. The fix pattern was applied broadly but each module has its own quirks (especially Stage 4 spec modules that write artifacts and Stage 6-7 modules that touch `.goose/state/`). Worth a spot-check session.
3. **The walkthrough itself isn't complete** — Doni was on Stage 0 Act 2 when the target-propagation bug was discovered. He'll restart from Stage 0 to test all the round-1-through-6 fixes. Capture friction in `walkthrough-findings-2026-04-15.md`.
4. **No commits this session.** Everything is uncommitted on local main. ~80 files modified. Recommended: one commit per round, or one consolidated "Walkthrough-driven teaching fixes" commit. Doni hasn't asked to commit yet.

### Surfaced this session, deferred

6. **Stage 5 parameter-name mismatches between training recipes and teach scripts.** Example: `recipes/shared/20-eval-isolation.yaml` calls the eval-isolation primitive with `external_dependencies` / `test_scope` / `current_test_command`, but `teaching/stage-5/eval-isolation.teach.md` references `dependency_to_mock` / `test_files` / `recording_approach`. Pre-existing — not introduced this session — but at runtime the facilitator may pass the wrong parameter names. Worth a dedicated reconciliation pass across all Stage 5 modules. Discovered during the Stage 4+5 target-propagation batch.

### Carried over from Phase B (still deferred)

1. teach-wrapper / training-module per-dimension writes vs new progression schema.
2. graduate-module modules_completed / current_module recompute (doc clarification or explicit step).
3. track-create concurrent-writer guard upgrade from detect-and-abort to a real lock.
4. Stage 6 conductor foregrounding in 22-continuous-dev.yaml and 23-cycle-review.yaml.
5. Curriculum integration (Option B from the prior handoff) — wire conductor into Stage 2/4/5 per the placement map in `phase-b-deferred-items-complete-2026-04-15.md`.

---

## Test plan for next session

### Step 1 — sanity-check the target propagation across stages

All 6 stages are done. Spot-check a couple of files to confirm:

```
Read C:\Users\donid\ClaudeProjects\goose-wizard\recipes\shared\21-eval-ratchet.yaml
Read C:\Users\donid\ClaudeProjects\goose-wizard\teaching\stage-5\eval-ratchet.teach.md
Read C:\Users\donid\ClaudeProjects\goose-wizard\recipes\agents\eval-ratchet.yaml
```

Each should have:
- Recipe: `**CRITICAL — TARGET PROPAGATION.**` block + `target_codebase_path` in sub-recipe param calls
- Teach: `> **Path resolution note.**` header + `(prepend the TARGET PROLOGUE)` on delegations
- Primitive: `target_codebase_path` parameter + `**WORKING DIRECTORY.**` section

### Step 2 — restart Doni's walkthrough from Stage 0 against docunator

His existing `~/.goose-wizard/` and `.goose/state/user_config.json` are intact. He should be able to just run:

```
goose run --recipe recipes/shared/00-start-here.yaml --interactive
```

then proceed through Module 1 → Module 2. The new target-propagation behavior should make the subagent operate on `C:\Users\donid\ClaudeInfra\docunator` instead of Goose Wizard. Confirm by checking what file the act-1 subagent picks (should be a docunator file, not `recipes/agents/code-review.yaml`).

### Step 3 — friction capture

Open `handoffs/walkthrough-findings-2026-04-15.md` (create if missing). For each issue:
- What he ran, what he expected, what happened
- Bucket A (broken) / B (friction) / C (design gap)
- Fix in same session if A; log if B/C.

### Step 4 — when walkthrough completes

If walkthrough goes clean through Stage 1, that's a major milestone. Two options:
- Commit everything from this session as one or several commits, then push.
- Keep iterating on Stage 2+ (Doni hasn't tested those yet).

---

## Reference — files modified in target propagation fix

### Training recipes (10 files)
`recipes/shared/01-see-what-ai-can-do.yaml`, `02-bug-fix.yaml`, `03-test-writer.yaml`, `04-code-review.yaml`, `05-refactor.yaml`, `06-build-then-test.yaml`, `07-review-gate.yaml`, `08-spec-first.yaml`, `09-three-agent-pipeline.yaml`, `10-parallel-reviewers.yaml`, `11-escalation-routing.yaml`, `22-continuous-dev.yaml`, `23-cycle-review.yaml`, `24-metrics-dashboard.yaml`, `25-pipeline-self-edit.yaml`, `26-skill-evolution.yaml` — and (pending) 12-21.

### Teaching scripts (~22 files)
All 5 in `teaching/stage-0/` plus all 4 in `teaching/stage-1/`, all 3 in `teaching/stage-2/`, all 3 in `teaching/stage-3/`, all 4 in `teaching/stage-4/` (pending), all 6 in `teaching/stage-5/` (pending), all 2 in `teaching/stage-6/`, all 3 in `teaching/stage-7/`.

### Agent primitives (~15+ files)
`recipes/agents/bug-fix.yaml`, `test-writer.yaml`, `code-review.yaml`, `refactor.yaml`, `builder.yaml`, `independent-tester.yaml`, `review-gate.yaml`, `spec-first.yaml`, `spec-writer.yaml`, `escalation-routing.yaml`, `continuous-dev.yaml`, `cycle-review.yaml`, `metrics-dashboard.yaml`, `pipeline-self-edit.yaml`, `skill-evolution.yaml` — plus Stage 4/5 spec/eval primitives (pending in background agent).

### Graduated coordinators (3 files)
`recipes/graduated/build-then-test.yaml`, `three-agent-pipeline.yaml`, `parallel-reviewers.yaml`.

### Principle files (3 files)
`teaching/meta/module-designer/SKILL.md` (Rules #9, #10, #11)
`teaching/meta/teacher-instructions.md` (Stuck Path escape hatch + Interpret Engagement Broadly + End Every Bridge With a Question sections)
`teaching/stage-4/spec-decomposition.teach.md` (spec_path resolution step)

---

## Open question for next session

**When to commit?** Doni hasn't asked. ~80 files modified across 6 rounds. Options:
1. **One consolidated commit** ("Walkthrough-driven teaching fixes — time, wall, escape, engagement, bridge, target propagation"). Easiest. Loses the round-by-round narrative.
2. **One commit per round** (6 commits). Clean history, lets you bisect if a regression appears.
3. **Wait until walkthrough validates the fixes,** then commit. Risk: if Doni iterates more, the diffs pile up.

Recommendation: **option 2 if walkthrough passes, option 3 if walkthrough surfaces more changes.** Either way, push only after walkthrough confirms the target-propagation fix actually works in a live `goose run`.
