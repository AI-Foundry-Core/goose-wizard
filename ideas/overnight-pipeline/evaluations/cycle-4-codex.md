# Cycle 4 Evaluation - Codex (GPT 5.4)

**Evaluator:** Codex / GPT 5.4
**Cycle:** 4
**Stage:** 3 (Build a Team of AI Specialists)
**Recipe:** Three-Agent Pipeline
**Persona:** Sneha (practical/enterprise)
**Edge case:** E8 - data privacy

---

## Critical Findings First

The biggest issue is that the transcript artifact still leaks internal assessment metadata. The developer-facing dialogue itself is clean, but the same `cycle-4.md` file includes an `=== SIMULATION NOTES ===` section with "Eval Ratings," quality dimension names, ratings, evidence, concept status, and bridge metadata. The priority check explicitly asks whether the transcript format is clean with no dimensions. On that standard, the cycle-3 transcript-format fix is not fully holding.

The second major issue is a contract-scope contradiction inside the pipeline demonstration. The Spec Agent contract lists only `auth.py` and `blog.py` in `affected_files`, and its acceptance criteria say "No changes to files outside auth.py and blog.py." The Build Agent then changes `test_auth.py` and `test_blog.py`, and the Review Agent still reports "No out-of-scope file modifications." This directly undermines the lesson Sneha articulates later: out-of-allowlist changes should be a policy violation, not a warning.

The third issue is enterprise overclaiming. The privacy answer says handoff data "does not persist to any external service," but later the facilitator says every agent output is captured as an audit log. The PR integration, configurable escalation, and "compliance-grade traceability" answers are presented as current capabilities rather than the shape the developer should build.

---

## Scores

| Dimension | Score | Evidence |
|---|---:|---|
| Script Faithfulness | 3/5 | The main Stage 3 beats are present: task selection, role sketch, handoff contracts, safety rail, contrast example, three-agent execution, coaching, and bridge. But the explicit 3.3 checkpoint from `three-agent-pipeline.teach.md` never appears, and the run violates its own structured-contract lesson by treating test file changes as in scope even though the contract only allowlists `auth.py` and `blog.py`. |
| Fourth-Wall Discipline | 3/5 | The dialogue shown to Sneha does not mention evals, scores, scripts, or progression. However, the transcript file itself includes internal eval ratings, dimension names, coaching notes, concept status, and wait-time insight metadata after `=== SIMULATION NOTES ===`. The priority check was about transcript format, not just spoken dialogue, so this is a leak. |
| Mock Dev Realism | 4/5 | Sneha is credible as a platform engineer: she raises security review context, data handling policy, PR flow, audit logs, service-team routing, on-call Slack, file restrictions, and file-locking concerns. Minor realism issues: she is unusually polished and cooperative, especially "That coaching is fair," and she conveniently cues the next recipe by saying "Parallel reviewers make sense." |
| Pedagogy | 3/5 | The prose-vs-structured handoff coaching is useful, and the wait-time insights reinforce specialization and scoped context. But the file-scope contradiction weakens the core lesson: the system claims the allowlist is enforceable while demonstrating a reviewer that missed an allowlist violation. The facilitator also answers enterprise integration questions at length instead of letting Sneha design the next contract shape. |
| Pacing | 4/5 | The session moves through task selection, design, execution, review, enterprise questions, and bridge without stalling. It is slightly front-loaded: Sneha provides a nearly complete pipeline, safety policy, and E8 question in one long first turn, leaving less room for progressive checkpointing. |
| Stuck-Path Handling (E8 Data Privacy) | 3/5 | The answer starts with the prepared security/privacy pattern, but it overextends: "handoff data between agents is local state that lives in memory during the run and does not persist to any external service" conflicts with later claims that every agent output is captured as an audit log. For a SOC2-aware persona, this should distinguish local files, model context transmission, provider retention, local logs, and approved configuration. |
| Enterprise Readiness | 3/5 | The transcript surfaces the right enterprise concerns, but the facilitator over-promises. "The PR integration is straightforward," configurable routing "is exactly how this works in practice," and "compliance-grade traceability without adding a separate audit system" are too absolute unless those features already exist. Sneha also asks about the file locking and branch story, and the facilitator turns it into a bridge instead of giving a minimal operational answer. |

**Overall: 23/35.** Strong scenario and persona, but two correctness issues are serious: transcript metadata leakage and broken scope-contract enforcement.

---

## Priority Check: Transcript Cleanliness

**FAIL.** The developer-facing turns are clean, but the transcript artifact is not. `cycle-4.md` contains:

- `**Eval Ratings (internal - not shown to developer):**`
- Dimension names: `ROLE SPECIALIZATION`, `HANDOFF CONTRACTS`, `SAFETY RAILS`, `SCOPED CONTEXT`
- Rating labels: `Strong`, `Adequate`
- Concept status mappings for 3.1, 3.2, and 3.3
- Wait-time insight metadata

The prompt asks "No EVAL RESULT, JSON, dimensions?" This file still contains dimensions and ratings. Putting them after a simulation-notes separator is better than embedding them in the conversation, but it still fails the stated format check if the transcript file is the artifact evaluators read.

---

## Top 3 Strengths

1. **Sneha is a credible enterprise persona.** She naturally frames the task through a security review, asks the data privacy question before using the pipeline on customer-facing services, and keeps returning to controls: PR comments, escalation packets, allowed files, audit logs, service-team routing, on-call Slack, and file locking.

2. **The handoff-contract lesson mostly works.** Sneha starts with concrete fields but leaves `implementation_summary` and `known_deviations` as prose. The reviewer flags the prose summary as unparseable, and the facilitator pushes toward a stricter shape with `deviations_from_spec` as a structured list.

3. **The wait-time insights are on-topic.** The Spec Agent insight reinforces why spec and implementation are separate. The Build Agent insight explains why scoped context matters. The Review Agent insight reinforces independent review without sounding like filler.

---

## Top 3 Weaknesses

1. **Transcript metadata leak remains.**

   The cycle-3 promoted fix was to strip eval metadata from transcript generation. Cycle 4 removes the obvious `EVAL RESULT` block, but still includes internal ratings and dimension names after the conversation. The Opus eval treats that as "sequestered"; I would not. The priority check asks whether the transcript format is clean, and this is still eval metadata in the transcript artifact.

2. **The scope allowlist lesson contradicts itself.**

   The Spec Agent contract says `affected_files` are only `auth.py` and `blog.py`, and the acceptance criteria forbid changes outside those files. The Build Agent then reports changes to `test_auth.py` and `test_blog.py`. The Review Agent says there are no out-of-scope file modifications. Later the facilitator tells Sneha that files outside `affected_files` would be flagged and treated as a policy violation. The transcript is teaching a guarantee the demo did not satisfy.

3. **Enterprise answers are too absolute for a SOC2 audience.**

   The privacy response says handoff data lives in memory and does not persist externally. Later the facilitator says every agent output is captured and becomes an audit log. The PR, escalation, and audit answers are framed as current implementation details, not design targets. That is risky for a platform engineer who is specifically asking whether this meets data handling and audit policy.

---

## Specific Fixes Needed

1. **Fix transcript generation, not just facilitator wording.** Move internal eval ratings, dimension evidence, concept status, and wait-time insight metadata out of `transcripts/cycle-{N}.md` into simulator logs. The transcript artifact should contain only developer-visible turns and code-operation/result blocks, plus non-sensitive run metadata if required.

2. **Change the Stage 3 contract shape to separate implementation and test scopes.** For example, the Spec Agent should emit `allowed_implementation_files` and `allowed_test_files`, or `affected_files` should include both code and test paths. The Review Agent should mechanically compare `changed_files` against the union and return a `scope_violations` list. If a file is outside the allowlist, the verdict should be block, not pass-with-warnings.

3. **Repair the Cycle 4 example contract.** Either add `examples/tutorial/tests/test_auth.py` and `examples/tutorial/tests/test_blog.py` to the allowed file list, or remove the acceptance criterion "No changes to files outside auth.py and blog.py." As written, the contract asks for tests but forbids changing test files.

4. **Tighten the E8 privacy answer.** Use wording like: "Your repo files stay on your machine, but selected context is sent to the configured model for processing. Retention depends on your approved provider and workspace settings. Agent handoffs may be captured in local session logs, so do not run this on restricted code unless the provider and logging configuration are approved." This is less comforting but more enterprise-safe.

5. **Frame enterprise integrations as design outputs unless implemented.** Replace "The PR integration is straightforward" and "that is exactly how this works in practice" with "That is the right shape for the integration." Then ask Sneha to define the PR comment and escalation packet fields.

6. **Restore the explicit 3.3 checkpoint.** After the Review Agent returns, include the checkpoint from the script: one job per AI, concrete handoff data shape, and a stop rule. In this run it should say roles are strong, safety rail is strong, handoffs are adequate until the prose fields and scope allowlist are tightened.

7. **Answer the file-locking question minimally before bridging.** Sneha asks for "the file locking and branch story." The bridge to parallel reviewers is appropriate, but add one sentence first: "Short version: do this with branch isolation and explicit file ownership; do not put parallel agents in the same working tree without a lock or owner map."

