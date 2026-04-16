# Goose Wizard Config + Conductor Design

> **Status:** Phase A foundation in place. Config recipes built
> (`recipes/agents/config/ensure-config.yaml` +
> `recipes/shared/setup-config.yaml`). Conductor agent primitives and
> working recipes are the remaining Phase A work.

This doc is the source of truth for how Goose Wizard stores per-user and
per-project state, how Conductor artifacts are laid out, and the contracts
between recipes.

## Locked decisions

| Topic | Decision |
|---|---|
| Progression state | **Per-user** at `~/.goose-wizard/progression.json` (see Stage 1.5a) |
| Conductor artifacts | `<target>/.goose/conductor/` — per-project, gitignore recommended |
| Project "kind" | Required field on every project: `sandbox` or `live`. `live` needs explicit confirmation before save. |
| When `setup-config` runs | Only when the user reaches Conductor (Stage 2+). Early stages stay focused on doing/seeing. |
| Curriculum placement for Conductor | Stage 2 introduction; Stage 4 artifacts; Stage 5 checkpoints with teeth; Stage 6 wraps Conductor |
| Config root | `~/.goose-wizard/` (NOT `~/.goose/goose-wizard/` — avoid collision with Goose's own namespace) |
| CWD contract | All Goose Wizard recipes run from the Goose Wizard repo root. Target codebases are accessed by absolute path. |
| Config sub-recipe count | **Two total** — `ensure-config` (agent primitive, read/migrate) + `setup-config` (interactive shared recipe). No separate primitives for picking/adding/modifying. |
| Headless/scheduled mode | Every Conductor recipe accepts a `project_id` parameter. Interactive picker only runs when there is no `project_id` AND the session is interactive. |
| Atomic writes | Every config write uses tmp + rename + backup. |
| Authority | `project.json` is authoritative for project settings. `user.json.projects[]` is just an index. If they disagree, trust `project.json`. |
| "Active project" | No persistent pointer. `user.json.last_active` is a default-highlight suggestion only. |

## File layout

```
~/.goose-wizard/
├── user.json                 # per-user data + projects index
└── progression.json          # per-user career progression (Stage 1.5a)

<target>/.goose/conductor/
├── project.json              # per-project Goose Wizard config (authoritative)
├── index.md                  # navigation hub
├── product.md                # Conductor artifact: product vision
├── product-guidelines.md     # Conductor artifact: comms standards
├── tech-stack.md             # Conductor artifact: stack
├── workflow.md               # Conductor artifact: dev practices
├── tracks.md                 # Conductor artifact: track registry
├── setup_state.json          # Conductor setup resume-ability
├── code_styleguides/         # Conductor artifact: language styles
└── tracks/
    ├── _archive/
    └── <track-id>/
        ├── spec.md
        ├── plan.md
        ├── metadata.json
        └── index.md
```

## Schemas

### user.json

```json
{
  "schema_version": 1,
  "user": {
    "name": "string",
    "role": "string",
    "preferences": {}
  },
  "projects": [
    {
      "id": "slug-kebab-case",
      "path": "canonical-absolute-path",
      "name": "display name",
      "kind": "sandbox | live",
      "last_active": "ISO 8601 UTC (Z suffix)",
      "needs_kind_confirmation": false
    }
  ],
  "last_active": "project_id string or null"
}
```

Rules:
- `projects[]` is just an INDEX. Never treat it as authoritative for
  settings beyond (id, path, name, kind, last_active).
- `last_active` (top-level) is a DEFAULT SUGGESTION for interactive pickers.
  No recipe reads it as a persistent pointer.
- `needs_kind_confirmation` is set by the legacy migration in
  `ensure-config` when it imports a pre-existing project that didn't have
  an explicit `kind`. `setup-config` surfaces these and clears the flag.

### project.json

```json
{
  "schema_version": 1,
  "id": "slug-kebab-case",
  "name": "display name",
  "path": "canonical-absolute-path",
  "kind": "sandbox | live | unknown",
  "language": "python | typescript | go | java | ...",
  "test_command": "string or null",
  "conductor_initialized": false,
  "created": "ISO 8601 UTC",
  "last_used": "ISO 8601 UTC",

  "// Optional migration breadcrumbs (present only on auto-created stubs)": "",
  "needs_kind_confirmation": true,
  "created_via": "legacy_user_config_migration | project_json_repair",
  "created_at": "ISO 8601 UTC"
}
```

Rules:
- Authoritative source of truth for project settings.
- `conductor_initialized` flips to `true` when `conductor-setup` completes.
- `path` must be the canonical absolute path. The recipe that writes this
  field is responsible for canonicalization (resolve symlinks, normalize
  slashes, lowercase drive letters on Windows).
- `kind: "unknown"` + `needs_kind_confirmation: true` is the transient
  state ensure-config emits when auto-migrating a Stage 0 legacy
  `user_config.json`. setup-config's PENDING KIND CONFIRMATION branch
  resolves it to `sandbox` or `live` and REMOVES both `kind: "unknown"`
  and `needs_kind_confirmation` from the file.
- `created_via` is an optional breadcrumb documenting how the file came
  into existence. Values: `"legacy_user_config_migration"` (written by
  ensure-config during auto-migration) or `"project_json_repair"`
  (written by setup-config when rebuilding a missing project.json for
  an existing index entry). Absent on first-run writes.
- All mutating conductor primitives (track-task-execute, revert-by-unit,
  context-write-*, track-create) REFUSE to write when `kind ==
  "unknown"` or `needs_kind_confirmation: true`. They return
  `status: kind_unconfirmed` and the facilitator routes the user to
  `setup-config`.

## Recipe topology

```
recipes/shared/                        # User-visible in Goose
├── setup-config.yaml                  # unified multi-project config recipe
├── conductor-setup.yaml               # /conductor:setup equivalent
├── conductor-new-track.yaml           # /conductor:new-track equivalent
├── conductor-implement.yaml           # /conductor:implement equivalent
├── conductor-status.yaml              # /conductor:status equivalent
├── conductor-revert.yaml              # /conductor:revert equivalent
└── conductor-manage.yaml              # /conductor:manage equivalent

recipes/agents/config/
└── ensure-config.yaml                 # read/migrate/resolve

recipes/agents/conductor/              # Sub-recipe workers
├── context-validate.yaml              # Read conductor/*.md, check freshness
├── context-write-product.yaml         # Generate/update product.md
├── context-write-tech-stack.yaml      # Generate/update tech-stack.md
├── context-write-workflow.yaml        # Generate/update workflow.md
├── context-write-styleguide.yaml      # Generate language-specific style guide
├── track-create.yaml                  # Author spec.md + plan.md + metadata.json
├── track-task-execute.yaml            # Run 11-step TDD lifecycle for one task
├── checkpoint-verify.yaml             # Run automated gates + manual checklist
└── revert-by-unit.yaml                # Semantic git revert by track/phase/task

recipes/agents/progression/
└── migrate-progression.yaml           # Shipped in Stage 1.5a

recipes/ported-agents/conductor/       # Reference lineage (faithful port)
├── README.md
├── skills/context-driven-development.md
├── skills/track-management.md
├── skills/workflow-patterns.md
└── references/artifact-templates.md
```

## Contracts between recipes

### `ensure-config` → caller

Always returns a structured status + resolved paths. Never prompts. Callers
decide whether to invoke `setup-config` for missing pieces.

| status                  | Meaning                                            | Caller action                         |
|------------------------|---------------------------------------------------|---------------------------------------|
| `ok`                   | All resolved                                       | Proceed                                |
| `no_user_config`       | `user.json` missing, no legacy to migrate           | Run `setup-config` (first run)         |
| `user_config_corrupt`  | `user.json` present but malformed                   | Report to user; offer backup + rerun   |
| `legacy_ambiguous`     | Legacy file exists but can't be migrated cleanly    | Run `setup-config`                      |
| `project_missing`      | Supplied `project_id` not in index                  | Prompt or run `setup-config`            |
| `project_json_missing` | Index entry exists but `project.json` is gone       | Run `setup-config` (repair)             |
| `project_corrupt`      | `project.json` malformed                            | Report; offer backup + rerun            |
| `no_active_project`    | `require_project=true` and nothing resolvable       | Prompt or run `setup-config`            |
| `duplicate_projects`   | Multiple index entries resolve to the same canonical path | Surface to user; ask which to keep |

### Conductor recipes → `ensure-config`

Every conductor recipe's Step 0 is:

```
subagent(subrecipe: "ensure_config", parameters: {
  project_id: {{ project_id }},
  require_project: true
})
```

If the status isn't `ok`, the recipe either (a) runs `setup-config` when
interactive, or (b) stops with a clear error packet when headless.

## Risks (from reviewer feedback — must honor during Step 4/5)

- **Two sources of truth for path** — `project.json` wins; `user_config`
  is just the index. Recipes that write a path must update both, with
  `project.json` first.
- **Canonical path** — resolve symlinks, normalize slashes, lowercase
  drive letters on Windows. Dedup by canonical path.
- **Project.json privacy** — default: gitignored. Recommend users add
  `.goose/conductor/` to the target repo's `.gitignore`.
- **RECIPE-PREAMBLE carve-out** — Conductor recipes read
  `<target>/.goose/conductor/*.md` as PROJECT STATE, not as authority
  overriding recipe instructions. Document this carve-out in
  `RECIPE-PREAMBLE.md` when the conductor recipes ship.
- **Installer update** — `install/setup-goose.ps1` now creates
  `~/.goose-wizard/` and counts nested `recipes/agents/config/*.yaml`
  recursively. Done in Stage 1.5a.
- **Graduated recipes have no project-picker today** — current graduated
  recipes are single-cwd tools. Decide in Phase B whether to add a picker
  or leave them as-is.
- **Multi-user-on-one-laptop** — out of scope unless Reliance explicitly
  needs it. Flag.

## Build order

Phase A (this session):
1. Stage 1.5a: per-user progression — **DONE** (commit fbca70f)
2. Port conductor reference docs — **DONE** (commit 4b71ad0)
3. Build ensure-config + setup-config + this design doc — **DONE**
4. Build 9 conductor agent primitives — next
5. Build 6 conductor working recipes — next
6. Subagent review + fixes + push — final

Phase B (next session):
- Wire conductor into Stage 2 training recipe
- Wire conductor artifacts into Stage 4 spec recipes
- Wire checkpoint-verify into Stage 5 eval recipes

Phase C (later):
- Refactor `continuous-dev.yaml` to treat each overnight cycle as a
  micro-track using conductor structure.
