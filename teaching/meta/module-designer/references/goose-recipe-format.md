# Goose Recipe YAML Format

## Working Recipe Template

```yaml
version: 1.0.0
title: "Recipe Name"
description: "One-line: what this recipe does for the developer"

parameters:
  - key: param_name
    input_type: text           # text, number, select, file
    requirement: required       # required, optional
    description: "What this parameter is"

instructions: |
  You are a [role] helping a developer [do what].
  
  Read .goose/team_context.md for the project's stack and conventions.
  
  [Clear, specific instructions for the agent.
   What to do. What to return. What NOT to do.
   No teaching content — this is a tool, not a lesson.]

extensions:
  - type: builtin
    name: developer

prompt: |
  [Starting prompt with {{ param_name }} template vars.
   This is what the agent sees first when the recipe runs.]
```

## Rules

1. **No teaching content.** The working recipe is a reusable tool. No explanations of why it's useful, no pitfall warnings, no coaching.
2. **Read team context.** Every recipe reads `.goose/team_context.md` first for stack info.
3. **Tier, not model.** Use `# tier: reasoning` or `# tier: fast` in comments. Never hardcode model names.
4. **Extension scoping.** Specify minimum needed extensions. Most recipes need `developer` at minimum.
5. **Parameters for user input.** Use Goose's parameter system for developer-provided values.
6. **Structured output.** The agent should return clear, structured results the developer can act on immediately.

## Sub-Recipe Invocation (for teach-wrapper)

The teach-wrapper invokes a working recipe as a sub-recipe:

```yaml
sub_recipes:
  - name: "bug_fix"
    path: "./recipes/stage-1/bug-fix.yaml"
    description: "Fix a bug in the developer's codebase"
    values:
      bug_description: "{{ developer_input }}"
```

Parent invokes via: `subagent(subrecipe: "bug_fix", parameters: {...})`

## Extension Reference

| Extension | What It Provides | When to Use |
|-----------|-----------------|-------------|
| `developer` | File read/write, terminal commands, git | Almost every recipe |
| Additional MCP extensions | Database, cloud, CI/CD tools | Per project config |
