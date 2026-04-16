# GooseForge Design Principles

Adapted from SubagentForge's 18 principles for the Goose recipe platform. These principles guide how GooseForge designs agent recipes.

**See also:** `recipe-hygiene.md` — concrete, checkable rules that operationalize these principles for Primitives vs Workflow Recipes.

---

## The 12 Core Principles

### 1. Single Responsibility, Sharp Identity

Every recipe gets one clear role expressed in one sentence. "Reviews code changes for security vulnerabilities" — not "helpful development assistant." Specialist recipes outperform generalists on every dimension.

**Test:** Can you describe what this recipe does in 15 words or less? If not, split it.

### 2. Constraints Are Features

Explicit boundaries on scope, tools, and output format produce higher quality than open-ended freedom. Define what the recipe DOES and what it DOES NOT do. A recipe with no "NEVER" statements is underspecified.

**Test:** Does the recipe have at least 3 explicit "NEVER" or "Do NOT" constraints in its instructions?

### 3. Prescriptive Over Descriptive

"NEVER modify source files" beats "tries to avoid modifying files." Use imperative language: Always, Never, Must. Behavioral rules are constraints, not suggestions.

**Test:** Read each rule in the instructions — would the agent know exactly what to do in an ambiguous situation?

### 4. Separate Planning from Execution

Build in structured reasoning before action. Coordinators plan, workers execute. Individual recipes think before acting. Without this separation, agents make cascading errors.

**In Goose:** The `instructions:` Process section should have distinct plan and execute phases.

### 5. Define Success Before Starting

Every recipe needs success criteria in the Return section. If you can't define "done well," the agent will drift. Define acceptance criteria before the work begins.

**Test:** Could someone unfamiliar with the task read the Return section and judge the output?

### 6. Context Is Finite and Precious

Every token depletes attention. Context degrades as it grows. Find the smallest set of high-signal input that produces the desired output. When agents hand off to each other via sub-recipes, pass scoped summaries — not raw history.

**In Goose:** Keep `instructions:` short (behavioral rules). Put the work in `prompt:`. Parameters should be focused, not kitchen-sink.

### 7. Invest in the Recipe, Not Just the Model

Same model, different recipe = dramatically different performance. The recipe determines: what tools are available, what constraints apply, what the agent sees, and how it reports results.

**In Goose:** A well-structured recipe with clear constraints outperforms a vague recipe on a better model.

### 8. Teams Need Coordination Protocols

Individually capable agents without common contracts are collectively incoherent. Define: who talks to whom (sub_recipes), in what format (parameter/return schemas), when handoffs happen, and what escalation looks like.

**In Goose:** Sub-recipe `parameters:` and `Return:` blocks ARE the contracts. Make them explicit.

### 9. Metacognitive Self-Awareness

Agents should know when they're uncertain. When confidence is low, escalate — don't guess. When the task is outside scope, say so — don't drift.

**In Goose:** Add "If uncertain about X, escalate to [target] instead of guessing" to the instructions.

### 10. Evidence Over Opinion

Every claim cites file:line. Severity ratings come with evidence. When the agent doesn't know, it says so. No opinion-based findings.

**In Goose:** The Return section should require evidence fields alongside every finding or recommendation.

### 11. Map Failure Modes Before Design

Before writing capabilities, map how the recipe can fail. For each failure mode: how it manifests, how to detect it, what happens when triggered. This makes failure visible and addressable.

**In Goose:** The Failure Modes section of instructions should be written BEFORE the Process section.

### 12. Graceful Shutdown and Resumability

Every recipe needs to report its state if interrupted. State must be persistable to files. For pipeline recipes, always produce an escalation packet on failure — not silent exit.

**In Goose:** Use `.goose/state/` files. Circuit breakers should produce structured escalation packets.

---

## Goose-Specific Principles

### 13. Instructions Are Short, Prompt Is the Work

Goose's system.md buries long instructions. Keep `instructions:` to behavioral rules (6 rules max). Put the actual work script, detailed flow, and task-specific content in `prompt:`.

### 14. Extensions Are Least Privilege

Only list extensions the recipe actually needs. A read-only reviewer should not have `developer` (which includes write/edit). Match extensions to the recipe's actual capabilities.

### 15. Sub-Recipes Are Workers, Not Conversations

Goose sub-recipes are non-interactive. They receive structured input, do work, return results. Design them as focused workers — not as interactive sessions. The parent recipe handles all developer interaction.

### 16. Parameters Drive the Interface

Goose parameters are the user's interface to the recipe. One required parameter drives the core task. 2-3 optional parameters refine it. Every parameter needs a user-facing description (not internal jargon).

---

## Agent Archetypes

When designing a recipe, classify it first. Each archetype has different best practices:

| Archetype | Does What | Key Principles |
|-----------|-----------|---------------|
| **Reviewer** | Examines artifacts, produces structured findings | P1, P2, P10 — Single responsibility, constraints (read-only), evidence |
| **Builder** | Implements changes within ownership boundaries | P4, P5, P2 — Plan then execute, success criteria, file boundaries |
| **Coordinator** | Decomposes tasks, assigns agents, synthesizes results | P8, P4, P6 — Coordination protocols, planning, scoped context |
| **Evaluator** | Judges work against defined criteria, issues verdicts | P5, P10, P11 — Success criteria, evidence, failure modes |
| **Investigator** | Diagnoses problems via hypothesis-evidence cycles | P10, P4, P9 — Evidence, plan before act, know when uncertain |

See the individual `archetype-*.md` files for detailed best practices per type.
