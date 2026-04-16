# Ported Agents — Stage-to-Agent Mapping

Agents in `recipes/ported-agents/` used as code-work sub-recipes in each stage. These are RIL-library agents ported into goose-wizard as Goose recipe YAMLs — lineage lives in `handoffs/ril-agents-port-*.md`, but runtime references are all local.

| Stage | Task | Ported Agent(s) | Folder | Notes |
|-------|------|-----------------|--------|-------|
| 1 | Bug Fix | `debugger`, `error-detective` | error-debugging | Investigation + root cause analysis |
| 1 | Test Writer | `test-automator` | unit-testing | Test generation |
| 1 | Code Review | `code-reviewer`, `architect-review` | comprehensive-review | Quality analysis + architectural consistency |
| 1 | Refactor | `legacy-modernizer` | code-refactoring | Safe incremental restructuring |
| 2 | Build-then-test | `test-automator` (separated from builder) | unit-testing | Key: different agent from the builder |
| 2 | Review gate | `code-reviewer` (as gate) | comprehensive-review | Checks builder output independently |
| 4 | Spec writing | `prd-development` | product-planning | PRD generation from feature ideas |
| 4 | Detailed spec | `feature-spec`, `acceptance-criteria` | product-specification | Testable acceptance criteria |
| 5 | Eval design | `product-evaluation`, `post-mortem` | product-evaluation | Structured evaluation and retrospective |
| 6 | Cycle hygiene | Overnight-pipeline patterns | (none — see `overnight-pipeline/`) | Conductor is a separate native Goose system; see conductor roadmap |
| 7 | Skill evolution | `tutorial-engineer` | code-documentation | Generates evolved skill files |

## How to Invoke

In the teach script, the code-work subagent invokes ported agents via the working recipe's sub-recipe system. The teach script doesn't reference ported agents directly — it invokes the working recipe, which uses the appropriate agents internally.

In the working recipe YAML, reference the agent's YAML in the instructions:

```yaml
instructions: |
  You are operating as a code reviewer. Follow the patterns in
  recipes/ported-agents/comprehensive-review/code-reviewer.yaml

  Read .goose/team_context.md for project context.
  [... specific task instructions ...]
```

## Lineage note

These ports were created on 2026-04-15. The originals remain at `~/ClaudeInfra/ril-agents/` as read-only reference; they are not runtime dependencies. The conductor plugin was deliberately NOT ported here — it's being redesigned as a native multi-recipe Goose system in a follow-up session (see handoff).
