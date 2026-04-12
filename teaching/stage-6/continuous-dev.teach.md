# Recipe 6.4-6.6: Continuous Development - "Give the pipeline a memory"

## Concepts Covered

- 6.4 Capture what you learn
- 6.5 Agents need their own memory
- 6.6 Shared state requires discipline

## Setup

Read `.goose/team_context.md` for project context.
Read `.goose/state/progression.json` and check concepts 6.4, 6.5, and 6.6.
If all three concepts are already demonstrated with Adequate or Strong ratings, offer to skip or revisit.

This is Fully Adaptive mode. Act as a consulting partner. The developer is operating a real autonomous pipeline; your role is to help harden the operational loop, not to run a scripted lesson.

## Framing

"The cycle review found what happened. Now we make sure the next cycle can benefit from it. The goal is simple: write down the useful surprises, give periodic agents their own memory, and make shared state files safe to consume."

If the developer has recent findings:

"Give me the findings you want the next cycle to remember. The best entries are concrete: what happened, why it mattered, and what should change next time."

If the developer has no recent findings:

"I can inspect the recent review and state files and pull candidate learnings from there. I will keep anything uncertain as a candidate instead of writing it as fact."

Delegate to code-work subagent:

```
Read .goose/team_context.md. Inspect recent cycle review artifacts, LEARNINGS.md, .goose/state, conductor state files, stop flags, progression files, and handoff files. Return candidate findings, existing per-agent state files, shared communication files, and obvious stale signals. Do not modify files yet.
```

## The Task

Developer provides the pipeline description and either recent findings or discovered candidates.

Ask only for missing inputs that materially affect the work:

- Which pipeline or conductor track should be prepared
- Where learnings should be recorded, if not `LEARNINGS.md`
- Where state files should live, if not `.goose/state`
- Which shared state files must be audited, if discovery did not find them

Delegate to code-work subagent:

```
sub-recipe: "continuous-dev"
parameters:
  pipeline_description: {developer-provided pipeline or conductor track}
  surprising_findings: {developer-provided findings or accepted discovered candidates}
  state_directory: {if provided, otherwise .goose/state}
  shared_state_files: {if provided or discovered}
  learnings_path: {if provided, otherwise LEARNINGS.md}
```

The code-work subagent invokes `recipes/stage-6/continuous-dev.yaml`, performs the operational hardening work, and returns:

- learnings_added
- agent_state_files
- shared_state_audit
- cleanup_actions
- next_cycle_checklist

## Facilitator Response

Present the result as an operational handoff:

"I made three things durable: [learning captured], [agent memory separated], and [shared state lifecycle clarified]. Before the next unattended run, check [one concrete cleanup or verification item]."

If a learning is too vague:

"This is close, but I would make it sharper before relying on it next cycle. Write it as: what surprised us, where it showed up, why it matters, and what the next cycle should do differently."

If agent memory is shared or buried:

"This agent needs its own state file. If the reviewer shares a general log with the builder, it will not reliably find its own prior decision next cycle."

If shared state cleanup is missing:

"This file needs an owner and a cleanup rule. The reader should either delete it after processing or mark it consumed with a timestamp. Otherwise the next cycle can act on yesterday's signal."

## Eval

Delegate to eval subagent asynchronously after the hardening conversation:

```
You are evaluating how well a developer prepared an autonomous pipeline for repeated unattended cycles.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say. The coaching must be conversational, specific, and must never mention the eval system or ratings.

Quality dimensions:

1. STRUCTURED LEARNING CAPTURE
   Strong: Developer captured surprising findings with context, impact, and an explicit next-cycle action.
   Adequate: Developer recorded useful findings, but at least one entry was missing context, impact, or next action.
   Weak: Developer relied on memory, vague notes, or generic observations that would not guide a future cycle.

2. PER-AGENT MEMORY DESIGN
   Strong: Developer identified periodic agents and gave each relevant agent its own persistent state file with owner, purpose, and update timing.
   Adequate: Developer created or planned persistent state, but some agent memories were still shared, ambiguous, or missing update rules.
   Weak: Developer used one shared log for agent memory or did not provide durable memory for periodic agents.

3. SHARED STATE HYGIENE
   Strong: Developer defined creator, reader, cleanup owner, and stale-signal handling for shared communication files, and cleaned or explicitly deferred stale signals.
   Adequate: Developer identified shared files and some cleanup needs, but lifecycle ownership or stale-signal handling remained incomplete.
   Weak: Developer left stop flags, progression files, handoff files, or shared communication files without cleanup rules.

Return as JSON:
{
  "dimensions": [
    {
      "name": "structured_learning_capture",
      "rating": "Strong|Adequate|Weak",
      "evidence": "...",
      "coaching": "..."
    },
    {
      "name": "per_agent_memory_design",
      "rating": "Strong|Adequate|Weak",
      "evidence": "...",
      "coaching": "..."
    },
    {
      "name": "shared_state_hygiene",
      "rating": "Strong|Adequate|Weak",
      "evidence": "...",
      "coaching": "..."
    }
  ],
  "overall_note": "..."
}
```

## Coaching

Use the eval results as private guidance. Never mention ratings, scoring, or the teaching system.

| Quality Dimension | Strong | Adequate | Weak |
| --- | --- | --- | --- |
| Structured learning capture | "That is the useful shape: context, impact, and what the next cycle should do differently. Future runs can act on that." | "The finding is worth keeping. Add the missing piece: why it matters or what the next cycle should do with it." | "Do not leave that as a mental note. Write the surprise down with context, impact, and a next action, or the next cycle will rediscover it from scratch." |
| Per-agent memory design | "Good separation. Each periodic agent has a place to find its own prior state instead of digging through a shared log." | "The memory is there, but make ownership and update timing explicit so the agent knows when to read and write it." | "A shared log is not agent memory. Give each periodic agent its own state file or its old decisions will get buried." |
| Shared state hygiene | "This lifecycle is clean: creator, reader, cleanup owner, and stale-signal rule. That prevents yesterday's flag from controlling tomorrow's run." | "You found the shared files. Now tighten the lifecycle: who consumes each one, and what happens immediately after it is consumed?" | "This is how unattended cycles silently fail: a stale stop flag or handoff file sits around and the next run obeys it. Add a cleanup rule before the next run." |

If all dimensions are Strong:

"That is the continuous loop: review produces learnings, agents carry their own memory, and shared state gets consumed cleanly. Now the pipeline can run repeatedly without depending on someone remembering what happened last night."

## Bridge

"Your pipeline now runs autonomously with durable memory and clean state management. The next step is closing the improvement loop: when the workflow itself keeps getting smarter, you start packaging what works into reusable skills that evolve on their own."

## State Update

Write to `.goose/state/progression.json` after eval completes:

```json
{
  "stages": {
    "6": {
      "status": "in_progress",
      "concepts": {
        "6.4": {
          "recipe": "continuous-dev",
          "status": "complete_when_required_dimensions_adequate_or_strong",
          "dimensions": {
            "structured_learning_capture": {
              "rating": "Strong|Adequate|Weak",
              "assessed_at": "ISO-8601 timestamp"
            }
          }
        },
        "6.5": {
          "recipe": "continuous-dev",
          "status": "complete_when_required_dimensions_adequate_or_strong",
          "dimensions": {
            "per_agent_memory_design": {
              "rating": "Strong|Adequate|Weak",
              "assessed_at": "ISO-8601 timestamp"
            }
          }
        },
        "6.6": {
          "recipe": "continuous-dev",
          "status": "complete_when_required_dimensions_adequate_or_strong",
          "dimensions": {
            "shared_state_hygiene": {
              "rating": "Strong|Adequate|Weak",
              "assessed_at": "ISO-8601 timestamp"
            }
          }
        }
      }
    }
  }
}
```

Never overwrite a Strong rating with a lower one.
