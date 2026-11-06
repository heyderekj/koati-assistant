# Koati's hooks for Codex

With these, a card you leave for Codex says **Working**, **Waiting** (a permission it asked for, answered in Codex, never in Koati) or **Stopped**.

1. Add Koati to Codex as an MCP server named `koati` (Koati's Settings → Your assistant shows how), and sign in.
2. Copy `hooks.json` to `~/.codex/hooks.json`. If you already have one, add these entries to it.
3. Run `/hooks` in Codex and trust them. Codex skips hooks it hasn't been told to trust, and asks again if they change.

The card says Waiting only when Codex actually asks you for permission. In its default sandbox some commands are simply blocked without asking, and then the card stays on Working.

Each hook calls Koati's `report_activity` over that same sign-in, with three things only: Codex's session id (Koati keeps a hash of it), the event's name and, after one of Koati's own tools, the card it was called on. Never your prompts, commands, file paths or file contents. A session that never touches a card left for Codex is never written down.

If you named the server something other than `koati`, change `"server"` in each hook to match.
