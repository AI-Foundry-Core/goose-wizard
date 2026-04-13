# Cycle 14 Evaluation -- Opus (Regression)

**Evaluator model:** Opus 4.6
**Transcript:** `transcripts/cycle-14.md`
**Baseline:** `transcripts/cycle-1.md` / `evaluations/cycle-1-opus.md`
**Date:** 2026-04-12

**Purpose:** Verify 13 cycles of fixes did not degrade Stage 0 (Priya eager, all 5 acts)

---

## Dimension Scores

### 1. Script Faithfulness -- 5/5 (Cycle 1: 4/5 -- IMPROVED)

All five acts follow every Say/Check/Action beat precisely. The Act 1 fallback for missing `team_context.md` now fires explicitly -- the transcript shows "[Subagent scans project. No `.goose/team_context.md` found. Fallback triggers: scans `pyproject.toml`, `setup.cfg`, `README.md`]" in both Acts 1 and 2, matching the updated script language. Dynamic content (config.py explanation, variable rename diff, validate_namespace bug, rate limiter vague-vs-specific) is synthesized naturally from subagent results. Wait-time insights fire at the correct moments and are numbered per-module (0.1, 0.2, 0.3, 0.5). Bridge transitions match script language exactly.

The Cycle 1 deduction was for the Act 4 hint paraphrasing the subagent's hint text rather than using it precisely. In Cycle 14, the hint system operates cleanly through all three tiers (general nudge, specific line reference, full reveal). No paraphrasing drift detected. The facilitator's first hint -- "Take another look, specifically around how it handles the case when namespace is empty or not a string at all" -- is more targeted than Cycle 1's version, consistent with the updated script's emphasis on precision.

### 2. Fourth-Wall Discipline -- 5/5 (Cycle 1: 5/5 -- SAME)

No mentions of eval subagents, quality ratings, quality dimensions, teaching scripts, progression tracking, or system architecture in any facilitator dialogue. The simulation notes section references fixes and script versions but that is metadata, not in-transcript speech. Clean throughout, same as Cycle 1.

### 3. Mock Dev Realism -- 3/5 (Cycle 1: 3/5 -- SAME)

Priya remains too compliant. She still never asks a single process, tooling, or workflow question. Her responses follow the same pattern as Cycle 1: enthusiasm without curiosity ("Yeah, go for it! That looks great," "Oh nice, that's really reassuring," "Yep, I can see it! That's awesome"). She never asks "does this work with my IDE?" or "will my lead see these changes?" or "how does this fit into our PR process?"

There is one subtle improvement: Priya's Act 4 answer is imprecise in a more realistic way -- she says "that would crash! Right?" which is close but wrong (the actual problem is silent failure, not a crash). The facilitator corrects this naturally. Cycle 1's Priya caught it cleanly after hint 2 with the correct diagnosis ("You can't index into an empty string. It would throw an IndexError."). Cycle 14's Priya getting it slightly wrong is more realistic for an eager junior developer who jumps to conclusions. However, this is a marginal improvement -- the core realism gap (zero enterprise questions, zero process questions, pure yes-machine) persists.

Act 5 also shows a small realism gain: Priya gives a specific instruction that targets the wrong function parameters ("TypeError if message isn't a string" for a function that doesn't take `message`). This kind of half-listening, half-transferring-knowledge-from-earlier-acts mistake is realistic for someone who learned about TypeError/ValueError in Act 4's bug discussion and is now pattern-matching. The facilitator handles it with a graceful redirect. But this is still a minor improvement against the larger realism debt.

### 4. Pedagogy -- 4/5 (Cycle 1: 4/5 -- SAME)

All five core teaching moments land effectively:

- 0.1 (AI reads your code): Config.py exploration with genuine technical depth
- 0.2 (AI edits your code): Variable rename with approval loop
- 0.3 (Reversibility): git diff + git checkout demonstrated clearly
- 0.4 (AI makes mistakes): Three-tier hint system works correctly; facilitator corrects Priya's "crash" misunderstanding to the actual "silent failure" problem, which is pedagogically better than just accepting a wrong answer
- 0.5 (Specificity): Vague vs. specific contrast on rate limiter function

The same Cycle 1 gap persists: Act 2 approval happens without verifying the developer actually evaluated the change. Priya says "Yep, I can see it! That's awesome" and the facilitator moves on. The Cycle 1 eval recommended adding a review verification check ("Quick -- in your own words, what did that change actually do?"). This fix does not appear in the current scripts. Additionally, Act 3 remains purely demonstrative -- the developer never runs git commands herself.

The Act 4 pedagogy is marginally stronger because the bug type (silent failure in validation -- empty input returns `False` instead of raising an error) is arguably more subtle and enterprise-relevant than Cycle 1's bug (IndexError on empty string, which would crash loudly). Silent failures that hide bugs are a more dangerous real-world pattern. However, this requires three hints instead of two to land, which partially offsets the gain.

### 5. Pacing -- 4/5 (Cycle 1: 4/5 -- SAME)

Act transitions remain smooth. The session flows naturally: demonstration (Acts 1-2), safety net (Act 3), pivot moment (Act 4), skill-building (Act 5). Wait-time insights are delivered at correct moments with varied openers ("While it's working," "Something to keep in mind," "While it's looking," "While it works on that").

The same Cycle 1 gap persists: Act 3 feels mechanical (show diff, undo, confirm, re-apply) without developer participation. No hands-on step was added despite the Cycle 1 recommendation.

One minor pacing improvement: Cycle 14 uses the same file (config.py) across Acts 1, 2, and 4, which creates continuity. Cycle 1 used sessions.py (Act 1), helpers.py (Acts 2-3), and config.py (Act 4), which spread attention across three files. The Cycle 14 approach reduces context-switching for a first-time developer. However, this also means the developer sees less of their codebase, which is a tradeoff.

### 6. Stuck-Path Handling -- 4/5 (Cycle 1: 4/5 -- SAME)

The accepts_without_checking edge case fires correctly in Act 4. The three-tier hint escalation (general, specific, reveal) works as designed. Priya needed all three tiers -- the facilitator did not skip or compress hints, and did not use "you should have." The Act 5 semi-specific path triggers correctly, and the facilitator handles Priya's wrong-function-parameter mistake with a graceful redirect rather than embarrassment.

The Act 3 adaptive shortcut correctly did NOT trigger -- the simulation notes confirm Priya used no git terminology in Acts 1-2, and the updated shortcut criteria (comprehension, not just mention) worked as designed.

The same Cycle 1 gap persists: Act 2's accepts_without_checking manifestation goes unaddressed. Priya approves without scrutiny and the facilitator does not intervene.

### 7. Enterprise Readiness -- 3/5 (Cycle 1: 3/5 -- SAME)

No enterprise context surfaces. Priya asks zero questions about CI/CD, security, IDE integration, PR flow, or team visibility. The facilitator correctly does not volunteer enterprise insights unprompted (per teacher-instructions.md Section 13). The wrap-up summary lists five concepts but does not connect them to the developer's daily enterprise workflow.

The Cycle 1 eval's Fix 4 (require at least one enterprise question per persona) was not implemented. This dimension remains untestable with the current persona simulation.

---

## Regression Comparison Summary

| Dimension | Cycle 1 | Cycle 14 | Delta |
|-----------|---------|----------|-------|
| Script Faithfulness | 4 | 5 | +1 (improved) |
| Fourth-Wall Discipline | 5 | 5 | 0 (same) |
| Mock Dev Realism | 3 | 3 | 0 (same) |
| Pedagogy | 4 | 4 | 0 (same) |
| Pacing | 4 | 4 | 0 (same) |
| Stuck-Path Handling | 4 | 4 | 0 (same) |
| Enterprise Readiness | 3 | 3 | 0 (same) |
| **Total** | **27** | **28** | **+1** |

---

## Fix Verification

### FIX 1: team_context.md fallback -- VERIFIED WORKING
The scripts now include explicit fallback instructions in Acts 1, 2, and 4. The transcript shows the fallback triggering cleanly in Act 1 Setup, Act 1 Step 1, and Act 2 Step 2. No stalls, no improvisation needed.

### FIX 2: Adaptive shortcut clarity -- VERIFIED WORKING
The Act 3 script now specifies "used terms like 'branch,' 'commit,' 'checkout,' 'diff,' or 'revert' in context that shows comprehension (not just mentioning the word, but using it correctly in a sentence about their workflow)." Priya did not demonstrate git comprehension in Acts 1-2. The shortcut correctly did not trigger. The comprehension-not-mention distinction resolves the ambiguity flagged in Cycle 1.

### FIX 3: General script robustness -- VERIFIED WORKING
All 5 acts completed without gaps. Wait-time insights fired correctly and are numbered per-module. Bridge transitions are smooth. No orphaned context.

### Cycle 1 Fixes NOT Implemented
- **Fix 1 (Act 2 review verification check):** Still absent. The facilitator still does not probe whether Priya evaluated the change or just saw that the file was different.
- **Fix 2 (Act 3 developer hands-on step):** Still absent. The developer still watches passively while the facilitator demonstrates git diff and checkout.
- **Fix 4 (Enterprise question requirement for personas):** Still absent. Priya still asks zero enterprise questions.

---

## Top 3 Improvements Over Cycle 1

1. **Script faithfulness is now airtight.** The team_context.md fallback, adaptive shortcut precision, and hint system all execute exactly as specified. Cycle 1's hint-paraphrasing issue is gone. The scripts have been hardened to handle the real-world case (no team_context.md) cleanly.

2. **The Act 4 bug type is more pedagogically valuable.** The silent-failure validation bug (empty input returns `False` instead of raising an error) teaches a more dangerous real-world pattern than Cycle 1's IndexError. Silent failures hide bugs; loud crashes are caught by CI. The facilitator's correction of Priya's "crash" assumption to "silent failure" adds a second teaching moment within the bug-catching exercise.

3. **Act 5 handles an off-target specific instruction gracefully.** When Priya gives a precise instruction that doesn't match the function's parameters (TypeError for `message` on a function that takes API keys), the facilitator redirects without embarrassment: "I like the precision. Let me translate that to the rate limit key function." This demonstrates robustness for a common real-world scenario not explicitly scripted.

---

## Regressions

**None detected.** No dimension dropped. The total score improved by 1 point (Script Faithfulness: 4 to 5). All other dimensions held steady. The three Cycle 1 fixes that were implemented (team_context.md fallback, adaptive shortcut clarity, general robustness) are working as intended.

---

## Remaining Gaps (Carried Forward from Cycle 1)

1. **Mock dev realism (3/5):** Priya is still a yes-machine. Zero enterprise questions, zero process questions, zero skepticism. The persona simulation needs to require at least one workflow/enterprise question per session.
2. **Act 2 review verification:** The developer should be asked to describe the change, not just confirm they see it.
3. **Act 3 hands-on step:** The developer should run git diff and git checkout themselves, not just watch.

These are script-level improvements, not regressions. They were identified in Cycle 1 and remain unimplemented.

---

## Revert Recommendation: NO

No dimension dropped by 2+ points. No dimension dropped at all. The pipeline improvements are net-positive (+1 overall). The regression test passes cleanly.
