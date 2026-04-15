# Recipe 5.5: Eval Isolation — "Mock external dependencies"

## Setup
Read .goose/team_context.md for project context.
Read ~/.rilgoose/progression.json — check if concept 5.5 is already demonstrated.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

This is **Fully Adaptive** mode. Consulting role — the developer leads, you spot gaps.

## Framing
"Has your test suite ever failed because an external API was slow or down? Not because your code was wrong — just because something outside your control decided not to respond?"

Let the developer share their experience with flaky external dependencies.

"That's the isolation problem. Your gate tests — the ones that block a merge or deploy — can't depend on whether Stripe or GitHub or your internal auth service is having a good day. Record real responses once, replay them in your tests. Your evals should test YOUR code, not someone else's uptime."

## The Task
Developer identifies an external dependency in their test suite — a REST API, database service, message queue, or any external system their tests call.

Delegate to code-work subagent:
  sub-recipe: "eval-isolation"
  parameters:
    dependency_to_mock: {developer's chosen dependency}
    test_files: {affected test files if they know them}
    recording_approach: {if they have a preference}

[Subagent identifies dependencies, records responses, updates tests to use fixtures]

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

## Bridge
"You've got independent verification, layered checks, ratchets to prevent regression, specific criteria, and isolated dependencies. There's one piece left: putting it all together into a gate that must pass before anything runs autonomously. That's the final checkpoint before you let the pipeline run on its own."

## State Update
Write to ~/.rilgoose/progression.json:
  concept 5.5 dimensions with eval ratings + timestamp
