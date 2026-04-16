# Goose Wizard — Agentic Development Harness for Reliance Teams

## Two Audiences — AIF vs RIL

**AIF (AI Foundry)** is Doni's team — the builders and teachers. ~10-12 people (Nate, Kyle, Jessica, Elsa, Rod, Kani, Kathleen, James, Jennifer, Doni, plus RIL-side collaborators Dharmendra, Amit, Anindya). All AI-literate experts. AIF uses Linear (workspace: "Aifoundry") as their task management system and is dogfooding the agentic workflow — Linear + AI agents — for their own work before teaching it to RIL teams.

**RIL (Reliance) teams** are the students — skeptical development teams with little or no AI coding experience. They are the target audience for the 8-stage curriculum. AIF teaches/builds systems for them.

When discussing "the team" or "our workflow," it means AIF unless explicitly stated otherwise. When discussing "the audience" or "developers learning," it means RIL teams.

## What This Is

A fork of Goose (Block/Linux Foundation's agent platform) extended with progressive teaching recipes that take development teams from zero agentic experience to autonomous development pipelines.

## Key Documents

| Document | What It Contains |
|----------|-----------------|
| `ideas/syllabus.md` | 8-stage concept map, adaptive teaching framework, quality-rating model |
| `ideas/plan.md` | Original research, architecture decisions, Stage 0 act scripts |
| `REFERENCES.md` | Pipeline patterns, Goose mechanics, CourseForge format |
| `overnight-pipeline/README.md` | Overnight pipeline framework |

## Architecture

- **Recipe layer only** — don't touch Goose's Rust core
- **Three agent roles:** Facilitator (guides), Code-Work Subagent (codes), Eval Subagent (rates quality)
- **Quality ratings:** Strong/Adequate/Weak, not binary pass/fail
- **RIL Agents** (`~/ClaudeInfra/ril-agents/`): 112+ specialized agents used as execution layer
