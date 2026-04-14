# Verification: All Audit Fixes

**Verifier:** Codex
**Date:** 2026-04-12

Scope followed `.codex_prompt_verify.md`. I read the module-designer references, the three audit reports listed there, and ran targeted filesystem/schema scans. I could not run Goose runtime validation because `goose` is not on PATH in this environment.

## 1. Recipe YAML fixes

**FAIL**

Canonical recipe files look improved: excluding variant files, I found no `input_type: text` and no optional parameters missing `default:` in `recipes/stage-*/*.yaml`.

However, the required fix says no `_claude` or `_codex` variant files should remain in recipe dirs, and variants still exist:

- `recipes/stage-1/code-review_claude.yaml`
- `recipes/stage-1/code-review_codex.yaml`
- `recipes/stage-7/pipeline-self-edit_claude.yaml`
- `recipes/stage-7/pipeline-self-edit_codex.yaml`

Those remaining variant files still contain `input_type: text`. They also have optional parameters without defaults:

- `code-review_claude.yaml`: `review_focus`, `context`
- `code-review_codex.yaml`: `review_focus`, `context`
- `pipeline-self-edit_claude.yaml`: `audit_focus`, `known_issues`, `verification_command`
- `pipeline-self-edit_codex.yaml`: `audit_focus`, `known_issues`, `verification_command`

Stage RIL-agent references are also only partially fixed:

- Stage 4 canonical recipes reference appropriate RIL agents.
- Stage 6 canonical recipes reference Conductor/product-evaluation resources.
- Stage 7 `skill-evolution.yaml` references `tutorial-engineer`, but `metrics-dashboard.yaml` and `pipeline-self-edit.yaml` have no RIL/conductor reference.

## 2. `teach-wrapper.yaml`

**PASS**

`teaching/meta/teach-wrapper.yaml` exists and wires the required roles:

- Facilitator is the main agent and explicitly never touches code.
- Code-work is invoked through the `working_recipe` sub-recipe.
- Eval subagent is delegated asynchronously with `delegate(async: true)`.
- It loads `teaching/meta/teacher-instructions.md`.
- It reads `.goose/team_context.md`.
- It reads and writes `.goose/state/progression.json`.

Note: I did not runtime-validate the wrapper against Goose. One thing to validate later is whether the `recipe_path` optional parameter needs a parameter-level `default:` rather than only the template default in `sub_recipes.path`.

## 3. `.goose/` bootstrap files

**PASS**

Both required bootstrap files exist:

- `.goose/team_context.md`
- `.goose/state/progression.json`

`team_context.md` is a fill-in template with project, stack, test/build commands, conventions, ownership, and known-issues sections.

`progression.json` is valid JSON and matches the initial state shape from `progression-format.md` at the top level:

- `developer_id`
- `last_updated`
- `stages`
- stages `0` through `7`
- per-stage `status`

The file is an empty initial state, so it does not yet include concept/dimension entries from the example schema.

## 4. Teaching script bug fixes

**PARTIAL**

The specific checklist items are fixed:

- `teaching/stage-2/spec-first.teach.md`: eval JSON dimension objects no longer include the extra `"concept"` field.
- `teaching/stage-5/eval-foundation.teach.md`: State Update includes "Never overwrite a Strong rating with a lower one."
- `teaching/stage-5/eval-layers.teach.md`: State Update includes the same Strong-overwrite protection.
- `teaching/stage-7/skill-evolution.teach.md`: State Update includes the same Strong-overwrite protection.
- `teaching/stage-0/act-5-say-it-better.teach.md`: State Update marks Stage 0 complete in `.goose/state/progression.json`.
- `teaching/stage-6/continuous-dev.teach.md`: Bridge no longer references stage numbers directly.

Residual audit gap: `teaching/stage-2/spec-first.teach.md` still does not include the "Never overwrite a Strong rating with a lower one" rule in its State Update section. This gap was called out in `ideas/audit-consistency-voice.md`, even though it was not included in the short fix checklist.

## Overall

**PARTIAL**

Wrapper and bootstrap files are present, and the listed teaching-script fixes mostly landed. The repo is not clean against the recipe audit because recipe variant YAMLs remain in runnable recipe dirs, those variants still use `input_type: text`, they still lack defaults on optional parameters, and two Stage 7 canonical recipes still lack an appropriate RIL/conductor reference.
