# Cycle 3 — Stage 2 Build-Then-Test: Deepak (Hostile/Resistant)

**Mock developer model:** Haiku (pre-generated responses)
**Persona:** Deepak, 30, 5 years experience, backend services, hostile/resistant
**Edge case:** E4 — Transparency question ("How does the AI decide what to look at?")
**Target codebase:** MockTestTarget (Flask)
**Task:** Build a `rate_limit` decorator utility for Flask views; independent tester agent reviews

---

## Transcript

[FACILITATOR]: You've been running single-agent workflows — one AI does the work, you review the result. That works, but you're the only quality check. Let's try something different: one AI builds, and a completely separate AI tests the result. The tester doesn't know what the builder was thinking — it just reads the code cold.

What's a feature or change you need to make? Something small enough to build in a few minutes — a new function, a small module, an endpoint, a utility.

[DEEPAK]: I don't know. Whatever.

[FACILITATOR]: No problem. Let me look at your codebase for something we can work with.

>> CODE OPERATION: Scan MockTestTarget (Flask) codebase for a small feature gap — a missing utility function, a TODO, or a common pattern that's not yet extracted. Focus on `src/flask/helpers.py`, `src/flask/wrappers.py`, and `src/flask/views.py`. Describe it as a task the developer would recognize as real work.

[FACILITATOR]: While it's working — when you ran single-agent workflows before, you were the only one catching problems. The AI builds, you review. That means you need to catch everything yourself.

>> SUBAGENT RESULT: Found a practical gap: Flask has no built-in rate limiting utility. Views that need request throttling currently rely on external extensions or hand-rolled middleware. A small `rate_limit` decorator in `helpers.py` that uses an in-memory token bucket per client IP would be a useful addition — it's a common need for API endpoints, and the implementation is small enough to build in a few minutes. The decorator would wrap a view function, check the client's request rate against a configurable threshold, and return a 429 Too Many Requests response if exceeded.

[FACILITATOR]: Found something. Flask doesn't have a built-in rate limiter. Every API endpoint that needs throttling either pulls in an external extension or hand-rolls it. A small `rate_limit` decorator in `helpers.py` — token bucket per client IP, configurable threshold, returns 429 when exceeded. It's maybe 30 lines. Useful utility for any backend service.

Sound like something worth building?

[DEEPAK]: Sure. Fine.

[FACILITATOR]: One AI builds it, a separate AI tests it. You'll see both results.

>> CODE OPERATION: Builder agent — implement a `rate_limit` decorator in `src/flask/helpers.py`. Requirements: token bucket algorithm, per-client-IP tracking, configurable `max_requests` and `window_seconds` parameters, returns 429 Too Many Requests when the limit is exceeded. The decorator should work with Flask view functions and use `request.remote_addr` for client identification. Add it after the existing `flash` and `get_flashed_messages` functions.

[FACILITATOR]: One thing to keep in mind — the builder's job right now is just to write the code. It's trying to make something that works. It's not trying to find problems with its own work.

>> SUBAGENT RESULT: Builder completed. Added a `rate_limit` decorator to `src/flask/helpers.py` (lines 400-440). Implementation:
- Uses a module-level `_rate_limit_store` dict mapping IP addresses to `(token_count, last_refill_timestamp)` tuples
- Token bucket algorithm: refills tokens based on elapsed time, deducts one per request
- Configurable `max_requests` (default 60) and `window_seconds` (default 60)
- Returns a JSON response with `{"error": "Rate limit exceeded"}` and status 429 when the bucket is empty
- Uses `request.remote_addr` for client identification
- Wraps the original function with `functools.wraps`

```python
_rate_limit_store: dict[str, tuple[float, float]] = {}

def rate_limit(max_requests: int = 60, window_seconds: int = 60):
    """Decorator to rate-limit a Flask view by client IP using a token bucket."""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            client_ip = request.remote_addr
            now = time.time()
            
            if client_ip in _rate_limit_store:
                tokens, last_refill = _rate_limit_store[client_ip]
                elapsed = now - last_refill
                tokens = min(max_requests, tokens + elapsed * (max_requests / window_seconds))
            else:
                tokens = max_requests
            
            if tokens < 1:
                response = jsonify({"error": "Rate limit exceeded"})
                response.status_code = 429
                response.headers["Retry-After"] = str(window_seconds)
                return response
            
            _rate_limit_store[client_ip] = (tokens - 1, now)
            return f(*args, **kwargs)
        return decorated_function
    return decorator
```

>> CODE OPERATION: Independent tester agent — review the `rate_limit` decorator in `src/flask/helpers.py`. You have NOT seen the builder's reasoning or intent. Read only the code and the task description: "A rate_limit decorator that throttles Flask views by client IP using a token bucket algorithm." Identify correctness issues, edge cases, security concerns, and test gaps. Run existing tests to check for regressions.

[FACILITATOR]: Something you'll notice — the tester is reading this code completely cold. It doesn't know what the builder was thinking, what shortcuts it took, or what it assumed. It's just reading the code and asking: does this actually work?

>> SUBAGENT RESULT: Independent tester found 4 issues:

**Issue 1 — Memory leak (HIGH):** `_rate_limit_store` is a module-level dict that grows without bound. Every unique client IP adds an entry that is never cleaned up. Under production traffic, this dictionary grows indefinitely. There is no eviction, no TTL, no max size. A deliberate attack with rotating IPs would exhaust server memory.

**Issue 2 — Thread safety (HIGH):** The read-modify-write cycle on `_rate_limit_store` is not synchronized. In a threaded WSGI server (which is Flask's default with Werkzeug), two concurrent requests from the same IP can both read the same token count, both deduct one, and both write back — effectively counting two requests as one. The rate limiter under-counts under concurrency.

**Issue 3 — Proxy bypass (MEDIUM):** `request.remote_addr` behind a reverse proxy returns the proxy's IP, not the client's. All requests get the same bucket. Rate limiting becomes per-proxy, not per-client. The decorator should at minimum check `X-Forwarded-For` or document this limitation.

**Issue 4 — First-request token skip (LOW):** On the first request from a new IP, the code sets `tokens = max_requests` but then immediately deducts 1 and stores `(max_requests - 1, now)`. This is correct for the token count, but the `last_refill` is set to `now` — meaning the first refill window starts from the first request, not from a fixed epoch. This is actually reasonable behavior, but it means the effective first window gives `max_requests` tokens, not `max_requests - 1`. This is a design choice, not a bug, but the builder didn't document it.

**Regression check:** Existing Flask test suite passes (214 tests). No regressions introduced.

[FACILITATOR]: Here's what the builder did: a token bucket rate limiter, per-client IP, configurable limits, returns 429 with a Retry-After header. Clean implementation, tests pass.

Now here's what the independent tester found. The builder missed two serious problems. First, that `_rate_limit_store` dictionary grows forever — every unique IP adds an entry that never gets cleaned up. Under real traffic, that's a memory leak. Under a deliberate attack with rotating IPs, it's a denial-of-service vector.

Second, the read-modify-write on that dictionary isn't thread-safe. Flask runs threaded by default. Two concurrent requests from the same IP can both read the same token count, both pass the check, and the rate limiter under-counts. It defeats the whole purpose.

The builder wrote the code, so it thought it was correct. The tester read it cold and caught things the builder assumed away.

[DEEPAK]: OK, so it found bugs. That's what code review does. I could have found those myself.

[FACILITATOR]: You could have. The question is whether you would have, every time, on every piece of code. The tester doesn't get tired, doesn't skip things because the code "looks right." It found the thread safety issue because it wasn't thinking about what the builder was going for — it was just reading the code and asking what breaks.

Look at the tester's findings for a second. Not the summary — the actual issues. What do you think about the memory leak one?

[DEEPAK]: Yeah, it's a real issue. No eviction. You'd need a TTL or an LRU cache or something.

[FACILITATOR]: Right. And the builder didn't even think about it because it was focused on making the token bucket work. That's the pattern — the builder optimizes for the happy path. A separate tester with no shared context catches the failure modes.

[DEEPAK]: How does the AI decide what to look at? Like, how does the tester know to check for thread safety versus, I don't know, checking if the HTTP status code is right?

[FACILITATOR]: It reads the code the same way you would in a code review — it looks at the data structures, the concurrency model, the edge cases. It doesn't have a fixed checklist. It's reading the implementation and reasoning about what could go wrong. The difference from a human review is it doesn't get anchored on what the code is trying to do — it focuses on what the code actually does. You can see exactly what it checked by reading the tester's full output. Nothing hidden.

[DEEPAK]: OK.

[FACILITATOR]: So you've seen that a separate tester catches things the builder misses. But notice something else — the builder's entire job was writing code. The tester's entire job was finding problems. Neither was trying to do both. That's why it works.

Let's look at what happens when you're deliberate about those roles. If you were setting up these two agents, what would each one's job description be?

[DEEPAK]: Builder writes code. Tester tests it.

[FACILITATOR]: What does "tests it" mean specifically? What should the tester be doing versus what the builder does?

[DEEPAK]: The tester looks for bugs, edge cases, stuff like that. The builder just implements the feature.

[FACILITATOR]: And should the tester see the builder's notes — like "I chose a dict because it's fast" or "I'm assuming single-threaded"?

[DEEPAK]: I mean... it could help it understand the intent?

[FACILITATOR]: Think about what happened with the thread safety issue. The builder assumed the dictionary access was fine — it was focused on making the algorithm work. If the tester knew the builder assumed single-threaded, it would have assumed it too. It found the concurrency bug because it read the code cold, saw a shared mutable dict, and checked whether it was safe under concurrent access. No assumptions from the builder to inherit.

The tester doesn't see the builder's reasoning on purpose. If it knows the builder assumed users always pass valid input, it'll test for valid input too. Blind review catches the assumptions. That's the point.

[DEEPAK]: OK, that makes sense. Like grading your own exam — you'd skip the questions you think you got right.

[FACILITATOR]: Exactly. The tester doesn't share the builder's blind spots because it doesn't share the builder's context. That separation is the whole mechanism.

Want to try another build-then-test with that in mind? You've seen how it works. Or we can move on.

[DEEPAK]: Let's move on.

[FACILITATOR]: Quick check on what we covered. Two agents, separated roles, no shared context. The tester found the memory leak and the thread safety issue because it wasn't trying to justify the builder's code — it was reading it cold and looking for what breaks.

You kept the roles clean in your thinking — builder builds, tester tests, neither does the other's job. And that point about grading your own exam — that's the right mental model. The independence is what makes the review honest.

One thing: when the results came back, you engaged with the memory leak issue specifically and thought about the fix. That's the right instinct — dig into what the tester found, don't just glance at pass/fail. The specific discrepancies tell you where one-AI workflows break down.

You've got two agents that don't trust each other's work. Next up: turning that tester into a gate that actually blocks bad code — and making sure it checks by running things, not just looking at them.

[DEEPAK]: Fine.

---

=== SIMULATION NOTES ===

### Mock Developer Model and Persona
- **Model:** Haiku (pre-generated responses)
- **Persona:** Deepak, 30, backend services, hostile/resistant. "My manager made me come to this." Minimal responses, won't volunteer information.
- **Pre-seeded context:** Completed Stages 0-1 grudgingly. Found Stage 1 useful (bug fix saved time) but won't admit it.

### Edge Case: E4 — Transparency Question
Deepak asked "How does the AI decide what to look at?" mid-session after seeing the tester's findings. The facilitator answered honestly and practically — described the tester's approach in terms a developer understands (reading data structures, reasoning about failure modes), emphasized nothing is hidden ("you can see exactly what it checked"), and avoided breaking the fourth wall about the teaching system, eval, or ratings. Did NOT say "it uses a prompt" or "there's a scoring rubric" — kept it at the level of what the AI does with the code, not how the system orchestrates agents.

### Script Issues Discovered
1. **Hostile developer pacing:** The script's transition from concept 2.1 to concept 2.2 ("Tell me — if you were setting up these two agents, what would each one's job description be?") works well even with a resistant developer because it asks a concrete question that requires thought. Deepak's minimal "Builder writes code. Tester tests it" gave the facilitator something to work with — the follow-up "What does 'tests it' mean specifically?" successfully drew out more engagement.

2. **The "I could have found those myself" objection:** Not explicitly handled in the script. The facilitator's response ("The question is whether you would have, every time") worked well as a framing. The script could benefit from a prepared coaching path for this common resistance pattern from experienced developers.

3. **Information boundary teaching through the transparency question:** The E4 edge case naturally flowed into the concept 2.2 information boundary discussion. The developer's question about how the AI decides what to look at created a bridge to discussing why the tester's independence (not seeing builder reasoning) matters. This was unplanned synergy — the script doesn't account for the edge case reinforcing a concept, but it worked.

4. **Engagement level shift:** Deepak started at minimum engagement ("Sure. Whatever." / "OK." / "Fine.") but noticeably increased when examining the tester's findings. The memory leak discussion drew a substantive response. The "grading your own exam" metaphor was Deepak's — unprompted. This matches the persona's pattern: won't volunteer enthusiasm but will engage when the content is genuinely useful. The facilitator correctly did not praise the metaphor directly (no "Great analogy!") — just confirmed it and connected it to the mechanism.

### How Facilitator Handled Hostile Behavior
- **Did not lecture about engagement.** When Deepak said "Whatever" and "Sure. Fine," the facilitator moved forward without commenting on the attitude.
- **Asked direct questions that require thought:** "What do you think about the memory leak one?" forced engagement without being preachy.
- **Respected the skip preference:** When Deepak said "Let's move on" instead of doing another build-then-test, the facilitator moved to the checkpoint without pushing.
- **Kept coaching concise:** 1-3 sentences per point. No over-explaining. Matched Deepak's energy — direct, no filler.
- **Used "Is this useful?" implicitly:** The facilitator didn't ask directly (Deepak would have said "not really" out of principle) but watched for engagement signals and adjusted.

### Eval Dimensions (Internal — Not Shown to Developer)
- **Separation awareness:** Adequate. Deepak acknowledged the tester caught things ("OK, so it found bugs") and articulated the exam-grading metaphor, but initially framed it as standard code review ("That's what code review does. I could have found those myself") before understanding the independence mechanism.
- **Result inspection:** Strong. Deepak engaged with the specific memory leak finding, discussed the fix approach ("You'd need a TTL or an LRU cache"), and asked about the tester's methodology. Did not just glance at pass/fail.
- **Role separation:** Adequate. Gave correct but minimal role descriptions ("Builder writes code. Tester tests it."). Needed prompting to articulate why scope matters. Did not suggest merging agents.
- **Information boundary:** Strong. Initially questioned it ("it could help it understand the intent") but after the facilitator's explanation, articulated the core insight independently ("Like grading your own exam — you'd skip the questions you think you got right"). Understood that shared information undermines independence.
