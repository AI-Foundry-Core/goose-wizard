# Eval Subagent Prompt Template

## How to Use

When designing a module, write a custom eval prompt that evaluates the specific quality dimensions for that recipe. Use this template as the structure, but customize the dimensions and rating criteria.

The eval subagent runs async (`delegate(async: true)`) after the developer completes the task. It sees the full conversation transcript and rates each quality dimension.

## Template

```
You are evaluating how well a developer approached [TASK DESCRIPTION].

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript (quote or paraphrase what the developer said/did)
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. [DIMENSION NAME]
   Strong: [What strong looks like — specific, observable from transcript]
   Adequate: [What adequate looks like — partial, room for improvement]
   Weak: [What weak looks like — missing or poorly done]

2. [DIMENSION NAME]
   Strong: [...]
   Adequate: [...]
   Weak: [...]

[... more dimensions as needed, typically 3-4 per recipe]

Return as JSON:
{
  "dimensions": [
    {
      "name": "[dimension name]",
      "rating": "Strong|Adequate|Weak",
      "evidence": "[specific evidence from transcript]",
      "coaching": "[suggested facilitator language, or null if Strong]"
    }
  ],
  "overall_note": "[optional: any cross-cutting observation the facilitator should know]"
}
```

## Rules for Writing Dimension Criteria

- **Observable:** The eval subagent can only see the transcript. It can tell what the developer typed, what questions they asked, whether they requested tests be run, etc. It cannot see what the developer did outside the conversation.
- **Graduated:** There must be a meaningful difference between Strong, Adequate, and Weak. If you can't describe three distinct levels, it's probably binary (a gate, not a dimension).
- **Specific to this recipe:** Don't write generic criteria like "showed good understanding." Write "provided reproduction steps including expected vs actual behavior" for a bug fix recipe.
- **Coaching is conversational:** The facilitator will say this to the developer. It should sound like a colleague's advice, not a rubric score. Never reference the eval system.

## Conditional Dimensions

Some dimensions only apply if a specific situation occurs (e.g., "redirect on struggle" only matters if the AI actually struggled). For these:

```
3. [CONDITIONAL DIMENSION NAME]
   Condition: Only rate this if [CONDITION — e.g., "the AI took 3+ attempts to solve the problem"]
   If condition not met: return {"name": "...", "rating": null, "evidence": "Not triggered — [reason]", "coaching": null}
   Strong: [...]
   Adequate: [...]
   Weak: [...]
```
