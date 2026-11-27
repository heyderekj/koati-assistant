#!/bin/sh
# Tells Koati what Gemini CLI is doing on a card left for it: working,
# waiting for your permission, or stopped. Run by the extension's hooks
# (hooks/hooks.json), which pass the extension's folder as $1.
#
# Sends three things only: Gemini's session id, the hook event's name and,
# after one of Koati's own tools, the card it was called on (with the
# pickup round and run Koati gave out for it). Never your prompts,
# commands, file paths or file contents.
#
# Needs KOATI_KEY: a hooks key from Koati's Settings → Your assistant →
# See it on the card → Gemini CLI. Quiet and quick either way: it prints
# only {} for Gemini, never blocks it, and a session that never touches a
# card left for your assistant is never written down.

answer() { printf '{}\n'; exit 0; }

# The key from your shell, or from a .env beside the extension.
if [ -z "$KOATI_KEY" ] && [ -n "$1" ] && [ -f "$1/.env" ]; then
    KOATI_KEY=$(sed -n "s/^KOATI_KEY=['\"]\{0,1\}\([^'\"]*\)['\"]\{0,1\}$/\1/p" "$1/.env" | head -n 1)
fi
# Or from Koati's one-line install, which keeps the key, and the address
# when it isn't koati.app, in a file only you can read.
if [ -z "$KOATI_KEY" ] && [ -f "$HOME/.koati/hooks.env" ]; then
    KOATI_KEY=$(sed -n "s/^KOATI_KEY=['\"]\{0,1\}\([^'\"]*\)['\"]\{0,1\}$/\1/p" "$HOME/.koati/hooks.env" | head -n 1)
    [ -n "$KOATI_URL" ] || KOATI_URL=$(sed -n "s/^KOATI_URL=\(https:[^'\" ]*\)$/\1/p" "$HOME/.koati/hooks.env" | head -n 1)
fi
[ -n "$KOATI_KEY" ] || answer

# The event, on one line, read here and never sent on.
input=$(tr -d '\n\r')
field() { printf '%s' "$input" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1; }

# Only letters, digits, dashes and underscores, so nothing else rides along.
session=$(field session_id | tr -cd 'A-Za-z0-9_-' | cut -c1-120)
event=$(field hook_event_name | tr -cd 'A-Za-z_')
[ -n "$session" ] && [ -n "$event" ] || answer
notice=""
[ "$event" = "Notification" ] && notice=$(field notification_type | tr -cd 'A-Za-z_')

card=""
round=""
run=""
if [ "$event" = "AfterTool" ]; then
    tool=$(field tool_name)
    key=""
    case "$tool" in
        mcp_*koati*get_handoff) key="id" ;;
        mcp_*koati*report_progress | mcp_*koati*ask_person | mcp_*koati*attach_artifact | mcp_*koati*upload_build | mcp_*koati*add_card_note) key="card_id" ;;
    esac
    if [ -n "$key" ]; then
        card=$(printf '%s' "$input" | sed -n "s/.*\"tool_input\"[[:space:]]*:[[:space:]]*{[^}]*\"$key\"[[:space:]]*:[[:space:]]*\"\{0,1\}\([0-9][0-9]*\).*/\1/p")
        # The round and run Koati handed out for it, when the call carried them: only a UUID's characters.
        round=$(printf '%s' "$input" | sed -n 's/.*"tool_input"[[:space:]]*:[[:space:]]*{[^}]*"handoff_round"[[:space:]]*:[[:space:]]*"\([0-9A-Fa-f-]\{36\}\)".*/\1/p')
        run=$(printf '%s' "$input" | sed -n 's/.*"tool_input"[[:space:]]*:[[:space:]]*{[^}]*"run_id"[[:space:]]*:[[:space:]]*"\([0-9A-Fa-f-]\{36\}\)".*/\1/p')
    fi
fi

# Only a session that has touched one of Koati's tools says anything: the
# rest of your sessions, in any project, never call Koati. A marker per
# session, on this machine only, remembers which ones have.
marks="${TMPDIR:-/tmp}/koati-hooks"
mark="$marks/gemini-$session"
if [ -n "$card" ]; then
    mkdir -p "$marks" 2>/dev/null && : > "$mark" 2>/dev/null
elif [ ! -e "$mark" ]; then
    answer
fi
[ "$event" = "SessionEnd" ] && rm -f "$mark" 2>/dev/null

body="{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"report_activity\",\"arguments\":{\"session\":\"$session\",\"event\":\"$event\",\"notice\":\"$notice\",\"runs_in\":\"gemini_cli\",\"card_id\":\"$card\",\"handoff_round\":\"$round\",\"run_id\":\"$run\"}}}"

curl -s -m 4 -o /dev/null -X POST "${KOATI_URL:-https://koati.app/mcp/koati}" \
    -H "Authorization: Bearer $KOATI_KEY" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    --data "$body" 2>/dev/null

answer
