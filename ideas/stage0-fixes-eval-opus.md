# Evaluation: Wait-Time Insights Framework, Insight Library, Script Integration, and Audit Fixes

**Evaluator:** Claude Opus 4.6 (independent)
**Date:** 2026-04-12
**Scope:** Section 13 of teacher-instructions.md, wait-time-insights.md, 5 Stage 0 act scripts, 4 Stage 1 teaching scripts

---

## A. Framework Coherence (Section 13 in teacher-instructions.md)

**Score: 4/5**

### What Works

- Rules are unambiguous for an LLM facilitator. The seven numbered rules cover the key behavioral cases: when to fire, when to skip, what to do when the list runs out, and when silence is acceptable. An LLM can follow these without interpretation guesswork.
- The 30-second threshold for skipping is practical. Simple git commands and file reads genuinely do return fast; this avoids the forced-insight anti-pattern.
- The revisit mechanism is well-integrated with progression state. Checking Strong/Weak/Adequate before drawing from old pools ties directly into Section 4 (Working with Eval Results) and Section 9 (State Management). No contradictions found.
- Rule 7 ("Never fourth-wall content") is consistent with Section 1's Fourth Wall Rule and Section 12's Universal Rule #1.
- The Enterprise Insights section is accurate for Reliance's context. CI/CD, security/privacy, IDE, team workflows, code review compatibility, and audit/compliance are the right concerns for enterprise dev teams.
- Voice guidance with example openers is concrete and matches Section 1's colleague voice.

### What Doesn't Work

1. **Rule 4 ("Ordered per module") conflicts with natural conversation flow.** The rule says "use them in order. Don't skip ahead or pick favorites." But what if insight #2 in the list is contextually irrelevant at the second wait point? The facilitator should pick the most contextually appropriate insight, not rigidly follow list order. The ordering constraint helps prevent an LLM from cherry-picking its favorites, but it also prevents adapting to the conversation. This needs a release valve.

2. **Enterprise Insights have no guidance on when to use proactively vs. reactively.** The text says "when contextually relevant, or in response to direct questions" but doesn't tell the facilitator how to detect contextual relevance. A developer at Reliance muttering about Jenkins is a trigger; a developer happily coding is not. The LLM needs a signal-detection heuristic, not just "when contextually relevant."

3. **The Security/Privacy insight is slightly misleading.** "No code is stored on external servers after the session" -- this depends on the provider and configuration. With ACP and Claude Max, the claim is roughly accurate but not guaranteed. For Codex/OpenAI, different retention policies may apply. Since Goose Wizard is "provider-agnostic, Claude Code default" (Principle 8), this insight should hedge or be parameterized by provider.

### Specific Fixes Needed

| File | Section | Fix |
|------|---------|-----|
| `teacher-instructions.md` | Section 13, Rule 4 | Add: "If the next insight in order is clearly irrelevant to the current operation, skip it and use the next one. The order is a default, not a straitjacket." |
| `teacher-instructions.md` | Section 13, Enterprise Insights | Add a trigger sentence before the list: "Share these when the developer mentions enterprise tooling, asks about team impact, or raises a concern about security/process. Do not volunteer enterprise context unprompted unless the developer is visibly hesitant about adopting the tool." |
| `teacher-instructions.md` | Section 13, Security/Privacy insight | Change to: "Your code stays on your machine. The AI reads files locally and sends context to the model for processing. Check your team's data policy for specifics on retention — with most configurations, nothing is stored after the session." |

---

## B. Insight Quality (wait-time-insights.md)

**Score: 4/5**

### What Works

- Colleague voice is consistent across all insights. None of them sound like a teacher or a training module. "Something to watch for with bug fixes -- AI loves wrapping things in try/catch" is exactly how an experienced colleague talks.
- Tags are correct. Every insight maps to a legitimate cross-cutting theme from the syllabus. Verified against the syllabus table at lines 308-317:
  - `[iteration]` maps to "Feedback loops must close" (the early-stage manifestation of iteration)
  - `[specificity]` maps to "Specificity determines quality"
  - `[verify]` maps to "Verify by execution, not inspection"
  - `[enterprise]` maps to enterprise integration (not a syllabus theme per se, but called out in CLAUDE.md principles)
  - `[review-scales]`, `[feedback-loops]`, `[specialization]`, `[define-success]`, `[risk-ladder]`, `[redirect]` all map to syllabus themes or Stage 1 concepts
- Ordering within each module is logical. Stage 0 leads with iteration (the broadest, safest concept), then specificity, then verify, then enterprise as optional. Stage 1 recipes lead with the most contextually relevant insight for that recipe type.
- Revisit variants are meaningfully different from originals. "First round of tests is a draft" vs. "the first result is rarely the final one" -- same concept, different framing for different work. Good.

### What Doesn't Work

1. **Stage 0 has only 4 insights for 5 acts.** Act 3 (Undo Button) and Act 5 (Say It Better) have no wait-time insights. Act 3 is short enough that this may be intentional (the script only has brief subagent calls). But Act 5 has a subagent call for the "specific request" that could easily take 30+ seconds. This is a gap.

2. **No `[feedback-loops]` tag in Stage 0 or Stage 1.** The syllabus says feedback loops first appear at 1.1 (iterate). Insight 1.1c is tagged `[redirect]`, not `[feedback-loops]`. The iteration tag on 1.2c and 1.4d covers the iterative aspect, but the explicit "feedback loops must close" theme has no insight anywhere. This means the revisit mechanism can never reinforce `[feedback-loops]` because no insight exists in the pool for it.

3. **No `[specialization]` tag in Stage 0 or Stage 1.** This is defensible -- specialization first appears at Stage 2 per the syllabus. But the revisit pool should eventually include it. The file should note this as a future addition when Stage 2 insights are written.

4. **The "any remaining wait" placement for 1.1d, 1.2d, 1.3d, 1.4d is vague.** What triggers "any remaining wait"? A fourth subagent call? A long eval? The facilitator needs to know: if there are only 3 wait points in a session, insight "d" never fires. This is fine behavior but should be explicit.

5. **Revisit variants table is incomplete.** It covers 0.1, 0.2, 0.3, 1.1c, and 1.1d. That is 5 entries out of 20 total insights. The remaining 15 Stage 1 insights have no revisit variants. When a Stage 2+ developer revisits a 1.2a-style insight, the facilitator has no reworded variant to draw from and must improvise. This is acceptable for an LLM but reduces consistency.

### Specific Fixes Needed

| File | Section | Fix |
|------|---------|-----|
| `wait-time-insights.md` | Stage 0 table | Add insight 0.5 for Act 5 (specific request wait): `"While it works on that — notice how much more specific your instruction was that time. That gap between vague and specific? It shows up in everything AI does, not just code edits."` Tag: `[specificity]`. Wait Point: "Act 5: specific request execution" |
| `wait-time-insights.md` | After Stage 1 tables | Add a note: "Stage 2+ insights (including `[specialization]`, `[feedback-loops]`, and `[define-success]` deepening) will be added when Stage 2 teaching scripts are written." |
| `wait-time-insights.md` | Stage 1 tables | Change "Any remaining wait" to "Fourth wait point (if reached)" for clarity. |

---

## C. Script Integration (Stage 0 + Stage 1 .teach.md files)

**Score: 5/5**

### What Works

- **Placement is correct everywhere.** Every `While waiting` block appears immediately after a delegation to a subagent, at operations that genuinely take 30+ seconds (codebase scans, recipe execution, eval subagent runs). No While-waiting blocks appear at fast operations (git checkout, file writes, state updates).
- **Stage 0 placements:**
  - Act 1: Insight 0.1 during codebase scan (correct -- scanning and reading a meaningful file takes time)
  - Act 2: Insight 0.2 during improvement scan (correct -- scanning for edit candidates takes time)
  - Act 4: Insight 0.3 during bug planting (correct -- finding a function and planting a subtle bug takes time)
  - Act 3 and Act 5: No While-waiting blocks (correct -- Act 3's operations are fast git commands and single-file edits; Act 5's vague request is deliberately producing a quick, bad result)
- **Stage 1 placements:**
  - Each recipe has 3 While-waiting blocks: one at the stuck-path scan, one at recipe execution, one at eval delegation. These are the three longest operations in each recipe. The "d" insights are marked for "any remaining wait" which only fires if an additional long operation occurs.
  - Insights match what is happening. 1.1a (context quality) fires during investigation -- relevant. 1.2a (tests that all pass) fires during test writing -- relevant. 1.3a (AI defaults to polite) fires during review -- relevant. 1.4a (baseline tests) fires during refactoring -- relevant.
- **No forced-feeling placements.** I checked every delegation point across all 9 scripts. Short operations (git checkout, file writes, state writes, re-applying an edit) correctly have no insights attached.

### What Doesn't Work

- **Act 5, Step 2 (the specific request):** The subagent is asked to "do your best work" and "make the change to the file." This could take 30+ seconds for a complex function. There is no While-waiting block here. However, this is borderline -- the specific request might be fast because it is one function and the subagent already knows the context. I would not call this a defect, but it is where insight 0.5 (proposed above) would naturally slot in.

### Specific Fixes Needed

| File | Section | Fix |
|------|---------|-----|
| `act-5-say-it-better.teach.md` | Step 2, after the specific-request delegation | Consider adding: `While waiting (insight 0.5): "While it works on that — notice how much more specific your instruction was that time. That gap between vague and specific? It shows up in everything AI does, not just code edits."` -- But only if insight 0.5 is added to the master index. |

---

## D. Audit Fix Quality (Stage 0 scripts only)

**Score: 4/5**

### Act 2: Edit Candidate List

The edit candidate list in Act 2 Step 2 now specifies:
- A variable with a vague name that could be more descriptive
- A branch condition that could be clearer or more explicit
- A log or error message that could include more useful context

And explicitly says: "Avoid trivial changes like adding a comment -- the change should be something the developer needs to actually evaluate, not rubber-stamp."

**Verdict: Good.** The anti-rubber-stamp instruction is the key improvement. The candidate types are substantive -- renaming a variable, clarifying a condition, and improving a log message all require the developer to actually think about whether the change is correct. The explicit exclusion of trivial changes (comments) prevents the subagent from taking the easy path.

**One concern:** "A variable with a vague name (x, data, temp, result)" -- the examples `data` and `result` are not always vague. In some contexts, `result` is perfectly descriptive. The subagent might rename something that doesn't need renaming. This is minor -- the developer's review should catch it, and that is actually the point of the act.

### Act 3: Adaptive Shortcut

The adaptive shortcut now works as follows:
1. Check: developer used git terminology unprompted or expressed familiarity during Acts 1-2
2. If yes: "You already know git. Quick check -- if I made a change you didn't like, how would you undo it?"
3. If they can answer (git checkout, git restore, git reset): confirm, re-apply the edit, skip to State Write + bridge to Act 4
4. If not detected: run the full Act 3 (show diff, undo, re-apply)

**Verdict: Good.** The flow is correct for both paths. The shortcut path re-applies the edit (needed for Act 4's bug planting to have a working file state) and writes progress state before bridging. The full path is unchanged and works as before.

**One issue:** The shortcut path says "Let me just re-apply that edit from Act 2 so we have something to work with going forward." This is slightly awkward -- it implies the edit was undone, but in the shortcut path, the developer never undid it. The edit from Act 2 is still applied. The re-apply delegation will either no-op (if the code already matches) or error. This is a sequencing bug.

### Act 4: Immediate-Catch Path

The immediate-catch path (developer identifies the bug before being prompted) now reads:

"You read diffs carefully -- that habit is going to save you. [bug_explanation]. Most people skim and say 'looks fine.' You didn't. That's the single most important skill in AI-assisted development -- reading what the AI actually wrote, not trusting that it got it right."

**Verdict: Good.** This feels natural. It praises the specific behavior (reading diffs carefully) without being patronizing. The contrast with "most people skim" reinforces the teaching point without lecturing. It still lands the core message: AI is confident but fallible, your review matters.

The after-prompt catch path is also good: "You caught it." validates without over-praising, then delivers the core teaching point.

### Act 5: Semi-Specific Handling, Review Beat, Wrap-Up Language

**Semi-specific handling:** The script now includes a dedicated block for semi-specific instructions. If the developer says something like "add better error handling" (better than "improve it" but still vague), the facilitator pushes with a targeted question: "What specific errors? What should happen when each one occurs?" This guides without lecturing. The examples cover error handling, readability, and performance.

**Verdict: Good.** The push is specific and contextual, not generic. The facilitator asks a question, not delivers a lecture. This matches coaching voice rules (Section 5).

**Review beat:** After the specific request is applied, the facilitator says: "Before we compare -- take a look at that diff. Could this change break anything?" This reinforces Act 4's lesson about reviewing AI output.

If the developer spots an issue: acknowledge and fix (reinforces Act 4).
If the developer says it looks fine: accept and move on. "The review habit is forming -- don't force a false finding."

**Verdict: Good.** The "don't force a false finding" instruction is critical. An LLM facilitator might be tempted to manufacture a problem for teaching purposes -- this rule prevents that. Natural reinforcement without artificiality.

**Wrap-up language:** The wrap-up now lists 5 takeaways in direct language and bridges to Stage 1 with: "Next time, bring a real bug or some code you've been meaning to clean up."

**Verdict: Good.** No fourth-wall breaks detected. No "you've completed Stage 0" or "the teaching framework" language. The numbered list is functional, not academic. The bridge frames Stage 1 as practical value ("fixing real problems, writing real tests") not curriculum advancement.

### Specific Fixes Needed

| File | Section | Fix |
|------|---------|-----|
| `act-3-undo-button.teach.md` | Adaptive Shortcut, re-apply step | The edit from Act 2 is still applied on the shortcut path (the developer never undid it). Either (a) remove the re-apply delegation from the shortcut path, or (b) add "Let me undo and re-apply that edit so you can see it's reversible" as a quick demonstration even in the shortcut. Option (a) is cleaner. |

---

## Overall Assessment

| Section | Score | Summary |
|---------|-------|---------|
| A. Framework Coherence | 4/5 | Clear rules, well-integrated. Ordering rigidity and enterprise trigger guidance need fixes. Security claim needs hedging. |
| B. Insight Quality | 4/5 | Strong colleague voice, correct tags, logical ordering. Gap at Act 5, missing feedback-loops tag, incomplete revisit variants. |
| C. Script Integration | 5/5 | All placements correct. No forced insights at fast operations. Context-appropriate throughout. |
| D. Audit Fix Quality | 4/5 | All four audit fixes are solid improvements. Act 3 adaptive shortcut has a sequencing bug with the re-apply step. |

### Ship Decision: **Conditional**

Ship after fixing the following punch list. None are architectural -- all are localized text changes.

### Prioritized Punch List

1. **[Act 3 sequencing bug]** `act-3-undo-button.teach.md` -- Remove or rework the re-apply delegation in the adaptive shortcut path. The edit is already applied; re-applying is a no-op or error. **Priority: High** (runtime failure risk).

2. **[Ordering rigidity]** `teacher-instructions.md` Section 13 Rule 4 -- Add a contextual-skip escape hatch. **Priority: Medium** (affects facilitator naturalness).

3. **[Security claim]** `teacher-instructions.md` Section 13 Enterprise Insights -- Hedge the data-retention claim. **Priority: Medium** (accuracy for enterprise audience).

4. **[Missing Act 5 insight]** `wait-time-insights.md` + `act-5-say-it-better.teach.md` -- Add insight 0.5 for the specific-request wait point. **Priority: Medium** (gap in coverage).

5. **[Enterprise trigger guidance]** `teacher-instructions.md` Section 13 -- Add signal-detection heuristic for when to share enterprise insights proactively. **Priority: Low** (the LLM will mostly get this right without it, but explicit is better).

6. **[Missing tags note]** `wait-time-insights.md` -- Add a note about `[feedback-loops]` and `[specialization]` being future additions. **Priority: Low** (documentation completeness).

7. **["Any remaining wait" clarity]** `wait-time-insights.md` -- Rename to "Fourth wait point (if reached)." **Priority: Low** (minor clarity improvement).
