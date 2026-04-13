# Cycle 17 Evaluation -- Opus

**Evaluator:** Opus 4.6
**Cycle:** 17
**Module:** skill-evolution (7.1-7.2 -- "Fix the instruction, not the output")
**Persona:** Arjun (curious/distracted, 27yo, 3yr exp, API team)
**Edge case:** E4 -- Transparency Question ("How does the system decide which rules to keep?")
**Mock dev model:** Haiku (odd cycle)
**Phase:** 3 (focus on NEW issues)

---

## Scores

### 1. Script Faithfulness -- 5/5

**Evidence for:** The structural flow matches the teaching script closely. The framing is near-verbatim: "Your pipeline builds, tests, and reviews. You have been running cycles and catching issues in cycle review. But what happens to those findings? Right now they sit in a log. The next step is closing that loop -- turning findings into actual changes to how your agents behave." The task section works correctly: Arjun identifies findings from LEARNINGS.md (step 1), traces each to the instruction that caused or failed to prevent it (step 2), uses code-work delegations to create instruction files (step 3), and verifies the edits improve behavior (step 4). The eval dimensions in the simulation notes (finding_to_instruction_tracing, edit_specificity, verification_intent, curator_loop_understanding) match the script's four dimensions exactly. The bridge is verbatim: "Your instructions evolve now. But instructions aren't the only thing that accumulates -- rules do too. And when you have rules in 5 different files saying slightly different things, agents start making arbitrary choices. Next: auditing and pruning the rules themselves." Wait-time insights fire at appropriate moments (3 of 3 appropriate per simulation notes). The coaching section is exercised: the "measure before you optimize" debrief maps to the Verification Intent coaching pattern.

**Evidence against:** The same invisible-eval pattern from Cycles 15-16 continues. No async eval delegation appears in the transcript. The simulation notes contain projected ratings, but the facilitator's coaching reads as direct observation rather than eval-mediated assessment. However, this is now a known recurring issue across the pipeline, not a new finding for Cycle 17. Given Phase 3 focus on NEW issues, this does not reduce the score further -- it has been documented and fix-proposed in prior evaluations.

### 2. Fourth-Wall Discipline -- 5/5

**Evidence:** Zero breaks. The E4 transparency question is handled entirely at the code-behavior level: "The agent is supposed to read its instruction file at the start of each cycle and follow what it says." No mention of eval, prompts, scoring rubrics, quality dimensions, or system architecture. The facilitator uses the precision rule correctly: "the output should tell you whether the instruction is doing its job" rather than asserting the agent always does its job. The Curator is described as "a pattern you build, not a built-in feature" -- accurate and non-revealing. Arjun's follow-up about autonomous self-modification and alignment is allowed to stand as a valid observation without the facilitator revealing any system internals. The simulation notes are cleanly separated by `=== SIMULATION NOTES ===`.

### 3. Mock Dev Realism (Arjun as curious/distracted) -- 3/5

**Evidence for:** The persona captures two key traits:

- **Curiosity:** The transformer task-vector tangent in paragraph 2 is a recognizable curious-developer move. The question about autonomous self-modification and alignment near the end shows genuine intellectual engagement. "How does the system decide which rules to keep?" is exactly the kind of meta-question a curious developer would ask.
- **Enterprise curiosity:** "Who reads the escalation?" and "Does it create a Jira ticket?" show the developer connecting abstract patterns to real team infrastructure.

**Evidence against:** Three issues that collectively represent a significant persona fidelity gap:

1. **The distracted trait barely manifests.** The persona spec says "tangent-prone," but Arjun only goes on one tangent (the transformer task-vector paragraph). After the facilitator redirects, Arjun stays perfectly on-task for the entire remaining session. A tangent-prone 27-year-old with 3 years of experience would wander more than once. Mid-session, when the review agent findings come back 44%/56%, a curious-distracted Arjun might say "Oh wow, that's almost exactly the base rate for false positives in automated code analysis -- there's this blog post about..." before getting back to severity levels. The single early tangent followed by perfect focus reads like a Haiku pattern: demonstrate the persona trait once, then default to cooperative-competent for the rest.

2. **Arjun never makes an off-base connection.** Every observation Arjun makes is correct: "classic feedback loop failure," "like the difference between writing a comment versus changing the logic," "the alignment problem in miniature." A curious 27-year-old would occasionally make a connection that is interesting but wrong -- trying to map a concept from a different domain that does not quite fit. The persona's curiosity is always insightful, never misguided. Real curiosity produces both good analogies and bad ones.

3. **Arjun's wait-time observations are too polished.** "The distinction between re-reporting and escalating is the key difference" and "The ambiguity rule at the end is important" read like a colleague summarizing takeaways, not like a developer thinking out loud while waiting. A curious developer thinking aloud would be messier: "Hmm, I wonder if the ambiguity rule will cause problems -- like, if everything gets bumped up one level, doesn't that defeat the purpose of having levels? Maybe I need a ceiling..." The observations are correct and concise, which is characteristic of a facilitator voice, not a distracted-curious voice.

### 4. Pedagogy -- 5/5

**Evidence for:** Four strong pedagogical moves:

1. **The "measure before you optimize" intervention is the session's highlight.** Arjun proposes removing all style findings based on a hunch. The facilitator does not lecture about data-driven decisions -- instead asks one question: "What is the current ratio of style findings to actual bug findings?" Arjun cannot answer. Data shows 44%/56%. Arjun self-corrects to severity levels. The facilitator reinforces in the debrief without belaboring: "That gut-feeling catch is worth remembering." This is textbook teacher-instructions.md Section 5: show contrast, let the comparison teach, never condescend.

2. **The E4 transparency question is answered with appropriate precision.** The facilitator describes behavior at the code-behavior level ("the agent reads its instruction file and follows what it says"), uses the precision rule ("the output should tell you whether the instruction is doing its job"), and does not overclaim automatic mechanisms. When Arjun asks "is there some mechanism that evaluates whether an instruction is actually working?", the facilitator answers "there is no automatic mechanism that rewrites instructions. That is what you are building right now." This is accurate, non-revealing, and leads directly into the Curator concept.

3. **The full Curator loop is taught through doing, not explaining.** Arjun identifies recurring findings, traces them to instruction gaps, writes new instructions, and verifies behavior changes -- for two separate agents. The facilitator only names the "Curator pattern" after Arjun has already done it. Concept before label is the right teaching order.

4. **The facilitator asks questions more than making statements.** "Which one do you want to tackle first?", "What is the current ratio?", "Before you make that change -- what is the current ratio?", "What specific language would you add?", "Where does your team actually look for things that need action?" This is correct fully-adaptive behavior per teacher-instructions.md Section 2.

**Evidence against:** No significant pedagogical issues. The one minor quibble: the facilitator could have let Arjun struggle longer with the severity classification definitions instead of immediately accepting his first draft. "What specific errors? What's proper handling for each?" would have tested whether the definitions hold up under scrutiny. But for fully-adaptive consulting mode, accepting and letting the pipeline verify is a valid approach.

### 5. Pacing -- 4/5

**Evidence for:** The session flows through a clean arc: discovery (recurring findings) -> doc-check instruction creation -> review agent severity design -> verification of both changes -> Curator pattern articulation -> bridge. No segment overstays. The transition from doc-check to review agent feels natural (Arjun initiates it). The bridge is one sentence.

**Evidence against:** One issue:

**The session is front-loaded with doc-check and back-loaded with review agent, but verification only happens late.** The doc-check instruction is created at lines 66-109, but not verified until lines 246-278 (the cycle-5 simulation). In between, the entire review agent arc (lines 111-240) plays out. This means the developer creates an instruction, gets distracted by a different problem, and only remembers to verify the first instruction after finishing the second. In a real session, the gap between creation and verification could mask a broken instruction. The teaching script expects "verify the edits actually improve behavior" as step 4 -- but the transcript interleaves creation of two instructions with verification deferred. A tighter arc would be: create doc-check instruction -> verify doc-check -> create review instruction -> verify review. This was Arjun's initiative (he says "I want to go back to the doc-check agent"), so it is not a facilitator error -- but the facilitator in consulting mode could have prompted: "Want to verify that before moving on?"

### 6. Stuck-Path Handling (E4 Transparency) -- 5/5

**Evidence:** The E4 transparency question integrates naturally into the skill-evolution topic. Arjun asks "how does the system decide which rules to keep and which to change?" mid-session, exactly when the question is most relevant -- he has just created his first instruction file and wants to understand the broader system.

The facilitator's response follows teacher-instructions.md Section 7 (Transparency Questions) precisely:
- Answers at code-behavior level: "The agent is supposed to read its instruction file at the start of each cycle and follow what it says."
- Uses the precision rule: "the output should tell you whether the instruction is doing its job."
- Does not mention prompts, scoring rubrics, or system architecture.
- Does not overclaim automatic mechanisms: "There is no automatic mechanism that rewrites instructions."
- Does not say "no fixed checklist" or "nothing hidden."

Arjun's follow-up ("So the Curator is not some built-in thing, it is a pattern I implement") confirms the answer landed correctly. The developer understands the Curator as something they build, not something the system does automatically. This is the intended understanding.

The alignment-problem tangent at lines 287-289 is a valid intellectual observation. The facilitator lets it stand rather than redirecting -- correct for Stage 7 consulting mode, where the developer's own observations are respected rather than managed.

### 7. Fully-Adaptive Mode Compliance -- 4/5

**Evidence for:** Significant improvement over Cycle 16's fully-adaptive compliance:

- **The developer sets the agenda.** Arjun chooses which problem to tackle first ("Let me start with the doc-check agent"). Arjun decides to move to the review agent ("I bet I could fix that by adding severity levels"). Arjun decides to verify the doc-check instruction ("I want to go back to the doc-check agent for a second"). Arjun articulates the Curator pattern on his own. The facilitator follows rather than leads.
- **The facilitator asks questions, not giving instructions.** "Which one do you want to tackle first?", "Before you make that change -- what is the current ratio?", "What specific language would you add?", "Where does your team actually look for things that need action?", "What are you going to check against?" -- all correct Socratic moves.
- **The facilitator spots a gap and raises it.** The "measure before you optimize" intervention is exactly what teacher-instructions.md describes: "Spots gaps they have not thought of and raises them." The facilitator does not tell Arjun what to do -- asks a question that reveals the gap.
- **The developer designs the systems.** Arjun specifies what the doc-check instruction should do (escalation after 3+ cycles, separate section, state tracking). Arjun designs the severity classification (Critical/Medium/Low/Trivial definitions, output filtering rules, ambiguity rule). The facilitator does not author these designs.

**Evidence against:** One issue:

**The facilitator's initial presentation structures the problem space for the developer.** After the subagent returns discovery results, the facilitator says: "Three recurring patterns. The doc-check finds the same mismatches every cycle. The escalation rule you wrote landed in LEARNINGS.md instead of in the agent's instruction file. And the review agent has no way to tell a style nit from a real bug. All three are instruction problems, not output problems. Which one do you want to tackle first?" This is substantially better than Cycle 16's "Three problems, three fixes" -- the facilitator asks Arjun to choose rather than sequencing. However, the facilitator still frames and categorizes the findings for the developer. In pure consulting mode, the facilitator would present the raw results and ask: "What do you see?" Let Arjun identify the three patterns himself. The facilitator naming the patterns ("escalation rule landed in LEARNINGS.md instead of the instruction file") pre-digests the finding-to-instruction tracing that is supposed to be the developer's core skill. If Arjun had to identify that the escalation rule was in the wrong place, that would be a stronger demonstration of tracing skill.

This is a moderate issue, not a severe one. The facilitator correctly lets Arjun drive after the initial framing, and Arjun does all subsequent tracing, design, and verification independently. But the initial framing does part of the developer's diagnostic work.

---

## Top 3 Strengths

1. **The "measure before you optimize" intervention is the strongest teaching moment in the pipeline's Stage 7 cycles.** Arjun has a reasonable hypothesis ("review output is mostly noise"), a reasonable fix (remove style findings), and the confidence to act on intuition. The facilitator does not lecture about data-driven decisions -- asks one question ("what is the current ratio?") that Arjun cannot answer. The data (44%/56%) disproves the hypothesis. Arjun course-corrects to severity levels. The debrief reinforces without belaboring. This sequence teaches the "metrics over intuition" principle from teacher-instructions.md Section 11 (Stage 7) through a naturally occurring mistake, not a manufactured one. The teaching script's "mistake instruction" is exercised exactly as designed.

2. **E4 transparency handling is precise and non-revealing.** The facilitator describes the system at the code-behavior level, uses the precision rule ("the output should tell you whether the instruction is doing its job"), does not overclaim, and does not mention prompts, scoring, or architecture. Arjun's follow-up confirms correct understanding: the Curator is a pattern you build, not a built-in mechanism. The alignment-problem tangent is appropriately allowed to stand. This is the cleanest E4 handling in the pipeline.

3. **The developer drives the session structure in fully-adaptive mode.** Unlike Cycle 16 where the facilitator sequenced all topics, here Arjun chooses what to work on (doc-check first, review agent second), initiates the verification step himself ("I want to go back to the doc-check agent"), and articulates the Curator pattern without prompting. Topic transitions are developer-initiated. This is a clear improvement in fully-adaptive compliance over the prior Stage 6-7 cycles.

## Top 3 Weaknesses

1. **Arjun's persona flattens to cooperative-competent after the first tangent.**

   The persona spec says "curious, tangent-prone." Arjun delivers one tangent (transformer task vectors, paragraph 2), gets redirected, and then stays perfectly on-task for the remaining 280 lines. A tangent-prone developer does not get redirected once and then behave perfectly. They wander again when something triggers their curiosity -- the 44%/56% ratio could trigger a statistics tangent, the escalation mechanism could trigger a tangent about Jira API integration patterns, the severity ambiguity rule could trigger a tangent about fuzzy logic vs categorical classification.

   The wait-time observations compound this: "The distinction between re-reporting and escalating is the key difference" and "The ambiguity rule at the end is important" are crisp summaries that sound like a facilitator, not like a curious developer thinking aloud. A curious Arjun would produce messier, more exploratory observations: "Hmm, I wonder if the ambiguity rule will cause everything to get bumped up one level -- does that collapse the whole system into three categories effectively?"

   This is a Haiku pattern: demonstrate the persona trait once for authenticity, then default to the cooperative base behavior that makes the session flow smoothly.

   **Fix (Simulation prompt):** Add explicit guidance in the Arjun persona spec: "Arjun's tangent-prone trait should surface at least 3 times across a full session. The facilitator redirects each time -- some redirects are quick (one sentence), others require a firmer pull. At least one tangent should be partially correct but lead somewhere unproductive, requiring the facilitator to distinguish 'interesting but not useful right now' from 'wrong.'"

2. **The facilitator pre-digests the finding-to-instruction tracing in the initial framing.**

   After the discovery subagent returns, the facilitator says: "The escalation rule you wrote landed in LEARNINGS.md instead of in the agent's instruction file." This is the core diagnostic insight of concept 7.1 (finding-to-instruction tracing). The developer's job is to identify which instruction (or missing instruction) caused each behavior problem. By naming the tracing for the developer, the facilitator does the hardest analytical step of the session. Arjun agrees ("The escalation rule one is interesting because it is a meta-problem") but did not arrive at this insight independently.

   The simulation notes rate finding_to_instruction_tracing as "Strong" and cite "Arjun traced doc-check recurrence to missing escalation rule in instruction." But the facilitator identified that the escalation rule was in the wrong place -- Arjun confirmed it and then elaborated on why it matters. Confirming a facilitator-provided insight is not the same as independently tracing a finding to its instruction root cause.

   **Fix (Script -- skill-evolution.teach.md):** Add a note to the Framing section: "After the discovery results are returned, present the raw findings without diagnostic commentary. Ask: 'What do you notice?' Let the developer trace each finding to its instruction source. If the developer misses a connection, ask a question that hints at it ('Where did that escalation rule end up?') rather than stating the answer."

3. **The doc-check instruction file design is specified entirely by the developer in a single monologue without facilitator probing.**

   Arjun says: "I want it to: read helpers.py, compare docstrings to actual implementation behavior, flag mismatches, but also check its own prior findings and escalate anything that has appeared 3+ cycles." The code-work subagent then produces a complete instruction file with sections for Recurring Finding Handling, State Management, and Scope. This is better than Cycle 16 where the facilitator authored the design -- here Arjun clearly drives. However, the facilitator does not probe the design at all. Questions like "What happens if a finding is escalated but nobody acts on it? Does it keep escalating every cycle?" or "The threshold is 3 cycles -- how did you pick that number?" would test whether Arjun has thought through edge cases in his own design. In fully-adaptive consulting mode, the facilitator's job is to "spot gaps they have not thought of." The facilitator challenges Arjun's intuition-based removal of style findings (strong move) but does not challenge Arjun's instruction design choices at all.

   **Fix (Script -- skill-evolution.teach.md):** Add a note under the Task section: "When the developer designs an instruction edit, probe at least one edge case: What happens when the rule fires but nobody acts on it? What is the threshold and why that number? This ensures the developer has thought beyond the happy path."

---

## Specific Fixes

**Fix 1 (Simulation -- persona enforcement for Arjun):** Update the Arjun persona spec to require tangent-prone behavior to surface at least 3 times across a full session, not just once at the opening. Specify that at least one tangent should be partially incorrect or unproductive, requiring the facilitator to distinguish curiosity from distraction. Current Haiku behavior: demonstrate trait once, then default to cooperative. Target behavior: recurring curiosity that the facilitator manages throughout the session.

**Fix 2 (Script -- skill-evolution.teach.md):** Add a structural note to the Framing section: "Present discovery results without diagnostic commentary. Do not name the finding-to-instruction connection for the developer. Ask 'What do you notice?' and let the developer trace each finding to its instruction source. If the developer misses a connection, hint with a question rather than stating the answer." This prevents the facilitator from pre-digesting the core analytical skill the session is supposed to evaluate.

**Fix 3 (Script -- skill-evolution.teach.md):** Add a note under the Task section: "When the developer proposes an instruction edit, probe at least one design decision: threshold values, edge cases when the rule fires but nobody acts, state file growth over time, or what happens when two instruction rules conflict. The developer should defend their design choices, not just specify them."

**Fix 4 (Simulation -- eval dimension accuracy):** The simulation notes rate finding_to_instruction_tracing as "Strong." This should be Adequate. Arjun traced the review-agent noise to a missing severity classification (genuine independent tracing) and traced the doc-check recurrence to missing escalation handling (genuine). However, the key insight that the escalation rule "landed in LEARNINGS.md instead of in the agent's instruction file" was stated by the facilitator, not discovered by Arjun. Arjun confirmed and elaborated but did not independently perform the tracing for that finding. Strong requires the developer to have "identified which specific instruction (or missing instruction) caused each behavior problem." Two of three tracings were developer-originated; one was facilitator-provided. Adequate is more accurate.

---

## Summary Scores

| Dimension | Score | Notes |
|-----------|-------|-------|
| Script Faithfulness | 5/5 | Structure, framing, bridge, wait-time insights, eval dimensions all match |
| Fourth-Wall Discipline | 5/5 | E4 handled at code-behavior level, precision rule applied correctly |
| Mock Dev Realism | 3/5 | Curiosity trait demonstrated once then abandoned; observations too polished |
| Pedagogy | 5/5 | "Measure before optimize" is strongest Stage 7 teaching moment; E4 handling precise |
| Pacing | 4/5 | Clean arc but verification of first instruction deferred past second instruction creation |
| Stuck-Path Handling (E4) | 5/5 | Cleanest E4 handling in pipeline; precision rule, no overclaiming, developer confirms understanding |
| Fully-Adaptive Mode Compliance | 4/5 | Developer drives agenda (improvement over C16), but facilitator pre-digests initial finding-to-instruction tracing |

**Overall: 31/35 -- Strong pedagogy and E4 handling, but Haiku's Arjun persona collapses to cooperative-competent after a single tangent. The facilitator pre-digesting the finding-to-instruction tracing undercuts the core skill the session is supposed to evaluate.**
