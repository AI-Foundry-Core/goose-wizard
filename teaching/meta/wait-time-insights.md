# Wait-Time Insights — Master Index

The facilitator draws from these insights during subagent wait times (30+ seconds). Each module's teaching script references this file for the ordered list. Insights are shared immediately after launching the subagent, one per wait, in order.

When the current module's list is exhausted, revisit insights from previous modules — check progression state to skip Strong-rated themes and prioritize Weak/Adequate ones. Reword for the current context; never repeat verbatim.

See `teacher-instructions.md` Section 13 for the full framework rules.

---

## Stage 0: See What AI Can Do

These insights preview practices the developer will build in Stage 1+. They plant seeds without teaching — the developer hears them, files them away, and recognizes them later.

| # | Insight | Tag | Wait Point |
|---|---------|-----|------------|
| 0.1 | "While it's working — one thing you'll notice is that the first result is rarely the final one. AI is fast, but the real workflow is iterative. First pass, review, adjust, second pass. That cycle is where the quality comes from." | `[iteration]` | Act 1: codebase scan |
| 0.2 | "Something to keep in mind — the more specific you are when you ask for something, the better the result. That's true for every AI tool. Vague in, vague out." | `[specificity]` | Act 2: improvement scan |
| 0.3 | "While it's looking — one habit worth building early: after any change, run the tests. AI writes confident code, but confident and correct aren't the same thing." | `[verify]` | Act 4: bug planting |
| 0.4 | "This works with whatever tools you already use — Jenkins, GitLab, VS Code, whatever your team runs. The AI just edits files on disk. Same files git tracks, same files your pipeline builds." | `[enterprise]` | Act 1: answer question (optional, if wait is long enough) |
| 0.5 | "While it works on that — notice how much more specific your instruction was that time. That gap between vague and specific? It shows up in everything AI does, not just code edits." | `[specificity]` | Act 5: specific request execution |

**Revisit pool for later stages:** Reword 0.1-0.3 in the context of whatever task the developer is doing. For example, 0.1 during test-writing becomes: "First round of tests is a draft — the second round is where the real coverage comes from."

---

## Stage 1: Get Real Work Done

Four recipes, each with 3-4 wait points. Insights are specific to the recipe but draw from cross-cutting themes and the Reference Guide Material.

### Recipe 1.1: Bug Fix

| # | Insight | Tag | Wait Point |
|---|---------|-----|------------|
| 1.1a | "While it investigates — the quality of the fix usually tracks with the quality of the description you gave it. Symptom, location, what you tried. The more it knows upfront, the fewer passes it needs." | `[specificity]` | Stuck-path scan or recipe execution |
| 1.1b | "Something to watch for with bug fixes — AI loves wrapping things in try/catch to make the error go away. That's not fixing the bug, that's hiding it. The diff will tell you which one happened." | `[verify]` | Recipe execution |
| 1.1c | "One pattern you'll see — if AI is going in circles after two or three attempts, the fix isn't 'try again.' It's changing the angle. Different context, different file, different theory about the cause." | `[redirect]` | Eval subagent |
| 1.1d | "Reading code is the safest thing AI does. Writing code is riskier. Restructuring code is riskier still. Bug fixes sit in the middle — keep that in mind when deciding how much to verify." | `[risk-ladder]` | Fourth wait point (if reached) |

### Recipe 1.2: Test Writer

| # | Insight | Tag | Wait Point |
|---|---------|-----|------------|
| 1.2a | "While it writes — one thing to watch: AI-generated tests that all pass on the first try aren't always a good sign. Sometimes they pass because they don't actually test anything meaningful. A test that can't fail is worse than no test." | `[verify]` | Recipe execution |
| 1.2b | "Scope matters a lot here. Pointing AI at one function gets you focused, meaningful tests. Pointing it at a whole module gets you shallow coverage of everything and deep coverage of nothing." | `[specificity]` | Stuck-path scan or recipe execution |
| 1.2c | "The first round of tests is a starting point, not the finished product. The real coverage comes from the iteration — fix the failures, add the edge cases, tighten the assertions. Second pass is always better." | `[iteration]` | Eval subagent |
| 1.2d | "Think of test writing as defining what 'correct' means before you ship. That habit — defining success criteria upfront — shows up everywhere once you start building bigger things." | `[define-success]` | Fourth wait point (if reached) |

### Recipe 1.3: Code Review

| # | Insight | Tag | Wait Point |
|---|---------|-----|------------|
| 1.3a | "While it reviews — AI defaults to polite. A review that says 'looks good' isn't necessarily a green light. It might just mean you didn't ask the right question. Specific focus gets specific findings." | `[specificity]` | Recipe execution |
| 1.3b | "One thing that makes AI review powerful — you can run it multiple times with different focus areas. Security pass, logic pass, performance pass. Each one finds things the others missed. That's how review scales without adding people." | `[review-scales]` | Stuck-path scan or recipe execution |
| 1.3c | "AI reviews mix real bugs with style opinions with outright mistakes. Your job is triage — which findings matter, which are noise, which are wrong. That judgment is the skill." | `[verify]` | Eval subagent |
| 1.3d | "Every change AI makes shows up as a normal diff in your PR. Your reviewers see the same thing they always see. Nothing about the review process changes for the rest of the team." | `[enterprise]` | Fourth wait point (if reached) |

### Recipe 1.4: Refactor

| # | Insight | Tag | Wait Point |
|---|---------|-----|------------|
| 1.4a | "While it refactors — baseline tests first, always. If you don't know what was passing before, you can't tell what the refactor broke." | `[verify]` | Recipe execution |
| 1.4b | "'Clean it up' is a vague instruction. 'Split this into two functions — one for validation, one for processing' is a specific one. Same AI, wildly different results. The goal definition is everything." | `[specificity]` | Stuck-path scan or recipe execution |
| 1.4c | "Refactoring is the riskiest thing on the AI task ladder. Reading is safe, writing is medium, restructuring can introduce subtle behavioral changes that tests don't catch. That's why you check the diff line by line." | `[risk-ladder]` | Eval subagent |
| 1.4d | "One pattern from teams that do this well — small refactors, committed individually. One function at a time. Each one verified before the next. It's slower per step but safer overall." | `[iteration]` | Fourth wait point (if reached) |

---

### Future Additions

Stage 2+ insights will add coverage for `[specialization]` (first appears at Stage 2), `[feedback-loops]` (deepens at Stage 6), and `[define-success]` deepening (Stage 4). These tags have no insights in the current pool — the revisit mechanism cannot reinforce them until Stage 2+ teaching scripts are written.

---

## Revisit Variants

When revisiting insights from earlier stages in a new context, use these reworded variants. The concept is the same; the framing matches the current work.

| Original | Revisit Context | Reworded Variant |
|----------|----------------|------------------|
| 0.1 (iteration) | During test writing | "First round of tests is a draft. The iteration — fix failures, add edge cases, tighten assertions — that's where real coverage comes from." |
| 0.1 (iteration) | During refactoring | "Refactoring usually takes two passes. First pass restructures, second pass catches the subtle things the restructuring shifted." |
| 0.2 (specificity) | During code review | "Same thing applies to reviews — 'review this code' gets you surface-level findings. 'Check this PR for security issues in the auth flow' gets you real findings." |
| 0.2 (specificity) | During refactoring | "Telling AI 'clean this up' is like telling a junior dev 'make it better.' Define the goal — extract a function, remove the dependency, whatever — and the result matches." |
| 0.3 (verify) | During code review | "Same instinct as running tests after a fix — don't trust a clean review at face value. Ask a follow-up: 'what could go wrong under load?' or 'what edge cases did you miss?'" |
| 0.3 (verify) | During refactoring | "After a refactor, running tests isn't enough by itself. The diff might show a subtle behavioral change that the tests don't cover. Both checks matter." |
| 1.1c (redirect) | During test writing | "If the tests keep failing in the same way, don't just retry. Change the approach — different function, smaller scope, or describe the expected behavior differently." |
| 1.1d (risk-ladder) | During refactoring | "Restructuring is the top of the risk ladder. That's not a reason to avoid it — just a reason to verify more carefully than you would for a simple read or write." |
