# 12-Cycle Plan

The planner can override this schedule based on findings, but this is the default sequence.

| Cycle | Type | Stage | Recipe | Personality | Forced Edge Cases | Rationale |
|-------|------|-------|--------|-------------|-------------------|-----------|
| 1 | Test | 0 | — | Priya (eager) | E9: accepts without checking | Stress-test verification coaching with someone who never checks |
| 2 | Test | 0 | — | Vikram (senior) | E6: wants to skip, E2: catches bug immediately | Test adaptive shortcuts and immediate-catch path |
| 3 | Test | 1 | bug-fix | Deepak (hostile) | E5: has no bug, E4: asks transparency Q | Hostile dev on stuck path + transparency question |
| 4 | Test | 1 | test-writer | Ananya (anxious) | E3: semi-specific instruction (adapted to test scope) | Junior dev, test pacing and encouragement |
| 5 | Test | 1 | code-review | Sneha (enterprise) | E8: data privacy, E7: compares to Copilot | Enterprise dev, FAQ stress test |
| 6 | Test | 1 | refactor | Karthik (multitasker) | E13: goes off-topic, E12: back-to-back waits | Half-attention, out-of-order handling |
| 7 | **Regression** | 0 | — | Priya (eager) | (none forced) | Re-test cycle 1's personality against any scripts changed in cycles 1-6 |
| 8 | Test | 0 | — | Meera (quiet) | E1: refuses edit, E11: too-simple function | Quiet dev, untested stuck paths |
| 9 | Test | 1 | bug-fix | Ravi (all-strong) | E10: all-strong input | Fast-track path, all-Strong coaching |
| 10 | **Regression** | 1 | test-writer | Ananya (anxious) | (none forced) | Re-test cycle 4's personality against changes from cycles 4-9 |
| 11 | Test | 0 | — | Arjun (curious) | E4: transparency Q, E14: gives session feedback | Curiosity management, fourth-wall test |
| 12 | Test | 1 | code-review | Deepak (hostile) | E6: wants to skip, E9: all-weak input | Hostile + all-weak: maximum coaching pressure |

## Cycle type rules
- **Test:** New personality + edge case. Evaluators assess, decision-maker may fix.
- **Regression:** Re-run a previous personality. If quality dropped, revert last fixes.

## Planner override rules
- If a cycle reveals a critical script bug, planner may insert an extra regression cycle
- If evaluator plateau detected (no new findings for 2 consecutive cycles), planner shifts to untested edge cases
- If Codex fails 3 times, planner removes Codex dependency from remaining cycles
