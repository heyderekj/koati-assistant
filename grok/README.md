# Koati's hooks for Grok Build

With these, a card you leave for Grok Build says **Working** or **Stopped**. Grok Build has no hook for a permission prompt, so it never says Waiting.

Grok Build's hooks run a command, so this one is a short `sh` script. It needs `curl`, which macOS and most Linux systems have.

1. In Koati, open Settings → Your assistant → See it on the card → Grok Build, and press Make a hooks key. It can only say what your assistant is doing, nothing else.
2. Put the `export KOATI_KEY=…` line it shows in your shell's profile.
3. Run the line Koati shows under it. It puts `koati-hook.sh` in `~/.grok/` and `hooks.json` in `~/.grok/hooks/koati.json`.

If you have the Cursor CLI: Grok Build's installer replaces Cursor's `agent` command in `~/.local/bin` with its own, and puts `~/.grok/bin` first on your PATH in `~/.zshrc`. Check `which agent` afterwards if you use Cursor's.

The script reads the session id and event name from Grok Build's own environment (`GROK_SESSION_ID`, `GROK_HOOK_EVENT`) and, after one of Koati's own tools, the card id from the event. That's all it sends: never your prompts, commands, file paths or file contents. Without `KOATI_KEY` it sends nothing. It never blocks Grok Build, and a session that never touches a card left for your assistant is never written down.
