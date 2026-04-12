# Team Context

Every recipe reads this file at startup. This describes the RILGoose project so the AI understands context.

---

## Project

- **Name:** RILGoose
- **Description:** A progressive teaching harness built on Goose (Block/Linux Foundation agent platform) that takes Reliance development teams from zero agentic experience to autonomous development pipelines through an 8-stage curriculum.
- **Repository:** C:\Users\donid\ClaudeProjects\RILGoose

---

## Stack

- **Language:** YAML (recipes), Markdown (teaching scripts, design docs)
- **Framework:** Goose agent platform (Rust core, recipe layer)
- **Database:** None — file-based configuration and state
- **Other:** Claude Code (via ACP), RIL Agents (112+ specialized agents), MCP extensions

---

## Test Commands

- **Run all tests:** Not applicable — this is a recipe/teaching content project, not a compiled application
- **Validation:** Recipes are validated by loading them in Goose; teaching scripts are reviewed manually or via eval subagents

---

## Build Commands

- **Build:** No build step — recipes and teaching scripts are consumed directly by Goose
- **Run locally:** Load a recipe in Goose desktop app or CLI (e.g., `goose run recipes/stage-0/see-what-ai-can-do.yaml`)
- **Lint:** No automated linting — YAML syntax checked on recipe load

---

## Conventions

- **Naming:** Kebab-case for file names (e.g., `bug-fix.teach.md`), stage-numbered directories (e.g., `stage-0/`, `stage-1/`)
- **File structure:** `recipes/` for working Goose YAMLs, `teaching/` for teaching scripts, `ideas/` for design docs
- **Branch naming:** Feature branches off main
- **Commit messages:** Descriptive, no ticket prefix convention

---

## Ownership Model

- **Recipes and teaching scripts:** Doni (project owner, non-technical) — designs with AI assistance
- **Goose core:** Upstream project — we only touch the recipe layer, never the Rust core
- **RIL Agents:** Managed separately in ~/ClaudeInfra/ril-agents/ — referenced but not modified here

---

## Known Issues

- Stage 0 act scripts exist in `ideas/plan.md` (lines 707-1155) but have not been extracted to individual files yet
- `HANDOFF_stage1_detail.md` has 4 unresolved gaps that need re-evaluation against the adaptive teaching model before Stage 1 scripts can be written
- Goose recipe format details are in `REFERENCES.md` — recipes must follow that exact YAML structure to load correctly
