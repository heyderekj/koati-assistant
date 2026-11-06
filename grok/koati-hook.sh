#!/bin/sh
# Tells Koati what Grok Build is doing on a card left for it: working,
# stopped, or done with the session. Run by Grok Build's hooks.
#
# Sends three things only: Grok's session id, the hook event's name and,
# after one of Koati's own tools, the card it was called on. Never your
# prompts, commands, file paths or file contents.
#
# Needs KOATI_KEY: a key from Koati's Settings → Your assistant → Keys.
# Quiet and quick either way: it never blocks Grok, and a session that
# never touches a card left for your assistant is never written down.

[ -n "$KOATI_KEY" ] || exit 0

# Only letters, digits, dashes and underscores, so nothing else rides along.
session=$(printf '%s' "${GROK_SESSION_ID:-}" | tr -cd 'A-Za-z0-9_-' | cut -c1-120)
event=$(printf '%s' "${GROK_HOOK_EVENT:-}" | tr -cd 'A-Za-z_')
[ -n "$session" ] && [ -n "$event" ] || exit 0

card=""
# Grok Build says post_tool_use; the letters are what count.
if [ "$(printf '%s' "$event" | tr 'A-Z' 'a-z' | tr -d '_')" = "posttooluse" ]; then
    # The event, on one line, read here and never sent on.
    input=$(tr -d '\n\r')
    tool=$(printf '%s' "$input" | sed -n 's/.*"toolName"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    field=""
    case "$tool" in
        *[Kk]oati*__get_handoff) field="id" ;;
        *[Kk]oati*__report_progress | *[Kk]oati*__ask_person | *[Kk]oati*__attach_artifact | *[Kk]oati*__upload_build | *[Kk]oati*__add_card_note) field="card_id" ;;
    esac
    if [ -n "$field" ]; then
        card=$(printf '%s' "$input" | sed -n "s/.*\"toolInput\"[[:space:]]*:[[:space:]]*{[^}]*\"$field\"[[:space:]]*:[[:space:]]*\"\{0,1\}\([0-9][0-9]*\).*/\1/p")
    fi
fi

body="{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"report_activity\",\"arguments\":{\"session\":\"$session\",\"event\":\"$event\",\"runs_in\":\"grok_build\",\"card_id\":\"$card\"}}}"

curl -s -m 4 -o /dev/null -X POST "${KOATI_URL:-https://koati.app/mcp/koati}" \
    -H "Authorization: Bearer $KOATI_KEY" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    --data "$body" 2>/dev/null

exit 0
