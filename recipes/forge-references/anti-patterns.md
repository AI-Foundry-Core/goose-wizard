# Anti-Patterns in Recipe Design

Common failures by archetype and general YAML generation pitfalls. GooseForge checks for these during validation.

---

## Universal Anti-Patterns

### 1. The Kitchen-Sink Recipe
**What it looks like:** One recipe that reviews, builds, tests, and deploys.
**Why it fails:** No single prompt can do everything well. The agent drifts between roles, skips steps, and produces inconsistent output.
**Fix:** Split into focused recipes. If it does two things, it should be two recipes.

### 2. The Vague Constraint
**What it looks like:** "The agent should try to be careful with file modifications."
**Why it fails:** "Try to" and "should" are suggestions, not rules. The agent will ignore them under pressure.
**Fix:** "NEVER modify files outside the assigned directory. NEVER skip test verification."

### 3. The Missing Failure Mode
**What it looks like:** A recipe with a Process section but no Failure Modes section.
**Why it fails:** Every recipe will encounter unexpected situations. Without failure modes, the agent improvises — badly.
**Fix:** Write Failure Modes BEFORE the Process section (Principle 11).

### 4. The Unstructured Return
**What it looks like:** "Return a summary of what you did."
**Why it fails:** Unstructured output can't be validated, parsed, or passed to downstream agents.
**Fix:** Define a Return block with named fields: root_cause, diff, test_results.

### 5. The Context Dump
**What it looks like:** Passing the entire conversation history to a sub-recipe.
**Why it fails:** Context is finite. Irrelevant context degrades performance (context rot).
**Fix:** Pass scoped summaries — task_summary, affected_files, constraints. Not raw history.

### 6. The Self-Reviewer
**What it looks like:** A builder that checks its own work before returning.
**Why it fails:** Self-verification bias — the agent that wrote the code thinks it's correct.
**Fix:** Separate builder and reviewer into different recipes. Never let one agent grade its own work.

---

## Archetype-Specific Anti-Patterns

### Reviewer
- **Monolithic reviewer:** Reviews everything in one pass (security, performance, style, logic). Produces noise. Split by dimension.
- **Opinionated findings:** "This code could be cleaner" with no file:line or evidence. Require structured findings.
- **Write access:** A reviewer that also applies fixes. Reviewers are read-only.

### Builder
- **Unbounded scope:** Builder with write access to the entire repo. Scope to assigned files only.
- **Narrative input:** Builder receives "make it better" instead of a structured spec. Require spec contracts.
- **Opportunistic refactoring:** Builder "cleans up" adjacent code while implementing. Stay within spec.

### Coordinator
- **Coding coordinator:** Coordinator that writes code instead of delegating. Coordinators plan and synthesize — never implement.
- **Agent sprawl:** More agents than tasks. Each agent should have meaningful work.
- **Silent failure:** Coordinator that absorbs errors without escalating. Always produce escalation packets.

### Evaluator
- **Vibe check:** Evaluator with no defined criteria — just "evaluate the quality." Require enumerated acceptance criteria.
- **Builder-evaluator:** Evaluator that also fixes what it finds. Evaluate and report — don't fix.
- **Amnesia:** Evaluator that doesn't track whether previous recommendations were adopted. Include cycle-aware checks.

### Investigator
- **Shotgun debugging:** Multiple unrelated changes at once. One hypothesis, one change, one verification.
- **Log vacuum:** Reading every log file instead of forming a hypothesis first. Hypothesis-driven investigation.
- **Symptom fix:** Wrapping errors in try/catch instead of finding root cause. Fix causes, not symptoms.

---

## YAML Generation Pitfalls

These are common mistakes when an LLM generates Goose recipe YAML:

| Pitfall | Example | Fix |
|---------|---------|-----|
| Invalid input_type | `input_type: text` | Use `string`, not `text` |
| Invalid input_type | `input_type: select` | Use `string` with description listing valid values |
| Missing default on optional | `requirement: optional` with no default | Add `default: ""` |
| Default on file param | `input_type: file` with `default: ""` | Remove default — file params can't have defaults |
| Conditional templates | `{{ if has_tests }}...{{ endif }}` | Not supported. Use parameter defaults and handle in instructions |
| Folded block scalar | `description: >` | Use `|` (literal) not `>` (folded) for multi-line |
| Unquoted special chars | `title: Bug Fix: AI Edition` | Quote: `title: "Bug Fix: AI Edition"` |
| Null default | `default:` (no value) | Use `default: ""` (quoted empty string) |
| Boolean trap | `default: yes` | Quote it: `default: "yes"` (YAML interprets bare yes as boolean) |
| Invented extensions | `name: code-analysis` | Use real names: `developer`, `analyze`, `summon`, `todo`, `memory` |
