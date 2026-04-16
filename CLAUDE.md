# goose-wizard — Agentic Development Harness for Reliance Teams

## Current Work
**Three-recipe-type architecture is complete.** All 26 modules converted:
- 40 agent primitives in `recipes/agents/` (top-level modules + nested
  `config/`, `progression/`, `conductor/` subdirs)
- 34 recipes in `recipes/shared/`: gateway + 26 numbered training
  modules + 7 support recipes (conductor, setup, etc.)
- 5 graduated coordinators in `recipes/graduated/`
- GooseForge: Recipe Forge + Pipeline Forge
- Gateway (Start Here) with check-progress sub-recipe
- Module designer skill updated for new architecture

**Stage 0:** Scripted, inline in `01-see-what-ai-can-do.yaml`. No agent primitive needed.
**Stages 1-7:** All training recipes, agent primitives, and teaching scripts exist. Graduation wired into every training recipe.

## Two Audiences — AIF vs RIL

**AIF (AI Foundry)** is Doni's team — the builders and teachers. ~10-12 people (Nate, Kyle, Jessica, Elsa, Rod, Kani, Kathleen, James, Jennifer, Doni, plus RIL-side collaborators Dharmendra, Amit, Anindya). All AI-literate experts. AIF uses Linear (workspace: "Aifoundry") as their task management system and is dogfooding the agentic workflow — Linear + AI agents — for their own work before teaching it to RIL teams.

**RIL (Reliance) teams** are the students — skeptical development teams with little or no AI coding experience. They are the target audience for the 8-stage curriculum. AIF teaches/builds systems for them.

When discussing "the team" or "our workflow," it means AIF unless explicitly stated otherwise. When discussing "the audience" or "developers learning," it means RIL teams.

## User Context
- **Doni** — non-technical, runs onboarding centrally for Reliance teams
- **Platform:** Windows 11
- **Subscriptions:** Claude Max (primary), Codex (optional add-on)
- **Role:** Designs the system, doesn't write the recipes himself — works with AI to design and iterate
- **Writing style:** Direct, confident, no jargon. Has a captured style profile at `~/ClaudeProjects/General/style_profile_executive_strategy_memo.md` for written communications.

## Conventions
- **Recipes are run from the CLI, not the desktop app.** The Goose desktop app has a clunky text-streaming experience (output jumps, doesn't reveal incrementally the way the CLI does) that breaks the teaching flow — developers lose the "watch the AI think" moment that sells the pitch. All user-facing entry points (root README, install READMEs, installer final messages, gateway recipe Section 3) direct developers to `goose run --recipe 00-start-here --interactive`. The desktop app is still useful for **browsing recipe YAML files** during Recipe Reveals, so we keep it installed — but do NOT tell developers to run recipes from it. If you're writing or editing any user-facing text that tells someone how to launch a recipe, lead with the CLI command; mention the desktop app only in a "keep it open on the side for reading" context.
- **Handoffs go in `handoffs/`.** When ending a session or switching context, write a handoff document to `handoffs/` with enough context for a fresh session to continue the work. Name it descriptively (e.g., `tonight-untested-recipes.md`).
- **Every handoff MUST include a "Decisions Doni made this session" section.** List every non-trivial decision he made — scope calls ("do X not Y"), design picks ("use A instead of B"), cadence rules ("review after every series"), deferred-vs-now calls. Include the reasoning when he gave one. A handoff without this section is incomplete: the next session won't know which design calls are locked-in vs still open, and will re-litigate them. When in doubt, err toward including more.

## Git Workflow
1. **`main` is the stable branch.** Never push directly to `main`. All changes go through a branch + PR.
2. **Branch from `main`, PR back to `main`.** No long-lived develop/staging branches — keep it simple.
3. **Branch naming:** `<type>/<short-description>` — e.g., `feature/pipeline-forge`, `fix/install-path`, `cleanup/rename-modules`, `docs/rollout-playbook`.
   - Types: `feature/`, `fix/`, `cleanup/`, `docs/`
4. **Self-merge is fine.** PRs exist for history and visibility, not as a review gate. Merge your own PR when ready.
5. **Keep PRs focused.** One logical change per PR. Don't bundle unrelated work.
6. **Delete branches after merge.** Don't let stale branches pile up.

## What This Is
A fork of [Goose](https://github.com/aaif-goose/goose) (Block/Linux Foundation's agent platform) extended with progressive teaching recipes that take development teams from zero agentic experience to autonomous development pipelines.

**Target audience:** Skeptical development teams at Reliance who have never used AI coding tools. The system must show value before teaching practices — lead with "look how powerful this is," not "here's what can go wrong."

## Key Design Documents

| Document | What It Contains | When to Read |
|----------|-----------------|-------------|
| `ideas/syllabus.md` | **Start here.** 8-stage concept map, adaptive teaching framework, quality-rating model, RIL agents integration, all design decisions with rationale | Every session — this is the source of truth |
| `ideas/plan.md` | Original research, architecture decisions, Goose internals, Stage 0 act scripts (lines 707-1155), Stage 1 design (lines 1310-1430) | When writing teaching scripts or understanding a technical decision |
| `ideas/rollout-playbook.md` | Rollout phases, ROI metrics, manager dashboard, internal selling guide | When discussing deployment, metrics, or stakeholder buy-in |
| `REFERENCES.md` | Quick-access details on pipeline patterns, Goose mechanics, CourseForge format | When implementing recipes or teaching scripts |
| `HOW_GOOSE_WORKS.md` | Goose operational learnings — scheduler, recipes, subagents, ACP providers, extensions, CLI reference | When building anything on Goose or debugging Goose behavior |
| `handoffs/stage1-detail.md` | Original handoff for Stage 1 work — lists 4 gaps to resolve before writing scripts | Before writing any Stage 1 content (gaps need re-evaluation against new adaptive model) |
| `overnight-pipeline/README.md` | Overnight pipeline framework — how to run, adapt, and start new runs | When setting up an overnight run or reviewing past results |
| `recipes/forge-references/recipe-hygiene.md` | 21 hygiene rules for recipe creation — Universal, Primitive, and Workflow categories. Every rule validated against Goose behavior | When writing or reviewing any recipe |

## Teaching Framework (Adaptive Evaluation)

We don't teach by lecturing. We teach by having developers do real work and coaching them on what they're missing.

**Core model:** Developer does real work → eval subagent rates quality (Strong/Adequate/Weak) → facilitator praises what's strong, coaches what's weak. Concepts are a checklist to verify, not a curriculum to deliver.

**Three agent roles:**
- **Facilitator** (main agent) — guides conversation, never touches code, teaches adaptively
- **Code-Work Subagent** — does all code operations
- **Eval Subagent** — rates quality of how the developer approached the work (batch, not real-time)

**Four teaching modes:**
| Mode | Stages | Why |
|------|--------|-----|
| Scripted | 0 | Can't evaluate what hasn't been encountered — need designed moments of surprise |
| Guided-Adaptive | 1 | Set up real work, developer does it, eval rates quality, teach gaps |
| Adaptive + Checkpoints | 2-4 | Developer builds real systems, facilitator checks in at defined points |
| Fully Adaptive | 5-7 | Developer has mental models, facilitator is consulting role |

Full details in `ideas/syllabus.md` under "Teaching Framework: Adaptive Evaluation."

## 8-Stage Progression
| Stage | Name | Mode | Key Concept |
|-------|------|------|-------------|
| 0 | See What AI Can Do | Scripted | AI reads/edits your code, everything reversible, AI makes mistakes, you control quality |
| 1 | Get Real Work Done | Guided-Adaptive | Bug fix, test writing, code review, refactoring — ordered by impact, not risk |
| 2 | Two AIs Are Better Than One | Adaptive+Checkpoints | Self-verification bias, separated concerns, execution checks, spec-first |
| 3 | Build a Team of AI Specialists | Adaptive+Checkpoints | Agent roles, contracts, safety rails, layered testing, parallel coordination |
| 4 | From Idea to Buildable Spec | Adaptive+Checkpoints | DDD artifact chain, persona decomposition, testable requirements, kill criteria |
| 5 | Trust But Verify | Fully Adaptive | Independent verification, layered evals, ratchets, mock isolation |
| 6 | Let It Run While You Sleep | Fully Adaptive | Cycle review, feedback loops, learnings capture, persistent memory |
| 7 | The System Gets Smarter | Fully Adaptive | Curator agent, skill evolution, rule pruning, metrics-driven improvement |

## Core Architecture
- **Goose fork** — battle-tested runtime, recipe system, sub-recipes, subagents, ACP, MCP extensions, desktop app + CLI
- **Our pipeline patterns** (from AgenticSystem) — file ownership, circuit breakers, 4-tier testing, escalation routing, separated concerns
- **DDD spec system** (from ddd-mcp-server) — artifact chain, persona decomposition, testable requirements, quality gates
- **Ported Agents** (local: `recipes/ported-agents/`) — agent patterns ported from the RIL-agents library, used as the execution layer in recipes. Originals at `~/ClaudeInfra/ril-agents/` are lineage only, not a runtime dependency.
- **Adaptive teaching model** — evolved from CourseForge's scripted model into quality-rated adaptive evaluation

## Guiding Principles
1. Meet teams where they are, not where we want them to be
2. The system teaches — humans don't have to
3. Earn trust before adding complexity
4. Enforce, don't suggest
5. Separation of concerns is non-negotiable
6. Recipes are the unit of knowledge transfer
7. Fork light, stay mergeable
8. Provider-agnostic, Claude Code default
9. Recipes specify tiers, not models
10. Show power first, teach practices second (skeptics need value before investment)
11. Teach through real work, not designed exercises (except Stage 0 bootstrapping)

## Key Technical Decisions
- **ACP** for subscription-based access (Claude Max, Codex) — no API keys
- **Recipe layer only** — don't touch Goose's Rust core
- **LLM-based orchestration** — use Goose's native subagents, add code-based orchestration only if needed
- **Hooks deferred** — Goose's ToolInspector trait makes adding them later ~200 lines
- **Three recipe types** — agent primitives (non-interactive workers), training recipes (interactive facilitators), graduated recipes (daily-use, replace training on completion)
- **Facilitator/CodeWork/Eval pattern** — training recipe facilitates, agent primitive does code work, eval subagent rates quality
- **Quality ratings not binary** — eval subagent rates Strong/Adequate/Weak, not yes/no
- **Stage 1 ordered by impact** — Bug Fix → Test Writer → Code Review → Refactor (not risk order)
- **Ported agents as execution layer** — agent primitives reference patterns from `recipes/ported-agents/` (local, versioned with the repo)
- **GooseForge** — recipe design system with Recipe Forge (single recipes) and Pipeline Forge (multi-step pipelines)
- **Pipeline Forge** — replaced Team Forge; thinks in stages/patterns, not team roles; composes from known Stage 2-3 patterns
- **Recipe hygiene rules** — 21 rules (8 universal, 5 primitive, 8 workflow) validated against actual Goose behavior. Includes: text-only first turn (smart_approve constraint), information barriers, operation boundaries, runtime isolation. See `recipes/forge-references/recipe-hygiene.md`

## Project Structure
```
goose-wizard/
├── CLAUDE.md                           # This file
├── HOW_GOOSE_WORKS.md                  # Goose operational learnings (scheduler, recipes, extensions, CLI)
├── ideas/
│   ├── syllabus.md                     # 8-stage concept map + adaptive teaching framework + decisions
│   ├── plan.md                         # Original master plan with research and Stage 0 scripts
│   └── rollout-playbook.md             # Rollout phases, ROI metrics, selling guide
├── REFERENCES.md                       # Quick-access technical details (pipeline, Goose, CourseForge)
├── handoffs/                           # Session handoff documents (save all handoffs here)
│   ├── stage1-detail.md                # Stage 1 gaps to resolve
│   ├── overnight-pipeline-setup.md     # Overnight pipeline design and setup
│   ├── overnight-results.md            # 20-cycle hardening results
│   ├── v1-modules.md                   # V1 module generation handoff
│   └── v2-fixes-and-audit.md           # V2 fixes and audit handoff
├── overnight-pipeline/                 # Pipeline kit: run any Goose recipes overnight
│   ├── pipeline_runner.py              # Deterministic Python loop (no LLM in orchestration)
│   ├── pipeline-kit.md                 # Instructions: how to build and run a pipeline
│   ├── README.md                       # Overview and key learnings
│   ├── personas.md                     # 9 reusable mock developer personas
│   ├── edge-cases.md                   # 14 reusable edge case scenarios
│   ├── recipes/                        # Pipeline-specific Goose recipes (NOT course recipes)
│   │   ├── simulate-session.yaml       # Run one mock teaching session
│   │   ├── evaluate-transcript.yaml    # Score one transcript
│   │   ├── classify-findings.yaml      # Bucket A/B/C classification
│   │   ├── apply-fixes.yaml            # Apply fixes + git commit
│   │   ├── plan-next-cycle.yaml        # Decide what's next or stop
│   │   └── summarize-run.yaml          # Write morning brief
│   ├── configs/                        # Run configurations (one folder per run)
│   │   └── tonight-untested/           # 9 untested recipes from first hardening run
│   ├── templates/                      # Copy these to start a new run
│   │   ├── cycle-template.md           # Recipe checklist format
│   │   ├── schedule-template.md        # Per-cycle variation format
│   │   └── state.json                  # Starting state
│   └── runs/                           # Archived completed runs
│       └── 2026-04-13-hardening/       # 20 cycles, 72 fixes, all regressions passed
├── recipes/                            # Working recipes (Goose YAML format)
│   ├── TWO-MODE-PATTERN.md             # SUPERSEDED — see three-recipe-type architecture
│   ├── RECIPE-PREAMBLE.md              # Runtime isolation preamble for recipes
│   ├── shared/                         # Training recipes — visible in Goose app
│   │   ├── 00-start-here.yaml          # ★ START HERE — gateway/dashboard
│   │   ├── 01-see-what-ai-can-do.yaml  # Stage 0: scripted demo
│   │   ├── 02-bug-fix.yaml             # Stage 1: training facilitator (calls agents/bug-fix)
│   │   ├── 03-test-writer.yaml         # ...through 26-skill-evolution.yaml
│   │   └── ...26 module recipes total
│   ├── agents/                         # 40 agent primitives — non-interactive workers (incl. nested config/, progression/, conductor/; NOT in GOOSE_RECIPE_PATH)
│   │   ├── bug-fix.yaml                # Stage 1: bug investigation + fix + test + diff
│   │   ├── test-writer.yaml            # Stage 1: generate and run tests
│   │   ├── code-review.yaml            # Stage 1: review code, return categorized findings
│   │   ├── refactor.yaml               # Stage 1: restructure code with baseline tests
│   │   ├── builder.yaml                # Stage 2: implement a change (used by build-then-test, three-agent-pipeline)
│   │   ├── independent-tester.yaml     # Stage 2: verify changes independently (used by build-then-test)
│   │   ├── review-gate.yaml            # Stage 2: pass/fail gate with execution evidence
│   │   ├── spec-first.yaml             # Stage 2: spec → test → build → verify workflow
│   │   ├── spec-writer.yaml            # Stage 3: turn task into implementation spec
│   │   ├── escalation-routing.yaml     # Stage 3: add circuit breakers and escalation to pipelines
│   │   ├── ...                         # Stages 4-7: 15 more domain-specific primitives
│   │   ├── check-progress.yaml         # Progression: reads state, returns training status
│   │   ├── graduate-module.yaml        # Progression: replaces training recipe with working version
│   │   ├── recipe-forge.yaml           # GooseForge: generates recipe YAML from structured inputs
│   │   └── recipe-validate.yaml        # GooseForge: validates recipe against 37 checks
│   ├── graduated/                      # 5 graduated recipes — multi-agent coordinators
│   │   ├── build-then-test.yaml        # Stage 2: builder + independent-tester coordinator
│   │   ├── three-agent-pipeline.yaml   # Stage 3: spec + build + review coordinator
│   │   ├── parallel-reviewers.yaml     # Stage 3: multi-layer parallel review coordinator
│   │   ├── recipe-forge.yaml           # GooseForge: interactive recipe design
│   │   └── pipeline-forge.yaml         # GooseForge: interactive pipeline design
│   │   # Single-agent modules don't need graduated recipes — the agent
│   │   # primitive IS the graduated version and replaces the training recipe directly.
│   ├── forge-references/               # GooseForge reference library
│   │   ├── design-principles.md        # 16 design principles
│   │   ├── canonical-recipe-structure.md # 10-section template + YAML generation rules
│   │   ├── archetype-*.md              # 5 archetype references (reviewer, builder, coordinator, evaluator, investigator)
│   │   ├── anti-patterns.md            # 6 universal + 15 archetype-specific anti-patterns
│   │   ├── recipe-hygiene.md           # 21 hygiene rules (Universal, Primitive, Workflow)
│   │   └── validation-checklist.md     # 37-item checklist + 6 quality detectors
│   └── local/                          # 6 pipeline recipes (personal/testing only)
│       ├── apply-fixes.yaml
│       └── ...5 more pipeline recipes
├── teaching/                           # Teaching scripts and meta
│   ├── meta/
│   │   ├── teach-wrapper.yaml          # DEPRECATED — replaced by training recipe pattern
│   │   ├── teacher-instructions.md     # How the facilitator should behave
│   │   └── module-designer/            # Skill for designing modules (load when building)
│   │       ├── SKILL.md                # Main skill file (~300 lines)
│   │       └── references/             # Templates, formats, example module
│   │           ├── goose-recipe-format.md
│   │           ├── eval-prompt-template.md
│   │           ├── example-module.md   # Complete Bug Fix module as reference
│   │           ├── progression-format.md
│   │           └── ported-agents-map.md
│   ├── stage-0/                        # Stage 0 is scripted (acts are the teaching)
│   ├── stage-1/                        # Stage 1 guided-adaptive scripts
│   │   ├── bug-fix.teach.md
│   │   ├── test-writer.teach.md
│   │   ├── code-review.teach.md
│   │   └── refactor.teach.md
│   ├── stage-2/ through stage-7/       # All stages now have teaching scripts
├── onboarding/                         # Project onboarding recipe
│   └── onboard.yaml
├── install.sh                              # macOS/Linux one-line installer (curl | bash)
├── install.ps1                             # Windows one-line installer (irm | iex)
└── install/                                # Installer support files
    ├── config.yaml                         # Default Goose config (copied at install time)
    ├── README.md                           # Install docs and troubleshooting
    └── project-template/                   # State templates seeded at install
```

## Cross-Project References
- **This project (goose-wizard)**: Recipes, teaching scripts, onboarding, syllabus, plan
- **AgenticSystem** (`~/ClaudeProjects/AgenticSystem/`): Source pipeline patterns — file ownership, circuit breakers, escalation, cycle review. Read `LEARNINGS.md` and `Evaluations/` for concepts that inform Stages 2-7.
- **ddd-mcp-server** (`~/ClaudeProjects/ddd-mcp-server/`): DDD spec system — artifact chain, golden prompts, quality gates, executive review simulation. Informs Stage 4.
- **Ported Agents** (`recipes/ported-agents/` inside this repo): 12 agents ported from the RIL-agents library as Goose recipe YAMLs. This is the runtime reference. Lineage only: `~/ClaudeInfra/ril-agents/` (read-only, not a dependency). Conductor was deliberately not ported — it's being redesigned as a native multi-recipe Goose system; see `handoffs/conductor-native-design-2026-04-15.md`.
- **CourseForge** (`~/ClaudeProjects/CourseForge/`): Original teaching model (Say/Check/Action). Stage 0 still uses this. Stages 1+ evolved to adaptive model.
- **The Goose fork** (TBD): The actual forked runtime with our recipes added.

## When to Read What
- **Starting a new session?** Read `ideas/syllabus.md` — it's the source of truth for everything designed so far
- **Writing teaching scripts?** Read syllabus Stage 1 quality dimensions + `REFERENCES.md` Section 3 (CourseForge format) + plan.md Stage 0 act scripts (format reference)
- **Designing working recipes?** Read `REFERENCES.md` Section 2 (Goose recipe YAML, subagent syntax)
- **Discussing rollout or metrics?** Read `ideas/rollout-playbook.md`
- **Need deep context on a decision?** Check syllabus Decision Log first, then `ideas/plan.md`
- **Setting up an overnight run?** Read `overnight-pipeline/pipeline-kit.md` for quick start
- **Working with Goose?** Read `HOW_GOOSE_WORKS.md` for scheduler, recipes, extensions, CLI reference
