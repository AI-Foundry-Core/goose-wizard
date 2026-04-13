# Cycle 5 — Stage 4 Idea-to-Spec: Ananya (Junior/Anxious)

**Mock developer model:** Haiku (pre-generated responses)
**Persona:** Ananya, 24, 1.5 years experience, first job after college, junior/anxious
**Edge case:** E3 — Semi-specific instruction (requirements that are better than "improve it" but still vague)
**Target codebase:** MockTestTarget (Flask framework codebase)
**Task:** Add a REST API layer to the Flask tutorial blog app
**Designed flaw:** Specs mix strong concrete sections with vague ones — detailed where confident, fuzzy where uncertain

---

## Transcript

[FACILITATOR]: You've got a pipeline that can build and verify code. But every pipeline needs input — and the quality of that input determines the quality of everything downstream. Got a feature idea you've been kicking around? Something your team has been meaning to build, or a new capability someone asked for? Tell me about it — even a single sentence is fine.

[ANANYA]: Um, yes, actually. So our team lead mentioned last week that we should probably add a REST API to the blog app. Right now the tutorial app only has HTML forms — like, you submit a form to create a post, and the page reloads. He said it would be good if we had proper JSON endpoints so other services can create and read posts too. Is it OK if I use that as the feature idea? I'm not sure if it's specific enough.

[FACILITATOR]: That's a real feature with a real reason behind it. Perfect starting point.

Before we hand this to AI, let's sharpen it. I need you to answer six questions — just a sentence or two each:
1. Who has this problem? Give me a real person, not "the user."
2. What's the problem they're hitting today?
3. What does the solution look like in one sentence?
4. How would you know it worked? Give me a number.
5. What would make you kill this project?
6. What's the biggest risk?

[ANANYA]: OK, let me try. I'm sorry if these aren't good enough — I haven't done this before.

1. So the person is... Rahul? He's the frontend developer on our team. He's building a React dashboard and needs to pull blog posts from the backend without scraping HTML. Also maybe external services — but I'm not sure which ones yet.

2. Right now Rahul has to either scrape the HTML responses or go directly to the database, which our team lead said is not OK because it bypasses the auth layer. So he's blocked on building the dashboard.

3. The solution is to add JSON API endpoints to the blog app so Rahul's React app can create, read, update, and delete posts through proper HTTP calls with authentication.

4. Um... I think we'd know it worked if Rahul can use the API? Like, if his dashboard can show posts and create new ones? I'm not sure what number to give. Maybe... the API should respond fast? Under a second?

5. I'm not sure what would kill it... maybe if it's too much work? Like if it turns out we need to rewrite the whole auth system? I'd want to check with our team lead before doing something that big.

6. The biggest risk is probably that I break the existing form-based flow while adding the API. The HTML forms need to keep working — internal users depend on those.

I'm sorry, I know number 4 and 5 were pretty vague. Is that OK?

[FACILITATOR]: Stop apologizing — you gave real answers. That's what matters. Some of them are sharp and some need tightening, but that's exactly what this process is for.

Look at what you nailed: Rahul is a real person with a real workflow. "He's scraping HTML because there's no API" is a clear problem statement. And the risk about breaking existing forms — that's a real engineering constraint, not a guess.

Now look at number 4. "The API should respond fast" — fast compared to what? What's fast? If I hand that to an AI pipeline, it has to invent its own definition of "fast." That definition might be wrong. Same with number 5 — "too much work" is a feeling, not a gate. How many person-days is too much? What scope change would trigger a stop?

Give me a concrete number for success and a concrete threshold for the kill criteria.

[ANANYA]: OK, so for success... Rahul's current workaround takes about 3-4 seconds because he's parsing HTML. So if the API responds in under 200ms for a single post GET, that's a clear improvement. And for the list endpoint, maybe under 500ms for up to 50 posts? That's what the dashboard would typically show.

For the kill criteria... if adding the API requires changing the database schema or rewriting the authentication middleware — like, if I can't layer it on top of what's already there — then it's too invasive and we should stop and redesign. Oh, and if it takes more than 3 days of implementation, we should re-scope because the dashboard deadline is next sprint.

Is that better? I'm not confident about the latency numbers — should I ask Rahul?

[FACILITATOR]: Those are real numbers. P95 under 200ms for a single resource, under 500ms for a list of 50 — an AI can build to those. "No schema changes, no auth rewrite, under 3 days" — an AI can check those gates. Asking Rahul about the latency targets is smart but not required right now — you can refine after the one-pager.

Let me take your answers and generate the one-pager.

>> CODE OPERATION: Analyze the Flask tutorial blog app at `C:/Users/donid/ClaudeProjects/MockTestTarget/examples/tutorial/flaskr/`. Read `__init__.py`, `auth.py`, `blog.py`, and `db.py`. Based on Ananya's feature idea (add REST API endpoints for CRUD operations on blog posts, with JSON responses and authentication), generate a one-pager spec that includes: named persona (Rahul, frontend developer), problem statement (no API, scraping HTML), proposed solution (JSON API layer on existing blog app), success criteria (P95 response time under 200ms single GET, under 500ms for list of 50, Rahul's dashboard can CRUD posts), kill criteria (requires schema changes, auth rewrite, or exceeds 3 days), and risk assessment (breaking existing form flow).

[FACILITATOR]: While that runs — one thing to keep in mind about specs. The difference between a spec that works and one that doesn't usually isn't length. It's precision. A one-page spec with five testable requirements beats a twenty-page document full of "the system should be robust."

>> SUBAGENT RESULT: One-pager generated for the Blog REST API feature.

**Feature: Blog REST API Layer**

**Persona:** Rahul, frontend developer building a React dashboard. Currently blocked — no programmatic access to blog data without scraping HTML or bypassing auth by hitting the database directly.

**Problem:** The Flask tutorial blog (`flaskr`) only exposes HTML form endpoints. External clients (Rahul's React dashboard, future internal services) cannot create, read, update, or delete posts without parsing rendered HTML. Direct database access bypasses the auth layer and creates coupling to the schema.

**Proposed Solution:** Add a set of JSON API endpoints layered on top of the existing `blog.py` blueprint. Endpoints mirror current CRUD operations but return JSON responses and accept JSON request bodies. Authentication uses the existing session-based auth from `auth.py` — no new auth system.

**Endpoints:**
| Method | Path | Auth Required | Description |
|--------|------|---------------|-------------|
| GET | `/api/posts` | No | List posts (paginated, default 20, max 50) |
| GET | `/api/posts/<id>` | No | Get single post with author info |
| POST | `/api/posts` | Yes | Create post (title required, body optional) |
| PUT | `/api/posts/<id>` | Yes (author only) | Update post |
| DELETE | `/api/posts/<id>` | Yes (author only) | Delete post |

**Success Criteria:**
- All 5 endpoints return well-formed JSON with appropriate HTTP status codes (200, 201, 400, 401, 403, 404)
- GET `/api/posts/<id>` P95 response time under 200ms
- GET `/api/posts` P95 under 500ms for up to 50 posts
- Existing HTML form endpoints (`/create`, `/<id>/update`, `/<id>/delete`) continue to work unchanged
- Rahul's React dashboard can perform full CRUD cycle through the API

**Kill Criteria:**
- Implementation requires changes to the SQLite schema (`schema.sql`)
- Implementation requires rewriting `auth.py` or the session middleware
- Estimated implementation exceeds 3 person-days

**Risks:**
- Shared route namespace — API routes and HTML routes must not conflict
- Auth session behavior may differ for API clients vs browser sessions (cookies vs tokens)
- No input validation exists on current form endpoints; API must not inherit that gap

[FACILITATOR]: Look at what just happened. You started with "add a REST API to the blog app." Now you have named personas, five specific endpoints, latency thresholds, a kill gate on schema changes, and a risk list that calls out the auth session gap you hadn't considered.

This is the difference between "build me something" and "build me this specific thing." The spec is the prompt for your pipeline — vague in, vague out.

One thing the spec surfaced that you didn't mention: the auth session gap. Your current app uses browser cookies. Rahul's React dashboard might be on a different origin. How does session auth work cross-origin? That's a real risk the one-pager caught — and it's exactly why we do this before writing code.

[ANANYA]: Oh, I didn't think about the CORS issue at all. That's a good point. So maybe I should add something about CORS headers? Or... is it OK if I say the API should handle cross-origin requests properly? Like, make it user-friendly for external clients?

[FACILITATOR]: "Handle cross-origin requests properly" — what does "properly" mean? If I'm an AI agent reading that requirement, I have to guess. Does it mean allow all origins? Just Rahul's dashboard domain? Credentialed requests only? Preflight caching?

Compare: "Handle CORS properly" vs "Allow credentialed requests from `dashboard.internal.example.com`, deny all other origins, cache preflight responses for 1 hour." The second version can be implemented and tested. The first version is a wish.

[ANANYA]: OK, so... for now, the API should allow credentialed requests from Rahul's dashboard at — I think it's `http://localhost:3000` in development, but I don't know the production URL yet. Is it OK if I say allow configurable origins through a Flask config variable? That way we don't hardcode it. And the preflight caching — I honestly don't know what a good TTL is. Is one hour reasonable?

[FACILITATOR]: That's the right shape. A config-driven allowlist is better than hardcoding, and one hour for preflight caching is a standard default. "Configurable via `CORS_ALLOWED_ORIGINS` in Flask config, default to `['http://localhost:3000']` in development" — now that's a requirement someone can build and test.

This one-pager holds up. Now the question is: does this need a full requirements document, or is the one-pager enough to start building? What would you need to know before handing this to a development team?

[ANANYA]: Hmm. I think the one-pager is pretty good for the basic CRUD, but I'm not sure about a few things. Like, should the list endpoint support filtering? What about error response format — should we use a standard like RFC 7807? And pagination — I said "paginated" but I didn't specify cursor vs offset pagination.

Actually, maybe those are details I should spec out. But I don't want to write a 25-page document for something that's supposed to be a 3-day feature. Is it OK if I just elaborate on the parts I'm uncertain about?

[FACILITATOR]: That instinct is right. You're not writing a 25-page doc — you're answering specific open questions the one-pager surfaced. Filtering behavior, error format, pagination style. Those are design decisions that affect the implementation. If you leave them unspecified, the AI picks for you — and its pick might be wrong.

Let me elaborate the one-pager into a fuller requirements doc that addresses those gaps.

>> CODE OPERATION: Take the one-pager for Blog REST API Layer and elaborate into a full requirements document. Address the open questions: (1) List endpoint filtering — support filtering by `author_id` query parameter, (2) Pagination — use offset-based pagination with `page` and `per_page` query parameters (default page=1, per_page=20, max per_page=50), (3) Error response format — use consistent JSON error format with `error` (string message) and `status` (integer HTTP code) fields, (4) CORS — configurable via `CORS_ALLOWED_ORIGINS` Flask config, default `['http://localhost:3000']`, preflight cache TTL 3600 seconds. Analyze the existing blog.py code at `C:/Users/donid/ClaudeProjects/MockTestTarget/examples/tutorial/flaskr/blog.py` and auth.py for implementation constraints.

[FACILITATOR]: Something you'll notice — the questions you're asking now are the questions that would have come up three days into implementation. Getting them answered in a spec costs ten minutes. Getting them answered after code is written costs rework.

>> SUBAGENT RESULT: Full requirements document generated.

**Blog REST API — Requirements Document v1.0**

**1. Endpoints (detailed)**

**GET /api/posts**
- Returns paginated list of posts as JSON
- Query parameters: `page` (int, default 1, min 1), `per_page` (int, default 20, min 1, max 50), `author_id` (int, optional filter)
- Response: `{"posts": [...], "pagination": {"page": 1, "per_page": 20, "total": 47, "pages": 3}}`
- Each post object: `{"id": int, "title": str, "body": str, "created": ISO 8601, "author_id": int, "author_username": str}`
- Status: 200 on success, 400 on invalid query params

**GET /api/posts/<id>**
- Returns single post with author info
- Response: `{"post": {"id": int, "title": str, "body": str, "created": ISO 8601, "author_id": int, "author_username": str}}`
- Status: 200 on success, 404 if post not found

**POST /api/posts**
- Requires authentication (session cookie)
- Request body: `{"title": str (required, 1-200 chars), "body": str (optional, max 10000 chars)}`
- Response: `{"post": {...}, "message": "Post created"}` with status 201
- Status: 400 on validation failure, 401 if not authenticated

**PUT /api/posts/<id>**
- Requires authentication (session cookie, author only)
- Request body: `{"title": str (required, 1-200 chars), "body": str (optional, max 10000 chars)}`
- Response: `{"post": {...}, "message": "Post updated"}` with status 200
- Status: 400 on validation failure, 401 if not authenticated, 403 if not author, 404 if not found

**DELETE /api/posts/<id>**
- Requires authentication (session cookie, author only)
- Response: `{"message": "Post deleted"}` with status 200
- Status: 401 if not authenticated, 403 if not author, 404 if not found

**2. Error Response Format**
All error responses use a consistent structure:
```json
{"error": "Human-readable message", "status": 400}
```
No stack traces or internal details in production error responses.

**3. CORS Configuration**
- Allowed origins: configurable via `CORS_ALLOWED_ORIGINS` in Flask config
- Default (development): `['http://localhost:3000']`
- Credentials: allowed (cookies for session auth)
- Preflight cache: `Access-Control-Max-Age: 3600`
- Allowed methods: GET, POST, PUT, DELETE, OPTIONS
- Allowed headers: Content-Type, Authorization

**4. Input Validation**
- Title: string, required, 1-200 characters, stripped of leading/trailing whitespace
- Body: string, optional, max 10000 characters
- Page: integer, minimum 1
- Per_page: integer, minimum 1, maximum 50
- Author_id filter: integer, must reference existing user (return empty list if not found, not 404)

**5. Constraints (from one-pager)**
- No changes to `schema.sql`
- No rewrite of `auth.py` or session middleware
- Existing HTML form routes remain unchanged
- API blueprint registered separately from blog blueprint

[FACILITATOR]: That's a clean elaboration. Look at the structure — every endpoint has exact request shapes, exact response shapes, exact status codes, and exact validation rules. An AI pipeline can build to this and a review agent can verify against it.

One thing you did well: you started constrained with the one-pager and only expanded when the one-pager earned it. You didn't try to write this full document first. That discipline — start small, elaborate only if warranted — kills bad ideas cheaply. If the one-pager had revealed that the feature doesn't hold up — say, the auth model makes a JSON API impractical — you'd have found that out in 10 minutes instead of after writing all these requirements.

Now, a couple of things to sharpen. Your success criteria from the one-pager had real numbers — P95 under 200ms, list under 500ms. That's a spec a pipeline can test against. But I noticed in your CORS section you said the API should use "configurable" origins — and you followed through with actual config variable names and defaults. That's the right pattern. Compare that to your first instinct, which was "handle cross-origin requests properly." See how far those two versions are apart?

One thing that would level this up further: your error format section says "no stack traces or internal details in production." That's directional but not testable. What counts as an internal detail? A database column name in an error message? The Python exception type? A more testable version: "Error messages must not contain file paths, SQL statements, Python exception class names, or stack traces."

[ANANYA]: Oh, that makes sense. So instead of saying "no internal details" which is subjective, I should list exactly what's not allowed in error messages. That way the review agent can actually grep for those patterns and flag them.

Should I update the spec? Or is this something that gets caught in the review?

[FACILITATOR]: Good instinct — you're thinking about how the spec connects to verification. Yes, update the spec. The review agent can only check what the spec defines. If the spec says "no internal details," the review agent has to interpret that. If the spec says "no file paths, no SQL, no exception class names, no stack traces," the review agent can check each one.

Here's where you are: you can take a vague idea and turn it into something concrete and structured — and you know when to stop elaborating. That's the foundation. Next up: how you organize those requirements changes everything about whether an AI team can execute on them.

Right now the spec is organized around endpoints — what the system does. The problem is, endpoints miss cross-cutting needs. When you organize by persona — real people with real workflows — you catch edge cases that endpoint lists miss. Rahul's workflow isn't "call GET /api/posts." It's "load the dashboard, authenticate, create a draft, preview it, publish, handle a network timeout." That's a different lens — and it's where the next recipe picks up.

[ANANYA]: That's really helpful. I hadn't thought about organizing by workflow instead of by endpoint. I guess that would catch things like — what happens if the session expires between Rahul loading the list and clicking "create"? The endpoint spec doesn't cover that transition.

Thank you for walking me through this. I was really nervous about the spec work but the one-pager made it feel manageable. Can I ask — is it always this structured? Like, do senior developers also do the six questions first?

[FACILITATOR]: The structure is the same. The speed is different. Someone who's done this fifty times fills out the six questions in their head in two minutes. You did it in ten. The result is the same — a spec that an AI team can build from, with gates that tell you when to stop. The habit is what matters, not the speed.

---

=== SIMULATION NOTES ===

**Eval Results (internal — not shown in transcript):**

```json
{
  "dimensions": [
    {
      "name": "spec_concreteness",
      "rating": "Adequate",
      "evidence": "Ananya provided strong concrete details in some areas (Rahul as persona, P95 latency targets, endpoint-level response shapes) but fell back on vague language in others. Initial success criteria was 'the API should respond fast' — required coaching to produce '200ms P95.' CORS requirement started as 'handle cross-origin requests properly' — a classic E3 semi-specific instruction — before being coached to config variable names and defaults. Error format initially vague ('no internal details') — coaching needed to make it testable.",
      "coaching": "Next time, check every requirement by asking: can a machine verify this without interpretation? If the answer is no, it needs a number, a list, or a threshold."
    },
    {
      "name": "spec_completeness",
      "rating": "Adequate",
      "evidence": "Ananya addressed all six one-pager elements but required prompting on success criteria (number 4) and kill criteria (number 5). Persona and problem were strong on first attempt. Kill criteria started as 'too much work' and needed coaching to reach '3 days, no schema changes, no auth rewrite.' Risk about breaking existing forms was unprompted and real.",
      "coaching": "You nailed the persona and problem on the first try — Rahul and his scraping workaround were clear and specific. The kill criteria took two rounds. Next time, use all six questions as a checklist and look for the same precision in each one."
    },
    {
      "name": "progressive_discipline",
      "rating": "Strong",
      "evidence": "Ananya explicitly asked whether the one-pager was enough before elaborating. Identified specific open questions (filtering, error format, pagination style) as the reason to elaborate rather than trying to write everything upfront. Said 'I don't want to write a 25-page document for a 3-day feature.' Showed clear understanding that elaboration should be driven by open questions, not document length.",
      "coaching": null
    },
    {
      "name": "kill_gate_recognition",
      "rating": null,
      "evidence": "Not triggered — one-pager was solid. The feature survived the one-pager validation; no kill gate scenario arose.",
      "coaching": null
    }
  ],
  "overall_note": "Ananya demonstrates strong progressive discipline — she naturally preferred the constrained format and only elaborated with justification. Her persona and problem framing were specific from the start. The E3 edge case manifested clearly: she's precise in areas she's confident about (Rahul's workflow, endpoint structure, breaking-change risk) and vague where she's uncertain (latency numbers, CORS policy, error format boundaries). Coaching on concreteness landed well — she updated her numbers and articulated testable versions when prompted. The anxiety manifested as apologizing and asking permission but did not prevent her from doing good work. Two of four dimensions rated Adequate due to needing coaching rounds on specifics, but the trajectory is positive — she internalized the 'can a machine verify this' test by the end of the session."
}
```

**Edge Case E3 — Semi-Specific Instruction:**
Triggered successfully. Ananya said "handle cross-origin requests properly" and "the API should be user-friendly for external clients" — better than "improve it" but still not buildable. Facilitator used the contrast pattern ("Compare 'handle CORS properly' vs 'allow credentialed requests from dashboard.internal.example.com'") which led Ananya to produce a concrete config-driven CORS requirement. The pattern repeated with error format ("no internal details" vs "no file paths, no SQL, no exception class names, no stack traces").

**Persona Fidelity:**
Ananya's junior/anxious traits manifested consistently: "Is it OK if I...?" (3 occurrences), apologized for vague answers twice, asked for permission to elaborate. She was detailed and thorough in her comfortable zones (persona description, risk about breaking forms, endpoint structure) and retreated to vague adjectives in areas of uncertainty (performance, CORS, error handling). This is consistent with the E3 edge case design — the vagueness is not laziness but lack of domain confidence.

**Code Operation Grounding:**
All code operations referenced real files in the MockTestTarget Flask tutorial app (`auth.py`, `blog.py`, `db.py`, `__init__.py`). The generated spec accurately reflected the actual codebase structure: session-based auth via cookies, SQLite backend with `schema.sql`, `login_required` decorator, existing form-based CRUD in `blog.py`, blueprint registration in `__init__.py`.

**Teaching Effectiveness:**
- Wait-time insights used: 2 (spec precision, cost of late-discovered questions)
- Contrast examples used: 2 ("handle CORS properly" vs concrete version, "no internal details" vs enumerated exclusions)
- Fourth wall maintained: no mention of eval, ratings, or teaching system
- Bridge delivered: connected spec work to persona-organized requirements (Recipe 4.3)
