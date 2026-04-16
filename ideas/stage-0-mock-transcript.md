# Stage 0 Mock Test Transcript

**Target codebase:** Flask framework (`<PROJECTS>\MockTestTarget`)
**Mock developer:** Rahul Sharma, 28, Python developer at Reliance, 4 years experience, works on internal Flask APIs
**Profile:** Competent but not exceptional. Mildly skeptical — his manager told him to attend. Gives short, guarded answers at first.
**Date of simulated session:** 2026-04-12
**Teaching scripts:** `teaching/stage-0/act-1` through `act-5`

---

=== ACT 1: See Your Code ===
*Concept 0.1 — AI reads your actual code*

---

[FACILITATOR]: Right now, you're used to AI that works like a search engine — you describe something, it gives you text back. What we're about to do is different. I can actually see your project files, read your code, and understand how your codebase works. Let me show you.

I'm going to send a helper to go browse through your project and pick an interesting file to look at. You might see some activity in your terminal — that's just my helper reading your files. Give me a moment.

  >> CODE OPERATION: Subagent reads `.goose/team_context.md` for project context, scans `src/flask/` directory, selects `src/flask/sessions.py` as a file with meaningful logic.
  >> RESULT: File selected: `src/flask/sessions.py`. Reason: "Core session management with multiple design patterns — callback dict, mixin inheritance, and a deliberate null-object pattern for error handling."

[FACILITATOR]: I picked `src/flask/sessions.py` because it's where Flask handles all session state management — the kind of thing every API developer touches but rarely reads deeply.

This file implements a layered session system. At the base, there's a `SessionMixin` that adds session-specific properties like `permanent`, `modified`, and `accessed` to any dictionary-like object. The interesting design choice is that `SecureCookieSession` inherits from both `CallbackDict` and `SessionMixin` — so any time you modify the session dict, the `on_update` callback fires and sets `modified = True`. That's how Flask knows whether it needs to write a new `Set-Cookie` header on the response.

Then there's the `NullSession` class, which is a textbook null-object pattern. If no secret key is configured, Flask doesn't crash — it gives you a session that looks normal for reads but raises a clear `RuntimeError` on any write attempt. That's a nice touch for developer experience during setup.

One thing worth noting: the `should_set_cookie` method has a subtle dual condition — it sets the cookie if the session was modified OR if the session is permanent and `SESSION_REFRESH_EACH_REQUEST` is enabled. That second condition is what keeps permanent sessions alive even when no data changes, which is something a lot of Flask developers don't realize is happening.

[RAHUL]: OK. That's... actually pretty accurate. I mean, I've read that file before, it's Flask core. But yeah, the `should_set_cookie` thing — I didn't know about the refresh behavior. We had an issue last quarter where session cookies were being sent on every response and nobody could figure out why.

[FACILITATOR]: Now it's your turn. Pick any file in your project — something you work with regularly — and ask me a question about it.

[RAHUL]: Alright. Look at `src/flask/helpers.py`. What does the `flash` function actually do under the hood? I use it but I've never really looked at the implementation.

  >> CODE OPERATION: Subagent reads `src/flask/helpers.py`, locates the `flash` function at line 326.
  >> RESULT: Function analysis complete. Also identified `get_flashed_messages` at line 360 as a follow-up point.

[FACILITATOR]: The `flash` function does three things. First, it pulls any existing flashed messages from the session with `session.get("_flashes", [])`. Then it appends your new message as a tuple of `(category, message)` to that list. Finally — and this is the part most people miss — it writes the entire list back to the session with `session["_flashes"] = flashes`. That last step isn't redundant. There's a comment in the code explaining why: Flask can't assume that mutating a list inside the session dict will trigger the session's change detection. Some session backends use external storage, and in-place mutations to nested structures won't propagate. So it does an explicit reassignment to guarantee `modified` gets set to `True`.

After setting the session data, it also fires the `message_flashed` signal, passing the app instance, the message, and the category — so any extensions listening for flash events get notified.

One more thing — the `category` parameter defaults to `"message"`, not `"info"` like a lot of people assume. If you're filtering flashes by category in templates and wondering why nothing shows up under `"info"`, that's probably why.

[RAHUL]: Huh. OK, that signal thing I didn't know about. We don't use signals. But the category default — yeah, that's bitten us before.

[FACILITATOR]: So that's the first big difference from ChatGPT — I'm not guessing about your code from a description. I'm reading the actual files.

But reading is just the start. Next, I'm going to make a change to your code. Don't worry — you'll approve everything first, and we'll learn how to undo it right after.

---

=== ACT 2: Your First Edit ===
*Concept 0.2 — AI edits your actual code*

---

[FACILITATOR]: Before I touch anything, let's create a practice branch. Everything we do today happens here — your main branch stays untouched.

  >> CODE OPERATION: Subagent runs `git checkout -b practice/stage-0`
  >> RESULT: Switched to a new branch 'practice/stage-0'

[FACILITATOR]: Done — we're on a practice branch now. Nothing we do here affects your real code. Think of it like a scratch pad.

Let me look through your code and find a small improvement I could make.

  >> CODE OPERATION: Subagent reads `.goose/team_context.md`, scans source files for improvement candidates. Identifies `get_expiration_time` method in `src/flask/sessions.py` line 223.
  >> RESULT: Found improvement candidate. The `get_expiration_time` method has no inline comment explaining the None return for non-permanent sessions.

[FACILITATOR]: I found something in `src/flask/sessions.py` on line 223.

Here's what's there now:
```python
def get_expiration_time(self, app: Flask, session: SessionMixin) -> datetime | None:
    """A helper method that returns an expiration date for the session
    or ``None`` if the session is linked to the browser session.  The
    default implementation returns now + the permanent session
    lifetime configured on the application.
    """
    if session.permanent:
        return datetime.now(timezone.utc) + app.permanent_session_lifetime
    return None
```

Here's what I'd change it to:
```python
def get_expiration_time(self, app: Flask, session: SessionMixin) -> datetime | None:
    """A helper method that returns an expiration date for the session
    or ``None`` if the session is linked to the browser session.  The
    default implementation returns now + the permanent session
    lifetime configured on the application.
    """
    if session.permanent:
        return datetime.now(timezone.utc) + app.permanent_session_lifetime

    # Non-permanent sessions expire when the browser closes (no Max-Age/Expires).
    return None
```

That return `None` is doing real work — it tells the cookie layer to omit `Max-Age` and `Expires`, making it a browser-session cookie. The comment makes that intention explicit so nobody "fixes" it later by adding a default expiration.

This is a small change, but it's a real one — I'm going to edit your actual file. Want me to go ahead?

[RAHUL]: Sure. It's just a comment.

  >> CODE OPERATION: Subagent edits `src/flask/sessions.py`, adds the inline comment before `return None` in `get_expiration_time`.
  >> RESULT: Edit applied successfully to `src/flask/sessions.py`.

[FACILITATOR]: Done. Open `src/flask/sessions.py` in your editor and look at line 230 — you should see the change.

This is the core loop of AI-assisted development: I propose, you review, you approve, I apply. You're always in control.

[RAHUL]: Yeah, I see it. It's there.

[FACILITATOR]: Now here's the thing — what if you didn't like that change? What if I made a bad suggestion? Let me show you how easy it is to undo anything I do.

---

=== ACT 3: The Undo Button ===
*Concept 0.3 — Everything is reversible*

---

[FACILITATOR]: Let's see what's changed in your project right now.

  >> CODE OPERATION: Subagent runs `git diff`
  >> RESULT:
  ```
  diff --git a/src/flask/sessions.py b/src/flask/sessions.py
  index 9a3d186..c4e71f2 100644
  --- a/src/flask/sessions.py
  +++ b/src/flask/sessions.py
  @@ -228,4 +228,5 @@ class SessionInterface:
       if session.permanent:
           return datetime.now(timezone.utc) + app.permanent_session_lifetime
  +    # Non-permanent sessions expire when the browser closes (no Max-Age/Expires).
       return None
  ```

[FACILITATOR]: Here's everything that's different from your original code:

```
diff --git a/src/flask/sessions.py b/src/flask/sessions.py
--- a/src/flask/sessions.py
+++ b/src/flask/sessions.py
@@ -228,4 +228,5 @@
     if session.permanent:
         return datetime.now(timezone.utc) + app.permanent_session_lifetime
+    # Non-permanent sessions expire when the browser closes (no Max-Age/Expires).
     return None
```

One command shows you every change. This is your first safety tool — `git diff` lets you see exactly what the AI changed before you commit anything.

Now let's undo that change completely.

  >> CODE OPERATION: Subagent runs `git checkout -- src/flask/sessions.py`, then runs `git diff`
  >> RESULT: Diff is empty. File restored to original state.

[FACILITATOR]: The file is back to its original state. That's your second safety tool — `git checkout` undoes changes to a file.

Between `git diff` (see what changed) and `git checkout` (undo it), you can always get back to where you started. The AI can never make a change you can't reverse.

[RAHUL]: We use git every day. I know how to revert changes.

[FACILITATOR]: Good — then this isn't new for you, it's just the same tool you already trust. That's the point. Let me re-apply that change so we have something to work with going forward.

  >> CODE OPERATION: Subagent re-applies the comment addition to `src/flask/sessions.py`.
  >> RESULT: Edit re-applied successfully.

[FACILITATOR]: Change re-applied. Now comes the most important lesson — what happens when the AI writes something wrong.

  >> STATE OPERATION: Subagent writes `.goose/state/.stage-0-progress.json` with acts_completed: [1, 2, 3], files_touched: ["src/flask/sessions.py"], branch: "practice/stage-0"

---

=== ACT 4: Catch the Bug ===
*Concept 0.4 — AI is confident, not correct*

---

[FACILITATOR]: Let me add a small feature to your code. I'm sending a helper to find a good spot and make a change — you'll see some activity while it works.

  >> CODE OPERATION: Subagent reads `.goose/team_context.md`, scans source files, selects `get_flashed_messages` in `src/flask/helpers.py` at line 360. Adds a "recent messages" feature — a new parameter `limit` that restricts how many flash messages are returned. Plants a subtle off-by-one bug: uses `< limit` instead of `<= limit` when the limit is 1-indexed from the user's perspective but applied to a 0-indexed slice, causing one fewer message than requested to be returned.

  >> RESULT (PRIVATE — not shown to developer):
  - file_path: src/flask/helpers.py
  - bug_location: line ~395, the slicing logic
  - bug_explanation: The function uses `flashes[:limit - 1]` instead of `flashes[:limit]`. When a user passes `limit=3`, they get 2 messages back instead of 3. The `- 1` suggests the author confused 0-indexed slicing with 1-indexed user expectations — but Python's slice notation already handles this correctly. `flashes[:3]` returns elements 0, 1, 2 — which is 3 elements.
  - hint_1: "Look at how the limit is applied to the list."
  - hint_2: "Check the slicing on the flashes list — does `limit=3` actually give you 3 messages?"
  - fix: Change `flashes[:limit - 1]` to `flashes[:limit]`

[FACILITATOR]: OK, I just made a change to `src/flask/helpers.py`. I added a `limit` parameter to `get_flashed_messages` so you can cap how many messages are returned — useful when you've got a notification area that only shows the latest few. Here's the diff:

```diff
 def get_flashed_messages(
-    with_categories: bool = False, category_filter: t.Iterable[str] = ()
+    with_categories: bool = False,
+    category_filter: t.Iterable[str] = (),
+    limit: int | None = None,
 ) -> list[str] | list[tuple[str, str]]:
     """Pulls all flashed messages from the session and returns them.
     Further calls in the same request to the function will return
@@ -386,6 +388,9 @@
     flashes = app_ctx.flashes
     if category_filter:
         flashes = [x for x in flashes if x[0] in category_filter]
+    if limit is not None:
+        # Restrict to the most recent messages up to the limit
+        flashes = flashes[:limit - 1]
     if not with_categories:
         return [x[1] for x in flashes]
     return flashes
```

Take a look at this. Does everything look correct to you?

[RAHUL]: Yeah, looks fine. It adds a limit parameter, filters the list, seems straightforward.

[FACILITATOR]: Take another look, specifically at how the limit is applied to the list.

[RAHUL]: Um... `flashes[:limit - 1]`... I mean, that's just slicing. If you pass limit=5 you get the first four... wait.

Actually, hold on. If I call `get_flashed_messages(limit=3)`, I'd expect to get 3 messages. But `flashes[:3 - 1]` is `flashes[:2]`, which gives me 2. That's off by one.

[FACILITATOR]: You caught it. The `- 1` is wrong. Python's slice notation is already exclusive on the upper bound — `flashes[:3]` gives you elements 0, 1, and 2, which is exactly 3 items. The extra `- 1` means you always get one fewer message than you asked for. It's the kind of mistake that looks right if you're thinking about it too fast — "zero-indexed, so subtract one" — but Python slicing already accounts for that.

This is the most important thing I'm going to teach you today: AI writes confident, plausible, wrong code. It doesn't hesitate or flag uncertainty. It just writes it like it's obviously correct.

Your job — always — is to review what the AI produces. Not skim it. Actually read it and think about whether it's right. You just proved you can do that.

[RAHUL]: Fair enough. But in my experience, most bugs are caught in testing anyway. If we have unit tests for this, the off-by-one would show up.

[FACILITATOR]: It would — if the test expected exact counts. A test that just checks "does it return a list?" would pass. A test that checks "limit=3 returns exactly 3" would catch it. The quality of your tests matters as much as having tests. But yes — testing is your third safety layer, after reviewing the diff and checking with git. We'll get into that in Stage 1.

Let me fix that.

  >> CODE OPERATION: Subagent edits `src/flask/helpers.py`, changes `flashes[:limit - 1]` to `flashes[:limit]`.
  >> RESULT: Fix applied.

[FACILITATOR]: Fixed. In real work, this is the cycle: AI proposes, you review, you catch issues, AI fixes them. The AI is fast but fallible. You are slower but critical. Together, you're better than either alone.

One more thing before we wrap up — I want to show you the single biggest lever you have when working with AI.

---

=== ACT 5: Say It Better ===
*Concept 0.5 — You control the quality*

---

[FACILITATOR]: For this last exercise, I want to show you something that will change how you work with AI forever. Watch what happens when I give a vague instruction versus a specific one.

Pick a function in your project — something that could be improved. Just tell me the file and function name.

[RAHUL]: The `stream_with_context` function in `src/flask/helpers.py`. It's always confused me and I think the code could be cleaner.

[FACILITATOR]: OK. First, I'm going to improve that function with a vague instruction. Watch what happens.

  >> CODE OPERATION: Subagent receives deliberately vague instruction: "Improve the function `stream_with_context` in `src/flask/helpers.py`." Instructed to make a surface-level, mediocre change.
  >> RESULT:
  - vague_diff:
    ```diff
     def stream_with_context(
         generator_or_function: t.Iterator[t.AnyStr] | t.Callable[..., t.Iterator[t.AnyStr]],
     ) -> t.Iterator[t.AnyStr] | t.Callable[[t.Iterator[t.AnyStr]], t.Iterator[t.AnyStr]]:
    -    """Wrap a response generator function so that it runs inside the current
    -    request context.
    +    """Wrap a response generator to preserve the request context during streaming.
    ```
  - vague_description: "Shortened the docstring's first line for readability."

[FACILITATOR]: Here's what I did with "improve this function":

```diff
 def stream_with_context(
     generator_or_function: t.Iterator[t.AnyStr] | t.Callable[..., t.Iterator[t.AnyStr]],
 ) -> t.Iterator[t.AnyStr] | t.Callable[[t.Iterator[t.AnyStr]], t.Iterator[t.AnyStr]]:
-    """Wrap a response generator function so that it runs inside the current
-    request context.
+    """Wrap a response generator to preserve the request context during streaming.
```

Shortened the docstring's first line for readability.

Not great, right? The instruction was vague, so the result was vague. Now let's try something different.

This time, YOU write the instruction. Be specific — tell me exactly what you want improved. For example:
- "Rename the variables to be descriptive"
- "Add input validation for null values and empty strings"
- "Break this into two smaller functions: one for X, one for Y"
- "Add error handling with specific error messages"

What would you like me to do with this function?

[RAHUL]: Add better error messages when it fails. Right now if you call it outside a request context you just get a generic RuntimeError.

[FACILITATOR]: That's a start — but I want to push you a bit. "Better error messages" is still somewhat vague. What specifically would a helpful error message tell the developer? What information would help them fix the problem?

[RAHUL]: OK fine. Add error handling that tells the developer which view function tried to use `stream_with_context`, and suggest they check that they're calling it inside a route handler, not in a background task or CLI command. And if the generator itself is None, raise a TypeError with a clear message instead of letting it blow up somewhere inside the iterator protocol.

[FACILITATOR]: Now that's specific.

  >> CODE OPERATION: Subagent applies the specific instruction to `stream_with_context` in `src/flask/helpers.py`. Adds a None check with TypeError, and improves the RuntimeError with contextual information.
  >> RESULT:
  - specific_diff:
    ```diff
     def stream_with_context(
         generator_or_function: t.Iterator[t.AnyStr] | t.Callable[..., t.Iterator[t.AnyStr]],
     ) -> t.Iterator[t.AnyStr] | t.Callable[[t.Iterator[t.AnyStr]], t.Iterator[t.AnyStr]]:
    +    if generator_or_function is None:
    +        raise TypeError(
    +            "stream_with_context() requires a generator or callable, got None."
    +            " Check that the decorated function returns a generator (uses 'yield')."
    +        )
    +
         """Wrap a response generator ...
         ...
         try:
             gen = iter(generator_or_function)
         except TypeError:
         ...
         def generator() -> t.Iterator[t.AnyStr]:
             if (ctx := _cv_app.get(None)) is None:
    -            raise RuntimeError(
    -                "'stream_with_context' can only be used when a request"
    -                " context is active, such as in a view function."
    +            import traceback
    +            caller = traceback.extract_stack(limit=3)[0]
    +            raise RuntimeError(
    +                f"stream_with_context() called outside a request context"
    +                f" (from {caller.filename}:{caller.lineno} in {caller.name})."
    +                f" This function must be called inside a route handler, not"
    +                f" in a background task, CLI command, or module-level code."
    +                f" If you need to stream from a background context, pass the"
    +                f" data directly instead of relying on the request context."
                 )
    ```
  - specific_description: "Added a None guard with a TypeError that tells you to check your generator, and replaced the generic RuntimeError with a message that names the exact file, line, and function that made the bad call — plus concrete suggestions for what to do instead."

[FACILITATOR]: Here's what I did with your specific instruction:

```diff
+    if generator_or_function is None:
+        raise TypeError(
+            "stream_with_context() requires a generator or callable, got None."
+            " Check that the decorated function returns a generator (uses 'yield')."
+        )

     def generator() -> t.Iterator[t.AnyStr]:
         if (ctx := _cv_app.get(None)) is None:
-            raise RuntimeError(
-                "'stream_with_context' can only be used when a request"
-                " context is active, such as in a view function."
+            import traceback
+            caller = traceback.extract_stack(limit=3)[0]
+            raise RuntimeError(
+                f"stream_with_context() called outside a request context"
+                f" (from {caller.filename}:{caller.lineno} in {caller.name})."
+                f" This function must be called inside a route handler, not"
+                f" in a background task, CLI command, or module-level code."
```

Added a None guard with a TypeError that tells you to check your generator, and replaced the generic RuntimeError with a message that names the exact file, line, and function that made the bad call — plus concrete suggestions for what to do instead.

Compare the two:

**Vague instruction** -- Shortened the docstring's first line for readability.
**Your instruction** -- Added a None guard with explicit TypeError, and replaced the generic RuntimeError with a message that includes the caller's file, line number, function name, and concrete suggestions for what to do instead.

Same AI, same function, completely different results. The difference was you. The quality of what you get from AI is directly proportional to the quality of what you ask for. This is the single most important skill in AI-assisted development — and you just demonstrated it.

[RAHUL]: OK I'll give you that one. The second version is actually useful. The first one is the kind of thing I'd get from ChatGPT and just ignore.

[FACILITATOR]: That's exactly the difference. ChatGPT with vague input gives you vague output. This tool with specific input gives you something you'd actually ship. The tool didn't get smarter between the two runs — you did.

[RAHUL]: Will this work with our Jenkins pipeline though? Like, if I'm running this on my machine it's one thing, but we have a whole CI/CD setup and code review process. Does this integrate with that or is it a separate thing?

[FACILITATOR]: It works with whatever you already have. The AI makes changes to files on disk — same files git tracks, same files Jenkins builds, same files your reviewers see in PRs. Nothing about your pipeline changes. The AI is just another pair of hands writing code. You still commit, push, open PRs, get reviews, run CI. The difference is how fast the code gets written.

That's everything for Stage 0. Here's what you learned today:

1. **AI can see your code** — it reads actual files, not guessing from descriptions
2. **You approve every change** — nothing happens without your permission
3. **Git is your undo button** — any change can be reversed instantly
4. **AI makes mistakes** — confident, plausible, wrong. Your job is to catch them
5. **Specific instructions get better results** — how you ask matters more than what you ask

You're ready for Stage 1, where you'll start doing real work: fixing bugs, writing tests, running code reviews — all with AI assistance.

Want to advance? Just run `goose advance`.

[RAHUL]: Maybe. Let me think about it. I want to try a few things on my own first and see if it actually holds up on my real tasks.

[FACILITATOR]: That's the right call. Try it on something real. When you're ready, Stage 1 starts with bug fixing — bring a real bug and we'll work through it.

  >> CLEANUP OPERATION: Subagent switches back to main branch, deletes practice/stage-0 branch, writes final state to `.goose/state/.stage-0-progress.json` with all 5 acts completed.

---

## SIMULATION NOTES

### Issues Found with Teaching Scripts

1. **Act 1 Step 2 — "Pick any file" is too open-ended for skeptics.** Rahul's response was cooperative, but a more resistant developer might say "I don't know, you pick one" or give a one-word answer. The script has no stuck-path for a developer who won't engage with the "pick a file" prompt. Suggestion: add a fallback where the facilitator offers 2-3 specific files and asks "which of these do you work with most?"

2. **Act 2 — "Sure. It's just a comment" reveals low engagement.** The script says to wait for the developer to approve, but doesn't distinguish between engaged approval ("yeah, that makes sense, go ahead") and dismissive approval ("sure whatever"). The facilitator should have a hook for when the developer treats the approval as trivial — the whole point is that approval matters.

3. **Act 3 — "We use git every day" pushback has no scripted response.** The facilitator had to improvise when Rahul pushed back on the git lesson. The script should anticipate experienced developers who already know git and provide an adaptive shortcut: verify they can do it, then move on. The teacher-instructions.md mentions this pattern but Act 3's script doesn't include it.

4. **Act 4 — First hint is too gentle for experienced developers.** "Look at how the limit is applied to the list" is vague enough that even a good developer might not know what to focus on. For Python developers specifically, the hint should reference slicing semantics directly. The hint levels could be calibrated to detected skill level.

5. **Act 5 — No script coverage for Rahul's enterprise question.** The Jenkins/CI question is exactly what a Reliance developer would ask, but the script has no handling for integration questions. The facilitator had to improvise. Suggestion: add a "common enterprise questions" section to the teaching script with prepared answers for CI/CD, code review tools, IDE integration, and team workflows.

### Unnatural Flow Points

1. **Act 2 to Act 3 transition feels rehearsed.** The "what if you didn't like that change?" bridge works on paper, but Rahul had already seen the change was trivial (just a comment). The undo demonstration feels low-stakes because the edit was low-stakes. Consider making the Act 2 edit something more substantive — a variable rename or a small logic extraction — so the undo feels more meaningful.

2. **Act 4 bug reveal pacing.** Rahul caught the bug on the second hint, which is the "happy path middle." But his initial "yeah, looks fine" was realistic — most developers skim diffs for syntax errors, not semantic bugs. The script handles this well. However, the facilitator's response after the catch ("This is the most important thing I'm going to teach you today") feels like a pivot to lecture mode. A more natural response would be shorter: "Exactly. Off by one. AI wrote it like it was obvious. Your review caught it."

3. **Act 5 first instruction was too vague.** The script says to wait for the developer's specific instruction, but Rahul's first attempt ("add better error messages") was mediocre — specific enough to not be obviously vague, but not specific enough to get great output. The facilitator pushing back on this was improvised and not in the script. The script should explicitly handle the "semi-specific" case where the instruction is better than "improve it" but still not precise enough.

### Missing Stuck-Path Coverage

1. **Developer refuses to pick a file in Act 1 Step 2.** No fallback.
2. **Developer says "just show me everything, I don't want to ask questions."** No path for developers who want to watch rather than participate.
3. **Developer catches the Act 4 bug immediately** (before being asked "does everything look correct?"). The script handles this in Step 3, but the pacing would be awkward — you'd skip the dramatic pause entirely. Consider acknowledging their speed: "You read diffs carefully. Good. That habit is going to save you."
4. **Developer asks "can I see the prompt you used?"** or other transparency questions. No path for developers curious about how the AI works internally.
5. **Developer's chosen function in Act 5 is too simple** (e.g., a one-liner getter). The vague-vs-specific contrast won't be dramatic. The script should suggest a function with enough complexity to show the difference.

### Timing Observations

- **Act 1:** Ran about 8 minutes. The subagent file-reading adds ~30 seconds of "activity" that the developer watches in the terminal. This dead time needs to feel purposeful, not awkward. The facilitator's "you might see some activity" framing helps but could be stronger.
- **Act 2:** Ran about 7 minutes. Fast because the edit was a comment. A more substantive edit would be better pedagogically but might take longer for the subagent to produce and for the developer to evaluate.
- **Act 3:** Ran about 4 minutes. Rahul's pushback shortened it. For developers who already know git, this act could be compressed to 2 minutes: verify they know how to undo, move on.
- **Act 4:** Ran about 12 minutes. This is the core act and took the longest. The hint progression (look fine → first hint → caught it) took about 3 minutes, which felt right. The debrief discussion about testing added 3 more minutes. Total is within the 10-minute target.
- **Act 5:** Ran about 11 minutes. The facilitator pushing back on Rahul's semi-specific instruction added ~2 minutes but was pedagogically valuable. The enterprise question at the end added another 2 minutes. Total is slightly over the 10-minute target.
- **Full session:** ~42 minutes. Within the 45-60 minute target range.

### Overall Assessment

The teaching scripts work well as a framework. The main gaps are:
1. **Enterprise context questions** — Reliance developers will always ask about integration with existing tools. Need prepared answers.
2. **Adaptive shortcuts for experienced developers** — Act 3 (git) is boring for anyone who uses git daily. The teacher-instructions.md mentions adaptive shortcuts but the act scripts don't implement them.
3. **Semi-specific instructions** — Act 5 assumes a binary vague/specific split, but real developers land in the middle. The script needs handling for "good but not good enough" instructions.
4. **Subagent wait time** — The dead time while subagents work needs better facilitation. Consider adding "here's what it's doing" narration or using that time to ask the developer a question.
