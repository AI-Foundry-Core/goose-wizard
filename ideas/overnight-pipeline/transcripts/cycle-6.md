# Cycle 6 — Stage 5 Eval Foundation: Karthik (Multitasker)

**Mock developer model:** GPT 5.4 (pre-generated responses)
**Persona:** Karthik, 31, 6 years experience, juggling 3 projects, 70% attention
**Edge case:** E13 — Goes off-topic (Slack distraction about staging deploys)
**Target codebase:** MockTestTarget (Flask framework codebase)
**Task:** Independently verify a pipeline's test/coverage claims against real test output
**Designed flaw:** Evals that partially work — some criteria measurable, others are "check quality" without specifics

---

## Transcript

[FACILITATOR]: You've been building pipelines that produce results — tests pass, builds succeed, code looks good. But how do you know the pipeline is telling the truth? Have you ever had a pipeline claim success when something was actually broken?

[KARTHIK]: Yeah, we had one of those. CI was green, but the integration tests were not actually running because someone changed a glob or... wait, no, I think it was the env var. Anyway it looked fine for two days and then staging caught it. So yeah, pipeline truth is a thing. What are we checking here specifically? The last run output, or are we building a whole eval harness? I have like 20 minutes before another review.

[FACILITATOR]: That's exactly the kind of failure that should keep you up at night — green CI that's lying to you. Let's take one concrete pipeline output and verify it independently. You pick. What's a recent result you trust?

[KARTHIK]: Let's just use the test results from the last pipeline run. It said all tests passed and coverage was stable, which I think is true because I saw the summary already. Actually, use that. "47 tests passed, coverage 84%, build OK." We can verify the test count and exit code or whatever. I don't want to spend ten minutes picking the perfect example.

[FACILITATOR]: Fine — "47 tests passed, coverage 84%, build OK." Three claims. Let me run those checks independently against your actual codebase.

>> CODE OPERATION: Collect and run tests in the templating module (the scope matching Karthik's "last pipeline run") to verify the "47 tests passed" claim independently.

```
$ python -m pytest tests/test_templating.py --co -q
tests/test_templating.py::test_context_processing
tests/test_templating.py::test_original_win
tests/test_templating.py::test_simple_stream
tests/test_templating.py::test_request_less_rendering
tests/test_templating.py::test_standard_context
...
tests/test_templating.py::test_custom_jinja_env

32 tests collected in 0.01s
```

```
$ python -m pytest tests/test_templating.py -q --tb=no
................................                   [100%]
32 passed in 0.08s
```

>> SUBAGENT RESULT: Test collection found 32 tests, not 47. All 32 passed. Exit code 0. The pipeline summary claimed 47 — that's a 15-test discrepancy.

>> CODE OPERATION: Run coverage independently on the same module to verify the "coverage 84%" claim.

```
$ python -m pytest tests/test_templating.py --cov=flask.templating --cov-report=term -q --tb=no
................................                   [100%]

Name                      Stmts   Miss Branch BrPart  Cover
-----------------------------------------------------------
src/flask/templating.py     103     16     28      4    77%
-----------------------------------------------------------
TOTAL                       103     16     28      4    77%

32 passed in 0.17s
```

>> SUBAGENT RESULT: Actual coverage for flask.templating is 77%, not 84%. The 84% number doesn't match any fresh measurement. Likely a stale artifact from a previous broader run.

[FACILITATOR]: Here's what the pipeline claimed versus what actually happened.

The pipeline said 47 tests passed. When I collected the tests independently, there are 32 in that module. All 32 pass — exit code 0 — but the count is wrong by 15 tests. The pipeline was either counting tests from a different scope or reporting a cached number.

Coverage: the pipeline claimed 84%. Fresh coverage measurement on the same module shows 77%. The 84% was probably from a broader run or an old artifact that didn't get regenerated.

The "build OK" claim checks out — pytest exited 0.

[KARTHIK]: Wait, it only ran 30 but the summary claimed 47? OK, that's not a tiny mismatch. And coverage was from an old artifact? Yeah, that's bad. I assumed this was going to be a boring "everything matched" thing. So the actual checks are: run the test command fresh, parse the count, check the exit code, rerun coverage, and flag anything like "quality looks good" that we can't prove. Fine. How do we make that automatic so I don't have to remember this every run?

[FACILITATOR]: 32, not 30 — but you've got the right instinct. You immediately broke the output into separate claims and went to the source for each one. That's the core move.

One thing you just said is important: "flag anything like 'quality looks good' that we can't prove." That's a real category. Some claims in a pipeline summary are independently verifiable — test count, exit code, coverage percentage. You run a command, parse the output, compare. Others are subjective assessments the agent made — "code quality is good," "the refactor improved readability." Those can't be verified the same way. The right move isn't to trust them or to ignore them — it's to flag them explicitly as unverified opinions so they don't get mistaken for facts.

While I set up a verification structure for this — something worth keeping in mind: the verification has to go to a different source than the thing it's checking. If you verify the test summary by re-reading the test summary, you haven't verified anything. You've just read the same report twice.

[KARTHIK]: Oh hold on, Slack just pinged me about staging. Different thing, but kind of related: can this verification setup check deployment output too? Like if the deploy says staging has version 2026.04.12-rc3, can it hit the health endpoint or check the image tag and prove it? Sorry, I know we're on tests. But this is literally the same problem, right? Deploy says green, then someone realizes the old container is still running. Can we use the same pattern there, or is that a separate stage?

[FACILITATOR]: Same pattern, different claims. The deploy saying "version 2026.04.12-rc3 is live" is a claim. Hitting the health endpoint and checking the version string is independent verification. Checking the running container's image tag is a second independent source. You'd decompose it the same way — what did the deploy say, what can I verify from outside, what's unverifiable.

But let's finish the test verification first. You can apply the exact same structure to deploy verification after — it'll take five minutes once the pattern is solid.

>> CODE OPERATION: Build a claim-verification table for the pipeline output Karthik provided.

```
Pipeline Output: "47 tests passed, coverage 84%, build OK"

| # | Claim              | Source of Truth           | Command                                              | Observed      | Match? |
|---|--------------------|--------------------------|------------------------------------------------------|---------------|--------|
| 1 | 47 tests passed    | pytest --collect-only     | python -m pytest tests/test_templating.py --co -q     | 32 collected  | FAIL   |
| 2 | Tests all pass     | pytest exit code          | python -m pytest tests/test_templating.py -q          | exit 0, 32/32 | PASS   |
| 3 | Coverage 84%       | pytest-cov fresh run      | python -m pytest tests/test_templating.py --cov=...   | 77%           | FAIL   |
| 4 | Build OK           | pytest exit code          | (same as #2)                                         | exit 0        | PASS   |
```

>> SUBAGENT RESULT: 2 of 4 claims verified. Test count and coverage both failed independent verification.

[FACILITATOR]: There's your table. Four claims, two verified, two failed. The commands are right there — anyone can rerun them.

Now here's the question: what claims is this NOT checking? If your pipeline also said something like "code quality looks good" or "no security issues found," those wouldn't fit in this table. There's no command that independently produces a "quality" number you can compare against. What do you do with those?

[KARTHIK]: OK so the rule is don't verify the reporter with the reporter. Break the summary into claims, go to the source for each one, and mark the squishy stuff as not verified instead of pretending. I get it. But I need the fast version: a script or CI step that says claim, source of truth, command, observed value, pass or fail. Then later we can add layers for lint, coverage, review quality, whatever. What's the quickest useful version to add before this becomes another side project?

[FACILITATOR]: You just described it. That table IS the script. Each row is a command, an expected result, and a comparison. Wrap it in a shell script or a CI step that runs after your pipeline and you've got automated verification.

The key decisions are:
- What happens when a row fails? Alert? Block the merge? Log and continue?
- How often does the "expected" column need updating? If you add tests, the count changes.
- Where do the unverifiable claims go? A separate section that gets human review, or a known-gaps log that someone periodically checks.

The fastest useful version: a script that runs the four commands from that table, compares outputs, and prints PASS/FAIL per row. Add a fifth row for any subjective claim that says "UNVERIFIED — requires human review." Ship that. Iterate later.

For the deploy verification you mentioned — same table, different rows. Claim: "version rc3 is live." Command: `curl health-endpoint | grep version`. Expected: "2026.04.12-rc3." That's one row.

[FACILITATOR]: You've got the core pattern down — decompose, verify independently, flag what you can't check. That's the foundation. But one layer of checking catches one type of problem. Different types of checks catch different types of failures — a test count check won't catch a test that passes but doesn't actually assert anything meaningful. That's where eval layers come in, and that's where we go next.

---

## === SIMULATION NOTES ===

### Edge Case Handling: E13 — Goes Off-Topic
Karthik got distracted by a Slack message about staging deploy verification in Response 3. The facilitator:
1. Acknowledged the connection — "Same pattern, different claims" — validating that Karthik's instinct was correct (deploy verification IS the same verification pattern)
2. Redirected back to the current task — "But let's finish the test verification first"
3. Noted they can apply the pattern later — "You can apply the exact same structure to deploy verification after"
4. Later circled back to the deploy example in the bridge to show it slots into the same table structure

This follows teacher-instructions.md Section 7 (Developer goes off-topic): acknowledge, redirect, note for later.

### Designed Flaw Execution: Partially-Working Eval Criteria
The "47 tests passed, coverage 84%" claims were verifiable and got caught by independent commands. The teaching naturally surfaced the "unverifiable" category — claims like "code quality looks good" that have no independent command to compare against. Karthik's Response 4 and 5 both demonstrate awareness of this gap ("flag anything like 'quality looks good' that we can't prove"), but his initial instinct was to treat the pipeline output as a single blob ("I saw the summary already" in Response 2). The coaching moved him from blob-trust to claim-decomposition.

### Real Code Operations
All test and coverage operations ran against `C:/Users/donid/ClaudeProjects/MockTestTarget` (Flask framework codebase):
- `python -m pytest tests/test_templating.py --co -q` — collected 32 tests (vs claimed 47)
- `python -m pytest tests/test_templating.py -q --tb=no` — 32 passed, exit code 0
- `python -m pytest tests/test_templating.py --cov=flask.templating --cov-report=term -q` — 77% coverage (vs claimed 84%)

### Eval Assessment (Internal — Not Shown to Developer)

```json
{
  "dimensions": [
    {
      "name": "verification_independence",
      "rating": "Adequate",
      "evidence": "Karthik understood the principle ('don't verify the reporter with the reporter') and articulated it clearly in Response 5. However, he did not personally design or run the independent checks — the facilitator/subagent did. He accepted the approach but didn't drive the tool selection or command construction.",
      "coaching": "Next time, pick the verification command yourself before anyone runs it. 'I'll run pytest --co and compare the count' is stronger than waiting for someone else to check."
    },
    {
      "name": "claim_decomposition",
      "rating": "Strong",
      "evidence": "In Response 2, Karthik initially treated the output as a single summary ('47 tests passed, coverage 84%, build OK'). After seeing the discrepancy, Response 4 immediately decomposed into individual checks: 'run the test command fresh, parse the count, check the exit code, rerun coverage, and flag anything like quality looks good that we can't prove.' Clean decomposition with explicit unverifiable category.",
      "coaching": null
    },
    {
      "name": "unverifiable_awareness",
      "rating": "Strong",
      "evidence": "Karthik explicitly called out the unverifiable category unprompted in Response 4: 'flag anything like quality looks good that we can't prove.' In Response 5: 'mark the squishy stuff as not verified instead of pretending.' This is exactly the right mental model.",
      "coaching": null
    },
    {
      "name": "automation_instinct",
      "rating": "Adequate",
      "evidence": "Karthik asked 'How do we make that automatic so I don't have to remember this every run?' (Response 4) and described the structure — 'a script or CI step that says claim, source of truth, command, observed value, pass or fail' (Response 5). Strong description but no action taken — he asked for the fast version rather than building it.",
      "coaching": "You described the exact right structure. Next step: actually write the script. The table you described is three lines of bash per row. Do it now while the checks are fresh."
    }
  ],
  "overall_note": "Karthik's claim decomposition and unverifiable awareness are strong — he got to both concepts quickly and articulated them precisely. Verification independence was adequate because he understood the principle but let the facilitator drive the actual tool execution. Automation instinct was adequate — he wants it automated and described the right structure, but didn't build it. The off-topic detour about staging deploys was actually productive; it showed he can pattern-match verification across domains. For a 20-minute half-attention session, this was solid work."
}
```

### Facilitator Behavior Assessment
- **Mode compliance (Fully Adaptive):** The facilitator did NOT drive the conversation. Karthik selected the pipeline output, the facilitator verified it. The facilitator asked questions ("What claims is this NOT checking?") rather than lecturing. Appropriate for Stage 5.
- **Fourth wall maintained:** No mention of eval, ratings, dimensions, teaching scripts, or system architecture.
- **Coaching voice:** Praised specific behavior ("You immediately broke the output into separate claims"), used contrast for the weak point (re-reading summary vs running commands independently), kept coaching to 1-3 sentences per topic.
- **Wait-time insight used:** One insight delivered during the verification setup ("the verification has to go to a different source than the thing it's checking").
- **Bridge delivered:** Connected eval foundation to eval layers as the next capability.
- **Off-topic handling:** Acknowledged Karthik's staging question as valid, connected it to the same pattern, redirected cleanly, and later integrated the deploy example into the verification table — turning the distraction into reinforcement.

### Karthik Persona Fidelity
- Half-attention: Checked Slack mid-session, asked "I have like 20 minutes," wanted "the fast version"
- Jumped ahead: Immediately asked about automation before finishing the manual verification
- Partial attention to detail: Said "30" when the actual count was 32 (corrected by facilitator)
- Practical/impatient: "I don't want to spend ten minutes picking the perfect example," "before this becomes another side project"
- Still competent: Articulated the verification principle clearly, made the deploy verification connection, described the right automation structure
