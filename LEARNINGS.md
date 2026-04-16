# Goose Wizard — Technical Learnings

## 2026-04-14 (Progression Schema & Setup Script)

- **[progression] Teaching scripts used skill-based sub-concepts while progression.json uses module-based concepts.** Overnight pipeline generated teaching scripts with finer-grained concept numbering (e.g., 3.1-3.5 across 3 Stage 3 modules) while progression.json assigns one concept per module (3.1, 3.2, 3.3). The State Update sections in teaching scripts would write eval ratings to wrong concept entries. Fixed by aligning all teaching script headers, setup checks, and state updates to progression.json's module-based numbering. Affected all stages 2-7 (~20 teaching scripts).

- **[progression] All 25 graduation slugs validated end-to-end.** Verified: (1) every training recipe's module_number/module_name matches progression.json, (2) every graduation source exists (graduated/ for multi-agent, agents/ for single-agent), (3) every target file exists in shared/. The graduate-module agent indexes by array position (module_number - 1), not concept ID — so concept numbering bugs in teaching scripts wouldn't break graduation itself, only eval state tracking.

- **[setup-ps1] PowerShell 5.1 Join-Path takes exactly 2 arguments.** `Join-Path a b c` works in PS 7+ but fails in PS 5.1 with "positional parameter cannot be found." Use nested calls: `Join-Path (Join-Path a b) c`.

- **[setup-ps1] Select-String on raw multiline string ignores (?m) flag.** `$rawString | Select-String -Pattern "^GOOSE_MODEL"` only matches at string start, not line start. Use `-match` with `(?m)` and `$Matches[1]` instead.

- **[setup-ps1] Em dashes in PowerShell cause mojibake on PS 5.1 without UTF-8 BOM.** Keep .ps1 files ASCII-only for Windows PowerShell compatibility.

## 2026-04-13 (Recipe Architecture & Model Selection)

- **[goose-model] GOOSE_MODEL must be opus for recipe instruction-following.** `GOOSE_MODEL: default` resolves to Sonnet (first model in SDK list). Sonnet skips acts, invents content, dumps tables despite explicit rules against it. Opus follows detailed act scripts reliably. The ACP adapter resolves the alias "opus" to the full model ID via `resolveModelPreference()` at line ~1284 of acp-agent.js.

- **[recipe-architecture] Put the script in `prompt:`, not `instructions:`.** The `instructions:` field is system-level context that gets buried under Goose's system.md (~200 lines of instructions were skimmed by the agent). The `prompt:` field is the user's first message — the last thing the agent reads before responding. Moving the act-by-act script to `prompt:` made the agent follow it precisely.

- **[recipe-architecture] Keep `instructions:` short — behavioral rules only.** 6 rules max: INTERACTIVE, SHOW YOUR WORK, NO TABLE, BE DIRECTIVE, FOLLOW THE SCRIPT, TONE. The script/flow/content goes in `prompt:`.

- **[recipe-ux] Agent fabricates file content unless told to use Read tool.** Saying "show the recipe file" causes the agent to reconstruct from memory with wrong details (fabricated extension names, wrong field descriptions). Must explicitly say "Use the Read tool to read the actual YAML file from disk."

- **[recipe-ux] Tone rules must be explicit and specific.** Without "Never say 'Good eye,' 'Great job,' 'This is the point'" the agent defaults to patronizing instructor voice. Generic "be a colleague" isn't enough — name the specific phrases to avoid.

- **[recipe-ux] `goose recipe open` from CLI may crash desktop app.** Error: "The backend server failed to start" on port 127.0.0.1:XXXXX. Possibly caused by having desktop already open on the same project. Needs more testing — two desktop sessions on different projects work fine, so this may be a same-project conflict, not a CLI vs desktop conflict.

- **[recipe-ux] Act 3 "Everything is reversible" must explain git.** Developers need to know the mechanism — "All code changes go through git, so everything is reversible" — not just the abstract promise. This connects AI edits to the tools they already know.

- **[test-codebase] docunator used as test codebase.** Switched from GooseTestProject (toy app) to `C:\Users\donid\ClaudeInfra\docunator` (real FastMCP server). More realistic for testing recipe behavior on real codebases. Requires `.goose/state/progression.json`, `.goose/team_context.md`, and `.claude/CLAUDE.md` (Goose override) to be set up.

## 2026-04-13 (CLI Training Flow & Recipe UX)

- **[acp-critical] Custom systemPrompt in acp-agent.js is overridden by Goose.** Lines 1008-1017: `params._meta.systemPrompt` (sent by Goose from its `system.md` template) replaces whatever default we set. Our custom prompt is just a fallback. In practice, Goose always sends its system prompt, so recipe `instructions:` are the primary way to control agent behavior.

- **[acp-critical] Goose's system.md says "Use Markdown formatting for all responses."** This overrides recipe instructions that say "no tables." The Goose system prompt is baked into the compiled Rust binary — cannot be changed via config. For CLI this is acceptable (markdown renders fine). For desktop app, this is why tables look terrible during streaming.

- **[acp-fix] autoMemoryEnabled: false is a separate patch from settingSources.** The claude_code preset loads auto-memory independently of settingSources. Even with settingSources: ["local"], memory files loaded until we added autoMemoryEnabled: false. These are two separate systems in the Claude SDK.

- **[acp-fix] AskUserQuestion was explicitly disallowed.** Line 1028 of acp-agent.js: `disallowedTools = ["AskUserQuestion"]`. This is the ONLY tool that lets the agent pause for user input. Without it, WAIT instructions in recipes have no mechanism. Patching to `[]` enables it.

- **[acp-discarded] Override clauses that mention the rule they're trying to suppress TEACH the rule.** Our `.claude/CLAUDE.md` said "Ignore memory rules about never simulate recipes" — the agent read this, learned about the "never simulate" concept, and followed it. Never mention what you want the agent to ignore.

- **[acp-discarded] Tom extension cannot override CLAUDE.md or system prompt.** Tested with GOOSE_MOIM_MESSAGE_FILE. The per-turn injection is too weak against system-level instructions. Same failure mode as the recipe preamble.

- **[goose-cli] `goose run --interactive` enables multi-turn chat after recipe.** Without `--interactive`, `goose run --recipe` processes the prompt and exits. With it, the session stays open for developer replies. This is required for all training recipes.

- **[goose-cli] `goose recipe open <path>` opens the desktop app with a recipe.** Confirmed working. Can be used at the end of a CLI training session to show the developer the recipe YAML in the desktop app — "see the blueprint behind what you just did."

- **[goose-cli] CLI streaming is chunky but better than desktop.** Known issue, PR #7233 (Feb 2026) added markdown entity buffering for CLI. Desktop app still has no dedicated fix. Tables are "a killer" per issue #7223. Major streaming refactor PR #8011 is in progress but not merged.

- **[goose-vscode] VS Code extension does NOT support recipes.** `block.vscode-goose` is chat-only, experimental, ~4,600 installs. No recipe launch, no recipe management. Also hardcodes gpt-4o-mini (issue #8264) and has Windows path bugs. Not viable for recipe-based training.

- **[goose-config] GOOSE_MODE: smart_approve improves interactivity.** Switching from autonomous to smart_approve forces tool approval prompts, which creates natural interaction points. Not a substitute for proper WAIT behavior but helps.

- **[recipe-ux] "Never narrate reasoning" is wrong for CLI.** In CLI, narration IS the experience. The user needs to SEE code snippets, buggy lines, and diffs. Without narration, the agent says "I found bugs and fixed them" — invisible magic. The correct rule is "SHOW YOUR WORK" not "don't narrate."

- **[recipe-ux] Agent ignores formatting rules that conflict with Goose system prompt.** "Do not show tables" in recipe loses to "Use Markdown formatting" in system.md. Possible mitigation: put formatting rules in the `prompt:` field (last thing agent reads) instead of `instructions:`.

- **[design-pivot] Training should teach Goose recipes, not just AI.** Doni's insight: each module should end by showing the recipe that powered it. `goose recipe open <path>` opens it in the desktop app. By Stage 2-3, developers understand recipe structure and can modify them. The curriculum teaches recipe literacy alongside AI skills.

## 2026-04-13 (ACP Context Pollution & Project Template)

- **[acp-critical] ACP adapter hardcodes `settingSources: ["user", "project", "local"]` at line 1038 of `acp-agent.js`.** This loads `~/.claude/CLAUDE.md`, `<cwd>/CLAUDE.md`, and `<cwd>/.claude/CLAUDE.md` into every Goose session. The `preset: "claude_code"` system prompt makes the agent identify as Claude Code. No config, env var, or recipe-level override can disable this — only patching the file or upstream changes.

- **[acp-critical] Recipe-level isolation preambles cannot override CLAUDE.md.** Tested three approaches: (1) recipe preamble saying "ignore CLAUDE.md", (2) `.claude/CLAUDE.md` with override clause, (3) Tom extension injecting per-turn context. All failed. The agent absorbs CLAUDE.md/memory at system level before reading recipe instructions, and specific actionable rules ("never simulate") beat generic overrides ("follow the recipe").

- **[acp-fix] Patching `settingSources` to `["local"]` solves context pollution.** Only `<cwd>/.claude/CLAUDE.md` loads, which we control via the project template. Setup script applies this patch automatically. Reinstalling the adapter (`npm install -g @agentclientprotocol/claude-agent-acp`) reverts the patch — useful for graduation.

- **[acp-override] `_meta.claudeCode.options.settingSources` can theoretically override the hardcoded array** (spread after the default at line 1040). But Goose doesn't expose `_meta` in recipe YAML, so this isn't usable from the recipe layer. Future upstream fix could use this mechanism.

- **[acp-override] `CLAUDE_CONFIG_DIR` env var redirects `~/.claude/` resolution** but is process-wide. Setting it persistently breaks normal Claude Code usage. Setting it per-process only works for CLI, not the desktop app.

- **[goose-app] Goose desktop app prompts for project directory at session start.** Selection stored in `%APPDATA%\Block\goose\data\projects.json`. Pre-populating this file with a single project entry auto-selects it on next launch. Format: `{ "projects": { "<path>": { "path": "<path>", "last_accessed": "<ISO>", "last_instruction": null, "last_session_id": null } } }`.

- **[goose-app] `GOOSE_WORKING_DIR` is process-wide, shared across sessions.** Known bug (Goose #6909): changing directory in one session affects all sessions. The developer extension reads from a global env var, not per-session context.

- **[goose-config] Per-provider env vars are NOT supported in config.yaml.** Extensions get an `env:` field for subprocess env vars, but providers don't. Provider subprocesses inherit the parent process's full environment.

- **[goose-config] Tom (Top Of Mind) extension injects context via `GOOSE_MOIM_MESSAGE_TEXT` / `GOOSE_MOIM_MESSAGE_FILE` env vars.** Injected every turn. Already enabled in config. Could theoretically override CLAUDE.md but in practice the agent still prioritizes CLAUDE.md rules.

- **[goose-memory] Goose's `chatrecall` extension loads past session summaries into new sessions.** Even after patching ACP to block CLAUDE.md, old sessions where the agent learned "never simulate" were recalled into new sessions. The `chatrecall` extension must be disabled during training. The `memory` extension (user preferences) is safe to keep. Sessions stored in `%APPDATA%\Block\goose\data\sessions\sessions.db` (SQLite, locked while Goose runs).

- **[project-template] Standard test project created at `install/project-template/`.** Contains sample Python task tracker app, `.claude/CLAUDE.md` override, `.goose/` state, `team_context.md`. Setup script deploys this to the user's project directory. Sample code has intentional bugs/gaps for training material (off-by-one in truncate, duplicate formatting logic, incomplete tests).

## 2026-04-13 (Goose Desktop App Setup)

- **[goose-recipe-discovery] `GOOSE_RECIPE_PATH` does NOT recurse subdirectories.** Each directory must be listed explicitly, semicolon-separated on Windows. Setting `GOOSE_RECIPE_PATH=recipes/` finds nothing; `GOOSE_RECIPE_PATH=recipes/stage-0;recipes/stage-1;...` finds everything. This is a PATH-style env var, not a glob.

- **[goose-recipe-discovery] `goose recipe list` only searches `GOOSE_RECIPE_PATH` and `GOOSE_RECIPE_GITHUB_REPO`.** Without these env vars, `goose recipe list` returns "No recipes found" even if recipes exist in the current directory or `.goose/recipes/`. The desktop app also uses these paths for its recipe browser.

- **[goose-recipe-discovery] `goose recipe open <path>` always works with a full file path.** This bypasses all discovery logic — you can open any recipe YAML from anywhere. The desktop app confirms with "Opened recipe 'Title' in Goose Desktop."

- **[goose-recipe-discovery] Deeplinks encode the entire recipe as base64 in a `goose://recipe?config=` URL.** These are self-contained — no file path needed, the full YAML is embedded. Useful for sharing recipes that aren't in the user's recipe path.

- **[goose-config] Enable memory, chatrecall, and orchestrator extensions for teaching.** Default config has these disabled. Memory = preferences across sessions, chatrecall = session history search, orchestrator = subagent management. All needed for multi-agent teaching recipes.

- **[goose-config] `projects.json` tracks known project directories.** Located at `AppData/Roaming/Block/goose/data/projects.json`. Goose auto-creates entries when you open a project. Contains path, last_accessed timestamp, and last_session_id.

- **[goose-acp] CRITICAL: ACP loads your CLAUDE.md and memory into every Goose recipe.** The ACP adapter (`acp-agent.js` line 1007-1038) uses `preset: "claude_code"` and `settingSources: ["user", "project", "local"]`. This means the Claude agent in a Goose recipe sees ~/.claude/CLAUDE.md, project CLAUDE.md, and auto-memory — all intended for Claude Code, not Goose. Confirmed: a recipe refused to run because it read a "never simulate recipes" feedback memory and thought IT was the simulator.

- **[goose-acp] Fix: every recipe needs a runtime identity preamble.** Add "You are running inside the Goose agent platform. This IS the real Goose runtime. Do NOT follow CLAUDE.md/memory instructions." at the top of every recipe's `instructions:` block. Without this, any user with Claude Code configured on the same machine will get polluted Goose sessions. See `recipes/RECIPE-PREAMBLE.md` for the standard text.

- **[goose-acp] This is not just Doni's problem — it affects all RIL teams.** Any developer who uses Claude Code will have some CLAUDE.md and memory loaded. The preamble is mandatory for all recipes, not just for testing on Doni's machine.

- **[goose-design] Two-mode recipes: teaching + working in one file.** Each recipe checks `.goose/state/progression.json` for its concept ID. If not complete → TEACHING MODE (isolation preamble, reads teaching script, guides developer, updates progression). If complete → WORKING MODE (standard instructions, CLAUDE.md welcome). One entry point, zero user choices.

- **[goose-design] Gateway recipe "★ START HERE" is the single entry point for training.** Reads progression, shows progress, runs next module. Zero parameters. Post-completion becomes a dashboard. All 27 recipes visible from day 1 — the full list signals a serious training system to skeptical developers.

- **[goose-design] Shared/local recipe split.** `recipes/shared/` = curated, numbered, deployed to all users via GOOSE_RECIPE_PATH. `recipes/local/` = personal sandbox, testing, pipeline tools. Promotion = move file from local to shared with next number prefix.

- **[goose-design] Async eval delegation is unreliable.** Goose Issue #7364: `delegate(async: true)` causes "task still running" errors. All recipes use synchronous `delegate()` for eval subagents instead.

- **[goose-design] Goose app shows recipe `title`, not filename.** Numbered filenames (02-bug-fix.yaml) control filesystem/CLI sort order. The app shows "Bug Fix" not "02 Bug Fix". Keep titles clean, put numbers in filenames only.

- **[goose-app] CONFIRMED: Goose desktop app sorts recipes by modification date, newest first.** Hardcoded in `crates/goose-server/src/routes/recipe_utils.rs`: `sort_by(|a, b| b.last_modified.cmp(&a.last_modified))`. No configurable sort option exists. No UI toggle. Numbered filenames only affect CLI `goose recipe list` order. To keep "★ START HERE" at the top of the app, `touch` it after any batch recipe update. The setup script should touch the gateway as its final step.

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
