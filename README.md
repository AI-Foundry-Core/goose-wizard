# goose-wizard

A progressive AI teaching harness built on [Goose](https://github.com/block/goose). Takes a development team from "never used AI coding tools" to "running autonomous multi-agent pipelines" through 26 hands-on modules across 8 stages.

Every module has you do real work on real code. You get coached on what you're missing. By the end, you can design and run your own AI pipelines — not just use pre-built ones.

## What's inside

- **8 stages, 26 modules** — from "AI fixes a bug" to "a pipeline that runs while you sleep and improves itself"
- **Three recipe types** — training (interactive facilitators), agents (non-interactive workers), graduated (daily-use multi-agent coordinators)
- **GooseForge** — design your own recipes and pipelines once you know the pattern

The full curriculum is in `ideas/syllabus.md`.

## Install

One line. Open a terminal and paste:

**Mac / Linux:**
```
curl -fsSL https://raw.githubusercontent.com/AI-Foundry-Core/goose-wizard/main/install.sh | bash
```

**Windows (PowerShell):**
```
irm https://raw.githubusercontent.com/AI-Foundry-Core/goose-wizard/main/install.ps1 | iex
```

The installer will:
- Install Goose CLI, Claude CLI, Node, Git (if missing)
- Clone this repo to `~/goose-wizard`
- Log you into Claude (a Claude Max subscription is required)
- Configure Goose for the training recipes
- Launch the gateway tutorial automatically

That's it — one line from install to your first training module. See [install/README.md](install/README.md) for details and troubleshooting.

> Keep the Goose desktop app open on the side during training — it's a good way to **browse the recipe YAML files** after each module's Recipe Reveal. Just don't run recipes from the app; the CLI experience is what the training is designed around.

## For teachers / recipe authors

If you're adding modules or recipes, start with `CLAUDE.md` at the repo root — it explains the teaching framework, the three recipe types, and the design conventions.

- `CLAUDE.md` — project instructions and conventions
- `HOW_GOOSE_WORKS.md` — Goose internals (scheduler, recipes, extensions, CLI)
- `ideas/syllabus.md` — full 8-stage concept map and decision log
- `teaching/meta/module-designer/SKILL.md` — the module-authoring skill

## Status

Active development. Target audience for the teaching flow is development teams new to AI coding tools; the harness itself is also used internally to dogfood agentic workflows.
