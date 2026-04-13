# RILGoose — Agentic Development Harness for Reliance Teams

## Current Work
**Syllabus is designed.** The full 8-stage concept map with adaptive teaching framework is at `ideas/syllabus.md`. All design decisions are recorded in the syllabus's Decision Log section.

**Next steps:**
1. Resolve the 4 gaps in `HANDOFF_stage1_detail.md` (delegate convention, dynamic content, pitfall strategy, teacher-instructions.md) — these need updating to reflect the new adaptive model
2. Write `teaching/meta/teacher-instructions.md` incorporating the adaptive teaching framework
3. Write Stage 1 teaching scripts (bug-fix, test-writer, code-review, refactor) using the quality-rating model from the syllabus
4. Write Stage 1 working recipe YAMLs

**Stage 0:** Design complete (full Say/Check/Action scripts in `ideas/plan.md` under "Act Scripts" — not yet extracted to individual act files).
**Stage 1:** Syllabus complete with quality dimensions. Teaching scripts and working YAMLs not yet written.
**Stages 2-7:** Concepts defined in syllabus. Detailed scripts and recipes not started.

## User Context
- **Doni** — non-technical, runs onboarding centrally for Reliance teams
- **Platform:** Windows 11
- **Subscriptions:** Claude Max (primary), Codex (optional add-on)
- **Role:** Designs the system, doesn't write the recipes himself — works with AI to design and iterate
- **Writing style:** Direct, confident, no jargon. Has a captured style profile at `~/ClaudeProjects/General/style_profile_executive_strategy_memo.md` for written communications.

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
| `HANDOFF_stage1_detail.md` | Original handoff for Stage 1 work — lists 4 gaps to resolve before writing scripts | Before writing any Stage 1 content (gaps need re-evaluation against new adaptive model) |
| `overnight-pipeline/README.md` | Overnight pipeline framework — how to run, adapt, and start new runs | When setting up an overnight run or reviewing past results |

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
- **RIL Agents** (from ~/ClaudeInfra/ril-agents/) — 112+ specialized agents used as the execution layer in recipes
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
- **Facilitator/CodeWork/Eval pattern** — main agent facilitates, code subagent does hands work, eval subagent rates quality
- **Quality ratings not binary** — eval subagent rates Strong/Adequate/Weak, not yes/no
- **Stage 1 ordered by impact** — Bug Fix → Test Writer → Code Review → Refactor (not risk order)
- **RIL Agents as execution layer** — recipes invoke existing agents from ~/ClaudeInfra/ril-agents/

## Project Structure
```
RILGoose/
├── CLAUDE.md                           # This file
├── ideas/
│   ├── syllabus.md                     # 8-stage concept map + adaptive teaching framework + decisions
│   ├── plan.md                         # Original master plan with research and Stage 0 scripts
│   └── rollout-playbook.md             # Rollout phases, ROI metrics, selling guide
├── REFERENCES.md                       # Quick-access technical details (pipeline, Goose, CourseForge)
├── HANDOFF_stage1_detail.md            # Stage 1 gaps to resolve (needs re-eval against new model)
├── overnight-pipeline/                 # Autonomous overnight test-evaluate-fix framework
│   ├── README.md                       # How to use and adapt for different activities
│   ├── personas.md                     # 9 reusable mock developer personas
│   ├── edge-cases.md                   # 14 reusable edge case scenarios
│   ├── templates/                      # Copy these to start a new run
│   │   ├── loop-prompt.md              # Generic loop prompt with {ACTIVITY} placeholders
│   │   └── state.json                  # Starting state template
│   └── runs/                           # Archived completed runs
│       └── 2026-04-13-hardening/       # 20 cycles, 72 fixes, all regressions passed
├── recipes/                            # Working recipes (Goose YAML format)
│   ├── stage-0/                        # "See What AI Can Do"
│   ├── stage-1/                        # "Get Real Work Done" (bug-fix, test-writer, code-review, refactor)
│   ├── stage-2/                        # "Two AIs Are Better Than One"
│   ├── stage-3/                        # "Build a Team of AI Specialists"
│   ├── stage-4/                        # "From Idea to Buildable Spec"
│   ├── stage-5/                        # "Trust But Verify"
│   ├── stage-6/                        # "Let It Run While You Sleep"
│   └── stage-7/                        # "The System Gets Smarter"
├── teaching/                           # Teaching scripts and meta
│   ├── meta/
│   │   ├── teach-wrapper.yaml          # Meta-recipe that wraps any recipe in teaching
│   │   ├── teacher-instructions.md     # How the facilitator should behave
│   │   └── module-designer/            # Skill for designing modules (load when building)
│   │       ├── SKILL.md                # Main skill file (~300 lines)
│   │       └── references/             # Templates, formats, example module
│   │           ├── goose-recipe-format.md
│   │           ├── eval-prompt-template.md
│   │           ├── example-module.md   # Complete Bug Fix module as reference
│   │           ├── progression-format.md
│   │           └── ril-agents-map.md
│   ├── stage-0/                        # Stage 0 is scripted (acts are the teaching)
│   ├── stage-1/                        # Stage 1 guided-adaptive scripts
│   │   ├── bug-fix.teach.md
│   │   ├── test-writer.teach.md
│   │   ├── code-review.teach.md
│   │   └── refactor.teach.md
│   ├── stage-2/ through stage-7/       # All stages now have teaching scripts
├── onboarding/                         # Project onboarding recipe
│   └── onboard.yaml
└── install/                            # Setup scripts
    └── install.sh
```

## Cross-Project References
- **This project (RILGoose)**: Recipes, teaching scripts, onboarding, syllabus, plan
- **AgenticSystem** (`~/ClaudeProjects/AgenticSystem/`): Source pipeline patterns — file ownership, circuit breakers, escalation, cycle review. Read `LEARNINGS.md` and `Evaluations/` for concepts that inform Stages 2-7.
- **ddd-mcp-server** (`~/ClaudeProjects/ddd-mcp-server/`): DDD spec system — artifact chain, golden prompts, quality gates, executive review simulation. Informs Stage 4.
- **RIL Agents** (`~/ClaudeInfra/ril-agents/`): 112+ specialized agents used as execution layer. See syllabus "RIL Agents Integration" section for stage-to-agent mapping.
- **CourseForge** (`~/ClaudeProjects/CourseForge/`): Original teaching model (Say/Check/Action). Stage 0 still uses this. Stages 1+ evolved to adaptive model.
- **The Goose fork** (TBD): The actual forked runtime with our recipes added.

## When to Read What
- **Starting a new session?** Read `ideas/syllabus.md` — it's the source of truth for everything designed so far
- **Writing teaching scripts?** Read syllabus Stage 1 quality dimensions + `REFERENCES.md` Section 3 (CourseForge format) + plan.md Stage 0 act scripts (format reference)
- **Designing working recipes?** Read `REFERENCES.md` Section 2 (Goose recipe YAML, subagent syntax)
- **Discussing rollout or metrics?** Read `ideas/rollout-playbook.md`
- **Need deep context on a decision?** Check syllabus Decision Log first, then `ideas/plan.md`
- **Setting up an overnight run?** Read `overnight-pipeline/README.md`, copy templates from `overnight-pipeline/templates/`
