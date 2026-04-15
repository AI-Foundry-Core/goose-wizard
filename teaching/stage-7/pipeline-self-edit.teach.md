# Recipe 7.2: Pipeline Self-Edit - "One source of truth per rule"

> **Path resolution note.** All paths and code operations in this script
> act on the TARGET codebase (the developer's project). The parent recipe
> injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md`, refers to instruction files, skill files,
> agent definitions, or "the pipeline," interpret those against
> `<TARGET>/` (e.g., `<TARGET>/.goose/`, `<TARGET>/agents/`, or wherever
> the developer's instruction files live under <TARGET>). Prepend the
> TARGET PROLOGUE to every `Delegate to subagent` call. Pass
> `target_codebase_path` to the `pipeline-self-edit` sub-recipe.

Covers concept 7.2 (pipeline-self-edit). Teaches rule deduplication and guardrail auditing.

Mode: Fully Adaptive. Facilitator is pure consulting - available when the developer asks, not driving.

---

## Setup

Read <TARGET>/.goose/team_context.md for project context.
Read ~/.rilgoose/progression.json - check concept 7.2 (module 25: pipeline-self-edit).
If both already demonstrated (all dimensions adequate+): offer to skip or revisit.

Check prerequisites:
- Concepts 7.1 and 7.2 should be complete (developer has edited instructions)
- Developer should have multiple agent instruction files in their pipeline
  (at least 3 - if fewer, the audit won't surface meaningful duplication)

If developer has fewer than 3 instruction files:
  "Rule conflicts become a real problem once you have 3+ agents with their own
  instruction files. If your pipeline is smaller than that, this recipe won't
  show you much yet. Come back when you've added more agents."

---

## Framing

"Every time you fix something, you add a rule. Every time an agent misbehaves,
you add a constraint. Over time, those rules pile up. Some end up in multiple
files. Some contradict each other. Some were written for a model version that's
two generations old. When agents see conflicting rules, they pick one at random  - 
and you get inconsistent behavior that's nearly impossible to debug."

Pause for developer response. Follow their lead.

If developer asks how bad this actually gets:
  "In one pipeline, the same naming convention rule existed in 3 different files
  with slightly different wording. The builder followed one version, the reviewer
  enforced another, and every PR got flagged for a 'violation' that was actually
  just the two agents disagreeing. Accuracy dropped 37% before anyone figured
  out why."

---

## Task

The developer drives. The facilitator is available for questions.

**What the developer needs to do:**

1. Gather all agent instruction/skill files across their pipeline
2. Run the pipeline-self-edit recipe to audit for duplication and conflicts
3. Review the safe edits it applied and the items it flagged for judgment
4. For the guardrail audit specifically: identify at least one guardrail that exists
   because of a model limitation that may no longer apply

Delegate to code-work subagent when the developer is ready (prepend the TARGET PROLOGUE):
  sub-recipe: "pipeline-self-edit"
  parameters:
    instruction_files: {developer's list of instruction file paths — absolute under <TARGET>/}
    audit_focus: {if developer wants to focus on a specific area}
    known_issues: {if developer has known conflicts to prioritize}
    verification_command: {if developer provides one — should run from within <TARGET>/}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent reads all files, extracts rules, cross-references, applies safe consolidation edits, verifies, and generates report]

Facilitator presents results naturally:
"[Here's the rule count before and after...] [These duplicates were consolidated...] 
[These conflicts need judgment...] [These guardrails might be outdated...] [Verification result...]"

**After the audit report:**
The developer should make decisions about unresolved conflicts, outdated guardrails, or any proposed cleanup the recipe intentionally did not apply.
The facilitator does not decide for them - this requires judgment about their
specific pipeline.

If the developer asks for the facilitator's opinion on a specific rule:
  Give it. Consulting mode means being genuinely helpful when asked, not
  withholding useful perspective.

**For the guardrail audit dimension:**
If the audit didn't surface any POTENTIALLY_OUTDATED rules, prompt:
  "Look at your oldest rules - the ones you added in the first few weeks. Are
  any of them working around a model behavior that's since been fixed? Models
  improve. Rules written for GPT-4 might not apply to GPT-5. Worth checking."

---

## Eval

Delegate to eval subagent (async: true):

```
You are evaluating how well a developer audited and pruned rules across their
pipeline's agent instruction files.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say  - 
   conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. DUPLICATION AWARENESS
   Strong: Developer identified rules that appeared in multiple files and chose a single source of truth for each. Understood that duplication causes drift - files get updated independently and diverge.
   Adequate: Developer found duplicates but handled them inconsistently - consolidated some, left others "because they seem harmless." Didn't fully grasp that even benign duplication causes problems when files get edited later.
   Weak: Developer didn't look for duplication, or dismissed duplicate rules as "not a big deal" without considering the downstream effects.

2. CONFLICT RESOLUTION QUALITY
   Strong: Developer resolved conflicts by making a deliberate choice about which version to keep, with reasoning about why. Didn't just pick the first one found - considered which is more specific, more correct, or more aligned with the pipeline's current goals.
   Adequate: Developer acknowledged conflicts but resolved them mechanically - kept the longer version, or the newer one, without reasoning about which is actually correct for the pipeline.
   Weak: Developer left conflicts unresolved, or "resolved" them by keeping both versions in the same file (which doesn't fix the problem - it just moves it).

3. GUARDRAIL SKEPTICISM
   Strong: Developer questioned at least one existing constraint and evaluated whether it's still necessary. Either confirmed it with evidence ("this model still hallucinates function names - I checked") or removed it with justification ("this was for GPT-4's tendency to X, which GPT-5 doesn't do").
   Adequate: Developer acknowledged that guardrails can become outdated but didn't actually evaluate any specific ones. Theoretical understanding without practical action.
   Weak: Developer treated all existing rules as sacred - never questioned whether any constraint might be unnecessary overhead.

4. CONSOLIDATION FOLLOW-THROUGH (conditional)
   Condition: Only rate this if the developer actually applied consolidation changes (not just reviewed the report).
   If condition not met: return rating=null, evidence="Developer reviewed audit but did not apply changes in this session", coaching=null
   Strong: Developer applied changes, verified the pipeline still works after consolidation, and the rule count is measurably lower.
   Adequate: Developer applied some changes but skipped verification - consolidated rules without checking that agents still behave correctly.
   Weak: Developer applied changes that introduced new problems - consolidated rules incorrectly or removed something that was actually needed.

Return as JSON:
{
  "dimensions": [
    {"name": "duplication_awareness", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "conflict_resolution_quality", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "guardrail_skepticism", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "consolidation_follow_through", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

---

## Coaching

Read eval results. For each dimension:

### Duplication Awareness

| Rating | Coaching |
|--------|----------|
| **Strong** | "Right - one source of truth per rule. When you need to change a rule later, you change it in one place. No drift, no surprises." |
| **Adequate** | "You found the duplicates, but leaving some 'because they're harmless' is how this problem comes back. When someone edits one copy six months from now and not the other, you get a ghost conflict. Consolidate all of them." |
| **Weak** | "Count how many files contain a rule about [specific example from their pipeline]. Now imagine changing that rule. You'd need to update every copy - and if you miss one, the agents disagree. That's why duplication matters." |

### Conflict Resolution Quality

| Rating | Coaching |
|--------|----------|
| **Strong** | "Good judgment calls. You didn't just pick arbitrarily - you thought about which version actually serves the pipeline. That's the difference between cleanup and improvement." |
| **Adequate** | "You resolved the conflicts, but 'keep the longer version' isn't always right. The shorter, more specific version might be better. For each conflict, ask: which version produces the behavior I actually want?" |
| **Weak** | "Leaving conflicts in place means your agents are making random choices. Pick one version. If you're not sure which is right, test both - run the pipeline with version A, then version B, and see which produces better output." |

### Guardrail Skepticism

| Rating | Coaching |
|--------|----------|
| **Strong** | "That's the right question to keep asking. Models improve, your pipeline matures, and rules that were essential six months ago become unnecessary drag. Periodic guardrail audits should be a habit." |
| **Adequate** | "You understand the concept - now pick one specific guardrail and actually test whether it's still needed. Remove it temporarily, run the pipeline, and see what happens. Evidence beats theory." |
| **Weak** | "Every rule has a cost - it's a constraint on what the agent can do. Some of those constraints were written for a model that's two generations old. Ask yourself: does this rule exist because of a model limitation that may no longer apply? If you can't remember why a rule exists, that's a sign it needs review." |

### Consolidation Follow-Through (if triggered)

| Rating | Coaching |
|--------|----------|
| **Strong** | "Clean execution - you consolidated, verified, and the pipeline is leaner. That's maintenance that most teams never do, and it compounds over time." |
| **Adequate** | "You consolidated but didn't verify. Rule changes can have unexpected effects - an agent might rely on a rule you thought was a duplicate but was actually slightly different for a reason. Always run the pipeline after consolidation." |
| **Weak** | "The consolidation introduced new issues. That's actually fine - it means you're learning which rules matter. Revert what broke, understand why, and try again with a more targeted approach." |

If ALL dimensions are Strong:
  "Your pipeline is cleaner, your rules don't conflict, and you're questioning
  whether old guardrails still earn their keep. That's the maintenance mindset
  that separates a pipeline that degrades from one that stays sharp."

---

## Recipe Reveal
After coaching, show the developer the recipe behind this session.

"This is the first recipe you've seen that edits other recipes. That's a big enough
shift that the safety rails deserve a close look."

Read the Pipeline Self-Edit agent recipe (recipes/agents/pipeline-self-edit.yaml) and show the developer:
- The **`audit_only` parameter defaulting to `'true'`** — "A curator agent defaults to
  read-only. You have to explicitly pass `audit_only: false` to let it touch instruction
  files. That's the kill-switch — any recipe that edits other recipes should ship with
  its destructive mode off by default."
- The **'NEVER remove rules marked POTENTIALLY_OUTDATED automatically' constraint** —
  "Even in apply mode, the agent isn't allowed to delete guardrails unilaterally. It flags
  them for human review. That's the line between a curator and a bulldozer: it can
  consolidate duplicates, but deciding whether an old rule still earns its keep stays with
  you."
- The **`rule_counts` return field (before and after)** — "The recipe is required to
  report rules per file before AND after. That's the metric that makes self-editing
  measurable — if total rules went from 84 to 71, you can see that the consolidation
  actually happened. A curator that can't show its work can't be trusted."
- The **split between `edits_applied` and `conflicts`** — "Anything the agent is
  confident about goes in `edits_applied`. Anything ambiguous lands in `conflicts` for you
  to decide. That's the self-editing pattern: automate the safe parts, escalate the
  judgment calls."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open <path to recipes/agents/pipeline-self-edit.yaml>`
"Look at `audit_only` first — that one default is most of what makes this recipe safe
to ship."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/pipeline-self-edit.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

---

## Bridge

"Your rules are clean and your guardrails are audited. But the rules
themselves aren't the only thing that needs to evolve — the instructions
driving your agents have to evolve from findings too. A finding from last
week's cycle should become a rule for next week's cycle automatically.
Next: the Curator pattern — turning findings into durable instruction
changes. That's the final module. Ready to close this out?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

---

## State Update

Write to ~/.rilgoose/progression.json:
  Update concept 7.2 (module 25: pipeline-self-edit) with all dimension ratings
  (duplication_awareness, conflict_resolution_quality, guardrail_skepticism,
  consolidation_follow_through) as sub-fields of concept 7.2's eval_ratings,
  plus timestamp.
  Update concept 7.2 status to "complete" when all required dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
