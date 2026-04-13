# Edge Case Library

Each cycle forces at least one edge case. The simulator prompt specifies which edge case to trigger and when.

---

| ID | Edge Case | Applicable Stages | Trigger Description |
|----|-----------|-------------------|---------------------|
| E1 | Developer refuses the edit | Stage 0 (Act 2) | When facilitator proposes a code change, developer says "No, don't change that" or "That's a private function, nobody looks at it." |
| E2 | Developer catches bug immediately | Stage 0 (Act 4) | Developer spots the planted bug before the facilitator asks "does everything look correct?" — identifies it from the diff alone. |
| E3 | Developer gives semi-specific instruction | Stage 0 (Act 5) | Developer says something like "add better error handling" — better than "improve it" but not specific enough for great output. |
| E4 | Developer asks transparency question | Stage 0, 1 | "Can I see the prompt you used?" or "How does the AI decide what to look at?" or "Is this recording what I type?" |
| E5 | Developer has no bug/task | Stage 1 (all) | When asked "got a bug?" developer says "No, things are fine right now" — triggers stuck-path scan. |
| E6 | Developer wants to skip | Stage 0, 1 | "I already know this, can we skip ahead?" or "This seems basic, when do we get to the real stuff?" |
| E7 | Developer compares to ChatGPT/Copilot | Stage 0, 1 | "How is this different from Copilot?" or "I already use ChatGPT for code, what's new here?" |
| E8 | Developer asks about data privacy | Stage 0, 1 | "Does my code leave my machine?" or "Is this compliant with our security policy?" |
| E9 | All-Weak input | Stage 1 | Developer gives minimal context, accepts without checking, doesn't iterate, broad scope — triggers maximum coaching. |
| E10 | All-Strong input | Stage 1 | Developer does everything right — triggers all-Strong coaching and fast-track bridge. |
| E11 | Function too simple for contrast | Stage 0 (Act 5) | Developer picks a one-liner getter/setter for Act 5's vague-vs-specific comparison — the contrast won't be dramatic. |
| E12 | Back-to-back long waits | Stage 1 | Both stuck-path scan AND recipe execution take 30+ seconds — tests consecutive wait-time insight delivery. |
| E13 | Developer goes off-topic | Stage 0, 1 | Developer starts talking about unrelated work problems, team drama, or asks the AI to do something outside the current recipe. |
| E14 | Developer gives feedback on the session | Stage 0, 1 | "This is actually useful" or "I don't think this is working for me" — tests fourth-wall discipline (facilitator shouldn't acknowledge it as "training feedback"). |
