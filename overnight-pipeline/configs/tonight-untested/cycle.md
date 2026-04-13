# Cycle Steps — Untested Recipes Hardening

| Step | Recipe | Timeout | Name |
|------|--------|---------|------|
| 1 | overnight-pipeline/recipes/simulate-session.yaml | 600 | simulate-session |
| 2 | overnight-pipeline/recipes/evaluate-transcript.yaml | 300 | evaluate-transcript |
| 3 | overnight-pipeline/recipes/classify-findings.yaml | 180 | classify-findings |
| 4 | overnight-pipeline/recipes/apply-fixes.yaml | 300 | apply-fixes |
| 5 | overnight-pipeline/recipes/plan-next-cycle.yaml | 180 | plan-next-cycle |
