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

---

### Cycle 5 — Ananya (anxious junior) — Stage 4 / Idea-to-Spec

**APPLIED (Bucket A):**

- **File:** teaching/stage-4/idea-to-spec.teach.md
  - **Before:** Phase 2 delegation said "Let the developer decide" and passed one-pager content directly to subagent with no guidance on who owns the concrete design choices
  - **After:** Added developer-ownership block before delegation: facilitator must ask the developer to choose each open question (filtering fields, pagination style, error format, etc.) before passing to the subagent. Provisional choices are flagged explicitly. Subagent prompt now includes developer's concrete choices rather than facilitator-invented defaults.
  - **Why:** Both evaluators flagged facilitator embedding design decisions (author_id filtering, offset pagination, specific error schema, CORS defaults, 3600s TTL) in the code-operation prompt instead of having Ananya decide. Violates the script's own principle: "the developer needs to be the one making vague things concrete."
  - **Confidence:** high

- **File:** teaching/stage-4/idea-to-spec.teach.md
  - **Before:** No auth-model coaching guidance existed — CORS coaching was the only cross-origin teaching path
  - **After:** Added "Auth-Model Coaching Note" section: after addressing CORS headers, facilitator probes whether session-cookie auth is appropriate for the API client's deployment (cookie domain, CSRF, token-based alternative). Surfaces it as an open design decision, not a resolved answer.
  - **Why:** Both evaluators flagged the auth-model gap. Session cookies + cross-origin is identified as risky, but coaching only addressed CORS headers. The deeper question — whether session auth is appropriate for API clients — was raised but never resolved.
  - **Confidence:** high

- **File:** teaching/stage-4/idea-to-spec.teach.md
  - **Before:** No `## Wait-Time Insights` section existed
  - **After:** Added 6 ordered wait-time insights tagged with `[specificity]` (x2), `[verify]`, `[progressive-elaboration]`, `[enterprise]`, `[define-success]`
  - **Why:** teacher-instructions.md Section 13 requires each module to have an ordered insight list. Stage 2 fixed in cycle 3, Stage 3 fixed in cycle 4, Stage 4 was still missing. Facilitator improvised well but had no module-specific insights to draw from.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Ananya name-drops RFC 7807 and cursor-vs-offset pagination — breaking persona fidelity for a 1.5yr anxious junior
  - **Evidence:** cycle 5 (Opus weakness #1, Codex weakness #3)
  - **Occurrences:** 1
  - **Why not applied:** Simulator persona fidelity issue, not a teaching script bug. Fix belongs in simulator persona constraints (Haiku produced technically sophisticated output inconsistent with Ananya's experience level). The teaching script is not responsible for mock model vocabulary.

- **Finding:** Enterprise context opportunities missed — Ananya mentions team lead and cross-team dependency but facilitator doesn't surface enterprise integration context
  - **Evidence:** cycle 5 (Opus enterprise readiness 3/5, Codex enterprise readiness 3/5)
  - **Occurrences:** 1
  - **Why not applied:** Adding enterprise coaching paths could help enterprise personas but overwhelm anxious juniors. The wait-time insight #5 (`[enterprise]`) partially addresses this. Full enterprise coaching branches are a structural enhancement that needs confirmation across persona types.

- **Finding:** Simulation notes section in transcript file contains eval ratings and dimension names
  - **Evidence:** cycle 4 (Codex), cycle 5 (Codex)
  - **Occurrences:** 2 (incremented from 1)
  - **Why not applied:** Simulator infrastructure change, not a teaching script fix. Evaluator disagreement continues: Opus considers it correctly sequestered, Codex considers it a leak.

---

### Cycle 6 — Karthik (multitasker) — Stage 5 / Eval Foundation

**APPLIED (Bucket A):**

- **File:** teaching/stage-5/eval-foundation.teach.md
  - **Before:** "The Task" section had facilitator delegating directly to code-work subagent after developer chose pipeline output, with no developer-driven verification design step
  - **After:** Added "Developer-Driven Verification Design" subsection: facilitator asks developer to propose verification commands for each claim before any code delegation. Developer's plan is passed to the subagent. If developer proposes re-reading the summary, that becomes the teaching moment.
  - **Why:** Both evaluators flagged as primary weakness (Opus weakness #1, Codex weakness #1). Facilitator drove verification in a Fully Adaptive session — developer never designed a check or selected a command. Explicit Bucket A criterion: mode mismatch in Stages 5-7.
  - **Confidence:** high

- **File:** teaching/stage-5/eval-foundation.teach.md
  - **Before:** Results presented declaratively: "Here's what the pipeline claimed vs. what actually happened... See that? The pipeline said [X] but..."
  - **After:** Converted to Socratic form: show raw numbers side-by-side, then ask "What do you make of that?" Let developer draw conclusions. Add explanation only if developer misses the discrepancy.
  - **Why:** Both evaluators flagged ~12 declarative statements vs ~4 questions. Fully Adaptive mode requires inverted ratio. Coaching section now has explicit Socratic rule.
  - **Confidence:** high

- **File:** teaching/stage-5/eval-foundation.teach.md
  - **Before:** Automation Instinct Adequate coaching: "You mentioned automating this later. Do it now — while the checks are fresh. A verification script that takes an hour to write saves you from..."
  - **After:** "You described the structure. What's stopping you from writing it right now? Pick the first row — which claim, which command, what does pass look like?"
  - **Why:** Both evaluators flagged facilitator describing automation instead of pushing the developer to act. Stage 5 answer is "build it" not "here's what to build."
  - **Confidence:** high

- **File:** teaching/stage-5/eval-foundation.teach.md
  - **Before:** No `## Wait-Time Insights` section existed
  - **After:** Added 6 ordered wait-time insights tagged with `[verify]` (x2), `[define-success]`, `[feedback-loops]`, `[enterprise]`, `[specialization]`
  - **Why:** teacher-instructions.md Section 13 requires each module to have an ordered insight list. Stages 2-4 were fixed in cycles 3-5; Stage 5 was still missing. Opus flagged missing second insight for consecutive operations.
  - **Confidence:** high

- **File:** teaching/stage-5/eval-foundation.teach.md
  - **Before:** No enterprise grounding guidance — verification pattern taught in a vacuum
  - **After:** Added "Enterprise Grounding" subsection after results: CI stage placement question, merge-block vs alert question, multi-project verification, ownership rule for unverifiable claims ("If the answer is 'someone,' it means nobody"). Uses questions not statements per Stage 5 mode.
  - **Why:** Both evaluators flagged enterprise readiness 3/5. Karthik mentioned 3 projects, Slack pings, 20-minute window — facilitator never connected verification to his workflow. Both evaluators provided specific fix suggestions.
  - **Confidence:** high

- **File:** teaching/meta/teacher-instructions.md
  - **Before:** Stage 5 guidance had 4 bullet points with no explicit developer-drives-verification rule or Socratic ratio guidance
  - **After:** Added 2 new bullet points: (1) developer designs verification before any code operation — facilitator asks what commands, delegates developer's plan; (2) Socratic ratio for Stage 5 — convert statements to questions, deliver answers only if developer doesn't reach them.
  - **Why:** The mode mismatch is a script structural issue, but teacher-instructions.md is where facilitator behavior is codified across all Stage 5 modules. Without this, future Stage 5 modules would repeat the same pattern.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Second wait-time insight missing for consecutive code operations
  - **Evidence:** cycle 6 (Opus, pacing weakness — two code operations but only one insight)
  - **Occurrences:** 1
  - **Why not applied:** Minor pacing gap. The insight list now exists (6 insights). Teacher-instructions.md Rule 3 already says consecutive operations can each get an insight. This is execution quality, not a script gap.

- **Finding:** Simulation notes section in transcript file contains eval ratings and dimension names
  - **Evidence:** cycle 4 (Codex), cycle 5 (Codex), cycle 6 (Codex fix #6)
  - **Occurrences:** 3 — **AUTO-PROMOTED to Bucket A.** Fix belongs in simulator instructions, not teaching scripts. Will be applied when simulator infrastructure is next edited.
  - **Why not applied this cycle:** Simulator infrastructure change, not a teaching script edit.

- **Finding:** Enterprise context opportunities missed — facilitator does not connect verification to developer's specific workflow reality
  - **Evidence:** cycle 5 (both evaluators enterprise 3/5), cycle 6 (both evaluators enterprise 3/5)
  - **Occurrences:** 2 (incremented from 1 — cycle 5 was generic enterprise, cycle 6 is specific to verification grounding)
  - **Why not applied as recurring:** The enterprise grounding section added in this cycle's Bucket A fix directly addresses this for eval-foundation. The recurring tracking is for modules that DON'T yet have enterprise grounding guidance.

---

### Cycle 7 — Arjun (curious) — Stage 6 / Cycle Review

**APPLIED (Bucket A):**

- **File:** teaching/meta/teacher-instructions.md
  - **Before:** E4 transparency response pattern said "It reads the implementation systematically — session artifacts, diffs, test outputs" as a factual statement with no hedge
  - **After:** Added precision rule: describe intended behavior as intended, not as fact. New DO example uses "It is supposed to read..." and "The output should tell us whether it actually did." Pushback answer now ends with "Whether it actually did that this time is exactly the question your review should answer."
  - **Why:** Codex flagged E4 answer contradicting the session's own evidence. The facilitator described eval agent behavior as fact, then the transcript proved the eval accepted summary claims without checking diffs or test outputs. In a session about "success signals can lie," the facilitator should not make success claims about the eval agent.
  - **Confidence:** high

- **File:** teaching/stage-6/cycle-review.teach.md
  - **Before:** No `## Wait-Time Insights` section existed
  - **After:** Added 6 ordered wait-time insights tagged with `[verify]` (x2), `[feedback-loops]` (x2), `[define-success]`, `[enterprise]`
  - **Why:** Opus flagged 1 insight across 6-7 code operations. teacher-instructions.md Section 13 requires each module to have an ordered insight list. Stages 2-5 were fixed in cycles 3-6; Stage 6 was still missing.
  - **Confidence:** high

- **File:** teaching/stage-6/cycle-review.teach.md
  - **Before:** No enterprise grounding section existed — facilitator never connected findings to team workflows
  - **After:** Added `## Enterprise Grounding` section after Facilitator Response. Includes required enterprise-context question after developer drafts findings ("How does your team find out about these findings?"). Added stop-flag lifecycle grounding with two-part push: team ownership and audit trail preservation.
  - **Why:** Enterprise readiness at 3/5 for three consecutive cycles (5, 6, 7). `enterprise_context_missed_openings` auto-promoted at 3 occurrences. Opus identified stop flag lifecycle and "write it up as a pattern" as natural openings that were not exploited. Codex identified missing audit-history plan for deleted stop flags.
  - **Confidence:** high

- **File:** teaching/meta/teacher-instructions.md
  - **Before:** Stage 6 guidance had 5 bullet points with no enterprise grounding rule or stop-flag lifecycle guidance
  - **After:** Added 2 new bullet points: (1) enterprise grounding after findings — ask where findings live and who acts on them, and (2) stop-flag lifecycle — require two-part answer (control signal + audit trail) and push for multi-developer ownership.
  - **Why:** Enterprise and stop-flag gaps are structural, not cycle-specific. Without teacher-instructions.md codification, future Stage 6 modules would repeat the same pattern.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Mock developer (Arjun, 3yr) performs senior-level operational audit after initial mistake — too polished for experience level
  - **Evidence:** cycle 7 (Opus weakness #1, Codex weakness #2), also cycle 5 (Ananya RFC vocabulary)
  - **Occurrences:** 2 (Haiku over-polishing persona fidelity — distinct from RFC vocabulary but same root cause)
  - **Why not applied:** Simulator persona fidelity issue, not a teaching script bug. Haiku tends to make mock developers slightly more capable than their profile warrants. Fix belongs in simulator persona constraints (experience-level calibration for investigation rigor, not just vocabulary).

- **Finding:** Enterprise context opportunities missed — facilitator does not connect findings to team workflows
  - **Evidence:** cycle 5 (both evaluators 3/5), cycle 6 (both evaluators 3/5), cycle 7 (both evaluators 3/5)
  - **Occurrences:** 3 — **AUTO-PROMOTED to Bucket A.** Applied this cycle: enterprise grounding section added to cycle-review script, teacher-instructions.md Stage 6 updated.
  - **Why not applied previously:** Needed confirmation that the pattern was systemic, not persona-specific.

- **Finding:** Consecutive wait-time insights missing when multiple code operations occur
  - **Evidence:** cycle 6 (Opus pacing), cycle 7 (Opus pacing weakness — 1 insight across 6-7 operations)
  - **Occurrences:** 2 (incremented from 1)
  - **Why not applied as recurring:** The insight list added in this cycle's Bucket A fix directly addresses this for cycle-review. The recurring tracking is for modules that DON'T yet have insight lists (Stage 7 modules still missing).

---

### Cycle 8 — Ravi (all-strong natural) — Stage 7 / Metrics Dashboard

**APPLIED (Bucket A):**

- **File:** teaching/stage-7/metrics-dashboard.teach.md
  - **Before:** No `## Wait-Time Insights` section existed
  - **After:** Added 6 ordered wait-time insights tagged with `[define-success]`, `[verify]`, `[feedback-loops]`, `[enterprise]`, `[specificity]`, `[iteration]`
  - **Why:** teacher-instructions.md Section 13 requires each module to have an ordered insight list. Stages 2-6 were fixed in cycles 3-7; Stage 7 was still missing. Both evaluators flagged zero insights across two non-trivial code operations. `consecutive_wait_time_insights_missing` hit 3 occurrences — auto-promoted from Bucket B.
  - **Confidence:** high

- **File:** teaching/stage-7/metrics-dashboard.teach.md
  - **Before:** No guidance on handling metrics contradictions between report data and developer-stated numbers
  - **After:** Added "Metrics conflict handling" block after the metrics report: facilitator must pause and resolve source of truth before interpreting results. Ask which dataset gates the decision and why. Do not continue with contradictory dashboard values.
  - **Why:** Codex flagged as primary weakness. In a recipe about "measure, don't guess," conflicting numbers (report says 2.70/0, developer says 2.1/2) are the teaching moment, not a wrinkle to smooth over. Opus noted the facilitator handled it gracefully but did not resolve the discrepancy explicitly.
  - **Confidence:** high

- **File:** teaching/stage-7/metrics-dashboard.teach.md
  - **Before:** All-Strong coaching line said "catching side effects" even when side_effect_awareness was null. No guidance on E10 over-coaching restraint.
  - **After:** Changed to "watching for side effects" (accurate regardless of whether a side effect appeared). Added E10 restraint note: do not suggest additional metrics or extensions when all dimensions are Strong. One sentence is enough — do not prescribe where the developer can decide.
  - **Why:** Both evaluators flagged the fourth-metric suggestion as over-coaching for E10. The coaching line claimed the developer "caught" side effects when the conditional dimension was null. Opus weakness #1, Codex weakness in pedagogy and stuck-path handling.
  - **Confidence:** high

- **File:** teaching/stage-7/metrics-dashboard.teach.md
  - **Before:** No enterprise grounding section existed — facilitator validated dashboard and threshold-gating concepts without asking where the dashboard lives or who sees failures
  - **After:** Added `## Enterprise Grounding` section before Bridge. Required question: "Where does the team see these numbers?" For threshold-gating, also ask what happens on failure (block, review item, alert). Kept to one question unless developer wants to go deeper.
  - **Why:** Enterprise readiness at 3/5 for four consecutive cycles (5, 6, 7, 8). Both evaluators identified the metrics-dashboard recipe as the most naturally enterprise-connectable recipe in the pipeline — a dashboard without a viewer is a log. `enterprise_context_missed_openings` was already promoted at cycle 7; this is the Stage 7 application.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Facilitator over-coaches by suggesting specific fourth metric ("session lifecycle assertions per auth-related test") when developer already identified the gap
  - **Evidence:** cycle 8 (Opus weakness #1, Codex pedagogy/stuck-path)
  - **Occurrences:** 1
  - **Why not applied:** The E10 restraint note added above addresses this structurally ("do not prescribe where the developer can decide"). The specific fourth-metric text is in the transcript, not in the teaching script. No script text to remove. If future cycles show facilitators still prescribing specific metrics for all-strong developers despite the new note, escalate to teacher-instructions.md.

- **Finding:** Session is compressed — only five developer turns for the capstone recipe of the entire 8-stage progression
  - **Evidence:** cycle 8 (Opus pacing weakness #2, Codex pacing)
  - **Occurrences:** 1
  - **Why not applied:** All-strong developers arriving prepared will naturally produce shorter sessions. This is execution quality, not a script bug. The script does not constrain session length. Future E10 testing might benefit from a richer scenario (e.g., change that made things worse), but that is a cycle-plan enhancement, not a script fix.

- **Finding:** Mock developer data divergence (Ravi says 2.1/2, report says 2.70/0) handled smoothly but not explicitly resolved
  - **Evidence:** cycle 8 (Codex weakness #1, Opus mock dev realism note)
  - **Occurrences:** 1
  - **Why not applied separately:** The metrics-conflict handling note added above addresses this structurally. The divergence was a mock model artifact, not a script gap. The script now tells facilitators to resolve conflicting numbers explicitly.
