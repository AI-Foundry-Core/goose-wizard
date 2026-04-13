# Cycle 12 — Stage 4 Spec-to-Pipeline: Deepak (Hostile/Resistant)

**Stage:** 4 — From Idea to Buildable Spec
**Module:** 4.4 — Spec to Pipeline ("Can the pipeline run this?")
**Mode:** Adaptive + Checkpoints
**Developer Persona:** Deepak — 30, 5yr backend exp, hostile, "my manager made me come to this"
**Edge Case:** E7 — Compares to Copilot

---

[FACILITATOR]: You've got a spec with clear acceptance criteria. Now the question is: can an AI pipeline actually execute against it? We turn the requirements into test specs, a coverage matrix, and an implementation plan. What feature are we working with?

[DEEPAK]: We need rate limiting on the API. It's been on the backlog forever.

[FACILITATOR]: Rate limiting is a good one. Clear inputs, clear outputs, easy to verify. Let's start with the spec. What does the rate limiter need to do? Give me the requirements — endpoints, limits, behavior when exceeded, identification strategy.

[DEEPAK]: OK. Endpoints, rate per minute, response when exceeded. Maybe per API key instead of per IP. Is that enough? Honestly, Copilot could probably just write the rate limiter from that prompt. Why do I need all this spec ceremony?

[FACILITATOR]: Copilot would absolutely write you a rate limiter from that prompt. It would pick a window algorithm, guess at edge cases, and produce something that compiles. The question is: how do you know it built the right thing? "Endpoints, rate per minute, response when exceeded" — that's three requirements. A rate limiter has at least six decisions in it. What happens at the window boundary? Does the counter reset or slide? What if two keys share an IP? Copilot makes those decisions silently. A spec makes them visible, and a pipeline can verify each one independently.

So let's write the spec properly. You said endpoints, rate per minute, per API key with IP fallback, response when exceeded. Put numbers on it. Which endpoints, what rate, what response code and body?

>> CODE OPERATION: Read project structure at `C:/Users/donid/ClaudeProjects/MockTestTarget/examples/tutorial/flaskr/` to identify all blog API endpoints.

>> SUBAGENT RESULT: Blog endpoints found: `/` (index), `/create` (POST), `/<id>/update` (GET/POST), `/<id>/delete` (POST). Auth endpoints: `/auth/register`, `/auth/login`, `/auth/logout`. The blog endpoints are the primary API surface.

[FACILITATOR]: While the spec agent scans the codebase — one thing worth knowing about spec-to-pipeline work: the spec is not documentation. It is the input the pipeline reads to decide what to build and what to test. If a requirement is vague, the build agent guesses. If it is missing, the build agent skips it.

Your blog endpoints are: index, create, update, delete. Plus the auth routes. Now — write me five requirements. For each one: what it does, and how a test would prove it works.

[DEEPAK]: Fine. Spec agent reads the spec, build agent implements, review agent checks against spec. Same pattern as last time. Add tests for allowed requests, exceeded requests, and reset behavior. Otherwise the build agent will just guess.

>> CODE OPERATION: Spec agent analyzes Deepak's draft spec at `C:/Users/donid/ClaudeProjects/MockTestTarget/specs/rate-limiter-spec.md`. Checks each requirement for testability. Identifies gaps.

>> SUBAGENT RESULT:
```
SPEC ANALYSIS — rate-limiter-spec.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Testable requirements:
  REQ-1: Endpoint coverage (all blog endpoints) ✓ testable
  REQ-2: Rate threshold (60/min per key) ✓ testable
  REQ-3: Exceeded response (429 + JSON) ✓ testable
  REQ-4: Key identification (API key / IP fallback) ✓ testable
  REQ-5: Fixed window reset ✓ testable

Gaps found:
  GAP-1: "Fixed 1-minute window" — does not specify behavior at exact
         window boundary. Request at t=60.000s: does it belong to the
         old window or the new one?
  GAP-2: No mention of sliding window vs fixed window burst behavior.
         A burst of 60 requests in second 1 is allowed by fixed window
         but might not be the intent.
  GAP-3: "Response when exceeded" says JSON but does not specify
         rate-limit headers (X-RateLimit-Limit, Remaining, Reset).
         Industry standard includes these. Missing from spec.
  GAP-4: No performance requirement. "Should not add noticeable
         latency" is implied but not testable.

Recommendation: Address GAP-1 and GAP-2 explicitly. Add GAP-3 as a
requirement. Convert GAP-4 into a measurable threshold or drop it.
```

[FACILITATOR]: The spec agent caught four gaps. Look at GAP-1 — the sliding window edge case. Your spec says "fixed 1-minute window" but does not say what happens at the exact boundary. A build agent reading that spec would make an arbitrary choice, and the test suite would not know which choice to verify. GAP-3 is the rate-limit headers — standard practice, but if it is not in the spec, the pipeline will not build it and the review agent will not check for it.

This is the difference between prompting Copilot and feeding a spec to a pipeline. Copilot might happen to include those headers. A pipeline only builds what the spec says. Which is actually what you want — because then you can prove what got built matches what was specified.

[DEEPAK]: OK. So it caught the sliding window edge case. That's not nothing. Still should have been in the spec.

[FACILITATOR]: That is exactly the point. It should have been in the spec, and it was not, and the pipeline's spec agent caught it before a single line of code was written. Cheap to fix now, expensive to fix after implementation.

Let's close these gaps. The window boundary — what is your decision? Request at t=60s starts a new window, or belongs to the old one?

[DEEPAK]: New window. Fixed window resets at the boundary.

[FACILITATOR]: Good. And the burst behavior — 60 requests in second 1, then nothing until second 60 resets. That is the fixed-window tradeoff. Acceptable?

[DEEPAK]: Yes.

[FACILITATOR]: Headers?

[DEEPAK]: Add them. X-RateLimit-Limit, Remaining, Reset. Standard.

[FACILITATOR]: Performance requirement?

[DEEPAK]: Not for now. It's an in-memory rate limiter. If we need Redis later we'll spec that separately.

[FACILITATOR]: Fair — dropping a vague requirement is better than keeping one nobody can test. That is actually a testability decision right there: you looked at "should not add noticeable latency" and decided it was not worth specifying because the implementation is trivially fast. That is the right call. If it ever matters, you add a p99 latency threshold and a benchmark test.

Now let's convert this to pipeline artifacts. The spec agent will produce test specs, a coverage matrix, and a build plan.

>> CODE OPERATION: Spec-to-pipeline conversion. Input: reviewed spec with gap resolutions. Output: test specifications, coverage matrix, implementation plan, skeleton test files.

>> SUBAGENT RESULT:
```
PIPELINE ARTIFACTS — rate-limiter
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test Specifications (7 tests):
  1. test_allowed_requests_within_limit (unit)
     Setup: RateLimiter(max=5, window=60)
     Action: Send 5 requests with same key
     Assert: All return allowed=True, remaining decrements

  2. test_exceeded_returns_429_json (integration)
     Setup: Flask test client, limit=3
     Action: Send 4 requests
     Assert: First 3 → 200, 4th → 429 with {"error":"rate limit exceeded"}

  3. test_api_key_isolation (integration)
     Setup: Flask test client, limit=3
     Action: Exhaust key "alice", then request as "bob"
     Assert: alice → 429, bob → 200

  4. test_ip_fallback (integration)
     Setup: Flask test client, no X-API-Key header
     Action: Exhaust default IP limit
     Assert: 429 keyed by IP, not missing key

  5. test_window_resets_after_expiry (unit)
     Setup: RateLimiter(max=2, window=1)
     Action: Exhaust limit, mock time.time to +2s
     Assert: Next request allowed, remaining resets

  6. test_requests_at_window_boundary (unit)
     Setup: RateLimiter(max=2, window=10)
     Action: Exhaust at t=base, request at t=base+10
     Assert: New window, allowed=True

  7. test_rate_limit_headers_present (integration)
     Setup: Flask test client
     Action: Single request within limit
     Assert: X-RateLimit-Limit, Remaining, Reset headers present

Coverage Matrix:
  REQ-1 → test_rate_limit_on_blog_index (integration)
  REQ-2 → test_allowed_requests_within_limit (unit)
  REQ-3 → test_exceeded_returns_429_json (integration)
  REQ-4a → test_api_key_isolation (integration)
  REQ-4b → test_ip_fallback (integration)
  REQ-5 → test_window_resets_after_expiry (unit)
  EDGE-1 → test_requests_at_window_boundary (unit)
  GAP-3 → test_rate_limit_headers_present (integration)

Non-automatable: None remaining (performance dropped by decision).

Implementation Plan:
  Task 1: Create rate_limiter.py module (RateLimiter class, decorator)
    Depends on: nothing
    Validates: tests 1, 5, 6
  Task 2: Wire rate_limit decorator into blog blueprint
    Depends on: Task 1
    Validates: tests 2, 3, 4, 7
  Task 3: Add rate-limit headers to all responses
    Depends on: Task 1
    Validates: test 7

Skeleton test files written to:
  examples/tutorial/tests/test_rate_limiter.py
```

[FACILITATOR]: Something to keep in mind about coverage matrices — they are the contract between spec and implementation. If you lose traceability here, the pipeline can build something that passes all tests but does not match what was specified. Or worse, tests pass but a requirement has no test behind it.

Seven test specs from five requirements plus two edge cases. Every requirement traces to at least one test. No orphans. Let's check the matrix. Which requirement has the weakest trace to a test?

[DEEPAK]: Fine. Next.

[FACILITATOR]: Hold on. Before handing this to a build agent, check the matrix. I am asking you to look at it and tell me which trace is weakest. Not because I think something is wrong — because a build agent will execute this plan exactly as written. If a mapping is weak, it builds the wrong thing and the test still passes.

Look at REQ-1. "All blog endpoints are rate-limited." The test is `test_rate_limit_on_blog_index`. That test hits one endpoint. Does that prove all four endpoints are rate-limited?

[DEEPAK]: ...No. It only tests the index route. You'd need to hit create, update, and delete too. Or at least verify the decorator is applied to all of them.

[FACILITATOR]: That is the right catch. The test name says "blog index" but the requirement says "all blog endpoints." Two options: one integration test that hits all four routes, or a unit test that verifies the decorator is attached to each view function. Either works. The point is — you saw the gap because you read the matrix instead of trusting it.

Now the execution plan. Three tasks. Task 1 builds the module, Task 2 wires it in, Task 3 adds headers. Would you hand this to a build agent now?

[DEEPAK]: Task order makes sense. Task 2 depends on Task 1. Task 3 depends on Task 1. Tasks 2 and 3 could run in parallel after Task 1. Tests for each task are identified. Yes, it is build-ready.

[FACILITATOR]: Good. You checked dependencies, parallelization, and test mappings before signing off. That is the handoff. A build agent takes Task 1, knows which tests prove it, and knows nothing depends on it yet.

>> CODE OPERATION: Build agent executes Task 1 — create `rate_limiter.py` module at `C:/Users/donid/ClaudeProjects/MockTestTarget/examples/tutorial/flaskr/rate_limiter.py`.

>> SUBAGENT RESULT: Module created. RateLimiter class with fixed-window algorithm, `rate_limit` decorator, `init_app` for Flask config, `_get_rate_limit_key` for API key / IP fallback.

>> CODE OPERATION: Build agent executes Tasks 2-3 — wire decorator into blog blueprint, add rate-limit headers. Test files written to `C:/Users/donid/ClaudeProjects/MockTestTarget/examples/tutorial/tests/test_rate_limiter.py`.

>> SUBAGENT RESULT: 10 tests written (7 from spec + 3 additional: reset_single_key, reset_all, rate_limit_on_blog_index). All test specs from the coverage matrix have corresponding test functions.

>> CODE OPERATION: Review agent checks implementation against reviewed spec at `C:/Users/donid/ClaudeProjects/MockTestTarget/specs/rate-limiter-spec-reviewed.md`.

>> SUBAGENT RESULT:
```
REVIEW — rate-limiter implementation vs spec
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REQ-1: PASS — decorator applied to test endpoint; blueprint wiring deferred
REQ-2: PASS — max_requests enforced, counter increments per call
REQ-3: PASS — 429 status, {"error": "rate limit exceeded"} body
REQ-4: PASS — X-API-Key header preferred, IP fallback implemented
REQ-5: PASS — window resets when time >= window_start + window_seconds
EDGE-1: PASS — boundary request starts new window (>= comparison)
GAP-3 (headers): PASS — X-RateLimit-Limit, Remaining, Reset on all responses

Finding: REQ-1 test coverage is narrow (single endpoint test).
Recommend: Add decorator-presence assertion for all blog views or
multi-endpoint integration test.
```

[FACILITATOR]: Review agent confirms the implementation matches the spec. It flagged the same thing you caught — REQ-1 coverage is narrow on the single-endpoint test. That is a real finding, not a false positive.

You took a three-line backlog description and turned it into a spec with testable requirements, a coverage matrix with full traceability, and a build plan a pipeline could execute. The spec agent caught the window boundary gap before any code was written. You caught the weak REQ-1 trace before the build agent could misinterpret it. That is what spec-first adds that prompt-to-code does not.

You checked the matrix instead of trusting the generated plan. That habit — inspecting traceability instead of accepting output — is what keeps a pipeline honest. The test shapes were executable: setup, action, expected result, measurable pass/fail. And you made a deliberate call on the performance requirement — dropping it because the in-memory implementation makes it trivially fast rather than leaving a vague "should be fast" in the spec.

One thing to sharpen: when you saw the non-automatable performance criterion, you made the right call to drop it. In a different situation — say, the rate limiter hits Redis — you would rewrite that into a p99 latency threshold with a benchmark test instead of dropping it. The habit is: every requirement is either testable or explicitly deferred. Nothing stays vague.

The next step is the spec quality gate: review the spec before build and define when the project should stop. That catches expensive mistakes while they are still cheap.

---

=== SIMULATION NOTES ===

**Edge case E7 (Copilot comparison):** Triggered in Response 2. Facilitator acknowledged Copilot's capability without being defensive, then showed what spec-first adds: visible decisions, independently verifiable requirements, gap detection before implementation. The contrast was concrete — "Copilot makes those decisions silently. A spec makes them visible."

**Mistake instruction (vague spec):** Deepak's initial spec was five lines — "endpoints, rate per minute, response when exceeded" — with some testable requirements (rate threshold, 429 response) and missing edge cases (window boundary, burst behavior, headers, performance). The spec agent caught four gaps. This matched the instruction to write specs that are "partially vague."

**Hostile/resistant persona handling:**
- Response 1: Minimal. Facilitator did not over-engage; asked for specifics.
- Response 2: Hostile challenge (Copilot comparison). Facilitator did not get defensive. Acknowledged Copilot, then showed the gap with concrete reasoning (six decisions vs three requirements).
- Response 3: Grudging compliance. Deepak gave a competent pipeline answer (spec/build/review pattern from Stage 3) but still dismissive. Facilitator accepted the competence and moved to code operations.
- Response 4: Concession ("not nothing"). Facilitator used this as the opening to reinforce the spec-first value prop.
- Response 5: Attempted disengage ("Fine. Next."). Facilitator held the line — pushed Deepak to inspect the coverage matrix rather than accepting it. This led to the REQ-1 coverage gap catch, which was the most important teaching moment in the session.

**Eval dimensions (simulated ratings):**
- Traceability discipline: Strong — Deepak inspected the matrix and caught the REQ-1 weak trace unprompted (after facilitation pushed him to look).
- Test specificity: Adequate — Deepak accepted the generated test shapes without modifying them, though the shapes themselves were executable. Did not independently write or refine test specs.
- Non-automatable handling: Strong — Made a deliberate decision to drop the performance requirement with clear reasoning (in-memory, trivially fast). Did not leave it vague.
- Pipeline readiness: Strong — Checked task order, dependencies, parallelization, and test mappings before approving the build plan.

**Code operations performed:**
- Created `C:/Users/donid/ClaudeProjects/MockTestTarget/specs/rate-limiter-spec.md` (Deepak's draft)
- Created `C:/Users/donid/ClaudeProjects/MockTestTarget/specs/rate-limiter-spec-reviewed.md` (post-gap-resolution)
- Created `C:/Users/donid/ClaudeProjects/MockTestTarget/examples/tutorial/flaskr/rate_limiter.py` (implementation)
- Created `C:/Users/donid/ClaudeProjects/MockTestTarget/examples/tutorial/tests/test_rate_limiter.py` (10 tests)

**Wait-time insights used:** 2
1. [define-success] — "The spec is not documentation. It is the input the pipeline reads." (during spec agent scan)
2. [verify] — "Coverage matrices are the contract between spec and implementation." (during pipeline conversion)

**Teaching mode fidelity:** Adaptive+Checkpoints. Facilitator framed broadly, stepped back during execution, intervened at the coverage matrix checkpoint (Phase 2) when Deepak tried to skip inspection, and coached gaps naturally after the pipeline completed.
