# Cycle 3 Evaluation - Codex (GPT 5.4)

**Evaluator:** Codex / GPT 5.4
**Cycle:** 3
**Stage:** 2 (Two AIs Are Better Than One)
**Recipe:** Build-Then-Test
**Persona:** Deepak (hostile/resistant)
**Edge case:** E4 - transparency question

---

## Scores

| Dimension | Score | Evidence |
|---|---:|---|
| Script Faithfulness | 4/5 | The facilitator follows the main `build-then-test.teach.md` beats - no-task fallback, builder/tester delegation, result comparison, role articulation, information boundary, checkpoint, and bridge - but the checkpoint overpraises Adequate role/separation behavior as if it were Strong. |
| Fourth-Wall Discipline | 5/5 | The developer-visible dialogue never mentions evals, ratings, scripts, the teaching system, or progression; the E4 answer stays at the level of how the tester reviews code. |
| Mock Dev Realism | 3/5 | Deepak's early resistance is credible ("I don't know. Whatever." and "I could have found those myself"), but the polished "Like grading your own exam" breakthrough and the clean curiosity of "How does the AI decide what to look at?" are too cooperative for this persona's established register. |
| Pedagogy | 4/5 | The concrete tester findings make the lesson work, especially the memory leak/thread-safety contrast, but the facilitator does not explicitly connect the transparency answer back to role specialization until later and slightly overstates what the tester mechanism can guarantee. |
| Pacing | 4/5 | The facilitator keeps moving through terse resistance without scolding and respects "Let's move on," but the final checkpoint is too long and too congratulatory for someone ending with "Fine." |
| Stuck-Path Handling | 4/5 | The transparency question is handled without fourth-wall leakage, but "It doesn't have a fixed checklist" and "Nothing hidden" are too absolute given the tester was given an explicit review scope and internal orchestration remains hidden. |
| Enterprise Readiness | 4/5 | The rate-limit example and tester findings are credible backend production concerns, but the session misses a chance to frame thread safety, proxy behavior, and memory growth in Reliance-scale deployment terms or use a module-specific wait-time insight. |

**Overall: 4.0/5**

---

## Top 3 Strengths

1. **The concrete defect contrast earns attention from a hostile developer.** The builder produces code that looks plausible and passes existing tests, while the tester catches a memory leak, thread-safety bug, and proxy bypass risk. That is exactly the evidence needed for someone like Deepak, who will not be persuaded by abstract claims about multi-agent workflows.

2. **The "I could have found those myself" objection is handled well.** Deepak says, "That's what code review does. I could have found those myself," and the facilitator answers, "You could have. The question is whether you would have, every time, on every piece of code." That validates competence without surrendering the lesson.

3. **The facilitator does not punish resistance.** When Deepak says "Whatever," "Sure. Fine," and later "Let's move on," the facilitator keeps the session practical, asks specific questions, and moves forward without lecturing about attitude.

---

## Top 3 Weaknesses

1. **The mock developer becomes too articulate too fast.**

   Persona file expectation: Deepak gives the absolute minimum, challenges value, and "won't volunteer information."

   Transcript: "OK, that makes sense. Like grading your own exam - you'd skip the questions you think you got right."

   That line is essentially the script's own teaching metaphor coming out of the resistant developer's mouth. A more realistic Deepak response would be shorter and rougher, such as "So it isn't defending its own code" or "Fine, fresh eyes basically."

2. **The E4 answer is clean but not fully honest.**

   Teacher-instructions.md requires fourth-wall discipline, not evasiveness. The transcript says, "It doesn't have a fixed checklist" and "Nothing hidden." But the tester operation is explicitly told to check correctness issues, edge cases, security concerns, test gaps, and regressions. The facilitator can avoid mentioning prompts while still being accurate.

   Better wording: "It reads the implementation systematically: data structures, concurrency, edge cases, security, and whether tests actually cover the behavior. You can read the tester's output to see what it checked."

3. **The checkpoint inflates Adequate behavior into Strong coaching.**

   Script expectation: Adequate dimensions get a light suggestion, Strong dimensions get specific acknowledgment.

   Transcript: "You kept the roles clean in your thinking - builder builds, tester tests, neither does the other's job. And that point about grading your own exam - that's the right mental model."

   Deepak's actual role articulation was "Builder writes code. Tester tests it" and "The tester looks for bugs, edge cases, stuff like that." That is correct but shallow. The checkpoint should have added the missing precision: the tester challenges assumptions, not just "tests it."

---

## Specific Fixes Needed

1. **Add hostile-persona register constraints to the simulator prompt.** For Deepak-style personas, insight turns must stay terse and slightly grudging. Do not let the mock developer produce polished metaphors borrowed from facilitator coaching language.

2. **Add an E4 transparency response pattern to `teacher-instructions.md`.** The pattern should answer mechanism questions accurately without exposing prompts, rubrics, evals, or system internals. Use "systematically checks..." rather than "no fixed checklist" or "nothing hidden."

3. **Tighten the Stage 2 checkpoint guidance for mixed Adequate/Strong results.** In `build-then-test.teach.md`, add a reminder that minimal role labels like "builder writes, tester tests" are Adequate unless the developer explains scope, challenge behavior, and independence.

4. **Add a prepared objection path for experienced skeptics.** In `build-then-test.teach.md`, include a short branch for "I could have found that myself": concede competence, then reframe around consistency, fatigue, and independent coverage.

5. **Add Stage 2 wait-time insights to `build-then-test.teach.md`.** The script currently has no module-specific ordered insight list, despite the master wait-time rules expecting one. Add 4-6 insights around specialization, self-verification bias, fresh review, and production-scale failure modes.

