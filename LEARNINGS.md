# RILGoose — Technical Learnings

## 2026-04-12

- **[goose-architecture] Working recipes run standalone, teach-wrapper is optional.** Goose's sub-recipe system lets the teach-wrapper invoke a working recipe as a sub-recipe. The working recipe has zero teaching code. After training, `goose run bug-fix` runs the clean recipe directly. The teach-wrapper adds facilitator + eval subagent around it. This separation is confirmed by Goose's recipe mechanics — sub-recipes are reusable YAML components invoked by name.

- **[goose-architecture] Eval subagent can run async in background.** Goose's `delegate(async: true)` spawns background tasks (up to 5 concurrent). Parent continues immediately, checks results later. This confirms our eval-after-task pattern works: facilitator continues conversation, eval subagent rates quality in background, facilitator reads result and decides what to coach.

- **[goose-architecture] No built-in progression tracking.** Goose has no state/progression API. Each recipe run is stateless. We must build progression ourselves — JSON state file tracking which concepts are demonstrated per developer, at what quality rating. This is custom work, not a Goose feature.

- **[courseforge-to-adaptive] Fourth wall rule carries over.** CourseForge's "never mention you're following a script" rule applies equally to adaptive teaching. The facilitator should never say "the eval subagent rated your context quality as weak." It should say "next time, also mention what you already tried." The machinery is invisible.

- **[courseforge-to-adaptive] "Watch then do" survives as "see it work, then try yourself."** CourseForge's demonstration-first pattern translates to: facilitator sets up the task, code-work subagent does the first pass while developer watches, then developer does the next one themselves. Still valid in adaptive mode.

- **[courseforge-to-adaptive] Exact script adherence drops, but simplicity rule stays.** Drop verbatim Say: blocks and rigid check gates. Keep: domain tasks should be trivially simple so the "aha" is the tool capability, not the content complexity. Keep: few turns (1-3 major interactions), clear I/O, one skill per exercise.

- **[courseforge-to-adaptive] Module previews maintain momentum.** End each recipe/stage with a 2-3 sentence bridge to what's next. This survived from scripted to adaptive unchanged. The bridge sentences in the syllabus (e.g., "imagine if a second AI did that for you") serve this function.

- **[courseforge-drop] Rigid check gates replaced by quality ratings.** CourseForge's "Check: STOP and WAIT" gates were binary — did the student do it or not. Our model rates HOW WELL they did it. The gate is now "all quality dimensions adequate or strong" not "student typed something."

- **[courseforge-quality-scorecard] 10-criterion rubric maps to module design, not eval.** The exercise quality scorecard (few turns, clear I/O, verifiable success, one skill, watch-then-do, minimal domain knowledge, aha is the tool, synthetic data, relatable scenario, mirrors structure) applies when DESIGNING modules, not when evaluating developer work. These criteria should go into the module designer skill file.
