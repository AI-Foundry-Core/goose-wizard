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

---

### Cycle 9 — Meera (quiet/disengaged) — Stage 1 / Test Writer

**APPLIED (Bucket A):**

- **File:** teaching/stage-1/test-writer.teach.md
  - **Before:** No disengagement check existed after the assertion-quality review. Facilitator proceeded to iteration without checking whether the developer found the session useful.
  - **After:** Added "Disengagement check" block after the dismissal handling: if the developer has given only one-word/one-phrase answers through target selection and assertion review, ask "Is this useful, or would you rather tackle something different?" before proceeding. Explicitly notes that "Want to add one?" is a task prompt, not an engagement check.
  - **Why:** Both evaluators flagged this. teacher-instructions.md Section 7 requires this check for persistent disengagement. Meera gave one-word answers across the entire session and the check was never triggered.
  - **Confidence:** high

- **File:** teaching/stage-1/test-writer.teach.md
  - **Before:** No guidance on accurately crediting developer behavior during iteration coaching
  - **After:** Added "No-overclaim rule" after the iteration observation checklist: credit only what the developer actually did. If the facilitator supplied an edge case and the developer agreed, say they "checked" or "accepted" the gap — not that they "caught it" or "found it themselves."
  - **Why:** Codex flagged facilitator saying Meera "caught the empty list gap yourself" when the facilitator actually identified it and Meera agreed. Accurate praise builds trust; inflated praise undermines it.
  - **Confidence:** high

- **File:** teaching/stage-1/test-writer.teach.md
  - **Before:** No enterprise grounding section — test writing occurred in a vacuum with no connection to team CI, coverage expectations, or test ownership
  - **After:** Added `## Enterprise Grounding` section before Bridge. Required question: "Where would your team see these results — local pytest only, CI, PR checks, or a coverage report?" One question, one follow-up at most.
  - **Why:** Enterprise readiness at 3/5 for five consecutive cycles (5-9). Both evaluators flagged the same structural absence. Test-writer is a natural fit for enterprise grounding — test ownership and CI visibility are core enterprise concerns.
  - **Confidence:** high

- **File:** teaching/stage-1/test-writer.teach.md
  - **Before:** Only three wait-time insights (1.2b, 1.2a, 1.2c) existed. Insight 1.2d was missing from the script entirely.
  - **After:** Added insight 1.2d ("Think of test writing as defining what 'correct' means before you ship") as an optional fourth insight for use during a second code operation (iteration pass).
  - **Why:** Both evaluators noted 3 of 4 insights used but 1.2d was unavailable. Opus specifically noted 1.2d would have been appropriate during the eval wait or as a closing thought. Four insights now available for modules with multiple code operations.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Haiku breaks quiet/disengaged persona when asked specific technical questions — delivers two-clause analytical responses instead of one-word answers
  - **Evidence:** cycle 5 (Ananya RFC vocabulary), cycle 7 (Arjun investigation rigor), cycle 9 (Meera mapping assertion analysis)
  - **Occurrences:** 3 — **AUTO-PROMOTED to Bucket A.** Fix belongs in simulator persona constraints, not teaching scripts. Haiku needs explicit constraint: "Even when asked specific technical questions, keep answers to one clause maximum. Do not explain reasoning unless asked a follow-up."
  - **Why not applied this cycle:** Simulator persona prompt change, not a teaching script edit. Will be applied when simulator infrastructure is next edited.

- **Finding:** Facilitator fills gaps too quickly with quiet developers — answers own questions instead of asking follow-ups
  - **Evidence:** cycle 9 (Opus pedagogy weakness #1)
  - **Occurrences:** 1
  - **Why not applied:** The facilitator's instinct to keep things moving is reasonable with a quiet person. This is execution quality, not a script bug. The disengagement check added above partially addresses this by creating a pause point. Need more quiet-persona cycles to confirm whether gap-filling degrades learning.

- **Finding:** No domain-specific coaching — generic principles delivered regardless of developer's team context (e.g., pipeline reliability for data pipeline teams)
  - **Evidence:** cycle 9 (Opus pedagogy weakness #2)
  - **Occurrences:** 1
  - **Why not applied:** Requires the facilitator to read team_context.md and connect coaching language to the developer's domain. This is an enhancement that could improve engagement with quiet developers. Need more persona-type combinations to confirm the pattern.

---

### Cycle 10 — Priya (eager) — Stage 2 / Spec-First

**APPLIED (Bucket A):**

- **File:** teaching/stage-2/spec-first.teach.md
  - **Before:** Partial-failure response named the specific failing test: "Look at which criteria aren't met yet: [specific failing criteria]"
  - **After:** Changed to full criterion sweep: "Go back to your acceptance criteria and check each one against the test results. Tell me which are met and which aren't." Added rule: do NOT name the failing test — developer must do the sweep. Only narrow if developer cannot find it after genuine attempt.
  - **Why:** Opus weakness #1: facilitator names `test_cache_invalidated_on_post_update FAILED` instead of forcing Priya to check all six criteria. This teaches "check the failing test" (reactive) instead of "check every criterion" (the spec-as-contract habit E9 is meant to build).
  - **Confidence:** high

- **File:** teaching/stage-2/spec-first.teach.md
  - **Before:** No reject-and-repair loop existed. Session ended with a known failing acceptance criterion.
  - **After:** Added reject-and-repair branch: after developer identifies the unmet criterion, ask "Would you approve this build as done?" Developer must practice explicit rejection. Then delegate targeted repair, rerun full suite, present result. Do not bridge or coach until suite is green or explicitly blocked.
  - **Why:** Codex weakness #1: session identifies the gap but bridges without fixing it. "Spec as contract" should end with the contract satisfied or explicitly blocked, not with a recognized-but-unresolved failure.
  - **Confidence:** high

- **File:** teaching/stage-2/spec-first.teach.md
  - **Before:** Coaching section had no brevity constraint
  - **After:** Added brevity rule: "1-3 sentences per dimension. Maximum. Do not make the same point multiple ways. If the developer already demonstrated understanding, one sentence of confirmation is enough."
  - **Why:** Opus weakness #2: five consecutive facilitator paragraphs making the same spec-as-contract point three ways. Violates teacher-instructions.md Section 5 brevity rule.
  - **Confidence:** high

- **File:** teaching/stage-2/spec-first.teach.md
  - **Before:** Stage 2 checkpoint existed but could be folded into the bridge. No comprehension question.
  - **After:** Made checkpoint non-optional with explicit instruction: "It is NOT optional and must NOT be folded into the bridge." Added required comprehension question: "Which of these would you rely on to stop a wrong-but-working implementation?" Added coaching redirect if developer points to tester instead of spec.
  - **Why:** Codex weakness #2: transcript jumps from coaching to bridge without explicit checkpoint review. If earlier Stage 2 concepts were Weak, they would go undetected.
  - **Confidence:** high

- **File:** teaching/stage-2/spec-first.teach.md
  - **Before:** No `## Wait-Time Insights` section existed
  - **After:** Added 6 ordered wait-time insights tagged with `[define-success]`, `[verify]`, `[feedback-loops]`, `[enterprise]`, `[specificity]`, `[iteration]`
  - **Why:** Codex weakness #3: teacher-instructions.md requires ordered insights for subagent waits. Facilitator improvised one useful insight but the script lacked a reusable list. `consecutive_wait_time_insights_missing` was auto-promoted at cycle 8; this is the Stage 2 spec-first application.
  - **Confidence:** high

- **File:** teaching/stage-2/spec-first.teach.md
  - **Before:** No enterprise grounding section existed
  - **After:** Added `## Enterprise Grounding` section before Bridge. Required question: "In your team, who else would review these acceptance criteria before you start building?" Follow-up: "Where would these tests run — local only, PR checks, or CI before deploy?" Maximum two questions.
  - **Why:** Enterprise readiness at 3/5 for six consecutive cycles (5-10). Both evaluators flagged spec-first as a natural fit for enterprise grounding — specs get team review, tests run in CI. `enterprise_context_missed_openings` was auto-promoted at cycle 7.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Mock developer recovery too thorough for first correction — Priya audits three criteria unprompted after being caught not checking one
  - **Evidence:** cycle 10 (Opus mock dev realism weakness #1)
  - **Occurrences:** 1 (GPT 5.4 specific — distinct from Haiku over-polishing)
  - **Why not applied:** Simulator persona fidelity issue, not a teaching script bug. GPT 5.4 shows learning too fast — realistic first-correction recovery would focus on the one missed criterion, not audit three others. May need explicit constraint in mock developer prompt: "After first correction, address only the specific gap flagged."

- **Finding:** Enterprise readiness at 3/5 for sixth consecutive cycle — structural gap
  - **Evidence:** cycles 5-10 (both evaluators every cycle)
  - **Occurrences:** 6 — already promoted and applied per-module since cycle 7. Enterprise grounding sections now exist in cycle-review, metrics-dashboard, test-writer, and spec-first. Remaining: Stage 0 acts, bug-fix, code-review, refactor, build-then-test, role-separation, review-gate, and all Stage 3-5 modules. The per-module approach is working but not yet universal.
  - **Why not applied universally:** Each module needs a contextually appropriate enterprise question. Batch-adding generic "where does this run?" to all modules would be worse than the current per-cycle targeted additions.

---

### Cycle 11 — Vikram (senior/overconfident) — Stage 3 / Escalation Routing

**APPLIED (Bucket A):**

- **File:** teaching/meta/teacher-instructions.md
  - **Before:** Section 13 wait-time insight rules had 7 numbered rules with no exception for challenge assessments
  - **After:** Added rule 8: "Suppress during challenge assessments. During a challenge assessment (Section 7 skip-request handling), do not share wait-time insights. The assessment requires uncoached performance. Resume insights after the assessment is complete and coaching has begun."
  - **Why:** Both evaluators flagged the wait-time insight ("the failure that burns you is never the one you planned for") as coaching delivered during a no-coaching challenge assessment. The insight system's "fire immediately" rule conflicts with the challenge assessment's "no coaching" rule. One-sentence addition resolves the protocol conflict.
  - **Confidence:** high

- **File:** teaching/stage-3/escalation-routing.teach.md
  - **Before:** Checkpoint asked two questions ("Which failure opens the breaker first?" and "What does the next owner receive...?"). No completeness check on failure classes. Facilitator could proceed with incomplete failure classification.
  - **After:** Added third checkpoint question: "Are there failures your current classes don't cover?" Added follow-up coaching requirement: if classes are incomplete (missing timeout, shared-state conflict, repeated no-progress), do not proceed to bridge. Developer must add missing classes before checkpoint is satisfied.
  - **Why:** Both evaluators flagged that failure_classification was rated Adequate with specific coaching ("add timeout and repeated no-progress") but the facilitator never delivered it. The other three dimensions got coaching to completion; failure_classification got a pass. Asymmetric teaching rigor.
  - **Confidence:** high

- **File:** teaching/stage-3/escalation-routing.teach.md
  - **Before:** No enterprise grounding section existed. Facilitator never connected escalation design to team workflow, audit trails, or design review.
  - **After:** Added `## Enterprise Grounding` section before Bridge. Required question: "On your team, who signs off on a new escalation route before it goes live?" Optional follow-up on audit trail for breaker decisions. Maximum two questions.
  - **Why:** Enterprise readiness at 3/5 for seventh consecutive cycle (5-11). Opus identified three specific gaps: no design review connection, no audit trail for breaker decisions, no cross-team routing. Codex flagged "Who signs off? Where is the breaker decision recorded?" `enterprise_context_missed_openings` was auto-promoted at cycle 7; this is the Stage 3 escalation-routing application.
  - **Confidence:** high

- **File:** teaching/stage-3/escalation-routing.teach.md
  - **Before:** No `## Wait-Time Insights` section existed
  - **After:** Added 6 ordered wait-time insights tagged with `[specialization]`, `[verify]`, `[feedback-loops]`, `[enterprise]`, `[risk-ladder]`, `[specificity]`
  - **Why:** `consecutive_wait_time_insights_missing` was auto-promoted at cycle 8. Escalation-routing has two subagent runs — both need available insights. The cycle 11 transcript used one improvised insight; a curated list ensures consistency and avoids the challenge-assessment conflict (new rule 8 suppresses insights during assessments, so insights 2-6 are available for post-assessment operations).
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Vikram loses overconfident voice after opening — becomes compliant-senior after first pushback
  - **Evidence:** cycle 11 (Opus weakness #1 with detailed analysis, Codex weakness #2). Also cycles 5, 7, 9 (Haiku persona over-polishing)
  - **Occurrences:** 4 (incrementing `haiku_persona_over_polishing` from 3). Already auto-promoted at cycle 9. Fix belongs in simulator persona constraints: "When the facilitator identifies a gap in your design, push back at least once using a specific pattern from your production experience before conceding."
  - **Why not applied:** Simulator persona prompt change, not a teaching script edit. The persona prompt needs experience-level-specific pushback instructions for Haiku.

- **Finding:** Enterprise readiness at 3/5 for seventh consecutive cycle — structural gap
  - **Evidence:** cycles 5-11 (both evaluators every cycle)
  - **Occurrences:** 7 — already promoted and applied per-module since cycle 7. Enterprise grounding sections now exist in cycle-review, metrics-dashboard, test-writer, spec-first, and escalation-routing. Remaining: Stage 0 acts, bug-fix, code-review, refactor, build-then-test, role-separation, review-gate, three-agent-pipeline, parallel-reviewers, and all Stage 4-5 modules.
  - **Why not applied universally:** Same rationale as prior cycles — each module needs contextually appropriate enterprise questions.

---

### Cycle 12 — Deepak (hostile) — Stage 4 / Spec to Pipeline

**APPLIED (Bucket A):**

- **File:** teaching/stage-4/spec-to-pipeline.teach.md
  - **Before:** Phase 1 had no resistance fallback. Facilitator could skip the entire preflight testability check if the developer resisted.
  - **After:** Added resistance fallback: scale down to one criterion ("Just one. Pick the rate threshold. What exact test proves it works?") instead of skipping. If developer will not engage with even one, flag test_specificity as untested.
  - **Why:** Both evaluators flagged Phase 1 as entirely skipped. Opus: "The developer never independently classifies tests by level or writes test shapes." Codex: "The softer prompt never proves Deepak can choose unit vs integration vs e2e." The script's Phase 1 exists but needs a fallback for hostile developers who refuse the full three-criterion exercise.
  - **Confidence:** high

- **File:** teaching/stage-4/spec-to-pipeline.teach.md
  - **Before:** No hard gate after weak matrix traces. Facilitator could acknowledge a weak trace and proceed to build.
  - **After:** Added hard repair step in Phase 2: if developer finds a weak trace, do not proceed to execution plan. Developer must choose repair (add stronger test, split requirement, or mark manual gate). Delegate narrow revision, re-present changed trace, confirm it proves the requirement. Explicit instruction: "Do not proceed to Phase 4 until every requirement traces to at least one test that would actually prove it."
  - **Why:** Codex central finding: "Deepak correctly says REQ-1 needs tests for create, update, and delete. The facilitator says 'That is the right catch,' but does not revise the coverage matrix. The build proceeds. The review agent later says the same thing." Opus also flagged this indirectly. A checkpoint that comments but does not gate is not a checkpoint.
  - **Confidence:** high

- **File:** teaching/stage-4/spec-to-pipeline.teach.md
  - **Before:** Coaching section had no brevity constraint
  - **After:** Added brevity rule: "1-3 sentences per dimension. Maximum. Pick one specific praise, one sharpening note, and the bridge. Do not recap what the developer did."
  - **Why:** Opus weakness #3: coaching synthesis covers six points in ~12 sentences across multiple paragraphs. Violates teacher-instructions.md Section 5. A hostile developer who just finished a full spec-to-pipeline exercise does not need a multi-paragraph debrief.
  - **Confidence:** high

- **File:** teaching/stage-4/spec-to-pipeline.teach.md
  - **Before:** No enterprise grounding section and no wait-time insights list existed
  - **After:** Added `## Enterprise Grounding` section before Checkpoint with three contextually appropriate questions (coverage matrix location, spec sign-off, test naming conventions). Added `## Wait-Time Insights` with 6 ordered insights tagged [define-success], [verify], [specificity], [feedback-loops], [enterprise], [iteration].
  - **Why:** Enterprise readiness at 3/5 for eighth consecutive cycle (5-12). `enterprise_context_missed_openings` auto-promoted at cycle 7; `consecutive_wait_time_insights_missing` auto-promoted at cycle 8. Spec-to-pipeline is a natural fit — coverage matrices are review artifacts, test naming should match team conventions.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** E7 Copilot comparison resolved in one exchange and never revisited as evidence accumulates
  - **Evidence:** cycle 12 (Opus weakness #2 with detailed analysis, Codex weakness #3)
  - **Occurrences:** 1
  - **Why not applied:** Enhancement, not a script bug. The initial E7 response is strong (both evaluators praised it). Compounding E7 with later evidence (matrix catch, review agent results) would improve the session but requires facilitator judgment about when to callback, not a script instruction. If future hostile-persona cycles show the same one-shot E7 pattern, consider adding a scripted E7 callback point at the matrix inspection stage.

- **Finding:** Hostile persona drops hostile voice in final third of session — becomes fully cooperative
  - **Evidence:** cycle 12 (Opus mock dev realism weakness #1, Codex mock dev realism). Also cycles 5, 7, 9, 11 (Haiku and GPT 5.4 persona fading)
  - **Occurrences:** 5 (incrementing `haiku_persona_over_polishing` from 4). Already auto-promoted at cycle 9. Both mock dev models (Haiku and GPT 5.4) show the same pattern: persona-defining behavior maintained for first 60% then evaporates.
  - **Why not applied:** Simulator persona constraint issue, not a teaching script gap.

- **Finding:** Enterprise readiness at 3/5 for eighth consecutive cycle — structural gap
  - **Evidence:** cycles 5-12 (both evaluators every cycle)
  - **Occurrences:** 8 — already promoted and applied per-module since cycle 7. Enterprise grounding sections now exist in cycle-review, metrics-dashboard, test-writer, spec-first, escalation-routing, and spec-to-pipeline. Remaining: Stage 0 acts, bug-fix, code-review, refactor, build-then-test, role-separation, review-gate, three-agent-pipeline, parallel-reviewers, and remaining Stage 4-5 modules.
  - **Why not applied universally:** Same rationale — each module needs contextually appropriate enterprise questions.

---

### Cycle 13 — Karthik (multitasker) — Stage 5 / Eval Ratchet

**APPLIED (Bucket A):**

- **File:** teaching/stage-5/eval-ratchet.teach.md
  - **Before:** "Delegate to code-work subagent" with no guidance on developer-guessed thresholds. Facilitator presented measured value directly.
  - **After:** Added "Let the developer set the threshold" block. If developer guesses, let them build with the guess, run the check, and discover the gap through execution. Two paths: guess (facilitator asks "how many tests can disappear?") vs. measured (proceed normally). Fully Adaptive mode — consequence teaches, not facilitator.
  - **Why:** Both evaluators flagged the facilitator pre-empting the threshold mistake ("Before you set a ratchet, you need the actual number") as Guided-Adaptive behavior in a Fully Adaptive session. Opus: "The facilitator caught the mistake before it happened, preventing a natural teaching moment." Codex: "The session never tests whether Karthik would protect himself from a bad baseline." Threshold precision should be tested authentically.
  - **Confidence:** high

- **File:** teaching/stage-5/eval-ratchet.teach.md
  - **Before:** Coaching section said "Read eval results. For each dimension:" — implying dimension-by-dimension delivery
  - **After:** Replaced with holistic coaching instruction: "Deliver coaching as a holistic summary, not dimension by dimension. 1-3 sentences per dimension maximum. Lead with what's Strong, weave in what's Weak. Do not recap conclusions the developer already reached during the session."
  - **Why:** Opus weakness #3: coaching synthesis covers four distinct topics across two paragraphs, going dimension by dimension. teacher-instructions.md Section 4 says "Do not mechanically go dimension by dimension." The script's framing ("For each dimension") invited the violation.
  - **Confidence:** high

- **File:** teaching/stage-5/eval-ratchet.teach.md
  - **Before:** No `## Wait-Time Insights` section existed
  - **After:** Added 6 ordered wait-time insights tagged with `[define-success]`, `[specificity]`, `[feedback-loops]`, `[enterprise]`, `[verify]`, `[iteration]`
  - **Why:** `consecutive_wait_time_insights_missing` was auto-promoted at cycle 8. Eval-ratchet has multiple subagent runs (baseline measurement, config/script creation, override mechanism). Cycle 13 transcript improvised three good insights but the script lacked a reusable list. This is the Stage 5 eval-ratchet application.
  - **Confidence:** high

- **File:** teaching/stage-5/eval-ratchet.teach.md
  - **Before:** No enterprise grounding section existed. Facilitator never connected ratchet design to team governance, config conventions, or cross-project coordination.
  - **After:** Added `## Enterprise Grounding` section before Bridge. Required question: "On your team, who is allowed to lower this threshold — and does that change need a PR approval?" Two optional follow-ups on config location and cross-project ratchets.
  - **Why:** Enterprise readiness at 3/5 for ninth consecutive cycle (5-13). Opus flagged three specific gaps: no team governance, no file location conventions, no cross-project coordination. Codex flagged same gaps plus unused v1 artifacts polluting a shared repo. `enterprise_context_missed_openings` auto-promoted at cycle 7; this is the Stage 5 eval-ratchet application.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Karthik's multitasker persona fades in final third — attention breaks concentrate in first third, engagement increases monotonically
  - **Evidence:** cycle 13 (Opus weakness on mock dev realism, Codex weakness #2). Also cycles 5, 7, 9, 11, 12 (cross-model persona fading)
  - **Occurrences:** 6 (incrementing `haiku_persona_over_polishing` from 5). Already auto-promoted at cycle 9. Opus confirms this is now a "cross-model pattern" — both Haiku and GPT 5.4 show the same 60/40 split. Suggested fix: simulator persona instruction "Maintain persona-defining behaviors throughout, including the final third."
  - **Why not applied:** Simulator persona constraint issue, not a teaching script gap.

- **Finding:** Unused v1 artifacts (.quality-ratchet-v1.json, scripts/check_ratchet_v1.py) created as simulator scaffolding but not cleaned up
  - **Evidence:** cycle 13 (Codex weakness #3)
  - **Occurrences:** 1
  - **Why not applied:** Simulator artifact hygiene issue, not a teaching script bug. If teaching scripts need contrast artifacts for "mistake instruction," they should be shown in the transcript and deleted after the contrast. Hidden scaffolding should not pollute the target repo.

- **Finding:** Enterprise readiness at 3/5 for ninth consecutive cycle — structural gap
  - **Evidence:** cycles 5-13 (both evaluators every cycle)
  - **Occurrences:** 9 — already promoted and applied per-module since cycle 7. Enterprise grounding sections now exist in cycle-review, metrics-dashboard, test-writer, spec-first, escalation-routing, spec-to-pipeline, and eval-ratchet. Remaining: Stage 0 acts, bug-fix, code-review, refactor, build-then-test, role-separation, review-gate, three-agent-pipeline, parallel-reviewers, eval-foundation, and remaining Stage 5-7 modules.
  - **Why not applied universally:** Same rationale — each module needs contextually appropriate enterprise questions.

---

### Cycle 14 — Priya (eager) — Stage 0 (all acts) — REGRESSION

**APPLIED (Bucket A):**

None. This was a regression cycle — no script changes applied.

**PROPOSED (Bucket B):**

- **Finding:** Act 1 demonstration picks `src/flask/config.py` despite script saying "not a config file"
  - **Evidence:** cycle 14 (Codex script faithfulness deduction)
  - **Occurrences:** 1
  - **Why not applied:** The file contains real framework logic (Flask's config module), so it is arguably "not a config file" in the application-config sense. But the literal filename violates the script's selection rule. This is a script instruction that could be tightened ("not a file whose primary purpose is configuration, and avoid files with 'config' in the name") or a simulator file-selection constraint. Not a regression — the same script instruction existed in Cycle 1.

**Regression Result:**

- **Opus:** 28/35 (+1 vs Cycle 1 baseline of 27/35). Script Faithfulness improved 4→5. All other dimensions held.
- **Codex:** 27/35 (same as Cycle 1 baseline of 27/35). All dimensions held.
- **Verdict:** NO REVERT. No dimension dropped. Pipeline improvements are net-positive.
- **Carried forward:** Act 2 review verification, Act 3 hands-on step, and enterprise question paths remain unimplemented from Cycle 1 recommendations.

---

### Cycle 15 — Sneha (enterprise) — Stage 1 / Code Review

**APPLIED (Bucket A):**

- **File:** teaching/meta/teacher-instructions.md
  - **Before:** Security/Privacy: "Your code stays on your machine. The AI reads files locally and sends context to the model for processing. Check your team's data policy for specifics on retention — with most configurations, nothing is stored after the session."
  - **After:** Security/Privacy: "The AI reads files locally and sends the relevant context to the model for processing. Nothing is persisted after the session in most configurations — check your team's data policy for specifics on retention and data handling. Your security team can verify the exact data flow for compliance."
  - **Why:** "Your code stays on your machine" directly contradicts "sends context to the model for processing." Enterprise security teams would flag this. Both evaluators independently flagged as critical.
  - **Confidence:** high

- **File:** teaching/stage-1/code-review.teach.md
  - **Before:** All-Strong coaching was a single block: "That's how you use AI review — tight scope, triaged the findings, steered for depth, and didn't trust a clean bill of health..."
  - **After:** Split into two exchanges with a required developer response between them. Added note: only use "probe beyond positive review" nudge when the first pass was actually mostly clean.
  - **Why:** Both evaluators flagged 5-sentence monologue debrief violating teacher-instructions.md Section 5 (1-3 sentences max) and Section 4 (never read eval results as a list). Recurring pattern from prior cycles.
  - **Confidence:** high

- **File:** teaching/stage-1/code-review.teach.md
  - **Before:** HEALTHY SKEPTICISM Strong criterion: "Developer probed beyond positive feedback — asked follow-up questions even when the review was mostly clean."
  - **After:** "Developer shows they are not accepting the review at face value — challenges questionable findings, asks for evidence or focused follow-up, or probes beyond positive feedback when the review is mostly clean."
  - **Why:** Codex flagged rubric mismatch — Sneha demonstrated real skepticism (challenged findings, requested security pass) but the criterion only recognized probing clean reviews. The old criterion was too narrow for code review where findings exist.
  - **Confidence:** high

- **File:** teaching/stage-1/code-review.teach.md
  - **Before:** No `## Wait-Time Insights` section, no `## Enterprise Grounding` section
  - **After:** Added 5 ordered wait-time insights tagged with `[review-scales]`, `[iteration]`, `[specificity]`, `[verify]`, `[enterprise]`. Added Enterprise Grounding section with team workflow connection question.
  - **Why:** teacher-instructions.md Section 13 requires each module to have an ordered insight list. Enterprise grounding section follows pattern established in test-writer (cycle 9) and applied to all subsequent modules.
  - **Confidence:** high

- **File:** teaching/stage-1/code-review.teach.md
  - **Before:** Healthy skepticism coaching phrases referenced only probing positive feedback
  - **After:** Coaching phrases updated to reflect broadened criterion — Strong praises challenging findings, Adequate coaches on pushback and focused follow-ups, Weak shows the full range of skepticism behaviors
  - **Why:** Coaching language must match the updated dimension definition. Old coaching was misaligned after criterion broadening.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Eval-mediated coaching loop not evidenced in code-review simulator artifacts
  - **Evidence:** cycle 15 (Opus weakness #2, Codex weakness #2)
  - **Occurrences:** 1
  - **Why not applied:** The script already specifies eval delegation (async: true). The issue is that simulator transcripts don't show the eval step running even when all dimensions are Strong. This is a simulator/transcript format concern, not a script bug. If other Stage 1 modules show the same pattern, promotes to cross-cutting simulator fix.

- **Finding:** Triage prompt fires proactively before developer has a chance to treat findings equally
  - **Evidence:** cycle 15 (Opus script faithfulness deduction, Codex script faithfulness deduction)
  - **Occurrences:** 1
  - **Why not applied:** The script already says the prompt fires "If the developer treats all findings equally without triaging." One occurrence of premature firing is not enough to require a structural guard. Tracking.

- **Finding:** Out-of-order stage completion not handled — developer who completed Stage 3 returns to Stage 1 recipe
  - **Evidence:** cycle 15 (simulator note)
  - **Occurrences:** 1
  - **Why not applied:** Structural addition to all recipe scripts. Would need a universal handling pattern in teacher-instructions.md. One occurrence — tracking.

### Cycle 16 — Ananya (anxious) — Stage 6/continuous-dev

**APPLIED (Bucket A):**

- **File:** teaching/stage-6/continuous-dev.teach.md
  - **Before:** No fully adaptive discovery guardrail after Setup section
  - **After:** Added guardrail: "After presenting discovery results, do not enumerate or sequence the findings. Ask an open question. Let the developer identify and prioritize the problems. If the developer misses a finding, raise it after they finish their own agenda."
  - **Why:** Both evaluators found the facilitator drives the agenda ("Three problems, three fixes"), sequences topics, and decides when each is complete. This is guided-adaptive behavior in a fully-adaptive session. Same mode-mismatch pattern from cycles 6 and 13.
  - **Confidence:** high

- **File:** teaching/stage-6/continuous-dev.teach.md
  - **Before:** No per-agent memory design guardrail in Facilitator Response section
  - **After:** Added guardrail: "The developer must specify each agent's owner, purpose, key fields, and update timing before state files are created. The facilitator may suggest missing safety-critical fields, but the code-work delegation should reflect the developer's design, not a facilitator-authored schema."
  - **Why:** Ananya said "each agent gets its own file" but the facilitator specified all fields (owner, purpose, update timing, data schemas) without developer input. Both evaluators flagged this as the most consequential mode violation — the eval cannot meaningfully rate per-agent memory design if the developer did not design it.
  - **Confidence:** high

- **File:** teaching/stage-6/continuous-dev.teach.md
  - **Before:** No `## Wait-Time Insights` section, no `## Enterprise Grounding` section
  - **After:** Added 5 ordered wait-time insights tagged with `[feedback-loops]`, `[verify]`, `[define-success]`, `[enterprise]`, `[feedback-loops]`. Added Enterprise Grounding section with three enterprise-context questions for team handoff, parallel pipelines, and cross-repo learnings.
  - **Why:** teacher-instructions.md Section 13 requires each module to have an ordered insight list. Enterprise grounding section follows pattern established in cycle-review (c7) and applied to all subsequent modules. continuous-dev was missing both.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Eval-mediated coaching loop not evidenced in continuous-dev simulator artifacts
  - **Evidence:** cycle 16 (Opus weakness #3, Codex finding #3). Same pattern as cycle 15.
  - **Occurrences:** 2 (incremented from 1)
  - **Why not applied:** Recurring issue — same as `eval_loop_not_evidenced` in state.json. The script already specifies async eval delegation. This is a simulator/transcript format concern, not a script bug.

- **Finding:** Formal continuous-dev sub-recipe delegation not exercised in transcript
  - **Evidence:** cycle 16 (Opus weakness #3, Codex weakness #3)
  - **Occurrences:** 1
  - **Why not applied:** The transcript uses ad-hoc code-work delegations instead of the structured `sub-recipe: "continuous-dev"` call. May require coordination with simulator harness and recipe wrapper. The conversational approach is pedagogically valid but leaves the production recipe interface untested.

---

### Cycle 17 — Arjun (curious/distracted) — Stage 7 / Skill Evolution

**APPLIED (Bucket A):**

- **File:** teaching/stage-7/skill-evolution.teach.md
  - **Before:** After discovery results, facilitator presented findings with diagnostic commentary: "[Here's what it found...] [These findings mapped to instruction gaps...]"
  - **After:** Added fully adaptive discovery guardrail: "Present raw findings without diagnostic commentary. Do not name the finding-to-instruction connection for the developer. Ask 'What do you notice?' Let the developer trace each finding to its instruction source. If the developer misses a connection, hint with a question rather than stating the answer."
  - **Why:** Both evaluators flagged facilitator saying "The escalation rule you wrote landed in LEARNINGS.md instead of in the agent's instruction file" — pre-digesting the core 7.1 skill (finding-to-instruction tracing). Opus: "the facilitator does the hardest analytical step of the session." Codex: "the first and most important trace is partially handed to him." Same mode-mismatch pattern from cycles 13 and 16.
  - **Confidence:** high

- **File:** teaching/stage-7/skill-evolution.teach.md
  - **Before:** No finding-validity check before using review findings to edit instructions
  - **After:** Added verification-quality guardrail: "Before the developer edits instructions based on review findings, have them sample-check at least one finding against the source. Ask: 'Before we tune the instruction around these findings, which of these are actually correct? Pick one and check the code.'"
  - **Why:** Codex flagged that baseline review data included shaky claims (abort() NoReturn finding, get_flashed_messages() caching treated as bug). The session teaches "measure before changing" but not "validate that the measurement source is trustworthy." For Stage 7 where findings update agent instructions, bad findings are not incidental — they make bad signal more durable.
  - **Confidence:** high

- **File:** teaching/stage-7/skill-evolution.teach.md
  - **Before:** No `## Wait-Time Insights` section, no `## Enterprise Grounding` section
  - **After:** Added 6 ordered wait-time insights tagged with `[feedback-loops]`, `[specificity]`, `[verify]`, `[enterprise]`, `[iteration]`, `[define-success]`. Added Enterprise Grounding section with two enterprise-context questions on instruction review process and file location.
  - **Why:** teacher-instructions.md Section 13 requires each module to have an ordered insight list. Enterprise grounding section follows pattern established in cycle-review (c7) and applied to all subsequent modules. skill-evolution was missing both. `consecutive_wait_time_insights_missing` and `enterprise_context_missed_openings` both auto-promoted.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Facilitator does not probe instruction design decisions — accepts threshold values and edge cases uncritically after challenging the intuition-based removal
  - **Evidence:** cycle 17 (Opus weakness #3)
  - **Occurrences:** 1
  - **Why not applied:** The facilitator correctly challenges the intuition-based style removal (strong intervention). Probing every design decision would be enhancement, not a bug fix. In fully-adaptive consulting mode, accepting the developer's design and letting the pipeline verify is valid. If future cycles show facilitators consistently skipping edge-case probes, escalate.

- **Finding:** Arjun's persona flattens to cooperative-competent after a single tangent — curiosity demonstrated once then abandoned
  - **Evidence:** cycle 17 (Opus weakness #1, Codex weakness #3). Also cycles 5, 7, 9, 11, 12, 13 (cross-model persona fading)
  - **Occurrences:** 7 (incrementing `haiku_persona_over_polishing` from 6). Already auto-promoted at cycle 9. Opus confirms single-tangent-then-perfect-focus pattern.
  - **Why not applied:** Simulator persona constraint issue, not a teaching script gap.

- **Finding:** Eval-mediated coaching loop not evidenced in skill-evolution simulator artifacts
  - **Evidence:** cycle 17 (Opus evidence-against on script faithfulness). Same pattern as cycles 15-16.
  - **Occurrences:** 3 (incrementing `eval_loop_not_evidenced` from 2)
  - **Why not applied:** Recurring issue. The script specifies async eval delegation. Simulator transcripts consistently show no eval step. Three occurrences — tracking for potential promotion at next cycle.

- **Finding:** Sub-recipe delegation not exercised — ad-hoc code-work delegations used instead of structured skill-evolution sub-recipe call
  - **Evidence:** cycle 17 (Codex script faithfulness deduction). Same pattern as cycle 16.
  - **Occurrences:** 2 (incrementing `sub_recipe_delegation_not_exercised` from 1)
  - **Why not applied:** Same rationale as cycle 16 — conversational approach is pedagogically valid but leaves production recipe interface untested.

---

### Cycle 18 — Deepak (hostile) — Stage 1 / Refactor

**APPLIED (Bucket A):**

- **File:** teaching/stage-1/refactor.teach.md
  - **Before:** No verification-evidence guardrail after "If the developer accepts immediately" diff review prompt
  - **After:** Added note: "When pointing out potential behavioral changes, show specific evidence from the diff. Do not claim a concrete behavior change unless the diff demonstrates it. If you suspect a subtle change but cannot confirm, phrase it as a verification question." Added overclaiming warning for hostile/experienced developers.
  - **Why:** Codex weakness #1: facilitator claimed early-return refactor changed error-display behavior, but the `elif` in the original code already showed only one error. Teaching from a false diff interpretation undermines facilitator credibility, especially with hostile developers who will exploit factual errors.
  - **Confidence:** high

- **File:** teaching/stage-1/refactor.teach.md
  - **Before:** No engagement-probing guidance in Framing section
  - **After:** Added "Engagement hook" block: if the developer names a specific codebase area, probe the history (who wrote it, when, what changed). Developers hostile to the session may still engage with their codebase's story.
  - **Why:** Opus weakness #2: facilitator had only one engagement tool (direct challenge "did you actually read the diff?"). Probing domain knowledge gives a second engagement strategy that connects to the developer's existing expertise rather than confronting their disengagement.
  - **Confidence:** medium

- **File:** teaching/stage-1/refactor.teach.md
  - **Before:** No guidance for combining goal_definition and scope_control coaching when both are Weak
  - **After:** Added combined coaching pattern: "Compare 'clean up auth' to 'flatten the nesting in register() lines 12-30.' The second one is specific enough that you can verify the result in one diff — and narrow enough that if the AI makes a mistake, you've only touched 20 lines." Avoids delivering scope as a separate brief mention that won't register with disengaged developers.
  - **Why:** Opus weakness #3: scope-control coaching was one sentence at the end of the debrief. For a hostile developer barely processing coaching at all, a brief separate mention is functionally no mention. Combining scope into goal-definition coaching leverages the stronger teaching point.
  - **Confidence:** high

- **File:** teaching/stage-1/refactor.teach.md
  - **Before:** Bridge had no adaptation for disengaged developers
  - **After:** Added hostile-persona adaptation: if developer was disengaged and did not verify, reframe bridge from "you've been catching everything" to a value proposition tied to the diff risk demonstrated in the session.
  - **Why:** Opus pacing weakness: bridge assumes the developer felt the weight of being "the one catching everything," but a disengaged developer caught nothing. The bridge should match what the developer experienced.
  - **Confidence:** high

- **File:** teaching/stage-1/refactor.teach.md
  - **Before:** No `## Wait-Time Insights` section, no `## Enterprise Grounding` section
  - **After:** Added 5 ordered wait-time insights tagged with `[specificity]`, `[verify]`, `[verify]`, `[enterprise]`, `[iteration]`. Added Enterprise Grounding section with team review question and two optional follow-ups on shared modules and cross-service refactoring.
  - **Why:** teacher-instructions.md Section 13 requires each module to have an ordered insight list. Enterprise grounding section follows pattern established in cycle-review (c7) and applied to all subsequent modules. refactor was missing both. `consecutive_wait_time_insights_missing` and `enterprise_context_missed_openings` both auto-promoted.
  - **Confidence:** high

**PROPOSED (Bucket B):**

- **Finding:** Deepak's hostility flatlines to passive indifference after E1 refusal — no active pushback after the initial refusal
  - **Evidence:** cycle 18 (Opus weakness #1, Codex weakness #3). Also cycles 5, 7, 9, 11, 12, 13, 17 (cross-model persona fading)
  - **Occurrences:** 8 (incrementing `haiku_persona_over_polishing` from 7). Already auto-promoted at cycle 9. Both evaluators confirm sustained active resistance would be the true stress test.
  - **Why not applied:** Simulator persona constraint issue, not a teaching script gap.

- **Finding:** All-weak eval forced against module rubric — scope_control and goal_definition ratings may not be grounded in transcript evidence
  - **Evidence:** cycle 18 (Codex weakness #2). Deepak narrows to one function and provides rough structural direction ("too nested," "flatten it out").
  - **Occurrences:** 1
  - **Why not applied:** Simulator eval calibration issue. If E9 requires all-weak, the developer behavior should actually be all-weak. The teaching script rubric is correct; the simulator needs to generate behavior that matches.

- **Finding:** Eval-mediated coaching loop not evidenced in refactor simulator artifacts
  - **Evidence:** cycle 18 (implicit — same pattern as cycles 15-17)
  - **Occurrences:** 4 (incrementing `eval_loop_not_evidenced` from 3). **Promoting to Bucket A at next applicable cycle** — four occurrences across four different modules.
  - **Why not applied:** Cross-cutting simulator/transcript format concern. The scripts specify async eval delegation. All four cycles (15-18) show no eval step in transcripts. Needs a structural fix to the simulator harness, not individual script changes.

---

### Cycle 19 — Sneha (enterprise) — Stage 3 / Three-Agent Pipeline — REGRESSION

**APPLIED (Bucket A):**

None. This was a regression cycle — no script changes applied.

**PROPOSED (Bucket B):**

- **Finding:** Mock developer violates Stage 3 mistake-realism instruction — pipeline design arrives fully structured with no coachable flaw
  - **Evidence:** cycle 19 (Opus mock dev realism -1, Codex weakness #2). Sneha's handoffs are typed and complete from the start; the script's designed flaw (partly-prose handoffs) never triggers.
  - **Occurrences:** 1
  - **Why not applied:** Simulator/test-harness issue, not a teaching script regression. The Stage 3 loop prompt says mock developers should include at least one subtle pipeline flaw. Haiku-generated Sneha did not comply. Future Stage 3 regressions should enforce this constraint more explicitly.

- **Finding:** Haiku-generated Sneha lacks distinctive enterprise vocabulary compared to GPT 5.4 Sneha
  - **Evidence:** cycle 19 (Opus mock dev realism -1). Missing "compliance-grade traceability," "policy violation," no spontaneous E8 data privacy question. Incrementing `haiku_persona_over_polishing` from 8 to 9 (already promoted).
  - **Occurrences:** 9 total. Already auto-promoted at cycle 9. Model quality issue, not script regression.
  - **Why not applied:** Simulator persona/model quality concern. The teaching script and facilitator behavior both improved; the persona simulation was weaker due to model choice.

- **Finding:** Advertised mock model provenance ambiguous — transcript says "Haiku (pre-generated responses)" but simulator log says "Haiku (simulated by Opus)"
  - **Evidence:** cycle 19 (Codex weakness #3)
  - **Occurrences:** 1
  - **Why not applied:** Simulator labeling issue. If Opus simulated Haiku rather than invoking Haiku, the model-diversity claim is weaker. Should be logged honestly.

**Regression Result:**

- **Opus:** 34/35 (+3 vs Cycle 4 baseline of 31/35). Script Faithfulness +1, Pedagogy +1, Pacing +1, Enterprise Readiness +1. Mock Dev Realism -1 (model quality, not script). Stuck-Path carried from baseline (no edge case triggered).
- **Codex:** 27/35 (same as Cycle 4 Codex baseline of 27/35). Script Faithfulness +1, Pedagogy +1, Enterprise Readiness +2. Mock Dev Realism -1, Stuck-Path +1 (carried). Fourth-Wall held at 3/5 (transcript artifact leak still unfixed).
- **Verdict:** NO REVERT. No dimension dropped 2+. All facilitator-controlled dimensions improved or held. The one regression (Mock Dev Realism -1) is attributable to Haiku mock model quality, not script degradation. Both Cycle 4 enterprise-overclaiming and scope-contract issues are visibly fixed.

---

### Cycle 20 -- Karthik (multitasker) -- Stage 5 / Eval Foundation -- FINAL REGRESSION

**APPLIED (Bucket A):**

None. This was the final regression cycle and no script degradation was found.

**PROPOSED (Bucket B):**

- **Finding:** Known-gaps ownership question not fully exercised
  - **Evidence:** cycle 20 (Opus Enterprise Readiness 4/5, Codex weakness #1). The facilitator asks whether unverifiable claims go to a known-gaps log or human review, but does not ask who owns the log or what trigger keeps it reviewed.
  - **Occurrences:** 2 total (first seen in Cycle 6's "someone periodically checks" known-gaps concern, confirmed in Cycle 20 regression).
  - **Why not applied:** `teaching/stage-5/eval-foundation.teach.md` already contains the exact ownership rule: "Who owns the known-gaps log? If the answer is 'someone,' it means nobody." This is a simulator/facilitator adherence issue, not missing script text.

- **Finding:** Clean regression under-tests Karthik's multitasker texture
  - **Evidence:** cycle 20 (Opus Mock Dev Realism 4/5, Codex Mock Dev Realism 4/5). Karthik has time pressure and stale-memory trust, but no Slack tangent, memory slip, or forced context switch like Cycle 6.
  - **Occurrences:** 1
  - **Why not applied:** The cycle intentionally used no forced edge cases to isolate the structural fix. Both evaluators agree this is not a teaching-script regression. Future Stage 5 regressions should include one realistic interruption to verify the fix under distraction.

**Regression Result:**

- **Opus:** 28/30 on comparable dimensions (+4 vs Cycle 6 comparable baseline of 24/30). Script Faithfulness +1, Pedagogy +2, Pacing +1, Enterprise Readiness +1. Mock Dev Realism -1 due to clean no-edge-case design. Stuck-Path not tested.
- **Codex:** 28/30 on comparable dimensions (+4 vs Cycle 6 comparable baseline of 24/30). Same score movement as Opus: Script Faithfulness +1, Pedagogy +2, Pacing +1, Enterprise Readiness +1, Mock Dev Realism -1, Stuck-Path not tested.
- **Verdict:** NO REVERT. No dimension dropped 2+. The primary regression target is verified: Karthik designs the verification plan before any code operation runs. The developer-driven Stage 5 fix holds.
