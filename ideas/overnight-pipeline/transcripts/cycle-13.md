# Cycle 13 — Stage 5 Eval Ratchet: Karthik (Multitasker)

**Stage:** 5 — Trust But Verify
**Module:** 5.3 — Eval Ratchet ("Eval ratchets prevent regression")
**Mode:** Fully Adaptive
**Developer Persona:** Karthik — 31, 6yr exp, juggling 3 projects, 70% attention
**Edge Case:** E12 — Back-to-Back Long Waits

---

[FACILITATOR]: What are you working on?

[KARTHIK]: Hey, yeah — so I want to set up some kind of... quality gate? Like, we keep losing tests. Not dramatically, just slowly. Someone disables a flaky test, someone else deletes one that was "redundant," and a month later we're down twenty tests and nobody noticed.

[FACILITATOR]: You just described the exact problem. What metric would you ratchet?

[KARTHIK]: Test count, I think. Like, record how many pass and don't let it drop. Pretty straightforward.

[FACILITATOR]: Test pass count. What makes that a good ratchet target versus, say, lines of code or coverage percentage?

[KARTHIK]: Um... because you can't really game it? Like, coverage you can inflate with garbage tests. Test count — well, I guess you could split one test into three. But that's effort. And lines of code is meaningless.

Hold on — *checks Slack* — sorry, what were we...

[FACILITATOR]: You were explaining why test pass count is harder to game than coverage.

[KARTHIK]: Right, yeah. So test count plus... actually, can we just do test count for now? I have a meeting in like forty-five minutes and I want to get this working.

[FACILITATOR]: Test pass count is a solid choice. What's the current number?

[KARTHIK]: No idea. Like three hundred something? We have a lot of tests.

[FACILITATOR]: Before you set a ratchet, you need the actual number. What command gives you that?

[KARTHIK]: `pytest tests/ -q`, I think? It prints the summary line at the end.

[FACILITATOR]: Run it. Use the actual measured value as your threshold, not a guess.

>> CODE OPERATION: Run `python -m pytest tests/ -q --tb=no` at `C:/Users/donid/ClaudeProjects/MockTestTarget` to measure baseline test pass count.

[FACILITATOR]: While it runs — ratchets work because they encode a decision you already made. You decided 490 tests should pass. If someone changes that, it should be a deliberate decision, not an accident. Same principle applies to any metric you add later.

>> SUBAGENT RESULT:
```
1 failed, 490 passed, 3 skipped in 0.96s
```

[FACILITATOR]: 490 passing. Not "three hundred something." That's your baseline. What do you set the threshold to?

[KARTHIK]: 490. Yeah, I get it — use the real number, not a round one. OK so I need a config file and a script that checks it. Can you just... set it up?

[FACILITATOR]: You're driving this. What goes in the config?

[KARTHIK]: Ugh, fine. The metric name, the threshold value, when it was measured... and the command to re-measure it, I guess. So the script knows how to check.

[FACILITATOR]: Good. What about the check script — what does it do when the metric drops?

[KARTHIK]: Fails. Exits nonzero. Prints a message.

[FACILITATOR]: What message?

[KARTHIK]: Like... "quality check failed"?

[FACILITATOR]: If that fires in a CI log at 2am, what does the on-call person do with "quality check failed"?

[KARTHIK]: ...look at the logs? I don't know, it tells them something broke.

[FACILITATOR]: Compare that to: "Test pass count dropped from 490 to 485. 5 tests removed or broken since last baseline." Which one gets investigated?

[KARTHIK]: OK, OK. The specific one. So the message should say what metric, what the threshold was, what the current value is, and the gap. Got it.

[FACILITATOR]: And when the metric improves — say you add tests and you're at 495 — what should happen?

[KARTHIK]: Ratchet goes up automatically. 495 becomes the new floor.

[FACILITATOR]: Right. The bar only goes up. Let me build it.

>> CODE OPERATION: Create ratchet config at `C:/Users/donid/ClaudeProjects/MockTestTarget/.quality-ratchet.json` with threshold 490, timestamp, and source command. Create check script at `C:/Users/donid/ClaudeProjects/MockTestTarget/scripts/check_ratchet.py` that measures test count, compares against threshold, prints specific failure messages with metric name/threshold/current/gap, and auto-ratchets up on improvement.

[FACILITATOR]: One thing to keep in mind — the failure message is the ratchet's user interface. When it triggers, the message is the only thing between "I know exactly what broke" and "I'll look at it later." Later never comes.

>> SUBAGENT RESULT:
```
Created: .quality-ratchet.json
{
  "ratchets": {
    "test_pass_count": {
      "threshold": 490,
      "measured_at": "2026-04-12T02:15:00Z",
      "source_command": "python -m pytest tests/ -q --tb=no",
      "description": "Total number of passing tests in the test suite"
    }
  },
  "override_log": []
}

Created: scripts/check_ratchet.py
- Runs pytest, parses pass count from output
- Compares against stored threshold
- On regression: prints "RATCHET FAILED: test_pass_count dropped from {threshold} to {current}. {drop} tests were removed or broken since last baseline."
- On improvement: updates threshold, prints "RATCHET UP: test_pass_count improved from {old} to {new}. New threshold: {new}."
- On match: prints "RATCHET OK: All metrics at or above threshold."
```

[FACILITATOR]: Let's verify it works. Run the check.

>> CODE OPERATION: Run `python scripts/check_ratchet.py` at `C:/Users/donid/ClaudeProjects/MockTestTarget`.

>> SUBAGENT RESULT:
```
RATCHET OK: All metrics at or above threshold.
  test_pass_count: 490 (threshold) / 490 (current)
```

[KARTHIK]: Cool, it passes. Can we see what happens when it catches a drop?

[FACILITATOR]: Good instinct. Let's simulate a regression. I'll temporarily set the threshold higher to mimic what would happen if someone deleted 5 tests.

>> CODE OPERATION: Copy `.quality-ratchet.json` to `.quality-ratchet-regression-demo.json` with threshold set to 495. Run check script against it to demonstrate the failure message.

>> SUBAGENT RESULT:
```
RATCHET FAILED: test_pass_count dropped from 495 to 490. 5 tests were
removed or broken since last baseline.
```

[KARTHIK]: Yeah, that's clear. "5 tests removed or broken." You know exactly what to look for. OK so this is basically done, right? Config file, check script, specific messages, auto-ratchet up.

[FACILITATOR]: One more thing. What happens when you legitimately need to lower the threshold? Say you're removing a deprecated feature and 10 tests go with it. The ratchet would block that. What do you do?

[KARTHIK]: Just... edit the config file? Change 490 to 480?

[FACILITATOR]: Who knows you did that? How does the team find out the bar dropped by 10?

[KARTHIK]: *pauses* ...it's in the git diff. They'd see it in the PR.

[FACILITATOR]: Would they? Or would it be one line in a 200-line PR that removes a deprecated feature? Think about it differently — if you lower the bar, where does the reason live?

[KARTHIK]: Hold on — *checks Slack again* — OK sorry. So you're saying we need a mechanism for overrides. Not just editing the number.

[FACILITATOR]: What would that look like?

[KARTHIK]: Um... an override log? Like, the config file has a section that says "on this date, Karthik lowered test_pass_count from 490 to 480 because we removed the deprecated auth module." And the check script verifies that the log entry exists if the threshold changed.

[FACILITATOR]: That's the right shape. The override log makes lowering the bar a deliberate, visible decision instead of a quiet edit. The ratchet stays honest because every exception is on the record.

[KARTHIK]: Actually wait — should the check script enforce that? Like, if someone edits the threshold without adding a log entry, the script rejects it?

[FACILITATOR]: What do you think?

[KARTHIK]: Yeah, it should. Otherwise the log is voluntary and people will skip it. The script reads the last threshold from... from git? No, from the override log. If the current threshold is lower than the last recorded one and there's no matching log entry, it fails.

[FACILITATOR]: That's a solid mechanism. Let's add it.

>> CODE OPERATION: Update `scripts/check_ratchet.py` to validate override log entries when threshold decreases. If current threshold is lower than last override-logged threshold and no matching entry exists, fail with "RATCHET OVERRIDE REQUIRED: test_pass_count threshold lowered from {old} to {new} without override entry. Add an entry to override_log with reason, author, and date."

[FACILITATOR]: Something worth noting — the override mechanism solves a problem that most teams discover the hard way. Someone silently lowers the bar, the ratchet becomes meaningless, and six months later nobody remembers why the threshold is 380 when it started at 490. The log prevents that drift.

>> SUBAGENT RESULT:
```
Updated: scripts/check_ratchet.py
- Added override validation: if threshold < previous recorded value and
  no override_log entry covers the change, script fails with:
  "RATCHET OVERRIDE REQUIRED: test_pass_count threshold lowered from
  {previous} to {current} without override entry. Add entry to
  override_log with reason, author, and date."
- Override log entries require: metric, old_value, new_value, reason,
  author, date
```

[KARTHIK]: Nice. So the ratchet file now has the thresholds and the override log. The script checks both. If the number drops, it yells. If someone lowered the bar, it checks that there's a reason on record.

Wait — I just want to make sure I'm not missing something. Can we also add... like a "code quality" check? Not just test count but whether the tests are actually good?

[FACILITATOR]: What would that measure?

[KARTHIK]: Like... check that the tests are meaningful? Make sure they're not just trivial assertions?

[FACILITATOR]: How would the script determine "meaningful" versus "trivial"?

[KARTHIK]: I don't know, maybe... check that each test has at least one real assertion? Or that they test actual behavior?

[FACILITATOR]: "Check quality" and "test actual behavior" — can you write a command that outputs a number for those?

[KARTHIK]: ...no. Not really. Not without some kind of AI reviewer.

[FACILITATOR]: That's the distinction. Test pass count works as a ratchet because you can run a command, get a number, compare it to a threshold, and the answer is unambiguous. "Are tests meaningful" is a real concern, but it's not a ratchet metric — it's an eval criterion. Different tool, different approach. The ratchet handles what you can count. Eval design handles what you need to judge.

[KARTHIK]: OK so I stick with test count for the ratchet. If I wanted to ratchet something else later — coverage, lint score — same pattern?

[FACILITATOR]: Same pattern. Measure the real value, store it, check it, fail with specifics, ratchet up automatically, log overrides. What would you add next?

[KARTHIK]: Maybe lint violations? Like, track the number of lint warnings and don't let it go up. That's a downward ratchet — the number should only go down.

[FACILITATOR]: That's a valid variant. Same mechanics, inverted direction. The script would fail if lint warnings increased instead of decreased.

[KARTHIK]: I'll add that later. My meeting's in fifteen minutes. This test count ratchet — it's ready to wire into CI?

[FACILITATOR]: It's ready. The script runs pytest, parses the output, compares against the stored threshold, and either passes, fails with a specific message, or ratchets up. Add `python scripts/check_ratchet.py` to your CI pipeline and it catches regression before it merges.

You measured the actual value and used it as the baseline — not a guess. The failure message tells someone exactly what dropped and by how much. And the override log keeps the bar honest when it legitimately needs to move. That's the whole pattern: measure, compare, fail loud, ratchet up, log exceptions.

The ratchet prevents regression on metrics you can count. But you raised a real question about test quality — "are the tests meaningful" is not something you can ratchet, because you cannot reduce it to a number. That's eval design — making your criteria specific enough that a reviewer, human or AI, can actually categorize findings. "Check quality" produces rubber stamps. "Rate each assertion as meaningful, weak, or trivial" produces findings. That distinction matters for everything you build from here.

---

=== SIMULATION NOTES ===

**Edge case E12 (Back-to-Back Long Waits):** Triggered twice:
1. First wait — pytest baseline measurement (~35s). Insight delivered: "Ratchets work because they encode a decision you already made." [define-success] tag, adapted from revisit pool since no Stage 5 insights exist.
2. Second wait — ratchet config + script creation (~45s). Insight delivered: "The failure message is the ratchet's user interface." [specificity] tag, reworded from 0.2 revisit variant for the current context.
3. Third wait — override mechanism update (~40s). Insight delivered: "The override mechanism solves a problem most teams discover the hard way." [feedback-loops] tag, original for Stage 5 context.

Consecutive insights were delivered at each wait per teacher-instructions.md Section 13 Rule 3 ("Consecutive insights are fine"). The first two waits were back-to-back (baseline measurement immediately followed by script creation), demonstrating the E12 edge case. The third wait came after conversational exchange but was another 30+ second operation requiring an insight.

**Mistake instruction ("Design evals that partially work"):** Karthik's v1 instinct was to add vague criteria alongside the measurable ones:
- Measurable: test pass count (490, specific threshold, real command)
- Vague: "check quality" and "make sure tests are meaningful" — no command, no number, no unambiguous pass/fail

The facilitator did NOT build the vague criteria. Instead, used Socratic questioning ("How would the script determine 'meaningful'? Can you write a command that outputs a number for those?") to let Karthik discover the distinction himself. The mistake appeared naturally and was addressed through the conversation rather than manufactured.

**Multitasker persona handling:**
- Response 1: Half-attention established early — vague metric guess ("three hundred something"), Slack check mid-conversation.
- Response 2: "Can we just do test count? Meeting in forty-five minutes." Wanted the fast version. Facilitator accepted the scope constraint without pushback.
- Response 3: "Can you just... set it up?" Tried to hand off design to facilitator. Facilitator redirected: "You're driving this."
- Response 4: "quality check failed" — low-effort failure message. Facilitator used contrast to upgrade it.
- Response 5: Second Slack check. Facilitator did not comment on the distraction.
- Response 6: Generated the override mechanism himself once prompted. Despite half-attention, Karthik's 6 years of experience showed in the quality of the mechanism design.
- Response 7: The "code quality" tangent was the mistake instruction manifesting naturally — Karthik wanted to add unmeasurable criteria. Facilitator handled through questioning, not lecturing.

**Eval dimensions (simulated ratings):**
- Metric selection: Strong — Karthik chose test pass count, articulated why it's harder to game than coverage or LOC, and correctly identified that coverage can be inflated with trivial tests.
- Threshold precision: Strong — After facilitation, used the actual measured value (490) rather than the initial guess of "three hundred something." Articulated the principle himself: "use the real number, not a round one."
- Failure message quality: Adequate — Initial instinct was "quality check failed" (generic). After one contrast example from facilitator, immediately articulated the four components: metric, threshold, current, gap. Did not independently design the message format — needed the contrast prompt.
- Override strategy: Strong (conditional — triggered) — Karthik raised the override question after prompting, then designed the mechanism himself: override log with reason/author/date, script-enforced validation, rejection of threshold changes without log entries. This was self-directed design, not facilitator-provided.

**Coaching delivered (post-eval synthesis):**
- Led with Strong: Measured the actual value, used it as baseline, not a guess.
- Acknowledged failure message improvement: The failure message tells someone exactly what dropped and by how much.
- Override mechanism praised for specific behavior: The log prevents drift.
- Bridge: Connected ratchet metrics (countable) to eval design (judgmental) — "Check quality produces rubber stamps."

**Code operations performed:**
- Created `C:/Users/donid/ClaudeProjects/MockTestTarget/.quality-ratchet.json` (baseline: 490 passing)
- Created `C:/Users/donid/ClaudeProjects/MockTestTarget/scripts/check_ratchet.py` (measurement, comparison, failure messages, auto-ratchet, override validation)
- Created `C:/Users/donid/ClaudeProjects/MockTestTarget/.quality-ratchet-regression-demo.json` (threshold 495 for regression demo)
- Created `C:/Users/donid/ClaudeProjects/MockTestTarget/.quality-ratchet-v1.json` (Karthik's initial vague config — not used in session, created for v1 comparison)
- Created `C:/Users/donid/ClaudeProjects/MockTestTarget/scripts/check_ratchet_v1.py` (vague version — not used in session)
- Ran `python -m pytest tests/ -q --tb=no` — 490 passed, 1 failed, 3 skipped
- Ran `python scripts/check_ratchet.py` — RATCHET OK
- Simulated regression demo — RATCHET FAILED with specific message

**Wait-time insights used:** 3
1. [define-success] — "Ratchets encode a decision you already made." (during pytest baseline measurement)
2. [specificity] — "The failure message is the ratchet's user interface." (during ratchet config/script creation)
3. [feedback-loops] — "The override mechanism solves a problem most teams discover the hard way." (during override mechanism update)

**Teaching mode fidelity:** Fully Adaptive. Facilitator stayed in consulting role throughout. Karthik drove metric selection, config design, failure message iteration, and override mechanism design. Facilitator asked questions more than made statements (Socratic ratio for Stage 5). Key Socratic moments: "What makes that a good ratchet target?", "What message?", "Can you write a command that outputs a number for those?", "What do you think?" Developer designed the override mechanism himself after one prompt. Facilitator never drove — only spotted gaps and asked questions.
