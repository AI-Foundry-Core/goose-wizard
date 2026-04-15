# Recipe 2.1: Build-Then-Test — "Two AIs Are Better Than One"

> **Path resolution note.** All paths and code operations in this script
> act on the TARGET codebase (the developer's project). The parent recipe
> injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md` or "the codebase," interpret those against
> `<TARGET>/`. Prepend the TARGET PROLOGUE to every `Delegate to subagent`
> call. Pass `target_codebase_path` to the `build-then-test` (builder
> and tester) sub-recipes.

Covers concept 2.1 (build-then-test). Teaches why one AI isn't enough and why specialists beat generalists.
Mode: Adaptive + Checkpoints.

---

## Quality Dimensions

### Concept 2.1 — Why One AI Isn't Enough

| Quality Dimension | Strong | Adequate | Weak |
|-------------------|--------|----------|------|
| **Separation awareness** | Developer recognized why the tester being independent matters — mentioned something like "it doesn't know what the builder assumed" or "fresh eyes." *"Exactly — the tester doesn't share the builder's blind spots. That's why it caught [X]. Same AI grading its own work misses the same things every time."* | Developer acknowledged the tester caught something but didn't articulate why independence matters. *"The tester found [X] that the builder missed. Think about why — the builder assumed its own code was correct. The tester read the code cold, with no assumptions. That independence is the whole point."* | Developer treated both agents as interchangeable or didn't notice the tester caught something the builder missed. *"Look at the tester's findings: [X]. The builder didn't flag that. It wrote the code, so it thought it was correct — like grading your own exam. A separate tester with no shared context is what caught it."* |
| **Result inspection** | Developer examined the discrepancies between builder and tester — read the tester's findings, asked questions about what was caught. *"Good — you dug into what the tester found instead of just glancing at pass/fail. That's how you learn what the builder's blind spots are."* | Developer looked at the summary but didn't examine the specific discrepancies. *"The summary said the tester found issues, but you didn't dig into what they were. Open the tester's findings — the specific discrepancies tell you where one-AI workflows break down."* | Developer ignored the tester's findings or accepted the result without reading it. *"Stop — the tester found [X] and you skipped right past it. The whole point of two agents is the second one catches things. If you don't read what it caught, you're back to trusting one AI."* |

### Concept 2.2 — Specialists Beat Generalists

| Quality Dimension | Strong | Adequate | Weak |
|-------------------|--------|----------|------|
| **Role separation** | Developer configured or understood that the builder and tester had different scopes — builder writes code, tester only tests. Didn't try to make one agent do both. *"You kept the roles clean — builder builds, tester tests, neither does the other's job. That separation is why the tester caught [X]. An agent trying to do both optimizes for the easy path."* | Developer understood there were two agents but was fuzzy on why they need different scopes. *"Two agents is the right structure, but the key is they have different jobs. The builder's job is implementation. The tester's job is finding problems. If you let one do both, it'll build something and then write tests that confirm what it built — not tests that challenge it."* | Developer suggested merging the agents or having the builder also write tests. *"Think about what happens if the builder also writes the tests: it writes code, then writes tests that match what it wrote. The tests pass, but they don't prove anything. The tester found [X] because it wasn't trying to justify the builder's code."* |
| **Information boundary** | Developer understood or respected that the tester shouldn't see the builder's reasoning — the independence is deliberate. *"Right — the tester only gets the task description and the code. No builder notes, no assumptions, no 'here's what I was going for.' That clean boundary is what makes the review honest."* | Developer understood the agents are separate but questioned why the tester can't see the builder's notes. *"The tester doesn't see the builder's reasoning on purpose. If it knows the builder assumed users always pass valid input, it'll test for valid input too. Blind review catches the assumptions. That's the point."* | Developer tried to pass builder context to the tester or didn't understand why the separation exists. *"You wanted to tell the tester what the builder was thinking. That defeats the purpose — if the tester shares the builder's assumptions, it shares the builder's blind spots. The tester reads the code cold. No context from the builder. That's what makes it effective."* |

---

## Setup

Read `<TARGET>/.goose/team_context.md` for project context.
Read ~/.rilgoose/progression.json — check concepts 2.1 and 2.2.
If both already demonstrated (all dimensions adequate+): offer to skip or revisit.
Verify Stage 1 is complete. If not, flag it — Stage 2 assumes the developer already knows single-agent workflows.

## Framing

"This time, one AI builds and a separate AI tests — the tester reads the code cold, with no idea what the builder was thinking."

"What's a small feature or change you need to make — something build-able in a few minutes? Or want me to find a small TODO in your codebase we can use?"

If developer has no current task:
  "No problem. Let me look at your codebase for something we can work with."
  Delegate to code-work subagent (prepend the TARGET PROLOGUE):
    "Read `<TARGET>/.goose/team_context.md`. Scan source code under
    `<TARGET>/` for a TODO, a missing utility function, or a small feature
    gap that would take 10-20 minutes to build manually. Describe it as a
    task the developer would recognize as real work."

## The Task — Concept 2.1

Developer describes the task (or accepts the found task).

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "build-then-test"
  parameters:
    task_description: {developer's description}
    acceptance_criteria: {if provided}
    target_files: {if provided}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent runs the two-phase workflow, returns builder summary + tester findings]

Facilitator presents the results naturally:

"Here's what the builder did: [summary]. Now here's what the independent tester found: [tester findings]."

If the tester caught something the builder missed (expected):
"See that? The tester found [specific issue] that the builder didn't flag. The builder wrote the code, so it thought it was correct. The tester read it cold and caught [X]. That's why one AI isn't enough."

If the tester found no issues (rare but possible):
"The tester verified everything clean this time. That doesn't always happen — when the builder makes assumptions, the independent tester is what catches them. The value is the verification, even when it confirms the code is solid."

Let the developer examine the results. Watch for the quality dimensions — are they inspecting the discrepancies? Do they understand why the tester being independent matters?

## Transition to Concept 2.2

"So you've seen that a separate tester catches things the builder misses. But notice something else — the builder's entire job was writing code. The tester's entire job was finding problems. Neither was trying to do both. That's why it works."

"Let's look at what happens when you're deliberate about those roles. This time, I want you to think about what the builder should focus on versus what the tester should focus on. Tell me — if you were setting up these two agents, what would each one's job description be?"

Let the developer articulate the roles. Guide toward: the builder implements, the tester challenges. The tester should NOT see the builder's reasoning.

If the developer suggests the builder should also write tests:
  "Think about what happens if the builder writes the tests: it implements
  something, then writes tests that match what it built. Those tests pass,
  but they prove nothing. The tester found [X] because it wasn't trying
  to justify the builder's work."

Run another build-then-test if the developer wants to try with deliberate role awareness, or continue to the checkpoint if the concept is clear.

## Checkpoint (after 2.2)

Delegate to eval subagent (async: true):
  [See eval prompt below]

Read eval results. Follow the priority order from teacher-instructions.md Section 4 exactly:
1. Acknowledge what was Strong — specific praise for the specific behavior the developer demonstrated.
2. Coach what was Weak — targeted, with contrast. This is the priority teaching.
3. Suggest for Adequate — light touch, one sentence with the "why." Do NOT praise Adequate as if it were Strong.

Use the coaching language from the quality dimension table above for each rating level. If a dimension is rated Adequate, use the Adequate coaching language — not the Strong language. Minimal role labels like "builder writes, tester tests" are Adequate unless the developer explains scope, challenge behavior, and independence.

Checkpoint framing:
"Quick check — you've now seen the build-then-test pattern. Two agents, separated roles, no shared context. [Address any weak dimensions]. The tester catches what the builder misses because it doesn't share the builder's assumptions."

If any 2.1 or 2.2 dimension is Weak, work through it before proceeding:
  "Before we move on — [coaching for weak dimension]. Let's try one more to make sure this clicks."
  Run another build-then-test with focus on the weak dimension.

If all dimensions are Adequate or Strong:
"Good foundation. Next we'll take this further — instead of just testing after building, you'll set up a review gate that blocks bad code from being accepted. Same principle, higher stakes."

## Wait-Time Insights

Ordered list for this module. Use per teacher-instructions.md Section 13 rules.

1. `[specialization]` "While it's working — notice the builder's entire job is implementation. It's not thinking about edge cases or security. That focus is why it's fast — and why it needs a second pair of eyes."
2. `[verify]` "One thing to keep in mind — the tester reads the code cold. No knowledge of what the builder intended. That's the same advantage a fresh code reviewer has on Monday morning."
3. `[self-verification-bias]` "Something you'll notice — when one agent writes and reviews its own code, it skips the same things every time. Same blind spots, same assumptions. Splitting the work breaks that cycle."
4. `[enterprise]` "In production systems at scale, the bugs that make it to prod are almost never syntax errors. They're assumption errors — thread safety, resource cleanup, edge cases nobody thought to test. That's exactly what an independent tester catches."
5. `[specialization]` "The builder optimizes for making the algorithm work. The tester optimizes for finding where it breaks. Those are opposing goals — which is why one agent can't do both well."
6. `[feedback-loops]` "Every time the tester catches something the builder missed, that's data about the builder's blind spots. Over time, you learn which kinds of issues need the hardest scrutiny."

---

## Recipe Reveal

After the wait-time insights and any checkpoint coaching, show the developer the recipe behind this session.

"Fifth recipe — and this one is the first multi-agent recipe you've seen. It's not one worker doing a job. It's a coordinator that runs two workers that don't know about each other."

Read the Build-Then-Test coordinator recipe (recipes/graduated/build-then-test.yaml) and show the developer:
- The **`sub_recipes` block** — "This is new. Every Stage 1 recipe was one agent doing one job. This recipe has a `sub_recipes:` section that lists two child recipes — `builder` and `tester`. The coordinator itself writes no code and runs no tests. Its entire job is to call the two sub-recipes in order and pass results between them."
- The **coordinator constraint 'NEVER do implementation or testing yourself'** — "Look at the instructions block: 'NEVER do implementation or testing yourself — delegate to sub-recipes.' That's the rule that keeps role separation real. The coordinator is not allowed to grade the builder's work — that's why the tester exists."
- The **information boundary in the prompt** — "Find the line 'Do NOT pass the builder's reasoning, assumptions, or self-review.' Remember when we talked about why the tester shouldn't see the builder's notes? That's literally encoded in the coordinator prompt. The tester gets `task_description`, `acceptance_criteria`, and `changed_files` — nothing else. The information wall is not a convention. It's a parameter list."
- The **two agent primitives side-by-side** — "Open builder.yaml and independent-tester.yaml next to each other. Builder's constraints say 'NEVER include your internal reasoning in the output.' Tester's constraints say 'NEVER trust the builder's summary — you have not seen it.' The separation you experienced is the product of two recipes each refusing to do the other's job."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open them in the desktop app:
Run: `goose recipe open <path to recipes/graduated/build-then-test.yaml>`
Run: `goose recipe open <path to recipes/agents/builder.yaml>`
Run: `goose recipe open <path to recipes/agents/independent-tester.yaml>`
"Three files for one workflow — that's what coordinated specialists look like on disk."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/<file>.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

## Bridge

"You've got two agents that don't trust each other's work. Next up: turning that tester into a gate that actually blocks bad code — and making sure it checks by running things, not just looking at them. Ready to keep going?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

## State Update

Write to ~/.rilgoose/progression.json:
  Update concept 2.1 (module 6: build-then-test) with all four dimension ratings
  (separation_awareness, result_inspection, role_separation, information_boundary)
  as sub-fields of concept 2.1's eval_ratings, plus timestamp.
  Update concept 2.1 status to "complete" when all four are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.

---

## Eval Subagent Prompt

```
You are evaluating how well a developer approached a two-agent build-then-test workflow. This covers concept 2.1 (build-then-test).

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript (quote or paraphrase what the developer said/did)
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. SEPARATION AWARENESS
   Strong: Developer recognized why the tester being independent matters — mentioned the builder's blind spots, fresh perspective, or "grading your own work" dynamic. Articulated that shared context reduces the tester's effectiveness.
   Adequate: Developer acknowledged the tester caught something the builder missed but did not articulate why independence (no shared context) is the mechanism that makes it work.
   Weak: Developer treated both agents as interchangeable, didn't notice the tester caught something new, or didn't engage with why two agents are different from one.

2. RESULT INSPECTION
   Strong: Developer examined the specific discrepancies between builder and tester — read the tester's findings in detail, asked about specific issues caught, or discussed what the builder's blind spot was.
   Adequate: Developer looked at the pass/fail summary but did not dig into the specific discrepancies or what exactly the tester found that the builder missed.
   Weak: Developer ignored the tester's findings, accepted the result without reading it, or showed no interest in what the second agent caught.

3. ROLE SEPARATION
   Strong: Developer understood or articulated that builder and tester have different scopes and jobs — builder implements, tester challenges. Did not suggest merging them or having one agent do both.
   Adequate: Developer understood there are two agents but was unclear on why they need different scopes, or initially suggested one agent could do both but accepted the separation after discussion.
   Weak: Developer actively suggested merging the agents, having the builder write its own tests, or showed no understanding of why role separation matters.

4. INFORMATION BOUNDARY
   Strong: Developer understood or respected that the tester should not see the builder's reasoning or assumptions — recognized that the information wall is deliberate and makes the review honest.
   Adequate: Developer understood the agents are separate but questioned why the tester can't see the builder's notes, or didn't proactively think about what information the tester receives.
   Weak: Developer tried to pass builder context to the tester, suggested the tester should know the builder's intent, or did not understand that shared information undermines the independence.

Return as JSON:
{
  "dimensions": [
    {"name": "separation_awareness", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "result_inspection", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "role_separation", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "information_boundary", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "Any cross-cutting observation about how the developer is internalizing the two-agent pattern"
}
```
