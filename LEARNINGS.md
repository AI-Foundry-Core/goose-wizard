# RILGoose — Technical Learnings

## 2026-04-12 (Session 2 — Install, Config, Validation)

- **[goose-install] Windows install via PowerShell script.** `Invoke-WebRequest -Uri "https://raw.githubusercontent.com/aaif-goose/goose/main/download_cli.ps1" -OutFile "download_cli.ps1"; .\download_cli.ps1`. Installs to `C:\Users\<user>\.local\bin\goose.exe`. The interactive configure step fails with "not connected" on first install — expected, provider must be configured manually afterward.

- **[goose-install] ACP adapter package is `@agentclientprotocol/claude-agent-acp`.** NOT `@zed-industries/claude-agent-acp` (old name in some docs) or `@anthropics/claude-agent-acp` (doesn't exist). Install: `npm install -g @agentclientprotocol/claude-agent-acp@0.26.0`. Binary lands at `C:\Users\<user>\AppData\Roaming\npm\claude-agent-acp.cmd`.

- **[goose-config] Provider config goes at top of config.yaml.** File: `C:\Users\<user>\AppData\Roaming\Block\goose\config\config.yaml`. Add `GOOSE_PROVIDER: claude-acp` and `GOOSE_MODEL: default` before the `extensions:` block. Model `default` = Opus, `sonnet` and `haiku` also available. Verify with `goose info -v`.

- **[goose-config] Claude ACP requires Claude CLI authenticated.** The ACP adapter wraps `claude` CLI, so `claude --version` must work. Uses existing Claude Max subscription — no API keys needed.

- **[goose-recipe-validation] Template syntax is parameter substitution only.** Goose supports `{{ param_name }}` but NOT `{{ if }}...{{ endif }}` conditionals. The validator reports "Missing definitions for parameters: endif" when it encounters these. Optional params render as their default value (empty string for `default: ""`).

- **[goose-recipe-validation] File params cannot have defaults.** `input_type: file` with `requirement: optional` + `default: ""` fails validation: "File parameters cannot have default values to avoid importing sensitive user files." Fix: change to `input_type: string` for optional file paths. Required file params are fine.

- **[goose-recipe-validation] `input_type: text` is invalid.** Goose expects `string`, not `text`. Also `select` is not valid — use `string` instead. Valid types: `string`, `number`, `boolean`, `date`, `file`.

- **[goose-recipe-validation] Optional params MUST have defaults.** "Optional parameters missing default values" is a validation error. Every `requirement: optional` param needs an explicit `default:` field.

- **[goose-recipe-validation] `goose recipe validate <path>` is the truth test.** Run this on every recipe before considering it done. It catches parameter mismatches, invalid types, missing defaults, and template syntax issues that static review misses.

## 2026-04-12 (Session 1 — Design and Generation)

- **[goose-architecture] Working recipes run standalone, teach-wrapper is optional.** Goose's sub-recipe system lets the teach-wrapper invoke a working recipe as a sub-recipe. The working recipe has zero teaching code. After training, `goose run bug-fix` runs the clean recipe directly. The teach-wrapper adds facilitator + eval subagent around it. This separation is confirmed by Goose's recipe mechanics — sub-recipes are reusable YAML components invoked by name.

- **[goose-architecture] Eval subagent can run async in background.** Goose's `delegate(async: true)` spawns background tasks (up to 5 concurrent). Parent continues immediately, checks results later. This confirms our eval-after-task pattern works: facilitator continues conversation, eval subagent rates quality in background, facilitator reads result and decides what to coach.

- **[goose-architecture] No built-in progression tracking.** Goose has no state/progression API. Each recipe run is stateless. We must build progression ourselves — JSON state file tracking which concepts are demonstrated per developer, at what quality rating. This is custom work, not a Goose feature.

- **[courseforge-to-adaptive] Fourth wall rule carries over.** CourseForge's "never mention you're following a script" rule applies equally to adaptive teaching. The facilitator should never say "the eval subagent rated your context quality as weak." It should say "next time, also mention what you already tried." The machinery is invisible.

- **[courseforge-to-adaptive] "Watch then do" survives as "see it work, then try yourself."** CourseForge's demonstration-first pattern translates to: facilitator sets up the task, code-work subagent does the first pass while developer watches, then developer does the next one themselves. Still valid in adaptive mode.

- **[courseforge-to-adaptive] Exact script adherence drops, but simplicity rule stays.** Drop verbatim Say: blocks and rigid check gates. Keep: domain tasks should be trivially simple so the "aha" is the tool capability, not the content complexity. Keep: few turns (1-3 major interactions), clear I/O, one skill per exercise.

- **[courseforge-to-adaptive] Module previews maintain momentum.** End each recipe/stage with a 2-3 sentence bridge to what's next. This survived from scripted to adaptive unchanged. The bridge sentences in the syllabus (e.g., "imagine if a second AI did that for you") serve this function.

- **[courseforge-drop] Rigid check gates replaced by quality ratings.** CourseForge's "Check: STOP and WAIT" gates were binary — did the student do it or not. Our model rates HOW WELL they did it. The gate is now "all quality dimensions adequate or strong" not "student typed something."

- **[courseforge-quality-scorecard] 10-criterion rubric maps to module design, not eval.** The exercise quality scorecard (few turns, clear I/O, verifiable success, one skill, watch-then-do, minimal domain knowledge, aha is the tool, synthetic data, relatable scenario, mirrors structure) applies when DESIGNING modules, not when evaluating developer work. These criteria should go into the module designer skill file.
