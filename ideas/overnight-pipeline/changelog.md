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

---

### Cycle 2 — Vikram (senior/overconfident) — Stage 1 / Bug Fix

**APPLIED (Bucket A):**

- **File:** teaching/stage-1/bug-fix.teach.md
  - **Before:** Insight 1.1c ("if AI is going in circles...") had no conditional — delivered even after clean one-pass fixes
  - **After:** Added conditional: skip insight 1.1c if the fix was clean/one-pass. Stay quiet or draw from previous module's pool per teacher-instructions.md Rule 5.
  - **Why:** Both evaluators flagged this as irrelevant delivery — teacher-instructions.md Rule 4 already says skip irrelevant insights, but the script had no guard.
  - **Confidence:** high

- **File:** teaching/meta/teacher-instructions.md
  - **Before:** "Show me. Do the task once with no guidance. If the eval confirms you've got it, we skip ahead."
  - **After:** "Show me. Do this once with no coaching from me. I'll still run the tools — you drive the decisions. If the result is solid, we skip ahead."
  - **Why:** "No guidance" was ambiguous (no coaching? no subagent?). Both evaluators flagged. Also removed "eval confirms" which is a fourth-wall leak.
  - **Confidence:** high

- **File:** teaching/stage-1/bug-fix.teach.md
  - **Before:** "Watch what the developer does next" listed diff review, questions, and test running — no design-level verification
  - **After:** Added two new checklist items (question implementation choices, probe edge cases) and a "Design-level verification" note explaining that senior developers questioning implementation decisions qualifies as Strong even without running tests.
  - **Why:** Both evaluators noted Vikram's design-level verification (list literal vs insert, empty-list edge case) was the strongest behavior in the transcript but not recognized by the script.
  - **Confidence:** high

- **File:** teaching/stage-1/bug-fix.teach.md
  - **Before:** No guidance on developer decision ownership during skip challenges
  - **After:** Added note under "The Task": after presenting the found issue to a skip-requesting developer, ask "What would you ask the agent to do next?" — developer must state the next action before proceeding.
  - **Why:** Both evaluators noted the skip challenge was hollow — facilitator still controlled everything. Developer must own the decision for the challenge to be real.
  - **Confidence:** high

- **File:** teaching/stage-1/bug-fix.teach.md
  - **Before:** "Show the diff: 'Here's exactly what changed — take a look.'" with no awareness of prior display
  - **After:** Added note: if code operation output is already visible, reference the diff rather than re-displaying it.
  - **Why:** Opus flagged duplicate diff display — patronizing for senior developers who explicitly asked to skip hand-holding.
  - **Confidence:** high

- **File:** teaching/stage-1/bug-fix.teach.md
  - **Before:** "Developer describes the bug (or accepts the found issue)" with no guidance on implicit consent
  - **After:** Added note: for skip-requesting developers, engagement with technical content (domain questions, impatience with process) serves as implicit task acceptance. Frame proceeding as the developer's decision.
  - **Why:** Opus flagged facilitator proceeding without consent — Vikram's "skip the hand-holding" is engagement, not acceptance. Script needed to distinguish.
  - **Confidence:** high

- **File:** teaching/stage-1/bug-fix.teach.md
  - **Before:** No guidance on what to pass to the sub-recipe after a facilitator scan finds a bug
  - **After:** Added note: pass evidence as a bug report, not an exact patch. The code-work subagent still owns the implementation.
  - **Why:** Codex flagged facilitator specifying the exact fix to the subagent, which turns code-work from investigator into patch applier and blurs the facilitator/code-work split.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Transcript leaks eval metadata (`>> EVAL RESULT:` with raw JSON visible inline)
  - **Evidence:** cycle 1 (Codex), cycle 2 (Opus + Codex)
  - **Occurrences:** 2 (promotes to Bucket A at 3)
  - **Why not applied:** Simulator/transcript format issue, not a teaching script bug. Fix belongs in simulator instructions (split developer-visible transcript from evaluator trace). At 3 occurrences, auto-promotes.

---

### Cycle 3 — Deepak (hostile) — Stage 2 / Build-Then-Test

**APPLIED (Bucket A):**

- **File:** teaching/stage-2/build-then-test.teach.md
  - **Before:** No `## Wait-Time Insights` section existed
  - **After:** Added 6 ordered wait-time insights tagged with `[specialization]`, `[verify]`, `[self-verification-bias]`, `[enterprise]`, `[specialization]`, `[feedback-loops]`
  - **Why:** teacher-instructions.md Section 13 requires each module to have an ordered insight list. Facilitator fell back on generic filler because the script had none.
  - **Confidence:** high

- **File:** teaching/meta/teacher-instructions.md
  - **Before:** No guidance on transparency questions (E4). Facilitator answered "It doesn't have a fixed checklist" and "Nothing hidden" — both misleading given the tester agent IS given structured review dimensions.
  - **After:** Added "### Transparency Questions (E4)" subsection to Section 7 (Stuck Path Handling) with response pattern: describe systematic review without claiming absence of structure or total transparency. DO/DON'T examples included.
  - **Why:** Factual error in facilitator response. The tester agent has structured review scopes; denying that is misleading even if it avoids fourth-wall breaks.
  - **Confidence:** high

- **File:** teaching/stage-2/build-then-test.teach.md
  - **Before:** Checkpoint instructions said "Strong: Acknowledge specifically... Adequate: Light suggestion... Weak: Targeted coaching" — no priority order enforcement and no guidance on distinguishing minimal role labels from Strong understanding
  - **After:** Checkpoint now explicitly follows teacher-instructions.md Section 4 priority order (Strong first, Weak second, Adequate third). Added note: minimal role labels like "builder writes, tester tests" are Adequate unless the developer explains scope, challenge behavior, and independence.
  - **Why:** Both evaluators flagged facilitator praising Adequate separation awareness as if it were Strong. The checkpoint coaching language did not enforce the priority order.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Hostile persona produces polished teaching metaphor ("grading your own exam") inconsistent with established 1-3 word response register
  - **Evidence:** cycle 3 (Opus + Codex)
  - **Occurrences:** 1
  - **Why not applied:** Simulator quality issue, not a teaching script bug. Fix belongs in simulator persona constraints (vocabulary register matching). The metaphor is in the script's Weak coaching language — the mock model absorbed it.

- **Finding:** Experienced skeptic objection path ("I could have found that myself") handled well ad-hoc but not scripted
  - **Evidence:** cycle 3 (Codex)
  - **Occurrences:** 1
  - **Why not applied:** The facilitator handled it correctly without script support. Adding a scripted branch is an enhancement, not a fix. Need more cycles to confirm whether ad-hoc handling degrades.

- **Finding:** Transcript leaks eval metadata (`>> EVAL RESULT:` with raw JSON visible inline)
  - **Evidence:** cycle 1 (Codex), cycle 2 (Opus + Codex), cycle 3 (assumed present — auto-promoted)
  - **Occurrences:** 3 — **AUTO-PROMOTED to Bucket A.** Fix in next cycle: split developer-visible transcript from evaluator trace in simulator instructions.
  - **Why not applied this cycle:** Requires simulator infrastructure change, not a teaching script edit. Will be applied in cycle 4 as a simulator fix.

---

### Cycle 4 — Sneha (enterprise) — Stage 3 / Three-Agent Pipeline

**APPLIED (Bucket A):**

- **File:** teaching/meta/teacher-instructions.md
  - **Before:** Stage 3 guidance said "The developer designs the pipeline. You do not design it for them" but had no specific guidance for enterprise integration questions
  - **After:** Added enterprise Q&A coaching pattern: answer the first question directly to establish credibility, then coach remaining questions through prompts ("You described the escalation target — what fields does the packet need?")
  - **Why:** Both evaluators flagged facilitator delivering multi-paragraph explanations of PR integration, escalation routing, and audit chains instead of coaching through questions. Violates "the developer designs the pipeline" principle.
  - **Confidence:** high

- **File:** teaching/meta/teacher-instructions.md
  - **Before:** Universal Rules had 10 rules; no guidance on describing unbuilt capabilities
  - **After:** Added Rule 11: "Frame unbuilt capabilities as design targets, not current facts." With DO/DON'T example contrasting "The PR integration is straightforward" vs "That's the right shape for it — when you wire this up..."
  - **Why:** Both evaluators flagged facilitator presenting PR integration, configurable escalation, and audit chains as current capabilities. Enterprise developers will try to use what is described; over-promising is risky for SOC2-aware audience.
  - **Confidence:** high

- **File:** teaching/stage-3/three-agent-pipeline.teach.md
  - **Before:** No `## Wait-Time Insights` section existed
  - **After:** Added 6 ordered wait-time insights tagged with `[specialization]` (x2), `[verify]`, `[feedback-loops]`, `[enterprise]`, `[define-success]`
  - **Why:** teacher-instructions.md Section 13 requires each module to have an ordered insight list. Stage 2 was fixed in cycle 3; Stage 3 was still missing. Facilitator had no module-specific insights to draw from.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Checkpoint after 3.3 not explicitly framed with the three-item checklist from the script
  - **Evidence:** cycle 4 (Opus weakness #2)
  - **Occurrences:** 1
  - **Why not applied:** The checkpoint text already exists in the script (lines 62-70). The facilitator delivered coaching organically but skipped the explicit "I am looking for three things" framing. This is execution quality, not a script bug.

- **Finding:** Scope-contract contradiction — spec allowlists only auth.py/blog.py but build changes test files, reviewer says scope is clean
  - **Evidence:** cycle 4 (Codex weakness #2)
  - **Occurrences:** 1
  - **Why not applied:** Simulator/mock execution issue, not a teaching script bug. The script correctly describes contracts; the simulated pipeline produced an inconsistent contract. Fix belongs in simulator instructions (contract examples should include test file paths).

- **Finding:** File-locking question deserves a minimal operational answer before bridging to next module
  - **Evidence:** cycle 4 (Codex fix #7)
  - **Occurrences:** 1
  - **Why not applied:** The bridge is correct per script design. Adding a one-sentence operational answer is an enhancement. Need more cycles to confirm whether the terse bridge leaves enterprise personas unsatisfied.

- **Finding:** Simulation notes section in transcript file contains eval ratings, dimension names, concept status
  - **Evidence:** cycle 4 (Codex — FAIL on transcript cleanliness; Opus — PASS, considers it evaluator-only metadata)
  - **Occurrences:** 1 (new framing — previous transcript_metadata_leak was about EVAL RESULT blocks in conversation, which is fixed)
  - **Why not applied:** Evaluator disagreement. Opus says simulation notes are evaluator-only metadata, correctly sequestered. Codex says any eval content in the transcript file is a leak. Decision: the transcript FILE should be clean; notes belong in simulator logs. But this is a simulator infrastructure change, not a teaching script fix.
