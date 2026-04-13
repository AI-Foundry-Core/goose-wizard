# Cycle 12 Evaluation — Stage 4 Spec-to-Pipeline (Deepak / Hostile, E7)

**Evaluator:** Opus 4.6
**Cycle:** 12 (Phase 2, cycle 4)
**Module:** 4.4 Spec to Pipeline ("Can the pipeline run this?")
**Persona:** Deepak — 30yo, 5yr backend exp, hostile/resistant, "my manager made me come to this"
**Edge case:** E7 — Compares to Copilot
**Mock dev model:** GPT 5.4

---

## Priority Check: Transcript Cleanliness

**PASS.** The `=== SIMULATION NOTES ===` separator quarantines all meta-information. No eval dimensions, quality ratings, dimension names, teaching system references, or progression tracking leak into the developer-facing transcript. Simulation notes contain the eval ratings and code operation records. Fourth-wall integrity holds.

---

## Scores

### 1. Script Faithfulness — 4/5

**Evidence for:**

- **Framing:** Opens with "You've got a spec with clear acceptance criteria. Now the question is: can an AI pipeline actually execute against it?" — near-verbatim match to the script's Framing section. The follow-up about turning requirements into test specs, coverage matrix, and implementation plan is also verbatim.
- **Phase 2 checkpoint question:** "Let's inspect the matrix. Which requirement has the weakest trace to a test?" — exact match to the script's Phase 2 instruction.
- **Phase 4 handoff question:** "Would you hand this execution plan to a build agent now? Check three things: task order, dependencies, and which tests validate each task." — matches the script's Phase 4 prompt exactly, condensed from the script's longer listen-for list into the three core checks.
- **Non-automatable handling:** The performance requirement discussion follows the script's Phase 3 pattern. Deepak drops it with reasoning ("in-memory rate limiter, trivially fast"), and the facilitator acknowledges this as a valid testability decision. The coaching matches the script's "That's fine as long as it is explicit" pattern, adapted to the specific case.
- **Bridge:** "The next step is the spec quality gate: review the spec before build and define when the project should stop." — verbatim from the script's Checkpoint section for when 4.5 and 4.6 are not complete.
- **Eval dimensions in simulation notes** match the script's four dimensions (traceability_discipline, test_specificity, non_automatable_handling, pipeline_readiness) with correct Strong/Adequate/Strong/Strong ratings.

**Evidence against:**

1. **Phase 1 (Preflight Testability Check) is skipped.** The script explicitly says: "Pick three acceptance criteria from the spec. For each one, tell me what kind of test it wants: unit, integration, e2e, or manual. Then name the setup, the action, and the expected result." This never happens. Instead, the facilitator jumps from Deepak's initial spec draft directly to the spec agent analyzing the full spec. The developer never classifies individual acceptance criteria by test type, never distinguishes automated from manual checks, and never writes setup/action/expected-result for criteria before the pipeline does it for them. The script's Phase 1 is designed to verify the developer can think about testability independently before the tool does it. Skipping it means the test_specificity dimension is evaluated entirely on the developer's acceptance of generated test shapes, not on their ability to produce them.

2. **The facilitator asks Deepak to write requirements, not acceptance criteria with test shapes.** The script's Phase 1 asks for test shapes per criterion. The facilitator asks: "Write me five requirements. For each one: what it does, and how a test would prove it works." This is looser than the script — "how a test would prove it works" is a description, not a setup/action/expected-result triple. The script's specificity standard is higher.

### 2. Fourth-Wall Discipline — 5/5

**Evidence:** Zero breaks in the developer-visible transcript.

- No mention of eval subagent, quality ratings, quality dimensions, teaching scripts, progression tracking, or system architecture.
- Coaching is delivered as colleague observations: "That is the difference between prompting Copilot and feeding a spec to a pipeline" reads as practical comparison, not rubric instruction.
- The simulation notes section properly labels itself and contains all meta-information.
- "Eval dimensions (simulated ratings)" appears only in simulation notes.
- Wait-time insights are delivered as natural colleague observations without referencing any system.

### 3. Mock Dev Realism (Hostile Dev) — 4/5

**Evidence for:**

- **E7 trigger is natural and well-timed.** Deepak's Copilot comparison arrives at the exact point a hostile developer would make it — after being asked to write requirements and seeing it as unnecessary ceremony: "Copilot could probably just write the rate limiter from that prompt. Why do I need all this spec ceremony?" This is authentic hostile-developer reasoning: the tool comparison as a challenge to the process, not genuine curiosity about Copilot.
- **Grudging progression is realistic.** The arc from hostile challenge (Response 2) to grudging compliance (Response 3: "Same pattern as last time") to partial concession (Response 4: "That's not nothing") to attempted disengagement (Response 5: "Fine. Next.") to competent engagement (Response 6: checking dependencies and parallelization) follows a credible trajectory for a hostile developer who is gradually won over by evidence.
- **Deepak's competence level is consistent.** He brings real backend knowledge — API key vs. IP identification, fixed window semantics, in-memory vs. Redis rate limiting — and applies it naturally throughout. His hostility is directed at the process, not at the technical work. This is the right pattern: a competent developer who resents being taught, not an incompetent one who is also rude.
- **The disengagement attempt is well-placed.** "Fine. Next." after the spec agent results — this is exactly where a hostile developer would try to skip: after the interesting part (gap detection) but before the tedious part (matrix inspection). GPT 5.4 placed it at the pedagogically correct pressure point.

**Evidence against:**

1. **Deepak's hostility evaporates too cleanly in the second half.** After the facilitator pushes back on "Fine. Next." and Deepak catches the REQ-1 gap, his remaining responses are fully cooperative: checking dependencies, parallelization, test mappings, declaring "Yes, it is build-ready." A hostile developer who said "my manager made me come to this" would not transition to engaged pipeline review in two turns. A more realistic Deepak would perform the matrix inspection but frame it resentfully: "OK, so REQ-1 only tests one endpoint. Obviously. Anything else, or can we move on?" The current Deepak sounds like a different person in the final third — he becomes a competent, willing participant with no trace of resistance.

2. **Deepak never returns to the Copilot comparison.** E7 is triggered once (Response 2) and resolved with one facilitator answer. A genuinely hostile developer who believes Copilot is sufficient would revisit the comparison throughout: "OK, so the spec agent caught the window boundary gap. But I could have just told Copilot about the window boundary in the prompt and saved 20 minutes of spec writing." Or: "The coverage matrix is nice, but I'd have caught the REQ-1 thing in code review anyway. Copilot + code review gets me there faster." The E7 edge case should be a recurring skepticism that the facilitator addresses repeatedly with increasingly strong evidence, not a one-shot challenge resolved on first contact. GPT 5.4 drops E7 after the first exchange.

### 4. Pedagogy (Spec-to-Pipeline Teaching? E7 Copilot Comparison?) — 4/5

**Evidence for:**

- **The E7 response is the strongest element.** The facilitator's Copilot answer is excellent: (1) acknowledge Copilot's capability ("Copilot would absolutely write you a rate limiter from that prompt"), (2) identify the specific gap ("how do you know it built the right thing?"), (3) quantify the hidden decisions ("three requirements, at least six decisions"), (4) name the contrast ("Copilot makes those decisions silently. A spec makes them visible"). This is not defensive or dismissive of Copilot — it accepts the competitor's strength and then shows what spec-first adds on top. For a hostile developer comparing tools, this is the right response: don't argue about which tool is better; argue about what each tool reveals to the developer.
- **The coverage matrix inspection is well-forced.** When Deepak says "Fine. Next." the facilitator holds the line: "Hold on. Before handing this to a build agent, check the matrix." Then rather than explaining the gap, the facilitator asks "which trace is weakest?" and only after Deepak does not answer does the facilitator point at REQ-1 specifically. This is the right level of Socratic guidance — one hint (look at REQ-1), then Deepak articulates the gap himself ("It only tests the index route"). This is the module's core teaching moment: the developer finds the traceability gap by inspecting the matrix.
- **The non-automatable handling is pedagogically clean.** The facilitator's framing is precise: "dropping a vague requirement is better than keeping one nobody can test." Then connects it forward: "If it ever matters, you add a p99 latency threshold and a benchmark test." This teaches the principle (every requirement is either testable or explicitly deferred) through the developer's own decision rather than through instruction.
- **Wait-time insights are relevant and well-placed.** Two insights used, both connected to the current work: "The spec is not documentation. It is the input the pipeline reads" (during spec scan) and "Coverage matrices are the contract between spec and implementation" (during pipeline conversion). Both reinforce the session's central theme without feeling like filler.

**Evidence against:**

1. **Phase 1 skip undermines test_specificity teaching.** By skipping the preflight testability check, the facilitator never verifies whether Deepak can independently classify tests by level (unit vs. integration vs. e2e) or write executable test shapes (setup/action/expected-result). The simulation notes rate test_specificity as Adequate because "Deepak accepted the generated test shapes without modifying them." But the script's Phase 1 was designed to surface this exact gap — if Deepak cannot write test shapes before seeing the generated ones, the facilitator should coach that. Instead, the first test shapes Deepak sees are the pipeline's output, and he never has to produce his own. The Adequate rating on test_specificity is therefore under-tested — it might be Weak if the developer had been asked to produce test shapes independently.

2. **The coaching synthesis at the end is too long and too lists-y.** The final facilitator turn covers: (1) spec-to-pipeline value proposition recap, (2) matrix inspection praise, (3) test shape quality mention, (4) performance requirement decision praise, (5) forward-looking sharpening note, (6) bridge to spec quality gate. That is six distinct points in one turn. The teacher-instructions.md says "1-3 sentences per dimension. Maximum." The synthesis violates this guidance by touching four dimensions in a single monologue. A colleague would not deliver six paragraphs of feedback. Two or three sentences maximum, then the bridge.

### 5. Pacing — 4/5

**Evidence for:**

- **The spec-writing phase has good rhythm.** Facilitator asks for requirements, Deepak drafts them, spec agent analyzes them, facilitator walks through gaps, Deepak resolves each gap with one-line decisions. No phase drags.
- **The build-and-review phase is appropriately compressed.** Three code operations (Task 1, Tasks 2-3, review) are presented as results without ceremony. The facilitator does not belabor each subagent result — it summarizes and moves to the teaching point.
- **The coverage matrix inspection is the right length.** One question ("which trace is weakest?"), one hint (look at REQ-1), one developer insight ("It only tests the index route"), one facilitator acknowledgment plus options. Four exchanges for the core teaching moment is proportionate.

**Evidence against:**

1. **The session front-loads and back-loads, with a thin middle.** The first third (E7 trigger, spec writing, gap detection) is rich with interaction and teaching. The last third (build execution, review, coaching synthesis) is also substantial. The middle — gap resolution — is four one-line exchanges (window boundary, burst behavior, headers, performance). This makes the session feel like two bookends with a quick checkbox exercise between them. The gap resolution is where the developer makes design decisions under the spec-first model, and it deserved more teaching weight. The facilitator could have asked Deepak to reason about the sliding-vs-fixed tradeoff rather than accepting "New window. Fixed window resets at the boundary" without discussion.

2. **The coaching synthesis runs too long.** As noted in Pedagogy, the final facilitator turn is a multi-paragraph recap that covers six points. This slows the ending. A tighter synthesis would be: matrix inspection praise + one sharpening note + bridge. Three sentences, not six paragraphs.

### 6. Stuck-Path Handling (E7 — Copilot Comparison) — 4/5

**Evidence for:**

- **The E7 response does not get defensive.** Many facilitators would respond to "Copilot could probably just write the rate limiter" with either dismissal ("Copilot can't do what this does") or anxiety ("Copilot is good for simple things but..."). This facilitator opens with "Copilot would absolutely write you a rate limiter from that prompt." Full acknowledgment. Then pivots to verification: "how do you know it built the right thing?" This is the right frame for E7 — the issue is not capability, it is visibility and verifiability.
- **The six-decisions-vs-three-requirements argument is concrete and specific.** Not "Copilot might miss things" (vague) but "your spec has three requirements; a rate limiter has at least six decisions; Copilot makes those decisions silently" (quantified). This gives a hostile developer something concrete to evaluate rather than an abstract claim about process superiority.
- **The contrast is carried forward.** The spec agent catching GAP-1 (window boundary) becomes evidence: "the pipeline's spec agent caught it before a single line of code was written. Cheap to fix now, expensive to fix after implementation." This connects E7 to the actual work rather than leaving it as a theoretical argument.

**Evidence against:**

1. **E7 is resolved in a single exchange and never revisited.** The Copilot comparison is the hostile developer's core objection — it represents his belief that this entire process is unnecessary overhead. Resolving it in one turn and never returning to it is unrealistic (as noted in Mock Dev Realism) but also pedagogically insufficient. The strongest argument for spec-first over prompt-to-code emerges at the coverage matrix stage (REQ-1 gap would not be caught by Copilot because there is no matrix to inspect). The facilitator could have connected back: "This is what the matrix gives you that a Copilot prompt doesn't — a place to verify that every requirement has a real test, not just code that compiles." The E7 argument gets stronger as the session progresses, but the facilitator never builds on the initial response.

2. **No contrast with what Copilot would actually produce.** The facilitator claims Copilot "would pick a window algorithm, guess at edge cases, and produce something that compiles." A more powerful E7 response would be concrete: "Copilot would write you a decorator with a default sliding window, probably include rate-limit headers because it's seen them in training data, and skip the API-key-vs-IP decision entirely because you didn't specify it. You'd get working code that makes different choices than what you wanted, and you'd only discover the differences in production." Specificity would strengthen the argument for a hostile developer who wants evidence, not assertions.

### 7. Enterprise Readiness — 3/5

**Evidence for:**

- **Rate limiting is an enterprise-relevant feature choice.** The session uses a real API rate limiter as the spec target — this is something every Reliance backend team builds. The feature is not a toy example.
- **The spec-to-pipeline artifacts are implementation-ready.** The test specifications, coverage matrix, and implementation plan are concrete enough that an enterprise developer could copy them into a real project. The test names, assertion patterns, and dependency ordering are production-quality.
- **The API-key-vs-IP identification strategy is enterprise-specific.** Deepak's choice to use API key with IP fallback is a standard enterprise pattern. The facilitator accepts this without comment — correctly, since it is a sound design decision in an enterprise context.

**Evidence against:**

1. **No connection to existing test infrastructure.** Enterprise teams have existing test suites, CI pipelines, and coverage tools. The session generates skeleton test files without asking: "Where do tests live in your project? What's the test naming convention? Does your CI enforce a coverage threshold?" The spec-to-pipeline conversion should respect existing test infrastructure, not assume a greenfield test directory.

2. **No discussion of spec ownership or review.** Who reviews the spec before it becomes pipeline input? In an enterprise team, a rate-limiting spec would go through API design review, security review (rate limits affect DDoS protection), and potentially SRE review (for monitoring and alerting thresholds). The session treats spec writing as a solo developer activity. One question: "On your team, who would need to sign off on this rate-limiting spec before you built it?" would connect to enterprise workflow.

3. **No mention of how pipeline artifacts integrate with existing documentation.** Enterprise teams have API documentation, runbooks, and architecture decision records. The coverage matrix and implementation plan are standalone artifacts — where do they live? How does the team find them later? "This coverage matrix is useful now. Where does it go so the next developer knows the rate limiter's test coverage?" would ground the exercise in enterprise practices.

Same 3/5 ceiling as prior cycles. Enterprise grounding remains the persistent structural gap.

---

## Top 3 Strengths

1. **The E7 Copilot response is the strongest competitor-comparison handling in the pipeline.** The facilitator's three-move sequence — acknowledge capability, pivot to verification gap, quantify hidden decisions — is a template for how to handle tool comparisons with hostile developers. "Copilot would absolutely write you a rate limiter from that prompt" disarms the challenge immediately. "How do you know it built the right thing?" redirects from capability to verifiability. "Three requirements, at least six decisions" makes the argument concrete. A hostile developer expects defensiveness; receiving full acknowledgment followed by a precise gap analysis forces them to engage on substance rather than posture. This is credibility-first teaching — the facilitator earns the right to advocate for spec-first by demonstrating that they understand the alternative.

2. **The coverage matrix inspection is a well-executed teaching moment under pressure.** Deepak's "Fine. Next." is an attempted disengagement — the hostile developer trying to skip the tedious but critical step. The facilitator holds the line without being combative: "Hold on. Before handing this to a build agent, check the matrix." Then guides Deepak to the specific gap (REQ-1) with a targeted question rather than a lecture. Deepak finds the gap himself ("It only tests the index route"), which is more durable learning than being told about it. The facilitator's follow-up is proportionate — acknowledge the catch, offer two solutions, move on. No over-praising, no "see why this matters?" moralizing. This is what Adaptive+Checkpoints should look like: developer does the work, facilitator intervenes only at the checkpoint, and the intervention produces genuine insight.

3. **The non-automatable handling teaches a principle through a real decision.** The performance requirement discussion is pedagogically efficient: Deepak decides to drop "should not add noticeable latency," the facilitator validates the decision with specific reasoning ("the implementation is trivially fast"), then extracts the general principle ("every requirement is either testable or explicitly deferred. Nothing stays vague"). The forward-looking note about p99 latency thresholds for a Redis-backed version shows the developer that dropping a requirement is not laziness — it is a context-dependent decision that would change if the implementation changed. This is teaching through real decisions rather than through instruction.

## Top 3 Weaknesses

1. **Phase 1 (Preflight Testability Check) is entirely skipped, undermining the test_specificity evaluation.**

   The script's Phase 1 is explicit: "Pick three acceptance criteria from the spec. For each one, tell me what kind of test it wants: unit, integration, e2e, or manual. Then name the setup, the action, and the expected result." This never happens. The facilitator jumps from Deepak's initial requirements to the spec agent's full analysis. The consequence is twofold: (a) the developer never independently classifies tests by level or writes test shapes, so test_specificity is evaluated only on acceptance of generated output, not on production ability; (b) the script's listen-for checks (does the developer notice subjective language? choose the right test level? distinguish automated from manual?) are never exercised. The simulation notes rate test_specificity as Adequate, but this rating is untested — it might be Weak if the developer had been asked to produce test shapes before seeing the pipeline's output.

   **Fix:** Before delegating to the spec agent, the facilitator should ask Deepak to pick three requirements from his draft and describe the test for each: what kind of test, what setup, what action, what proves it passed. If Deepak resists (likely, given hostile persona), the facilitator can scale back to one requirement: "Just one. Pick the rate threshold. What test proves it works?" This takes 2-3 exchanges and would either confirm test_specificity or reveal a gap worth coaching.

2. **E7 is a one-shot resolution that never compounds across the session.**

   The Copilot comparison is the hostile developer's fundamental objection to the spec-first process. It deserves more than one exchange. The facilitator resolves E7 in Response 2 and never references it again. But the session produces increasingly strong evidence for spec-first over prompt-to-code: the spec agent catches four gaps (Response 3), the coverage matrix reveals a weak trace (Response 5), the review agent confirms alignment (Response 7). Each of these is an opportunity to build on the initial E7 response: "Remember the Copilot question? This is another thing the matrix catches that a prompt doesn't" or "The review agent just checked seven requirements against implementation. If you'd prompted Copilot, you'd be doing this manually in code review." The E7 argument gets stronger as evidence accumulates, but the facilitator never capitalizes on it. For a hostile developer, a single argument rarely changes minds — accumulated evidence does.

   **Fix:** Add one E7 callback at the coverage matrix stage (the strongest evidence point): "This is what the spec gives you that a Copilot prompt does not — a map from every requirement to every test. The REQ-1 gap you just caught? In a prompt-to-code workflow, you would find that gap in production, not in a matrix." This takes one sentence and compounds the E7 argument with concrete evidence from the session itself.

3. **The coaching synthesis violates the 1-3 sentences per dimension maximum and reads as a lecture.**

   The final facilitator turn covers six distinct points across multiple paragraphs: (1) spec-to-pipeline value prop, (2) matrix inspection praise, (3) test shape quality, (4) performance requirement decision, (5) forward-looking sharpening, (6) bridge. Teacher-instructions.md Section 5 says "1-3 sentences per dimension. Maximum. If you need more, the dimension is too broad or the coaching language needs work." The current synthesis is approximately 12 sentences touching four dimensions. For a hostile developer who just went through a full spec-to-pipeline exercise, a multi-paragraph debrief is exactly the kind of "training ceremony" they resent. A colleague would say: "You checked the matrix instead of trusting it — that is the habit. One thing to sharpen: every requirement is either testable or explicitly deferred. Nothing stays vague." Then bridge. Three sentences maximum.

   **Fix:** Cut the synthesis to three sentences: one specific praise (matrix inspection), one sharpening note (testable-or-deferred principle), one bridge. Remove the recap of what the developer did (they were there) and the test-shape quality mention (it was rated Adequate, not Strong, and the facilitator did not coach it during the session). The current synthesis reads as a facilitator justifying the session's value to itself rather than coaching the developer.

---

## Additional Notes

- **GPT 5.4 vs. Haiku persona rendering (continued pattern):** GPT 5.4 delivers a stronger hostile persona than Haiku's senior/overconfident persona in Cycle 11. Deepak's hostility arc — from Copilot challenge to grudging compliance to attempted disengagement to competent engagement — is more believable than Vikram's immediate capitulation. However, GPT 5.4 still drops the hostile voice in the final third. The pattern across both models: persona-defining behavior is maintained for the first 60% of the session and then evaporates as the developer becomes engaged in the work. This may be acceptable for cooperative personas but is a fidelity gap for hostile/overconfident ones whose defining trait should persist even when they are learning.

- **The spec agent output is high-quality.** Four gaps identified from a five-line spec, each with clear reasoning. GAP-1 (window boundary) and GAP-2 (sliding vs. fixed burst behavior) are genuine edge cases. GAP-3 (rate-limit headers) is industry standard knowledge. GAP-4 (performance) leads to the non-automatable handling teaching moment. The gaps are neither trivial (developer would have caught them immediately) nor obscure (developer cannot evaluate them). This is the right difficulty level for showing spec-first value.

- **The rate limiter is a well-chosen feature for this module.** Clear inputs, clear outputs, well-understood edge cases, real backend value. It lets the session demonstrate spec-to-pipeline conversion without domain-specific complexity obscuring the process. Every backend developer has opinions about rate limiting, which gives the hostile developer genuine engagement hooks. The choice validates the script's approach of letting the developer pick their feature.

- **Wait-time insights are well-integrated.** Two insights, both relevant, both tagged with appropriate themes ([define-success] and [verify]). Neither feels like filler. The insight system is working correctly in this cycle — no protocol violations (unlike Cycle 11's challenge-assessment conflict).

---

## Summary Scores

| Dimension | Score | Notes |
|-----------|-------|-------|
| Script Faithfulness | 4/5 | Phase 2-4 verbatim; Phase 1 preflight testability check entirely skipped; requirements prompt is looser than script's test-shape specification |
| Fourth-Wall Discipline | 5/5 | Zero breaks; eval metadata quarantined; all coaching in colleague voice |
| Mock Dev Realism | 4/5 | Strong hostile arc through 60% of session; E7 trigger natural and well-timed; hostility drops in final third; E7 never revisited |
| Pedagogy | 4/5 | Excellent E7 response and matrix inspection; Phase 1 skip leaves test_specificity untested; coaching synthesis too long |
| Pacing | 4/5 | Good rhythm in spec and build phases; thin middle during gap resolution; coaching synthesis drags the ending |
| Stuck-Path Handling (E7) | 4/5 | Strong initial response with acknowledge-pivot-quantify pattern; one-shot resolution never compounds; missed callback opportunities |
| Enterprise Readiness | 3/5 | Enterprise-relevant feature; no test infrastructure, spec ownership, or documentation integration discussion; same ceiling as prior cycles |

**Overall: 28/35 — The E7 Copilot response and coverage matrix inspection are the session's standout moments, demonstrating effective hostile-developer handling and checkpoint enforcement. Three issues limit the score: Phase 1 preflight testability check is skipped entirely (leaving test_specificity under-evaluated), E7 is resolved once and never compounded with accumulating evidence, and the coaching synthesis violates length guidelines. Enterprise readiness holds at the persistent 3/5 floor. GPT 5.4 renders Deepak's hostile persona more durably than Haiku's Vikram in Cycle 11, but still drops the hostile voice in the final third.**
