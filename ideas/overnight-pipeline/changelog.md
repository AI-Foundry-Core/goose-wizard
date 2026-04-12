# Overnight Pipeline Changelog

All changes to teaching scripts — applied (Bucket A) and proposed (Bucket B).

---

## Format

Each entry:
```
### Cycle N — [personality] — [stage/recipe]

**APPLIED (Bucket A):**
- **File:** path/to/file.md
  - **Before:** exact text replaced
  - **After:** exact new text
  - **Why:** one sentence
  - **Confidence:** high/medium

**PROPOSED (Bucket B):**
- **Finding:** description
  - **Evidence:** which cycle(s)
  - **Occurrences:** N (promotes to Bucket A at 3+)
  - **Why not applied:** reason
```

---

*Pipeline started: 2026-04-12*
*Cycles planned: 12*

---

### Cycle 1 — Priya (eager) — Stage 0 (all acts)

**APPLIED (Bucket A):**

- **File:** teaching/stage-0/act-1-see-your-code.teach.md
  - **Before:** Setup reads `.goose/team_context.md` with no fallback; subagent also assumes it exists
  - **After:** Added fallback block: if team_context.md missing, delegate subagent to scan README.md, pyproject.toml, setup.cfg, package.json, Cargo.toml, or go.mod. Subagent instruction updated to reference Setup fallback.
  - **Why:** Non-Goose projects and fresh repos lack this file; facilitator stalls on step 1 without a fallback.
  - **Confidence:** high

- **File:** teaching/stage-0/act-2-first-edit.teach.md
  - **Before:** Subagent reads `.goose/team_context.md` with no fallback
  - **After:** Added inline fallback instruction: if missing, scan common project metadata files to infer the stack.
  - **Why:** Same dead-end as Act 1 — subagent needs project context regardless of whether team_context.md exists.
  - **Confidence:** high

- **File:** teaching/stage-0/act-4-catch-the-bug.teach.md
  - **Before:** Subagent reads `.goose/team_context.md` with no fallback
  - **After:** Added inline fallback instruction: if missing, scan common project metadata files.
  - **Why:** Same dead-end as Acts 1 and 2.
  - **Confidence:** high

- **File:** teaching/stage-0/act-3-undo-button.teach.md
  - **Before:** "If the developer has used git terminology unprompted"
  - **After:** "If the developer has demonstrated git understanding unprompted during Acts 1-2 — used terms like 'branch,' 'commit,' 'checkout,' 'diff,' or 'revert' in context that shows comprehension (not just mentioning the word, but using it correctly in a sentence about their workflow)"
  - **Why:** Threshold was vague — different facilitator instances would interpret "used git terminology" differently. Now requires demonstrated comprehension.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Act 2 approval happens without review verification — developer confirms seeing the change but not evaluating it
  - **Evidence:** cycle 1 (Opus eval, weakness #2)
  - **Occurrences:** 1
  - **Why not applied:** Structural change adding a new Check beat. The script works as written — this is a pedagogical enhancement. Needs more cycles to confirm the pattern matters across persona types.

- **Finding:** Act 3 developer never touches git — purely demonstrative, no hands-on step
  - **Evidence:** cycle 1 (Opus eval, weakness #3)
  - **Occurrences:** 1
  - **Why not applied:** Structural change adding a new Step 2b. Would increase Act 3 duration from ~5 to ~8 minutes. Needs confirmation across multiple personas that passive observation is insufficient.

- **Finding:** Act 5 specific-request may produce breaking API changes without test/risk note
  - **Evidence:** cycle 1 (Codex eval, weakness #2)
  - **Occurrences:** 1
  - **Why not applied:** Script already includes "Could this change break anything?" check (line 89). Adding subagent-level risk_note/test_to_run is a structural change to the delegation format. Need more evidence the existing check is insufficient.

- **Finding:** Priya never asks enterprise questions — enterprise insight paths untested
  - **Evidence:** cycle 1 (Opus eval, weakness #1; Codex eval, enterprise readiness 2/5)
  - **Occurrences:** 1
  - **Why not applied:** Fix target is persona simulation instructions (personas.md / cycle-plan.md), not teaching scripts. Pipeline infrastructure change, not script fix.

- **Finding:** Transcript metadata leaks fourth-wall ("Forced Edge Case", "Edge case triggered")
  - **Evidence:** cycle 1 (Codex eval, weakness #1)
  - **Occurrences:** 1
  - **Why not applied:** Simulator format issue, not a teaching script bug. Transcript file annotations are evaluator-only metadata. Fix belongs in simulator instructions, not .teach.md files.
