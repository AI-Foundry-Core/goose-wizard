# Recipe 4.2: Spec Decomposition — "Real people, not abstract features"

Covers concept 4.2 (spec-decomposition). Teaches persona-driven decomposition and testable requirements.

Mode: Adaptive + Checkpoints

> **Path resolution note.** All paths, spec reads, and artifact writes in
> this script act on the TARGET codebase (the developer's project). The
> parent recipe injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md`, "the codebase," "the repo," or "your spec,"
> interpret those against `<TARGET>/`. The `spec_path` passed to any
> sub-recipe must be an absolute path under `<TARGET>/`. Prepend the
> TARGET PROLOGUE to every `Delegate to subagent` call. Pass
> `target_codebase_path` to the `spec-decomposition` and `spec-to-pipeline`
> sub-recipes.

---

## Setup

Read `<TARGET>/.goose/team_context.md` for project context.
Read ~/.rilgoose/progression.json — check if concepts 4.3 and 4.4 are already demonstrated.
If both already demonstrated (all dimensions adequate+): offer to skip or revisit.
If 4.3 demonstrated but not 4.4: skip to the testability phase.

Prerequisite: The developer should have a spec from Recipe 4.1/4.2 (the idea-to-spec output). If they don't have one, either run idea-to-spec first or use an existing spec from their project.

---

## Framing

"You've got a spec with requirements. Now the question is: how do you organize those requirements so an AI team can actually build from them? Let's take your spec and restructure it. First — who are the real people who'll use this feature?"

---

## Phase 1: Persona Decomposition (Concept 4.3)

Ask the developer to identify their personas BEFORE invoking the recipe:

"Give me 2-3 real people who would use this feature. Not 'the user' or 'admin' — give me a name, what they do, and what their day looks like. Priya the working mother in Pune checking her portfolio on the train. Raj the warehouse supervisor who can't leave the floor to file a report. Real people. Or want me to draft 2-3 personas from the spec and let you refine them?"

Listen to the developer's personas. Note:
- Are they named real people or abstractions ("User Type A")?
- Do they have context (role, situation, pain points)?
- Are they meaningfully different from each other?

Resolve the spec path before delegating: if the developer already named a spec file, use it (resolve relative paths against `<TARGET>/`). Otherwise ask "Point me at your spec, or want me to use the latest Stage 4 output in your repo?" and scan `<TARGET>/` if they pick the latter. Do not block on missing spec_path — produce a candidate under `<TARGET>/` and confirm. Every spec_path must be an absolute path under `<TARGET>/`.

Then delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "spec-decomposition"
  parameters:
    spec_path: {absolute path under <TARGET>/ to their spec from 4.1/4.2, or the resolved candidate}
    personas: {developer's persona descriptions}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent produces persona-organized decomposition with use cases and acceptance criteria]

Facilitator presents the decomposition, highlighting the persona-first structure:

"See how the requirements look different when they're organized around [Persona 1 name] and [Persona 2 name]? When you organize by feature — 'login module,' 'dashboard,' 'reports' — you miss cross-cutting needs. [Persona name]'s workflow crosses three of those features. Persona-first catches those connections."

If the developer's personas were too abstract:
"You said '[their abstract persona].' Compare that to: '[the AI's enriched version with name, context, pain point].' The second version forces you to think about a real workflow. Abstract personas produce abstract requirements."

---

## Phase 2: Testable Requirements (Concept 4.4)

After reviewing the decomposition, draw attention to the acceptance criteria:

"Look at the acceptance criteria the decomposition produced. Every one of them follows a pattern: Given [context], When [action], Then [measurable outcome]. That pattern matters because an AI can turn each one directly into a test."

Ask the developer to evaluate a few:
"Pick three acceptance criteria from the decomposition. For each one: could an AI write an automated test from this? If not, what's missing?"

Let the developer assess. If they identify untestable criteria correctly — acknowledge it. If they miss untestable ones, point them out:

"This one — [quote the criterion] — says 'the experience should feel seamless.' What does a test for 'seamless' look like? Compare it to: 'the user completes the workflow in under 3 clicks with no error messages.' Now I can write a test."

If the developer has their own spec with vague requirements:
"Let's rewrite three of your vaguest requirements right now. Give me one that uses words like 'easy,' 'fast,' 'intuitive,' or 'user-friendly,' and let's make it testable."

Delegate to code-work subagent (if rewriting requirements — prepend the TARGET PROLOGUE):
  sub-recipe: "spec-to-pipeline"
  parameters:
    spec_path: {absolute path under <TARGET>/ to decomposed spec}
    test_framework: {from <TARGET>/.goose/team_context.md or developer's preference}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent converts acceptance criteria to test specs under <TARGET>/]

"Every requirement now traces to a test. If a requirement doesn't have a test, either the requirement is untestable — rewrite it — or a test is missing — add it. This traceability is what makes an AI pipeline reliable. No test means no verification means no trust."

---

## Eval

Delegate to eval subagent (async: true):

```
You are evaluating how well a developer approached decomposing a spec into persona-driven, testable requirements.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript (quote or paraphrase what the developer said/did)
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. PERSONA GROUNDING (Concept 4.3)
   Strong: Developer created personas with real names, specific roles, concrete situations, and distinct pain points. Each persona represented a meaningfully different type of user with different needs.
   Adequate: Developer created named personas but they lacked depth — missing pain points, vague roles, or personas that were too similar to each other. Needed some prompting to add specifics.
   Weak: Developer used abstractions ("the user," "admin," "Type A user") or created personas that were essentially the same person with different names. Did not think in terms of real people.

2. PERSONA-FIRST ORGANIZATION (Concept 4.3)
   Strong: Developer organized or validated requirements around persona workflows rather than system features. Recognized that a single persona's workflow might cross multiple features/modules.
   Adequate: Developer understood the persona-first concept but defaulted to feature groupings when first organizing. Adjusted after prompting.
   Weak: Developer organized requirements by feature or system component and resisted reorganizing around personas, or didn't see the difference between the two approaches.

3. TESTABILITY ASSESSMENT (Concept 4.4)
   Strong: Developer correctly identified testable vs untestable acceptance criteria. Rewrote vague criteria into measurable ones without prompting. Understood that "an AI could write a test for this" is the bar.
   Adequate: Developer could identify obviously untestable criteria ("should be user-friendly") but missed more subtle ones ("system should respond quickly"). Needed guidance on rewriting.
   Weak: Developer couldn't distinguish testable from untestable criteria, or didn't attempt to evaluate them. Accepted vague criteria as sufficient.

4. REWRITE QUALITY (Concept 4.4)
   Strong: Developer's rewritten criteria had specific numbers, clear pass/fail conditions, and no subjective language. Each rewrite was tighter than the original and clearly automatable.
   Adequate: Developer's rewrites improved on the originals but still contained some vague language or lacked specific thresholds. Direction was right, precision was lacking.
   Weak: Developer's rewrites were still vague, or the developer didn't attempt rewrites. Treated testability as an abstract concept rather than a practical skill.

5. CROSS-CUTTING RECOGNITION (Concept 4.3 — conditional)
   Condition: Only rate this if the spec had requirements that spanned multiple personas or system boundaries.
   If condition not met: return rating=null, evidence="Not triggered — spec was single-persona", coaching=null
   Strong: Developer identified cross-cutting concerns (performance, security, accessibility) and ensured they had testable criteria covering all affected personas.
   Adequate: Developer recognized cross-cutting concerns when pointed out but didn't identify them independently.
   Weak: Developer missed cross-cutting concerns entirely or treated them as belonging to a single persona.

Return as JSON:
{
  "dimensions": [
    {"name": "persona_grounding", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "persona_first_organization", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "testability_assessment", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "rewrite_quality", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "cross_cutting_recognition", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

---

## Coaching

Read eval results. For each dimension:

### Persona Grounding (4.3)

| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Your personas were real people — [quote their best persona]. When you think about [persona name]'s day, you design for real workflows, not abstract use cases. That's what catches edge cases." |
| Adequate | "Your personas had names, but [persona name] was still pretty generic. What's their actual day like? What frustrates them? The more specific the persona, the more specific the requirements you derive from them." |
| Weak | "You said '[their abstract label].' That's a category, not a person. Compare it to: '[AI's enriched persona].' The second one forces you to think about a real workflow — when does she use this, where is she, what's competing for her attention? Abstract personas produce abstract requirements." |

### Persona-First Organization (4.3)

| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You organized around people, not features. That's why you caught [cross-cutting need] — it spans three features but it's one workflow for [persona name]. Feature-based organization would have missed that." |
| Adequate | "You started organizing by feature — 'login module,' 'dashboard' — which is natural, but it misses cross-cutting workflows. [Persona name]'s checkout flow touches authentication, inventory, and payment. Organize by her workflow and you see the full picture." |
| Weak | "Your requirements are grouped by system component. The problem: [persona name]'s workflow crosses four of those components. When each component team builds to their own requirements, nobody owns the end-to-end experience. Reorganize around persona workflows and the gaps become obvious." |

### Testability Assessment (4.4)

| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You correctly flagged [quote the untestable criterion] and knew it needed a rewrite. That instinct — 'can an AI write a test for this?' — is the filter for every requirement you write." |
| Adequate | "You caught the obvious ones like 'user-friendly,' but missed [quote the subtle untestable criterion]. 'System should respond quickly' sounds specific but it's not — quickly compared to what? Under what load? The test is: 'P95 response time under 200ms with 1000 concurrent users.'" |
| Weak | "If an AI can't write a test for a requirement, the requirement isn't specific enough. 'The interface should be intuitive' — how do you test that? '95% of first-time users complete the task without help documentation' — now I can write a test. Every requirement needs this treatment." |

### Rewrite Quality (4.4)

| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Your rewrites were tight — [quote their best rewrite]. Specific numbers, clear pass/fail, no wiggle room. That's a requirement an AI pipeline can execute against." |
| Adequate | "Your rewrites improved on the originals, but [quote the still-vague part] still has room for interpretation. Push every rewrite until it has a specific number and a clear pass/fail condition." |
| Weak | "Your rewrite — [quote it] — is still vague enough that two developers would interpret it differently. The test for a good requirement: if two different AI agents read it, do they build the same thing? If not, it's not specific enough." |

### Cross-Cutting Recognition (4.3 — conditional)

| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You identified [cross-cutting concern] and made sure it covered all affected personas. That's the advantage of persona-first organization — cross-cutting concerns become visible." |
| Adequate | "Performance requirements like [example] affect [Persona 1] and [Persona 2] differently. You saw it when I pointed it out — next time, scan for requirements that span multiple persona workflows. Those are usually the ones that fall through the cracks." |
| Weak | "Security, performance, and accessibility aren't features — they're cross-cutting concerns that touch every persona. Your spec treated them as belonging to one persona. Audit every non-functional requirement: does it affect multiple personas? If so, each persona needs their own acceptance criteria for it." |

---

## Bridge to Spec Review

"You've got a spec that's organized around real people with testable requirements. But how do you know it's actually good? Your own judgment is necessary but not sufficient — you'll miss things because you wrote it. That's where AI-assisted quality gates come in. Let's run your spec through a multi-dimension review and see what it catches. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

---

## State Update

Write to ~/.rilgoose/progression.json:
  Update concept 4.2 (module 13: spec-decomposition) with all dimension ratings
  (persona_grounding, persona_first_organization, cross_cutting_recognition,
  testability_assessment, rewrite_quality) as sub-fields of concept 4.2's eval_ratings,
  plus timestamp.
  Update concept 4.2 status to "complete" when all required dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
