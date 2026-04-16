# Cycle 01 Transcript — Stage 0: See What AI Can Do

**Mock Developer:** Priya (Eager/Over-Accepting)
**Forced Edge Case:** E9 — Developer accepts everything without checking
**Mock Dev Model:** Haiku (simulated — Agent tool unavailable; responses authored in-persona)
**Target Codebase:** Flask framework (<PROJECTS>\MockTestTarget)
**Date:** 2026-04-12

---

=== ACT 1: See Your Code ===

[FACILITATOR]: Right now, you're used to AI that works like a search engine — you describe something, it gives you text back. What we're about to do is different. I can actually see your project files, read your code, and understand how your codebase works. Let me show you.

I'm going to send a helper to go browse through your project and pick an interesting file to look at. You might see some activity in your terminal — that's just my helper reading your files. Give me a moment.

While it's working — one thing you'll notice is that the first result is rarely the final one. AI is fast, but the real workflow is iterative. First pass, review, adjust, second pass. That cycle is where the quality comes from.

  >> CODE OPERATION: Subagent reads .goose/team_context.md, scans src/flask/, selects src/flask/helpers.py
  >> RESULT: Selected helpers.py — contains flash(), get_flashed_messages(), send_file(), url_for(), redirect(), abort()

[FACILITATOR]: I picked `src/flask/helpers.py` because it's the heart of the developer-facing API — this is where the functions live that Flask users call most often.

This file implements the public helper functions that Flask applications use constantly. `flash()` and `get_flashed_messages()` handle the message flashing system — a way to store a message in the session so it survives a redirect and can be displayed on the next page load. `url_for()` generates URLs for endpoints. `redirect()` and `abort()` are the standard ways to control response flow. `send_file()` and `send_from_directory()` handle serving static files securely.

What ties them together is the context system. Almost every function here reaches into `current_app` or `session` or `request` — these are thread-local proxies that Flask manages per-request. The file is a thin wrapper layer: most of the heavy lifting is delegated to Werkzeug, but Flask adds its own context-aware behavior on top.

One thing worth noting: look at the `flash()` function. There's a comment explaining why it doesn't just do `session.setdefault('_flashes', []).append(...)`. The original implementation assumed mutating a list in the session would automatically mark the session as modified — but that's not true for session backends that use external storage. So now it reads, appends, and writes back explicitly. That's the kind of subtle correctness issue that trips up experienced developers.

Now it's your turn. Pick any file in your project — something you work with regularly — and ask me a question about it. Could be "what does this function do?" or "why is this structured this way?" or anything else.

[PRIYA]: Oh wow, that's really cool that it can read actual files! Um, can you look at `src/flask/sessions.py` and tell me what the `save_session` method does?

[FACILITATOR]: The `save_session` method on `SecureCookieSessionInterface` is the last thing that runs before a response goes out the door. Its job is to serialize the session data into a signed cookie and attach it to the response.

Here's what it does step by step: First, it gathers all the cookie parameters — name, domain, path, secure flag, SameSite policy, httponly, partitioned. Then it checks if the session was accessed at all — if so, it adds a `Vary: Cookie` header so caches know the response depends on the session. If the session is empty and was modified (meaning the user cleared it), it deletes the cookie. If the session is empty but wasn't modified, it returns silently — no point setting an empty cookie. Otherwise, it checks `should_set_cookie` to decide whether the cookie actually needs updating, calculates an expiration time if the session is permanent, signs the session data using itsdangerous, and sets the cookie on the response.

One thing you might find interesting: the signing serializer stacks the current secret key with any fallback keys from `SECRET_KEY_FALLBACKS`. This lets you rotate secrets without instantly invalidating every active session — old sessions can still be verified with the fallback keys, but new sessions always get signed with the current key.

So that's the first big difference from ChatGPT — I'm not guessing about your code from a description. I'm reading the actual files.

But reading is just the start. Next, I'm going to make a change to your code. Don't worry — you'll approve everything first, and we'll learn how to undo it right after.

---

=== ACT 2: Your First Edit ===

[FACILITATOR]: Before I touch anything, let's create a practice branch. Everything we do today happens here — your main branch stays untouched.

  >> CODE OPERATION: git checkout -b practice/stage-0
  >> RESULT: Switched to a new branch 'practice/stage-0'

Done — we're on a practice branch now. Nothing we do here affects your real code. Think of it like a scratch pad.

Let me look through your code and find a small improvement I could make.

Something to keep in mind — the more specific you are when you ask for something, the better the result. That's true for every AI tool. Vague in, vague out.

  >> CODE OPERATION: Scanned config.py, found get_namespace() method using vague variable names (rv, k, v)
  >> RESULT: Proposed renaming rv -> result, k -> config_key, v -> config_value in get_namespace()

I found something in `src/flask/config.py` around line 353.

Here's what's there now:
```python
rv = {}
for k, v in self.items():
    if not k.startswith(namespace):
        continue
    if trim_namespace:
        key = k[len(namespace) :]
    else:
        key = k
    if lowercase:
        key = key.lower()
    rv[key] = v
return rv
```

Here's what I'd change it to:
```python
result = {}
for config_key, config_value in self.items():
    if not config_key.startswith(namespace):
        continue
    if trim_namespace:
        key = config_key[len(namespace) :]
    else:
        key = config_key
    if lowercase:
        key = key.lower()
    result[key] = config_value
return result
```

The single-letter variables `k` and `v` make you re-read the context to understand what they hold. `config_key` and `config_value` tell you immediately — especially useful when `key` (the output key) is a separate variable computed from `config_key` (the original key). And `result` is clearer than `rv` about what the function returns.

This is a small change, but it's a real one — I'm going to edit your actual file. Want me to go ahead?

[PRIYA]: Yeah, looks great! Go for it!

  >> CODE OPERATION: Edit applied to src/flask/config.py — rv -> result, k -> config_key, v -> config_value
  >> RESULT: File updated successfully

[FACILITATOR]: Done. Open `src/flask/config.py` in your editor and look around line 353 — you should see the change.

This is the core loop of AI-assisted development: I propose, you review, you approve, I apply. You're always in control.

[PRIYA]: Yep, I see it! That looks really clean. Nice work!

[FACILITATOR]: Before we move on — did you actually open the file and look at the diff, or are you taking my word for it?

[PRIYA]: Oh — I mean, yeah I saw the summary you showed me. It looked good!

[FACILITATOR]: That's worth pausing on. I just changed your production code. The summary I showed you is what I *intended* to change — but the only way to know what *actually* changed is to look at the file yourself. In a minute I'll show you a command that makes that easy. For now, just flag it: never trust a summary when you can check the real thing.

Now here's the thing — what if you didn't like that change? What if I made a bad suggestion? Let me show you how easy it is to undo anything I do.

---

=== ACT 3: The Undo Button ===

[FACILITATOR]: Let's see what's changed in your project right now.

  >> CODE OPERATION: git diff
  >> RESULT: Shows the config.py changes — rv->result, k->config_key, v->config_value

Here's everything that's different from your original code:

```
diff --git a/src/flask/config.py b/src/flask/config.py
index 34ef1a5..a2b3f69 100644
--- a/src/flask/config.py
+++ b/src/flask/config.py
@@ -350,18 +350,18 @@ class Config(dict):
-        rv = {}
-        for k, v in self.items():
-            if not k.startswith(namespace):
+        result = {}
+        for config_key, config_value in self.items():
+            if not config_key.startswith(namespace):
                 continue
             if trim_namespace:
-                key = k[len(namespace) :]
+                key = config_key[len(namespace) :]
             else:
-                key = k
+                key = config_key
             if lowercase:
                 key = key.lower()
-            rv[key] = v
-        return rv
+            result[key] = config_value
+        return result
```

One command shows you every change. This is your first safety tool — `git diff` lets you see exactly what the AI changed before you commit anything.

Now let's undo that change completely.

  >> CODE OPERATION: git checkout -- src/flask/config.py, then git diff
  >> RESULT: Diff is empty — file restored to original state

The file is back to its original state. That's your second safety tool — `git checkout` undoes changes to a file.

Between `git diff` (see what changed) and `git checkout` (undo it), you can always get back to where you started. The AI can never make a change you can't reverse.

[PRIYA]: Oh that's awesome! So easy to undo. That makes me feel a lot better about trying stuff.

[FACILITATOR]: Let me re-apply that change so we have something to work with going forward.

  >> CODE OPERATION: Re-applied the same config.py edit
  >> RESULT: Edit applied successfully

Change re-applied. Now comes the most important lesson — what happens when the AI writes something wrong.

---

=== ACT 4: Catch the Bug ===

[FACILITATOR]: Let me add a small feature to your code. I'm sending a helper to find a good spot and make a change — you'll see some activity while it works.

While it's looking — one habit worth building early: after any change, run the tests. AI writes confident code, but confident and correct aren't the same thing.

  >> CODE OPERATION: Found get_flashed_messages() in helpers.py. Injected bug: changed f[0] to f[1] in category_filter lambda. This makes the filter compare message TEXT against category names instead of comparing CATEGORY against category names.
  >> RESULT: Bug injected at line 396 — filter(lambda f: f[1] in category_filter, flashes) instead of f[0]

OK, I just made a change to `src/flask/helpers.py`. Here's the diff:

```
diff --git a/src/flask/helpers.py b/src/flask/helpers.py
index fb7f6eb..f741126 100644
--- a/src/flask/helpers.py
+++ b/src/flask/helpers.py
@@ -393,7 +393,7 @@ def get_flashed_messages(
         flashes = session.pop("_flashes") if "_flashes" in session else []
         app_ctx._flashes = flashes
     if category_filter:
-        flashes = list(filter(lambda f: f[0] in category_filter, flashes))
+        flashes = list(filter(lambda f: f[1] in category_filter, flashes))
     if not with_categories:
         return [x[1] for x in flashes]
     return flashes
```

Take a look at this. Does everything look correct to you?

[PRIYA]: Yeah, that makes sense! Looks like it's filtering flashed messages. Looks good to me!

[FACILITATOR]: Take another look — specifically at what the filter is comparing. The `flashes` list holds tuples of `(category, message)`. What index is the category?

[PRIYA]: Oh right, so the tuple is category and message... I think that looks fine? The filter is checking if the flash is in the category filter.

[FACILITATOR]: Look at line 396. The tuple is `(category, message)` — index 0 is the category, index 1 is the message. The filter is using `f[1]`, which checks if the *message text* is in `category_filter`. That means if you flash `("error", "Login failed")`, and your template filters by category `"error"`, this would look for `"Login failed"` in the category list instead. It would silently return no messages.

Don't feel bad about missing it — this is exactly the kind of mistake AI makes constantly, and it's exactly why reviewing AI output is a non-negotiable skill. The AI wrote this confidently. It didn't warn you. It never will. That's your job.

[PRIYA]: Oh wow, I totally missed that! Yeah, f[1] would be the message not the category. That's sneaky. OK I'll look more carefully next time.

[FACILITATOR]: Let me fix that.

  >> CODE OPERATION: Fixed f[1] back to f[0] in helpers.py line 396
  >> RESULT: Corrected diff confirmed

Fixed. In real work, this is the cycle: AI proposes, you review, you catch issues, AI fixes them. The AI is fast but fallible. You are slower but critical. Together, you're better than either alone.

One more thing before we wrap up — I want to show you the single biggest lever you have when working with AI.

---

=== ACT 5: Say It Better ===

[FACILITATOR]: For this last exercise, I want to show you something that will change how you work with AI forever. Watch what happens when I give a vague instruction versus a specific one.

Pick a function in your project — something that could be improved. Just tell me the file and function name.

[PRIYA]: Hmm, how about `get_flashed_messages` in `helpers.py`? We were just looking at that one!

[FACILITATOR]: OK. First, I'm going to improve that function with a vague instruction. Watch what happens.

  >> CODE OPERATION: Vague instruction "Improve the function get_flashed_messages in helpers.py" — produced minimal change
  >> RESULT: Would add a generic comment "# Retrieve and filter flashed messages" above the function body

Here's what I did with "improve this function":

```diff
 def get_flashed_messages(
     with_categories: bool = False, category_filter: t.Iterable[str] = ()
 ) -> list[str] | list[tuple[str, str]]:
+    # Retrieve and filter flashed messages
     flashes = app_ctx._flashes
```

Added a generic comment restating what the function already obviously does.

Not great, right? The instruction was vague, so the result was vague. Now let's try something different.

This time, YOU write the instruction. Be specific — tell me exactly what you want improved. For example:
- "Rename the variables to be descriptive"
- "Add input validation for null values and empty strings"
- "Break this into two smaller functions: one for X, one for Y"
- "Add error handling with specific error messages"

What would you like me to do with this function?

[PRIYA]: Oh yeah, that first one was definitely not great! Um, how about... make it more readable?

[FACILITATOR]: That's a start — but I want to push you a bit. What specifically makes it hard to read? The lambda? The single-letter variable names in the list comprehension? The inline conditional? Pick one thing.

[PRIYA]: Oh OK, good point! Yeah, the lambda with f[0] and f[1] is confusing because you can't tell what those indexes mean. And the `[x[1] for x in flashes]` at the end — same problem. Can you replace those with named tuple unpacking so the variables say what they are?

[FACILITATOR]: Now that's a specific instruction.

Something you'll notice — the difference between vague and specific shows up in everything AI does, not just code edits.

  >> CODE OPERATION: Applied specific instruction — replaced lambda with list comprehension using tuple unpacking, converted category_filter to set for O(1) lookups
  >> RESULT: Full diff showing clear improvement

Here's what I did with your specific instruction:

```diff
     if category_filter:
-        flashes = list(filter(lambda f: f[0] in category_filter, flashes))
+        allowed_categories = set(category_filter)
+        flashes = [
+            (category, message)
+            for category, message in flashes
+            if category in allowed_categories
+        ]
     if not with_categories:
-        return [x[1] for x in flashes]
+        return [message for _category, message in flashes]
     return flashes
```

The lambda `f[0]` and `f[1]` are gone — now it's `category` and `message`, which read naturally. The `filter()` call is replaced with a list comprehension that unpacks each tuple, so you immediately see what's being compared. I also converted `category_filter` to a set for O(1) membership testing — not your request, but a freebie since I was already restructuring the loop. And `[x[1] for x in flashes]` became `[message for _category, message in flashes]` — the underscore prefix signals "I know this exists but I'm intentionally ignoring it."

Before we compare — take a look at that diff. Could this change break anything?

[PRIYA]: That looks amazing! No I think it's all good, can't see any issues!

[FACILITATOR]: What would happen if someone passed a generator as `category_filter` — something that can only be iterated once? Before this change, the `in` operator on the original iterable would work each time. After this change, `set(category_filter)` consumes the generator on the first call. Is that a problem here?

[PRIYA]: Oh, I hadn't thought of that! Um... but I guess since we're converting to a set right away, it would just consume it once and that's fine? The set sticks around for the whole filter.

[FACILITATOR]: Right — converting to a set actually *fixes* a potential issue with the original, where iterating a generator-based filter multiple times would silently produce empty results on the second pass. So the change is safe. But that's the kind of thing worth checking — not just "does the diff look clean" but "what inputs could this break?"

Good. Now compare the two:

**Vague instruction** -- Added a generic comment restating what the function does.
**Your instruction** -- Replaced opaque index access with named tuple unpacking, converted filter to efficient set lookup, made every variable self-documenting.

Same AI, same function, completely different results. The difference was you. The quality of what you get from AI is directly proportional to the quality of what you ask for. This is the single most important skill in AI-assisted development — and you just demonstrated it.

That's the basic loop. Here's what you've got now:

1. **AI can see your code** — it reads actual files, not guessing from descriptions
2. **You approve every change** — nothing happens without your permission
3. **Git is your undo button** — any change can be reversed instantly
4. **AI makes mistakes** — confident, plausible, wrong. Your job is to catch them
5. **Specific instructions get better results** — how you ask matters more than what you ask

Next time, bring a real bug or some code you've been meaning to clean up. That's where this gets practical — fixing real problems, writing real tests, running real reviews. All with AI doing the heavy lifting.

  >> CODE OPERATION: git checkout main, git branch -D practice/stage-0
  >> RESULT: Returned to main branch, practice branch deleted

---

=== SIMULATION NOTES ===

**Mock dev model:** Haiku (simulated in-persona — Agent tool was unavailable for actual subagent spawning)

**Issues found with teaching scripts:**

1. **Act 2 has no stuck path for rubber-stamping.** The script says "Check: Wait for the developer to confirm they see the change" but provides no guidance for when the developer says "yep looks good!" without actually opening the file. The facilitator had to improvise the "did you actually open the file?" intervention. This is the single biggest gap for the E9 persona — the script assumes the developer will do the verification step, but an over-accepter won't. **Recommendation:** Add an explicit stuck path after Act 2's confirmation check: "If the developer confirms without evidence of having checked (no specific detail about what they saw, immediate response, or response that only references the summary you showed), pause and redirect."

2. **Act 3 has no check after the undo.** The script shows the diff, undoes it, and moves on. It never asks the developer to verify the undo worked. For an eager developer like Priya, this missed an opportunity to build the habit of checking — she would have just said "cool!" and never confirmed the file was actually restored. **Recommendation:** Add a check after the undo: "Open the file again — is it back to the original?"

3. **Act 4's "looks fine" path works well but doesn't escalate hard enough for E9.** The script has hint_1, hint_2, and a reveal. For Priya's persona, she said "looks fine" at the top level AND after hint_1 — the script handled this. However, the script's final reveal is gentle: "Don't feel bad about missing it." For a developer who accepts everything, the coaching needs to be sharper: the facilitator should connect this directly to the danger of their specific habit ("If you'd approved that without looking, your category filters would silently return nothing in production"). The script leaves this to facilitator discretion, which is fine for experienced facilitators but risky for LLM facilitators.

4. **Act 5's "semi-specific" redirect worked perfectly.** Priya said "make it more readable" and the script's coaching to push for specificity ("What specifically makes it hard to read?") produced a genuinely better second attempt. This is the strongest part of the Act 5 script.

5. **Act 5's final review check has no stuck path for over-acceptance.** The script says "Check: Wait for the developer's response" after showing the specific diff and asking "Could this change break anything?" Priya said "No I think it's all good!" The facilitator had to improvise the generator/iterable question. **Recommendation:** Add guidance for when the developer says the diff looks fine: "If the developer accepts without specific analysis, ask one targeted question about edge cases relevant to the change."

**Places where Priya's eager acceptance wasn't handled well:**

- **Act 2 Step 3:** "Wait for the developer to confirm they see the change" — no guidance for distinguishing genuine confirmation from rubber-stamping. The facilitator intervened but this was improvised.
- **Act 3 overall:** No check points at all for developer engagement. The entire act is show-and-tell with no verification that the developer internalized the safety tools. Priya sailed through without being asked to demonstrate anything.
- **Act 4 initial response:** Priya said "Looks good to me!" which triggers the hint path correctly, but the script doesn't specifically address the *pattern* of always saying "looks good." The facilitator catches one instance; the script should note if the developer has said "looks fine/good" at every check point so far and escalate.

**Missing stuck paths for over-accepting developers:**

1. **Cross-act pattern detection.** No script guidance for noticing that the developer has accepted every single thing across Acts 1-4 without ever pushing back, asking a question, or identifying an issue independently. By Act 4, the facilitator should be explicitly flagging this pattern, not just handling each instance in isolation.

2. **Act 3 "prove it" moment.** The Adaptive Shortcut checks if the developer knows git, but there's no equivalent for the standard path. The developer should be asked to run `git diff` themselves or type `git checkout` themselves — not just watch the facilitator do it.

3. **Act 5 "vague diff" acceptance.** If the developer says the vague result "looks fine!" (which Priya's persona would), the script doesn't handle it. It assumes the developer will agree the vague result is bad. Add: "If the developer accepts the vague result, point out what's actually wrong with it before moving to the specific instruction."

**Whether the facilitator successfully coached verification habits:**

Partially. The facilitator caught Priya's rubber-stamping in Act 2 (improvised), guided her through the bug in Act 4 (scripted path worked), and pushed her on specificity in Act 5 (scripted path worked well). However:

- Priya never independently verified anything across all 5 acts.
- Priya never ran `git diff` herself or opened a file herself.
- The Act 4 lesson about "AI writes confident wrong code" landed conceptually but Priya immediately went back to accepting without checking in Act 5.
- The facilitator's sharpest intervention was the improvised "did you actually open the file?" in Act 2. The scripts need more of these built in.

**Overall assessment:** The scripts handle the E9 persona adequately for a single session — the designed surprise in Act 4 lands regardless of the developer's behavior. But the scripts don't build cumulative pressure on the over-accepting pattern. A developer like Priya leaves the session having been told 3 times to check things, but never having actually formed the habit. The scripts would benefit from at least one mandatory "you do it" moment per act where the facilitator refuses to proceed until the developer performs a specific verification action.
