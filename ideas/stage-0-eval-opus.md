# Stage 0 Mock Test Evaluation

## Overall Verdict

The transcript demonstrates a competent execution of the Stage 0 teaching scripts with strong pedagogical beats in Acts 1, 4, and 5. The facilitator mostly follows the Say/Check/Action structure and maintains fourth-wall discipline throughout. However, the mock reveals several script gaps that would cause problems with real developers -- particularly around dismissive approval handling, experienced-developer shortcuts, and enterprise integration questions that the facilitator had to improvise through. The scripts need hardening before shipping to real Reliance teams.

---

## Scores

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| A. Script Faithfulness | 4 | Say blocks followed almost verbatim; minor reordering in Act 5 where the facilitator pushed back on semi-specific instructions (not scripted) |
| B. Fourth-Wall Discipline | 5 | Zero breaks. No mention of eval, ratings, scripts, teaching system, or progression mechanics. Consistent "experienced colleague" voice throughout |
| C. Mock Developer Realism | 4 | Rahul's skepticism, short answers, and gradual warming are well-calibrated; his knowledge of Flask internals is realistic; his "maybe, let me try on my own first" ending is exactly right for a mandated attendee |
| D. Pedagogical Effectiveness | 4 | Acts 1 and 4 land cleanly; Act 5's vague-vs-specific contrast works well; Act 3 feels redundant for the target profile; Act 2's teaching point ("you approve everything") is undercut by the trivial edit |
| E. Pacing and Flow | 3 | 42 minutes total is fine; Act 2-to-3 transition feels rehearsed; Act 3 is dead weight for git-literate developers; subagent wait times need better facilitation |
| F. Stuck-Path Coverage | 2 | Multiple realistic developer behaviors have no scripted handling; the transcript itself identifies 5 missing stuck paths; the facilitator had to improvise at least 3 times |
| G. Enterprise Readiness | 3 | Jenkins/CI question was handled adequately but entirely improvised; no prepared answers for IDE integration, code review tools, team workflows, or security/compliance concerns that Reliance teams will raise |

---

## Top 5 Strengths

### 1. Act 4 Bug Reveal is Perfectly Calibrated
The off-by-one bug in `flashes[:limit - 1]` is exactly the kind of mistake AI makes -- plausible, confident, wrong. Rahul's initial "yeah, looks fine" followed by the self-correcting "wait, hold on" is the ideal pedagogical arc. The facilitator's framing -- "AI writes confident, plausible, wrong code. It doesn't hesitate or flag uncertainty" -- is the single best line in the transcript and nails Concept 0.4.

**Evidence:** Lines 220-232. Rahul catches the bug on the second prompt with no hand-holding on the actual logic, demonstrating the script's hint progression works.

### 2. Act 1 Code Analysis Creates Genuine Surprise
The `should_set_cookie` dual-condition detail in `sessions.py` connects directly to a real issue Rahul's team experienced ("we had an issue last quarter where session cookies were being sent on every response"). This is the designed moment of surprise working as intended -- the AI explains something the developer's own team struggled with.

**Evidence:** Lines 29-31. Rahul's response shifts from guarded ("OK. That's... actually pretty accurate") to engaged ("the should_set_cookie thing -- I didn't know about the refresh behavior").

### 3. Act 5 Semi-Specific Pushback (Improvised but Effective)
The facilitator pushing Rahul from "add better error messages" to the fully specific instruction about view function identification and TypeError handling is pedagogically excellent. It demonstrates the gradient between vague and specific, not just the binary the script assumes.

**Evidence:** Lines 298-302. Rahul's first instruction is mediocre. The facilitator says "that's a start -- but I want to push you a bit." Rahul responds with a dramatically better instruction. The contrast between the two outputs makes the teaching point undeniable.

### 4. Fourth-Wall Discipline is Flawless
Across 400 lines of transcript, the facilitator never once mentions eval, ratings, scripts, progression, stages as a numbered system, or the teaching architecture. Even the "goose advance" mention at the end is presented as a natural tool command, not system vocabulary. The voice is consistently "experienced colleague," never "instructor."

**Evidence:** Every facilitator line reads as natural conversation. Compare "This is the core loop of AI-assisted development" (line 112) with what a broken fourth wall would sound like: "This is Concept 0.2 in the teaching framework."

### 5. Rahul's Ending is Realistic and Healthy
"Maybe. Let me think about it. I want to try a few things on my own first" is exactly what a skeptical developer forced to attend should say after a good session. Not converted, but interested. The facilitator's response -- "That's the right call. Try it on something real" -- validates the skepticism instead of pushing for commitment.

**Evidence:** Lines 395-397. This is the right outcome for a Stage 0 session with a mandated attendee. Anything more enthusiastic would feel manufactured.

---

## Top 5 Weaknesses

### 1. Act 3 is Dead Weight for Git-Literate Developers
Rahul says "We use git every day. I know how to revert changes" (line 165), and the facilitator has to improvise a response because the script has no adaptive shortcut for this. The teacher-instructions.md explicitly calls for this shortcut ("Show me how you'd undo a change the AI made. If they can, move on") but Act 3's script does not implement it. A 4-year Python developer at Reliance absolutely knows git. This act will feel condescending for the target audience.

**Evidence:** Lines 165-167. The facilitator recovers with "Good -- then this isn't new for you, it's just the same tool you already trust" but the damage is done. The act ran 4 minutes when it should have been 1-2 with an adaptive shortcut.

### 2. Act 2's Trivial Edit Undercuts "You Approve Everything"
The edit is a single-line comment addition. Rahul's response -- "Sure. It's just a comment" (line 105) -- reveals the problem: the approval feels meaningless when the change has zero risk. The teaching point is "you're always in control," but the developer experiences "I clicked yes on something that doesn't matter." The Simulation Notes correctly identify this (lines 417-419): the Act 2 edit should be more substantive so the approval feels consequential.

**Evidence:** Line 105. Compare Rahul's dismissive approval here with his engaged response to the Act 4 diff review. The difference is stakes -- when the change matters, the developer pays attention.

### 3. Enterprise Integration Questions Have No Scripted Handling
Rahul asks about Jenkins and CI/CD (lines 379-381) -- exactly the question every Reliance developer will ask. The facilitator improvises a good answer ("It works with whatever you already have... The AI is just another pair of hands writing code"), but this should be scripted and tested. Missing from the scripts: IDE integration questions, code review tool integration, security/compliance ("does my code leave my machine?"), and team workflow questions ("can two people use this on the same repo?").

**Evidence:** Lines 379-381 and Simulation Notes line 415. The improvised answer works, but an untested facilitator might give a worse one, or worse, break the fourth wall by referencing Goose internals.

### 4. Missing Stuck Paths Would Cause Real Failures
The Simulation Notes identify 5 missing stuck paths (lines 427-431). The most critical: (a) developer refuses to pick a file in Act 1 -- no fallback; (b) developer catches the Act 4 bug immediately -- the pacing breaks because the dramatic pause is wasted; (c) developer asks "can I see the prompt you used?" -- no handling for transparency questions. These are not edge cases -- they are common behaviors for the target audience of skeptical enterprise developers.

**Evidence:** Lines 427-431. Additionally, the transcript shows no coverage of a developer who is actively hostile ("this is a waste of my time") versus merely skeptical. Mandated attendees can be actively resistant.

### 5. Subagent Wait Time Creates Awkward Dead Spots
The transcript notes subagent operations that create visible terminal activity while the developer watches. The facilitator's only framing is "you might see some activity in your terminal" (line 18). For a 30-second operation, this creates a real awkward pause in what should feel like a conversation. The Simulation Notes flag this (lines 435-437) but the scripts have no "fill the dead time" strategy -- no questions to ask the developer, no context to share, no narration of what the AI is doing.

**Evidence:** Line 18 and Simulation Notes lines 435-437. This will be worse in real sessions where subagent operations might take 60+ seconds.

---

## Specific Script Fixes Recommended

### 1. `act-3-undo-button.teach.md` -- Add Adaptive Shortcut
**Section:** Before Step 1
**What to add:**
```
## Adaptive Shortcut

Check: If the developer has used git terminology unprompted, or expressed
familiarity with version control at any point during Acts 1-2:

Say:
"You already know git. Quick check — if I made a change you didn't like,
how would you undo it?"

Check: Wait for response. If they mention git checkout, git restore, or
git reset, skip to Step 3 (Re-apply for Later Acts).

Say:
"Exactly. Same tools you already trust. Nothing new to learn here."
```

### 2. `act-2-first-edit.teach.md` -- Make the Edit Substantive
**Section:** Step 2, subagent instruction
**Current:** The subagent finds "a small, safe improvement" -- candidates include comments, vague variable names, log messages.
**Change:** Remove "comment" from the candidate list. Add "a small logic extraction or variable rename" as the preferred candidate. The edit should be something the developer needs to actually evaluate, not rubber-stamp.

### 3. `act-5-say-it-better.teach.md` -- Handle Semi-Specific Instructions
**Section:** After Step 1, Check block
**What to add:**
```
## Step 1b: Push for Precision (if needed)

Check: If the developer's instruction is better than "improve it" but still
not specific enough to produce dramatically different output:

Say:
"That's a start — but I want to push you a bit. [Specific question about
what's missing from their instruction: What errors exactly? What should
the message say? What types should be validated?]"

Check: Wait for revised instruction.
```

### 4. `act-4-catch-the-bug.teach.md` -- Handle Immediate Bug Catch
**Section:** Step 2, after showing the diff
**What to add:**
```
**If the developer identifies the bug immediately (before being prompted):**

Say:
"You read diffs carefully — that habit is going to save you. [bug_explanation].

Most people skim and say 'looks fine.' You didn't. That's the single most
important skill in AI-assisted development."

[Skip to Step 4: Fix It]
```

### 5. All act scripts -- Add Enterprise FAQ Section
**Location:** New file `teaching/stage-0/enterprise-faq.teach.md` or appended to each act
**Content:** Prepared answers for:
- CI/CD integration ("It works with whatever you already have. The AI edits files on disk -- same files git tracks, same files Jenkins builds.")
- Security/data privacy ("Your code stays on your machine. The AI reads files locally.")
- IDE integration ("It runs in your terminal alongside your IDE. You keep using VS Code / IntelliJ as normal.")
- Team workflows ("Multiple people can use it on the same repo. It's per-developer, like any IDE plugin.")
- Code review compatibility ("AI changes show up in PRs like any other change. Your reviewers see normal diffs.")

### 6. All act scripts -- Add Subagent Wait Narration
**Location:** Every `Action: Delegate to subagent` block
**What to add:** A "While waiting" instruction for the facilitator:
```
While waiting: [Ask the developer a question related to the current act's
concept, OR narrate what the AI is doing: "It's reading through your source
files looking for [X]..."]
```

---

## Would You Ship This?

**Conditional.**

The transcript demonstrates that the teaching design works -- the five concepts land in the right order, the surprise moments convert skepticism into engagement, and the facilitator voice is credible. Acts 1, 4, and 5 are strong enough to ship as-is.

**Conditions before shipping:**

1. **Fix Act 3 adaptive shortcut.** Every Reliance developer knows git. Without the shortcut, this act will feel patronizing and damage trust built in Acts 1-2. This is the highest-priority fix.

2. **Add enterprise FAQ handling.** Jenkins, security, and team workflow questions are guaranteed for this audience. Improvised answers risk fourth-wall breaks or inaccurate claims. This needs scripted, tested responses.

3. **Handle the semi-specific instruction case in Act 5.** The binary vague/specific assumption does not match reality. Real developers will give mediocre instructions, and the script needs to guide them to precision.

4. **Make the Act 2 edit substantive.** A comment addition produces dismissive approval, which teaches the wrong lesson about the importance of review.

5. **Add the immediate-bug-catch path for Act 4.** Strong developers will catch off-by-one errors on first read. The script should reward this, not awkwardly skip the dramatic pause.

These are all script-level fixes -- the architecture, teaching framework, and core design are sound. The mock test did its job: it found the gaps before real developers did.
