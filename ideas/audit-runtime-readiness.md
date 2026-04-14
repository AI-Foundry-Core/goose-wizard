# Audit: Runtime Readiness — What Will Break

**Auditor:** Codex / GPT 5.4
**Date:** 2026-04-12
**Verdict:** Not ready to run against Goose yet. The content is a strong V1 draft, but the runtime layer is incomplete and several recipe fields likely fail current Goose validation.

---

## Findings

### 1. HIGH: Most recipes likely fail Goose recipe validation

Current Goose docs define `input_type` values as `string`, `number`, `boolean`, `date`, `file`, or `select`, require defaults for optional parameters, and validate template variables. The root `recipes/` tree has 88 uses of `input_type: text`, 58 optional parameters without defaults, and 60 Handlebars-style conditionals like `{{ if ... }}...{{ endif }}`.

Example: `recipes/stage-1/bug-fix.yaml` lines 8, 13, 55.

Source: Goose Recipe Reference docs.

### 2. HIGH: The teaching runtime entrypoint is missing

The docs say `teaching/meta/teach-wrapper.yaml` loads `teaching/meta/teacher-instructions.md`, but neither file exists at the root. Only variant files and a consolidated copy exist.

What breaks: first-run teaching mode, delegate convention, eval handling, and progression updates have no runnable wrapper.

### 3. HIGH: Required project state files are absent

`.goose/team_context.md` and `.goose/state/progression.json` do not exist in this repo, but recipes and teaching scripts assume them throughout.

What breaks: recipes will start by reading missing context; teaching scripts will try to read/write missing progression state without a helper.

### 4. HIGH: Structured returns are described but not enforced

Recipes use prose `Return:` sections, but none of the 30 root recipe YAMLs define `response:`/`json_schema`.

What breaks: teach scripts and downstream coaching expect fields like `root_cause`, `diff`, and `test_results`, but Goose will not force parseable output.

### 5. MEDIUM: Variant files are still in the runnable recipe path

`recipes/stage-1/` contains `code-review.yaml`, `code-review_claude.yaml`, and `code-review_codex.yaml`; `recipes/stage-7/` has three `pipeline-self-edit` variants.

What breaks: recipe discovery/library UX can expose draft variants as runnable modules.

### 6. MEDIUM: State management is still convention-only

No schema migration, concurrency handling, or corruption recovery. Async eval/state writes can clobber or corrupt progress, and re-runs can downgrade prior ratings unless enforced by code.

### 7. MEDIUM: Install/onboarding docs point at missing files

`CLAUDE.md` references `onboarding/onboard.yaml` and `install/install.sh`; both are absent.

What breaks: a new team cannot install or bootstrap from the repo as documented.

---

## Verification Notes

`goose` is not installed on PATH. Python lacks `PyYAML`. Could not run `goose recipe validate` or a full YAML parser locally. Findings based on filesystem/schema scans and current official Goose recipe docs.
