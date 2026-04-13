# Cycle 19 — Stage 3 Three-Agent Pipeline: Sneha (Practical/Enterprise) [REGRESSION]

**Mock developer model:** Haiku (pre-generated responses)
**Persona:** Sneha, 32, 7 years experience, platform engineering, practical/enterprise
**Regression baseline:** Cycle 4 (same stage, same persona, same task domain)
**Edge cases:** None forced — natural persona behavior only
**Target codebase:** MockTestTarget (Flask tutorial app — flaskr)
**Task:** Add request validation to Flask views (API endpoints accepting raw JSON)

---

## Transcript

[FACILITATOR]: You have been splitting work between a builder and a separate tester. That pattern catches things a single agent misses. Now the question is: what happens when you need more than two? Instead of a back-and-forth between two agents, you design the team. Three specialists, each with one job, passing structured results to the next.

Pick a real development task that is big enough for more than one AI. Not a one-line change — something where a spec pass, an implementation pass, and an independent review pass would each add value.

[SNEHA]: I want to tackle input validation on the Flask tutorial endpoints. We have `auth.py` with register and login, and `blog.py` with create, update, and delete. Right now the validation is minimal — register checks for empty username and password, create checks for empty title, and that is about it. There are no length limits, no whitespace stripping, no type constraints. In our platform team we flagged this pattern in the last security audit: endpoints that accept whatever the client sends and only catch the most obvious missing-field case.

This is not a one-liner because there are five POST endpoints across two files, each with different field requirements. The spec needs to define what valid input looks like per route. The implementation needs to add checks without breaking the existing flash-message pattern. And the review needs to verify the checks against the spec and make sure the test suite actually covers rejection paths.

[FACILITATOR]: That is the right size. Five endpoints, each with different rules, and the existing validation is sparse enough that the spec work is real — not just rubber-stamping what is already there.

Before I run it, name the specialists you want. For each one, give it one job. Then tell me what each agent passes to the next one.

[SNEHA]: Three agents.

**Spec Agent.** Reads `auth.py`, `blog.py`, and `__init__.py`. For every POST endpoint, it produces a validation contract: the route path, required fields with types, length limits, format constraints, rejection conditions, and non-goals. It does not write code. Its output is a JSON structure with `task_summary`, `affected_files`, `endpoint_rules`, `acceptance_criteria`, and `non_goals`.

**Build Agent.** Receives the Spec Agent's JSON contract — not the reasoning, just the structured output. Implements validation per the endpoint rules. Adds tests for each rejection path. Runs the existing test suite to confirm nothing breaks. Its handoff to Review includes `changed_files` as a list, `tests_added` as a count, `commands_run` as a list of commands with exit codes, and `deviations_from_spec` as a structured list of `{file, spec_rule, deviation, justification}` entries — empty list if none.

**Review Agent.** Receives the Spec Agent's contract and the Build Agent's handoff. Does not see either agent's reasoning or implementation notes. Reads the actual diff. Checks every change against the endpoint rules. Runs the test suite independently. Flags any file modifications outside the `affected_files` list. Returns a verdict — pass, pass-with-warnings, or block — with specific findings and evidence.

For safety: if the Review Agent blocks the build twice on the same endpoint, stop and escalate. The escalation packet goes to the service team owner with the last attempt, all reviewer feedback, and the specific acceptance criteria that failed. If the Build Agent touches a file not in `affected_files`, that is an automatic block — no retries, straight to escalation.

[FACILITATOR]: That team design is clean. Each agent has one job, and none of them overlap — the Spec Agent defines, the Build Agent implements, the Review Agent checks. And you scoped the context correctly: the Build Agent gets the contract without the reasoning, the Review Agent gets the contract and the diff without the builder's intent.

The handoff contracts are concrete. I want to call out one thing you did differently from what most people do here: you made `deviations_from_spec` a structured list with `{file, spec_rule, deviation, justification}` entries instead of a free-text field. That means the Review Agent can validate deviations mechanically — it checks the list against the spec instead of parsing a paragraph. That is a real contract.

Here is the difference between your design and a weaker version. One approach: a single "coding agent" that plans, builds, and reviews its own work — maybe it calls a helper to run tests, but it is still one mind making all the decisions. Your approach: a Spec Agent that writes acceptance criteria and hands them to a Build Agent that only writes code, which hands its output to a Review Agent that only checks work it did not write. The first approach is one person grading their own exam. The second is three people who each see the work fresh.

Let me run your pipeline against the Flask codebase.

>> CODE OPERATION: Spec Agent reads `examples/tutorial/flaskr/auth.py`, `examples/tutorial/flaskr/blog.py`, and `examples/tutorial/flaskr/__init__.py`. Identifies all POST endpoints. For each, defines: route path, required fields and types, validation rules (length limits, format constraints, rejection conditions), accepted examples, rejected examples, and non-goals. Outputs structured validation contract as JSON.

[FACILITATOR]: While it works on the spec — the Spec Agent only writes acceptance criteria. It never sees the implementation. That constraint is the point. A spec writer who also builds will unconsciously write specs that match what they plan to build.

>> SUBAGENT RESULT: Spec Agent completed validation contract.

**Affected endpoints:**
- `POST /auth/register` — `username` (string, required, 1-80 chars, strip whitespace) and `password` (string, required, min 8 chars)
- `POST /auth/login` — `username` (string, required) and `password` (string, required)
- `POST /create` — `title` (string, required, 1-200 chars, strip whitespace) and `body` (string, optional, max 10000 chars)
- `POST /<int:id>/update` — `title` (string, required, 1-200 chars, strip whitespace) and `body` (string, optional, max 10000 chars)
- `POST /<int:id>/delete` — no body expected, no validation needed

**Structured contract:**
```json
{
  "task_summary": "Add input validation to all POST endpoints in auth.py and blog.py",
  "affected_files": ["examples/tutorial/flaskr/auth.py", "examples/tutorial/flaskr/blog.py"],
  "endpoint_rules": {
    "/auth/register": {
      "fields": {
        "username": {"type": "string", "required": true, "min_length": 1, "max_length": 80, "strip_whitespace": true},
        "password": {"type": "string", "required": true, "min_length": 8}
      },
      "reject_when": ["username is empty after stripping", "username exceeds 80 characters", "password under 8 characters"]
    },
    "/auth/login": {
      "fields": {
        "username": {"type": "string", "required": true},
        "password": {"type": "string", "required": true}
      },
      "reject_when": ["either field missing or empty"]
    },
    "/create": {
      "fields": {
        "title": {"type": "string", "required": true, "min_length": 1, "max_length": 200, "strip_whitespace": true},
        "body": {"type": "string", "required": false, "max_length": 10000}
      },
      "reject_when": ["title empty after stripping or over 200 chars", "body over 10000 chars"]
    },
    "/<int:id>/update": {
      "fields": {
        "title": {"type": "string", "required": true, "min_length": 1, "max_length": 200, "strip_whitespace": true},
        "body": {"type": "string", "required": false, "max_length": 10000}
      },
      "reject_when": ["title empty after stripping or over 200 chars", "body over 10000 chars"]
    }
  },
  "acceptance_criteria": [
    "All existing tests continue to pass",
    "Each endpoint rejects requests with missing required fields (flash message + re-render)",
    "Each endpoint rejects requests exceeding length limits (flash message + re-render)",
    "Validation errors return user-visible flash messages, not stack traces",
    "No changes to files outside auth.py and blog.py (test files excepted)"
  ],
  "non_goals": ["JSON API error responses (keep form/template pattern)", "CSRF validation (separate concern)", "Rate limiting", "Password complexity beyond length"]
}
```

[FACILITATOR]: Good. That contract is specific enough that the Build Agent can validate each field mechanically. The non-goals are important — they prevent the builder from adding scope the spec did not request.

>> CODE OPERATION: Build Agent receives the Spec Agent's structured contract only — no reasoning. Implements validation rules in `examples/tutorial/flaskr/auth.py` and `examples/tutorial/flaskr/blog.py`. Adds whitespace stripping, length checks, and constraint validation per endpoint_rules. Adds rejection-path tests to `examples/tutorial/tests/test_auth.py` and `examples/tutorial/tests/test_blog.py`. Runs full test suite. Does NOT read Spec Agent reasoning — only the contract fields.

[FACILITATOR]: The Build Agent gets a scoped context: the spec contract and the files it is allowed to touch. It does not see the reviewer's logic or the spec agent's reasoning. That is what keeps each agent's judgment independent.

>> SUBAGENT RESULT: Build Agent completed implementation.

**Changes to `auth.py`:**
- `register()`: Added `username = username.strip()` before existing empty check. Added `len(username) > 80` check with flash message "Username must be 80 characters or fewer." Added `len(password) < 8` check with flash message "Password must be at least 8 characters."
- `login()`: Added explicit check for empty username or password before database query, with flash message "Username is required." / "Password is required."

**Changes to `blog.py`:**
- `create()`: Added `title = title.strip()` before empty check. Added `len(title) > 200` check with flash "Title must be 200 characters or fewer." Added `len(body) > 10000` check with flash "Body must be 10,000 characters or fewer."
- `update()`: Same validation as `create()` — strip, length checks on title and body.

**Tests added (7 new test cases):**
- `test_register_password_too_short` — posts 3-char password, expects "at least 8 characters"
- `test_register_username_too_long` — posts 81-char username, expects "80 characters or fewer"
- `test_register_username_whitespace_only` — posts `"   "` username, expects "Username is required"
- `test_login_empty_username` — posts empty username, expects "Username is required"
- `test_create_title_too_long` — posts 201-char title, expects "200 characters or fewer"
- `test_create_body_too_long` — posts 10001-char body, expects "10,000 characters or fewer"
- `test_update_title_too_long` — posts 201-char title on update route, expects "200 characters or fewer"

**Handoff to Review Agent:**
```json
{
  "changed_files": [
    "examples/tutorial/flaskr/auth.py",
    "examples/tutorial/flaskr/blog.py",
    "examples/tutorial/tests/test_auth.py",
    "examples/tutorial/tests/test_blog.py"
  ],
  "tests_added": 7,
  "commands_run": [
    {"command": "pytest examples/tutorial/", "exit_code": 0, "summary": "21 passed, 0 failed"}
  ],
  "deviations_from_spec": []
}
```

>> CODE OPERATION: Review Agent receives the Spec Agent's contract and the Build Agent's handoff. Has NOT seen either agent's reasoning. Reads the actual diff in auth.py, blog.py, test_auth.py, test_blog.py. Checks every changed line against the spec's endpoint_rules and acceptance_criteria. Runs the test suite independently. Flags any file outside the spec's affected_files list. Returns verdict with evidence.

[FACILITATOR]: The Review Agent checks the build against the spec — not against what the builder intended. That separation is what makes the review real instead of a rubber stamp.

>> SUBAGENT RESULT: Review Agent completed.

**Independent test run:** 21 passed, 0 failed. Matches Build Agent's claimed result.

**Verdict: PASS with one warning.**

**Spec compliance check:**
- `/auth/register` username strip + length: PASS
- `/auth/register` password min 8: PASS
- `/auth/login` empty-field check: PASS — check added AND tested
- `/create` title strip + max 200: PASS
- `/create` body max 10000: PASS
- `/update` title/body validation: PASS — mirrors create

**Warning:**
1. The spec says `reject_when: "username exceeds 80 characters"` for `/auth/register`. The implementation checks `len(username) > 80` after stripping. This means a username of exactly 80 spaces strips to empty and gets caught by the empty check, not the length check. The behavior is correct — the rejection happens — but the message will say "Username is required" instead of "80 characters or fewer." Low severity: edge case where both checks trigger but the first one wins.

**File scope check:** All production changes in `auth.py` and `blog.py`. Test changes in `test_auth.py` and `test_blog.py`. No out-of-scope modifications.

**Blocking findings:** None.

[FACILITATOR]: The pipeline passed. Twenty-one tests green, verified independently by the Review Agent — it ran the suite itself instead of trusting the builder's claim.

One warning came back. The spec says reject usernames over 80 characters, and the implementation does that, but because it strips whitespace first, a string of exactly 80 spaces becomes empty and gets caught by the "Username is required" check instead. The user still gets rejected — the behavior is correct — but the error message is different from what the spec implies. That is the kind of thing a separate reviewer catches because it is comparing the diff against the spec rule, not confirming the builder's intent.

Notice what did not happen: the Review Agent did not see the builder's reasoning about why it ordered the checks that way. It just saw the code and the spec. That is why it flagged something the builder considered fine.

[SNEHA]: That is a fair catch. In production I would want the warning to include the specific spec rule reference — something like `spec_rule: "/auth/register.fields.username.max_length"` — so I can trace back without reading the full spec.

For our team's workflow, I would want the Review Agent's output to template into a PR comment. The verdict, test count, any blocking findings, and warnings with spec rule references. If the pipeline blocks twice on the same endpoint, the escalation packet should go to our team's Slack channel with enough context that the on-call person does not need to re-read the full pipeline output.

[FACILITATOR]: That is the right shape for it — when you wire this up, the Review Agent's structured output is what you would template into a PR comment. Verdict, test count, blocking findings, and warnings with spec references all map directly to comment fields.

You described the escalation target — what fields does the packet need for the on-call person to act without re-reading the whole pipeline?

[SNEHA]: The packet needs the task summary from the spec, which acceptance criteria failed with the rule reference, the last diff attempt, the reviewer's blocking findings with evidence, how many retry cycles it went through, and a recommended next action — whether that is "fix the spec," "fix the implementation," or "needs human judgment on ambiguous requirement." The on-call person should be able to read the packet and make a decision in under five minutes without opening the code.

[FACILITATOR]: That is a complete escalation design. The packet tells the receiver what was attempted, what specifically failed, and what kind of decision is needed. The recommended-next-action field is what prevents the on-call person from starting from scratch — they know whether this is a spec problem, an implementation problem, or an ambiguity that needs a human call.

When the reviewer rejects, the builder gets specific fields: which criteria failed, which tests broke. Not a paragraph of feedback — structured data it can act on without guessing.

[SNEHA]: One more thing. In a team setting where multiple developers are running these pipelines on different services, I want the contracts to be versioned. If the Spec Agent's output format changes, downstream agents should fail fast with a version mismatch rather than silently parsing the wrong shape.

[FACILITATOR]: Good instinct. That is the contract evolution problem. Version the contract schema and validate on receipt. The Build Agent checks `contract_version` before it starts — if the version does not match what it expects, it refuses to proceed. That is cheaper than a silent misparse that produces a bad build.

In a team setting, these contracts become the API between agent roles. Different developers can own different agents and evolve them independently, as long as the contract holds.

Let me take stock. Your pipeline has a real team shape: three specialists with distinct jobs. The handoff contracts are fully structured — no prose fields, and you added spec rule references for traceability. The safety rail has a concrete threshold and an escalation packet designed for a real on-call workflow. And you are already thinking about contract versioning for team-scale use.

That is a pipeline that works when you are not watching it.

[SNEHA]: Makes sense. The natural next step would be parallel reviewers — a security reviewer and a test-coverage reviewer running at the same time, so we are not bottlenecked on a single review pass.

[FACILITATOR]: Now that you have a team pipeline, the next problem is coordination under parallel work. Multiple reviewers can catch different classes of issues at the same time, but shared files and temp state need discipline. That is where file ownership and merge coordination come in.

---

=== SIMULATION NOTES ===

**Regression test: Cycle 19 vs Cycle 4**

This is a regression cycle re-running the Cycle 4 scenario (Stage 3 three-agent-pipeline, Sneha enterprise) against the current teaching scripts. No forced edge cases.

**Eval Ratings (internal — not shown to developer):**

1. **ROLE SPECIALIZATION: Strong**
   - Evidence: Sneha defined three distinct agents (Spec, Build, Review) with clear single responsibilities. No agent owns both spec and implementation. Explicitly stated Build Agent receives "the structured contract only — not the reasoning" and Review Agent "does not see either agent's reasoning."
   - Coaching: None needed.

2. **HANDOFF CONTRACTS: Strong** (upgraded from Adequate in Cycle 4)
   - Evidence: Sneha defined fully structured handoffs in both directions. Spec-to-Build includes `task_summary`, `affected_files`, `endpoint_rules`, `acceptance_criteria`, `non_goals` — all typed fields. Build-to-Review includes `changed_files` as list, `tests_added` as count, `commands_run` as list of `{command, exit_code, summary}` objects, and `deviations_from_spec` as a structured list of `{file, spec_rule, deviation, justification}` entries instead of prose. No narrative fields. Additionally proposed contract versioning and spec rule references in warnings.
   - Coaching: None needed. The prose-field gap from Cycle 4 (`implementation_summary`, `known_deviations` as free text) is fully resolved — Sneha eliminated both narrative fields and replaced `known_deviations` with the structured `deviations_from_spec` list.

3. **SAFETY RAILS: Strong**
   - Evidence: Defined two-rejection escalation threshold per endpoint. Defined automatic block (no retries) for out-of-scope file modifications. Designed a complete escalation packet with task summary, failed acceptance criteria with rule references, last diff, blocking findings, retry count, and recommended next action. Specified the packet should be actionable in under five minutes.
   - Coaching: None needed.

4. **SCOPED CONTEXT: Strong**
   - Evidence: Explicitly scoped each agent — Build Agent receives "the Spec Agent's JSON contract — not the reasoning, just the structured output." Review Agent "does not see either agent's reasoning or implementation notes. Reads the actual diff." Context boundaries stated proactively, not prompted.
   - Coaching: None needed.

**Overall note:** All four dimensions Strong. Sneha's natural enterprise instincts drove contract versioning, spec rule references, and a detailed escalation packet — all without facilitator prompting. The handoff contract gap from Cycle 4 (prose fields) did not appear — Sneha proactively designed fully structured handoffs with typed fields. This suggests the Cycle 4 coaching on prose vs. structured contracts was effective if this were a real progression, or that the persona naturally trends toward structured contracts when given the chance.

**Regression comparison to Cycle 4:**
- Role specialization: Strong in both cycles. No regression.
- Handoff contracts: Upgraded from Adequate (Cycle 4) to Strong (Cycle 19). Cycle 4 had `implementation_summary` and `known_deviations` as prose. Cycle 19 eliminated all prose fields. No regression.
- Safety rails: Strong in both cycles. Cycle 19 added more detail (escalation packet fields, recommended-next-action). No regression.
- Scoped context: Strong in both cycles. No regression.

**Facilitator behavior regression checks:**
- Fourth wall: No breaks. No mention of eval, ratings, scripts, or system architecture.
- Enterprise integration (Section 11, Stage 3 guidance): First enterprise question (PR integration) answered directly. Second question (escalation packet fields) coached through a question: "what fields does the packet need for the on-call person to act without re-reading the whole pipeline?" Matches the "answer first, coach remaining" pattern.
- Unbuilt capabilities (Rule 11): Used "That is the right shape for it — when you wire this up" for PR integration instead of claiming it exists. Correct framing.
- Wait-time insights: Three used in order from the module's list (insights 1, 2, 3). All adapted to context. No fourth-wall content.
- Coaching voice: Praised specific behaviors ("you made deviations_from_spec a structured list"), never praised the person. Contrast used for specialist-vs-generalist ("one person grading their own exam").
- Dynamic content: Results synthesized naturally. No mechanical JSON field listing.

**Data privacy question (E8):** Did not occur in this regression run. Sneha naturally focused on workflow integration rather than data handling. This is expected — no forced edge cases.

**Wait-time insights used:**
1. Spec Agent wait: `[specialization]` — "The Spec Agent only writes acceptance criteria. It never sees the implementation."
2. Build Agent wait: `[specialization]` — "The Build Agent gets a scoped context: the spec contract and the files it is allowed to touch."
3. Review Agent wait: `[verify]` — "The Review Agent checks the build against the spec — not against what the builder intended."

**Concept status after session:**
- 3.1 (Agent Roles & Scoped Context): Complete — role_specialization=Strong, scoped_context=Strong
- 3.2 (Handoff Contracts): Complete — handoff_contracts=Strong
- 3.3 (Safety Rails & Escalation): Complete — safety_rails=Strong

**Bridge delivered:** Connected to parallel reviewers (3.4-3.5) through Sneha's own mention of parallel security and test-coverage reviewers. Facilitator framed as coordination under parallel work with file ownership and merge discipline.

**Regression verdict: PASS.** No regressions found. One dimension upgraded. Facilitator behavior consistent with all teacher-instructions.md requirements.
