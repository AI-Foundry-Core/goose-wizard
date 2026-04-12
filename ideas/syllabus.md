# RILGoose Syllabus — Concept Map Across All Stages

**Purpose:** Single source of truth for what we teach, where we teach it, and what it builds on.

**Framing:** This is a progression of capability, not a catalog of dangers. Each stage shows teams something powerful, then teaches the practices that make it reliable. Skeptics need to see value before they'll invest in practices.

**Sources:** `[pipeline]` = lessons from our AgenticSystem project. `[ddd]` = patterns from the Document-Driven Development system. `[research]` = industry best practices from eval/testing research.

---

## Teaching Framework: Adaptive Evaluation

We don't teach by lecturing. We teach by having developers do real work and coaching them on what they're missing.

### The Core Principle

The system watches what the developer does, evaluates it against a concept checklist, and teaches only what's needed. A senior dev who writes a great spec gets "Good — you nailed the persona decomposition and testable criteria." A junior dev who writes vague requirements gets targeted coaching on exactly what's vague.

### Architecture

```
Developer does real work
        │
        ▼
┌─────────────────┐     ┌──��───────────────────┐
│  Facilitator     │────▶│  Code-Work Subagent   │
│  (main agent)    │     │  (does the hands work)│
│                  │     └──────────────────────┘
│  Stays in the    │
│  conversation.   │     ┌──────────────────────┐
│  Guides the task.│────▶│  Eval Subagent        │
│  Teaches gaps.   │     │  (background check)   │
│                  │◀────│  Returns: which        │
└─────────────────┘     │  concepts demonstrated,│
        │               │  which missing + what  │
        ▼               │  to teach              │
  Targeted coaching     └──────────────────────┘
  ONLY for gaps
```

**Facilitator (main agent):** Guides the conversation and the task. Never touches code. Receives eval results and decides what to teach. Speaks as a knowledgeable colleague, not an instructor reading a script.

**Code-Work Subagent:** Does all code operations — reading files, running tests, making edits, generating diffs. Reports results back to the facilitator.

**Eval Subagent:** Runs after the developer completes a task (batch, not real-time). Sees the full conversation transcript. Rates the developer's work on quality dimensions — not "did they do it" (of course they did, the recipe guided them) but "how well did they do it." Returns structured ratings with specific evidence and suggested coaching.

### Four Teaching Modes (progressive by stage)

| Mode | Used In | How It Works |
| --- | --- | --- |
| **Scripted** | Stage 0 | Facilitator follows a script. Designed moments of surprise. Developer has no mental model yet — you can't evaluate what they've never encountered. |
| **Guided-Adaptive** | Stage 1 | Facilitator sets up real work ("got a bug? tell me about it"). Developer does the work. Eval subagent rates quality of how they did it. Facilitator praises what was strong, coaches what was weak. |
| **Adaptive + Checkpoints** | Stages 2–4 | Developer builds real systems. Eval tracks quality across multiple interactions. Facilitator intervenes at defined checkpoints (every 3-4 concepts). |
| **Fully Adaptive** | Stages 5–7 | Developer has the mental models. Facilitator shifts to consulting role — available when called, coaching when gaps appear, otherwise staying out of the way. |

### Key Design Rule

> Never go adaptive on a concept the developer has no mental model for. You can evaluate skills adaptively. You cannot evaluate understanding of ideas the developer has never encountered.

### How Eval Works: Quality Ratings, Not Binary Checks

The eval subagent doesn't check "did they do it" — the guided recipe ensures they do it. It evaluates **how well** they did it. Each quality dimension gets a rating:

- **Strong** — Developer demonstrated this well. Facilitator acknowledges specifically what was good. ("You gave it the symptom, what you ruled out, and a theory. That's exactly the kind of context that makes AI fast.")
- **Adequate** — Developer did it but could improve. Facilitator gives a light suggestion. ("Good start — next time also mention what you already tried, so the AI doesn't retrace your steps.")
- **Weak** — Developer missed this or did it poorly. Facilitator coaches with specifics. ("You said 'the login is broken.' Compare that to: 'login fails after OAuth redirect, I checked the callback URL, I think the session isn't persisting.' The second version gets a fix in one pass.")

The eval subagent returns for each dimension: the rating, what specifically the developer did (evidence from the transcript), and suggested coaching language. The facilitator makes the final call on what to say.

### Progress Tracking

Progress is concept-based, not exercise-based. Each concept tracks the developer's best rating across attempts. Managers see: "Team X: Stage 0 complete. Stage 1: 2 strong, 1 adequate, 1 weak." A team that's all strong/adequate advances. A team with weak ratings gets another pass at those recipes with coaching.

### Practical Mechanisms

**Skip mechanism:** A developer who believes they already know a stage's concepts can request a challenge assessment — they do the task once with no guidance, the eval subagent rates them, and if all dimensions are adequate or strong they skip ahead. This respects experienced developers' time without letting people skip foundations they haven't earned.

**Stuck paths:** When a recipe can't proceed (no bug available, test suite won't run, repo won't build, AI loops without progress):
- The facilitator detects the block and offers alternatives: "No current bugs? Let me find a code smell in the project we can use instead."
- For infrastructure issues (build failures, missing dependencies), the facilitator delegates to a diagnostic subagent before continuing.
- If the AI loops on a task after 3 attempts, the facilitator stops and teaches the "redirect" concept live: "This is actually a teaching moment — when AI loops, change the approach."

**Inter-stage gates:** Self-directed with guardrails. The system offers advancement when all concepts in a stage are adequate or strong. The developer can accept or stay longer. They cannot skip ahead without demonstrating competence (via the skip mechanism above). No manager approval required — the system is the gate.

---

## 8-Stage Progression

| Stage | Name | Mode | One-Line |
| --- | --- | --- | --- |
| 0 | See What AI Can Do | Scripted | AI is a development tool, not a chatbot |
| 1 | Get Real Work Done | Guided-Adaptive | Use AI daily for real tasks |
| 2 | Two AIs Are Better Than One | Adaptive + Checkpoints | AI checking AI is more reliable than you checking AI |
| 3 | Build a Team of AI Specialists | Adaptive + Checkpoints | Multi-agent pipelines with specialized roles |
| 4 | From Idea to Buildable Spec | Adaptive + Checkpoints | Turn a feature idea into a spec AI can execute on |
| 5 | Trust But Verify | Fully Adaptive | Build the eval system that proves it's working |
| 6 | Let It Run While You Sleep | Fully Adaptive | Autonomous multi-session pipelines |
| 7 | The System Gets Smarter Over Time | Fully Adaptive | Self-improving pipelines |

---

## Stage 0: "See What AI Can Do"
*Mode: Scripted. Developer has never used AI coding tools — there's nothing to evaluate yet.*
*Goal: Developer goes from "AI is a chatbot" to "AI is a development tool that works on my actual code."*
*Duration: \~45-60 minutes. One recipe, 5 acts.*

**Why scripted:** These are mental model shifts, not skills. A developer can't demonstrate "everything is reversible" through real work because they don't yet know `git checkout` undoes AI changes. They need to be shown. The designed moments of surprise ("look, it read your actual file") are what convert skeptics.

**Adaptive shortcut:** If a developer clearly already knows something (uses git terminology unprompted, asks about branching strategy), the facilitator can skip the walkthrough and do a quick verification instead: "Show me how you'd undo a change the AI made." Then move on.

| # | Concept | Act | What We Teach | Prerequisite |
| --- | --- | --- | --- | --- |
| 0.1 | **AI reads your actual code** | See Your Code | Not guessing from descriptions — reading real files, understanding real structure. The developer picks a file and asks questions. AI answers from the code, not from training data. | None |
| 0.2 | **AI edits your actual code** | First Edit | AI proposes a change to a real file. Developer approves before it happens. This is the core loop: AI proposes, you review, you approve. | 0.1 |
| 0.3 | **Everything is reversible** | Undo Button | `git diff` shows what changed. `git checkout` undoes it. Practice branches keep experiments safe. The developer should never feel nervous. | 0.2 |
| 0.4 | **AI is confident, not correct** | Catch the Bug | AI writes plausible code with a subtle bug — and doesn't flag it. The developer learns to read AI output critically, not skim it. This is the one habit that separates productive AI users from everyone else. | 0.2, 0.3 |
| 0.5 | **You control the quality** | Say It Better | Same AI, same function — vague instruction produces garbage, specific instruction produces exactly what you wanted. The developer is the difference, not the AI. | 0.1–0.4 |

**Stage 0 arc:** "AI can see and change your code. Everything is reversible. AI is fast but not always right. And the quality is up to you."

---

## Stage 1: "Get Real Work Done"
*Mode: Guided-Adaptive. Facilitator sets up real work. Developer does it. Eval rates how well they did it.*
*Goal: Developer uses AI daily and sees measurable productivity gains.*
*Duration: \~20-30 minutes per recipe. Four independent recipes, ordered by impact.*

**How it works:** The facilitator says "Got a bug you've been stuck on? Tell me about it." The developer describes the bug. The code-work subagent investigates and fixes it. The eval subagent rates the quality of how the developer approached it — context quality, verification thoroughness, iteration. The facilitator praises what was strong and coaches what was weak.

### Recipe 1.1: Bug Fix — "AI as investigator"

**Core requirement:** Developer provides a real bug, gives context, gets it fixed, and verifies the fix addresses the root cause.

| Quality Dimension | Strong | Adequate | Weak |
| --- | --- | --- | --- |
| **Context quality** | Developer described the symptom, what they already tried, where they suspect the issue, and/or how to reproduce it. *"That's exactly the kind of context that makes AI fast — you gave it the symptom, what you ruled out, and a theory. This is why it found the fix in one pass."* | Developer gave some context but left out key info (e.g., described symptom but not what they tried). *"Good start — next time also mention what you already tried, so the AI doesn't retrace your steps."* | Developer said something like "the login is broken" with no detail. *"Compare what you said to: 'login fails after OAuth redirect, I checked the callback URL, I think the session isn't persisting.' The second version gets a fix in one pass. Context is everything."* |
| **Fix verification** | Developer checked the diff, ran tests, or asked what was changed before accepting. *"Good — you checked what the fix actually did before accepting it. That's the habit."* | Developer glanced at the result but didn't run tests or inspect the diff closely. *"It looks like it worked, but open the diff. AI sometimes hides errors instead of fixing them — wraps things in try/catch, suppresses the exception. Quick check: did it solve the problem or silence it?"* | Developer just accepted the fix without checking. *"Stop — always check what the fix did. Open the diff. Run the tests. AI confidently 'fixes' bugs by suppressing errors. If you don't verify, you'll ship a hidden problem."* |
| **Redirect on struggle** | *(Only rated if AI struggled)* Developer changed approach after 2+ failed attempts — different context, different theory, different angle. *"Smart move — you gave it a different angle when it was stuck. That's the right instinct."* | Developer waited too long but eventually adjusted. *"You let it loop a few rounds before changing approach. After 2 failed attempts, switch it up — different context, different file, different theory."* | Developer kept retrying the same way. *"When it's going in circles, stop. Don't let it loop. Give it a completely different angle — a different file to look at, a different theory about the cause."* |

**Source:** [pipeline] Symptom suppression is the #1 bad-fix pattern; context quality determines fix speed

### Recipe 1.2: Test Writer — "AI writes the tests you never get around to"

**Core requirement:** Developer picks a function, AI generates tests, developer runs and evaluates them.

| Quality Dimension | Strong | Adequate | Weak |
| --- | --- | --- | --- |
| **Scope definition** | Developer targeted a specific function or small module with clear boundaries. *"Perfect scope — tight and specific. AI writes much better tests when it's focused on one thing."* | Developer targeted a reasonable scope but could be tighter. *"This is OK, but you'd get better tests if you narrowed it to just [specific function]. Smaller scope = better tests."* | Developer asked for "tests for everything" or a very broad scope. *"Start with one function, not the whole module. AI writes better tests when the scope is tight. Pick the most important function and start there."* |
| **Test execution** | Developer ran the tests and looked at results (pass/fail counts, error messages). *"Good — you ran them. That's the difference between tests that exist and tests that work."* | Developer ran tests but didn't look closely at the results. *"You ran them, which is good. But look at the output — which ones failed? Why? The failure messages tell you what to fix next."* | Developer looked at the test code but never ran it. *"These look right but you never ran them. Always run them. AI writes tests that look correct but fail on execution. That's where the real iteration starts."* |
| **Quality evaluation** | Developer questioned whether tests check real behavior — noticed weak assertions or trivial tests. *"You caught that — this assertion just checks the function returns something, not the right thing. That's the skill: distinguishing meaningful tests from padding."* | Developer accepted the tests but asked a general question about quality. *"Good instinct to ask. Look at this specific test — would it catch a real bug? If you changed the function's logic, would this test fail? If not, it's not testing anything meaningful."* | Developer accepted all passing tests without questioning. *"These all pass. But look at this one — it asserts ****\*\*\*\*\*\*****\*\*\*\*\*\*\***`true == true`**\*\*\*\*\*\*\*\*\*. That passes no matter what. A test that can't fail is worse than no test. Ask: would this test catch a real bug?"* |
| **Iteration** | Developer did a second round — fixed failures, added edge cases, or improved weak tests. *"Great — the second round is always better. You went from [X] to [Y] passing tests, and the new ones test real edge cases. That iteration cycle is the real workflow."* | Developer acknowledged the need for iteration but stopped after one round. *"First pass is a starting point. Try one more round — fix the failures and add an edge case. The iteration cycle (write → run → fix → run) is where the quality comes from."* | Developer stopped after the first pass regardless of quality. *"You've got a first draft. But test writing is iterative — write, run, fix, run. Each round gets better. Try again with the failures and one edge case you can think of."* |

**Source:** [pipeline] 32 tests "passed" but never executed; trivial tests are a symptom of underspecified prompts

### Recipe 1.3: Code Review — "AI as tireless reviewer"

**Core requirement:** Developer points AI at real code (PR, commit, or files), gets review feedback, and works with the findings.

| Quality Dimension | Strong | Adequate | Weak |
| --- | --- | --- | --- |
| **Scope definition** | Developer pointed at specific files, a PR, or a commit range. *"Good scoping — you pointed it at exactly what matters. That's why the findings are relevant."* | Developer gave a reasonable scope but could be more precise. *"This worked, but next time try pointing at just the changed files in the PR, not the whole directory. Tighter scope = less noise."* | Developer asked for a general review of a broad area. *"Point it at a PR or specific files, not the whole repo. What you got back is mostly noise because the scope was too broad."* |
| **Triage quality** | Developer distinguished real issues from noise — identified what to fix, what to ignore, what's wrong. *"You triaged well — you caught that finding #3 is a real bug but #5 is just a style preference. That judgment is exactly what makes AI review useful."* | Developer engaged with the findings but treated them mostly equally. *"Some of these are real bugs, some are style preferences, and some are just wrong. Don't treat them equally. Which ones would you actually fix before merging?"* | Developer accepted all findings at face value or dismissed them all. *"AI reviews mix real bugs with style opinions with outright mistakes. You need to triage — which are real issues? Which are noise? That skill is what makes this tool useful."* |
| **Iteration and refinement** | Developer refined the review with focused follow-ups ("focus on security," "ignore style"). *"Smart — you steered it. Each focused pass finds more than one broad pass. This is how you get the most from AI review."* | Developer did one pass but didn't try to refine. *"Good first pass. Try steering it: 'ignore style issues, just find logic errors' or 'focus on security.' Each focused pass finds things the general one missed."* | Developer took the first result as final. *"This is a starting point, not the final answer. Try: 'now focus only on security issues' or 'ignore formatting, find logic errors.' You can steer it to find what matters."* |
| **Healthy skepticism** | Developer probed beyond positive feedback — asked follow-up questions even when the review was mostly clean. *"Good instinct — you didn't let 'looks good' be the final word. AI defaults to polite. Probing further is how you find what it missed."* | Developer accepted mostly-positive results but didn't blindly trust them. *"The review says this code is clean. It might be. But AI defaults to polite — a positive review is a starting point. Try asking: 'what could go wrong in production?'"* | Developer accepted a positive review without question. *"It said the code looks clean. That doesn't mean there are no bugs. AI defaults to polite. Always probe: 'what are the edge cases?' or 'what could go wrong under load?' Silence from AI isn't a green light."* |

**Source:** [pipeline] 65% of reviews found nothing because the instructions were vague; specific focus produces findings

### Recipe 1.4: Refactor — "AI handles the restructuring you've been putting off"

**Core requirement:** Developer defines what "better" means, runs tests before, AI refactors, runs tests after, developer reviews the full diff.

| Quality Dimension | Strong | Adequate | Weak |
| --- | --- | --- | --- |
| **Goal definition** | Developer stated a clear goal: "make this more readable by splitting into smaller functions" or "make this testable by removing the database dependency." *"Clear goal — that's why the refactor did exactly what you wanted."* | Developer gave a general direction ("clean this up") but not a specific goal. *"'Clean it up' worked OK, but compare: 'split this into two functions — one for validation, one for processing.' Specific goals get specific results."* | Developer said "refactor this" with no goal. *"What does 'better' mean for this code? More readable? More testable? Faster? If you can't say, the AI guesses — and it guesses wrong half the time. Define the goal first."* |
| **Baseline established** | Developer ran tests and noted the state (all pass, N tests) before the refactor started. *"Good — you have a baseline. If anything breaks, you'll know immediately."* | Developer ran tests but didn't note the baseline clearly. *"You ran the tests, but note the count: [N] tests passing. After the refactor, if that number changes, something broke."* | Developer didn't run tests before starting. *"Always run tests first. That's your baseline — if they pass now and fail after, you know the refactor broke something. Without a baseline, you can't tell."* |
| **Post-refactor verification** | Developer ran tests after AND reviewed the diff for behavioral changes. *"Good — tests pass and you checked the diff for hidden changes. That's the full verification."* | Developer ran tests OR reviewed the diff, but not both. *"Tests pass, but did you check the diff? [or] You checked the diff, but did you run the tests? You need both — tests catch regressions, diff review catches behavioral changes that tests don't cover."* | Developer accepted the refactor without running tests or reviewing. *"Stop — run the tests. A refactor that breaks tests isn't a refactor. And check the diff: this line looks like cleanup but it changed a conditional. Restructuring can hide behavioral changes."* |
| **Scope control** | Developer targeted one function or a small, coherent unit. *"Right scope ��� one function, clean result. This is how you refactor safely."* | Developer's scope was reasonable but a bit broad. *"This worked, but next time try one function at a time. Smaller refactors are easier to review and less likely to have ripple effects."* | Developer tried to refactor a whole module or multiple unrelated functions. *"Too much at once. Start with one function — the ugliest one. Get it clean, verified, and committed. Then the next one. Small refactors are safe refactors."* |

**Source:** [pipeline] Cross-phase regression blind spots; specs must define "done" before building

### Bridge to Stage 2

> "You've been the one catching everything — verifying fixes, evaluating tests, triaging reviews, checking diffs. Imagine if a second AI did that for you. That's Stage 2."

### Reference Guide Material (lives in a tips document, not taught live)

- **Iteration as a workflow** — First pass is a starting point. Each round gets better.
- **When to stop and redirect** — 2-3 failed attempts means rethink the approach, not retry harder.
- **Prompt patterns by recipe** — Examples of good prompts for reviews, tests, bug reports, refactor requests.
- **Risk ladder** — Why some AI tasks are inherently safer (reading vs. writing vs. restructuring).

**Stage 1 arc:** "AI just fixed your bug, wrote your tests, reviewed your PR, and cleaned up your legacy code. You're 10x faster. Now imagine what happens when AI checks AI."

---

## Stage 2: "Two AIs Are Better Than One"
*Mode: Adaptive + Checkpoints. Developer builds real two-agent workflows. Facilitator checks in after concepts 2.2 and 2.4.*
*Goal: Developer discovers that a second AI catching the first AI's mistakes is more reliable than catching them yourself.*

| # | Concept | Recipe | Core Requirement | Observable Signals | Teaching Trigger | Source |
| --- | --- | --- | --- | --- | --- | --- |
| 2.1 | **Why one AI isn't enough** | build-then-test | Developer sets up a build-then-test workflow and sees the tester catch something the builder missed | Tester found at least one issue the builder didn't flag; developer acknowledged the difference | "The AI that wrote the code thinks it's correct — like grading your own exam. The tester just found [X] that the builder missed. This is the single biggest reliability upgrade." | [pipeline] Self-verification bias |
| 2.2 | **Specialists beat generalists** | build-then-test, review-gate | Developer configures agents with different roles (builder vs. tester) rather than one general agent | Developer assigned different extensions/scopes to each agent; didn't use one agent for both jobs | "An AI focused only on testing finds more bugs than one that builds AND tests. You just saw that. Separation of concerns isn't bureaucracy — it's how you get reliability." | [pipeline] File ownership matrix |
| 2.3 | **Prove it works, don't just look at it** | review-gate | Developer's review gate checks execution results, not just file existence | Gate checks test pass/fail counts or exit codes, not just "does the file exist" | "Checking that tests exist is not checking that they pass. Always verify by execution. Your gate should run the code, not just look at it." | [pipeline] "Pipelines that check artifacts instead of outcomes ship broken work" |
| 2.4 | **Define success before building** | spec-first | Developer writes acceptance criteria before asking AI to build | Developer wrote what "done" looks like before the build started | "You just defined success criteria up front. That prevented the AI from solving the wrong problem. Tests before code. Spec before tests." | [pipeline] Behavioral test suite written BEFORE building |

**Checkpoint after 2.2:** Facilitator reviews — are the agent roles clearly separated? Any confusion about why two agents instead of one?

**Checkpoint after 2.4:** Facilitator reviews — does the developer understand the spec-first pattern? Bridge to Stage 3.

**Stage 2 arc:** "One AI builds, another AI tests. Neither trusts the other's work. Your code is more reliable than when you checked everything yourself."

---

## Stage 3: "Build a Team of AI Specialists"
*Mode: Adaptive + Checkpoints. Developer designs real multi-agent pipelines. Facilitator checks in after concepts 3.3 and 3.5.*
*Goal: Developer designs multi-agent pipelines where specialized AIs handle different parts of the workflow.*

| # | Concept | Recipe | Core Requirement | Observable Signals | Teaching Trigger | Source |
| --- | --- | --- | --- | --- | --- | --- |
| 3.1 | **Agent roles and specialization** | three-agent-pipeline | Developer creates a pipeline with 3+ agents, each with a defined role and scoped knowledge | Each agent has a clear, distinct responsibility; no agent does "everything" | "Each AI should have one job and deep knowledge of that job. A spec analyst, a builder, a tester — each sees only what it needs." | [pipeline] 5 specialized agents, each loading one skill file |
| 3.2 | **Agents need clear contracts** | three-agent-pipeline | Developer defines the data format between agents (what Agent A outputs, what Agent B expects) | Agent handoffs have explicit structure; not just "pass the result along" | "When Agent A writes data for Agent B, the format is a hidden contract. You just saw what happens when nobody validates it — [specific issue]. Define the contract explicitly." | [pipeline] test_progression.json format drift |
| 3.3 | **Safety rails for autonomous operation** | three-agent-pipeline, escalation-routing | Developer configures failure thresholds and escalation paths | Pipeline has circuit breakers (stop after N failures) and escalation (route to specialist or human) | "Without safety rails, a failing agent loops forever burning resources. Circuit breakers say 'stop after 3 failures.' Escalation says 'route to someone who can help.' This is how you let it run without babysitting." | [pipeline] 3 breakers stuck OPEN permanently |
| 3.4 | **Layered testing catches what single-pass misses** | parallel-reviewers | Developer sets up multi-layer testing (at least 2 tiers) | Tests cover different levels (e.g., syntax + behavioral, or contract + execution) | "One layer of testing catches one class of error. Parse → Structure → Contract → Execution — each layer catches what the others miss." | [pipeline] Four-tier testing strategy |
| 3.5 | **Parallel agents need coordination** | parallel-reviewers | Developer runs agents in parallel and handles shared-state correctly | No file corruption, temp files scoped, results properly merged | "Multiple AIs working simultaneously is powerful but shared files need locking and temp files need unique names. Concurrent writes corrupt state." | [pipeline] Shared temp files break under parallel agents |

**Checkpoint after 3.3:** Are safety rails in place? Bridge from "team of agents" to "how do we feed this team good specs?"

**Checkpoint after 3.5:** Full review — is the pipeline robust? Ready for Stage 4 (specs) and Stage 5 (evals).

**Stage 3 arc:** "You have a team of AI specialists — each with a defined role, clear contracts between them, and safety rails that let them work autonomously."

---

## Stage 4: "From Idea to Buildable Spec"
*Mode: Adaptive + Checkpoints. Spec writing is a new mental model for most developers — needs more guidance than pure adaptive. Facilitator checks in after 4.2 (progressive elaboration) and 4.5 (quality gates).*
*Goal: Developer learns to turn a vague feature idea into a specification precise enough for an AI team to execute autonomously.*

**How it works:** The developer has a real feature idea (or is given one). They go through the DDD artifact chain — starting with a one-pager, then elaborating into requirements if warranted. The eval subagent scores their spec against quality dimensions and identifies gaps. The facilitator coaches on what's missing. If the spec is already good: "This is solid — your acceptance criteria are testable, your personas are grounded, and you've defined kill criteria. This is ready for a pipeline."

**Checkpoint after 4.2:** Has the developer internalized progressive elaboration? Are they resisting the urge to over-specify too early?

**Checkpoint after 4.5:** Has the developer gone through a quality gate cycle? Do they understand that fixing a spec is 100x cheaper than fixing a product?

| # | Concept | Recipe | Core Requirement | Observable Signals | Teaching Trigger | Source |
| --- | --- | --- | --- | --- | --- | --- |
| 4.1 | **Vague specs produce vague output** | idea-to-spec | Developer's spec is specific enough for an AI to act on without asking clarifying questions | Spec has concrete details (numbers, names, criteria), not placeholders or TBD | "This section says 'the system should be fast.' Fast how? For whom? Under what load? 'P95 latency < 200ms for order placement' is a spec. 'Should be fast' is a wish. The spec is the prompt for your pipeline — vague in, vague out." | [ddd] Golden prompts enforce "no TBD, no placeholders" |
| 4.2 | **Progressive elaboration** | idea-to-spec | Developer starts with a constrained format (one-pager) before jumping to detailed requirements | Developer didn't try to write a 25-page doc first; started with the core value proposition | "Start with a one-pager: what's the problem, who has it, what's the solution, what's the risk? If the one-pager doesn't convince, the requirements doc won't either. Kill bad ideas cheaply." | [ddd] Artifact chain: One-Pager → Business Plan → Requirements |
| 4.3 | **Decompose by persona, not by feature** | spec-decomposition | Developer's requirements are organized around real people, not abstract features | Spec names specific personas with demographics, pain points, and use cases — not just "the user" | "Requirements organized by feature miss cross-cutting needs. 'Priya, working mother in Pune' forces you to think about her whole workflow. Each persona gets their own use cases and edge cases." | [ddd] Persona-driven decomposition |
| 4.4 | **Every requirement must be testable** | spec-to-pipeline | Developer writes acceptance criteria that an AI could turn into a test | Requirements have clear pass/fail criteria; not subjective ("should be user-friendly") | "If AI can't write a test for this requirement, the requirement isn't specific enough. 'User-friendly' is not testable. '95% of first-time users complete checkout without help' is." | [ddd] Table-driven requirements with acceptance criteria |
| 4.5 | **AI-assisted spec quality gates** | spec-review | Developer runs their spec through a quality review and addresses findings | Developer iterated on the spec after review feedback; didn't just accept the first draft | "The review flagged that your market sizing isn't traceable to real data. Fix the spec now — it's 100x cheaper to fix a spec than to fix a product built from a bad spec." | [ddd] 10-dimension Executive Review Simulation |
| 4.6 | **Kill criteria prevent zombie projects** | spec-review | Developer's spec includes conditions under which the project should stop | Spec has explicit kill criteria with measurable thresholds | "What would make you kill this project? '<2% conversion at month 3' is a kill criterion. Without it, failed projects limp along because nobody defined what failure looks like." | [ddd] Kill criteria in every one-pager |

**Stage 4 arc:** "You can turn a napkin idea into a spec that an AI team can build from. Bad specs produce bad products — no amount of AI talent fixes a vague spec."

---

## Stage 5: "Trust But Verify"
*Mode: Fully Adaptive. Developer builds a real evaluation system for their pipeline. Facilitator coaches on gaps in their eval strategy.*
*Goal: Developer builds the evaluation system that proves autonomous pipelines are actually working.*

| # | Concept | Recipe | Core Requirement | Observable Signals | Teaching Trigger | Source |
| --- | --- | --- | --- | --- | --- | --- |
| 5.1 | **Never trust self-reported results** | eval-foundation | Developer's eval system verifies results independently, not by reading agent claims | Pipeline runs tests independently and parses exit codes; doesn't just trust agent-reported pass/fail | "The pipeline says 'all tests pass.' Did it actually run them? Run pytest yourself. Parse the exit code. Compare against what the agent claimed. A 20-line check prevents silent failures." | [pipeline] Nobody independently verified agent results; [research] Anthropic: "inspect the final state, not what the agent claims" |
| 5.2 | **Layered eval strategy** | eval-layers | Developer's eval system has at least two layers (e.g., deterministic + behavioral, or code-based + model-based) | Multiple eval types present; not just "run the tests" | "No single eval catches everything. Deterministic checks catch the obvious. Behavioral tests catch the functional. Model-based grading catches the subjective. You need layers." | [research] Three grader types: code-based, model-based, human |
| 5.3 | **Eval ratchets prevent regression** | eval-ratchet | Developer configures quality thresholds that only go up | Test count or coverage has a minimum that blocks regression | "Once you have 200 passing tests, the number should never go below 200. That's a ratchet — the bar only goes up. Without it, quality erodes invisibly between cycles." | [research] Trunk-based ratchets; [pipeline] 23 failing tests normalized as "acceptable" |
| 5.4 | **Specific checks find problems, vague checks don't** | eval-design | Developer's eval criteria are specific enough to produce actionable findings | Eval checks specific things ("rate each assertion as meaningful/weak/trivial") not vague things ("check quality") | "'Check quality' produces rubber stamps. 'Open 2-3 test files and rate each assertion' produces findings. Specificity in your eval is just as important as specificity in your spec." | [pipeline] Evaluators rubber-stamp when given vague checklists |
| 5.5 | **Mock external dependencies for reliable evals** | eval-isolation | Developer's eval suite doesn't depend on live external APIs for gate tests | Gate tests use recorded/mocked responses; live API tests run on a separate schedule | "If your tests depend on a live external API, they'll fail randomly when the API is slow or down. Record real responses once, replay them in your eval suite." | [research] Service virtualization; [pipeline] Golden path gates permanently broken by live API instability |
| 5.6 | **Evals must run before autonomy** | eval-gate | Developer has a functioning eval system before enabling autonomous operation | Eval pipeline exists and runs independently; not just planned | "An autonomous pipeline without evals is a pipeline you can't trust. Before you let it run overnight, prove that your evals catch real problems." | [pipeline] "The next evolution is measurement and feedback about the pipeline itself" |

**Stage 5 arc:** "You have mechanical proof that the pipeline works — not agent claims, not rubber stamps, but independent verification at every layer. Now you can let it run."

---

## Stage 6: "Let It Run While You Sleep"
*Mode: Fully Adaptive. Developer runs real autonomous pipelines. Facilitator coaches on operational gaps.*
*Goal: Developer runs multi-session autonomous pipelines and knows how to evaluate whether they're working well.*

| # | Concept | Recipe | Core Requirement | Observable Signals | Teaching Trigger | Source |
| --- | --- | --- | --- | --- | --- | --- |
| 6.1 | **Step back and evaluate the whole** | ten-session-cycle, cycle-review | Developer reviews pipeline output holistically after N sessions, not just per-session | Developer looks at trends across sessions, not just the latest output | "Individual sessions can look fine while the system slowly drifts. Step back after 10 sessions and ask: is the output actually getting better?" | [pipeline] Cycle review prompt — 14 mandatory verification steps |
| 6.2 | **Close the feedback loop** | cycle-review | Developer verifies that review findings actually get applied, not just logged | Developer checks if previous cycle's recommendations changed behavior in subsequent sessions | "You flagged this issue last cycle. Did the pipeline actually fix it? Signal → Action → Verification. Most systems skip the third step and the loop degrades silently." | [pipeline] Supervisor recommendations written but never verified |
| 6.3 | **Success signals can lie** | cycle-review | Developer distinguishes real success from ceremonial success | Developer investigated behind "all green" results to verify they're meaningful | "All tests pass. But did you check what they're testing? Your Stage 5 eval system catches the mechanical lies. Cycle review catches the systemic ones." | [pipeline] 73% of integration tests never ran |
| 6.4 | **Capture what you learn** | continuous-dev | Developer documents surprising findings in a structured format | Learnings written down with context, not just mental notes | "That's a real finding — write it down. 'Builder produces clean code but never commits pipeline changes' is a learnings entry. Future cycles benefit from what you discovered now." | [pipeline] LEARNINGS.md |
| 6.5 | **Agents need their own memory** | continuous-dev | Developer gives periodic agents their own state file, not a shared log | Each agent that runs across sessions has dedicated persistent state | "If the cycle reviewer shares a log with the builder, its entries get buried. Give each periodic agent its own state file. It needs to find what it wrote last time." | [pipeline] CYCLE_REVIEW_LOG.md |
| 6.6 | **Shared state requires discipline** | continuous-dev | Developer handles inter-layer communication files correctly (create, read, clean up) | Stop flags and progression files are cleaned up after processing; no stale signals | "That stop flag is from last cycle but nobody cleaned it up. Now this cycle's pipeline sees it and exits immediately. The reader must clean up after processing." | [pipeline] `.stop_cycle` not cleaned up → 3 cycles of no-builds |

**Stage 6 arc:** "The pipeline runs 10 sessions overnight. You review in the morning. You know exactly how to tell whether it actually worked — because you built the eval system first."

---

## Stage 7: "The System Gets Smarter Over Time"
*Mode: Fully Adaptive. Developer evolves their pipeline. Facilitator is pure consulting.*
*Goal: The pipeline itself evolves — agent instructions improve, bad rules get pruned, measurements drive decisions.*

| # | Concept | Recipe | Core Requirement | Observable Signals | Teaching Trigger | Source |
| --- | --- | --- | --- | --- | --- | --- |
| 7.1 | **The Curator closes the loop** | skill-evolution | Developer creates an agent that turns review findings into verified improvements to the system | A curator-type agent exists that reads findings and produces changes, not just reports | "You have agents that build and agents that review. The Curator turns review findings into actual system improvements — and verifies they worked." | [pipeline] ACE pattern: Generator → Reflector → Curator |
| 7.2 | **Agent instructions should evolve** | skill-evolution | Developer updates skill files based on observed performance | Skill files have been modified based on what worked/failed in practice | "When it fails, fix the instruction, not the output. The instruction is the root cause. A tester that writes trivial tests has a prompt that never defined 'meaningful assertion.'" | [pipeline] "Fix the prompt, not the output" |
| 7.3 | **Rules accumulate and conflict** | pipeline-self-edit | Developer audits rules for duplication and conflict | Rule count is tracked; duplicates across files have been consolidated | "You have the same rule in 3 files. When they conflict, the agent picks one at random. One source of truth per rule. Audit and prune." | [pipeline] 37.5% accuracy loss from competing rules |
| 7.4 | **Measure, don't guess** | metrics-dashboard | Developer uses metrics to evaluate pipeline changes, not just intuition | Before/after metrics exist for at least one pipeline change | "You changed the builder prompt last week. Is it actually better? Without metrics — session productivity, test quality trends, task completion rate — you're guessing." | [pipeline] Pipeline A/B testing |
| 7.5 | **Audit your guardrails** | pipeline-self-edit | Developer identifies at least one guardrail that's no longer needed | A constraint has been reviewed and either justified or removed | "This rule exists because the model used to hallucinate function names. Does it still? Models improve. Periodically ask: are these training wheels we forgot to remove?" | [pipeline] "What guardrails exist because of a model limitation that may no longer apply?" |

**Stage 7 arc:** "The system doesn't just run — it learns. Agent instructions get better, bad rules get pruned, and measurements tell you what's actually working."

---

## Cross-Cutting Themes (Reinforced Across Multiple Stages)

| Theme | First Appears | Deepens At | The Progression |
| --- | --- | --- | --- |
| **Specificity determines quality** | 0.5 (prompts) | 1.1–1.4 (task scope), 4.1 (specs), 5.4 (evals) | Vague prompt → vague output. Vague spec → vague product. Vague eval → rubber stamp. |
| **Verify by execution, not inspection** | 1.2 (run tests) | 2.3, 3.4, 5.1 (independent verification) | Run tests → execution checks → layered testing → independent eval pipeline |
| **Review scales through AI, not humans** | 0.4 (you review) | 1.3, 2.1, 6.1 | Human reviews AI → AI reviews AI → cycle review → metrics review |
| **Feedback loops must close** | 1.1 (iterate) | 6.2, 7.1 | Manual iteration → verified feedback loops → Curator agent |
| **Specialization beats generalization** | 2.2 | 3.1, 7.2 | Separate writer/tester → specialized agent roles → evolved skill files |
| **Define success before building** | 1.4 (define "better") | 2.4, 4.4 (testable requirements) | Define refactor goal → spec-first dev → persona-driven requirements with acceptance criteria |

---

## RIL Agents Integration

Agents from `~/ClaudeInfra/ril-agents/` that map to each stage.

| Stage | RIL Agent(s) | Plugin | Role in Stage |
| --- | --- | --- | --- |
| 1 | `debugger`, `error-detective` | error-debugging | Bug Fix recipe — investigation and root cause analysis |
| 1 | `test-automator`, `tdd-orchestrator` | unit-testing, tdd-workflows | Test Writer recipe — test generation and TDD discipline |
| 1 | `code-reviewer`, `architect-review` | comprehensive-review | Code Review recipe — quality analysis and architectural review |
| 1 | `legacy-modernizer` | code-refactoring | Refactor recipe — safe incremental restructuring |
| 2 | `test-automator` (separated from builder) | unit-testing | Build-then-test — independent testing agent |
| 2 | `code-reviewer` (as gate) | comprehensive-review | Review-gate — separate review agent checks builder output |
| 3 | `team-lead` | agent-teams | Decomposes work into parallel tasks with ownership |
| 3 | `team-implementer`, `team-reviewer` | agent-teams | Parallel execution with defined roles |
| 4 | `prd-development` | product-planning | PRD generation from feature ideas |
| 4 | `feature-spec`, `acceptance-criteria` | product-specification | Detailed spec + testable acceptance criteria |
| 5 | `product-evaluation`, `post-mortem` | product-evaluation | Structured evaluation and retrospective |
| 6 | Conductor framework | conductor | Autonomous orchestration with track management |
| 7 | `tutorial-engineer` | documentation-generation | Meta — generates evolved skill files and teaching content |

---

## Concepts Not Yet Mapped

| Concept | Source | Notes |
| --- | --- | --- |
| **Agents that edit files must commit them** | LEARNINGS.md | Implied by Stage 1 git workflow? Or explicit in Stage 2+? |
| **Revert functions must not destroy untracked work** | LEARNINGS.md | Stage 3 operational safety. |
| **Declarative pipeline graph** | Synthesis | Stage 7 — self-modifying pipeline architecture. |
| **Incident response workflow** | ril-agents incident-response plugin | What happens when the autonomous pipeline breaks in production. Stage 6 operational concern. |

---

## Concept Count by Stage

| Stage | Name | Mode | Core Concepts |
| --- | --- | --- | --- |
| 0 | See What AI Can Do | Scripted | 5 |
| 1 | Get Real Work Done | Guided-Adaptive | 4 (with 14 observable signals) |
| 2 | Two AIs Are Better Than One | Adaptive + Checkpoints | 4 |
| 3 | Build a Team of AI Specialists | Adaptive + Checkpoints | 5 |
| 4 | From Idea to Buildable Spec | Adaptive + Checkpoints | 6 |
| 5 | Trust But Verify | Fully Adaptive | 6 |
| 6 | Let It Run While You Sleep | Fully Adaptive | 6 |
| 7 | The System Gets Smarter | Fully Adaptive | 5 |
| **Total** |  |  | **41 core concepts, 14 quality dimensions (Stage 1), 27 signal-based (Stages 2-7)** |

---

## Design Decision Log

Decisions made during syllabus design, recorded for context when building teaching scripts and recipes.

### Decision: Adaptive evaluation model, not scripted teaching
**What:** Instead of a scripted curriculum where the teacher delivers every concept in order, we use an adaptive model where the developer does real work and the system teaches only what they're missing.
**Why:** Two independent evaluators (learning experience designer + enterprise adoption strategist) agreed:
- Scripted teaching patronizes senior developers and wastes their time — they'll tell their team it's useless
- Adaptive teaching lets juniors get coaching without the social cost of admitting they need it
- Skeptics convert when AI solves THEIR problem, not a planted exercise
- Adaptive scales better at Reliance's size — different teams have different baselines
**Trade-off:** Harder to guarantee consistency across 500 teams. Eval subagents may misjudge skill level. Manager reporting shifts from "completed exercise 3" to "demonstrated 3/4 concepts."
**Mitigation:** Stage 0 stays scripted (can't evaluate what hasn't been encountered). Observable signals are binary where possible (did they run tests? yes/no). Progress tracking is concept-based, giving managers a clear dashboard.

### Decision: Four teaching modes (Scripted → Guided-Adaptive → Adaptive+Checkpoints → Fully Adaptive)
**What:** Teaching mode progressively loosens as the developer builds mental models.
**Why:** Key design rule: "Never go adaptive on a concept the developer has no mental model for." Stage 0 developers don't know what AI can do — scripted moments of surprise are necessary. Stage 1 developers know the basics but need guidance on real work. Stage 2-3 developers are building real systems. Stage 4+ developers have the mental models and need consulting, not teaching.

### Decision: Eval subagent checks binary signals, not qualitative judgments
**What:** Observable signals are designed to be binary (did they/didn't they) rather than qualitative (was it good enough?).
**Why:** Eval subagents reliably detect "did the developer run the tests" but unreliably judge "was the context the developer provided good enough." Binary signals are consistent at scale. Qualitative judgments are where the facilitator (main agent) adds value — it interprets the results, not the eval subagent.

### Decision: Lead with impact, not safety (Stage 1 reordering)
**What:** Stage 1 recipes reordered from risk-based (Code Review → Test Writer → Bug Fix → Refactor) to impact-based (Bug Fix → Test Writer → Code Review → Refactor).
**Why:** Target audience is skeptics. Bug fix first produces a solved problem. Code review first produces a list of opinions. By Stage 1, trust is already established (Stage 0 taught git safety and the approval loop).

### Decision: Consolidate Stage 1 from 14 concepts to 4 core + observable signals
**What:** Each recipe teaches ONE core concept with 3-4 observable signals. Supporting ideas are teaching triggers, not standalone exercises.
**Why:** Original 14-concept Stage 1 treated every observation as a standalone teaching moment. The adaptive model evaluates naturally — signals like "scoped the request" and "ran the tests" are checked, not lectured on.

### Decision: Reframe from "dangers of AI" to "power of AI + smart practices"
**What:** Every concept leads with what AI can do, then follows with the practice that makes it reliable.
**Why:** Skeptics who hear "AI lies, AI fakes tests" conclude "so why bother?" The same content framed as "AI fixes your bug in 2 minutes — here's how to verify the fix" makes the practice feel like common sense.

### Decision: Insert Stage 4 (Idea → Spec) before autonomous operation
**What:** New stage teaching how to turn feature ideas into buildable specifications.
**Why:** Autonomous pipelines are only as good as what you feed them. The DDD project proved that vague specs produce vague products. The artifact chain (one-pager → requirements → system design) provides structure. Persona-driven decomposition, testable requirements, kill criteria, and AI-assisted quality gates are all patterns from the DDD system.
**Source:** `C:\Users\donid\ClaudeProjects\ddd-mcp-server`

### Decision: Insert Stage 5 (Evals) before autonomous operation
**What:** New stage teaching how to build evaluation systems.
**Why:** The pipeline taught us: 32 tests "passed" but never executed, 73% of integration tests never ran, 23 failing tests normalized as "acceptable." Autonomy without verification is negligence.
**Source:** AgenticSystem learnings + 16-agent evaluation synthesis + testing/verification research.

### Decision: 8 stages, not 6
**What:** Expanded from 6 stages (0-5) to 8 stages (0-7) by adding Specs and Evals.
**Why:** The jump from "multi-agent pipelines" to "autonomous cycles" skipped two critical prerequisites. The two new stages connect to existing cross-cutting themes — "specificity determines quality" threads from prompts (Stage 0) through specs (Stage 4) to evals (Stage 5).

### Decision: Stage 4 draws from DDD, not generic agile/product management
**What:** The spec stage uses the DDD artifact chain and quality gates, not generic user stories.
**Why:** The DDD system was built for Reliance teams — their vocabulary, scale, and decision-making patterns. More rigorous than "write user stories" and maps directly to what an AI pipeline needs.

### Decision: Use RIL Agents as the execution layer
**What:** Recipes invoke existing agents from `~/ClaudeInfra/ril-agents/` rather than building custom agents.
**Why:** 112+ specialized agents already tested and composable. The `code-reviewer`, `test-automator`, `debugger`, `team-lead`, `prd-development`, `feature-spec`, and `acceptance-criteria` agents map directly to our stage concepts.
**Source:** `~/ClaudeInfra/ril-agents/` — 193 agent files, 146 skills, 79 commands.

### Decision: TDD deferred as standalone concept
**What:** TDD is available via `tdd-orchestrator` but not a core teaching concept.
**Why:** TDD is a software methodology, not an AI concept. The Test Writer recipe naturally demonstrates write-run-fix cycles. If teams struggle with test quality, TDD can be added as an optional Stage 2 recipe.

### Decision: Context management is operational, not a teaching concept
**What:** How to manage context windows is not taught — the platform should handle it transparently.
**Why:** Teaching developers to manually manage context is teaching workarounds for platform limitations. The concepts that matter (agents need memory, shared state needs discipline) are taught.

### Decision: Incident response deferred to reference material
**What:** Not a core teaching concept, available as reference for Stage 6.
**Why:** Reactive operational knowledge, not progressive capability. If incidents become a common pain point, it becomes a recipe.

### Decision: Quality ratings (Strong/Adequate/Weak) not binary signals
**What:** The eval subagent rates quality dimensions on a 3-point scale, not binary yes/no. Each rating has specific facilitator language for praise (strong), light coaching (adequate), and targeted coaching (weak).
**Why:** Binary signals answer "did they do it" — but in a guided recipe, of course they did it. The real question is "how well did they do it." A developer who says "the login is broken" and a developer who says "login fails after OAuth redirect, I checked the callback URL, I think the session isn't persisting" both "provided context" — but the quality difference is the entire teaching opportunity. LLM eval subagents are good at qualitative assessment with specific evidence (they see the full transcript). The facilitator makes the final call, so a slightly off eval rating just means the facilitator adjusts.
**Trade-off:** Qualitative ratings are less consistent across teams than binary checks. Mitigated by: the facilitator interprets (not blindly follows) the eval, and strong/adequate/weak is a coarse enough scale to be reliable.

### Decision: Stage 4 downgraded from Fully Adaptive to Adaptive + Checkpoints
**What:** Stage 4 (From Idea to Buildable Spec) uses Adaptive + Checkpoints mode with facilitator check-ins after concepts 4.2 and 4.5.
**Why:** Spec writing (persona decomposition, testable requirements, kill criteria) is a new mental model for most developers — even experienced ones. This is closer to a new concept introduction than a skill application, so it needs more guidance. Fully Adaptive would risk developers producing a superficial spec and thinking they're done.

### Decision: No "good enough" tier acknowledged in the syllabus
**What:** Although evaluators predicted most teams plateau at Stage 1-2, the syllabus does not endorse a stopping point.
**Why:** Labeling a tier as "good enough" gives people permission to stop. The progression should always pull people forward by showing what they unlock next. Natural plateau is fine — endorsing it is not.

### Decision: Practical mechanisms added (skip, stuck paths, inter-stage gates)
**What:** Added three mechanisms to the teaching framework: skip/challenge assessment for experienced devs, stuck path handling (no bug, tests won't run, AI loops), and self-directed inter-stage gates with guardrails.
**Why:** Evaluators flagged these as missing. Without skip mechanisms, experienced devs are forced through basics. Without stuck paths, the first infrastructure issue kills the teaching session. Without clear gates, progression is ambiguous.

### Decision: Dual-mode recipes — working recipe is standalone, teaching wraps it
**What:** Each stage has clean working recipe YAMLs (no teaching code) that run independently. The teach-wrapper meta-recipe loads the working recipe as a Goose sub-recipe and adds the facilitator + eval subagent around it. Developers reuse working recipes forever after teaching is complete.
**Why:** Verified against Goose mechanics — sub-recipes are reusable YAML components invoked by name, `delegate(async: true)` supports background eval, and recipes run standalone with no dependency on the wrapper. This means `goose run bug-fix` is a clean tool experience post-training.
**Implication:** Working recipes must be designed FIRST as clean, reusable tools. Teaching is a layer on top, not mixed in.

### Decision: Progression tracking is custom (Goose has none)
**What:** We build our own concept progression tracking — a JSON state file per developer recording which concepts are demonstrated and at what quality rating.
**Why:** Goose has no built-in state/progression API. Each recipe run is stateless. We need to persist: concept ID, quality rating (strong/adequate/weak), timestamp, stage completion status. This feeds the manager dashboard.

### Decision: Module designer skill file, not a standalone agent
**What:** Build a skill file that any session loads when designing modules — encodes recipe structure, teaching patterns, quality dimensions, and CourseForge rules. Not a standalone agent.
**Why:** A skill file is loaded into context on demand. A standalone agent would need to be invoked separately. The module design task is done BY the session's main agent with the skill file's knowledge, not delegated to a separate agent.

### Decision: CourseForge rules that survived into adaptive model
**What:** Kept: never break fourth wall, module previews (bridges), few turns, clear I/O, one skill per exercise, watch-then-do, domain simplicity. Dropped: verbatim scripts, rigid check gates, pipeline orchestration mechanics.
**Why:** The pedagogical principles are universal. The delivery mechanism (scripted vs adaptive) changed, but "keep it simple," "show before asking them to do," and "never reveal the machinery" apply regardless of teaching mode.
