# RILGoose — Agentic Development Harness for Reliance Teams

## Current Work
**Active handoff:** `HANDOFF_stage1_detail.md` — flesh out Stage 1 teaching scripts and working recipe YAMLs.
**Stage 0:** Design complete (full Say/Check/Action scripts in `ideas/plan.md` under "Act Scripts" — not yet extracted to individual act files in `recipes/stage-0/acts/`).
**Stage 1:** Outline complete, needs full scripts and working YAMLs.
**Stages 2-5:** Outlined only.

## User Context
- **Doni** — non-technical, runs onboarding centrally for Reliance teams
- **Platform:** Windows 11
- **Subscriptions:** Claude Max (primary), Codex (optional add-on)
- **Role:** Designs the system, doesn't write the recipes himself — works with AI to design and iterate
- **Writing style:** Direct, confident, no jargon. Has a captured style profile at `~/ClaudeProjects/General/style_profile_executive_strategy_memo.md` for written communications.

## What This Is
A fork of [Goose](https://github.com/aaif-goose/goose) (Block/Linux Foundation's agent platform) extended with progressive teaching recipes that take development teams from zero agentic experience to autonomous development pipelines.

## Core Architecture
- **Goose fork** — battle-tested runtime, recipe system, sub-recipes, subagents, ACP, MCP extensions, desktop app + CLI
- **Our pipeline patterns** (from AgenticSystem) — file ownership, circuit breakers, 4-tier testing, escalation routing, separated concerns
- **CourseForge teaching model** — Say/Check/Action scripts, self-teaching architecture, exercise quality scorecard

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

## Key Technical Decisions
- **ACP** for subscription-based access (Claude Max, Codex) — no API keys
- **Recipe layer only** — don't touch Goose's Rust core
- **LLM-based orchestration** — use Goose's native subagents, add code-based orchestration only if needed
- **Hooks deferred** — Goose's ToolInspector trait makes adding them later ~200 lines
- **Teacher/Hands pattern** — main agent teaches (never touches code), subagents do all code work
- **Forced teaching** — first run of any recipe is teaching mode, mandatory. `/teach` to revisit.
- **Dual-mode recipes** — working YAML + teaching script (.teach.md), wrapped by teach-wrapper.yaml

## Project Structure
```
RILGoose/
├── CLAUDE.md                           # This file
├── ideas/
│   └── plan.md                         # Master plan with all decisions and research
├── recipes/                            # Working recipes (Goose YAML format)
│   ├── stage-0/                        # "From Chat to Code"
│   │   ├── from-chat-to-code.yaml      # Parent recipe (teacher orchestrator)
│   │   ├── acts/                       # Act scripts loaded via load()
│   │   │   ├── act-1-see-your-code.md
│   │   │   ├── act-2-first-edit.md
│   │   │   ├── act-3-undo-button.md
│   │   │   ├── act-4-catch-the-bug.md
│   │   │   └── act-5-say-it-better.md
│   │   └── state/                      # Per-user progress tracking
│   ├── stage-1/                        # "Real Work" (code-review, test-writer, bug-fix, refactor)
│   ├── stage-2/                        # "Agent + Verification"
│   ├── stage-3/                        # "Multi-Agent Pipelines"
│   ├── stage-4/                        # "Autonomous Cycles"
│   └── stage-5/                        # "Self-Improving Systems"
├── teaching/                           # Teaching scripts (separate from working recipes)
│   ├── meta/
│   │   ├── teach-wrapper.yaml          # Meta-recipe that wraps any recipe in teaching
│   │   └── teacher-instructions.md     # How the teacher should behave (level-adapted)
│   ├── stage-0/                        # Stage 0 is self-contained (acts are teaching)
│   ├── stage-1/
│   │   ├── code-review.teach.md
│   │   ├── test-writer.teach.md
│   │   ├── bug-fix.teach.md
│   │   └── refactor.teach.md
│   └── stage-2/
├── onboarding/                         # Project onboarding recipe
│   └── onboard.yaml                    # Auto-detect + ask + generate + validate + handoff
├── install/                            # Setup scripts
│   └── install.sh                      # Zero-assumption install script
└── HANDOFF_stage1_detail.md            # Current handoff for Stage 1 work
```

## 6-Stage Maturity Model
| Stage | Name | Key Concept |
|-------|------|-------------|
| 0 | From Chat to Code | AI can see/edit code, git safety, AI makes mistakes, prompting |
| 1 | Real Work | Code review, test writing, bug fixing, refactoring |
| 2 | Agent + Verification | Separation of concerns, second AI checks first |
| 3 | Multi-Agent Pipelines | Agent roles, escalation, circuit breakers |
| 4 | Autonomous Cycles | Cycle review, meta-improvement, learnings |
| 5 | Self-Improving Systems | Skill evolution, metrics-driven improvement |

## How to Work in This Project
1. Read `ideas/plan.md` for the full plan with all decisions and research
2. Read `REFERENCES.md` for quick-access technical details on all three source systems (pipeline patterns, Goose mechanics, CourseForge format)
3. Stage 0 design is complete (teaching scripts in the plan, need to be extracted to act files)
4. Stage 1 design needs fleshing out — see `HANDOFF_stage1_detail.md`
5. Stages 2-5 are outlined but not designed yet
6. The Goose fork hasn't been created yet — recipes are being designed first

## When to Read Reference Sources
- **Writing teaching scripts?** Read `REFERENCES.md` Section 3 (CourseForge format) + the Stage 0 act scripts in the plan for format examples
- **Designing working recipes?** Read `REFERENCES.md` Section 2 (Goose recipe YAML, subagent syntax)
- **Designing Stage 2+ content?** Read `REFERENCES.md` Section 1 (pipeline patterns, learnings, evaluation findings)
- **Need deep context on a decision?** Read `ideas/plan.md` — every decision has rationale and research

## What Lives Where
- **This project (RILGoose)**: Recipes, teaching scripts, onboarding, install scripts, plan
- **AgenticSystem**: The source pipeline patterns we're porting (reference only, don't modify)
- **CourseForge**: The teaching model we're adapting (reference only, don't modify)
- **The Goose fork** (TBD): The actual forked runtime with our recipes added
