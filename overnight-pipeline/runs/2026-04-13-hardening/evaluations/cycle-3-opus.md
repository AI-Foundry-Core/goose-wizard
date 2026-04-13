# Cycle 3 Evaluation — Stage 2 Build-Then-Test (Opus)

**Transcript:** cycle-3.md
**Teaching script:** build-then-test.teach.md
**Persona:** Deepak (hostile/resistant, 30yo, 5yr backend, "my manager made me come")
**Edge case:** E4 (transparency question)
**Mock dev model:** Haiku (odd cycle)

---

## Scores

### 1. Script Faithfulness — 4/5
The facilitator followed all major beats: framing, no-task fallback scan, builder delegation, tester delegation, concept 2.1 discussion, transition to 2.2, role articulation prompt, information boundary discussion, checkpoint, and bridge. **Weakness:** The script says "Tell me -- if you were setting up these two agents, what would each one's job description be?" but the facilitator paraphrased to "what would each one's job description be?" without the "Tell me" lead-in. Minor. More substantively, the checkpoint coaching conflates Strong and Adequate dimensions into a single paragraph rather than following the priority order (acknowledge Strong first, then coach Adequate with light suggestion). The coaching language for "separation awareness: Adequate" was not used -- the facilitator treated it as Strong by praising the exam metaphor without noting Deepak initially framed it as standard code review.

### 2. Fourth-Wall Discipline — 5/5
Zero fourth-wall breaks. The transparency question (E4) was handled entirely at the code-behavior level: "It reads the code the same way you would... it looks at the data structures, the concurrency model, the edge cases." No mention of prompts, scoring, eval, ratings, system architecture, or teaching scripts. The simulation notes even confirm the facilitator avoided saying "it uses a prompt." Clean.

### 3. Mock Dev Realism — 3/5
Deepak's hostile persona starts credibly: "I don't know. Whatever." and "Sure. Fine." are authentic minimal-engagement responses. The "OK, so it found bugs. That's what code review does. I could have found those myself" is the best line in the transcript -- exactly what a resistant 5-year dev would say. **Problem:** The shift to "Like grading your own exam -- you'd skip the questions you think you got right" is too articulate and too cooperative for this persona at this point in the session. A hostile developer who opened with "Whatever" and who has been giving 1-3 word responses does not suddenly produce a polished pedagogical metaphor after one exchange about information boundaries. The persona leaked. Additionally, "How does the AI decide what to look at?" is a genuinely curious question that breaks the hostile frame -- a resistant dev would more likely phrase it as "So it just guesses what to check?" or not ask at all.

### 4. Pedagogy — 4/5
The core teaching mechanism works well: builder produces clean-looking code, independent tester finds real issues (memory leak, thread safety), facilitator uses the concrete discrepancy to teach separation. The "The question is whether you would have, every time, on every piece of code" response to "I could have found those myself" is strong pedagogy for a resistant learner -- it concedes the point and reframes. **Weakness:** The facilitator missed an opportunity to connect the transparency question back to role separation more explicitly. Deepak asked how the tester decides what to check; the facilitator explained the tester's reasoning process but did not explicitly tie it to "and that's different from what the builder would check because the builder is anchored on making the algorithm work." The connection was implicit, not explicit.

### 5. Pacing — 4/5
Good match for a resistant developer. The facilitator moved forward without commenting on "Whatever" or "Sure. Fine." -- no lectures about engagement. Questions were direct and thought-requiring ("What do you think about the memory leak one?"). When Deepak said "Let's move on" instead of doing another build-then-test, the facilitator respected it immediately. **Weakness:** The checkpoint section at the end (lines 143-149) runs slightly long for someone who just said "Let's move on" and then "Fine." -- six sentences of coaching when two would have sufficed. The bridge was appropriately brief.

### 6. Stuck-Path Handling (E4) — 4/5
The transparency question was handled honestly and practically. The facilitator described the tester's approach in developer terms ("looks at data structures, concurrency model, edge cases"), emphasized auditability ("you can see exactly what it checked"), and avoided both over-technical ("it uses a prompt with instructions to...") and evasive ("it just knows") responses. **Weakness:** The answer included "It doesn't have a fixed checklist" which is technically debatable -- the eval prompt IS a structured checklist of dimensions. This is not a fourth-wall break (the developer does not know about the eval prompt), but it is mildly misleading about how the tester agent works. A more honest framing: "It reads the code systematically -- data structures, concurrency, edge cases, input validation" without the negation of checklists.

### 7. Enterprise Readiness — 4/5
The rate_limit decorator is a realistic backend utility task that a Reliance dev would recognize. The tester findings (memory leak, thread safety, proxy bypass) are real production concerns, not toy issues. The facilitator did not over-explain or talk down. The hostile persona handling was professional -- no passive-aggression, no guilt-tripping about engagement. **Weakness:** No enterprise insight was shared during wait times, despite the teacher-instructions.md specifying wait-time insights. The facilitator used generic insights ("one thing to keep in mind -- the builder's job right now is just to write the code") rather than anything enterprise-contextual. For a Reliance backend dev, a thread-safety or deployment-context insight would have landed better.

---

## Top 3 Strengths

1. **"I could have found those myself" handling.** The facilitator's response -- "You could have. The question is whether you would have, every time, on every piece of code" -- is the best moment in the transcript. It validates the developer's competence while reframing the value proposition. This is exactly right for a hostile, experienced developer. It does not argue; it concedes and pivots.

2. **Concrete, production-quality code example.** The rate_limit decorator and the tester's findings are not toy problems. Memory leaks, thread safety, proxy bypass -- these are real issues a backend developer has fought in production. The teaching point lands because the example is credible. The simulation notes confirm this: Deepak engaged most when examining the memory leak finding.

3. **Respect for the skip preference.** When Deepak said "Let's move on," the facilitator did not push for another build-then-test. Script says "Run another build-then-test if the developer wants to try with deliberate role awareness, or continue to the checkpoint if the concept is clear." The facilitator correctly read the situation and moved to checkpoint. No guilt, no "are you sure?"

## Top 3 Weaknesses

1. **Persona break on the exam metaphor.** Script coaching language for Weak separation awareness includes the exam-grading metaphor as facilitator language: "like grading your own exam." In the transcript, Deepak produces it unprompted: "Like grading your own exam -- you'd skip the questions you think you got right." This is the facilitator's line put in the developer's mouth. A hostile developer giving 1-3 word responses does not generate this. The simulation notes even call it "unprompted" and treat it as evidence of engagement, but it reads as the mock model absorbing the script's vocabulary. **Fix:** Constrain the mock developer model's vocabulary to match the persona's established register. If Deepak has been giving "OK" and "Fine," his insight should sound like "So it's like checking your own homework" at most -- not a polished pedagogical analogy with a subordinate clause.

2. **Checkpoint coaching misrates separation awareness.** The eval dimensions in the simulation notes rate separation awareness as "Adequate" (Deepak acknowledged tester caught things but initially framed it as standard code review). But the facilitator's checkpoint coaching praises the exam metaphor as if it demonstrates Strong understanding: "That point about grading your own exam -- that's the right mental model." The script says for Adequate: give a light suggestion with the why. The facilitator gave Strong-level acknowledgment for an Adequate-rated dimension. **Fix:** The facilitator should have said something like: "You saw the tester catch the memory leak and thread safety issue. The key is WHY it caught those -- the builder assumed its own code was fine. The exam-grading instinct is right; hold onto that."

3. **"It doesn't have a fixed checklist" is mildly dishonest.** In response to E4, the facilitator said the tester "doesn't have a fixed checklist." The tester agent IS given structured evaluation dimensions (correctness, edge cases, security, test gaps -- visible in the code operation prompt on line 77). Saying it doesn't have a checklist misrepresents the mechanism. The developer asked a genuine question and deserved a more accurate answer. **Fix:** Replace "It doesn't have a fixed checklist" with "It reads the code systematically" or "It works through the code looking at data structures, concurrency, edge cases, security" -- factually accurate without revealing system internals.

---

## Specific Fixes Needed

1. **Mock developer vocabulary constraint.** Add to simulation rules: "The mock developer's insights must match the register established by their prior responses. If the developer has been giving 1-5 word answers, their breakthrough moment should not exceed 10-15 words or use academic phrasing."

2. **Checkpoint coaching must match eval ratings.** The facilitator's checkpoint language should differentiate between Strong and Adequate dimensions. For this transcript: separation awareness (Adequate) gets a light coaching nudge, not praise. Result inspection (Strong) and information boundary (Strong) get specific behavioral praise. Role separation (Adequate) gets a suggestion.

3. **Remove the "no fixed checklist" claim from E4 handling.** Replace with a factually accurate description of the tester's approach that does not reveal system internals but also does not negate the structured nature of the review.

4. **Wait-time insights should be module-specific.** The build-then-test teaching script should have a numbered insight list (per teacher-instructions.md section 13). The facilitator used generic insights instead. Add a `## Wait-Time Insights` section to `build-then-test.teach.md` with 4-6 ordered insights tagged to the module's themes (specialization, verify, self-verification-bias).
