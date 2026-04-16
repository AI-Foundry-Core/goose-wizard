# Canonical Recipe Structure

Every GooseForge-generated recipe follows this structure. The 10 canonical directive sections map to Goose YAML fields as shown below.

**See also:** `recipe-hygiene.md` — behavioral constraints that every recipe generated from this template must satisfy.

---

## Section-to-YAML Mapping

| # | Canonical Section | Goose YAML Location |
|---|---|---|
| 1 | Role + Scope | `title:`, `description:`, first paragraph of `instructions:` |
| 2 | Constraints & Boundaries | IMPORTANT block in `instructions:` + `extensions:` (tool restriction) |
| 3 | Decision Framework | Process section of `instructions:` |
| 4 | Approval Tiers | Text in `instructions:` (Goose handles permissions at runtime) |
| 5 | Failure Modes | Safety rails section of `instructions:` |
| 6 | Task Decomposition Limits | `instructions:` + `sub_recipes:` |
| 7 | Context Architecture | `parameters:` + file-read directives in `instructions:` + `extensions:` |
| 8 | Verification Requirements | Evidence rules in `instructions:` Process section |
| 9 | Session Lifecycle | Checkpoint/state rules in `instructions:` (runtime manages sessions) |
| 10 | Success Criteria | Return block at end of `instructions:` |

---

## Template

```yaml
version: 1.0.0
# type: primitive | training | coordinator       # Hygiene rule U1
title: "Short Name"                              # Section 1: identity
description: "One sentence — what it does"       # Section 1: trigger

parameters:                                       # Section 7: user inputs
  - key: primary_input
    input_type: string
    requirement: required
    description: "The main task — user-facing language"
  - key: optional_context
    input_type: string
    requirement: optional
    default: ""
    description: "Additional context if available"

instructions: |
  ## Role                                         # Section 1
  You are a [role]. Your job is [one sentence mission].
  You receive [input]. You produce [output].

  ## Constraints                                  # Section 2
  IMPORTANT:
  - NEVER [hard constraint 1]
  - NEVER [hard constraint 2]
  - Do NOT [boundary 3]

  ## Process                                      # Sections 3 + 8
  1. [Step — include decision gates]
  2. [Step — include verification points]
  3. [Step — include evidence requirements]

  ## Failure Modes                                # Section 5
  - If [condition]: [detection] → [mitigation]
  - If [condition]: [detection] → [mitigation]
  - Circuit breaker: if [repeated failure], halt and escalate.

  ## Return                                       # Section 10
  Return:
  - field_1: [what it contains — measurable]
  - field_2: [what it contains — measurable]
  - field_3: [what it contains — measurable]

extensions:                                       # Section 2 + 7: tools
  - type: builtin
    name: developer

# sub_recipes:                                    # Section 6: decomposition
#   - name: "child_task"
#     path: "../agents/child.yaml"
#     description: "What the child does"

prompt: |                                         # Section 7: initial context
  Primary input: {{ primary_input }}
  Context: {{ optional_context }}
  [One-line action directive.]
```

---

## Rules for Each Section

### Section 1: Role + Scope
- `title:` is 3-7 words, action-oriented
- `description:` is one sentence explaining when to use this recipe
- First paragraph of `instructions:` states role, input format, output format

### Section 2: Constraints
- Minimum 3 explicit "NEVER" or "Do NOT" statements
- Use prescriptive language — "NEVER", not "tries to avoid"
- `extensions:` enforces tool-level constraints (least privilege)

### Section 3: Decision Framework
- Numbered steps in the Process section
- Include decision gates: "If X, then Y. Otherwise, Z."
- Include grading criteria if the recipe evaluates anything

### Section 5: Failure Modes
- Write BEFORE the Process section (design principle: map failures before building)
- Each failure mode has: condition, detection signal, mitigation action
- Multi-agent recipes must have circuit breakers with explicit thresholds

### Section 7: Context Architecture
- One required `parameter:` drives the task
- 2-3 optional parameters refine it
- File reads in instructions load project context (`.goose/team_context.md`)
- `prompt:` injects parameters as the initial message

### Section 10: Success Criteria
- `Return:` block lists every output field
- Each field must be measurable (not "good code" — "diff of changes")
- A reviewer could verify the output against these fields

---

## YAML Generation Rules

When GooseForge produces a recipe, it must follow these rules:

1. **Multi-line strings**: Always use `|` (literal block scalar)
2. **Indentation**: 2 spaces throughout, consistent
3. **Quoting**: Double-quote all `title:`, `description:`, and `default:` values
4. **Parameters**: `input_type` must be one of: `string`, `number`, `boolean`, `date`, `file`
5. **Optional params**: Must have `default:` field (use `""` for empty string)
6. **File params**: Cannot have defaults (security restriction)
7. **Templates**: `{{ param_name }}` only — no conditionals, no filters, no dots
8. **Empty defaults**: Use `default: ""` (not `default:` or `default: null`)
9. **Boolean values**: Quote `yes`, `no`, `on`, `off` if they are string values
10. **Validation**: Output must pass `goose recipe validate`
