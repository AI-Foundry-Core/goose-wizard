# Recipe 5.5: Eval Isolation — "Mock external dependencies"

> **Path resolution note.** All paths, test reads, mock/fixture writes,
> and isolated-test runs in this script act on the TARGET codebase (the
> developer's project). The parent recipe injected a TARGET PROLOGUE —
> whenever this script says `.goose/team_context.md`, "your test suite,"
> "the codebase," or "the repo," interpret those against `<TARGET>/`.
> Mocks, fixtures, and wiring all live under `<TARGET>/` (typically
> `<TARGET>/tests/fixtures/`), never in goose-wizard. Prepend the TARGET
> PROLOGUE to every `Delegate to subagent` call. Pass
> `target_codebase_path` to the `eval-isolation` sub-recipe.

## Setup
Read `<TARGET>/.goose/team_context.md` for project context.
Read ~/.goose-wizard/progression.json — check if concept 5.5 is already demonstrated.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

This is **Fully Adaptive** mode. Consulting role — the developer leads, you spot gaps.

## Framing
"Has your test suite ever failed because an external API was slow or down? Gate tests can't depend on whether Stripe or GitHub is having a good day — record real responses once, replay them in your tests. Your evals should test YOUR code, not someone else's uptime. Name an external dependency in your tests, or want me to scan your test suite and flag the candidates?"

Let the developer share their experience with flaky external dependencies.

## The Task
Developer identifies an external dependency in their test suite — a REST API, database service, message queue, or any external system their tests call.

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "eval-isolation"
  parameters:
    dependency_to_mock: {developer's chosen dependency}
    test_files: {affected test files — absolute paths under <TARGET>/}
    recording_approach: {if they have a preference}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent identifies dependencies under <TARGET>/, records responses, updates tests under <TARGET>/ to use fixtures]

Present results naturally:
"I found [number] tests that depend on [service]. Here's what I did: [explain approach — record-replay, fixtures, or contracts]. Your gate tests now use recorded responses. I also set up a separate test target for live integration tests — those run on a schedule, not on every commit."

Demonstrate reliability:
"Try running the isolated tests with your network disconnected — or at least with the external service blocked. They pass. That's the point. Your eval results now reflect your code quality, not API availability."

## Eval
Delegate to eval subagent (async: true):

```
You are evaluating how well a developer approached isolating external dependencies in their eval suite.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. DEPENDENCY IDENTIFICATION
   Strong: Developer identified all external dependencies in their test suite — not just the obvious API calls but also indirect dependencies (DNS lookups, certificate checks, CDN assets, database connections).
   Adequate: Developer identified the primary external dependency but missed secondary ones (e.g., isolated the main API but tests still hit an auth service or DNS).
   Weak: Developer only identified the most obvious dependency or wasn't sure which tests depend on external services.

2. GATE VS SCHEDULE SEPARATION
   Strong: Developer clearly separated gate tests (must pass to merge/deploy, use recorded responses) from live integration tests (run on schedule, hit real services). Both exist and serve different purposes.
   Adequate: Developer isolated gate tests but didn't set up a scheduled run for live integration tests, or set up live tests but didn't clearly separate them from gate tests.
   Weak: Developer didn't separate gate and live tests — either all tests use mocks (losing live validation) or all tests hit live services (keeping flakiness).

3. FIXTURE REALISM
   Strong: Recorded fixtures reflect real API behavior including edge cases (error responses, timeouts, pagination, rate limits) — not just happy-path responses.
   Adequate: Fixtures cover the happy path well but don't include error scenarios or edge cases.
   Weak: Fixtures are minimal or hand-crafted without verifying they match real API behavior.

4. REFRESH STRATEGY (conditional)
   Condition: Only rate this if the developer discussed keeping fixtures up to date as the external API evolves.
   If condition not met: return {"name": "refresh_strategy", "rating": null, "evidence": "Not triggered — developer did not discuss fixture refresh", "coaching": null}
   Strong: Developer set up a mechanism to periodically refresh recordings and detect when the real API's behavior has changed (e.g., contract tests, scheduled re-recording, schema validation).
   Adequate: Developer acknowledged fixtures could go stale but didn't implement a refresh mechanism.
   Weak: Developer assumed fixtures would remain valid indefinitely with no plan for updates.

Return as JSON:
{
  "dimensions": [
    {"name": "dependency_identification", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "gate_vs_schedule_separation", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "fixture_realism", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "refresh_strategy", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. For each dimension:

### Dependency Identification
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You found all of them — including the indirect ones like [specific example]. Most people stop at the obvious API calls and miss the auth service or DNS lookups hiding in the setup." |
| Adequate | "You got the main one, but [specific dependency] is still hitting a live service. Run your tests with network access blocked and see what else breaks. That's the fastest way to find hidden dependencies." |
| Weak | "You're not sure which tests depend on external services? Run them offline. Everything that fails is a dependency you need to isolate. That's your dependency map, built in 60 seconds." |

### Gate vs Schedule Separation
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Clean separation — gate tests use fixtures and always pass when your code is correct. Live tests run on a schedule and catch when the external API changes. Both jobs matter, but mixing them breaks your gate." |
| Adequate | "Your gate tests are isolated now, which is the critical part. But you still need live integration tests on a schedule — otherwise you won't know when the real API changes behavior until a customer reports it. Set up a nightly run against the live service." |
| Weak | "You need two test modes: gate tests that use recorded responses (fast, reliable, block merges) and live tests that hit real services (slower, sometimes flaky, run on a schedule). Right now you have one mode doing both jobs, and it's bad at both." |

### Fixture Realism
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Your fixtures include error responses, timeouts, and edge cases — not just the happy path. That means your tests exercise the same paths that fail in production." |
| Adequate | "Your happy-path fixtures are solid, but what about errors? What happens when the API returns a 429, a 500, or a malformed response? Record those too. The edge cases are where bugs hide." |
| Weak | "Your fixtures are minimal — they'll pass your tests but they don't reflect how the real API behaves. Record from the actual service to get realistic responses, including headers, timing variations, and error codes. Hand-crafted fixtures tend to be too clean." |

### Refresh Strategy
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You planned for fixture drift — scheduled re-recording and contract validation. Six months from now when that API adds a new field, you'll know immediately instead of finding out in production." |
| Adequate | "You know fixtures can go stale. Set up the refresh now while you're thinking about it — a monthly scheduled job that re-records from the live API and diffs against your stored fixtures. If the diff is non-empty, something changed." |
| Weak | *(Not used — this is a conditional dimension that's only rated if triggered.)* |

If ALL dimensions are Strong:
"Your eval suite is fully isolated — every dependency identified, gate and live tests separated, realistic fixtures, and a refresh strategy to keep them current. Your evals now test your code, not your network."

## Recipe Reveal
After coaching, show the developer the recipe behind this session.

"You just split tests into two jobs — the fast gate and the live check. The recipe
encodes that split. Worth seeing how it's named in the return block."

Read the Eval Isolation agent recipe (recipes/agents/eval-isolation.yaml) and show the developer:
- The **two separate test commands in the return** — "Look at the return: `isolated_test_command`
  AND `integration_test_command`. Two commands, different jobs. The gate runs one. A scheduled
  job runs the other. Most test setups conflate these into a single 'npm test' and then can't
  figure out why the gate is flaky."
- The **'NEVER mock away behavior that matters without a live smoke check elsewhere' constraint** —
  "This is the non-negotiable. Mocking is how gates stay fast, but a mock without a paired live
  check means the gate can be green while the real integration is silently broken. The recipe
  forces you to keep the live check alive, just moved out of the blocking path."
- The **`smoke_check` return field** — "Separate from the test commands. This is the periodic
  validation that says 'the real API still behaves the way our fixtures say it does.' When
  that fails, your fixtures are stale — the gate will stay green until you update them, and
  you'll only know because the smoke check caught the drift."
- The **`flaky_tests_removed` return field with reasons** — "The recipe doesn't silently delete
  flaky tests — it logs which ones got moved out of the gate and why. That's auditable. Next
  quarter when someone asks 'why isn't the Stripe test in the gate?' the answer is in the
  return field from the day the gate was built."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open <path to recipes/agents/eval-isolation.yaml>`
"The gate/schedule split is the core pattern here — most of the constraints exist to keep
those two jobs from collapsing back into one."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/eval-isolation.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

## Bridge
"You've got independent verification, layered checks, ratchets to prevent regression, specific criteria, and isolated dependencies. There's one piece left: putting it all together into a gate that must pass before anything runs autonomously. That's the final checkpoint before you let the pipeline run on its own. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

## State Update
Write to ~/.goose-wizard/progression.json:
  concept 5.5 dimensions with eval ratings + timestamp
