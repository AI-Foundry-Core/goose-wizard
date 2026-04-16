# goose-wizard Rollout Playbook

**Purpose:** The operational guide for rolling out the agentic development harness across Reliance development teams. The syllabus defines WHAT we teach. This playbook defines HOW we roll it out, measure success, and sell it internally.

**Status:** Stub — to be fleshed out after Stages 0-1 teaching content is built and piloted.

---

## Time Estimates

| Stage | Duration per Developer | Format |
|-------|----------------------|--------|
| 0 — See What AI Can Do | ~45-60 minutes | One session, 5 scripted acts |
| 1 — Get Real Work Done | ~20-30 min per recipe (4 recipes) | Can be spread across days |
| 2 — Two AIs Are Better Than One | TBD (estimate after pilot) | — |
| 3 — Build a Team of AI Specialists | TBD | — |
| 4 — From Idea to Buildable Spec | TBD | — |
| 5 — Trust But Verify | TBD | — |
| 6 — Let It Run While You Sleep | TBD | — |
| 7 — The System Gets Smarter | TBD | — |

**Stage 0 + 1 total:** ~3-4 hours per developer. Can be completed in one afternoon or spread across a week.

---

## ROI Metrics to Track

These are natural byproducts of recipe usage — not a separate measurement system.

### Per-Developer Metrics (captured by recipes)
- **Time to first AI-assisted fix** — how quickly a developer goes from Stage 0 to solving a real bug with AI
- **Bug fix speed** — time from bug description to verified fix (Stage 1.1)
- **Test coverage delta** — test count before/after using Test Writer recipe (Stage 1.2)
- **Review cycle time** — time from "review this PR" to actionable findings (Stage 1.3)
- **Refactor confidence** — pre/post test pass rate on refactored code (Stage 1.4)

### Per-Team Metrics (aggregated)
- **Adoption rate** — % of team that completed Stage 0, % actively using Stage 1 recipes weekly
- **Recipe usage frequency** — which recipes are used most, which are abandoned
- **Concept progression** — team average ratings (strong/adequate/weak) across Stage 1 dimensions
- **AI-assisted PRs merged** — PRs where at least one Stage 1 recipe was used in the workflow

### Director-Level Metrics (for budget/expansion conversations)
- **Developer hours saved per week** — estimated from recipe usage patterns
- **PR cycle time reduction** — before/after AI-assisted review
- **Test coverage improvement** — before/after AI-assisted test writing
- **Defects caught pre-merge** — findings from AI code review that would have shipped

---

## Manager Dashboard

Managers see concept-level progress, not exercise completion.

**Per developer:** "Priya: Stage 0 complete. Stage 1: Bug Fix (strong), Test Writer (adequate), Code Review (not started), Refactor (not started)."

**Per team:** "Team Backend-Payments: 8/10 developers completed Stage 0. 5/10 active in Stage 1. Average Stage 1 rating: 2 strong, 1.5 adequate, 0.5 weak."

**Across teams:** "150 teams enrolled. 120 completed Stage 0. 85 active in Stage 1. 12 reached Stage 2+."

---

## Rollout Phases

### Phase 1: Pilot (Month 1-2)
- **Scope:** 5 teams, hand-selected (mix of skeptics and enthusiasts, different stacks)
- **Goal:** Validate Stage 0 + 1 content works across stacks, measure time estimates, collect ROI data
- **Output:** Case studies with real numbers ("Team X reduced PR review time by 35%")
- **Critical:** Fix any stuck paths, stack-specific issues, or eval subagent reliability problems before scaling

### Phase 2: Early Adopters (Month 2-4)
- **Scope:** 50 teams, self-selected from teams that expressed interest
- **Goal:** Validate at-scale delivery, refine manager dashboard, build internal word-of-mouth
- **Output:** Standardized onboarding flow, FAQ, known issues list

### Phase 3: Broad Rollout (Month 4-6)
- **Scope:** All interested teams (target: 200-500)
- **Goal:** Self-service onboarding, minimal central support needed
- **Prerequisite:** Pilot and early adopter data proving ROI

### Phase 4: Advanced Track (Month 6+)
- **Scope:** Teams that completed Stages 0-1 and want Stages 2+
- **Goal:** Build the pipeline engineering capability across the organization
- **Note:** This is opt-in. Most teams are productive at Stage 1. Advanced track is for teams building autonomous systems.

---

## Selling Internally

### The 30-second pitch to an engineering director
"Your team spends X hours a week on code review, test writing, bug investigation, and refactoring. This system teaches them to use AI for all four — hands-on, on their actual codebase, in one afternoon. Pilot teams saw [ROI metric]. It's self-teaching — no trainers needed, no workshops to schedule."

### Common objections and responses
| Objection | Response |
|-----------|----------|
| "We tried Copilot, nobody used it" | "Copilot is autocomplete. This teaches workflows — bug fixing, test writing, code review. Different value proposition." |
| "My team doesn't have time for training" | "Stage 0 is 45 minutes. Stage 1 is done on real work — their actual bugs, their actual code. It's not training time, it's accelerated work time." |
| "How do I know it's working?" | "Concept-level progress tracking. You see exactly which skills each developer has demonstrated, not just 'completed a course.'" |
| "What about security/compliance?" | "All work happens on the developer's local machine with their existing code. No code leaves the environment. The AI reads files, proposes changes, developer approves everything." |
| "8 stages is too much" | "Stages 0-1 are the core program — 3-4 hours, immediate productivity gains. Stages 2+ are advanced track for teams that want to go further." |

---

## Open Questions (to resolve during pilot)

- What's the right cadence? One afternoon? Spread across a week? One recipe per day?
- Do teams need a "champion" (one person who goes first and helps others)?
- How do we handle teams with no test framework? (Stage 1.2 assumes runnable tests)
- How do we handle teams with no recent PRs? (Stage 1.3 assumes reviewable code)
- What's the minimum viable manager dashboard for Phase 1?
- Should there be a Slack channel / Teams channel for questions during rollout?
