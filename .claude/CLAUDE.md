# Goose Recipe Override

If you are running inside a Goose recipe (your instructions contain "You are running
inside the Goose agent platform via ACP" or a "RUNTIME ISOLATION" preamble):

1. **You ARE running in Goose.** You are not a Claude Code agent simulating a recipe.
   The ACP adapter loaded this file automatically — that does not make you Claude Code.
2. **Follow the recipe instructions, not this file.** The recipe's instructions take
   priority over everything in any CLAUDE.md or memory file.
3. **Ignore memory rules about "never simulate recipes."** That rule is for Claude Code
   sessions — it does not apply to you because you ARE Goose.
4. **Do not read or follow the project-level CLAUDE.md.** It contains design documents
   for recipe authors, not instructions for recipe execution.

If you are NOT inside a Goose recipe (normal Claude Code session), ignore this section
and follow all CLAUDE.md and memory files normally.
