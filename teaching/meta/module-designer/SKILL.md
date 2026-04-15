---
name: rilgoose-module-designer
description: Design RILGoose teaching modules — agent primitives + training recipes + quality-rated eval. Use this skill whenever designing, writing, or reviewing any Stage 0-7 module, recipe, teaching script, eval prompt, or facilitator instruction. Also use when someone asks to "build a module," "create a recipe," "write a teaching script," or "design Stage N content." Load it proactively at the start of any session focused on module creation.
---

# RILGoose Module Designer

This skill encodes everything needed to design complete teaching modules for the RILGoose system — an 8-stage progressive AI development training program for Reliance teams.

## When to Use

- Designing a new agent primitive YAML for any stage
- Writing a training recipe (facilitator + sub-recipe call + eval subagent prompt)
- Creating or reviewing quality dimensions for any concept
- Building the progression state tracking for a module
- Reviewing an existing module for consistency with the framework

## When NOT to Use

- General Goose recipe development unrelated to RILGoose teaching
- Editing the syllabus itself (that's a design task, not a module build task)
- Rollout planning or metrics (see `ideas/rollout-playbook.md`)
- Modifying the Goose runtime or Rust core

## Required Context

Before designing any module, read these files:
1. `ideas/syllabus.md` — Source of truth for concepts, quality dimensions, and design decisions
2. This skill file — The patterns and rules for how modules work
3. `references/goose-recipe-format.md` — Goose YAML template and rules
4. `references/eval-prompt-template.md` — Eval subagent prompt format
5. `references/example-module.md` — Complete Bug Fix module as reference implementation

---

## Core Architecture: Three Recipe Types

Design the agent primitive FIRST. Teaching wraps around it — never the other way around.

### 1. Agent Primitive (`recipes/agents/recipe-name.yaml`)

The non-interactive worker. Receives parameters, does the work, returns structured results. No teaching, no eval, no conversation. This must be genuinely useful as a standalone tool — if a developer wouldn't reuse it after training, the recipe is wrong. For single-agent modules (Stage 1, most of Stage 4-7), the agent primitive IS the graduated version — it replaces the training recipe when the developer completes training.

### 2. Training Recipe (`recipes/shared/NN-recipe-name.yaml`)

The interactive facilitator visible in the Goose app. Calls the agent primitive via `sub_recipes:`, runs eval, coaches the developer. Title ends with "(Training)". Has 6 behavioral rules in `instructions:` and the full teaching flow in `prompt:`. References the teaching script at `teaching/stage-N/recipe-name.teach.md`.

### 3. Graduated Recipe (`recipes/graduated/recipe-name.yaml`) — multi-agent only

For modules with multiple agents (build-then-test, three-agent-pipeline, parallel-reviewers), the graduated recipe is a coordinator that composes agent primitives via `sub_recipes:`. It's genuinely different from any single primitive. Single-agent modules don't need this — the primitive IS the graduated version.

**Why this separation matters:** The agent primitive is the product. The training recipe is onboarding. The graduated recipe is the daily-use coordinator. If you can't cleanly separate them, the agent primitive isn't well-designed.

### How They Connect at Runtime

```
First run:  training recipe (shared/) → reads teaching script → calls agent primitive (agents/)
                                                               → spawns eval subagent (async)
                                                               → facilitator coaches based on eval

Graduation: graduate-module agent copies working version → replaces training in shared/
            Single-agent: copies agents/primitive.yaml → shared/NN-name.yaml
            Multi-agent:  copies graduated/coordinator.yaml → shared/NN-name.yaml

After:      shared/NN-name.yaml → runs directly, no teaching, no eval
```

---

## The Three Agent Roles

Every teaching session has exactly three agent roles. Understanding why each exists prevents you from conflating their responsibilities.

### Facilitator (main agent)
Guides the conversation. Never touches code. Receives eval results and decides what to say. Speaks as a knowledgeable colleague — not an instructor, not an AI, not a system following rules. The developer should feel like they're pair-programming with someone experienced, not sitting through a training module.

### Agent Primitive (sub-recipe)
Does all code operations as a non-interactive sub-recipe. Reading files, running tests, making edits, generating diffs. Returns structured results to the facilitator. References ported agent patterns from `recipes/ported-agents/` in its instructions. Lives in `recipes/agents/`.

### Eval Subagent
Runs async after the developer completes the task. Sees the full conversation transcript. Rates quality dimensions as Strong/Adequate/Weak with evidence and suggested coaching language. Returns structured JSON. The facilitator reads this and decides what to say — it never follows eval results blindly.

**Why eval is async and batch:** Real-time eval would add latency to every interaction and make the conversation feel sluggish. Batch eval after task completion lets the facilitator debrief naturally. The eval subagent has the full transcript, so it can assess the entire interaction holistically.

---

## Teaching Modes

The mode determines how much structure the facilitator provides. It's set per stage, not per module.

| Mode | Stages | Facilitator Role | Eval Approach |
|------|--------|-----------------|---------------|
| **Scripted** | 0 | Follows Say/Check/Action script | No eval subagent — concepts are mental model shifts |
| **Guided-Adaptive** | 1 | Sets up the task, lets developer do it, coaches after | Eval rates quality dimensions after each recipe |
| **Adaptive + Checkpoints** | 2-4 | Lighter touch — frames the work, checks in at defined points | Eval tracks across multiple concepts, facilitator reviews at checkpoints |
| **Fully Adaptive** | 5-7 | Consulting role — available when needed, not driving | Eval runs on broader capability demonstration |

**The key insight:** As the developer's mental models develop, the facilitator steps back. Stage 0 is a guided tour. Stage 7 is occasional consulting. The eval subagent is what enables this — it watches so the facilitator doesn't have to hover.

---

## Quality Dimensions: The Heart of Adaptive Teaching

The eval subagent doesn't check "did they do it" — in a guided recipe, they always do it. It evaluates **how well** they did it.

### What Makes a Good Quality Dimension

1. **Observable from the transcript.** The eval sees the conversation. It can tell what the developer said, asked, or did. It cannot read minds or see what the developer did outside the conversation.

2. **Ratable on a spectrum.** Strong/Adequate/Weak must be meaningfully different. If it's truly binary (they did or didn't), it's a gate, not a quality dimension. The interesting teaching happens in the space between adequate and strong.

3. **Coachable in 1-2 sentences.** If the facilitator needs a paragraph to explain the gap, the dimension is too broad. Split it.

4. **Connected to real impact.** The developer should intuitively understand why this matters — not "because the system says so" but "because it makes AI 3x faster at finding the fix."

### Writing Coaching Language

The coaching language is what the facilitator actually says. It's the most important part of the module because it's what the developer hears.

- **Strong:** Praise the specific behavior, not the person. "You gave it the symptom, what you ruled out, and a theory" — not "Good job" or "Well done."
- **Adequate:** One actionable suggestion with the why. "Next time also mention what you already tried — it prevents the AI from retracing your steps."
- **Weak:** Show the contrast. "Compare what you said to: [better version]. The second version gets a fix in one pass." Never condescend. Never say "you should have."
- **Always invisible:** Never mention eval, ratings, scores, or system architecture. The developer hears coaching, not verdicts.

See `references/example-module.md` for the complete Bug Fix quality dimension table.

---

## Pedagogical Rules (from CourseForge, adapted for adaptive teaching)

These rules apply to every module regardless of stage or mode.

1. **Never break the fourth wall.** The facilitator is a colleague, not an AI executing instructions. Never mention scripts, evals, quality ratings, or the teaching system. The developer should feel like they're getting help, not being assessed.

2. **Lead with value, not warnings.** "AI just found your bug in 2 minutes" not "AI makes mistakes you need to catch." The practice ("verify the fix is real") comes after the value is demonstrated. This is because our audience is skeptics who need to see power before they'll invest in practices.

3. **Bridge to what's next.** End every recipe/stage with 1-2 sentences connecting the current accomplishment to the next capability. "You've been reviewing everything yourself. What if a second AI did that?"

4. **Few turns per dimension.** 1-3 interactions to coach a quality dimension. If it takes more, the dimension is too broad or the coaching language needs work.

5. **One skill per recipe.** Each recipe teaches one core concept. Quality dimensions are facets of that concept. If a recipe seems to teach two things, split it.

6. **Domain simplicity.** The "aha" is the tool capability, not the code complexity. Pick an ugly simple function for a refactoring demo, not a complex algorithm.

7. **Watch then do (Stages 0-1).** Demonstrate first (agent primitive does it while developer watches), then the developer tries. In later stages, the developer leads.

8. **Real code, real work.** Stage 0 excepted — everything else uses the developer's actual codebase. No toy projects, no synthetic exercises. The developer should be solving a real problem.

9. **Always offer an escape hatch on user picks.** Every time the facilitator asks the developer to pick/bring/name/describe something, ALSO offer to pick it for them. Adapt to context: "or want me to pick one?" / "or want me to find a bug in your codebase?" / "or want me to draft personas from the spec?" The next step must be SUPER EASY. A developer who doesn't know what to pick must not be stuck.

10. **Interpret user engagement broadly.** When the facilitator asks "pick a file and ask a question," a developer who asks about a concept, design decision, pattern, or architecture piece IS engaging — not deflecting. Do not redirect them back to "pick a file." Subagent specs that reference `{user_specified_file}` should instead be framed to answer whatever the developer actually asked about, reading any files needed to answer well. The only reason to re-ask is silence or clearly off-topic response.

11. **End every bridge with a question.** Every Step/Section that bridges to a next act, module, or phase must end with a clear CTA question — "Ready?" / "Want to keep going?" / "Ready to do it for real?" / "Shall we move on?" — followed by a `Check: Wait for confirmation` line. Statements trail off; questions create handoffs. Users should never be left wondering whether the facilitator is done talking or expecting them to act. Adapt the question to context (same-session continuation vs next-module vs end-of-stage), but always end with one.

---

## Progression State

Goose has no built-in progression tracking, so every module reads/writes a state file. See `references/progression-format.md` for the JSON schema. Key rules:

- A concept is **complete** when all required dimensions are Adequate or Strong
- A stage is **complete** when all concepts are complete
- Conditional dimensions (like "redirect on struggle" — only triggered if AI struggles) don't block completion
- The facilitator reads state at session start to skip already-demonstrated concepts
- The training recipe writes state after eval completes, then calls graduate-module

---

## Module Quality Scorecard

After designing a module, score it against these 10 criteria. All must score ≥6/10, total ≥70/100.

| # | Criterion | Question to Ask |
|---|-----------|----------------|
| 1 | Few turns | Can each quality dimension be coached in 1-3 interactions? |
| 2 | Clear I/O | Does the developer know what they're producing before starting? |
| 3 | Verifiable success | Does each dimension have objective evidence from the transcript? |
| 4 | One skill | Does the recipe teach exactly one core concept? |
| 5 | Watch then do | In Stages 0-1, does the demo come before the developer's attempt? |
| 6 | Minimal domain | Does the task avoid requiring domain expertise unrelated to the concept? |
| 7 | Tool is the aha | Is the impressive part the AI capability, not the code complexity? |
| 8 | Real code | Does it use the developer's actual codebase? (Stage 0 excepted) |
| 9 | Relatable task | Is this something the developer does (or should do) regularly? |
| 10 | Reusable recipe | Would the developer use this agent primitive in daily work after training? |

---

## Reference Files

These contain templates and detailed examples. Read the specific one you need, not all of them.

| File | When to Read | Contents |
|------|-------------|----------|
| `references/goose-recipe-format.md` | Writing an agent primitive YAML | Goose YAML template with all fields, parameter types, extension scoping |
| `references/eval-prompt-template.md` | Writing an eval subagent prompt | Complete template with structured JSON output format |
| `references/example-module.md` | First time designing a module, or reviewing your design against a known-good example | Complete Bug Fix module: agent primitive + training recipe + teaching script + eval prompt |
| `references/progression-format.md` | Implementing state tracking | JSON schema for progression.json with examples |
| `references/ported-agents-map.md` | Choosing which ported agents to reference | Stage-to-agent mapping table (ports live in `recipes/ported-agents/`) |

### Additional References (GooseForge)

| File | When to Read | Contents |
|------|-------------|----------|
| `recipes/forge-references/canonical-recipe-structure.md` | Designing agent primitives | 10-section template + YAML generation rules |
| `recipes/forge-references/validation-checklist.md` | Validating any recipe | 37-item checklist + 6 quality detectors |
| `recipes/forge-references/archetype-*.md` | Choosing patterns for an agent | 5 archetype references (reviewer, builder, coordinator, evaluator, investigator) |
