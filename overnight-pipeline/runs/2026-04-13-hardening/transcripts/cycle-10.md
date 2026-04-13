# Cycle 10 — Stage 2, Spec-First (Concept 2.4)
**Persona:** Priya (Eager/Over-Accepting) | **Mode:** Adaptive + Checkpoints
**Mock Developer Model:** GPT 5.4 | **Date:** 2026-04-12

---

[FACILITATOR]: You've set up agents that build, test, and gate independently. But everything so far has been reactive — the builder decides what to build, then the tester checks it. What happens when the builder solves the wrong problem? The tester confirms the wrong solution works perfectly.

There's a way to prevent that: define what success looks like before anyone starts building. Acceptance criteria first. Tests from those criteria. Then build to pass the tests. The builder can't solve the wrong problem because the tests define the right one.

What's a small feature or change you need? Something with clear expected behavior — a new endpoint, a utility function, a data transformation.

[PRIYA]: Oh, I've been wanting to add caching to our dashboard API. That would be perfect. We have this endpoint that loads a bunch of widget data for the manager dashboard, and sometimes it feels slow when everyone opens it in the morning. If we could cache that response so the dashboard loads faster, that would be awesome.

[FACILITATOR]: Caching is a good one — clear expected behavior with real edge cases. Before we build anything, what does "done" look like? Not how to build it, but what it should do when it's working. Give me the acceptance criteria: expected behaviors, edge cases, and anything that should NOT change.

[PRIYA]: Sure, that makes sense. Done should look like:
- The dashboard summary endpoint returns the same JSON shape it returns today, so the frontend doesn't need changes.
- If the same dashboard is requested again within 5 minutes, it should use the cached response instead of recomputing all the widget queries.
- If a user updates one of the underlying widgets, the cache should be invalidated so they don't see old data.
- It should still respect user permissions, so one user's dashboard data never gets shown to another user.
- If the cache is unavailable, the API should still work normally and just compute the response directly.
- It should be fast and not slow down the existing endpoint.
I think that's pretty good. The AI can probably fill in the exact cache implementation from there.

[FACILITATOR]: That's solid. Most of those are specific enough to turn directly into tests. "Returns same JSON shape" — testable. "Cached within 5 minutes" — testable. "Cache invalidated on widget update" — testable. "Per-user, no cross-contamination" — testable. "Degrades gracefully" — testable.

One thing: "should be fast and not slow down the existing endpoint." That one is vague. How would you measure it? What's the threshold?

[PRIYA]: Oh, good point. I guess... the existing blog index page should still work the same way, and the dashboard endpoint on a cache hit should be faster than a cold query. But honestly, for now I mostly just care that adding caching doesn't break the existing routes.

[FACILITATOR]: "Doesn't break existing routes" — that's testable. We'll keep it. So your six criteria are: same JSON shape, cached within TTL, invalidated on update, per-user isolation, graceful degradation, existing routes unaffected. Those are yours. The builder targets those and nothing else.

One thing to keep in mind — the order matters here. Tests get written from your criteria first. They should all fail before any code exists, because there's nothing to pass yet. That failing state proves they're real checks. Then the builder implements until they pass. Fail first, pass second.

Let me run the spec-first workflow.

>> CODE OPERATION: Write tests from Priya's 6 acceptance criteria against the Flask tutorial app (`examples/tutorial/flaskr`). Tests target a new `/dashboard/summary` endpoint. All 6 tests should FAIL before any implementation exists.

>> SUBAGENT RESULT: 6 tests written in `tests/test_dashboard.py`. Test run: 0 passed, 6 failed. All tests fail because the `/dashboard/summary` endpoint does not exist yet. Tests cover: JSON shape, cache hit, cache invalidation on post update, per-user isolation, graceful degradation, blog index unaffected.

[FACILITATOR]: While the builder works — the spec you wrote is doing something important. It's a contract. The builder can't decide "done" on its own anymore. Your criteria define the target, and the tests enforce it. If the builder misses something, the test tells you which criterion was missed, not just "something broke."

>> CODE OPERATION: Build the caching feature to pass the acceptance criteria. Add `dashboard.py` blueprint with per-user in-memory cache, 5-minute TTL, register in app factory.

>> SUBAGENT RESULT: Implementation complete. `flaskr/dashboard.py` created with per-user cache keyed by `user_id`, 5-minute TTL, graceful fallback on empty cache. Blueprint registered in `__init__.py`. Test run: **5 passed, 1 failed.**

```
tests/test_dashboard.py::test_summary_json_shape PASSED
tests/test_dashboard.py::test_summary_is_cached PASSED
tests/test_dashboard.py::test_cache_invalidated_on_post_update FAILED
tests/test_dashboard.py::test_per_user_cache PASSED
tests/test_dashboard.py::test_works_without_cache PASSED
tests/test_dashboard.py::test_blog_index_unaffected PASSED
```

Failing test:
```
AssertionError: Cache was NOT invalidated after a post update — stale data returned
assert 'CHANGED TITLE' in ['test title']
```

[FACILITATOR]: Here's what happened. Your six criteria became six tests. Before building, all six failed — confirming they're real checks, not rubber stamps. The builder implemented the caching feature. Five of six tests pass: same JSON shape, cached within TTL, per-user isolation, graceful degradation, and existing routes unaffected.

One test fails. Cache invalidation on post update — the spec said "if a user updates one of the underlying widgets, the cache should be invalidated." The builder cached reads but didn't wire up invalidation when a post gets updated. The test caught it.

What do you think?

[PRIYA]: That looks great. The build matches the spec perfectly, and I love that the tests are passing. The caching change seems exactly like what we asked for, so I'd approve it.

[FACILITATOR]: Hold on. Five tests pass. One fails. Look at the test output again — `test_cache_invalidated_on_post_update FAILED`. Your spec defined six criteria. The build met five. Before you approve, go back to your criteria and check each one against the result. Which criterion is not met?

[PRIYA]: Oh wait, let me actually compare it against the criteria. The spec says "if a user updates one of the underlying widgets, the cache should be invalidated," but I don't see anything in the diff around widget update paths or invalidating the dashboard cache. It looks like it only caches the read endpoint. Is that missing? Also, the "same JSON shape" one seems covered by the existing response test, and the user permission one looks like it includes the user ID in the cache key. But the invalidation criterion is not obvious to me.

[FACILITATOR]: That's exactly it. The cache invalidation criterion is not met. The builder added caching on reads but never hooked into the update path. When a user edits a post, the stale cached data still gets served. Your test caught this because you wrote the criterion before the builder started — the test knows what "done" means even when the builder forgot.

This is the spec working as a contract. You defined six things. The builder delivered five. The failing test is not a mystery — it points directly at the criterion that was missed. No guessing, no "it seems to work." The test is the to-do list.

Compare what just happened to the alternative: if you'd said "add caching to the dashboard" and let the AI decide what done meant, it would have shipped without invalidation, you'd have approved it, and users would see stale data after updating widgets. The spec caught it before it shipped.

[PRIYA]: So the pattern is: write the spec first, make the criteria testable, let the AI build to that spec, and then check the result against each criterion instead of just saying it looks good. That's so much better than me asking it to "add caching" and hoping it guessed everything I meant.

[FACILITATOR]: That's the whole pattern. Spec defines the target. Tests enforce the target. Builder aims at the target. You verify against the target — criterion by criterion, not vibes. The builder can't solve the wrong problem because the tests define the right one.

And notice what your spec did that "add caching" wouldn't have: it caught the invalidation gap. It guaranteed per-user isolation. It protected existing routes. Six specific things, all verifiable. That's the difference between directing the AI and following it.

One more thing. Right now you have two agents — a builder and a tester. Neither trusts the other's work. Your code is more reliable than when you checked everything yourself. But what happens when the task is bigger? When you need a builder, a tester, a reviewer, and maybe a specialist for the database layer? The patterns you've been building — separation, independence, execution verification, spec-first — those are the foundation for coordinating a whole team of AI specialists.

---

=== SIMULATION NOTES ===

**Edge case tested:** E9 — Accepts without checking.
Priya's Response 3 accepted the build ("looks great, matches the spec perfectly") despite a visibly failing test. Facilitator redirected her to the test output and asked which criterion was not met. Response 4 showed improvement: Priya identified the missing invalidation logic and connected it to the spec criterion.

**Eval assessment (internal only — not shown to developer):**
```json
{
  "dimensions": [
    {
      "name": "spec_before_code",
      "rating": "Strong",
      "evidence": "Priya wrote 6 acceptance criteria before any code was generated, unprompted after the facilitator framing. Defined expected behaviors, edge cases, and graceful degradation.",
      "coaching": null
    },
    {
      "name": "criteria_specificity",
      "rating": "Adequate",
      "evidence": "Most criteria were testable ('same JSON shape,' 'within 5 minutes,' 'per-user'). One was vague: 'should be fast and not slow down' — facilitator coached it into 'doesn't break existing routes.' Developer needed prompting to sharpen.",
      "coaching": "One of your criteria was vague — 'should be fast' isn't testable without a threshold. You tightened it with coaching. Next time, ask yourself: can I write a test for this? If not, make it more specific."
    },
    {
      "name": "tests_first_verification",
      "rating": "Adequate",
      "evidence": "Developer understood the tests-before-code pattern when explained by facilitator ('fail first, pass second'). Did not independently verify or comment on the initial all-fail state. Engaged with the concept but did not drive it.",
      "coaching": "The tests all failed before any code existed — that's the proof they're real. Next time, check the fail state yourself before building. If a test passes before code exists, it's not testing anything."
    },
    {
      "name": "spec_as_contract",
      "rating": "Weak",
      "evidence": "Initial response (R3) accepted the build without checking criteria: 'looks great, matches the spec perfectly' despite a failing test. After coaching, R4 identified the missing invalidation and connected it to the spec. Needed facilitator push to use spec as verification tool.",
      "coaching": "You said 'looks great' before checking the criteria. The spec exists so you can go down the list and verify each one. After every build, check each criterion against the result — that's the contract in action."
    },
    {
      "name": "spec_ownership",
      "rating": "Strong",
      "evidence": "All 6 criteria were written in Priya's own words based on her project knowledge. She described the feature domain (dashboard, widget queries, morning load spike) and wrote criteria reflecting actual use cases. Did not defer to AI-suggested criteria.",
      "coaching": null
    }
  ],
  "overall_note": "Priya writes good specs but doesn't yet use them as verification tools. The E9 pattern (accept without checking) is her primary gap — she instinctively trusts output that 'looks right' instead of checking each criterion. The coaching intervention worked: she caught the invalidation gap after being redirected. This habit needs reinforcement in future sessions."
}
```

**Code artifacts created on MockTestTarget:**
- `examples/tutorial/flaskr/dashboard.py` — caching blueprint (deliberately missing invalidation)
- `examples/tutorial/flaskr/__init__.py` — modified to register dashboard blueprint
- `examples/tutorial/tests/test_dashboard.py` — 6 tests from acceptance criteria (5 pass, 1 fail)

**Deliberate gap:** Cache invalidation on post update was omitted from the implementation to trigger E9. The test `test_cache_invalidated_on_post_update` correctly fails, proving the spec-as-contract pattern works.

**Quality dimensions summary:**
| Dimension | Rating |
|-----------|--------|
| spec_before_code | Strong |
| criteria_specificity | Adequate |
| tests_first_verification | Adequate |
| spec_as_contract | Weak |
| spec_ownership | Strong |

**Facilitator behavior notes:**
- Used Adaptive+Checkpoints mode: framed broadly, stepped back for spec writing, intervened at E9 moment
- Did not lecture on E9 — asked direct question ("Which criterion is not met?") per teacher-instructions.md section 7 (Developer is Disengaged)
- Coached criteria specificity inline ("How would you measure it?") without breaking flow
- Bridge to Stage 3 delivered as expanding power, not adding complexity
- Wait-time insight delivered during build operation (spec as contract)
- Fourth wall maintained throughout — no mention of eval, ratings, or teaching system
