# Installer build-out + ACP patch bisect plan — 2026-04-15

**Date:** 2026-04-15 (late session, context-compacted handoff)
**Branch:** `practice/stage-0` (pushed to `origin/AI-Foundry-Core/goose-wizard`)
**Last pushed commit:** `d8f82e2` Lazy-load act scripts in Stage 0 recipe.
**Uncommitted state:** clean working tree.

---

## Next-session priority

**First task:** walk Doni through each of the 5 ACP patches and explain what they do, then bisect them — re-apply ONE AT A TIME and test whether Goose's recipe behavior regresses. Goal: identify which patches are actually load-bearing vs which were added speculatively.

**Current ACP state on Doni's machine:** UNPATCHED. He uninstalled + reinstalled `@agentclientprotocol/claude-agent-acp` during this session's debugging (to test whether the double-write rendering bug was caused by our patches). The reinstall wiped all 5 patches. He has NOT re-run the installer since. So right now he's running clean upstream ACP.

**Why bisect:** We wrote 5 patches but only have clear evidence that Patch 1 (settingSources) is load-bearing — without it, `~/.claude/settings.json` allowlists leak into training sessions (observed in his last recipe run: Claude named specific Bash allowlist entries it shouldn't have known). The other 4 patches may or may not be necessary.

---

## The 5 ACP patches (what each does, why it exists)

All applied to `acp-agent.js` inside the installed `@agentclientprotocol/claude-agent-acp` package. Source of truth: `install/setup-goose.ps1` lines ~740-880 (Windows) and `install/install-mac.command` (Mac).

### Patch 1: `settingSources: ["local"]`

**Original:** `settingSources: ["user", "project", "local"]`
**Patched:** `settingSources: ["local"]`

**Why:** The ACP adapter instructs the embedded Claude Agent SDK to load `CLAUDE.md` from three scopes: user (`~/.claude/CLAUDE.md`), project (`<cwd>/CLAUDE.md`), and local (`<cwd>/.claude/CLAUDE.md`). User-scope loading brings Doni's personal Claude Code memory into every recipe session, causing the agent to identify as Claude Code, refuse to run recipes, and hallucinate memories. Local-only means only the project template's `.claude/CLAUDE.md` loads — which we control and contains the "you ARE Goose, ignore personal memory" override.

**Evidence it's load-bearing:** In the unpatched run this session, Claude named specific entries from Doni's `~/.claude/settings.json` allowlist (`Bash(python:*)`, `Bash(git:*)`, etc.). With Patch 1 applied, that shouldn't happen.

**Likely verdict:** KEEP. This is the core isolation patch.

### Patch 2: Insert `autoMemoryEnabled: false,`

**Patched:** injects `autoMemoryEnabled: false,` right after `settingSources: ["local"],`.

**Why:** The `claude_code` preset enables auto-memory by default, reading from `~/.claude/projects/<hash>/memory/` independently of `settingSources`. Bringing in user memory files overrides recipe instructions and causes confusion.

**Likely verdict:** PROBABLY KEEP, but we haven't isolated whether auto-memory loading actually breaks anything if Patch 1 is already in place. Worth testing: re-apply only Patch 1, see if memory leaks still happen. If so, add Patch 2.

### Patch 3: `disallowedTools: []`

**Original:** `const disallowedTools = ["AskUserQuestion"];`
**Patched:** `const disallowedTools = [];`

**Why:** The ACP adapter blocks `AskUserQuestion` by default. Without it, the recipe facilitator can't pause and wait for user input during multi-step teaching sessions — it would narrate past every "wait for user" checkpoint.

**Likely verdict:** KEEP. Interactive recipes depend on this tool. Test: run recipe 02, check if the facilitator actually pauses at decision points.

### Patch 4: Re-enable extended thinking (regex match, replaces our own earlier disable)

**Current state:** either the upstream `const maxThinkingTokens = process.env.MAX_THINKING_TOKENS ? parseInt(...) : undefined;` OR our earlier `const maxThinkingTokens = 0;` (disabled). Current installer restores the upstream form if it finds our old `= 0` patch.

**Why it exists:** Earlier we had this set to 0 to hide thinking blocks from the Goose UI. Doni explicitly reversed that this session ("I want people to be impressed with the AI — leave thinking on"). So this patch now just reverts any prior goose-wizard disable-patch.

**Likely verdict:** NO-OP on a fresh unpatched adapter (the regex finds no match; it only acts if an older disable is present). Safe to leave as-is.

### Patch 5: System prompt replacement

**Original:** `let systemPrompt = { type: "preset", preset: "claude_code" };`
**Patched:** a hand-written string starting with "You are an AI assistant running in the Goose agent platform..."

**Why:** The `claude_code` preset is massive, mentions memory systems and `CLAUDE.md`, and drowns out recipe instructions. The replacement focuses the agent on following recipe instructions. It also explicitly requires a one-sentence pre-tool-call announcement so the Goose approval dialog has context for what's being approved.

**Current prompt text contains marker:** `"user knows what they are approving"` (for already-patched detection).

**Likely verdict:** KEEP THE REPLACEMENT but UNCERTAIN about the pre-tool-announcement clause. Doni observed that on unpatched ACP, Claude still narrated before some tool calls ("Let me check what your settings look like") — the model does this naturally. May not need to explicitly require it. Worth testing: does the patched version differ materially from unpatched for the pre-approval announcement?

---

## Suggested bisect order

**Goal:** re-apply patches one at a time, run recipe 02 after each, check which symptoms change.

1. **Baseline (no patches — current state).** Run recipe 02 on a simple task. Document: does `~/.claude/settings.json` leak? Does the facilitator wait at checkpoints? Does the approval dialog show tool details?

2. **Apply only Patch 1 (`settingSources`).** Re-run. Verify the allowlist leak stops. Don't add other patches yet.

3. **Apply Patch 3 (`disallowedTools: []`).** Needed for `AskUserQuestion`. Verify interactive pauses work.

4. **Decide Patch 5.** Compare prompt behavior with upstream `claude_code` preset. If the preset is causing recipe-instruction drift, apply Patch 5. Otherwise skip it.

5. **Decide Patch 2 (`autoMemoryEnabled`).** Only add if memory leaks still occur after Patches 1/3/5.

6. **Patch 4 is moot** (only matters if an old disable is present; nothing to verify on unpatched adapter).

After each step, commit the installer change that corresponds to the patch(es) kept, with a clear "this patch fixes X" commit message tied to the observed evidence. Drop the patches that turn out to be unnecessary.

---

## Known upstream issues NOT caused by our patches

These persist with or without patches — don't try to fix them in the installer.

### 1. Goose CLI TUI double-write in approval dialogs

**Symptom:** Approval prompt text `"Goose would like to call the above tool, do you allow?"` appears with the tool-details line (title, args, path) redrawn over by the prompt. User sees `◆ ... ◇ ... would like to call the above tool` overlapped.

**Root cause (confirmed):** The ACP adapter sends rich structured tool info via `requestPermission` RPC — verified in `acp-agent.js` line 816 and `tools.js` lines 16-100+: titles like "Read /path/to/file", Bash command strings, Write diffs. Goose's Rust CLI is supposed to render these but is dropping them. Goose's own code (`crates/goose-cli/src/session/output.rs`) only has a minimal `println!("action_required(tool_confirmation): {tool_name}")` that gets clobbered.

**Fix path:** file upstream issue at `block/goose`. Or recommend desktop app (GUI, no TTY race). We can't fix from installer.

### 2. Smart_approve may not gate tool calls via ACP

**Symptom:** Doni set `GOOSE_MODE=smart_approve`, but Bash commands (`git log`, `python --version`) ran without approval dialogs. `Always Allow` clicks didn't appear to persist.

**Hypothesis:** When using the claude-acp provider, Goose's smart_approve permission layer may be deferring to the ACP adapter's own permission handling, which in turn defers to Claude Code's allowlist (`~/.claude/settings.json`). Two permission systems fighting, neither fully in control.

**Not confirmed.** Worth investigating by checking Goose's source for how it routes permission decisions in ACP sessions.

### 3. Recipe 01 first-turn latency

**Partially addressed** in commit `d8f82e2` — recipe 01 now lazy-loads act scripts (1 at a time) instead of all 5 at startup. Should cut first-turn latency in half. Doni has NOT tested this post-fix yet; still to verify.

---

## Installer state — what's in and what's pending

### In and pushed (as of `d8f82e2`)

- `install/install-windows.bat` — double-click wrapper
- `install/setup-goose.ps1` — Phase 1 bootstrap (Git, Node, Goose CLI, Goose desktop, Claude CLI via native installer w/ npm fallback, ACP adapter, config.yaml, credentials check) + Phase 2 configure (recipe path, extensions, ACP patches, state dirs)
- `install/install-mac.command` — self-contained Mac equivalent (Homebrew bootstrap, native Claude installer, etc.)
- `install/README.md` — usage + troubleshooting

### Known installer issues to fix next session

1. **npm calls fail under restricted PowerShell.** `& npm install -g ...` invokes `npm.ps1`, which blocks under ExecutionPolicy Restricted. Fix: change calls to `npm.cmd` or use `& (Get-Command npm.cmd)`. Affects both Claude CLI fallback install and ACP adapter install steps. Doni hit this manually during the uninstall test.

2. **Windows Goose zip extraction assumes subfolder structure.** May break if upstream changes zip layout. Currently uses a recursive `Get-ChildItem` search for `goose.exe` which is robust, but we should add a test.

3. **Patches 2, 4, 5 haven't been proven load-bearing.** The bisect plan above will determine which to keep. After the bisect, drop the unnecessary ones from `setup-goose.ps1` and `install-mac.command`.

### Completed this session

- Full prerequisite bootstrap for both platforms (Git, Node, Goose CLI + desktop, Claude CLI native, ACP adapter)
- Claude login via plain `claude` (not `claude auth login` which doesn't exist)
- Credentials file detection to skip login prompt when possible
- `claude doctor` post-install health check (45s timeout)
- `CLAUDE_CODE_GIT_BASH_PATH` proactively written to `~/.claude/settings.json` so Claude Code can find Git Bash on non-standard Git installs
- `GOOSE_MODE: smart_approve` default (NOT `auto` — Doni explicitly rejected auto as too permissive for company-wide training)
- `GOOSE_MODEL: opus` default (Sonnet ignores recipe instructions)
- ASCII-only installer files (PowerShell 5.1 chokes on em dashes in CP1252)
- `Join-Path` calls nested 2-arg style (PS 5.1 doesn't support 3+ arg form)
- Cross-platform installer one file per platform (install-windows.bat + setup-goose.ps1; install-mac.command self-contained)
- `.gitignore` updated to exclude `.claude/settings.local.json` and `.goose/state/`
- Extended thinking re-enabled per Doni's explicit request ("I want people to be impressed")
- Recipe 01 lazy-load fix (`d8f82e2`) — NOT TESTED after fix
- All 36 required params across 27 training recipes flipped to optional with empty defaults (commit `0afdaa6`)

---

## Doni's decisions this session

1. **Installer should be click-to-run on Windows and Mac.** One file per platform (his call). Native installers, not winget for Claude (Anthropic's recommended path). Click-to-run means: install all prerequisites auto, not just configure.

2. **Keep `GOOSE_MODE: smart_approve`, NOT `auto`.** "We can't do that for a company-wide training program." Rejected my suggestion to flip back to auto even after the approval-dialog rendering issue surfaced. Reasoning: training is safety-critical for skeptical devs; can't ship with full autonomous mode as default.

3. **Keep extended thinking ON.** "I want people to be impressed with the AI." Reversed an earlier patch that hid thinking blocks from the UI.

4. **Switched Claude CLI install from npm to Anthropic's native installer.** With npm as fallback for corporate environments that block `iex`-from-web.

5. **Training recipes should NOT have required inputs.** "Why would we want required inputs?" — all 36 required params flipped to optional with empty default. Teaching script elicits the input from the developer at session start.

6. **Deferred: full walkthrough on docunator.** Session ran out of time on installer + ACP patches. The walkthrough from the prior handoff (`walkthrough-fixes-2026-04-15.md`) is still pending — Recipe 01 still needs an end-to-end test with the lazy-load fix.

7. **No force-flip to auto mode.** Explicit: "and don't ask again to flip to auto."

8. **Bisect the patches instead of keeping all 5 by default.** Next session's starting instruction: explain patches one at a time, test whether each is needed, strip the ones that aren't.

---

## Critical files for next session to read first

1. This file.
2. `install/setup-goose.ps1` Phase 2 section (the ACP patch block, ~line 740-880) — see the 5 patches' current text.
3. `recipes/shared/01-see-what-ai-can-do.yaml` — lazy-load fix, verify behavior.
4. `install/README.md` — current installer docs.
5. `HOW_GOOSE_WORKS.md` — for ACP, subagent, and permission-mode mechanics. Outdated on v1.27-1.30 features (structured shell output, skills platform, adaptive thinking, goose serve, adversary.md, GooseMode persistence). Not yet refreshed.

## Open questions for the next session to resolve

1. Which of Patches 2, 4, 5 are actually needed?
2. Is the double-write rendering issue worth filing upstream, or do we just recommend desktop app for training?
3. Does smart_approve actually gate anything when using claude-acp? If not, we need either a different mode or an upstream fix.
4. Does the Recipe 01 lazy-load fix actually help? (Not tested yet.)
5. Does extended thinking ON visibly help the teaching feel? (Doni's intuition — worth validating in the walkthrough.)
