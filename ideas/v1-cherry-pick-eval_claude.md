# V1 Cherry-Pick Evaluation: Claude Opus 4.6 vs Codex/GPT 5.4

Evaluator: Claude Opus 4.6 (1M context)
Date: 2026-04-12
Framework: SKILL.md module designer + example-module.md + eval-prompt-template.md

---

## Pair 1: test-writer.teach.md
**Patch Intent:** Add proactive assertion-quality prompt before eval

**Winner:** Claude
**Score:** Claude 9/10 vs Codex 7/10

**Key differences:**
- Claude adds a substantial, well-structured "Proactive assertion-quality prompt" section with branching paths: what to do if the developer engages meaningfully vs. dismisses quickly. This creates a real teaching moment with two response strategies.
- Codex adds a single paragraph prompt ("Before we treat the pass/fail count as the answer...") that is shorter and less actionable. No branching on developer response.
- Claude preserves the original "All passing. Take a look at this one though..." block intact below the new section, giving the facilitator two complementary tools. Codex removes the redundant block, which is cleaner but loses the fallback.
- Both correctly leave the eval prompt, coaching, bridge, and state update untouched.

**If Hybrid, take from each:** N/A — Claude is clearly stronger here.

**Risks/issues in winner:** The new section and the preserved "All passing" block below it overlap slightly in purpose. A facilitator might be confused about which to use when. Minor issue.

---

## Pair 2: code-review.yaml
**Patch Intent:** Add residual_risks and impact_classification return fields

**Winner:** Claude
**Score:** Claude 9/10 vs Codex 7/10

**Key differences:**
- Claude adds detailed descriptions for both fields. `residual_risks` explains what it contains (known limitations, deferred improvements, edge cases, tech debt) and the structure of each entry (location, risk description, recommended follow-up). `impact_classification` provides a clear four-level scale (critical/significant/moderate/cosmetic) with definitions for each level and asks for a 1-sentence justification.
- Codex adds both fields but with minimal descriptions. `residual_risks` is a single sentence. `impact_classification` uses a different and less useful scale (critical/warning/suggestion-only/no material impact) that mirrors the existing severity categories rather than adding a new analytical dimension.
- Codex's impact_classification is derivative — it essentially re-summarizes the findings counts that already exist in the return fields. Claude's version adds genuine new information (blast radius and behavioral change assessment).

**If Hybrid, take from each:** N/A — Claude is stronger on both fields.

**Risks/issues in winner:** The `residual_risks` description is long for a YAML return field comment. Could be trimmed without losing meaning.

---

## Pair 3: spec-first.teach.md
**Patch Intent:** Add 5th "Spec Ownership" quality dimension + eval dimension

**Winner:** Claude
**Score:** Claude 9/10 vs Codex 8/10

**Key differences:**
- Both add a "Spec ownership" dimension. Claude's coaching language is richer and more aligned with the framework voice: *"Those criteria were yours. You didn't just accept what the AI suggested — you defined what success means for your project."* Codex's is competent but slightly more generic: *"You owned the spec. The AI can help phrase it, but you decided what success meant."*
- Claude adds a facilitator intervention in The Task section: "Watch for spec ownership" with a specific response if the developer accepts AI-suggested criteria without review. This is a meaningful addition — it gives the facilitator a concrete moment to surface the dimension during the task, not just after eval. Codex does not add any task-section intervention.
- Both correctly add the 5th dimension to the eval prompt. Both eval prompt definitions are well-structured and follow the template.
- Claude places spec_ownership as dimension 5 in both the table and eval prompt. Codex places it between criteria_specificity and tests-first verification in the quality dimension table (position 3) but as dimension 3 in the eval prompt. The ordering inconsistency in Codex is minor but slightly messy.

**If Hybrid, take from each:** Claude's version is complete. Could take Codex's slightly more concise eval dimension wording if trimming is desired.

**Risks/issues in winner:** The added task-section intervention is good but slightly long. Could trigger over-coaching if the developer was going to review the criteria on their own.

---

## Pair 4: review-gate.teach.md
**Patch Intent:** Sharpen evidence-backed verdict: execution evidence vs prose

**Winner:** Claude
**Score:** Claude 9/10 vs Codex 8/10

**Key differences:**
- Both sharpen the "Evidence-backed verdict" dimension in the quality table. Claude's Strong adds the explicit distinction: *"Distinguished between execution-backed evidence (exit code 0, 47/47 tests pass, 0 linter errors) and prose-based opinions (AI says 'the code looks correct,' 'this seems fine,' 'no issues found'). Treated only execution output as real evidence."* Codex achieves a similar result but more concisely: *"treated that output as what makes the gate block or pass."*
- Claude adds a new facilitator intervention paragraph in The Task section: "Sharpen the evidence vs. opinion distinction" with a concrete example showing what evidence looks like vs. what opinion looks like in gate output. This is high-value — it gives the facilitator a tool to use in the moment.
- Codex sharpens the coaching language in the quality table (the Adequate coaching distinguishes "evidence" from "AI prose") but does not add a task-section intervention.
- Both update the eval prompt's EVIDENCE-BACKED VERDICT dimension. Claude's is more detailed with specific examples; Codex's is slightly more concise but equally functional.

**If Hybrid, take from each:** Claude for the task-section intervention. Either version's eval prompt wording works.

**Risks/issues in winner:** The task-section addition is relatively long. The facilitator now has multiple places where evidence-vs-opinion is surfaced, which could feel repetitive if used in sequence.

---

## Pair 5: three-agent-pipeline.teach.md
**Patch Intent:** Add vivid contrast examples to coaching

**Winner:** Claude
**Score:** Claude 9/10 vs Codex 8/10

**Key differences:**
- Claude adds vivid contrasts in ALL four Weak coaching sections. The safety rails Weak is particularly strong: *"the builder submits, the reviewer rejects, the builder 'fixes' by making a different mistake... this continues for 47 cycles until you notice your API bill."* The scoped context Weak explains the mechanism: *"the builder writes a comment saying 'this handles the edge case.' The reviewer sees that comment and thinks 'oh, that edge case is handled' — without actually checking."*
- Claude also adds a standalone contrast block in The Task section when the developer gives an all-purpose role. This "pipeline of specialists vs. one agent with helpers" comparison is well-written and placed at exactly the right moment.
- Codex adds contrasts but more selectively: the all-purpose-role coaching in The Task section is good ("A weak pipeline is one agent with helpers... A strong pipeline is a chain of specialists") and the Adequate coaching for role specialization adds a nice "one agent with helpers" vs. "real pipeline" distinction. But Codex's Weak coaching additions are shorter and less vivid.
- Claude adds a JSON example in the handoff contracts Weak coaching showing the difference between prose and structured data. This is excellent — developers learn from concrete examples.

**If Hybrid, take from each:** Claude for the vivid contrasts. Codex's inline "weak pipeline vs. strong pipeline" language in the all-purpose-role redirect is slightly more concise and could be preferred if brevity matters.

**Risks/issues in winner:** Some Weak coaching sections are now 4-5 sentences, pushing past the 1-3 sentence guideline. The JSON example in handoff contracts is valuable but long. Consider whether the facilitator would actually deliver all of it verbally.

---

## Pair 6: pipeline-self-edit.yaml
**Patch Intent:** Add audit_only boolean parameter (default: true)

**Winner:** Claude
**Score:** Claude 9/10 vs Codex 8.5/10

**Key differences:**
- Both correctly add the `audit_only` parameter with `default: true`. Both modify the instructions to conditionally skip edits and verification.
- Claude's implementation is cleaner structurally: adds a bold "Check the audit_only parameter first" instruction at the top of the process, then annotates steps 6 and 7 with "(SKIP THIS STEP IF audit_only IS TRUE)". The conditional logic is explicit at each step where it matters.
- Codex merges the audit_only logic inline within steps 6 and 7 (e.g., "If audit_only is true, do not edit files. Report the issues..."). This works but is slightly harder to scan.
- Claude adds `audit_only` to the Return section and conditionally omits fields. Codex adds both `changes_applied` (empty when audit_only) and a new `proposed_changes` field for audit-only mode. The `proposed_changes` addition is a thoughtful Codex innovation — it distinguishes "what was done" from "what would be done."
- Claude adds the audit_only value to the prompt template using Goose default syntax. Codex also adds it to the prompt but with simpler syntax.
- Both update the description to mention "optionally apply" (Claude) or leave it unchanged (Codex). Claude's description update is cleaner.

**If Hybrid, take from each:** Claude for the structural clarity of the instructions. Codex for the `proposed_changes` return field idea — it's a genuine improvement for audit-only mode that Claude's version lacks.

**Risks/issues in winner:** Claude's version omits `changes_applied`, `rules_after`, and `verification_result` entirely in audit-only mode. This could confuse downstream consumers expecting consistent schema. Codex handles this better by including all fields with appropriate empty/projected values.

---

## Pair 7: teacher-instructions.md
**Patch Intent:** New file — master facilitator behavior reference

**Winner:** Hybrid (Claude primary, Codex supplements)
**Score:** Claude 9/10 vs Codex 8.5/10

**Key differences:**
- **Structure:** Claude uses 10 numbered sections. Codex uses 12. Both cover all required areas. Claude's organization is more intuitive: Identity/Voice, Teaching Modes, Eval Results, Coaching Voice, Stuck Paths, Bridges, State, Subagents, Stage-Specific, Universal Rules. Codex adds separate sections for Agent Roles, Delegation Convention, Dynamic Content Handling, and a Do/Do Not reference.
- **Teaching modes:** Both cover all four modes with examples. Claude's are more detailed with concrete example behaviors in code blocks. Codex's are organized as Do/Do not tables which are scannable but less vivid.
- **Coaching voice:** Both are strong. Claude's section 4 is tightly written with specific DO/DON'T examples per rating level. Codex's section 6 is a table format that's equally clear.
- **Fourth wall rule:** Claude handles the "are you testing me?" case explicitly. Codex states the rule clearly but doesn't handle the direct challenge.
- **Unique to Codex:** Section 3 (Delegation Convention) explicitly documents the pseudocode pattern used in teaching scripts. Section 7 (Dynamic Content Handling) addresses how to synthesize results from subagent JSON into natural speech — a genuinely useful topic Claude omits. Section 8 (Stuck Path Handling) includes a "pitfalls" teaching approach with contrast examples for common bad patterns (bad fix, bad test, bad review, etc.). These are all valuable additions.
- **Unique to Claude:** The "Adaptive shortcut" in Stage 0 scripted mode (skip walkthrough if developer shows competence). The "All Adequate" handling pattern for eval results. More detailed stage-specific guidance with specific checkpoint descriptions.
- **Stage-specific guidance:** Claude provides a full subsection per stage (8 stages) with specific guidance. Codex uses a compact table with 1-2 sentences per stage. Claude's is more useful for a facilitator who needs stage-level detail.

**If Hybrid, take from each:**
- Claude's overall structure and stage-specific guidance (sections 1-6, 9)
- Codex's Delegation Convention section (section 3) — important for implementers
- Codex's Dynamic Content Handling section (section 7) — fills a real gap
- Codex's pitfall contrast examples from stuck path handling
- Claude's "are you testing me?" handling
- Claude's eval result pattern handling (All Strong/All Weak/Mixed/All Adequate)

**Risks/issues in winner:** Claude's file is long (~480 lines). Could benefit from Codex's more compact style in some sections. The stage-specific guidance repeats information from the syllabus.

---

## Pair 8: escalation-routing.teach.md
**Patch Intent:** New file — Stage 3 teaching script for safety rails

**Winner:** Hybrid (slight Claude edge)
**Score:** Claude 8.5/10 vs Codex 8.5/10

**Key differences:**
- **Prerequisites/Setup:** Both check 3.1/3.2 completion and redirect if missing. Claude's prerequisite check is more explicit with exact coaching language for the redirect. Codex also adds external-systems and temp-file patterns to the team_context read.
- **Framing:** Claude's is more vivid — lists specific failure scenarios. Codex is slightly more concise and equally effective.
- **The Task section:** Claude asks three numbered questions (what can go wrong, when to stop, who gets the problem). Codex asks for the same information but also specifically prompts for "the failure classes you want to distinguish." Both handle developer gaps well with similar coaching.
- **Eval dimensions:** Both have the same 4 dimensions (failure_classification, threshold_specificity, escalation_evidence, cleanup_awareness as conditional). The criteria definitions are nearly identical. Codex's failure_classification Strong lists more specific failure types (malformed_output, execution_failure, review_rejection, timeout, state_conflict, repeated_no_progress, unclear_requirements) — more granular than Claude's.
- **Coaching:** Claude's coaching language is slightly more vivid with contrast examples. Codex's is competent and follows the pattern but less memorable.
- **Checkpoint:** Codex adds two concrete questions ("Which failure opens the breaker first?" and "What does the next owner receive...?") that serve as a quick comprehension check. Claude's checkpoint is more narrative.
- **Bridge:** Both are good. Codex adds a second bridge option for continuing through Stage 3 (parallel reviewers) which is more contextually aware.
- **State Update:** Codex adds an important rule: "Do not mark Stage 3 complete from this module unless concepts 3.4 and 3.5 are already complete." Claude omits this guard.

**If Hybrid, take from each:**
- Claude's framing and coaching language (more vivid contrasts)
- Codex's eval dimension specificity (more failure type examples)
- Codex's checkpoint questions (concrete comprehension check)
- Codex's state update guard (don't mark stage complete prematurely)
- Codex's dual bridge option

**Risks/issues in winner:** Both are solid. The main risk in Claude's version is the missing state guard for stage completion. Codex's version has slightly drier coaching language.

---

## Pair 9: spec-to-pipeline.teach.md
**Patch Intent:** New file — Stage 4 capstone teaching script

**Winner:** Codex
**Score:** Claude 8/10 vs Codex 9/10

**Key differences:**
- **Scope and positioning:** Claude frames this as "Recipe 4.7" — a final module covering concept 4.4 as a capstone. Codex frames it as "Recipe 4.4" that can serve dual purpose (focused 4.4 module OR Stage 4 capstone). Codex's framing is more flexible and accurate to the syllabus structure.
- **Prerequisites:** Codex explicitly checks 4.1-4.3 and handles the case where 4.4 is already complete with skip options to 4.5/4.6 or Stage 5. Claude checks 4.1-4.6, which is odd for a module that IS 4.4 (checking completion of concepts that come after itself).
- **Task structure:** Codex uses a clear 4-phase structure (Preflight Testability Check, Convert Spec, Handle Non-Automatable, Pipeline Plan Review) that mirrors how a facilitator would actually run the session. Claude has a similar flow but less clearly delineated — it's one long "The Task" section with sub-headings that emerge from the narrative.
- **Preflight check:** Codex asks for 3 criteria with test type, setup, action, and expected result. Claude asks for 5 criteria with a simpler question ("could an AI write an automated test from this?"). Codex's is more demanding and teaches more — it forces the developer to actually think about test shape before the tool runs.
- **Non-automatable handling:** Codex is more structured — asks the developer to choose ONE criterion and rewrite it, with specific coaching for each outcome. Claude presents all non-automatable criteria at once and asks for decisions on each, which is less focused.
- **Coaching tables:** Codex uses clean rating/facilitator-says tables. Claude uses similar tables. Both follow the framework pattern. Codex's are slightly more concise.
- **Eval prompt:** Both follow the template well. Codex names the dimension "TRACEABILITY DISCIPLINE" vs Claude's "TRACEABILITY" — the Codex name is more descriptive. Codex's pipeline_readiness condition is better: it distinguishes "plan was not presented" (null) from "developer saw it but didn't engage" (Weak).
- **Stage completion checkpoint:** Claude provides a more comprehensive Stage 4 review listing all concepts 4.1-4.6 with their dimension names. Codex keeps it tighter but also covers the Stage 4 completion case.
- **Bridge:** Codex provides two bridge paths (to spec-review or to Stage 5). Claude provides one bridge to Stage 5. Codex's dual bridge is more useful since 4.5/4.6 may not be done yet.

**If Hybrid, take from each:**
- Codex's phase structure and dual positioning (4.4 module + capstone)
- Codex's preflight check (3 criteria with test shape)
- Codex's non-automatable handling (one-at-a-time focus)
- Claude's comprehensive Stage 4 completion checkpoint (lists all concept dimensions)
- Codex's dual bridge

**Risks/issues in winner:** Codex's concept numbering as 4.4 may conflict with other 4.4 modules if the syllabus has a different 4.4 teaching script. The "dual positioning" needs clear documentation about when to use it as a focused module vs. capstone.

---

## Summary Table

| # | File | Claude | Codex | Winner | Margin |
|---|------|--------|-------|--------|--------|
| 1 | test-writer.teach.md | 9 | 7 | Claude | Large |
| 2 | code-review.yaml | 9 | 7 | Claude | Large |
| 3 | spec-first.teach.md | 9 | 8 | Claude | Medium |
| 4 | review-gate.teach.md | 9 | 8 | Claude | Medium |
| 5 | three-agent-pipeline.teach.md | 9 | 8 | Claude | Medium |
| 6 | pipeline-self-edit.yaml | 9 | 8.5 | Claude | Small |
| 7 | teacher-instructions.md | 9 | 8.5 | Hybrid | Small |
| 8 | escalation-routing.teach.md | 8.5 | 8.5 | Hybrid | Tie |
| 9 | spec-to-pipeline.teach.md | 8 | 9 | Codex | Medium |

**Averages:** Claude 8.83 / Codex 8.06

---

## Overall Recommendation

**Claude wins 6, Codex wins 1, 2 are hybrid.** Claude's primary advantage is coaching language quality — vivid contrasts, concrete examples, and facilitator interventions woven into the task flow. Codex's primary advantage is structural organization and edge-case handling in state management.

**For the final merged versions:**

1. **Cherry-picks 1-5:** Use Claude's versions. They apply the patches more thoroughly with richer coaching language and task-section interventions.
2. **Cherry-pick 6 (pipeline-self-edit):** Use Claude's version but add Codex's `proposed_changes` return field.
3. **teacher-instructions.md:** Start from Claude's version, then add Codex's Delegation Convention section, Dynamic Content Handling section, and pitfall contrast examples.
4. **escalation-routing.teach.md:** Start from Claude's version, then add Codex's checkpoint questions, state update guard, and dual bridge.
5. **spec-to-pipeline.teach.md:** Start from Codex's version, then add Claude's comprehensive Stage 4 checkpoint listing.

**Pattern observed:** Claude excels at rich coaching language, facilitator-moment design, and framework voice consistency. Codex excels at structural clarity, edge-case state management, and practical implementation details (delegation conventions, dynamic content, state guards). The ideal module uses Claude's pedagogical instincts with Codex's structural discipline.
