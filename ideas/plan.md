# RIL Agentic Harness — Planning Document

**Started:** 2026-04-12
**Status:** Research & architecture decisions in progress
**Goal:** Build an adaptable agentic harness for Reliance teams that grows with them from 0 → 1 → 2 → ... with agentic development, using "recipes" as progressive agentic workflows.

---

## Core Concept

Combine three systems:
- **Goose** (battle-tested agent platform by Block, now Linux Foundation) — provides the runtime, recipe system, sub-recipes, subagents, ACP provider bridge, MCP extensions, desktop app + CLI
- **Our Pipeline** (AgenticSystem) — provides the hard-won design patterns: file ownership, circuit breakers, 4-tier testing, escalation routing, cycle review, separated concerns
- **CourseForge** — provides the teaching model: Say/Check/Action scripts, intake profiling, exercise quality scorecard, self-teaching architecture

---

## Guiding Principles

### 1. Meet teams where they are, not where we want them to be
A team that's never used AI coding doesn't need circuit breakers and escalation routing. They need to see Claude read a file and explain it. Every recipe starts from the team's current maturity. The stage model is diagnostic, not aspirational.

### 2. The system teaches — humans don't have to
The harness itself guides developers through each recipe hands-on (CourseForge model). No separate training program, slide decks, or workshops. A developer launches a teaching recipe and Claude walks them through it. This scales — you don't need an expert in every room.

### 3. Earn trust before adding complexity
Each stage proves the value of the previous one before introducing the next concept. A team shouldn't move to multi-agent pipelines until they've seen single-agent recipes fail in ways that multi-agent solves. Complexity is the reward for outgrowing simplicity.

### 4. Enforce, don't suggest
Agents ignore instructions under pressure. File ownership, circuit breakers, and escalation must be mechanically enforced — not hoped for. Where Goose can't enforce today (no hooks), we use extension scoping and parent orchestration as best available enforcement, and build hooks when stronger guarantees are needed.

### 5. Separation of concerns is non-negotiable
The agent that writes code must never be the agent that tests it. The agent that reviews must not be the agent that builds. Self-verification bias is how autonomous systems silently rot. Every multi-agent recipe must respect this.

### 6. Recipes are the unit of knowledge transfer
Not documentation, wikis, or runbooks. A recipe is executable — you run it and it works. When a team discovers a workflow that works, they capture it as a recipe. When we want to teach a pattern, we express it as a recipe. Recipes are how knowledge moves between teams.

### 7. Fork light, stay mergeable
We don't own Goose's Rust core. Every change lives at the recipe/extension layer so we can pull upstream improvements without merge conflicts. If we ever touch the core (hooks), we design it as an upstream contribution, not a private divergence.

### 8. Provider-agnostic, Claude Code default
Claude Code is the default — everything works out of the box with a single Claude Max subscription. But recipes never hardcode a provider. They specify **capability tiers** (e.g., "needs strong reasoning", "needs fast structured output"), and the harness maps those to whatever providers the team has configured. Today that's Claude and optionally Codex. Tomorrow it's Ollama, local models, or whatever else Goose's ACP supports. When a team adds a new provider, they update the tier mapping — recipes don't change.

### 9. Recipes specify tiers, not models
Recipes say `tier: reasoning` or `tier: fast`, not `model: claude-opus`. A config file maps tiers to providers. This is how we support Claude-only teams, Claude+Codex teams, and future local-model teams with the same recipe library. Similar to how our pipeline already uses model tiers in `project_config.json`.

---

## Decision Log

### Decision 1: Fork Goose, don't build from scratch
**Date:** 2026-04-12
**Decision:** Fork https://github.com/aaif-goose/goose and extend at the recipe layer
**Why:**
- Goose is battle-hardened — used internally by Block at scale, now under Linux Foundation
- Our pipeline has not been used effectively in production yet
- Goose already has: recipe YAML format, parameterization, scheduling, retry logic, deeplink sharing, desktop app, CLI, community recipe cookbook
- Our concepts (file ownership, circuit breakers, escalation, teaching) are *patterns* that can be expressed as Goose recipes and extensions — they don't require a new runtime
- Building our own would mean reimplementing what Goose already provides (UI, MCP integration, provider management, session handling)

**Alternatives considered:**
- Build our own Python harness inspired by Goose's recipe format — rejected because we'd be reinventing battle-tested infrastructure
- Use Goose for stages 0-2, our harness for 3+ — rejected because two systems is confusing for teams learning

### Decision 2: Use ACP (Agent Client Protocol) for subscription-based access
**Date:** 2026-04-12
**Decision:** Use Goose's ACP provider adapters to run on Claude Max and Codex subscriptions — no API keys needed
**Why:**
- Doni's team uses Claude Code (Max subscription) and Codex (OpenAI subscription), not API keys
- ACP spawns the CLI tools as subprocesses and communicates via JSON-RPC over stdin/stdout
- Uses existing `claude auth login` / Codex login authentication
- No per-token API billing

**How it works:**
```
Goose recipe → claude-acp adapter → spawns `claude` CLI (Max subscription)
Goose recipe → codex-acp adapter → spawns `codex` CLI (subscription)
```

**Setup:**
```bash
npm install -g @zed-industries/claude-agent-acp   # Claude
npm install -g @zed-industries/codex-acp           # Codex
export GOOSE_PROVIDER=claude-acp                   # or codex-acp
```

**Model selection:** `default` (opus), `sonnet`, `haiku` for Claude. Configurable per-subagent.
**Limitation:** Subscription rate limits apply (not API throughput).

### Decision 3: Extend at the recipe layer, don't touch Rust core (initially)
**Date:** 2026-04-12
**Decision:** All our additions will be recipes (YAML), sub-recipes, and MCP extensions (Python/JS). We won't modify Goose's Rust source code unless we need to add hooks later.
**Why:**
- Keeps our fork easy to maintain and merge upstream changes
- Goose's recipe system + sub-recipes + subagents already support multi-agent orchestration natively
- Extension scoping lets us limit tools per subagent (partial file ownership)
- Our pipeline patterns translate well to recipe instructions and sub-recipe composition

### Decision 4: Hooks are deferred — add later if needed
**Date:** 2026-04-12
**Decision:** Start without deterministic hooks (like Claude Code's PreToolUse/PostToolUse). Add them later if LLM-enforced orchestration proves insufficient.
**Why not now:**
- Goose has NO equivalent to Claude Code's deterministic hooks today
- Goose's "Adversary Mode" is LLM-based (probabilistic, fail-open) — not reliable for enforcement
- Extension scoping + parent-level orchestration may be sufficient for stages 0-3

**Why we're not worried:**
- Goose already has a `ToolInspector` trait — an inspector pipeline that runs before every tool call
- 5 inspectors already exist (security, egress, adversary, permissions, repetition)
- Adding a deterministic `ScriptHookInspector` is ~200 lines of new Rust code, 3-5 lines changed in existing files
- It piggybacks on architecture literally designed for this pattern
- Estimated effort: 1-2 days for PreToolUse (allow/deny), medium effort for PostToolUse
- This would also be a valuable upstream contribution to the Goose community

**Technical details for when we build it:**
- Implement `ToolInspector` trait in new `crates/goose/src/hooks/script_hook_inspector.rs`
- Register in `Agent::create_tool_inspection_manager()` (agent.rs line 258)
- Hook receives tool name + args as JSON, runs user script, reads exit code (0=allow, 1=deny, 2=require approval)
- For argument modification: add `AllowModified` variant to `InspectionAction` enum

### Decision 5: LLM-based orchestration first, code-based orchestration only if needed
**Date:** 2026-04-12
**Decision:** Use Goose's native LLM-driven subagent orchestration with detailed recipe instructions. Only introduce code-based orchestration (MCP extension replicating autonomous_dev.py logic) if we observe the LLM-based approach failing at higher stages.
**Why:**
- Goose's subagent system is more capable than initially assessed — supports parallel execution, extension scoping, per-subagent model/provider overrides, async background tasks, structured result returns
- For stages 0-2, LLM orchestration is clearly sufficient (simple delegation, 1-2 subagents)
- For stages 3+, well-written recipe instructions may be enough — the parent orchestrator's job is routing and gating, which is simpler than the work itself
- Starting with Goose's native model means less custom code to maintain, easier to stay mergeable with upstream
- If issues emerge, we have a clear upgrade path: build a Python MCP extension that implements deterministic sequencing, circuit breakers, and escalation

**What we'll watch for (triggers to introduce code-based orchestration):**
- Parent LLM skipping agents in a multi-step sequence
- Parent LLM not respecting failure thresholds (should stop after N failures but doesn't)
- Parent LLM routing to wrong specialist on escalation
- Subagent results not being properly validated before proceeding
- Any case where the LLM "shortcuts" the pipeline by collapsing steps

**How Goose subagents actually work (for reference):**

Two internal systems:
1. **`summon` extension** — Main system. Parent LLM calls `delegate(instructions, extensions, provider, model, max_turns, async)`. Creates fresh Agent + Session, runs full conversation, returns result as tool call response.
2. **`orchestrator` extension** — Conversational. Parent creates named agent session, sends messages iteratively. Child persists across messages.

Key mechanics:
- Each subagent gets own context (fresh history, own system prompt, own provider)
- Extension scoping filters tools at spawn time
- No nesting — subagents cannot spawn subagents (tool hidden + runtime guard + system prompt)
- Parallel via `tokio::spawn` — up to 5 concurrent (configurable via `GOOSE_MAX_BACKGROUND_TASKS`)
- Results return as tool call results (text or structured JSON via `final_output_tool`)
- Subagents forced to `Auto` permission mode (prevents hanging on approvals)
- Inter-agent communication via file artifacts on disk

How this differs from our pipeline:
| Aspect | Goose | Our Pipeline |
|--------|-------|-------------|
| Spawning | LLM decides (prompt-driven) | Script decides (code-driven) |
| Orchestration | Parent LLM via natural language | autonomous_dev.py via Python |
| Inter-agent comms | File artifacts on disk | State files + structured JSON |
| Failure handling | 5-min timeout, silent failure | Circuit breakers, escalation routing |
| Tool scoping | Filter extensions by name | File ownership matrix |
| Parallelism | Up to 5 via tokio | ThreadPoolExecutor for panels |
| Who decides flow? | The LLM | The code |

---

## Research Summary

### Goose Architecture
- **Language:** 58% Rust, 34% TypeScript
- **Core crates:** goose (main), goose-cli, goose-server, goose-sdk, goose-mcp, goose-acp
- **UI:** Desktop app (Electron-style) + CLI + embedded API
- **Now maintained by:** Agentic AI Foundation (AAIF) at Linux Foundation (previously Block)
- **Provider support:** 15+ LLM providers — Anthropic, OpenAI, Google, Ollama, OpenRouter, Azure, Bedrock, etc.
- **Extension model:** MCP (Model Context Protocol) — 70+ extensions

### Goose Recipe System
- YAML files that package: instructions, prompt, extensions, parameters, retry logic, structured output
- Parameterized with `{{ variable_name }}` templates
- Shared as deeplinks, exported YAML, or clipboard
- Can be scheduled via cron for recurring autonomous execution
- No API keys/credentials embedded — privacy preserved

### Goose Sub-Recipes & Subagents (Key for our multi-agent patterns)
- **Sub-recipes:** Predefined YAML templates invoked by name from a parent recipe
- **Subagents:** Independent AI instances with own context, spawned dynamically
- **Parallel execution:** Multiple `subagent()` calls in one message run concurrently
- **Per-subagent settings:** Different model, provider, max_turns per subagent
- **Extension scoping:** Limit which MCP extensions each subagent can access
- **`sequential_when_repeated: true`** — prevent parallel runs of certain tasks
- **Summary mode:** Subagents return concise summaries by default

### Goose Permission/Safety Model (the hooks gap)
- **Adversary Mode:** LLM-based tool call reviewer — natural language rules, probabilistic, fail-open
- **Smart Approval:** Pattern matching on read/write/delete — not user-extensible
- **macOS Sandbox:** OS-level restrictions — Desktop Mac only
- **No deterministic hooks** — no scriptable PreToolUse/PostToolUse equivalent
- **`ToolInspector` trait exists** — clean abstraction for adding new inspectors (our path to hooks later)

### Our Pipeline Patterns to Port as Recipes

| Pattern | Description | Recipe Stage |
|---------|-------------|-------------|
| File ownership matrix | Each file has ONE owner agent | Stage 2+ |
| Separated concerns | Agents that write don't test | Stage 2+ |
| 4-tier testing | Parse → Structure → Contract → Execution | Stage 2-3 |
| Circuit breakers | N consecutive failures → stop + escalate | Stage 3+ |
| Escalation routing | Failed agent → specialist agent or human | Stage 3+ |
| Cycle review | Holistic review after N sessions | Stage 4+ |
| Skill files | Per-agent knowledge documents | Stage 1+ |
| Progressive assertion checking | Test before build, gate on red | Stage 2+ |
| Meta-improvement | System edits its own pipeline | Stage 5 |

### CourseForge Patterns to Port

| Pattern | Description | Use In Harness |
|---------|-------------|----------------|
| Say/Check/Action scripts | Structured teaching format — Claude follows verbatim | Teaching recipes that guide devs through each stage |
| Exercise quality scorecard | 10-criterion rubric, ≥70/100, no criterion <6 | Validate recipe exercises teach the right skills |
| Intake profiling | Company + role interviews → standardized profiles | Team onboarding — assess maturity, recommend starting stage |
| Dual-pass quality gate | Consistency check + pedagogical review | Ensure teaching recipes actually work |
| Playbook pattern | Captured lessons learned | Document what works/fails during rollout |
| SCRIPT_INSTRUCTIONS.md | Meta-rules for how Claude teaches | Embedded in teaching recipe instructions |

---

## Maturity Stage Model

### Stage 0: "From Chat to Code" (never used AI coding beyond ChatGPT)
**Concepts:** AI can see your code, AI can change your code, git as safety net, AI makes mistakes, prompt quality matters
**Recipe:** Single recipe with 5 acts loaded via `load()`, subagents handle all code actions
**Architecture:** Teacher/Hands pattern (see Stage 0 Design section below)
**Duration:** ~45-60 minutes
**Permission mode:** Manual approval (user approves every action)

### Stage 1: "Real Work" (0 → 1)
**Concepts:** Code review workflow, writing tests, bug fixing, refactoring, iteration, when to trust vs verify
**Recipes:** code-review, test-writer, bug-fix, refactor (each has teaching + working mode)
**Architecture:** Teaching wrapper for first run, working mode for subsequent runs
**Permission mode:** Smart approval (reads auto-approved, writes shown)
**Key shift:** From learning the tool to getting real work done. Real branches, real PRs.

### Stage 2: Agent + Verification (1 → 2)
**Concepts:** Self-verification bias, separated concerns, file ownership
**Recipes:** build-then-test, review-gate, spec-first

### Stage 3: Multi-Agent Pipelines (2 → 3)
**Concepts:** Agent roles, escalation, circuit breakers, 4-tier testing
**Recipes:** three-agent-pipeline, parallel-reviewers, escalation-routing

### Stage 4: Autonomous Cycles (3 → 4)
**Concepts:** Cycle review, meta-improvement, learnings capture, false positive detection
**Recipes:** ten-session-cycle, cycle-review, continuous-dev

### Stage 5: Self-Improving Systems (4 → 5)
**Concepts:** Curator agent, skill file evolution, rule pruning, metrics-driven improvement
**Recipes:** skill-evolution, pipeline-self-edit, metrics-dashboard

---

## Team Collaboration & Multi-Language Decisions

### Decision 6: Per-team onboarding config, not runtime detection
**Date:** 2026-04-12
**Decision:** Configure language, stack, and team context once at onboarding via an interactive onboarding recipe. Output is a project config file + personalized CLAUDE.md section that makes all subsequent recipes work without runtime guessing.
**Why:**
- Runtime language detection is unreliable and adds latency to every recipe
- Teams know their stack — ask once, configure permanently
- Different stacks need different test commands, build tools, file structure conventions
- Onboarding config also captures team maturity, enabling proper stage recommendations

### Key team collaboration decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Session isolation | Branch-per-developer, PR-based workflow | Prevents agents from colliding on shared branches |
| Recipe location | In-repo `/.goose/recipes/` directory | Version controlled, reviewed via PR, shared across team |
| Git workflow | Feature branches, recipes produce PRs not direct commits | Standard team workflow, enables code review |
| Project config (CLAUDE.md) | Shared in repo, changes require PR review | It's the project's "constitution" — shouldn't be unilaterally changed |
| Credentials | Per-developer (`~/.config/goose/`), never in repo | Security baseline |
| Language recipes | Generic recipes + per-project onboarding config | One recipe library works across all teams/languages |
| Extensions | Curated sets per stack, configured at project level | Teams get relevant tools without manual setup |
| Skill files | Language-agnostic principles, language-specific examples within same file | Maintainable, teaches the pattern not the syntax |

---

## Onboarding Recipe Specification

### Purpose
An interactive recipe that profiles a project and its team, then generates configuration that makes all subsequent recipes work out of the box. Run once per project, not per developer.

### Where Config Lives — The Many-to-Many Model
Config lives in the **project repo**, not in the harness or per-developer. This handles the real-world relationships cleanly:

- **One developer, multiple projects** — Each project has its own `.goose/` config. Developer's personal progression (stage) is stored locally.
- **One team, multiple projects** — Each project gets its own onboarding because stacks differ (Team A's backend is Python, their frontend is TypeScript — separate configs).
- **One project, multiple teams** — They share the same `.goose/project_config.yaml` because it describes the project, not the team.

| What | Where | Scope |
|------|-------|-------|
| Stack, commands, extensions, conventions | `{project-repo}/.goose/` | Per-project, shared via git |
| Current stage, completed recipes | `~/.config/goose/progression/` | Per-developer, local |
| Recipes, teaching modules, onboarding recipe | Harness repo (our Goose fork) | Global, shared across all teams/projects |

### Who Runs It
One team member (typically the tech lead or whoever is setting up the harness). They run the onboarding recipe once on the project's codebase. The output is committed to the repo so every other developer gets the config automatically when they pull.

### Inputs
- Path to team's codebase (or repo URL)
- Access to talk to a team member (interactive Q&A)

### Outputs (All Committed to Repo)

All output files live in `/.goose/` in the project root and are version controlled:

| File | Purpose | Who Uses It |
|------|---------|-------------|
| `project_config.yaml` | Stack, commands, tiers, extensions, team profile, progression defaults | Every recipe reads this to know the project |
| `team_context.md` | Human-readable summary of stack, commands, conventions — injected into recipe prompts | Every recipe includes this in its instructions |
| `recommended_recipes.md` | Starting path: which recipes to try first at Stage 0, how to advance/skip | Developers read this to know where to start |

**Sharing mechanism:** Git. The onboarding output is committed and pushed. Every developer who clones or pulls the repo gets the config. No separate distribution step, no config sync tool, no manual copying.

**Re-running:** If the project changes significantly (new language added, CI tool changed, team restructured), any team member can re-run the onboarding recipe. It overwrites the existing config, which goes through PR review like any other code change.

### Phase 1: Auto-Detect (Explore Codebase)

The recipe explores the project and detects as much as possible without asking:

**Language & Framework**
- Scan file extensions to determine primary language(s)
- Read config files: `package.json`, `requirements.txt`, `Pipfile`, `go.mod`, `pom.xml`, `build.gradle`, `Cargo.toml`, `Gemfile`, `.csproj`
- Identify frameworks: React/Next.js/Express, Django/Flask/FastAPI, Spring Boot, Gin/Echo, Rails, .NET, etc.

**Test Framework & Commands**
- Detect test runner from config: `jest.config`, `pytest.ini`, `setup.cfg [tool:pytest]`, `go test`, `mvn test`, etc.
- Find existing test files and their location patterns (`test/`, `__tests__/`, `*_test.go`, `*Test.java`, `spec/`)
- Determine test run command (`npm test`, `pytest`, `go test ./...`, `mvn test`, `cargo test`)
- Check for coverage tools (`istanbul`, `coverage.py`, `go tool cover`)

**Project Structure**
- Map directory layout: where source lives, where tests live, where config lives
- Detect monorepo patterns (multiple `package.json`, workspace configs)
- Find build output directories
- Identify key entry points (`main.py`, `index.ts`, `cmd/main.go`, `src/main/java/`)

**Git Workflow**
- Branch naming patterns from `git branch -a` history
- PR template existence (`.github/pull_request_template.md`)
- Protected branch configuration (if accessible)
- Commit message conventions from `git log`

**CI/CD Pipeline**
- Detect CI tool: `.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml`, `.circleci/`, `azure-pipelines.yml`
- Read CI config to understand: what checks run, what deploys look like, required status checks
- Find any deployment configs (Docker, Kubernetes, serverless)

**Existing Tooling**
- Linters: `.eslintrc`, `.flake8`, `.golangci.yml`, `checkstyle.xml`
- Formatters: `.prettierrc`, `black`, `gofmt`
- Type checking: `tsconfig.json`, `mypy.ini`, `pyright`
- Database: look for migration files, ORM configs, connection strings in env templates

**MCP-Relevant Services**
- GitHub/GitLab from git remote URLs
- Database type from connection strings or ORM config
- Cloud provider from deployment configs
- Project management from config files or integrations

### Phase 2: Ask What Couldn't Be Detected

Interactive questions for the team member:

**Team Profile**
- How many developers on the team?
- What roles? (frontend, backend, fullstack, DevOps, QA)
- Does the team do code reviews? How? (PR-based, pair programming, ad hoc)
- Any compliance or security constraints? (air-gapped, data residency, audit requirements)

**Goals**
- What's the primary goal? (ship faster, fewer bugs, reduce manual work, learn AI-assisted development)
- Any specific pain points? (slow code reviews, test coverage gaps, deployment issues, knowledge silos)
- What does success look like in 3 months?

**Note: No maturity assessment.** We do NOT ask about prior AI/agentic experience. Everyone starts at Stage 0. The progression system teaches the concepts in order. Teams that already know the basics can use skip commands to move through stages quickly, but it's their choice — not our guess.

### Phase 3: Generate Onboarding Config

Output files created in the project:

**`/.goose/project_config.yaml`**
```yaml
# Auto-generated by onboarding recipe — [date]
# Team: [team name]

project:
  name: [detected or asked]
  languages: [python, typescript]  # primary languages
  frameworks: [fastapi, react]
  
build:
  command: "npm run build"          # or "mvn package", "go build ./...", etc.
  test_command: "pytest"            # or "npm test", "go test ./...", etc.
  lint_command: "ruff check ."      # or "eslint .", etc.
  coverage_command: "pytest --cov"
  
structure:
  source_dirs: ["src/", "app/"]
  test_dirs: ["tests/", "__tests__/"]
  config_dir: ".config/"
  docs_dir: "docs/"
  
git:
  workflow: "feature-branch"        # or "trunk-based", "gitflow"
  branch_convention: "feature/{ticket}-{description}"
  pr_required: true
  protected_branches: ["main", "develop"]
  commit_convention: "conventional"  # or "freeform"

ci:
  tool: "github-actions"
  required_checks: ["test", "lint", "build"]
  
team:
  size: 5
  roles: ["frontend", "backend", "fullstack"]
  review_process: "pr-based"
  
tiers:
  reasoning: "claude-acp/default"   # maps to opus
  fast: "claude-acp/sonnet"
  quick: "claude-acp/haiku"
  # Uncomment when Codex is available:
  # diverse: "codex-acp/default"

progression:
  current_stage: 0                  # everyone starts at 0
  completed_stages: []              # tracks which stages have been completed or skipped
  # Skip commands: `goose skip-to --stage 2` marks stages 0-1 as skipped
  # Progress commands: `goose progress` shows current stage + what's next
  
extensions:
  recommended:
    - developer                     # always
    - github                        # detected from git remote
    # - supabase                    # if detected
    # - linear                      # if team uses it
```

**`/.goose/team_context.md`** (injected into recipe instructions)
```markdown
# Team Context — Auto-Generated

## Tech Stack
- Primary: Python 3.11 + FastAPI
- Frontend: TypeScript + React 18
- Database: PostgreSQL via SQLAlchemy
- Tests: pytest (backend), jest (frontend)

## Commands Quick Reference
| Action | Command |
|--------|---------|
| Run all tests | `pytest` |
| Run frontend tests | `npm test` |
| Lint | `ruff check . && eslint src/` |
| Build | `npm run build` |
| Start dev server | `uvicorn app.main:app --reload` |

## Project Structure
[detected directory map]

## Team Conventions
- PRs required for all changes to main
- Conventional commits
- Tests required for new features
- [any other detected conventions]
```

**`/.goose/recommended_recipes.md`**
```markdown
# Your Recipe Path

Everyone starts at Stage 0. If you already know the basics, use skip commands to move ahead.

## Stage 0 — Start Here
1. `/recipes/stage-0/hello-claude.yaml` — First interaction with Claude on your codebase
2. `/recipes/stage-0/read-and-explain.yaml` — Claude reads and explains your code
3. `/recipes/stage-0/first-edit.yaml` — Make a simple change with Claude's help

When you're comfortable: `goose advance` to move to Stage 1
Already know this? `goose skip-to --stage 1` to jump ahead

## Stage 1 — Single-Agent Recipes
1. `/recipes/stage-1/code-review.yaml` — Have Claude review a PR
2. `/recipes/stage-1/test-writer.yaml` — Generate tests for existing code
3. `/recipes/stage-1/bug-fix.yaml` — Describe a bug, let Claude find and fix it

## Stage 2 — Agent + Verification
4. `/recipes/stage-2/build-then-test.yaml` — Separated build + test agents
5. `/recipes/stage-2/spec-first.yaml` — Spec → build → validate pipeline

Each stage unlocks via `goose advance` (after completing recipes) or `goose skip-to --stage N` (to jump ahead).
```

### Progression & Skip Commands

The harness tracks each developer's current stage in `/.goose/project_config.yaml`. Commands:

| Command | What it does |
|---------|-------------|
| `goose advance` | Marks current stage complete, unlocks next stage's recipes |
| `goose skip-to --stage N` | Marks stages 0 through N-1 as skipped, sets current stage to N |
| `goose progress` | Shows current stage, completed/skipped stages, next recommended recipe |
| `goose reset-stage` | Resets back to Stage 0 (for re-learning or new team members) |

**Skip doesn't delete access** — a developer who skips to Stage 2 can still run Stage 0 and 1 recipes. Skip just changes what `goose progress` recommends and which teaching modules are surfaced.

**Per-developer, not per-team** — progression is tracked per developer (stored locally), not per project. One team member can be at Stage 3 while another is at Stage 0. The project config (stack, commands, extensions) is shared; the progression is personal.

### Phase 4: Validate

Run a simple smoke test on the actual codebase:
1. Execute the detected test command — confirm it works
2. Run a simple code-review recipe on a recent commit — confirm Goose can read and reason about the code
3. Verify MCP extensions connect (GitHub, etc.)
4. Report results to the team member

### Phase 5: Handoff

Present the team member with:
- Summary of what was detected and configured
- Starting point: Stage 0, first recipe to try
- How to skip ahead if they already know the basics
- How to customize the config if anything was wrong
- How to re-run onboarding if the team or project changes

---

## System Design Decisions (from gap analysis, 2026-04-12)

### Setup & Installation
**Decision:** Package as much as possible into a single install script + an MD file that can be fed to any AI to complete the rest.
- Install script handles: Goose, Node.js, ACP adapters, Claude Code auth prompt
- MD file handles: anything that requires interactive decisions or environment-specific config
- Goal: zero-assumption setup for someone who's only used ChatGPT

### Motivation ("The Why")
**Decision:** Don't create a separate motivation document. Build the "why" into teaching moments within recipes themselves. Each recipe should make the value self-evident through the experience.

### Safety & Trust Building
**Decision:** Critical theme in Stage 0 recipes. Specific design choices:
- Show what the AI is about to do before it does it (preview diffs)
- Teach git as the undo button early
- Permission modes map to stages: manual approval (Stage 0) → smart approval (Stage 1-2) → autonomous (Stage 3+)
- Early recipes should intentionally produce bad code to teach recovery — the user learns that AI makes mistakes, how to spot them, and how to fix them. This builds trust through competence, not blind faith.

### Failure & Recovery Training
**Decision:** Build directly into recipes, not as a separate module. Specific approach:
- Some early recipes intentionally write bad code, then walk the user through identifying and fixing the problem
- Teaches: how to read diffs, how to revert, how to give better instructions, how to intervene mid-recipe
- The lesson is: "AI will make mistakes — your job is to catch them and guide corrections"

### Success Metrics
**Decision:** Plug into existing project scope, not abstract metrics. Approach:
- During onboarding, capture the team's current project scope and estimated timeline
- Measure: did they complete it faster with the harness?
- Also track: recipes completed, stage progression, recipe-assisted PRs merged
- This makes the value proposition concrete and tied to real work

### Onboarding Ownership & Progression Model
**Decision:** Doni runs onboarding centrally. Key design changes:
- **Teams don't advance — individual users advance.** The system recognizes when a user is ready and offers the next recipe.
- **Readiness detection:** The system observes how the user performs in current-stage recipes (confidence, speed, quality of interaction) and suggests advancement when appropriate. Not a gate — a nudge.
- **Recipe onboarding:** Each new recipe a user moves to should adapt itself based on:
  - What the user did in earlier recipes (learnings about their working style)
  - Current state of the repo (changes made since onboarding)
  - This means recipes read a per-user context file that accumulates observations

### Conversation Log Access
**Decision:** Save user conversation logs to a central location Doni can access. Requirements:
- Opt-out mechanism — users must be able to decline logging
- Simple implementation — consider: Goose session logs already exist locally, could sync to a shared location (S3 bucket, shared drive, or git repo)
- Purpose: Doni can review how teams are using the system, identify friction points, improve recipes
- Privacy: logs should be anonymizable, no credentials captured

### Sandbox Approach
**Decision:** No separate sandbox project. Instead, users work on a local clone of their real codebase but don't push changes during early stages. Benefits:
- Exercises are immediately relevant (it's their actual code)
- No artificial "tutorial project" to learn and then re-learn on real code
- Git branch isolation provides safety: work on a throwaway branch, delete if needed
- Stage 0-1 recipes should explicitly create a practice branch and remind users they can safely discard it

### Recipe Catalog
**Decision:** Defer. A recipe library is just YAML files in a directory — easy to point any AI at later.

### Teaching Content Design
**Decision:** TBD — see open question below about sequencing.

---

## Open Questions (for future sessions)

1. **Fork organization:** Do we fork under a Reliance GitHub org, or Doni's personal account? What do we name it?
2. **Custom distro:** Goose supports custom distributions (CUSTOM_DISTROS.md) — should we build a branded "RIL Goose" distro with pre-configured extensions and defaults?
3. **Teaching integration:** Embed Say/Check/Action scripts inside recipe instructions, or keep separate teaching modules?
4. **Recipe testing:** How do we validate recipes work before rolling out? Goose has evals (`evals/` dir) — can we use that?
5. **Upstream contributions:** Which of our additions should we contribute back to Goose? (hooks would be a strong candidate)
6. **Windows compatibility:** Goose is primarily macOS/Linux — need to verify Windows support for Reliance teams
7. **Rate limiting:** With subscription-based access, how do we handle rate limits for parallel subagent workloads?
8. **Which MCP extensions to pre-configure:** GitHub, Supabase, n8n, Linear, Slack — which are relevant for RIL teams?
9. **Teaching content sequencing:** Design teaching content before building the system, after, or in parallel?
10. **Per-user context accumulation:** How does the system track what it's learned about each user across recipes? File format, storage location, what gets captured.

---

## Stage 0 Design: "From Chat to Code"

### Teaching Architecture: Teacher/Hands Pattern

The main agent is the **teacher** — it talks to the user, follows the teaching script, manages the conversation. It never touches the codebase directly.

**Subagents are the hands** — whenever the teacher needs something done in the codebase (read a file, make an edit, introduce a bug), it delegates to a subagent. The subagent does the work and reports back with structured context the teacher needs to continue the conversation.

```
Main Agent (teacher) — owns the conversation
│
├── load("acts/act-1-see-your-code.md") → reads script into context
│   ├── Say: "Let's look at your codebase..."
│   ├── delegate("Read src/auth.py, explain what it does in 2-3 paragraphs 
│   │            suitable for the developer who works on this project")
│   │   └── subagent reads file, returns explanation
│   ├── Say: [presents explanation to user]
│   └── Check: user picks a file and asks a question
│       ├── delegate("Read {file}, answer this question: {question}")
│       │   └── subagent reads file, returns answer
│       └── Say: [presents answer]
│
├── load("acts/act-2-first-edit.md") → reads script
│   ├── delegate("Find a function in {source_dir} that has a vague variable 
│   │            name. Propose renaming it. Return: file path, line number, 
│   │            current name, proposed name, and the diff")
│   │   └── subagent finds candidate, returns structured response
│   ├── Say: "Here's a small change I'd like to make..." [shows diff]
│   ├── Check: user approves
│   ├── delegate("Apply this rename: {file}, {old_name} → {new_name}")
│   │   └── subagent makes the edit, confirms
│   └── Say: "Open {file} in your editor — you'll see the change on line {n}"
│
├── load("acts/act-3-undo-button.md") → reads script
│   └── [walks user through git revert, then recreates practice branch]
│
├── load("acts/act-4-catch-the-bug.md") → reads script  
│   ├── delegate("Find a function in {source_dir} that handles input or 
│   │            data processing. Add a subtle bug — wrong comparison operator,
│   │            off-by-one, missing edge case. Return: (1) file and line, 
│   │            (2) what the bug is, (3) the diff to show the user, 
│   │            (4) a hint if they're stuck, (5) how to fix it")
│   │   └── subagent introduces bug, returns PRIVATELY to teacher
│   ├── Say: "I just added a small feature. Review this diff — does it look right?"
│   ├── [shows diff, DOES NOT reveal the bug]
│   ├── Check: user reviews and responds
│   │   ├── If user catches it → "Excellent. [explains why this matters]"
│   │   ├── If user misses it → "Look more carefully at line {n}. [hint]"
│   │   └── If still stuck → "Here's what's wrong: [reveal]. Here's why..."
│   └── delegate("Fix the bug in {file}") → subagent fixes it
│
├── load("acts/act-5-say-it-better.md") → reads script
│   ├── delegate("Given this vague instruction: 'improve this function', 
│   │            make a mediocre change to {function} in {file}. 
│   │            Return the diff and what you did")
│   │   └── subagent makes mediocre change
│   ├── Say: "Here's what I did with that vague instruction..." [shows diff]
│   ├── Say: "Now let's try again with a specific instruction..."
│   ├── Check: user writes a specific instruction
│   ├── delegate("{user's specific instruction}")
│   │   └── subagent makes the change, returns diff
│   ├── Say: "Compare the two results..." [side by side]
│   └── Teaching point about prompt quality
│
└── Wrap-up
    ├── Summary of 5 concepts learned
    ├── delegate("Delete branch practice/stage-0")
    └── Offer advancement to Stage 1
```

**Why this pattern:**
- Teacher's context stays clean — it sees conversation + teaching scripts + subagent summaries, not raw file contents
- Each subagent is disposable — one task, return, done
- The subagent return includes everything the teacher needs to continue naturally (file paths, line numbers, diffs, hints)
- The teacher never breaks character to read code or run commands
- Subagent instructions include act context so they know what role they're playing

### File Structure

```
recipes/stage-0/
├── from-chat-to-code.yaml          # Parent recipe (teacher instructions + orchestration)
├── acts/
│   ├── act-1-see-your-code.md       # Say/Check/Action script for Act 1
│   ├── act-2-first-edit.md          # Say/Check/Action script for Act 2
│   ├── act-3-undo-button.md         # Say/Check/Action script for Act 3
│   ├── act-4-catch-the-bug.md       # Say/Check/Action script for Act 4
│   └── act-5-say-it-better.md       # Say/Check/Action script for Act 5
└── state/
    └── .stage-0-progress.json       # Tracks which acts completed, files touched, user observations
```

### Act Scripts (Say/Check/Action Detail)

#### Act 1: "See Your Code" (~10 minutes)

```markdown
# Act 1: See Your Code

## Setup
Action: Read .goose/team_context.md to learn the project's stack and source directories.

## Step 1: Teacher Demonstrates

Say:
"Right now, you're used to AI that works like a search engine — you describe 
something, it gives you text back. What we're about to do is different. 
I can actually see your project files, read your code, and understand 
how your codebase works. Let me show you.

I'm going to send a helper to go browse through your project and pick 
an interesting file to look at. You might see some activity in your 
terminal — that's just my helper reading your files. Give me a moment."

Action: delegate to subagent:
  "Read .goose/team_context.md for project context. 
  Find a file in the main source directory that has meaningful logic 
  (not a config file, not a test). Pick something a developer on this 
  team would recognize — an API endpoint, a data model, a utility 
  function, a component. 
  
  Read the file. Return:
  - file_path: which file you chose
  - why: why you picked this one (1 sentence)
  - explanation: 2-3 paragraph explanation of what this file does, 
    written for a developer who works on this project (not a beginner 
    tutorial — speak to them as a peer)
  - interesting_detail: one specific thing about the implementation 
    worth calling out"

Say: 
"I picked [file_path] because [why].

[explanation]

One thing worth noting: [interesting_detail]."

## Step 2: User Tries

Say:
"Now it's your turn. Pick any file in your project — something you 
work with regularly — and ask me a question about it. Could be 
'what does this function do?' or 'why is this structured this way?' 
or anything else."

Check: Wait for the user to name a file and ask a question.

Action: delegate to subagent:
  "Read {user_specified_file}. Answer this question from the developer 
  who works on this code: {user_question}. 
  
  Return:
  - answer: clear, peer-level answer to their question
  - follow_up: one follow-up observation about the file they might 
    find interesting"

Say:
"[answer]

[follow_up]"

## Step 3: Bridge to Act 2

Say:
"So that's the first big difference from ChatGPT — I'm not guessing 
about your code from a description. I'm reading the actual files. 

But reading is just the start. Next, I'm going to make a change 
to your code. Don't worry — you'll approve everything first, and 
we'll learn how to undo it right after."
```

#### Act 2: "Your First Edit" (~10 minutes)

```markdown
# Act 2: Your First Edit

## Step 1: Create Safety Branch

Say:
"Before I touch anything, let's create a practice branch. Everything 
we do today happens here — your main branch stays untouched."

Action: delegate to subagent:
  "Run: git checkout -b practice/stage-0
  Return confirmation that the branch was created."

Say:
"Done — we're on a practice branch now. Nothing we do here affects 
your real code. Think of it like a scratch pad."

## Step 2: Find and Propose a Change

Say:
"Let me look through your code and find a small improvement I could make."

Action: delegate to subagent:
  "Read .goose/team_context.md for project context.
  Find a small, safe improvement in the source code. Good candidates:
  - A variable with a vague name (x, data, temp, result) that could 
    be more descriptive
  - A function missing a brief comment explaining its purpose
  - A log message that could be more descriptive
  
  Do NOT make the change yet. Return:
  - file_path: which file
  - line_number: which line
  - current_code: the current code (just the relevant lines)
  - proposed_code: what it would look like after the change
  - diff: a readable diff showing the change
  - rationale: one sentence explaining why this is better"

Say:
"I found something in [file_path] on line [line_number].

Here's what's there now:
```
[current_code]
```

Here's what I'd change it to:
```
[proposed_code]
```

[rationale]

This is a small change, but it's a real one — I'm going to edit 
your actual file. Want me to go ahead?"

Check: Wait for user to approve.

## Step 3: Apply the Change

Action: delegate to subagent:
  "Edit [file_path]: replace [current_code] with [proposed_code].
  Confirm the edit was applied. Return the file path."

Say:
"Done. Open [file_path] in your editor and look at line [line_number] — 
you should see the change.

This is the core loop of AI-assisted development: I propose, you 
review, you approve, I apply. You're always in control."

Check: Wait for user to confirm they see the change.

## Step 4: Bridge to Act 3

Say:
"Now here's the thing — what if you didn't like that change? What 
if I made a bad suggestion? Let me show you how easy it is to 
undo anything I do."
```

#### Act 3: "The Undo Button" (~5 minutes)

```markdown
# Act 3: The Undo Button

## Step 1: Show the Change

Say:
"Let's see what's changed in your project right now."

Action: delegate to subagent:
  "Run: git diff
  Return the full diff output."

Say:
"Here's everything that's different from your original code:

```
[diff output]
```

One command shows you every change. This is your first safety tool — 
`git diff` lets you see exactly what the AI changed before you 
commit anything."

## Step 2: Undo It

Say:
"Now let's undo that change completely."

Action: delegate to subagent:
  "Run: git checkout -- [file_path that was edited in Act 2]
  Then run: git diff
  Return confirmation that the diff is now empty."

Say:
"The file is back to its original state. That's your second safety 
tool — `git checkout` undoes changes to a file. 

Between `git diff` (see what changed) and `git checkout` (undo it), 
you can always get back to where you started. The AI can never make 
a change you can't reverse."

## Step 3: Re-apply for Later Acts

Say:
"Let me re-apply that change so we have something to work with going 
forward."

Action: delegate to subagent:
  "Re-apply the same edit from Act 2: [file_path], [current_code] → [proposed_code].
  Confirm it was applied."

Say:
"Change re-applied. Now comes the most important lesson — what happens 
when the AI writes something wrong."

## State: Write Progress
Action: delegate to subagent:
  "Write to .goose/state/.stage-0-progress.json:
  {
    'acts_completed': [1, 2, 3],
    'files_touched': ['[file_path]'],
    'branch': 'practice/stage-0'
  }"
```

#### Act 4: "Catch the Bug" (~10 minutes)

```markdown
# Act 4: Catch the Bug

## Step 1: Introduce the Bug (Privately)

Say:
"Let me add a small feature to your code. I'm sending a helper to 
find a good spot and make a change — you'll see some activity 
while it works."

Action: delegate to subagent:
  "Read .goose/team_context.md for the stack.
  Find a function in the source code that does some logic — 
  data processing, validation, calculation, string handling. 
  Something with at least a few lines of logic.
  
  Add a realistic-looking change that contains a SUBTLE bug. 
  Good bug types for [detected language]:
  - Wrong comparison operator (< instead of <=)
  - Off-by-one in a loop or slice
  - Missing null/undefined/None check
  - Wrong variable used (using the input instead of the processed version)
  - String concatenation in wrong order
  
  The change should look plausible — like something a competent 
  developer might write quickly without thinking. NOT an obvious 
  syntax error.
  
  Make the change to the file.
  
  Return (THIS IS PRIVATE — teacher will not show all of this to user):
  - file_path: which file
  - diff: the full diff to show the user
  - bug_location: exact line number and what's wrong
  - bug_explanation: why this would cause a problem at runtime
  - hint_1: a gentle nudge without giving it away
  - hint_2: a more specific hint pointing at the line
  - fix: what the correct code should be"

## Step 2: Show the Diff

Say:
"OK, I just made a change to [file_path]. Here's the diff:

```
[diff]
```

Take a look at this. Does everything look correct to you?"

Check: Wait for user's response.

## Step 3: Guide Based on Response

If user identifies the bug:

Say:
"You caught it. [bug_explanation]. 

This is the most important thing I'm going to teach you today: 
AI writes confident, plausible, wrong code. It doesn't hesitate 
or flag uncertainty. It just writes it like it's obviously correct. 

Your job — always — is to review what the AI produces. Not skim it. 
Actually read it and think about whether it's right. You just proved 
you can do that."

If user says it looks fine:

Say:
"Take another look, specifically around [hint_1]."

Check: Wait for response.

If still stuck:

Say:
"Look at line [bug_location]. [hint_2]"

Check: Wait for response.

If still stuck:

Say:
"Here's what's wrong: [bug_explanation].

Don't feel bad about missing it — this is exactly the kind of mistake 
AI makes constantly, and it's exactly why reviewing AI output is 
a non-negotiable skill. The AI wrote this confidently. It didn't 
warn you. It never will. That's your job."

## Step 4: Fix It

Say:
"Let me fix that."

Action: delegate to subagent:
  "Fix the bug in [file_path] at line [bug_location]. 
  The correct code should be: [fix].
  Return the corrected diff."

Say:
"Fixed. In real work, this is the cycle: AI proposes → you review → 
you catch issues → AI fixes them. The AI is fast but fallible. 
You are slower but critical. Together, you're better than either alone."
```

#### Act 5: "Say It Better" (~10 minutes)

```markdown
# Act 5: Say It Better

## Step 1: The Vague Request

Say:
"For this last exercise, I want to show you something that will 
change how you work with AI forever. Watch what happens when I give 
a vague instruction versus a specific one.

Pick a function in your project — something that could be improved. 
Just tell me the file and function name."

Check: Wait for user to pick a function.

Say:
"OK. First, I'm going to improve that function with a vague instruction. 
Watch what happens."

Action: delegate to subagent:
  "You have been given a deliberately vague instruction. Follow it 
  literally — do not overperform.
  
  Instruction: 'Improve the function [function_name] in [file_path]'
  
  Make a mediocre, surface-level change. Maybe rename one variable, 
  or add a generic comment like '// process data'. Do the minimum 
  that technically counts as 'improving.'
  
  Do NOT actually edit the file. Just return:
  - vague_diff: what the change would look like
  - vague_description: one sentence describing what you did"

Say:
"Here's what I did with 'improve this function':

```
[vague_diff]
```

[vague_description]

Not great, right? The instruction was vague, so the result was vague. 
Now let's try something different. 

This time, YOU write the instruction. Be specific — tell me exactly 
what you want improved. For example:
- 'Rename the variables to be descriptive'
- 'Add input validation for null values and empty strings'
- 'Break this into two smaller functions: one for X, one for Y'
- 'Add error handling with specific error messages'

What would you like me to do with this function?"

Check: Wait for user to write a specific instruction.

## Step 2: The Specific Request

Action: delegate to subagent:
  "Apply this instruction to [function_name] in [file_path]:
  
  '{user_specific_instruction}'
  
  Do your best work. Make the change to the file.
  
  Return:
  - specific_diff: the full diff
  - specific_description: what you did and why each change matters"

Say:
"Here's what I did with your specific instruction:

```
[specific_diff]
```

[specific_description]

Compare the two:

**Vague instruction** → [vague_description]
**Your instruction** → [specific_description]

Same AI, same function, completely different results. The difference 
was you. The quality of what you get from AI is directly proportional 
to the quality of what you ask for. This is the single most important 
skill in AI-assisted development — and you just demonstrated it."

## Step 3: Bridge to Stage 1

Say:
"That's everything for Stage 0. Here's what you learned today:

1. **AI can see your code** — it reads actual files, not guessing 
   from descriptions
2. **You approve every change** — nothing happens without your 
   permission
3. **Git is your undo button** — any change can be reversed instantly
4. **AI makes mistakes** — confident, plausible, wrong. Your job 
   is to catch them
5. **Specific instructions → better results** — how you ask matters 
   more than what you ask

You're ready for Stage 1, where you'll start doing real work: 
code reviews, writing tests, fixing bugs — all with AI assistance.

Want to advance? Just run `goose advance`."
```

### Design Constraints for All Stage 0 Content

- **Manual approval mode** — user approves every tool call
- **Practice branch** — all work on `practice/stage-0`, never touches main/master
- **Their real code** — not a tutorial project, local only, no pushes
- **Say/Check/Action format** — teacher follows script precisely
- **No jargon** — no "MCP", "subagents", "context window", "tokens". Plain language.
- **Subagents do all code work** — teacher never reads files or runs commands directly
- **Subagent returns include everything teacher needs** — file paths, line numbers, diffs, explanations, hints
- **Explain subagents to the user as they happen** — when the teacher delegates, briefly tell the user what's happening in plain language: "I'm sending a helper to go read that file — give me a moment." This demystifies the system and subtly teaches the multi-agent concept they'll use later. Don't use the word "subagent" — say "helper", "assistant", or "I'm going to go look at that"
- **Act 4 bug is PRIVATE** — subagent tells teacher where the bug is, teacher doesn't reveal it to user
- **~45-60 minutes total** — each act 5-10 minutes, don't let any act drag

---

## Recipe Teaching Architecture

### Core Principle: Every Recipe Has Two Modes

Every recipe exists as a **working recipe** (just does the job) and has an associated **teaching script** (guides a first-time user through the recipe's concepts, pitfalls, and nuance).

**First run of any recipe = teaching mode, mandatory, no opt-out.** After that, working mode with `/teach` available to revisit.

```
User runs: goose run code-review

System checks progression file:
├── Never completed teaching for code-review
│   → Automatically runs teach-wrapper (no prompt, no choice)
└── Previously completed teaching
    → Runs code-review.yaml directly (working mode)
```

### Why Forced Teaching

- People who need it most will skip it if given the choice
- Even experienced developers benefit from learning each recipe's specific pitfalls and nuance
- The teacher grows up with the user — Stage 0 teacher explains diffs, Stage 3 teacher explains circuit breakers
- Teaching is the mechanism for transferring our hard-won pipeline learnings

### `/teach` Command for Re-Learning

`/teach code-review` — re-runs teaching mode regardless of progression state. Use cases:
- Forgot how a recipe works
- Want to show a teammate
- Recipe was updated with new features
- New developer joining a team already at Stage 2+

### File Structure

```
recipes/
├── stage-0/
│   └── from-chat-to-code.yaml         # Stage 0 is special (single recipe, 5 acts)
├── stage-1/
│   ├── code-review.yaml                # Working recipe
│   ├── test-writer.yaml
│   ├── bug-fix.yaml
│   └── refactor.yaml
├── stage-2/
│   ├── build-then-test.yaml
│   └── ...
teaching/
├── meta/
│   ├── teach-wrapper.yaml              # Meta-recipe that wraps any recipe in teaching
│   └── teacher-instructions.md         # How the teacher should behave (level-adapted)
├── stage-1/
│   ├── code-review.teach.md            # Teaching script for code-review
│   ├── test-writer.teach.md
│   ├── bug-fix.teach.md
│   └── refactor.teach.md
├── stage-2/
│   └── ...
```

### Teach Wrapper (Meta-Recipe)

```yaml
# teaching/meta/teach-wrapper.yaml
version: 1.0.0
title: "Recipe Teacher"
description: "Wraps any recipe in a guided teaching experience"

parameters:
  - key: recipe
    input_type: text
    requirement: required
    description: "Which recipe to teach (e.g., stage-1/code-review)"

instructions: |
  You are a teacher guiding a developer through a recipe for 
  the first time.
  
  1. Load the teaching script: 
     load("teaching/{recipe}.teach.md")
  2. Load the teacher behavior guide:
     load("teaching/meta/teacher-instructions.md")
  3. Read the user's progression file to understand their level
  4. Follow the teaching script — it has concepts, pitfalls, 
     and nuance specific to this recipe
  5. When the script says "demonstrate", delegate to the actual 
     recipe's working logic via subagent
  6. When the script says "user tries", let them drive and 
     intervene only at teaching moments
  7. After completion, update progression file: mark recipe 
     as taught, record completion date
```

### Teacher Level Adaptation

The teacher doesn't disappear — it grows up with the user:

| Stage | Teacher behavior | What it teaches |
|-------|-----------------|-----------------|
| 0 | Step-by-step, explains everything, waits at every check | Basics: AI sees code, edits, undo, mistakes, prompting |
| 1 | Explains the recipe's approach, demonstrates once, user drives | Workflows: review, test, fix, refactor |
| 2 | Explains the concept (why separation matters), shows the pattern | Principles: verification, file ownership, spec-first |
| 3 | Explains the architecture, walks through setup | Systems: multi-agent, escalation, circuit breakers |
| 4 | Explains the meta-level, user operates | Meta: autonomous cycles, false positives, learnings |
| 5 | Peer-level discussion of tradeoffs, user designs | Design: when to evolve, when to prune, metrics |

### Progression File

```json
// ~/.config/goose/progression/{project-hash}.json
{
  "current_stage": 1,
  "recipes": {
    "stage-0/from-chat-to-code": {
      "taught": true,
      "completed_at": "2026-04-15",
      "runs": 1
    },
    "stage-1/code-review": {
      "taught": true,
      "completed_at": "2026-04-16",
      "runs": 7
    },
    "stage-1/test-writer": {
      "taught": false,
      "runs": 0
    }
  },
  "observations": {
    "prompt_quality": "improving",
    "reviews_diffs_before_accepting": true,
    "uses_specific_instructions": true
  }
}
```

---

## Stage 1 Design: "Real Work"

### Overview

Four separate recipes, each a standalone workflow the developer will reuse long after training. Unlike Stage 0 (one flow), these are independent — can be done in any order, but recommended sequence builds from lowest to highest risk.

### Progression: Lowest Risk → Highest Risk

| Recipe | Risk Level | What AI Does | Why This Order |
|--------|-----------|--------------|----------------|
| 1.1 Code Review | Read-only | Reads code, gives feedback | AI can't break anything |
| 1.2 Test Writer | Additive | Writes new test files | Doesn't change existing code |
| 1.3 Bug Fix | Modification | Changes existing code | Higher risk, but user can revert |
| 1.4 Refactor | Restructure | Reorganizes code | Highest risk, sets up Stage 2's "why" |

### Recipe 1.1: "Code Review"

**Working mode:** User points it at a PR, branch diff, or set of files. AI reviews and returns findings.

**Teaching script concepts:**
- How to point AI at the right scope (a PR, specific files, a commit range)
- How to read AI review feedback critically (it flags style issues alongside real bugs — learn to triage)
- AI reviews are a starting point, not the final word — it misses things, it over-flags things
- How to iterate: "focus on security issues only" or "ignore style, just find logic errors"
- **Pitfall to teach:** AI will praise clean code even if it has bugs. Positive feedback ≠ no bugs.
- **Nuance:** Review is the highest-leverage recipe — use it on your own PRs before asking teammates. Faster feedback, better PRs.

**Teaching flow:**
1. Teacher explains what code review with AI looks like
2. Delegate: subagent reviews a recent commit or PR in the project
3. Teacher walks through the findings — what's useful, what's noise, what's missing
4. User picks a different commit/PR and runs the review themselves
5. Teacher debriefs: "What did you find useful? What would you ignore?"

### Recipe 1.2: "Test Writer"

**Working mode:** User points it at a function or module. AI writes tests.

**Teaching script concepts:**
- How to specify what to test (function, module, edge cases, happy path)
- Tests need to actually run — AI often writes tests that look right but fail
- The iteration cycle: AI writes tests → run them → some fail → AI fixes → repeat
- How to evaluate test quality (does it test behavior or just syntax?)
- **Pitfall to teach:** AI writes tests that pass but test nothing meaningful. A test that asserts `true == true` is worse than no test. Show an example.
- **Nuance:** Start with one function, not "write tests for the whole module." Smaller scope = better tests.

**Teaching flow:**
1. Teacher explains the test-writing workflow
2. Teacher picks a function, delegates to subagent to write tests
3. Subagent writes tests and runs them, returns results
4. Teacher walks through: which tests are meaningful, which are weak
5. User picks a function and tries it themselves
6. If tests fail, teacher guides through the fix-iterate cycle
7. Teaching moment: "Notice how the second round of tests was better? That's because the AI learned from the failures. Iteration is the pattern."

### Recipe 1.3: "Bug Fix"

**Working mode:** User describes a bug. AI finds and fixes it.

**Teaching script concepts:**
- Give context about the bug — what you've already tried, where you think it is, reproduction steps
- The more context you give, the faster and more accurate the fix
- Always review the fix — AI sometimes fixes the symptom, not the root cause
- Run tests after the fix to catch regressions
- **Pitfall to teach:** AI will confidently "fix" a bug by suppressing the error instead of solving the underlying problem. Show an example (try/catch that swallows the exception).
- **Nuance:** If the AI is going in circles after 2-3 attempts, stop and rethink. Give it different context or a different angle. Don't let it loop.

**Teaching flow:**
1. Teacher explains the bug-fix workflow
2. Teacher asks: "Is there a known bug in this project right now? Or something that's been annoying you?"
3. If yes: use the real bug. If no: teacher has subagent find a code smell or potential issue.
4. User describes the problem to the AI
5. Subagent investigates and proposes a fix
6. Teacher walks through: is this a real fix or a symptom suppression?
7. Run tests, verify the fix
8. Teaching moment: "You gave it [X context] and it found the fix in [Y] attempts. When you give less context, it takes longer and makes more mistakes."

### Recipe 1.4: "Refactor"

**Working mode:** User identifies code to refactor. AI restructures it.

**Teaching script concepts:**
- Define what "better" means before starting — more readable? More testable? Faster?
- Always run tests before AND after refactoring
- Review the full diff, not just the changed function — refactors can have ripple effects
- Start small — refactor one function, not an entire module
- **Pitfall to teach:** AI refactors can change behavior while looking like pure cleanup. Show an example where renaming + restructuring subtly changes a conditional.
- **Nuance:** "This is the last recipe in Stage 1. By now you've probably noticed — you're doing a lot of reviewing. In Stage 2, you'll learn how to have a second AI check the first one's work, so you don't have to catch everything yourself."

**Teaching flow:**
1. Teacher explains refactoring with AI — risks, rewards, safety checks
2. Subagent runs tests, captures baseline (all pass, N tests)
3. User picks a function or small module to refactor, describes what "better" means
4. Subagent does the refactor, returns the diff
5. Teacher walks through: what changed, any ripple effects, any behavioral changes
6. Subagent runs tests again — do they still pass?
7. If tests fail: teaching moment about why pre/post test comparison matters
8. Bridge to Stage 2: "You just spent time carefully reviewing AI output. What if another AI did that for you?"

### Readiness for Stage 2

After completing all four teaching sessions and using at least one recipe independently, the system offers advancement:

"You've been doing code reviews, writing tests, fixing bugs, and 
refactoring — all with AI. You've also been reviewing a lot of 
AI output yourself. Stage 2 introduces a powerful idea: what if 
a second AI checked the first one's work? Ready to try it?
Run `goose advance` when you are."

---

## Next Steps

- [ ] Fork the Goose repo
- [ ] Set up ACP with Claude Max subscription locally — verify it works on Windows
- [ ] Design Stage 0 parent recipe YAML (from-chat-to-code.yaml)
- [ ] Write act script markdown files (acts 1-5)
- [ ] Test teacher/hands pattern with a real Goose session
- [ ] Design the onboarding recipe
- [ ] Design Stage 1 teaching content
- [ ] Map our pipeline's skill files to Goose's instruction format
- [ ] Test sub-recipe + subagent orchestration with a simple multi-agent workflow
- [ ] Document the custom distro setup process
