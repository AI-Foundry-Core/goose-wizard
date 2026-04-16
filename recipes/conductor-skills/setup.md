# Setup Skill — Project Initialization & Context Artifacts

Conductor reads this file when the user wants to initialize a project,
update context artifacts, or re-run setup.

## Project Initialization Flow

1. Check if `.goose/conductor/` exists under the target project
2. If not, create the directory structure:
   - `.goose/conductor/product.md`
   - `.goose/conductor/tech-stack.md`
   - `.goose/conductor/workflow.md`
   - `.goose/conductor/tracks.md` (empty registry)
   - `.goose/conductor/code_styleguides/` (directory, populated later by styleguide agent)
3. Ask the user structured questions for each artifact (see procedures below)
4. Write each artifact using the inline procedures

## Context Artifact Procedures

### Writing product.md

**Target path:** `<project.path>/.goose/conductor/product.md`

**Inputs (structured):**
- `product_name` — one-line product name
- `problem_statement` — what problem this solves and for whom
- `solution_summary` — high-level approach
- `personas_json` — array of `{ persona, needs, pain_points }`
- `features_json` — array of `{ feature, status, description }`
- `metrics_json` — array of `{ metric, target, current }`
- `roadmap_json` — array of `{ phase, scope }`

**Template structure:**

```markdown
# [Product Name]

> [One-line description — derived from product_name]

## Problem

[problem_statement content]

## Solution

[solution_summary content]

## Target Users

| Persona | Needs | Pain Points |
|---|---|---|
| [persona] | [needs] | [pain_points] |

## Core Features

| Feature | Status | Description |
|---|---|---|
| [feature] | [status] | [description] |

## Success Metrics

| Metric | Target | Current |
|---|---|---|
| [metric] | [target] | [current] |

## Roadmap

- **[Phase 1]**: [scope]
- **[Phase 2]**: [scope]
```

**Mode rules:**
- `create` — write from inputs. Fail if file already exists (return
  `status: already_exists`). If a required section has no input, leave a
  `<!-- TODO -->` marker so the author sees the gap.
- `update` — file must exist (else `status: not_found`). Read existing
  file, parse by section headers. Merge: replace supplied fields, keep
  everything else untouched. Never lose existing sections.
- `replace` — overwrite entirely. Requires explicit caller intent.

**Validation rules:**
- Never generate Lorem-ipsum filler.
- Never invent content not supplied by the user.
- If a required section has no input and no existing content (in update
  mode), leave a `<!-- TODO -->` marker.

### Writing tech-stack.md

**Target path:** `<project.path>/.goose/conductor/tech-stack.md`

**Inputs (structured):**
- `languages_json` — array of `{ technology, version, purpose }`
- `dependencies_json` — array of `{ package, version, rationale }`
- `infrastructure_json` — array of `{ component, choice, notes }`
- `dev_tools_json` — array of `{ tool, purpose, config }`
- `detect_from_project` — boolean; if true, auto-detect from manifests

**Manifest detection logic (when `detect_from_project` is true):**

Scan the project root for these files and extract language, version, and
direct dependencies only:

| Manifest file | What to extract |
|---|---|
| `requirements.txt` | Python packages + pinned versions |
| `pyproject.toml` | Python version, build system, dependencies |
| `package.json` | Node version (engines), dependencies, devDependencies |
| `Cargo.toml` | Rust edition, dependencies |
| `go.mod` | Go version, module dependencies |
| `composer.json` | PHP version, dependencies |

Rules for detection:
- Never enumerate transitive dependencies; list only direct/top-level.
- Never guess versions. Read the manifest, report what is there, or
  write `unknown`.
- If a manifest is present but malformed, report `status: manifest_corrupt`
  with the filename and parse error. Do NOT write partial state.

**Conflict handling:** When both manifest detection and caller-supplied
inputs exist for the same field, prefer the caller-supplied value. Surface
the conflict so the caller can reconcile:
`{ field, caller_value, manifest_value, resolved_as }`.

**Template structure:**

```markdown
# Tech Stack

## Languages & Frameworks

| Technology | Version | Purpose |
|---|---|---|
| [technology] | [version] | [purpose] |

## Key Dependencies

| Package | Version | Rationale |
|---|---|---|
| [package] | [version] | [rationale] |

## Infrastructure

| Component | Choice | Notes |
|---|---|---|
| [component] | [choice] | [notes] |

## Dev Tools

| Tool | Purpose | Config |
|---|---|---|
| [tool] | [purpose] | [config] |
```

**Mode rules:**
- `create` — fail if file exists. If no manifest found AND no inputs
  provided, return `status: missing_inputs`.
- `update` — file must exist. Merge section-by-section; new values
  override, existing sections not mentioned are preserved.
- `replace` — overwrite entirely.

### Writing workflow.md

**Target path:** `<project.path>/.goose/conductor/workflow.md`

**Inputs (structured):**
- `methodology` — dev methodology summary (e.g., "TDD with trunk-based
  development")
- `git_conventions_json` — object with `branch_naming`, `commit_format`,
  `pr_requirements` fields
- `quality_gates_json` — array of `{ gate, requirement }`
- `deployment_steps_json` — array of ordered deployment step strings

**Template structure:**

```markdown
# Workflow

## Methodology

[methodology content]

## Git Conventions

- **Branch naming**: [branch_naming]
- **Commit format**: [commit_format]
- **PR requirements**: [pr_requirements]

## Quality Gates

| Gate | Requirement |
|---|---|
| [gate] | [requirement] |

## Deployment

1. [step 1]
2. [step 2]
3. [step 3]
```

**Mode rules:**
- `create` — fail if file exists. If a required section is empty, leave
  a `<!-- TODO -->` marker and include it in the "gaps" list.
- `update` — file must exist. Merge section-by-section; preserve
  untouched sections.
- `replace` — overwrite entirely.

**Validation rules:**
- Never invent a test-coverage target, branch-naming convention, or gate
  threshold that was not supplied.
- Only render what the caller supplies. Empty sections get `<!-- TODO -->`.

## Common Write Convention

All artifact writes follow the backup rotation convention:

1. Write the new content to `<file>.tmp` in the same directory.
2. If the original file already exists, rename it to
   `<file>.bak.<YYYYMMDDTHHMMSSZ>` (UTC compact timestamp — e.g.,
   `product.md.bak.20260415T173042Z`). Generate the timestamp from the
   shell, not from agent wall-clock reasoning.
3. Rename `<file>.tmp` to the final name.
4. If step 3 fails, leave both `<file>.tmp` and `<file>.bak.<timestamp>`
   in place. The user has the old canonical state and the attempted new
   state, both visible, neither blessed. Report the failure; do NOT
   auto-recover.

**Never:**
- Overwrite an existing `.bak` file (timestamps guarantee uniqueness).
- Use rotating-numeric schemes (`.bak.1`, `.bak.2`).
- Auto-delete backups. Disk hygiene is the user's call.

Creating a new file that does not exist yet requires no backup.

## Update Mode

When updating an existing artifact:

1. Read the current file.
2. Parse the file by section headers (## headings).
3. Merge new content section-by-section:
   - Sections with new values: replace the section content entirely.
   - Sections not mentioned in the update: preserve untouched.
   - Never drop or lose existing sections.
4. Write using the backup convention above.

## Validation

After writing any artifact, re-read it and confirm:
- File exists and is non-empty.
- All expected section headers are present (## Problem, ## Solution,
  ## Target Users, etc. for product.md; ## Languages & Frameworks,
  ## Key Dependencies, etc. for tech-stack.md; ## Methodology,
  ## Git Conventions, etc. for workflow.md).
- No template placeholders remain (`<!-- TODO -->` markers are acceptable
  only when the user has not supplied content for that section; they must
  not appear for sections where input was provided).
- Tables are well-formed (header row, separator row, data rows).

## Safety Guards

Before writing any artifact:
- If `project.kind == "live"`, refuse unless the caller has obtained
  explicit typed user confirmation (`live_confirmed: true`).
- If `project.kind == "unknown"` or `needs_kind_confirmation: true`,
  refuse unconditionally until the kind is resolved.
