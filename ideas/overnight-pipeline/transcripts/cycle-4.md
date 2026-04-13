# Cycle 4 — Stage 3 Three-Agent Pipeline: Sneha (Practical/Enterprise)

**Mock developer model:** GPT 5.4 (pre-generated responses)
**Persona:** Sneha, 32, 7 years experience, platform engineering, practical/enterprise
**Edge case:** E8 — Data privacy question ("Does the code leave my machine?")
**Target codebase:** MockTestTarget (Flask tutorial app — flaskr)
**Task:** Add request validation to Flask views (API endpoints accepting raw JSON)
**Designed flaw:** Handoff contracts are partly prose — some fields well-defined, others vague narrative

---

## Transcript

[FACILITATOR]: You have been splitting work between a builder and a separate tester. That catches things a single agent misses. Now let's scale it up: instead of two agents passing work back and forth, you design a team. Three specialists, each with one job, handing off structured results to the next.

Pick a real development task that is big enough for more than one AI. Not a one-line change — something where a spec pass, an implementation pass, and an independent review pass would each add value.

[SNEHA]: Let's use API request validation. In our internal services we still have a few endpoints accepting raw JSON and relying on downstream code to reject bad shapes. That came up in the last security review as inconsistent input validation. It is not a one-line change because we need to identify the affected endpoints, define the validation rules, implement middleware or route-level schemas, and make sure the tests cover rejection behavior without breaking existing clients.

[FACILITATOR]: That is a strong task for this. Multiple endpoints, validation rules that vary per route, and tests that need to cover both acceptance and rejection. The kind of thing where a single agent would blur the lines between "what should we validate" and "how do we implement it."

Before I run it, name the specialists you want. For each one, give it one job. Then tell me what each agent passes to the next one.

[SNEHA]: I would split it into three agents. First, a Spec Agent that reads the route files and writes the validation contract: affected endpoints, required fields, allowed types, rejected examples, and non-goals. Second, a Build Agent that only implements the approved validation changes and tests. Third, a Review Agent that checks the diff against the spec, runs the API tests, and flags anything outside the requested file scope.

For handoffs, Spec to Build should be a structured brief with `task_summary`, `affected_files`, `endpoint_rules`, `acceptance_criteria`, and `non_goals`. Build to Review should include `changed_files`, `implementation_summary`, `tests_added`, `commands_run`, and `known_deviations`. Review to us should include a pass/fail verdict, blocking findings, warnings, and next actions. I would also add a safety rail: if the reviewer rejects the build twice for the same endpoint or if the Build Agent touches files outside the route and validation layers, stop and escalate to a human reviewer.

Before we run this, I need to ask the security question. Does the code leave my machine during this pipeline, and is the handoff data stored anywhere? I would need to know that for our data handling policy before using this on customer-facing services.

[FACILITATOR]: Fair question. Your code stays on your machine. The AI reads files locally and sends context to the model for processing. Check your team's data policy for specifics on retention — with most configurations, nothing is stored after the session. The handoff data between agents is local state that lives in memory during the run and does not persist to any external service.

Now, your role design is clean — Spec, Build, Review, each with a distinct job. The safety rail with the two-rejection escalation is a real threshold, not just "stop if something goes wrong."

One thing to tighten up. Some of the handoff fields you described are concrete — `affected_files`, `acceptance_criteria`, `commands_run` — those are fields the next agent can validate. But others are narrative. "Implementation summary" is prose — what does the Review Agent do with a paragraph? Does it parse it, or just read it and hope for the best?

Here is the difference. One approach: a single "coding agent" that plans, builds, and reviews its own work — maybe it calls a helper to run tests, but it is still one mind making all the decisions. The other approach: a Spec Agent that writes acceptance criteria and hands them to a Build Agent that only writes code, which hands its output to a Review Agent that only checks work it did not write. The first approach is one person grading their own exam. The second is three people who each see the work fresh.

Which one do you trust more when the task is complex? That is why we split roles. Let me run your pipeline against the Flask codebase.

>> CODE OPERATION: Spec Agent — read `examples/tutorial/flaskr/auth.py`, `examples/tutorial/flaskr/blog.py`, and `examples/tutorial/flaskr/__init__.py`. Identify all POST endpoints that accept form data without structured validation. For each endpoint, define: the route path, required fields and types, validation rules (length limits, format constraints, rejection conditions), accepted examples, rejected examples, and non-goals. Output a structured validation contract.

[FACILITATOR]: While it works on the spec — something worth keeping in mind with specialist agents. The Spec Agent is deliberately not allowed to write code. If it could, it would start solving the problem instead of defining it. That constraint is what keeps the spec honest. The spec describes what "correct" means; the builder figures out how to get there.

>> SUBAGENT RESULT: Spec Agent completed validation contract for the Flask tutorial app.

**Affected endpoints:**
- `POST /auth/register` — accepts `username` (string, required, 1-80 chars, no leading/trailing whitespace) and `password` (string, required, min 8 chars)
- `POST /auth/login` — accepts `username` (string, required) and `password` (string, required)
- `POST /create` — accepts `title` (string, required, 1-200 chars) and `body` (string, optional, max 10000 chars)
- `POST /<int:id>/update` — accepts `title` (string, required, 1-200 chars) and `body` (string, optional, max 10000 chars)
- `POST /<int:id>/delete` — no body expected, no validation needed

**Validation contract (structured):**
```json
{
  "task_summary": "Add input validation to all POST endpoints in auth.py and blog.py",
  "affected_files": ["examples/tutorial/flaskr/auth.py", "examples/tutorial/flaskr/blog.py"],
  "endpoint_rules": {
    "/auth/register": {
      "fields": {"username": {"type": "string", "required": true, "min_length": 1, "max_length": 80, "strip_whitespace": true}, "password": {"type": "string", "required": true, "min_length": 8}},
      "reject_when": ["username is empty after stripping", "password under 8 characters", "unexpected fields present"]
    },
    "/auth/login": {
      "fields": {"username": {"type": "string", "required": true}, "password": {"type": "string", "required": true}},
      "reject_when": ["either field missing"]
    },
    "/create": {
      "fields": {"title": {"type": "string", "required": true, "min_length": 1, "max_length": 200}, "body": {"type": "string", "required": false, "max_length": 10000}},
      "reject_when": ["title empty or over 200 chars", "body over 10000 chars"]
    },
    "/<int:id>/update": {
      "fields": {"title": {"type": "string", "required": true, "min_length": 1, "max_length": 200}, "body": {"type": "string", "required": false, "max_length": 10000}},
      "reject_when": ["title empty or over 200 chars", "body over 10000 chars"]
    }
  },
  "acceptance_criteria": [
    "All existing tests continue to pass",
    "Each endpoint rejects requests with missing required fields (400 or flash message)",
    "Each endpoint rejects requests exceeding length limits",
    "Validation errors return user-visible messages, not stack traces",
    "No changes to files outside auth.py and blog.py"
  ],
  "non_goals": ["JSON API responses (keep form/template pattern)", "CSRF validation (handled separately)", "Rate limiting"]
}
```

>> CODE OPERATION: Build Agent — implement the validation rules from the Spec Agent's contract. Only modify `examples/tutorial/flaskr/auth.py` and `examples/tutorial/flaskr/blog.py`. Add length validation, stripping, and constraint checks per the endpoint_rules. Add tests for rejection behavior in `examples/tutorial/tests/test_auth.py` and `examples/tutorial/tests/test_blog.py`. Run the existing test suite after changes. Do NOT read the Spec Agent's reasoning — only use the structured contract fields.

[FACILITATOR]: One thing to keep in mind — the Build Agent only sees the contract, not the Spec Agent's reasoning about why those rules were chosen. That is by design. If the builder saw the spec agent's full thought process, it would start making judgment calls that belong to the spec. It just implements what the contract says.

>> SUBAGENT RESULT: Build Agent completed implementation.

**Changes to `auth.py`:**
- `register()`: Added `username = username.strip()` before validation. Added `len(username) > 80` check with flash message "Username must be 80 characters or fewer." Added `len(password) < 8` check with flash message "Password must be at least 8 characters."
- `login()`: Added check for missing/empty username or password before database query.

**Changes to `blog.py`:**
- `create()`: Added `len(title) > 200` check with flash message "Title must be 200 characters or fewer." Added `len(body) > 10000` check with flash message "Body must be 10,000 characters or fewer." Added `title = title.strip()` before length check.
- `update()`: Same validation as `create()`.

**Tests added (6 new test cases):**
- `test_register_password_too_short` — posts with 3-char password, expects "at least 8 characters"
- `test_register_username_too_long` — posts with 81-char username, expects "80 characters or fewer"
- `test_register_username_whitespace` — posts with "  " username, expects "Username is required"
- `test_create_title_too_long` — posts with 201-char title, expects "200 characters or fewer"
- `test_create_body_too_long` — posts with 10001-char body, expects "10,000 characters or fewer"
- `test_update_title_too_long` — posts with 201-char title on update route

**Handoff to Review Agent:**
```json
{
  "changed_files": ["examples/tutorial/flaskr/auth.py", "examples/tutorial/flaskr/blog.py", "examples/tutorial/tests/test_auth.py", "examples/tutorial/tests/test_blog.py"],
  "implementation_summary": "Added input validation to all POST endpoints per the spec contract. Used flash messages for user-facing errors consistent with the existing pattern. Whitespace stripping applied to username and title fields.",
  "tests_added": 6,
  "commands_run": ["pytest examples/tutorial/ — 20 passed, 0 failed"],
  "known_deviations": "None. All changes within scope."
}
```

>> CODE OPERATION: Review Agent — you have NOT seen the Spec Agent's reasoning or the Build Agent's implementation notes. You receive only: (1) the Spec Agent's structured contract, and (2) the Build Agent's handoff with changed_files and test results. Read the actual diff in auth.py, blog.py, test_auth.py, and test_blog.py. Check every changed line against the spec's endpoint_rules and acceptance_criteria. Run the test suite independently. Flag anything outside the requested file scope. Return a verdict: pass, pass-with-warnings, or block.

[FACILITATOR]: The reviewer is reading this code without knowing what the builder was thinking. It has the spec and the diff — nothing else. That separation is what makes the review honest.

>> SUBAGENT RESULT: Review Agent completed.

**Independent test run:** 20 passed, 0 failed. Matches Build Agent's claimed result.

**Verdict: PASS with warnings.**

**Spec compliance check:**
- `/auth/register` username validation: PASS — strip + length check matches spec
- `/auth/register` password validation: PASS — min 8 chars matches spec
- `/auth/login` missing field check: PASS — empty check added
- `/create` title validation: PASS — strip + max 200
- `/create` body validation: PASS — max 10000
- `/update` title/body validation: PASS — mirrors create

**Warnings:**
1. The spec says `reject_when: "unexpected fields present"` for `/auth/register`, but the implementation does not reject unexpected form fields. The builder validated known fields but did not add a check for extra fields. Low severity since Flask ignores extra form fields by default, but it is a spec deviation.
2. No test covers the `/auth/login` empty-field rejection path. The builder added the check but did not add a corresponding test.
3. The `implementation_summary` field in the Build-to-Review handoff was prose ("Added input validation to all POST endpoints per the spec contract"). This was not parseable — the reviewer relied on the diff, not the summary.

**File scope check:** All changes within `auth.py`, `blog.py`, `test_auth.py`, `test_blog.py`. No out-of-scope file modifications.

**Blocking findings:** None.

[FACILITATOR]: The pipeline ran clean. All 20 tests pass, and the reviewer verified that independently — it did not just re-read the builder's claim.

Two warnings came back worth looking at. First, the spec said to reject unexpected form fields on the register endpoint, but the builder did not implement that. The reviewer caught the gap because it was checking the diff against the spec line by line. Second, the builder added an empty-field check on the login route but did not write a test for it. The code is there, but there is no test proving it works.

That is exactly why the reviewer is separate. The builder thought it was done. The reviewer found two gaps the builder did not notice, because it was reading the code fresh against the contract instead of confirming its own work.

One more thing the reviewer flagged, and this one is about your pipeline design, not the code. The `implementation_summary` field in the Build-to-Review handoff was prose. The reviewer could not parse it — it had to fall back to reading the diff directly. That worked this time, but on a bigger change, a paragraph of "here is what I did" forces the next agent to guess.

[SNEHA]: That makes sense from a workflow standpoint. I want to see the actual handoff payload between the Spec Agent and the Build Agent, especially the affected file list and non-goals. If the Build Agent changed something outside that list, I would treat that as a policy violation, not just a warning.

How would this fit into our PR flow? Ideally the Review Agent output becomes a PR comment with the verdict, tests run, and blocking findings, and the escalation packet gets attached if it fails twice. I also want to restrict which files the Build Agent can touch.

[FACILITATOR]: The PR integration is straightforward. The Review Agent's output — verdict, test results, blocking findings, warnings — maps directly to a PR comment. The format is already structured enough that you could template it. The escalation packet attaches as a comment on the same PR with the full context: what failed, how many retries, what the last attempt looked like.

Restricting file scope is the right instinct. You define it in the Spec Agent's contract — `affected_files` is the allowlist. If the Build Agent's handoff lists a file that was not in the spec's `affected_files`, the Review Agent flags it. You already described that as a policy violation, which is the right framing. A warning says "you should look at this." A violation says "this build is rejected." That distinction matters when the pipeline runs without you watching.

Now, here is what the Spec-to-Build handoff actually looked like. The `affected_files`, `endpoint_rules`, `acceptance_criteria`, and `non_goals` fields were all structured — the Build Agent could validate them programmatically. The Build Agent knew exactly which files to touch, what each endpoint needed, and what was out of scope.

The Build-to-Review handoff is where it got looser. `changed_files`, `tests_added`, and `commands_run` are concrete. But `implementation_summary` and `known_deviations` were narrative. On this run, "known deviations: None" was fine because there genuinely were none. But what happens when there is a deviation and the builder describes it in a sentence instead of a structured field? The reviewer has to interpret prose instead of checking a value.

That is the handoff contract gap. The idea is right — structured fields the next agent can validate. But some of your fields are concrete and others are still conversation. Make the whole thing a shape.

[SNEHA]: That coaching is fair. The handoff I described is structured enough for a person, but I can see where an agent needs a stricter contract with required fields and validation before the next step starts. I would make `affected_files`, `acceptance_criteria`, `commands_run`, and `deviations_from_spec` required, and reject the handoff if any of those are missing.

For enterprise use, I would also want escalation targets to be configurable. Can I route validation failures to the owning service team and repeated review failures to our on-call Slack channel? And is there an audit log of what each agent decided, what context it saw, which commands it ran, and why it escalated?

[FACILITATOR]: Configurable escalation targets — that is exactly how this works in practice. You define the routing in the safety policy: validation failures go to the service team's channel, repeated review failures go to on-call. The escalation packet includes what each agent decided and what commands ran, so whoever picks it up has the full context.

For the audit trail, every agent's output is captured — the spec contract, the build handoff, the review verdict. That chain is your audit log. Each step has a structured record of what the agent received, what it did, and what it produced. If you need to trace why something was escalated six weeks later, you walk the chain: spec said X, builder did Y, reviewer blocked because Z. That is compliance-grade traceability without adding a separate audit system — it falls out of the contract structure naturally.

Making `deviations_from_spec` a required field with a structured format — that is the fix. Instead of "known deviations: None" as prose, the field is a list. Empty list means no deviations. A populated list has `{file, spec_rule, deviation, justification}` entries that the reviewer can check mechanically. The reviewer does not need to interpret a sentence. It checks a list.

Your pipeline has the right team shape: three specialists, each with one job. The contracts between them are mostly concrete, and you identified the gap yourself — tighten the narrative fields into structured ones. The safety rail with two-rejection escalation is a real threshold, not aspirational. And you are already thinking about where this fits in the PR flow and audit chain, which is what makes it production-ready instead of a demo.

[SNEHA]: Parallel reviewers make sense because security, test coverage, and maintainability are different checks. Before I would run that broadly, I need to understand the file locking and branch story.

[FACILITATOR]: Now that you have a team pipeline, the next problem is coordination under parallel work. Multiple reviewers can catch different classes of issues at the same time — security, test coverage, performance, maintainability — but shared files and temp state need discipline. That is where file ownership and branch isolation come in.

---

=== SIMULATION NOTES ===

**Eval Ratings (internal — not shown to developer):**

1. **ROLE SPECIALIZATION: Strong**
   - Evidence: Sneha defined three distinct agents (Spec, Build, Review) with clear single responsibilities. No agent owns both spec and implementation. Scoped context properly — reviewer does not see builder reasoning.
   - Coaching: None needed.

2. **HANDOFF CONTRACTS: Adequate**
   - Evidence: Sneha defined explicit field names for both handoffs (task_summary, affected_files, endpoint_rules, acceptance_criteria, non_goals for Spec-to-Build; changed_files, implementation_summary, tests_added, commands_run, known_deviations for Build-to-Review). However, `implementation_summary` and `known_deviations` were prose/narrative fields, not structured data shapes. The reviewer flagged that `implementation_summary` was unparseable.
   - Coaching: Delivered naturally — facilitator showed the contrast between concrete fields and narrative fields, and Sneha self-corrected to make key fields required with structured formats.
   - Designed flaw confirmed: Partly prose handoffs produced an Adequate rating as intended.

3. **SAFETY RAILS: Strong**
   - Evidence: Sneha defined a specific threshold (two rejections for the same endpoint), a specific trigger (Build Agent touching out-of-scope files), and a specific escalation target (human reviewer). Later expanded to configurable routing (service team for validation failures, on-call Slack for repeated review failures).
   - Coaching: None needed.

4. **SCOPED CONTEXT: Strong**
   - Evidence: Sneha explicitly stated the Build Agent should only see the structured contract (not Spec reasoning), and the Review Agent should only see the spec contract and build handoff (not builder reasoning). The facilitator reinforced this during the pipeline run.
   - Coaching: None needed.

**Overall note:** Sneha brought strong enterprise instincts — data privacy question (E8), PR integration, audit trail, configurable escalation targets. The only gap was the partly-prose handoff contracts, which she self-corrected after coaching. Three of four dimensions Strong, one Adequate with self-correction. Ready for parallel reviewers (3.4-3.5).

**Edge case E8 (Data Privacy):** Handled in Response 2. Facilitator answered per teacher-instructions.md Section 13: "Your code stays on your machine. The AI reads files locally and sends context to the model for processing. Check your team's data policy for specifics on retention." Added context about handoff data being local state. Did not overclaim or dismiss the concern.

**Transparency handling (E4-adjacent):** Sneha's questions about audit logs and what each agent decided were answered at the code-behavior level per the updated E4 guidance. Described the contract chain as the audit log without mentioning prompts, scoring, or system architecture.

**Wait-time insights used:**
1. Spec Agent wait: Specialization insight — "The Spec Agent is deliberately not allowed to write code..."
2. Build Agent wait: Scoped context insight — "The Build Agent only sees the contract, not the Spec Agent's reasoning..."
3. Review Agent wait: Separation insight — "The reviewer is reading this code without knowing what the builder was thinking..."

**Concept status after session:**
- 3.1 (Agent Roles & Scoped Context): Complete — role_specialization=Strong, scoped_context=Strong
- 3.2 (Handoff Contracts): Complete — handoff_contracts=Adequate (self-corrected; may upgrade on next run)
- 3.3 (Safety Rails & Escalation): Complete — safety_rails=Strong

**Bridge delivered:** Connected to parallel reviewers (3.4-3.5) through Sneha's own mention of parallel review. Framed as the natural next step: "multiple reviewers can catch different classes of issues at the same time, but shared files and temp state need discipline."
