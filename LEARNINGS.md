# RILGoose — Technical Learnings

## 2026-04-13 (Overnight Pipeline Results — 20 Cycles)

- **[pipeline] Planner agents over-increment cycle counters.** The Haiku planner subagent repeatedly advanced `current_cycle` in state.json before the cycle actually ran (cycles 12-14). Root cause: the planner was told to "update state.json" without being told that current_cycle should stay at N until the decision-maker finishes. Fix: planner should ONLY set `next_planned`, never touch `current_cycle` or `completed_cycles`.

- **[pipeline] Codex evaluator is the most time-expensive step.** Each Codex eval takes 100-200 seconds vs 90-170s for Opus agent evals. The Codex agent explores the repo extensively before writing its evaluation. Future runs should give Codex a tighter prompt: "write evaluation only, do not explore pipeline state or read prior evaluations."

- **[pipeline] Systematic gaps compound across modules — batch-fix them.** Wait-time insights and enterprise grounding were missing from EVERY module. Each cycle found the same gap in the next module, requiring the same fix 10+ times across cycles 7-18. Future pipeline design should batch-fix structural patterns across all modules at once when first discovered, not one module per cycle.

- **[pipeline] Bucket B auto-promotion at 3 is too slow for module-level patterns.** When every module has the same gap, it takes 3 cycles to promote and N more to apply everywhere. For clearly structural patterns (not persona-dependent), promote immediately and batch-apply.

- **[pipeline] Mock dev persona fidelity degrades after ~60% of every session.** Happened with every mock model (Haiku and GPT 5.4) and every persona. Persona-defining traits (hostility, anxiety, multitasking) concentrate in the first third and default to cooperative-competent. This is fundamental LLM behavior. Future simulations need mid-session persona reinforcement checkpoints.

- **[pipeline] GPT 5.4 (Codex) produces better persona fidelity than Haiku.** GPT 5.4 generates more distinctive, domain-specific responses (Vikram's payment jargon, Sneha's SOC2 vocabulary). Haiku defaults to helpful/cooperative faster. For stress-testing hostile/anxious/quiet personas, Codex is the better mock dev model.

- **[pipeline] Regression cycles must match the mock model to the baseline.** Cycle 19 used Haiku for a Cycle 4 baseline that used GPT 5.4, causing a mock-dev-realism regression that was purely model-dependent, not script-dependent. Match models for clean comparison.

- **[pipeline] "Fully adaptive mode mismatch" is the most impactful bug class.** Appeared in 3 different Stage 5-7 scripts (Cycles 6, 13, 16). The facilitator naturally defaults to guided-adaptive behavior even when the script says "developer drives." The fix — requiring an open question and developer design before any code operation — is the single most important structural change.

- **[pipeline] Privacy/security language must be reviewed for contradictions before pilot.** "Code stays on your machine" + "sends context to the model" (Cycle 15) would fail enterprise security review. All enterprise-facing language needs internal-contradiction review, not just simulation discovery.

- **[orchestration] Decision-maker is the most reliable subagent role.** Structured input (two eval reports + classification rules) produces consistent, reliable output. Simulators vary widely because the task is creative. Evaluators vary based on how much they explore before writing. Decision-makers are deterministic because the rules are explicit.

- **[orchestration] Subagents still use compound commands despite explicit warnings.** Despite "NEVER use && or ||" in every prompt, subagents occasionally use them, causing permission stalls. The most reliable mitigation is global CLAUDE.md rules, but subagent prompts should still include the warning since subagents don't inherit parent CLAUDE.md.

- **[orchestration] Codex writes files to the repo when you just want stdout evaluation.** Codex agents (via codex_review.py) often create evaluation files directly in the repo rather than returning text to stdout. This is sometimes useful (saves a Write step) but sometimes creates untracked files that need cleanup. Be explicit in prompts: "return your evaluation as text, do NOT write files."

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
