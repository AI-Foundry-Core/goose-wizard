# 12-Cycle Plan

The planner can override this schedule based on findings, but this is the default sequence.

## Mock Developer Model Alternation
- **Odd cycles (1, 3, 5, 7, 9, 11):** Haiku subagent generates mock developer responses in real-time during simulation
- **Even cycles (2, 4, 6, 8, 10, 12):** GPT 5.4 (Codex) generates all mock developer responses upfront in a single call, then the Opus simulator weaves them into the transcript

This provides genuine model diversity in personality modeling — different weights produce different behavior patterns, preventing self-play convergence.

## Cycle Sequence

| Cycle | Type | Stage | Recipe | Personality | Mock Dev Model | Forced Edge Cases | Rationale |
|-------|------|-------|--------|-------------|----------------|-------------------|-----------|
| 1 | Test | 0 | — | Priya (eager) | Haiku | E9: accepts without checking | Stress-test verification coaching with someone who never checks |
| 2 | Test | 0 | — | Vikram (senior) | GPT 5.4 | E6: wants to skip, E2: catches bug immediately | Test adaptive shortcuts and immediate-catch path |
| 3 | Test | 1 | bug-fix | Deepak (hostile) | Haiku | E5: has no bug, E4: asks transparency Q | Hostile dev on stuck path + transparency question |
| 4 | Test | 1 | test-writer | Ananya (anxious) | GPT 5.4 | E3: semi-specific instruction (adapted to test scope) | Junior dev, test pacing and encouragement |
| 5 | Test | 1 | code-review | Sneha (enterprise) | Haiku | E8: data privacy, E7: compares to Copilot | Enterprise dev, FAQ stress test |
| 6 | Test | 1 | refactor | Karthik (multitasker) | GPT 5.4 | E13: goes off-topic, E12: back-to-back waits | Half-attention, out-of-order handling |
| 7 | **Regression** | 0 | — | Priya (eager) | Haiku | (none forced) | Re-test cycle 1's personality against any scripts changed in cycles 1-6 |
| 8 | Test | 0 | — | Meera (quiet) | GPT 5.4 | E1: refuses edit, E11: too-simple function | Quiet dev, untested stuck paths |
| 9 | Test | 1 | bug-fix | Ravi (all-strong) | Haiku | E10: all-strong input | Fast-track path, all-Strong coaching |
| 10 | **Regression** | 1 | test-writer | Ananya (anxious) | GPT 5.4 | (none forced) | Re-test cycle 4's personality against changes from cycles 4-9 |
| 11 | Test | 0 | — | Arjun (curious) | Haiku | E4: transparency Q, E14: gives session feedback | Curiosity management, fourth-wall test |
| 12 | Test | 1 | code-review | Deepak (hostile) | GPT 5.4 | E6: wants to skip, E9: all-weak input | Hostile + all-weak: maximum coaching pressure |

## Cycle type rules
- **Test:** New personality + edge case. Evaluators assess, decision-maker may fix.
- **Regression:** Re-run a previous personality. If quality dropped, revert last fixes.

## Mock developer model rules
- **Haiku (odd):** Spawned as a subagent within the simulator at each Check point. Persona + conversation context passed each time. Real-time interaction.
- **GPT 5.4 (even):** Single Codex call before simulation starts. Receives: persona definition, full teaching script structure with all Check points, edge cases to force. Generates all developer responses upfront. Simulator reads and weaves them into the transcript.
- **If Codex fails on an even cycle:** Fall back to Haiku for that cycle. Log the failure. If Codex fails 3+ times total, planner switches all remaining cycles to Haiku.

## Planner override rules
- If a cycle reveals a critical script bug, planner may insert an extra regression cycle
- If evaluator plateau detected (no new findings for 2 consecutive cycles), planner shifts to untested edge cases
- If Codex fails 3 times, planner removes Codex dependency from remaining cycles
