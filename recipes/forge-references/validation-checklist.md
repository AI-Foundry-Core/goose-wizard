# GooseForge Validation Checklist

37 items adapted from SubagentForge's 60+ item checklist for Goose recipe YAML. Every forged recipe must pass all REQUIRED items. RECOMMENDED items improve quality.

---

## Identity (REQUIRED)

- [ ] **Single sentence role:** Can you describe what this recipe does in 15 words or less? Check `title:` + `description:`.
- [ ] **Trigger condition:** Does `description:` say when/why to use this recipe?
- [ ] **Name matches function:** Is the filename descriptive and action-oriented?
- [ ] **No overlap:** Does this recipe do something no other recipe in the project already does?

## Scope (REQUIRED)

- [ ] **Explicit capabilities:** Does the instructions block define what the agent can do (3-5 areas)?
- [ ] **Explicit constraints:** Are there at least 3 "NEVER"/"Do NOT" boundaries in the IMPORTANT block?
- [ ] **Extension least privilege:** Does `extensions:` list only the tools the agent actually needs?
- [ ] **No scope creep:** Does the recipe stay within its stated purpose throughout the instructions?

## Directives (REQUIRED)

- [ ] **Prescriptive language:** Are rules "Always X", "NEVER Y" — not "tries to" or "should consider"?
- [ ] **Process defined:** Is there a numbered step-by-step methodology in instructions?
- [ ] **Output format specified:** Is there a `Return:` block listing exact fields the agent must produce?
- [ ] **Edge cases handled:** Would the agent know what to do if inputs are empty, malformed, or out of scope?

## Parameters (REQUIRED)

- [ ] **Required params have no default:** Required parameters omit the `default:` field.
- [ ] **Optional params have defaults:** Every optional parameter has `default: ""` or another sensible default.
- [ ] **Valid input_type values:** All params use `string`, `number`, `boolean`, `date`, or `file`.
- [ ] **User-facing descriptions:** Each param description tells the user what to provide, not internal jargon.
- [ ] **Template vars match:** Every `{{ param_name }}` in `prompt:` and `instructions:` has a matching parameter entry.

## Recipe Validation (REQUIRED)

- [ ] **Passes goose recipe validate:** The recipe validates without errors.
- [ ] **Version present:** `version: 1.0.0` is set.
- [ ] **No conditional templates:** Instructions do not use `{{ if }}...{{ endif }}`.
- [ ] **Multi-line strings use block scalar:** All multi-line fields use `|` notation.

## Failure Handling (REQUIRED for multi-agent recipes)

- [ ] **Retry limits defined:** Agent retry count is capped (e.g., "2 retries for malformed output").
- [ ] **Loop limits defined:** Build-review or iterative loops have a maximum iteration count.
- [ ] **Circuit breaker present:** Repeated same-failure triggers a halt and escalation.
- [ ] **Escalation is visible:** Pipeline halts produce structured escalation packets, not silent failure.

## Context Architecture (REQUIRED)

- [ ] **Project context read:** Recipe reads `.goose/team_context.md` for project-specific context.
- [ ] **Sub-recipe paths valid:** All `sub_recipes:` paths resolve to existing YAML files.
- [ ] **RIL agent paths valid:** Any `~/ClaudeInfra/ril-agents/` references point to agents that exist.

## Success Criteria (REQUIRED)

- [ ] **Return block is measurable:** Each Return field is verifiable (not "good code" — "diff of changes").
- [ ] **Handoff contracts defined:** If agents pass data between each other, the exact shape is specified.

## Teaching Integration (REQUIRED for training recipes)

- [ ] **Teaching state check:** Step 1 reads `progression.json` and branches on status.
- [ ] **Runtime isolation:** Teaching mode includes the RUNTIME ISOLATION preamble.
- [ ] **Teaching script reference:** Teaching mode reads the correct `.teach.md` file.
- [ ] **Graceful fallback:** If the teaching script doesn't exist, falls back to working mode.
- [ ] **Progression update:** Teaching mode updates `progression.json` on completion.
- [ ] **Working mode standalone:** Working mode functions without teaching infrastructure.

## Quality (RECOMMENDED)

- [ ] **Escalation triggers documented:** Recipe states when to stop and involve a human.
- [ ] **Anti-patterns listed:** 2-3 "do NOT do this" examples in the IMPORTANT block.

---

## Quality Detectors

Run these 6 checks on any recipe (adapted from SubagentForge's Metacog detectors):

| Detector | Trigger | Question |
|----------|---------|----------|
| **Ghost User** | Recipe claims to serve "users" without naming a scenario | "Who specifically is affected if this recipe fails?" |
| **Fog** | Instructions use aspirational language (smart, relevant, appropriate) | "What work is this word doing that hasn't been specified?" |
| **Accountability** | Recipe has capabilities but no correctness definition | "What does 'correct' mean here — how would you know if it was wrong?" |
| **Scope Creep** | Capability list exceeds stated role | "Could this be two recipes instead of one?" |
| **Trust Mismatch** | Recipe has write access but no failure handling | "What's the consequence of a silent failure?" |
| **Intent Gap** | Recipe optimizes for a proxy metric, not the actual goal | "When the metric improves but the user is worse off, what happens?" |
