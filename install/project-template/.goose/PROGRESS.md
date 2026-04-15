# Goose Training Progress

**Run all commands from the RILGoose repo directory** (the folder that
contains this file). Then copy-paste the command for the module you
want to run.

Each training module ends by checking off its entry here and telling
you the next command — so after your first run, you can come back to
this file anytime to see where you are and what's next.

---

## Stage 0 — See What AI Can Do

- [ ] **1. See What AI Can Do** — AI reads and edits your code, everything is reversible, AI makes mistakes, you control quality
  ```
  goose run --recipe recipes/shared/01-see-what-ai-can-do.yaml --interactive
  ```

## Stage 1 — Get Real Work Done

- [ ] **2. Bug Fix** — Give AI the right context and get a fix in one pass
  ```
  goose run --recipe recipes/shared/02-bug-fix.yaml --interactive
  ```

- [ ] **3. Test Writer** — AI writes tests from your specs, you verify coverage
  ```
  goose run --recipe recipes/shared/03-test-writer.yaml --interactive
  ```

- [ ] **4. Code Review** — AI reviews code, you learn to evaluate its findings
  ```
  goose run --recipe recipes/shared/04-code-review.yaml --interactive
  ```

- [ ] **5. Refactor** — AI restructures code while preserving behavior
  ```
  goose run --recipe recipes/shared/05-refactor.yaml --interactive
  ```

## Stage 2 — Two AIs Are Better Than One

- [ ] **6. Build Then Test** — Two AIs: one builds, a separate one verifies independently
  ```
  goose run --recipe recipes/shared/06-build-then-test.yaml --interactive
  ```

- [ ] **7. Review Gate** — Independent pass/fail gate backed by execution evidence
  ```
  goose run --recipe recipes/shared/07-review-gate.yaml --interactive
  ```

- [ ] **8. Spec First** — Define success criteria before any agent starts building
  ```
  goose run --recipe recipes/shared/08-spec-first.yaml --interactive
  ```

## Stage 3 — Build a Team of AI Specialists

- [ ] **9. Three-Agent Pipeline** — Spec, build, and review agents with explicit contracts
  ```
  goose run --recipe recipes/shared/09-three-agent-pipeline.yaml --interactive
  ```

- [ ] **10. Parallel Reviewers** — Multiple reviewers on different layers, findings merged safely
  ```
  goose run --recipe recipes/shared/10-parallel-reviewers.yaml --interactive
  ```

- [ ] **11. Escalation Routing** — Circuit breakers and failure routing for agent pipelines
  ```
  goose run --recipe recipes/shared/11-escalation-routing.yaml --interactive
  ```

## Stage 4 — From Idea to Buildable Spec

- [ ] **12. Idea to Spec** — Turn a vague idea into a concrete, buildable specification
  ```
  goose run --recipe recipes/shared/12-idea-to-spec.yaml --interactive
  ```

- [ ] **13. Spec Decomposition** — Organize specs by persona, make every requirement testable
  ```
  goose run --recipe recipes/shared/13-spec-decomposition.yaml --interactive
  ```

- [ ] **14. Spec Review** — AI-assisted quality gates and kill criteria for specs
  ```
  goose run --recipe recipes/shared/14-spec-review.yaml --interactive
  ```

- [ ] **15. Spec to Pipeline** — Trace requirements to tests to build plans
  ```
  goose run --recipe recipes/shared/15-spec-to-pipeline.yaml --interactive
  ```

## Stage 5 — Trust But Verify

- [ ] **16. Eval Foundation** — Build independent verification that catches real problems
  ```
  goose run --recipe recipes/shared/16-eval-foundation.yaml --interactive
  ```

- [ ] **17. Eval Design** — Write eval criteria specific enough to find real issues
  ```
  goose run --recipe recipes/shared/17-eval-design.yaml --interactive
  ```

- [ ] **18. Eval Layers** — Layer evals by cost and failure type for efficient coverage
  ```
  goose run --recipe recipes/shared/18-eval-layers.yaml --interactive
  ```

- [ ] **19. Eval Gate** — Blocking quality gates that must pass before code ships
  ```
  goose run --recipe recipes/shared/19-eval-gate.yaml --interactive
  ```

- [ ] **20. Eval Isolation** — Mock external dependencies so evals run reliably every time
  ```
  goose run --recipe recipes/shared/20-eval-isolation.yaml --interactive
  ```

- [ ] **21. Eval Ratchet** — Quality thresholds that only go up, preventing regression
  ```
  goose run --recipe recipes/shared/21-eval-ratchet.yaml --interactive
  ```

## Stage 6 — Let It Run While You Sleep

- [ ] **22. Continuous Dev** — Give pipelines memory: learning capture, agent state, shared state
  ```
  goose run --recipe recipes/shared/22-continuous-dev.yaml --interactive
  ```

- [ ] **23. Cycle Review** — Review overnight runs: what worked, what failed, what to tune
  ```
  goose run --recipe recipes/shared/23-cycle-review.yaml --interactive
  ```

## Stage 7 — The System Gets Smarter

- [ ] **24. Metrics Dashboard** — Measure pipeline impact with real data, not intuition
  ```
  goose run --recipe recipes/shared/24-metrics-dashboard.yaml --interactive
  ```

- [ ] **25. Pipeline Self-Edit** — Deduplicate rules, resolve conflicts, audit guardrails
  ```
  goose run --recipe recipes/shared/25-pipeline-self-edit.yaml --interactive
  ```

- [ ] **26. Skill Evolution** — The curator loop: findings become instructions, instructions evolve
  ```
  goose run --recipe recipes/shared/26-skill-evolution.yaml --interactive
  ```
