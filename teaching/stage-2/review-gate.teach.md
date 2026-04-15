# Recipe 2.2: Review Gate — "Prove It Works, Don't Just Look at It"

Covers concept 2.2 (review-gate). Teaches execution-backed review gates.
Mode: Adaptive + Checkpoints.

---

## Quality Dimensions

### Concept 2.3 — Prove It Works, Don't Just Look at It

| Quality Dimension | Strong | Adequate | Weak |
|-------------------|--------|----------|------|
| **Execution over inspection** | Developer configured the gate to run tests and check exit codes/pass counts — not just check that files exist. *"Right — your gate ran the tests and checked the results. Checking that a test file exists tells you nothing. Checking that 47 tests pass and 0 fail tells you everything."* | Developer set up a gate but relied partly on file existence or code inspection rather than execution results. *"Your gate checked some things by running them, but also relied on 'does the file exist.' Existence checks are worthless — an empty test file exists too. Every check should be: run it, read the output, decide."* | Developer's gate only checked that files exist or looked at code without executing anything. *"Your gate looked at the code and said it looks fine. But did it run? A test file that exists but fails is worse than no test file — it gives false confidence. Always run it. Check the exit code. Read the output."* |
| **Evidence-backed verdict** | Developer required or asked for concrete execution output — test counts, exit codes, linter results — before accepting the gate's verdict. Distinguished between execution-backed evidence (exit code 0, 47/47 tests pass, 0 linter errors) and prose-based opinions (AI says "the code looks correct," "this seems fine," "no issues found"). Treated only execution output as real evidence. *"Good — you wanted the numbers. '47 pass, 0 fail, exit 0' is evidence. 'The code looks correct' is an opinion. You required the evidence before accepting the verdict — that's the discipline that makes gates real."* | Developer accepted the gate's verdict but didn't distinguish between execution evidence and AI prose. May have seen test counts alongside "looks good" language and treated both as equally valid. *"The gate said PASS and gave you some numbers — but it also said 'the code looks well-structured.' One of those is evidence, the other is opinion. Test counts and exit codes are evidence. 'Looks good' is the AI restating its own confidence. Next time, separate the two: what did it run, and what did it just say?"* | Developer accepted the gate's result based on the AI's tone or summary language — "looks good," "no issues found," "everything checks out" — without requiring any execution output. Treated the AI's confidence as the verdict. *"The gate said 'everything looks good' and you accepted it. But 'looks good' isn't a verdict — it's an opinion. A gate needs evidence: how many tests ran? What was the exit code? Did the linter pass? Without execution output, you're trusting tone, not facts. That's a review, not a gate."* |
| **Gate vs. review distinction** (conditional) | Condition: Only rate this if the developer explicitly discussed or asked about the difference between a review and a gate. If condition not met: return rating=null, evidence="Not triggered", coaching=null. Strong: Developer articulated that a gate blocks progression while a review is advisory — the gate's PASS/FAIL is a decision, not a suggestion. *"That's the key distinction — a review gives opinions, a gate makes decisions. Your gate said FAIL and that means the change doesn't go through. No negotiation."* | Adequate: Developer understood there's a difference but conflated them — e.g., treated the gate's findings as suggestions to consider. *"A review suggests things to fix. A gate blocks the change until they're fixed. Your gate found issues — that's not advice, that's a FAIL. The change doesn't proceed until those are resolved."* | Weak: Developer treated the gate as just another review — optional, advisory, something to consider. *"You read the gate's findings like suggestions. But a gate isn't advice — it's a checkpoint. FAIL means stop. Fix the issues. Run the gate again. This is the difference between catching bugs and shipping them."* |

---

## Setup

Read .goose/team_context.md for project context.
Read ~/.rilgoose/progression.json — check concept 2.2.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.
Verify concepts 2.1 and 2.2 are complete. If not, flag it — 2.3 builds on the two-agent pattern.

## Framing

"You've seen how a separate tester catches what a builder misses. But right now, you're the one deciding what to do with the tester's findings. What if you turned that into a gate — something that actually blocks bad code, with evidence you can verify?"

"Think about the build-then-test workflow you just ran. The tester found issues, and you looked at them. Now imagine that tester is a gate: it runs the tests, checks the results, and returns PASS or FAIL. Not 'here are some things to consider' — a hard decision backed by evidence."

"Let's set one up. We need a change to review. You can either:"
- "Use a change you need to make right now"
- "Use the build-then-test recipe to make a change, then run the review gate on it"

If developer has no current change:
  "Let me set something up."
  Delegate to code-work subagent:
    sub-recipe: "build-then-test"
    parameters:
      task_description: "Find a TODO or small improvement in the codebase and implement it"
  Use the output as the change to gate.

## The Task

Developer has a change to review (built themselves, built via recipe, or pre-existing).

Delegate to code-work subagent:
  sub-recipe: "review-gate"
  parameters:
    change_description: {what was changed}
    changed_files: {files modified}
    gate_criteria: {developer's criteria if provided}

[Subagent runs the review gate, returns PASS/FAIL with evidence]

Facilitator presents the results naturally:

If gate returned FAIL:
"The gate returned FAIL. Here's what it found: [specific issues with evidence]. It ran the tests — [X pass, Y fail, exit code Z]. [Specific blocking issue]. This isn't advice to consider — it's a hard stop."

Probe: "Look at the evidence. The gate said [specific claim]. Is that backed by execution output — test results, exit codes — or is it just an opinion? That's the distinction that matters."

If gate returned PASS:
"Gate says PASS. [X tests pass, 0 fail, exit 0. Linter clean.] But look at the evidence — did you check whether it actually ran everything, or are you trusting the summary?"

Key moment — watch for execution vs. inspection:
"Open the gate's results. Does it show you actual test output — pass counts, exit codes, linter results? Or does it say 'the code looks correct'? One is evidence. The other is opinion."

**Sharpen the evidence vs. opinion distinction.** If the gate's output mixes execution results with prose opinions, call it out explicitly:

"Look at this line: '[X tests pass, 0 fail].' That's evidence — the gate ran something and measured the result. Now look at this line: '[the code is well-structured and follows best practices].' That's opinion — the AI read the code and stated its confidence. A gate should decide on evidence. If the only thing backing the PASS is prose, the gate is just a review with a fancier name."

If developer is satisfied with the gate checking file existence or code inspection:
  "Pause — the gate checked that the test file exists. But does it pass?
  An empty test file exists too. Let me show you the difference."
  Delegate to code-work subagent:
    "Run the actual tests in {changed files}. Show the full output:
    pass/fail counts, exit code, any errors."
  Present the difference: "See? Existence check says 'yes.' Execution check says '[actual result].' Only one of those protects you."

## Eval

Delegate to eval subagent (async: true):
  [See eval prompt below]

## Coaching

Read eval results. For each dimension:
- Strong: Acknowledge specifically using the coaching language from the quality dimension table.
- Adequate: Light suggestion using the coaching language from the quality dimension table.
- Weak: Targeted coaching with contrast using the coaching language from the quality dimension table.

If ALL dimensions are Strong:
"That's a solid review gate — execution-backed, evidence-required, hard pass/fail. This is what separates 'AI said it looks fine' from 'AI proved it works.' From here, every workflow you build should have a gate like this."

## Bridge

"You've got agents that build, test, and gate — all independently. But they're all reacting to what you asked for. What if you defined success before anyone started building? That way the builder has a target, the tester has a checklist, and the gate has criteria that existed before the code did."

## State Update

Write to ~/.rilgoose/progression.json:
  concept 2.2 dimensions with eval ratings + timestamp.

---

## Eval Subagent Prompt

```
You are evaluating how well a developer set up and used an independent review gate. This covers concept 2.2 (Prove it works, don't just look at it).

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript (quote or paraphrase what the developer said/did)
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. EXECUTION OVER INSPECTION
   Strong: Developer configured or expected the gate to run tests, check exit codes, execute linting — verification through running things, not just reading files. Developer understood that existence checks ("does the file exist") are meaningless compared to execution checks ("does it pass").
   Adequate: Developer set up a gate but relied partly on inspection or file existence rather than pure execution results. May have mixed execution and existence checks without distinguishing their value.
   Weak: Developer's gate approach relied on looking at code, checking that files exist, or reading the implementation — no meaningful execution-based verification.

2. EVIDENCE-BACKED VERDICT
   Strong: Developer required or asked for concrete execution output — specific test counts, exit codes, linter line counts — before accepting the gate's PASS or FAIL verdict. Critically, the developer distinguished between execution-backed evidence (test counts, exit codes, measurable output) and prose-based opinions (AI saying "looks good," "no issues found," "well-structured code"). Only execution output was treated as real evidence.
   Adequate: Developer accepted the gate's verdict (PASS or FAIL) and may have seen execution output, but did not distinguish between execution evidence and AI prose. Treated "47 tests pass" and "the code looks correct" as equally valid backing for the verdict.
   Weak: Developer accepted the gate's result based on the AI's summary language or confident tone — "looks good," "everything checks out" — without requiring any execution output. Treated the AI's confidence as the verdict itself.

3. GATE VS. REVIEW DISTINCTION (conditional)
   Condition: Only rate this if the developer explicitly discussed, asked about, or demonstrated understanding of the difference between a review (advisory) and a gate (blocking decision).
   If condition not met: return {"name": "gate_vs_review", "rating": null, "evidence": "Not triggered — developer did not discuss the distinction", "coaching": null}
   Strong: Developer articulated that a gate blocks progression while a review is advisory. Understood that FAIL means the change does not proceed.
   Adequate: Developer understood there is a difference but treated the gate's findings as suggestions rather than hard decisions.
   Weak: Developer treated the gate as another review — optional, advisory, something to weigh rather than follow.

Return as JSON:
{
  "dimensions": [
    {"name": "execution_over_inspection", "concept": "2.3", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "evidence_backed_verdict", "concept": "2.3", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "gate_vs_review", "concept": "2.3", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "Any cross-cutting observation about how the developer is internalizing execution-based verification"
}
```
