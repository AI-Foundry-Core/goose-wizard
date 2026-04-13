# Schedule

Optional — defines what varies per cycle. If absent, every cycle runs identically.
Each column becomes a parameter passed to every recipe in that cycle.

| Cycle | Persona | Teaching Script | Edge Cases |
|-------|---------|----------------|------------|
| 1 | priya_eager | stage-1/bug-fix | E3_skip |
| 2 | vikram_senior | stage-1/test-writer | E7_copilot |
| 3 | deepak_hostile | stage-1/code-review | E1_refuses |

**Rules:**
- Column headers become param names (lowercased, spaces → underscores)
- The `Cycle` column must match cycle numbers (1, 2, 3...)
- Empty cells are passed as empty strings
- Add any columns you need — they all become recipe params
