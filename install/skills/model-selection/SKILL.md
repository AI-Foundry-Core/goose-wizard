---
name: model-selection
description: Required reading before invoking another goose recipe via shell (`goose run --recipe ...`). Tells you exactly which environment variable to set for each model role on each provider. Goose's `--model` flag and `GOOSE_MODEL` env var DO NOT actually select the model for ACP providers — only the substrate-native overrides documented here work. Load this skill any time you are about to spawn a `goose run` subprocess.
---

# Model Selection for goose run subprocess invocations

## Why this skill exists

Goose's session banner LIES about which model is actually serving an ACP provider. Setting `--model X` or `GOOSE_MODEL=X` echoes into the banner but does not change the model that actually runs. Verified 2026-04-26 against `claude-acp` (every `--model <anything>` returned the same substrate default model).

To actually select the model for `claude-acp` or `codex-acp`, use the substrate-native env vars below. Bad model IDs fail loudly with a clean error — that's the right basis for retry-on-failure.

## The role-to-env-var map

This project uses three model roles. Each role maps to a different model per provider.

| Role | Provider | Env var(s) to set on the spawning shell |
|------|----------|-----------------------------------------|
| **top-model** | `claude-acp` | `ANTHROPIC_MODEL=claude-opus-4-7` |
| **top-model** | `codex-acp` | `CODEX_HOME=$HOME/.codex-homes/gpt-5.5` |
| **top-model** | `openrouter` | `OPENROUTER_API_KEY=<key>` + `GOOSE_MODEL=moonshotai/kimi-k2.6` |
| **fallback-model** | `claude-acp` | `ANTHROPIC_MODEL=claude-sonnet-4-6` |
| **fallback-model** | `codex-acp` | `CODEX_HOME=$HOME/.codex-homes/gpt-5.4` |
| **fallback-model** | `openrouter` | `OPENROUTER_API_KEY=<key>` + `GOOSE_MODEL=qwen/qwen3-coder` |
| **fast-model** | `claude-acp` | `ANTHROPIC_MODEL=claude-haiku-4-5-20251001` |
| **fast-model** | `codex-acp` | *(no fast tier yet — fall back to fallback-model)* |
| **fast-model** | `openrouter` | `OPENROUTER_API_KEY=<key>` + `GOOSE_MODEL=google/gemini-2.5-flash` |

`$HOME` resolves to the user's home (e.g., `C:/Users/Doni.Lerner` on this machine). Use the absolute path in actual shell invocations.

For OpenRouter, `<key>` is the contents of an OpenRouter API key file (NOT the path). On this machine the file is at `~/AI Projects/.secrets/openrouter-goose-test.key`; in the Docker harness the bash launcher reads that file and forwards the contents via `docker run -e OPENROUTER_API_KEY=...`.

## Command shape

**Claude leaves:**

```bash
ANTHROPIC_MODEL=<id-from-table> goose run --recipe <path> --provider claude-acp [--params k=v ...]
```

**Codex leaves:**

```bash
CODEX_HOME=<path-from-table> goose run --recipe <path> --provider codex-acp [--params k=v ...]
```

**OpenRouter:**

```bash
OPENROUTER_API_KEY=<key> GOOSE_MODEL=<id-from-table> goose run --recipe <path> --provider openrouter [--params k=v ...]
```

For ACP providers, no `--model` flag and no `GOOSE_MODEL` env var — the substrate reads the env vars above directly. For OpenRouter, `GOOSE_MODEL` IS the active knob (Goose's native provider path), and `OPENROUTER_API_KEY` is required for auth. Recipes invoked via OpenRouter must declare `- type: platform; name: skills` in their `extensions:` block (LEARNINGS.md 2026-04-28); ACP providers ignore that declaration.

## Failure modes and how to detect them

| Symptom | Mechanism | What to do |
|---------|-----------|------------|
| Bad ANTHROPIC_MODEL | exit ≠ 0, stderr: `"There's an issue with the selected model …"` | Pick a different role from the table; retry |
| Bad CODEX_HOME path / missing auth.json | exit ≠ 0, stderr: `"Authentication required"` | Stop and report — setup problem, not a model problem |
| Bad GOOSE_MODEL on openrouter | exit ≠ 0, stderr usually contains `"model not found"` or HTTP 4xx from OpenRouter | Pick a different role from the table; retry |
| Missing OPENROUTER_API_KEY | exit ≠ 0, stderr: `"OPENROUTER_API_KEY not set"` or HTTP 401 | Stop and report — setup problem, not a model problem |
| Rate limit | exit ≠ 0, stderr contains `"rate limit"` / `"429"` / `"quota exceeded"` | Wait 5 min, retry same model up to 2 times, then escalate to a different role |
| **Silent degenerate output** (exit 0, but content is empty / mismatched / "I already did this") | No exit-code signal | Validate output content (minimum length, required markers); treat as failure if validation fails |

## Verification when correctness matters

Goose's banner (`● new session · <provider> <model>`) is unreliable for ACP providers. To verify which model actually ran, ask the model to self-identify in the response — model self-IDs are reliable when the prompt is explicit ("State your exact model ID, not just the family name").

## Setup (per machine, per collaborator)

The codex homes referenced above must exist on the machine running goose:

- `~/.codex-homes/gpt-5.5/` (top-model on codex)
- `~/.codex-homes/gpt-5.4/` (fallback-model on codex)

Each contains `auth.json` (copied from `~/.codex/auth.json`) and `config.toml` with `model = "<name>"`. Setup is per-machine — see project `LEARNINGS.md` for the one-time setup steps.

## Notes for adding a new role or model

- New role: add a row to the table above. Roles are intentionally task-shaped (top / fallback / fast), not model-named, so model upgrades don't ripple into recipe changes.
- New claude model: just edit the env var value in this skill.
- New codex model: create a new codex home (mkdir, copy auth.json, write config.toml), then point the role at it here.
- New openrouter model: edit the `GOOSE_MODEL=<id>` value here. The id is the OpenRouter model slug (e.g., `google/gemini-2.5-flash`). The Docker harness's `model_resolver.py` mirrors this table — update both in the same change.

## Source for these claims

Verified 2026-04-26 via sterile-CWD tests: `--model fake-model-99-doesnt-exist` against claude-acp returned a successful run with the substrate default model (banner lies). `ANTHROPIC_MODEL=claude-opus-4-7` returned an Opus 4 self-ID with opus-style output. `ANTHROPIC_MODEL=claude-haiku-4-5-20251001` returned Haiku 4.5 self-ID. `ANTHROPIC_MODEL=fake-name` failed loudly. CODEX_HOME swap verified for both gpt-5.5 and gpt-5.4 homes. Full details in `docs/goose-provider-model-semantics.md` and `LEARNINGS.md` (2026-04-26).
