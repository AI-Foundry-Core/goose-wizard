# Kickoff Prompt — Paste This Into a Fresh Claude Code Session

Copy everything between the triple-dashed lines below into a new Claude Code session in `C:\Users\donid\ClaudeProjects\RILGoose`.

---

Continue the RIL-agents port work from yesterday. Full plan and inventory are already committed — your job is stages 2-5.

**Read these first, in order:**
1. `handoffs/ril-agents-port-handover-2026-04-14.md` — the plan, decisions, file mapping, commit staging, constraints
2. `handoffs/ril-agents-port-inventory.md` — the underlying inventory that led to the plan

**Then execute:**

- **Stage 2 — Port.** Create `recipes/ported-agents/<plugin>/<name>.yaml` for the 12 source `.md` files listed in the handover. Each port: preserve identity and directives faithfully, don't improve behavior during the port, follow the YAML structure shown in the handover. Also create `recipes/ported-agents/conductor/continuous-dev-patterns.md` — a ~100-200 line RILGoose-voice digest of the three conductor skills (context-driven-development, track-management, workflow-patterns), tailored to what `recipes/agents/continuous-dev.yaml` actually does (learnings capture, per-agent memory, shared-state audit, next-cycle checklists). Read conductor's three SKILL.md files under `~/ClaudeInfra/ril-agents/plugins/conductor/skills/` for source material — **read-only, do not modify them**. Commit when done.

- **Stage 3 — Rewire.** Update 21 recipe YAMLs and 4 teaching/reference docs per the handover's "Files that need rewiring" section. Replace every `~/ClaudeInfra/ril-agents/...` path with the matching local `recipes/ported-agents/...` path. Fix the three misreferences flagged in the handover. For `pipeline-forge.yaml` and `recipe-forge.yaml`, replace the open-ended "search `~/ClaudeInfra/...`" instructions with pointers to `recipes/forge-references/` and `recipes/ported-agents/`. Commit when done.

- **Stage 4 — Top-level docs.** Rewrite `CLAUDE.md`, `REFERENCES.md`, `HOW_GOOSE_WORKS.md`, and check `ideas/syllabus.md` — reframe RIL-agents from "runtime dependency" to "lineage/inspiration." Remove instructions that tell future sessions to look in `~/ClaudeInfra`. Commit when done.

- **Stage 5 — Verify.** Run `grep -r "ClaudeInfra/ril-agents"` on the RILGoose repo. Must return zero matches in `recipes/`, `teaching/`, and the top-level docs. Matches in `handoffs/` and `overnight-pipeline/runs/*/transcripts/` are historical and can stay — flag them. Validate every ported YAML against `recipes/forge-references/validation-checklist.md` (37 checks). Write `handoffs/ril-agents-port-complete.md` documenting created files, modified files, grep output, validation results, and any deviations. Commit.

**Spin up 4 subagents (2 Claude + 2 Codex) after each of stages 2, 3, 4, and 5 to review and fix what they flag.** (Codex review script: `python ~/ClaudeProjects/AgenticSystem/codex_review.py --project-dir ~/ClaudeProjects/RILGoose --prompt-file <prompt> --timeout 300`. Write Codex prompts to temp files inside the project dir, not `/tmp/`.)

**Hard constraints (do not violate):**
- `~/ClaudeInfra/ril-agents/` is read-only. Never modify. Other systems depend on it.
- One source `.md` → one ported `.yaml`. Do not merge or consolidate. The conductor digest is the only exception — it's an explicit derivative, not a port.
- If a source file references something missing, stop and flag it in the completion handoff, don't invent content.
- Commit in five distinct stages per the handover, not one mega-commit.
- Push each commit to `origin/main` after committing. If a commit lands on a feature branch (environment quirk), checkout main, ff-only merge the branch, and push.

**Scope reminder:** 12 ports + 1 conductor digest = 13 new files under `recipes/ported-agents/`. ~26 files modified for rewiring. Expected 4 commits after the inventory commit that's already in.

When all five stages are done, report back with: "Port complete. N files created, M files modified, grep returns 0 runtime matches, all ports validated." and the path to the completion handoff.

---

That's the whole kickoff prompt. The handover doc has every file path, every decision, and every constraint spelled out — so the fresh session should be able to pick up without asking questions.
