# Recipe 4.1: Idea to Spec — "From napkin to blueprint"

Covers concept 4.1 (idea-to-spec). Teaches concrete specs and progressive elaboration.

Mode: Adaptive + Checkpoints
Checkpoint after 4.2: Has the developer internalized progressive elaboration?

> **Path resolution note.** All paths and artifact writes in this script
> act on the TARGET codebase (the developer's project). The parent recipe
> injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md`, "the codebase," "the repo," or "the spec
> file," interpret those against `<TARGET>/`. Spec artifacts belong under
> `<TARGET>/specs/` (or the project's existing spec directory), never in
> goose-wizard. Prepend the TARGET PROLOGUE to every `Delegate to subagent`
> call. Pass `target_codebase_path` to the `idea-to-spec` sub-recipe.

---

## Setup

Read `<TARGET>/.goose/team_context.md` for project context.
Read ~/goose-wizard/progression.json — check if concepts 4.1 and 4.2 are already demonstrated.
If both already demonstrated (all dimensions adequate+): offer to skip or revisit.
If 4.1 demonstrated but not 4.2: skip to the elaboration phase.

---

## Framing

"Every pipeline needs input, and the quality of that input determines everything downstream. Got a feature idea you've been kicking around? Tell me about it — even a single sentence is fine. Or want me to pick something promising out of your TODOs or feature-shaped gaps?"

If developer has no current feature idea:
  "No problem. Let me look at your codebase for opportunities."
  Delegate to code-work subagent (prepend the TARGET PROLOGUE):
    "Read <TARGET>/.goose/team_context.md. Scan <TARGET>/ for TODOs,
    feature requests in comments, or obvious gaps in the codebase that
    represent a real feature opportunity. Describe it as a feature idea
    the developer would recognize — one paragraph max. Reference
    absolute paths under <TARGET>/."

---

## Phase 1: The One-Pager (Concept 4.1 — Vague specs produce vague output)

Developer describes their feature idea.

Facilitator takes the developer's raw idea and asks them to refine it into a one-pager BEFORE delegating to the recipe. This is the teaching moment — the developer needs to be the one making vague things concrete.

"Before we hand this to AI, let's sharpen it. I need you to answer six questions — just a sentence or two each:
1. Who has this problem? Give me a real person, not 'the user.'
2. What's the problem they're hitting today?
3. What does the solution look like in one sentence?
4. How would you know it worked? Give me a number.
5. What would make you kill this project?
6. What's the biggest risk?"

Listen to the developer's answers. Note which ones are vague (adjectives instead of numbers, "the user" instead of a named persona, missing kill criteria, success criteria that aren't measurable).

Then delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "idea-to-spec"
  parameters:
    feature_idea: {developer's refined idea with their answers}
    target_audience: {from developer's persona answer}
    context: {any context the developer provided}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent produces the one-pager — written under <TARGET>/specs/ or equivalent]

Facilitator presents the one-pager, then draws attention to the difference between the developer's original idea and the structured output:

"Look at what just happened. You started with [paraphrase their original vague idea]. Now you have a one-pager with named personas, measurable success criteria, and kill conditions. This is the difference between 'build me something' and 'build me this specific thing.' The spec is the prompt for your pipeline — vague in, vague out."

---

## Phase 2: Progressive Elaboration (Concept 4.2 — One-pager before requirements)

If the one-pager reveals the idea is weak:
"The one-pager just did its job — it exposed that [specific weakness]. This is why we start here. You just killed a bad idea in 10 minutes instead of discovering it 3 months into development. That's progressive elaboration."

If the one-pager is solid, proceed to elaboration:
"This one-pager holds up. Now the question is: does this need a full requirements document, or is the one-pager enough to start building? What would you need to know before handing this to a development team?"

Let the developer decide. If they want to elaborate:

**Before delegating:** The developer must own the concrete choices. For each open question the developer surfaced (filtering approach, error format, pagination style, auth mechanism, etc.), ask the developer to decide before passing to the subagent. Do not embed design decisions in the code-operation prompt that the developer has not explicitly chosen. Example prompts:
- "You said filtering is needed — what fields does [persona] actually filter on?"
- "You mentioned pagination — for a simple dashboard, which style fits: page numbers or a cursor?"
- "Error format — what fields does the frontend need in every error response?"

If the developer genuinely does not know (not avoidance, but real knowledge gap), mark the choice as provisional in the subagent prompt and flag it as an open design decision in the spec.

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "idea-to-spec"
  parameters:
    feature_idea: {one-pager content, with developer's concrete choices, elaborated into full requirements}
    target_audience: {personas from one-pager}
    context: {one-pager content as context, with any provisional choices flagged}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent produces full requirements document — written under <TARGET>/specs/ or equivalent]

If the developer tries to jump to detailed requirements without the one-pager:
"Hold on — before we go deep, let's make sure the idea survives a one-page summary. If you can't make the case in one page, more detail won't fix it. Start with the one-pager."

---

## Auth-Model Coaching Note

When the developer's spec involves cross-origin API access (e.g., a React dashboard consuming a Flask API), CORS coaching alone is insufficient. After addressing CORS headers/origins, probe the deeper auth-model question:

"CORS solves the browser-origin part. Separate question: does session-cookie auth work for [persona]'s client in your deployment? If the client isn't on the same cookie domain, session cookies won't arrive. That's a design decision — session-based with shared domain, or token-based auth for API clients. Worth capturing in the spec as an open question for review rather than assuming session cookies will work."

Do not resolve this for the developer — surface it as an open design decision they need to flag in the spec.

---

## Wait-Time Insights

Share one insight per subagent wait, in order. Adapt to what just happened in conversation.

1. `[specificity]` — "The difference between a spec that works and one that doesn't usually isn't length. It's precision. 'Should be fast' gives the AI nothing. 'P95 under 200ms' gives it a test to write."
2. `[specificity]` — "The questions you're asking now are the questions that would have come up three days into implementation. Cheaper to answer them in a document than in a debugging session."
3. `[verify]` — "Every requirement in the spec should be something a machine can verify. If you can't write a test for it, the requirement is still too vague."
4. `[progressive-elaboration]` — "A one-pager that kills a bad idea in 10 minutes is more valuable than a 25-page requirements doc that takes a week to write for the same bad idea."
5. `[enterprise]` — "This is what your team lead can review quickly: persona, measurable success, kill gates. In a bigger team, that turns a vague ask into a concrete design-review conversation."
6. `[define-success]` — "Kill criteria aren't pessimism — they're scope protection. Knowing when to stop is what keeps a 3-day feature from becoming a 3-month project."

---

## Eval

Delegate to eval subagent (async: true):

```
You are evaluating how well a developer approached turning a feature idea into a spec.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript (quote or paraphrase what the developer said/did)
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. SPEC CONCRETENESS (Concept 4.1)
   Strong: Developer's spec input contained concrete details — specific numbers for success criteria, named personas with real context, measurable thresholds, no placeholder language like "should be fast" or "TBD."
   Adequate: Developer provided some concrete details but fell back on vague language in places — adjectives instead of numbers, "the user" instead of a named persona, or success criteria that aren't measurable.
   Weak: Developer's input was mostly vague — "it should be good," "users will like it," no numbers, no named personas, no measurable outcomes. The AI had to invent all the specifics.

2. SPEC COMPLETENESS (Concept 4.1)
   Strong: Developer addressed all six one-pager elements without prompting — problem, persona, solution, success criteria, kill criteria, and risk. Nothing material was missing.
   Adequate: Developer covered most elements but missed one or two — typically kill criteria or risk. Needed prompting to fill gaps.
   Weak: Developer provided a feature description but left out most of the one-pager structure. The AI had to generate the entire framework.

3. PROGRESSIVE DISCIPLINE (Concept 4.2)
   Strong: Developer started with the constrained one-pager format and only elaborated after validating it. Did not try to write a 25-page doc first. Made a deliberate decision about whether elaboration was warranted.
   Adequate: Developer followed the one-pager-first flow but showed impatience — wanted to jump to details or asked "can we skip to the full requirements?" before completing the one-pager.
   Weak: Developer tried to skip the one-pager entirely and go straight to detailed requirements, or treated the one-pager as a formality rather than a kill gate.

4. KILL GATE RECOGNITION (Concept 4.2 — conditional)
   Condition: Only rate this if the one-pager revealed a weakness in the idea (vague value prop, unclear problem, no differentiation).
   If condition not met: return rating=null, evidence="Not triggered — one-pager was solid", coaching=null
   Strong: Developer recognized the weakness and adjusted — refined the idea, narrowed scope, or decided to pivot before elaborating.
   Adequate: Developer acknowledged the weakness when pointed out but needed facilitator guidance to decide what to do about it.
   Weak: Developer ignored the weakness and pushed to elaborate anyway, or didn't see the one-pager as a validation tool.

Return as JSON:
{
  "dimensions": [
    {"name": "spec_concreteness", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "spec_completeness", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "progressive_discipline", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "kill_gate_recognition", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

---

## Coaching

Read eval results. For each dimension:

### Spec Concreteness (4.1)

| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Your spec had real numbers — [quote their specific metric]. That's a spec an AI team can build from. 'P95 latency under 200ms' is a requirement. 'Should be fast' is a wish." |
| Adequate | "You had some good specifics, but [quote the vague part] is still fuzzy. What number would make that concrete? The spec is the prompt for your entire pipeline — every vague line produces vague output downstream." |
| Weak | "Compare what you said — [quote their vague input] — to what the spec produced: [quote the AI's concrete version]. See the difference? The AI guessed all those numbers. If those guesses are wrong, everything built from this spec is wrong. You need to own the specifics." |

### Spec Completeness (4.1)

| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You covered all the bases — problem, persona, solution, success, kill criteria, risk. That's a complete one-pager. Nothing for the AI to guess at." |
| Adequate | "You missed [the missing element]. That's one of the most common gaps — [explain why that element matters]. Next time, use all six questions as a checklist before handing off." |
| Weak | "The AI had to invent your personas, your success criteria, and your kill conditions. That means the spec reflects the AI's assumptions, not your knowledge. The six questions — who, what problem, what solution, how to measure, when to kill, biggest risk — take 5 minutes and save weeks." |

### Progressive Discipline (4.2)

| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You started small and only expanded when the one-pager earned it. That discipline — start constrained, elaborate only if warranted — kills bad ideas cheaply." |
| Adequate | "I noticed you wanted to jump ahead to the full requirements. The one-pager is a kill gate, not a formality. If the idea can't survive one page, more detail won't save it." |
| Weak | "You tried to skip straight to detailed requirements. Here's why that's expensive: a 25-page requirements doc for a bad idea wastes a week. A one-pager that exposes the same flaw takes 10 minutes. Start small. Elaborate only if the one-pager holds up." |

### Kill Gate Recognition (4.2 — conditional)

| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You caught the weakness in the one-pager and adjusted before going deeper. That's exactly the instinct — the one-pager exists to expose problems early." |
| Adequate | "The one-pager showed [the weakness], and you saw it once I pointed it out. Next time, read the one-pager as a critic before deciding to elaborate. Ask: does this actually hold up?" |
| Weak | "The one-pager revealed [the weakness], but you pushed to elaborate anyway. That's how zombie projects start — you see the warning signs but keep building because you've already invested time. The one-pager is permission to stop." |

---

## Checkpoint After 4.2

If ALL 4.1 and 4.2 dimensions are Adequate or Strong:
"You can take a vague idea and turn it into something concrete and structured — and you know when to stop elaborating. That's the foundation. Next up: how you organize those requirements changes everything about whether an AI team can execute on them."

If any dimension is Weak:
Coach on the weak dimensions (using coaching language above), then offer:
"Want to try another feature idea and see if the one-pager process clicks? Sometimes it takes two rounds to feel natural."

---

## Recipe Reveal
After coaching, show the developer the recipe behind this session.

"Twelfth recipe — and this one is the first of the Stage 4 spec chain. The earlier
Stage 1-3 recipes did work on code you already had. This one produces a spec from
nothing but an idea."

Read the Idea to Spec recipe (recipes/agents/idea-to-spec.yaml) and show the developer:
- The **hard constraint against skipping the one-pager** — "Look at Constraints:
  'NEVER skip the one-pager — it's a kill gate for bad ideas.' 'Do NOT jump straight to
  detailed requirements without the one-pager.' That progressive-discipline behavior you
  were rated on? It's literally a rule the agent won't break. The one-pager isn't
  suggested — it's enforced."
- The **Process ordering that locks in the kill gate** — "Process: step 2 produces a
  one-pager. Step 3 PRESENTS it and asks whether to elaborate. Only step 4 — conditional
  on a 'yes' — produces the full requirements doc. That's the kill gate sequenced in
  numbered steps. The developer has to choose to elaborate; it's never automatic."
- The **six required one-pager elements** — "Step 2 names them: problem statement,
  proposed solution, target personas, success criteria (measurable), kill criteria, key
  risks, scope boundaries. Those are the exact six questions you answered in Phase 1.
  'Measurable' is in parentheses because the next constraint is 'NEVER use subjective
  success criteria (\"easy to use\", \"fast\").'"
- The **spec-writing target path convention** — "Notice the `target_codebase_path`
  parameter and the working-directory block: 'Write all spec artifacts under
  {target_codebase_path}/specs/.' The spec lands in the developer's project, not
  goose-wizard. Artifacts live where the build agents will look for them — that's why the
  later recipes in the chain take `spec_path` as input and know where to find it."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open recipes/agents/idea-to-spec.yaml`
"Stage 4 is a chain — this recipe writes the spec, the next three decompose, review,
and convert it. Watch how each one takes the previous artifact as input."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/idea-to-spec.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

---

## Bridge to Spec Decomposition

"You've got a solid spec. But right now it's organized around features — what the system does. The problem is, features miss cross-cutting needs. When you organize by persona — real people with real workflows — you catch edge cases that feature lists miss. That's Recipe 4.3. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

---

## State Update

Write to ~/goose-wizard/progression.json:
  Update concept 4.1 (module 12: idea-to-spec) with all dimension ratings
  (spec_concreteness, spec_completeness, progressive_discipline, kill_gate_recognition)
  as sub-fields of concept 4.1's eval_ratings, plus timestamp.
  Update concept 4.1 status to "complete" when all required dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
