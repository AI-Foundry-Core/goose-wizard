# Audit: Internal Consistency and Voice/Framework Compliance

**Date:** 2026-04-12
**Scope:** 10 teaching scripts spanning Stages 0-7, plus reference documents (SKILL.md, teacher-instructions.md, example-module.md, eval-prompt-template.md, progression-format.md)

---

## 1. Structure Consistency

**Expected section order (from example-module.md):** Setup, Framing, [Stuck Path], Task, Eval, Coaching, Bridge, State Update

### Findings

**Scripts that follow the canonical order:**
- `teaching/stage-1/bug-fix.teach.md` -- exact match
- `consolidated/teaching/stage-1/test-writer.teach.md` -- exact match
- `teaching/stage-5/eval-foundation.teach.md` -- exact match
- `teaching/stage-5/eval-layers.teach.md` -- exact match
- `teaching/stage-7/skill-evolution.teach.md` -- exact match (uses "Task" not "The Task")

**Scripts that deviate:**

1. **Stage 0 scripts (act-1, act-4):** Use Step 1/Step 2/Step 3/Bridge structure instead. No Setup, no Eval, no Coaching, no State Update. **Verdict: Acceptable deviation.** Stage 0 is Scripted mode -- no eval subagent, no quality dimensions, no progression tracking per-dimension. The stepped format matches CourseForge Say/Check/Action. However, there is no state update at all in Stage 0 scripts. The progression-format.md shows Stage 0 as a simple `"complete"` status with no dimensions, so the acts presumably rely on external completion marking. **Recommendation:** Add a brief note in each Stage 0 act about who marks stage 0 complete (the teach-wrapper, presumably after all 5 acts run).

2. **`consolidated/teaching/stage-2/spec-first.teach.md`:** Adds a "Quality Dimensions" table before Setup (not in the canonical order). Adds a "Checkpoint" section between Coaching and Bridge. **Verdict: Partially acceptable.** The Quality Dimensions table up front is useful reference but departs from the example-module where dimensions live in a separate "Part 4" section. The Checkpoint section is expected for Stages 2-4 per the teaching framework, but it is not present in the example module. **Recommendation:** Standardize where the Quality Dimensions table goes -- either always at top (as a reference block) or always after the eval prompt. Currently inconsistent.

3. **`consolidated/teaching/stage-3/three-agent-pipeline.teach.md`:** Adds "Checkpoint After 3.3" between Task and Eval. **Verdict: Acceptable.** Checkpoints are part of Stages 2-4 mode.

4. **`consolidated/teaching/stage-3/escalation-routing.teach.md`:** Adds "Checkpoint After 3.3" between Task and Eval. Same pattern as three-agent-pipeline. **Verdict: Consistent with its peer.**

5. **`consolidated/teaching/stage-4/spec-to-pipeline.teach.md`:** Uses Phase 1/2/3/4 sub-structure within The Task section, plus a Checkpoint section. Has a "Stuck Path" as a named section rather than inline in Framing. **Verdict: The phase structure is a good adaptation for a complex multi-step recipe, but differs from simpler scripts.**

6. **`teaching/stage-6/continuous-dev.teach.md`:** Uses "Facilitator Response" instead of "Coaching" for the post-result section. Has a separate Coaching section that only reads eval results. **Verdict: The dual structure (Facilitator Response for immediate presentation, Coaching for post-eval) is cleaner than other scripts but differs from the convention.** All other scripts blend result presentation into "The Task" and keep "Coaching" for post-eval only. This script's approach is arguably better but inconsistent.

### Summary

| Deviation | Scripts Affected | Severity |
|-----------|-----------------|----------|
| Stage 0 uses Steps not sections | act-1, act-4 (all Stage 0) | Low -- mode-appropriate |
| Quality Dimensions table placement inconsistent | spec-first (top) vs. others (inline or absent) | Medium |
| "Facilitator Response" vs "Coaching" naming | continuous-dev | Medium |
| Checkpoint placement varies (before vs after Eval) | spec-first, three-agent-pipeline, escalation-routing, spec-to-pipeline | Low -- all checkpoints are post-task |
| Phase sub-structure within Task | spec-to-pipeline | Low -- complexity-appropriate |

---

## 2. Coaching Voice Compliance

**Checked against teacher-instructions.md rules:**
- No "you should have"
- No empty praise ("Good job!", "Well done!")
- No fourth-wall breaks (mentions of eval, ratings, scripts, teaching system)
- No lectures longer than 3 sentences per dimension
- Praise behavior, not people
- Show contrast for weak ratings

### Findings

**Fourth-wall breaks: NONE found.** All 10 scripts keep the system invisible. No mentions of "eval subagent," "quality rating," "teaching system," or "progression tracking" in any facilitator-facing language. Eval prompts correctly instruct "never mentions the eval system or ratings." Clean across the board.

**"You should have": NONE found.** All weak coaching uses contrast examples ("Compare what you said to...") or direct instruction ("Stop -- always check...") rather than retrospective blame.

**Empty praise: NONE found.** All Strong coaching praises specific behavior:
- "You gave it the symptom, what you ruled out, and a theory" (bug-fix)
- "Perfect scope -- tight and specific" (test-writer)
- "You defined success before the first line of code" (spec-first)
- "You went straight to the source" (eval-foundation)

**Lecture length:** All coaching blocks are 1-3 sentences per dimension. One notable case:

- **`consolidated/teaching/stage-3/three-agent-pipeline.teach.md`, Weak coaching for "role_specialization":** This coaching block is 4 sentences: "Right now this is one generalist wearing three hats. Compare that to: Spec Agent writes acceptance criteria, Build Agent changes code, Review Agent runs checks. The first design is one person grading their own exam -- they'll always find their own work reasonable. The second design is three people who each see the work fresh." **Verdict: Borderline.** The last two sentences are the contrast, which is the core teaching move. Could be tightened to 3 sentences.

- **`consolidated/teaching/stage-3/three-agent-pipeline.teach.md`, Weak coaching for "handoff_contracts":** Also 4 sentences with a code example. **Verdict: The code example is integral -- hard to shorten meaningfully.**

- **`consolidated/teaching/stage-3/three-agent-pipeline.teach.md`, Weak coaching for "safety_rails":** 5 sentences. "Without a stop rule, a failing agent loops forever. Here's what that looks like in practice: the builder submits, the reviewer rejects, the builder 'fixes' by making a different mistake, the reviewer rejects again, and this continues for 47 cycles until you notice your API bill. Compare that to: after 3 rejected reviews, stop, package the last attempt with all reviewer feedback, and route to a human. The pipeline costs you 3 cycles instead of 47." **Verdict: Over the 3-sentence limit but the narrative illustration is effective. Consider condensing the middle two sentences into one.**

- **`consolidated/teaching/stage-3/escalation-routing.teach.md`, Weak coaching for "escalation_evidence":** 3 sentences. Compliant.

**Voice consistency:** All scripts maintain the "knowledgeable colleague" voice. No academic language found ("research shows," "best practices suggest"). No hedging ("you might want to consider"). The spec-first script uses slightly more structured/formal language in its Quality Dimensions table (longer coaching strings), but the actual Coaching section redirects to that table rather than duplicating it.

### Summary

| Issue | Location | Severity |
|-------|----------|----------|
| Coaching block exceeds 3 sentences | three-agent-pipeline: role_specialization (4 sentences) | Low |
| Coaching block exceeds 3 sentences | three-agent-pipeline: handoff_contracts (4 sentences + code) | Low |
| Coaching block exceeds 3 sentences | three-agent-pipeline: safety_rails (5 sentences) | Medium |
| No violations found | Fourth wall, empty praise, "you should have", academic voice | Clean |

---

## 3. Eval Prompt Consistency

**Template requirements (from eval-prompt-template.md):**
- Opening: "You are evaluating how well a developer approached [TASK]"
- Transcript block with `{transcript}` placeholder
- Rating instructions: Rate as "Strong", "Adequate", or "Weak" with evidence and coaching
- Conditional dimensions use `rating: null` pattern
- Return as JSON with `dimensions` array and `overall_note`
- Each dimension object: `name`, `rating`, `evidence`, `coaching`

### Findings

**All 10 scripts with eval prompts follow the template structure.** (Stage 0 has no eval prompts, which is correct.)

**JSON structure consistency:**

- **bug-fix, test-writer, eval-foundation, eval-layers, skill-evolution:** Use the minimal object: `{"name", "rating", "evidence", "coaching"}`. Matches template exactly.
- **spec-first:** Adds a `"concept"` field to each dimension object: `{"name", "concept": "2.4", "rating", "evidence", "coaching"}`. **Deviation.** No other script includes `concept` in the eval JSON.
- **three-agent-pipeline, escalation-routing:** Use the minimal object. Match template.
- **spec-to-pipeline:** Uses the minimal object. Match template.
- **continuous-dev:** Uses the minimal object. Match template.

**Dimension naming conventions:**
- All use snake_case: `context_quality`, `fix_verification`, `scope_definition`, etc. Consistent.
- Conditional dimensions consistently use `rating: null` with evidence "Not triggered" and `coaching: null`. Good.

**One inconsistency in conditional dimension format:**
- **escalation-routing** uses a dash in the null evidence: `"Not triggered - failure scenario did not create dirty state"`
- **bug-fix** uses an em-dash: `"Not triggered -- AI solved in fewer than 3 attempts"` (actually rendered as two hyphens in the markdown)
- **spec-first** uses an em-dash: `"Not triggered -- implementation matched spec on first pass"`
- **Minor formatting inconsistency** but functionally equivalent. All parse correctly.

### Summary

| Issue | Location | Severity |
|-------|----------|----------|
| Extra `concept` field in eval JSON | spec-first | Medium -- breaks JSON schema uniformity |
| Inconsistent dash style in "Not triggered" evidence | Multiple scripts | Low -- cosmetic |

---

## 4. Bridge Quality

**Requirements (from teacher-instructions.md Section 8):**
- Every script ends with a bridge
- Structure: [What you just did] + [What becomes possible next]
- Frames advancement as expanding power, not adding complexity
- No curriculum language ("now we'll learn about...")
- No complexity framing ("introduces additional complexity")
- No system architecture reveals ("You've completed Stage 1")

### Findings

**All 10 scripts have bridges.** Every script ends with a Bridge section (Stage 0 uses "Bridge to Act N").

**Bridge quality assessment:**

| Script | Bridge Text | Compliance |
|--------|-------------|------------|
| act-1 | "reading is just the start... I'm going to make a change to your code" | Good -- power expansion |
| act-4 | "one more thing... the single biggest lever you have" | Good -- teaser |
| bug-fix | "imagine applying this speed to test writing" | Good -- power expansion |
| test-writer | "you were the one checking the quality... imagine pointing AI at someone else's PR" | Good -- power expansion |
| spec-first | "Right now you have two agents... What happens when the task is bigger?" | Good -- power expansion |
| three-agent-pipeline | "the next problem is coordination under parallel work" | Good -- next capability |
| escalation-routing | "Safety rails answer what the team does when it gets stuck" | Good -- connects to next |
| spec-to-pipeline | Two conditional bridges (to spec-review or Stage 5) | Good -- context-aware |
| eval-foundation | "one layer of checking isn't enough... That's eval layers" | Good -- power expansion |
| continuous-dev | "Stage 7 takes the next step: when the workflow itself keeps improving" | **Borderline.** Mentions "Stage 7" by name. |
| skill-evolution | "rules accumulate... auditing and pruning the rules themselves" | Good -- next capability |
| eval-layers | "what prevents quality from slowly sliding backward... That's ratchets" | Good -- power expansion |

**One violation:** `continuous-dev.teach.md` bridge says "Stage 6 is the point where autonomy becomes operational. Stage 7 takes the next step." This references stage numbers, which is system architecture language. The teacher-instructions.md explicitly prohibits "You've completed Stage 1. Stage 2 covers..." The continuous-dev bridge is less egregious (it does not say "you've completed"), but naming stages by number in the bridge is a minor fourth-wall crack.

**Recommendation:** Rewrite continuous-dev bridge to avoid stage numbers: "Now the pipeline runs itself and remembers what it learned. The next move is packaging those improvements into reusable skills -- so the whole system gets smarter, not just this one pipeline."

### Summary

| Issue | Location | Severity |
|-------|----------|----------|
| Bridge references stage numbers | continuous-dev | Medium |
| All other bridges compliant | -- | Clean |

---

## 5. Progression State Writes

**Requirements (from progression-format.md and teacher-instructions.md):**
- Write to `.goose/state/progression.json`
- Record each dimension with rating + timestamp
- Set concept complete when all required dimensions are Adequate or Strong
- Set stage complete when all concepts are complete
- Never overwrite Strong with lower rating
- Conditional dimensions with `rating: null` do not block completion

### Findings

**State update presence:**
- Stage 0 scripts: No state update sections. **Gap.** Who marks Stage 0 complete? The progression-format.md shows Stage 0 as `"status": "complete"` with no dimensions, but none of the act scripts write this.
- All Stage 1+ scripts: Have State Update sections. Good.

**Strong-overwrite protection:**
- bug-fix: "Never overwrite a Strong rating with a lower one." Present.
- test-writer: "Never overwrite a Strong rating with a lower one." Present.
- spec-first: Does not explicitly state Strong-overwrite protection. **Gap.**
- three-agent-pipeline: "Never overwrite a Strong rating with a lower one." Present.
- escalation-routing: "Never overwrite a Strong rating with a lower one." Present.
- eval-foundation: Does NOT include Strong-overwrite protection. **Gap.**
- eval-layers: Does NOT include Strong-overwrite protection. **Gap.**
- continuous-dev: "Never overwrite a Strong rating with a lower one." Present.
- spec-to-pipeline: "Never overwrite a Strong rating with a lower one." Present.
- skill-evolution: Does NOT include Strong-overwrite protection. **Gap.**

**Field naming consistency:**

Most scripts use a prose description of what to write. One script deviates:
- **continuous-dev:** Includes a full JSON example block showing the exact state structure. This is the most explicit and implementation-ready state update of any script. **Verdict: Better than prose, but inconsistent with all other scripts.** If a developer or LLM reads the continuous-dev script, the JSON block is unambiguous. All other scripts leave the exact JSON structure to the teach-wrapper's interpretation.

**Concept-to-dimension mapping:**
- Scripts covering single concepts (bug-fix 1.1, test-writer 1.2, eval-foundation 5.1): Straightforward.
- Scripts covering multiple concepts (three-agent-pipeline 3.1-3.3, continuous-dev 6.4-6.6, skill-evolution 7.1-7.2): Explicitly map which dimensions belong to which concept. Good.
- spec-to-pipeline: Maps all dimensions to concept 4.4 and notes conditional dimension handling. Good.

**Stage completion logic:**
- spec-first (2.4): "If all Stage 2 concepts are complete, set stage 2 status to complete." Present.
- three-agent-pipeline: Does NOT check stage completion -- only individual concepts. Acceptable since it covers 3.1-3.3, not all of Stage 3.
- escalation-routing: "Do not mark Stage 3 complete from this module unless concepts 3.4 and 3.5 are already complete." Good -- explicit about what it cannot do.
- spec-to-pipeline: "If concepts 4.1 through 4.6 are complete, mark Stage 4 complete." Present.
- continuous-dev: State JSON shows `"status": "in_progress"` for Stage 6, with concept-level completion rules. Correct.

### Summary

| Issue | Location | Severity |
|-------|----------|----------|
| No state update in Stage 0 scripts | All Stage 0 acts | Medium |
| Missing Strong-overwrite protection | spec-first, eval-foundation, eval-layers, skill-evolution | High |
| Inconsistent state update format (JSON vs prose) | continuous-dev vs all others | Low |

---

## 6. Teacher-Instructions Alignment

**Question:** Does `teacher-instructions.md` accurately reflect the patterns in the actual teaching scripts? Any contradictions?

### Alignment confirmed

1. **Four teaching modes** match script behavior: Stage 0 = Scripted (act scripts follow Say/Check/Action), Stage 1 = Guided-Adaptive (bug-fix, test-writer let developer do work then coach), Stages 2-4 = Adaptive+Checkpoints (spec-first, three-agent-pipeline have checkpoints), Stages 5-7 = Fully Adaptive (eval-foundation, continuous-dev, skill-evolution open with consulting stance).

2. **Coaching voice rules** match actual coaching language in all scripts. Specific behavior praise, contrast for weak, no empty praise.

3. **Delegation convention** matches all scripts. All use the same pseudocode pattern: `Delegate to code-work subagent: sub-recipe: "name"`.

4. **Dynamic content handling** matches. All scripts present results naturally, not as mechanical JSON field listings.

5. **Stuck path handling** matches. bug-fix, test-writer, spec-first, three-agent-pipeline, escalation-routing, spec-to-pipeline all have stuck paths that scan the codebase for real tasks.

6. **Bridge patterns** match (one exception noted in Section 4).

### Contradictions and gaps

1. **Teacher-instructions Section 9 says:** "Read `.goose/state/progression.json`" at session start and "Write to `.goose/state/progression.json`" after eval. The State Management section says "Never overwrite a Strong rating with a lower one." However, 4 of 10 scripts omit this protection. **The instructions are correct; the scripts are inconsistent.** (See Section 5 findings.)

2. **Teacher-instructions Section 2 (Guided-Adaptive) says:** "Does NOT interrupt the developer during the task to correct approach." The test-writer script has a "Proactive assertion-quality prompt" that surfaces assertion quality during the task before eval runs. This is a mid-task intervention where the facilitator asks the developer to inspect test quality. **Mild contradiction.** The test-writer approach is pedagogically sound (it gives the eval something to observe) but technically violates the "don't interrupt, wait for eval" rule.

3. **Teacher-instructions Section 7 (Stuck Path - Teaching Pitfalls Through Contrast) says:** "do not manufacture fake failures outside Stage 0." All Stage 1+ scripts comply. Stage 0 act-4 (Catch the Bug) manufactures a bug, which is correct per the "outside Stage 0" exception. Consistent.

4. **Teacher-instructions Section 11 (Stage 1) says:** "The demo-then-do pattern: code-work subagent demonstrates, then the developer drives next time." The bug-fix script has the subagent do the fix and the developer observes/verifies. But there is no explicit "now you try" step where the developer drives a second bug fix. The test-writer script similarly has the subagent write tests. **Partial gap:** The "watch then do" is meant to happen across recipe runs (first run of bug-fix = watch, second run = do), but this is not explicitly orchestrated in any script. The scripts assume a single run per session.

### Summary

| Issue | Type | Severity |
|-------|------|----------|
| 4 scripts missing Strong-overwrite protection | Scripts deviate from instructions | High |
| Test-writer mid-task assertion prompt | Script contradicts "don't interrupt" rule | Low |
| "Watch then do" not explicitly orchestrated | Gap in both instructions and scripts | Medium |

---

## 7. Quality Scorecard

Scoring 3 modules against the 10-criterion scorecard from SKILL.md (each criterion 1-10, all must be >=6, total >=70).

### Module A: Bug Fix (Stage 1) -- Early

| # | Criterion | Score | Rationale |
|---|-----------|-------|-----------|
| 1 | Few turns | 9 | 3 dimensions, each 1-2 sentence coaching. Clean. |
| 2 | Clear I/O | 9 | Developer knows: describe bug -> get fix + diff + test results. |
| 3 | Verifiable success | 9 | Dimensions are observable from transcript (what developer said, whether they checked diff). |
| 4 | One skill | 10 | Bug fixing only. No scope creep. |
| 5 | Watch then do | 7 | Subagent demonstrates fix, developer observes. No explicit "now you drive" step in single session. |
| 6 | Minimal domain | 9 | Any bug in any codebase. No specialized domain knowledge needed. |
| 7 | Tool is the aha | 9 | "AI found your bug in 2 minutes" is the wow moment. |
| 8 | Real code | 10 | Uses developer's actual codebase. Stuck path scans for real issues. |
| 9 | Relatable task | 10 | Every developer fixes bugs. |
| 10 | Reusable recipe | 10 | `goose run bug-fix` is genuinely useful daily. |
| **Total** | | **92/100** | **All criteria >= 6. Passes.** |

### Module B: Three-Agent Pipeline (Stage 3) -- Mid

| # | Criterion | Score | Rationale |
|---|-----------|-------|-----------|
| 1 | Few turns | 7 | 4 dimensions across 3 concepts. Checkpoint adds coaching turns. Approaching the limit. |
| 2 | Clear I/O | 8 | Developer designs pipeline -> gets execution log with roles, contracts, results. Clear but complex. |
| 3 | Verifiable success | 8 | Role design, handoff format, safety rails are observable from developer's pipeline sketch. |
| 4 | One skill | 7 | Covers 3 concepts (role specialization, handoff contracts, safety rails). Bundled but thematically unified as "pipeline design." |
| 5 | Watch then do | N/A | Stage 3 is Adaptive+Checkpoints. Not applicable. Score: 8 (developer designs before running). |
| 6 | Minimal domain | 8 | Any multi-step dev task. The pipeline concepts are new but the code domain is the developer's own. |
| 7 | Tool is the aha | 7 | The aha is "three specialized agents > one generalist" but it is a design insight, not a visible speed/power moment like bug-fix. |
| 8 | Real code | 9 | Uses developer's real task. Stuck path finds a suitable task from the repo. |
| 9 | Relatable task | 7 | Multi-agent pipelines are not something most developers do today, but the underlying tasks (spec, build, review) are familiar. |
| 10 | Reusable recipe | 7 | `goose run three-agent-pipeline` is useful for real pipeline design. Less frequently used than bug-fix. |
| **Total** | | **78/100** | **All criteria >= 7. Passes.** |

### Module C: Skill Evolution (Stage 7) -- Late

| # | Criterion | Score | Rationale |
|---|-----------|-------|-----------|
| 1 | Few turns | 8 | 4 dimensions (1 conditional). Fully Adaptive mode means less facilitator-driven turns. |
| 2 | Clear I/O | 7 | Input: cycle review findings + skill files. Output: instruction edits + verification. Clear but depends on prior pipeline output. |
| 3 | Verifiable success | 7 | Finding-to-instruction tracing and edit specificity are observable. Verification intent is binary. Curator loop is hard to assess in one session. |
| 4 | One skill | 8 | "Evolve instructions from findings" is one skill. Covers two concepts but they are tightly coupled (7.1 Curator loop, 7.2 instruction evolution). |
| 5 | Watch then do | N/A | Stage 7 is Fully Adaptive. Developer leads entirely. Score: 9. |
| 6 | Minimal domain | 7 | Requires the developer to have a running pipeline with cycle reviews. High prerequisite but appropriate for Stage 7. |
| 7 | Tool is the aha | 7 | "The system gets smarter on its own" is powerful but abstract. Less visceral than "fixed your bug in 2 minutes." |
| 8 | Real code | 9 | Uses developer's actual pipeline findings. No synthetic exercises. |
| 9 | Relatable task | 6 | Instruction evolution is new to most developers. But "fix the root cause, not the symptom" is deeply relatable. |
| 10 | Reusable recipe | 7 | `goose run skill-evolution` is useful for ongoing pipeline maintenance. |
| **Total** | | **75/100** | **All criteria >= 6. Passes.** |

---

## Top Issues to Fix (Priority Order)

### 1. CRITICAL: Missing Strong-overwrite protection in 4 scripts

**Scripts:** `spec-first.teach.md`, `eval-foundation.teach.md`, `eval-layers.teach.md`, `skill-evolution.teach.md`

**Risk:** Without this rule, a developer who re-runs a recipe could have a Strong rating downgraded to Adequate, losing earned progress.

**Fix:** Add "Never overwrite a Strong rating with a lower one." to the State Update section of each script. One line per file.

### 2. MEDIUM: No state update in Stage 0 scripts

**Scripts:** All 5 Stage 0 act scripts (act-1 through act-5)

**Risk:** No script marks Stage 0 complete. The progression.json shows Stage 0 as a simple complete/incomplete status, but nothing writes it.

**Fix:** Add a State Update section to act-5 (the final act) that marks Stage 0 complete when all 5 acts have run. Alternatively, document that the teach-wrapper handles this externally.

### 3. MEDIUM: Eval JSON schema inconsistency in spec-first

**Script:** `consolidated/teaching/stage-2/spec-first.teach.md`

**Risk:** The `"concept"` field in eval JSON dimensions exists only in this script. If the teach-wrapper or any state management code depends on a uniform schema, this will cause issues.

**Fix:** Either add `"concept"` to all multi-concept eval prompts (three-agent-pipeline, escalation-routing, continuous-dev, skill-evolution) or remove it from spec-first.

### 4. MEDIUM: Bridge uses stage numbers

**Script:** `teaching/stage-6/continuous-dev.teach.md`

**Risk:** Minor fourth-wall crack. Developer hears "Stage 6" and "Stage 7" which are system architecture terms.

**Fix:** Rewrite bridge to use capability language instead of stage numbers.

### 5. LOW: Coaching length exceeds 3-sentence limit

**Script:** `consolidated/teaching/stage-3/three-agent-pipeline.teach.md` -- weak coaching for safety_rails (5 sentences), role_specialization (4 sentences), handoff_contracts (4 sentences + code block)

**Fix:** Condense the safety_rails coaching narrative. The role_specialization and handoff_contracts are borderline acceptable given contrast examples require setup.

### 6. LOW: Quality Dimensions table placement inconsistent

**Scripts:** spec-first puts the table at top of file; all others put dimensions inline in Coaching or in a separate Part.

**Fix:** Pick one convention and standardize. Recommendation: keep dimensions inline in the Coaching section (matching example-module.md), with an optional reference table at top for complex modules (5+ dimensions).

### 7. LOW: "Facilitator Response" naming divergence

**Script:** `teaching/stage-6/continuous-dev.teach.md`

**Fix:** Rename "Facilitator Response" to match the convention used in all other scripts -- either fold it into "The Task" (result presentation) or rename to "Result Presentation" and keep "Coaching" for post-eval.
