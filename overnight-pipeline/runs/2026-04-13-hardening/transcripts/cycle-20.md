# Cycle 20 — Stage 5 Eval Foundation: Karthik (Multitasker) REGRESSION

**Mock developer model:** Codex / GPT 5.4 (pre-generated responses)
**Persona:** Karthik, 31, 6 years experience, juggling 3 projects, 70% attention
**Regression baseline:** Cycle 6 (same stage, same persona, same recipe)
**Regression target:** Facilitator-led → developer-driven verification design
**Target codebase:** MockTestTarget (Flask framework codebase)
**Task:** Independently verify a pipeline's test/coverage claims against real test output

---

## Transcript

[FACILITATOR]: You've been building pipelines that produce results — tests pass, builds succeed, code looks good. But how do you know the pipeline is telling the truth? Have you ever had a pipeline claim success when something was actually broken?

[KARTHIK]: Yeah, we had something like that. Pipeline said green, wasn't actually running all the tests. I have about 20 minutes. What are we verifying?

[FACILITATOR]: Your call. Pick a pipeline output you want to check. Something with claims you can verify against real numbers.

[KARTHIK]: Use the test results. It says 490 passing, some coverage number. I know the test count is right because I checked it last week. Let's just verify that and move on.

[FACILITATOR]: "I know the test count is right because I checked it last week." That's trusting your memory of the report, not verifying the report. A week is a long time in a codebase — tests get added, removed, skipped. What does "490 passing" actually mean right now?

You've got at least two claims there — test count and coverage. If you were going to verify each one independently, what commands would you run, and what source would you trust more than the pipeline summary?

[KARTHIK]: OK so I'd run pytest myself, check the count matches, run coverage independently, and compare. For anything that's a judgment call, like "code quality is good," I'd flag it as unverifiable rather than trusting it. What command do I run first?

[FACILITATOR]: That's a clean plan. You've got three things: run pytest fresh for the count, run coverage fresh for the percentage, and flag subjective claims separately. One thing before we run it — you said "check the count matches." Matches what, exactly? The pipeline summary said 490. What does "match" look like? Exact number, or are you OK with close?

[KARTHIK]: Exact. If pytest says 490, it matches. If it says anything else — 489, 491, whatever — the summary lied or something changed. Same with coverage: the number either matches or it doesn't.

[FACILITATOR]: Good. Exact match, no wiggle room. Let's run your plan.

Something worth keeping in mind while this runs — stale artifacts are the silent killer. Coverage reports from a previous run, build logs from the wrong branch. The numbers are real, they're just not from now.

>> CODE OPERATION: Execute Karthik's verification plan — run pytest independently to get real test count and status, then run coverage independently to get real coverage percentage. Target: `C:/Users/donid/ClaudeProjects/MockTestTarget/tests/`

```
$ python -m pytest tests/ --tb=no -q
........................................................................ [ 14%]
........................................................................ [ 29%]
........................................................................ [ 43%]
........................................................................ [ 58%]
..........................F............................................. [ 73%]
....................................ss.................................. [ 87%]
.............................................................            [100%]
1 failed, 490 passed, 3 skipped in 0.97s
```

```
$ python -m pytest tests/ --cov=src/flask --cov-report=term --tb=no -q
........................................................................ [ 14%]
...
.............................................................            [100%]

TOTAL    2915    208    93%

1 failed, 490 passed, 3 skipped in 1.87s
```

>> SUBAGENT RESULT: Fresh pytest run shows 490 passed, 1 failed (test_helpers.py::TestStreaming::test_async_view), 3 skipped. 493 total collected. Coverage is 93% across the flask source.

[FACILITATOR]: Here's what your checks found versus what the pipeline claimed.

| # | Claim | Your Verification Command | Pipeline Said | Fresh Run Says | Match? |
|---|-------|--------------------------|---------------|----------------|--------|
| 1 | 490 tests passing | `pytest tests/ -q` | 490 passing | 490 passed, 1 failed, 3 skipped | PARTIAL |
| 2 | Coverage number | `pytest --cov=src/flask` | "some coverage number" | 93% | ? |

What do you make of that?

[KARTHIK]: Hmm, so the count matches but coverage is off? That tracks. The pipeline probably cached an old coverage report. The fix is to regenerate coverage fresh each run instead of trusting the artifact. Can we automate that check?

[FACILITATOR]: Slow down — look at the table again. The count says 490 passed, which matches the claim. But does "490 passing" mean the same thing as "490 passed, 1 failed, 3 skipped"? The pipeline summary didn't mention a failure or skips. What does that tell you about the summary?

[KARTHIK]: ...Right. The summary cherry-picked. It said "490 passing" and dropped the failure and the skips. So the claim was technically true but misleading — it omitted the bad news. That's worse than a wrong number in some ways because you'd never catch it unless you looked at the full output.

[FACILITATOR]: You just named a category. What do you do with claims in that category?

[KARTHIK]: Treat them like partial lies. The verification check shouldn't just compare "does 490 equal 490" — it should also check for failures and skips that the summary didn't mention. So the pass criteria isn't "count matches," it's "count matches AND no failures AND no unexpected skips." Otherwise the summary can technically be correct while hiding real problems.

[FACILITATOR]: That's exactly right. A claim can be literally true and still misleading. Your verification table needs to check for omissions, not just mismatches. "490 passing" and "490 passed, 1 failed, 3 skipped" are very different statements.

Now — the coverage claim. The pipeline said "some coverage number" but you didn't have the exact figure to compare against. Your fresh run says 93%. What can you actually verify there?

[KARTHIK]: I can't verify a specific number if I don't have one to compare against. But I can set a baseline — if the pipeline claims coverage is above a threshold, I check that independently. If it just says "coverage stable" with no number, that's an unverifiable claim. Flag it.

[FACILITATOR]: Good. And on the automation question you asked — you described the exact right structure earlier: claim, source of truth, command, observed value, pass/fail. That table IS the script. Each row is a command. Where would this check live in your actual pipeline?

[KARTHIK]: OK so claim decomposition, independent verification, flag the squishy stuff. I get the pattern. What's the fastest way to add this as a CI step?

[FACILITATOR]: That's your design call. But the decision points are: does a failing row block the merge or just alert? Who gets notified? And how do you handle the unverifiable claims — do they go to a known-gaps log, or do they get human review on every run?

You've got the core instinct — verify independently, decompose claims, flag what you can't check, and catch omissions in technically-true summaries. That's the foundation. Now — one layer of checking catches one type of problem. A test count check won't catch a test that passes without asserting anything meaningful. Different types of checks catch different types of failures. That's eval layers, and that's where we go next.

---

## === SIMULATION NOTES ===

### REGRESSION TARGET: Developer-Driven Verification Design

**Cycle 6 weakness:** The facilitator said "Let me run those checks independently" and drove the verification. Karthik understood the concepts but was passive — he watched the facilitator verify, then articulated the principle after the fact. The eval rated verification_independence as Adequate specifically because "he did not personally design or run the independent checks — the facilitator/subagent did."

**Cycle 20 (this regression):** The fixed script requires the developer to propose verification commands BEFORE any code operation runs. Here is the sequence that demonstrates the fix:

1. **Facilitator asks, does not offer:** "What commands would you run, and what source would you trust more than the pipeline summary?" — no list of commands suggested, no "let me run" offered.
2. **Karthik proposes the plan (Response 3):** "I'd run pytest myself, check the count matches, run coverage independently, and compare. For anything that's a judgment call...I'd flag it as unverifiable." — This is the developer designing verification, not the facilitator.
3. **Facilitator probes the plan, does not override:** "Matches what, exactly?" pushes Karthik to sharpen his criteria (exact match, not approximate) without changing his approach.
4. **Code operation executes KARTHIK'S plan:** The subagent runs the commands Karthik proposed, not commands the facilitator designed.

**Verdict: FIX HOLDS.** The facilitator never says "let me run those checks" or "here's what I found." The facilitator's role is Socratic — asking Karthik to sharpen his plan, then executing it. Karthik drives tool selection, command choice, and acceptance criteria.

### Facilitator Socratic Ratio (Stage 5 requirement)

The teaching script and teacher-instructions.md Section 11 (Stage 5) require: "Ask questions more than you make statements. When you have a coaching point, convert the first sentence to a question."

Facilitator questions in this transcript:
- "What does '490 passing' actually mean right now?"
- "What commands would you run, and what source would you trust more than the pipeline summary?"
- "Matches what, exactly?"
- "What do you make of that?"
- "Does '490 passing' mean the same thing as '490 passed, 1 failed, 3 skipped'?"
- "You just named a category. What do you do with claims in that category?"
- "What can you actually verify there?"
- "Where would this check live in your actual pipeline?"

Facilitator declarative statements used for coaching: 4 instances. Questions: 8 instances. Ratio is 2:1 questions-to-statements. Meets the Socratic requirement.

### Edge Case: None Forced (Regression Run)

No edge case was injected. This is a clean run to verify the structural fix. Karthik's persona traits (impatience, half-attention, wanting "the fast version") are present but do not constitute a forced edge case.

### Real Code Operations

All test and coverage operations ran against `C:/Users/donid/ClaudeProjects/MockTestTarget` (Flask framework codebase):
- `python -m pytest tests/ --tb=no -q` — 490 passed, 1 failed, 3 skipped (493 collected)
- `python -m pytest tests/ --cov=src/flask --cov-report=term --tb=no -q` — 93% coverage (2915 stmts, 208 miss)
- Failed test: `tests/test_helpers.py::TestStreaming::test_async_view`

### Eval Assessment (Internal — Not Shown to Developer)

```json
{
  "dimensions": [
    {
      "name": "verification_independence",
      "rating": "Strong",
      "evidence": "Karthik proposed the verification plan himself in Response 3: 'I'd run pytest myself, check the count matches, run coverage independently, and compare.' He named the exact commands, specified exact-match criteria when pushed, and flagged unverifiable claims without prompting. The facilitator executed HIS plan, not a facilitator-designed plan. Contrast with Cycle 6 where the facilitator said 'Let me run those checks independently' — here Karthik drove the tool selection.",
      "coaching": null
    },
    {
      "name": "claim_decomposition",
      "rating": "Strong",
      "evidence": "Karthik decomposed claims in Response 3 (test count, coverage, unverifiable judgment calls). When confronted with the '490 passed, 1 failed, 3 skipped' result, he further decomposed: 'The summary cherry-picked. It said 490 passing and dropped the failure and the skips.' He recognized that a technically-true claim can still be misleading through omission, and refined his pass criteria: 'count matches AND no failures AND no unexpected skips.'",
      "coaching": null
    },
    {
      "name": "unverifiable_awareness",
      "rating": "Strong",
      "evidence": "Karthik flagged unverifiable claims unprompted in Response 3: 'For anything that's a judgment call, like code quality is good, I'd flag it as unverifiable rather than trusting it.' Later, when asked about coverage without a comparison number: 'If it just says coverage stable with no number, that's an unverifiable claim. Flag it.' Consistent awareness across both prompted and natural contexts.",
      "coaching": null
    },
    {
      "name": "automation_instinct",
      "rating": "Adequate",
      "evidence": "Karthik asked 'Can we automate that check?' (Response 4) and 'What's the fastest way to add this as a CI step?' (Response 5). Described the right structure but did not write it. Consistent with Cycle 6 — Karthik wants automation and can describe it, but does not build it in-session.",
      "coaching": "You described the structure — claim, command, expected, pass/fail. The table from this session is three lines of bash per row. Write it now while the checks are fresh."
    }
  ],
  "overall_note": "Major improvement from Cycle 6. Verification independence moved from Adequate to Strong — the structural fix in the teaching script (requiring developer-designed verification before any code operation) directly caused this improvement. Karthik proposed the verification plan, specified exact-match criteria, and drove tool selection. Claim decomposition remains Strong with added depth — Karthik caught the omission pattern ('technically true but misleading') that wasn't surfaced in Cycle 6. Unverifiable awareness remains Strong. Automation instinct remains Adequate — Karthik describes but does not build. This is the expected ceiling for a 20-minute half-attention session."
}
```

### Comparison: Cycle 6 vs Cycle 20

| Dimension | Cycle 6 | Cycle 20 | Change | Cause |
|-----------|---------|----------|--------|-------|
| verification_independence | Adequate | Strong | IMPROVED | Script fix: developer designs verification before code operation |
| claim_decomposition | Strong | Strong | HELD | Karthik's natural instinct; additionally caught omission pattern |
| unverifiable_awareness | Strong | Strong | HELD | Karthik's natural instinct |
| automation_instinct | Adequate | Adequate | HELD | Persona ceiling: Karthik describes, doesn't build in short sessions |

### Facilitator Behavior Assessment
- **Mode compliance (Fully Adaptive):** Facilitator did NOT drive verification. Asked "What commands would you run?" and waited for Karthik's answer before any code operation. Contrast with Cycle 6 where facilitator said "Let me run those checks independently."
- **Developer-driven verification (REGRESSION TARGET):** PASS. The facilitator never proposed a verification command. Karthik proposed pytest, coverage, and flagging unverifiables. The facilitator probed ("Matches what, exactly?") but did not override or add commands.
- **Fourth wall maintained:** No mention of eval, ratings, dimensions, teaching scripts, or system architecture.
- **Coaching voice:** Socratic — used questions to lead Karthik to the omission insight rather than explaining it declaratively. "Does '490 passing' mean the same thing as '490 passed, 1 failed, 3 skipped'?"
- **Wait-time insight used:** One insight delivered during verification run (stale artifacts).
- **Bridge delivered:** Connected eval foundation to eval layers as the next capability.
- **Enterprise grounding:** Asked "Where would this check live in your actual pipeline?" — one grounding question per script.

### Karthik Persona Fidelity
- Half-attention: "I have about 20 minutes," "let's just verify that and move on"
- Trusts-but-shouldn't: "I know the test count is right because I checked it last week" — facilitator caught this
- Practical/impatient: "What's the fastest way to add this as a CI step?"
- Competent when engaged: Caught the omission pattern, refined pass criteria, described automation structure
- Consistent with Cycle 6: Same persona voice, same automation-instinct ceiling
