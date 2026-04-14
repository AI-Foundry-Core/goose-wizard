# Goose Recipe YAML Format

## Agent Primitive Template

Agent primitives live in `recipes/agents/`. They are non-interactive workers called as sub-recipes by training and graduated recipes.

```yaml
version: 1.0.0
title: "Name Agent"                    # Always ends with "Agent"
description: "One-line: what this recipe does"

parameters:
  - key: param_name
    input_type: string               # string, number, boolean, date, file
    requirement: required             # required, optional
    description: "What this parameter is"
  - key: optional_param
    input_type: string
    requirement: optional
    default: ""                       # Required for optional params
    description: "Additional context if available"

instructions: |
  You are a [role] specialist. You receive [input] and return [output].

  Read `.goose/team_context.md` for the project's stack and conventions.

  Follow the patterns in:
  ~/ClaudeInfra/ril-agents/plugins/[domain]/agents/[agent].md

  ## Constraints
  IMPORTANT:
  - NEVER [hard constraint 1]
  - NEVER [hard constraint 2]
  - NEVER [hard constraint 3]
  - NEVER [hard constraint 4]

  ## Process
  1. [Step with decision gate]
  2. [Step with verification]
  3. [Step with evidence requirement]

  ## Return
  Return:
  - field_1: [measurable output]
  - field_2: [measurable output]

extensions:
  - type: builtin
    name: developer

prompt: |
  Input: {{ param_name }}
  Context: {{ optional_param }}
  [One-line action directive.]
```

## Training Recipe Template

Training recipes live in `recipes/shared/`. They are interactive facilitators that call agent primitives via sub_recipes.

```yaml
version: 1.0.0
title: "N.N Name (Training)"          # Always ends with "(Training)"
description: "Guided walkthrough: [what it teaches]"

parameters:                            # Match the agent primitive's parameters
  - key: param_name
    input_type: string
    requirement: required
    description: "Same as agent primitive"

sub_recipes:
  - name: "agent_name"
    path: "../agents/agent-name.yaml"
    description: "What the agent does"
  - name: "graduate_module"
    path: "../agents/graduate-module.yaml"
    description: "Graduates the module by replacing training recipe with working version"

instructions: |                        # 6 rules only — work goes in prompt
  You are a teaching facilitator running a guided [topic] session.

  Rules:
  1. INTERACTIVE: Stop and WAIT for the developer at every decision point.
  2. NARRATE DELEGATION: Tell the developer when you're calling the agent.
  3. NEVER touch code yourself — all work goes through the sub-recipe.
  4. NEVER mention eval, ratings, scores, or that this is training.
  5. COACH NATURALLY: Weave feedback into conversation, not a list.
  6. LEAD WITH STRENGTH: Praise what the developer did well before coaching gaps.

prompt: |
  [Full teaching flow: runtime isolation, file reads, progression check,
   teaching script flow, eval, recipe reveal, state update, graduation, bridge]
```

## Sub-Recipe Invocation

Training recipes invoke agent primitives as sub-recipes:

```yaml
sub_recipes:
  - name: "bug_fix"
    path: "../agents/bug-fix.yaml"
    description: "Investigates and fixes a bug"
```

Called in the prompt via: `subagent(subrecipe: "bug_fix", parameters: {...})`

## Rules

1. **Agent primitives have no teaching content.** They are reusable tools.
2. **Read team context.** Every recipe reads `.goose/team_context.md`.
3. **Tier, not model.** Use `# tier: reasoning` in comments. Never hardcode models.
4. **Extension scoping.** Minimum needed. Most recipes need `developer`.
5. **Parameters for user input.** Use Goose's parameter system.
6. **Structured Return block.** Every primitive must define output fields.
7. **Template vars match params.** Every `{{ var }}` in prompt must have a matching `key:`.
8. **Optional params need defaults.** Use `default: ""` for empty strings.

## Extension Reference

| Extension | What It Provides | When to Use |
|-----------|-----------------|-------------|
| `developer` | File read/write, terminal commands, git | Almost every recipe |
| `analyze` | Code analysis tools | Recipes needing static analysis |
