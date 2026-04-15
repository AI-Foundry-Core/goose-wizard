# RILGoose

A progressive AI teaching harness built on [Goose](https://github.com/block/goose). Takes a development team from "never used AI coding tools" to "running autonomous multi-agent pipelines" through 26 hands-on modules across 8 stages.

Every module has you do real work on real code. You get coached on what you're missing. By the end, you can design and run your own AI pipelines — not just use pre-built ones.

## What's inside

- **8 stages, 26 modules** — from "AI fixes a bug" to "a pipeline that runs while you sleep and improves itself"
- **Three recipe types** — training (interactive facilitators), agents (non-interactive workers), graduated (daily-use multi-agent coordinators)
- **GooseForge** — design your own recipes and pipelines once you know the pattern

The full curriculum is in `ideas/syllabus.md`.

## Install

**Windows:** Double-click `install\install-windows.bat` in a fresh clone.

**Mac:** Double-click `install/install-mac.command` in Finder.

Either installer will:
- Install Goose CLI + desktop app, Claude CLI, Node, Git (if missing)
- Prompt you to log into Claude (a Claude Max subscription is required)
- Configure Goose to find this repo's training recipes
- Apply a small set of patches to the Claude-ACP adapter so recipes run cleanly

See `install/README.md` for details, troubleshooting, and manual-setup instructions.

## Start training

Training runs from the **command line**, not the desktop app. Open a terminal in the RILGoose directory and run:

```
goose run --recipe 00-start-here --interactive
```

The gateway tutorial walks you through Goose, the training arc, and captures which codebase you want to train on.

> Keep the Goose desktop app open on the side during training — it's a good way to **browse the recipe YAML files** after each module's Recipe Reveal. Just don't run recipes from the app; the CLI experience is what the training is designed around.

## For teachers / recipe authors

If you're adding modules or recipes, start with `CLAUDE.md` at the repo root — it explains the teaching framework, the three recipe types, and the design conventions.

- `CLAUDE.md` — project instructions and conventions
- `HOW_GOOSE_WORKS.md` — Goose internals (scheduler, recipes, extensions, CLI)
- `ideas/syllabus.md` — full 8-stage concept map and decision log
- `teaching/meta/module-designer/SKILL.md` — the module-authoring skill

## Status

Active development. Target audience for the teaching flow is development teams new to AI coding tools; the harness itself is also used internally to dogfood agentic workflows.
