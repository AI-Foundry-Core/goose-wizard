# 20-Cycle All-Stages Plan

Covers all 8 stages (0-7). Every stage gets at least 1 cycle; high-priority stages get 2-3.

## Mock Developer Model Alternation
- **Odd cycles (1, 3, 5, 7, 9, 11, 13, 15, 17, 19):** Haiku subagent generates mock developer responses in real-time
- **Even cycles (2, 4, 6, 8, 10, 12, 14, 16, 18, 20):** GPT 5.4 (Codex) generates all mock developer responses upfront in a single call
- **If Codex fails 3+ times:** All remaining even cycles fall back to Haiku

## Phase 1 — One Recipe Per Stage (8 cycles)

Test the entry-point recipe for each stage. These are the scripts developers encounter first.

| Cycle | Type | Stage | Recipe | Personality | Mock Model | Edge Cases | Rationale |
|-------|------|-------|--------|-------------|------------|------------|-----------|
| 1 | Test | 0 | (all 5 acts) | Priya (eager) | Haiku | E9: accepts without checking | Over-accepter stresses verification coaching |
| 2 | Test | 1 | bug-fix | Vikram (senior) | GPT 5.4 | E6: wants to skip | Senior dev tests adaptive respect for expertise |
| 3 | Test | 2 | build-then-test | Deepak (hostile) | Haiku | E4: transparency Q | Hostile dev on first multi-agent concept |
| 4 | Test | 3 | three-agent-pipeline | Sneha (enterprise) | GPT 5.4 | E8: data privacy | Enterprise dev on pipeline design |
| 5 | Test | 4 | idea-to-spec | Ananya (anxious) | Haiku | E3: semi-specific instruction | Anxious dev writing specs for the first time |
| 6 | Test | 5 | eval-foundation | Karthik (multitasker) | GPT 5.4 | E13: goes off-topic | Half-attention on verification fundamentals |
| 7 | Test | 6 | cycle-review | Arjun (curious) | Haiku | E4: transparency Q, E14: session feedback | Curious dev on autonomous ops review |
| 8 | Test | 7 | metrics-dashboard | Ravi (all-strong) | GPT 5.4 | E10: all-strong input | Natural dev on self-improvement metrics |

## Phase 2 — Second Recipe + Regression (6 cycles)

Test second-priority recipes and run first regression check.

| Cycle | Type | Stage | Recipe | Personality | Mock Model | Edge Cases | Rationale |
|-------|------|-------|--------|-------------|------------|------------|-----------|
| 9 | Test | 1 | test-writer | Meera (quiet) | Haiku | E5: has no task | Quiet dev on stuck path |
| 10 | Test | 2 | spec-first | Priya (eager) | GPT 5.4 | E9: accepts without checking | Eager dev on spec-driven development |
| 11 | Test | 3 | escalation-routing | Vikram (senior) | Haiku | E6: wants to skip | Senior dev on safety rails |
| 12 | Test | 4 | spec-to-pipeline | Deepak (hostile) | GPT 5.4 | E7: compares to Copilot | Hostile dev on capstone spec exercise |
| 13 | Test | 5 | eval-ratchet | Karthik (multitasker) | Haiku | E12: back-to-back waits | Multitasker on regression prevention |
| 14 | **Regression** | 0 | (all 5 acts) | Priya (eager) | GPT 5.4 | (none forced) | Re-test cycle 1 personality against fixed scripts |

## Phase 3 — Coverage Completion + Final Regression (6 cycles)

Fill remaining high-value recipes and run final regressions.

| Cycle | Type | Stage | Recipe | Personality | Mock Model | Edge Cases | Rationale |
|-------|------|-------|--------|-------------|------------|------------|-----------|
| 15 | Test | 1 | code-review | Sneha (enterprise) | Haiku | E8: data privacy | Enterprise dev on AI review workflow |
| 16 | Test | 6 | continuous-dev | Ananya (anxious) | GPT 5.4 | E5: has no task | Anxious dev on autonomous pipelines |
| 17 | Test | 7 | skill-evolution | Arjun (curious) | Haiku | E4: transparency Q | Curious dev on meta-learning |
| 18 | Test | 1 | refactor | Deepak (hostile) | GPT 5.4 | E1: refuses edit, E9: all-weak | Hostile + all-weak on most complex Stage 1 recipe |
| 19 | **Regression** | 3 | three-agent-pipeline | Sneha (enterprise) | Haiku | (none forced) | Re-test most complex stage against changes |
| 20 | **Regression** | 5 | eval-foundation | Karthik (multitasker) | GPT 5.4 | (none forced) | Re-test verification stage against changes |

## Coverage Summary

| Stage | Recipes Tested | Total Recipes | Coverage |
|-------|---------------|---------------|----------|
| 0 | 1 (all acts) + 1 regression | 1 | 100% |
| 1 | 4 | 4 | 100% |
| 2 | 2 | 3 | 67% (review-gate untested) |
| 3 | 2 + 1 regression | 3 | 67% (parallel-reviewers untested) |
| 4 | 2 | 4 | 50% (spec-decomposition, spec-review untested) |
| 5 | 2 + 1 regression | 6 | 33% (4 untested) |
| 6 | 2 | 2 | 100% |
| 7 | 2 | 3 | 67% (pipeline-self-edit untested) |

**Overall:** 17 of 26 unique sessions tested (65%). All stages have at least 1 recipe tested. Stage 5 has lowest coverage but eval-foundation + eval-ratchet cover the most critical concepts.

## Personality Coverage

| Personality | Cycles Used | Stages Touched |
|-------------|-------------|----------------|
| Priya (eager) | 1, 10, 14 (regression) | 0, 2 |
| Vikram (senior) | 2, 11 | 1, 3 |
| Deepak (hostile) | 3, 12, 18 | 2, 4, 1 |
| Sneha (enterprise) | 4, 15, 19 (regression) | 3, 1, 3 |
| Ananya (anxious) | 5, 16 | 4, 6 |
| Karthik (multitasker) | 6, 13, 20 (regression) | 5, 5, 5 |
| Arjun (curious) | 7, 17 | 6, 7 |
| Ravi (all-strong) | 8 | 7 |
| Meera (quiet) | 9 | 1 |

All 9 personas used. No personality used on the same stage twice (except regression).

## Cycle Type Rules
- **Test:** New recipe + personality. Evaluators assess, decision-maker may fix.
- **Regression:** Re-run a previous personality on the same recipe. If quality dropped 2+ points on any dimension, revert.

## Mock Developer Model Rules
- **Haiku (odd):** Spawned as a subagent within the simulator at each Check point.
- **GPT 5.4 (even):** Single Codex call before simulation starts. Generates all developer responses upfront. Simulator weaves them into the transcript.
- **If Codex fails:** Fall back to Haiku for that cycle. After 3 total Codex failures, all remaining even cycles use Haiku.

## Planner Override Rules
- If a critical script bug is found: insert a regression cycle next
- If no new findings for 2 consecutive cycles: shift to untested recipes
- If Codex fails 3+ times: remove Codex from remaining cycles
- Planner may swap recipes within the same stage if it judges another recipe is higher priority based on findings

## Morning Brief Schedule
- Written at cycles 7 (end of Phase 1), 14 (end of Phase 2), and 20 (final)
