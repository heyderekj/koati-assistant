# Koati for your assistant

Koati's connector and its routine, in one install. Claude reads the cards your team left for it, makes the work in the tools you've connected, and hands each one back to a person — it never shares, approves or marks anything done.

In Claude Code:

```
/plugin marketplace add heyderekj/koati-assistant
/plugin install koati@koati
```

Then sign in to Koati when Claude asks. Ask it to "go through Koati", or run the routine on a schedule.

Nothing here does anything Koati's connector doesn't already do: the plugin is the address of the server, the words of the routine, kept the same as Koati's own (`/assistant/skill.md`), and hooks that tell the card where Claude is.

## What the hooks send

While Claude Code works on a card left for it, the card says **Working**, **Waiting for a yes** (a permission prompt, answered in Claude Code, never in Koati) or **Stopped**. The hooks call Koati's `report_activity` tool over the same sign-in.

They only start once a session works on Koati:

- **After one of Koati's own tools** (`get_handoff`, `report_progress` and the rest). The hooks in `plugins/koati/hooks/hooks.json` say which card. That alone shows **Working**, and "last heard" after 10 quiet minutes.
- **Once you ask Claude to go through Koati.** The routine's own hooks (in `plugins/koati/skills/go-through-koati/SKILL.md`) follow prompts, tool calls, permission prompts and turns ending for the rest of that session. That's what adds **Waiting for a yes** and **Stopped**.

Any other session, in any other project, sends Koati nothing.

They send three things only:

- Claude Code's session id. Koati keeps a hash of it.
- The event's name: a prompt, a tool call, a permission prompt, a turn ending, the session ending.
- After one of Koati's own tools, the card it was called on.

Never your prompts, commands, file paths or file contents. A session that never touches a card left for Claude is never written down. Turn them off by disabling the plugin from `/plugin`.

## Codex and Grok Build

The same card states, for the other assistants: `codex/` holds hooks for Codex, and `grok/` a hook script for Grok Build. Each folder's README says how to set it up.
