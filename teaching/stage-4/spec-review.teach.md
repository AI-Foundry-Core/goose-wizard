# Recipe 4.3: Spec Review - "Quality gates and kill criteria"

Covers concept 4.3 (spec-review). Teaches AI-assisted quality gates and kill criteria.

Mode: Adaptive + Checkpoints
Checkpoint after 4.5: Has the developer gone through a quality gate cycle and revised the spec?

> **Path resolution note.** All paths, spec reads, and any revision
> writes in this script act on the TARGET codebase (the developer's
> project). The parent recipe injected a TARGET PROLOGUE — whenever this
> script says `.goose/team_context.md`, "the codebase," "the repo," or
> "the spec," interpret those against `<TARGET>/`. The `spec_path` passed
> to `spec-review` must be an absolute path under `<TARGET>/`. Any
> revision the developer chooses to apply lands under `<TARGET>/`, never
> goose-wizard. Prepend the TARGET PROLOGUE to every `Delegate to subagent`
> call. Pass `target_codebase_path` to the `spec-review` sub-recipe.

---

## Setup

Read `<TARGET>/.goose/team_context.md` for project context.
Read ~/.rilgoose/progression.json and check if concepts 4.5 and 4.6 are already demonstrated.
If both are already demonstrated with all dimensions adequate or strong, offer to skip or revisit.
If 4.5 is demonstrated but 4.6 is not, skip directly to the kill criteria pass.

Prerequisite: The developer should have a spec from Recipe 4.1 through 4.4. If they do not, use an existing project spec or run idea-to-spec first.

---

## Framing

"You have a spec that looks buildable. Now we run it through a quality gate before anyone builds from it. The point is not to get a pretty review report. The point is to find the expensive mistakes while they are still cheap to fix."

Ask the developer:
"What kind of spec are we reviewing - one-pager, requirements doc, or decomposed spec? Point me at it, or let me find the most recent spec artifact in the project."

---

## Phase 1: Quality Gate Review (Concept 4.5)

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "spec-review"
  parameters:
    spec_path: {absolute path under <TARGET>/ to the developer's spec}
    spec_type: {one-pager | requirements-doc | decomposed-spec}
    review_focus: "build readiness, ambiguity, testability, persona grounding, and kill criteria"
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent reviews the spec (read-only) and returns dimension ratings, blocking issues, improvement suggestions, overall readiness, and next action]

Present the review naturally:
"The review found [number] blockers and [number] warnings. The most important one is [top finding]. If we build now, this is likely to turn into [specific rework or failure mode]."

Ask the developer to triage:
"Which finding do you want to fix first, and why?"

If the developer picks a low-impact wording issue while blockers remain:
"Let's start with the issue that would waste build time. Wording can wait. Ambiguous acceptance criteria, missing persona coverage, or no kill criteria will break the pipeline."

Then revise the spec:
Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  "Revise the spec at <absolute path under <TARGET>/> to address the selected finding only. Preserve the rest of the document. Write the revision back to the same file under <TARGET>/. Return the before/after section and explain exactly how the finding is resolved."

Run the review again on the revised spec:
Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "spec-review"
  parameters:
    spec_path: {absolute path under <TARGET>/ to the revised spec}
    spec_type: {same spec type}
    review_focus: "confirm the selected finding is resolved and identify remaining blockers"
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

Facilitator says:
"That's the loop: review, fix one meaningful gap, review again. Fix the spec now - it is 100x cheaper than fixing a product built from a bad spec."

---

## Phase 2: Kill Criteria (Concept 4.6)

Look at the review's kill criteria finding.

If kill criteria are missing:
"What would make you kill this project? Not 'if people do not like it' - a threshold. For example: less than 2% conversion after month 3, support tickets above a set number after pilot, or no measurable reduction in manual handling time."

If kill criteria exist but are vague:
"This is pointed in the right direction, but it is not yet a kill criterion. Add the number, the time window, and the data source."

Ask the developer to draft or revise 1-3 kill criteria:
- metric
- threshold
- time window
- measurement source
- owner of the stop/continue decision

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  "Insert the revised kill criteria into the spec at <absolute path under <TARGET>/>. Write the update back to the same file under <TARGET>/. Keep criteria measurable, tied to the business goal, and visible in the decision section."

---

## Eval

Delegate to eval subagent (async: true):

```
You are evaluating how well a developer used AI-assisted spec review and kill criteria.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say - conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. REVIEW ITERATION (Concept 4.5)
   Strong: Developer ran the spec through a review, selected a meaningful finding, revised the spec, and re-ran the review or otherwise confirmed the issue was resolved.
   Adequate: Developer ran the review and acknowledged findings, but revised lightly or did not confirm that the revision resolved the issue.
   Weak: Developer treated the review as a report to accept or ignore, with no meaningful revision.

2. FINDING TRIAGE (Concept 4.5)
   Strong: Developer prioritized findings by build risk, ambiguity, testability, decision impact, or downstream cost.
   Adequate: Developer selected a reasonable finding to fix but did not explain why it mattered most.
   Weak: Developer focused on low-impact wording or formatting while leaving blockers unresolved.

3. REVIEW SKEPTICISM (Concept 4.5)
   Strong: Developer engaged with the review critically - accepted useful findings, challenged weak findings, and used evidence from the spec.
   Adequate: Developer generally trusted the review but asked at least one clarifying question or checked one finding.
   Weak: Developer accepted all review output at face value or dismissed it all without inspecting evidence.

4. KILL CRITERIA QUALITY (Concept 4.6)
   Strong: Developer defined kill criteria with metric, threshold, time window, measurement source, and decision owner.
   Adequate: Developer defined kill criteria with a measurable threshold but missed one supporting detail such as time window, data source, or owner.
   Weak: Developer omitted kill criteria or wrote subjective criteria such as "if users dislike it" without measurable thresholds.

5. STOPPING MINDSET (Concept 4.6)
   Strong: Developer treated kill criteria as a decision tool that prevents wasted build time and zombie projects.
   Adequate: Developer included kill criteria but framed them mostly as optional guardrails.
   Weak: Developer resisted kill criteria, treated them as pessimistic, or avoided defining what failure looks like.

Return as JSON:
{
  "dimensions": [
    {"name": "review_iteration", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "finding_triage", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "review_skepticism", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "kill_criteria_quality", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "stopping_mindset", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

---

## Coaching

Read eval results. For each dimension:

### Review Iteration (4.5)

| Rating | Facilitator Says |
|--------|------------------|
| Strong | "You used the review the right way: finding, revision, second check. That is how a spec gets stronger before build." |
| Adequate | "You ran the gate and made a start. Do one more pass after the revision so we know the gap is actually closed." |
| Weak | "A review that does not change the spec is just a report. Pick the highest-risk finding, revise that section, and check it again." |

### Finding Triage (4.5)

| Rating | Facilitator Says |
|--------|------------------|
| Strong | "Good triage. You fixed the finding that would have caused build rework, not the one that was easiest to polish." |
| Adequate | "That finding is worth fixing. Next time say why it is first: build risk, ambiguity, testability, or decision impact." |
| Weak | "Do not spend the first pass on wording while the acceptance criteria are still vague. Fix the thing that would make an AI team stop and ask questions." |

### Review Skepticism (4.5)

| Rating | Facilitator Says |
|--------|------------------|
| Strong | "You treated the review as evidence, not authority. That is the right posture: use the useful findings, challenge the weak ones, and improve the spec." |
| Adequate | "You checked one finding, which is good. Push that a bit further next time - the review is a tool, not a verdict." |
| Weak | "Do not accept or reject the whole review in one move. Inspect the evidence finding by finding, then decide what actually improves the spec." |

### Kill Criteria Quality (4.6)

| Rating | Facilitator Says |
|--------|------------------|
| Strong | "Those kill criteria are useful because they are measurable: metric, threshold, time window, source, and owner. If the pilot misses that line, the decision is already defined." |
| Adequate | "The kill criterion is close. Add the missing detail - usually the time window or data source - so nobody has to negotiate failure later." |
| Weak | "Ask the hard question now: what result would make us stop? Write it as a threshold, like conversion below X by month 3 or support cost above Y after pilot." |

### Stopping Mindset (4.6)

| Rating | Facilitator Says |
|--------|------------------|
| Strong | "You treated stopping as a responsible decision, not a failure. That is what prevents zombie projects." |
| Adequate | "The criteria are there, but make them part of the decision process, not a footnote. They should tell the team when to stop or revise." |
| Weak | "Kill criteria are not pessimism. They protect the team from continuing a project after the evidence says it is not working." |

---

## Checkpoint After 4.5

If all 4.5 dimensions are Adequate or Strong:
"You have the quality gate loop: review, triage, revise, verify. That is the habit that keeps bad specs from turning into expensive builds."

If any 4.5 dimension is Weak:
Coach on the weak dimensions, then run one narrower review/revision cycle before closing the module.

If all 4.6 dimensions are Adequate or Strong:
"Your spec now says not just what to build, but when to stop. That makes it much harder for this to become a zombie project."

If any 4.6 dimension is Weak:
Ask the developer to write one measurable kill criterion before completing the module.

---

## Recipe Reveal
After the checkpoint, show the developer the recipe behind this session.

"Fourteenth recipe. Third in the Stage 4 chain — and this one is read-only. It never
edits your spec. It reviews it, finding-by-finding, and hands you the list. You decide
what to fix."

Read the Spec Review recipe (recipes/agents/spec-review.yaml) and show the developer:
- The **read-only declaration repeated in instructions AND working-directory block** —
  "'This primitive is READ-ONLY — do not edit files.' And then in the working directory
  block: 'Do NOT write files. Return findings as structured data.' Same pattern you saw
  in code-review.yaml. A reviewer that could edit would have an incentive to declare
  itself correct. Separating review from revision is what makes the quality gate real."
- The **two different 10-dimension rubrics by `spec_type`** — "Process step 2: 'Select
  the appropriate 10-dimension rubric for the spec type.' One-pagers get problem clarity,
  kill criteria, market evidence, feasibility. Requirements docs get testability,
  persona coverage, traceability, gap analysis. The recipe knows the 10 things to
  check — you don't have to remember them. The review skepticism dimension you were
  rated on? This is what it's skeptical of — 10 named dimensions with evidence."
- The **'NEVER rate without evidence — quote the specific text or absence'** —
  "That constraint is why the review iteration loop worked. Every finding cites what
  in the spec triggered it. When you went back to revise, you weren't debating the
  reviewer's opinion; you were responding to a specific quoted passage. Evidence is
  what lets you triage confidently."
- The **`next_action` return field** — "The return has `next_action: The single most
  important thing to fix first.` That's the finding-triage dimension you were rated on —
  baked into the output. The agent commits to ONE thing you should fix before anything
  else. No 47-item priority list."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open recipes/agents/spec-review.yaml`
"Notice how this one is an evaluator archetype — strict read-only, returns findings.
Compare it to spec-decomposition.yaml which rewrites the spec. Different archetypes,
different constraints."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/spec-review.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

---

## Bridge

"That closes the spec stage. You can now turn an idea into something an AI team can build from: specific, persona-driven, testable, reviewed, and honest about when to stop. Next stage is about proving the system worked after it builds - evals and verification. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

---

## State Update

Write to ~/.rilgoose/progression.json:
  Update concept 4.3 (module 14: spec-review) with all dimension ratings
  (review_iteration, finding_triage, review_skepticism, kill_criteria_quality,
  stopping_mindset) as sub-fields of concept 4.3's eval_ratings, plus timestamp.
  Mark concept 4.3 complete when all required dimensions are Adequate or Strong.
  Mark Stage 4 complete when concepts 4.1 through 4.4 are complete.
  Never overwrite a Strong rating with a lower one.
