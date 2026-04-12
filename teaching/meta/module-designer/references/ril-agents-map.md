# RIL Agents — Stage-to-Agent Mapping

Agents from `~/ClaudeInfra/ril-agents/` used as code-work subagents in each stage.

| Stage | Task | RIL Agent(s) | Plugin | Notes |
|-------|------|-------------|--------|-------|
| 1 | Bug Fix | `debugger`, `error-detective` | error-debugging | Investigation + root cause analysis |
| 1 | Test Writer | `test-automator` | unit-testing | Test generation. `tdd-orchestrator` available but TDD not a core concept |
| 1 | Code Review | `code-reviewer`, `architect-review` | comprehensive-review | Quality analysis + architectural consistency |
| 1 | Refactor | `legacy-modernizer` | code-refactoring | Safe incremental restructuring |
| 2 | Build-then-test | `test-automator` (separated from builder) | unit-testing | Key: different agent from the builder |
| 2 | Review gate | `code-reviewer` (as gate) | comprehensive-review | Checks builder output independently |
| 3 | Team pipeline | `team-lead` | agent-teams | Decomposes work into parallel tasks |
| 3 | Parallel execution | `team-implementer`, `team-reviewer` | agent-teams | Defined roles, file ownership |
| 4 | Spec writing | `prd-development` | product-planning | PRD generation from feature ideas |
| 4 | Detailed spec | `feature-spec`, `acceptance-criteria` | product-specification | Testable acceptance criteria |
| 5 | Eval design | `product-evaluation`, `post-mortem` | product-evaluation | Structured evaluation and retrospective |
| 6 | Orchestration | Conductor framework | conductor | Autonomous track management |
| 7 | Skill evolution | `tutorial-engineer` | documentation-generation | Generates evolved skill files |

## How to Invoke

In the teach script, the code-work subagent invokes RIL agents via the working recipe's sub-recipe system. The teach script doesn't reference RIL agents directly — it invokes the working recipe, which uses the appropriate agents internally.

In the working recipe YAML, reference the agent in the instructions:
```yaml
instructions: |
  You are operating as a code reviewer. Follow the patterns in 
  ~/ClaudeInfra/ril-agents/plugins/comprehensive-review/agents/code-reviewer.md
  
  Read .goose/team_context.md for project context.
  [... specific task instructions ...]
```
