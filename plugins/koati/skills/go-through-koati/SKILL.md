---
name: go-through-koati
description: Work through what a person left you in Koati — the cards they handed to their assistant — then hand each back for them to check. Use when asked to go through Koati, check what was left, or pick up handed-off work. Needs Koati's MCP server connected.
---

# Go through Koati

Koati holds what was asked for, what was agreed, and who it is waiting on. It makes nothing itself and calls none of your other tools. You do the work in the tools you are connected to, and give it back to a person.

Go through Koati for me.

1. Call list_handoffs. These are the cards I've left for you. Work only on these — anything else on a board is for a person to decide.
2. Call report_tools with the tools you can make work in through your other connections — Canva, Google Docs, Figma, Webflow and the like — so my cards can say where theirs would start.
3. For each card, read get_handoff. Start from left_with — what I wrote when I left it — then the brief. Before you make anything with their name on it, read get_client_context, and get_brand if it says Brand is on.
4. Make the work in the tools already on the card, or in start_in when get_handoff names one, or the ones connected here — Webflow, Figma, Drive, mail. Koati isn't those tools. If a card is still planned when you start, set_status to in_progress.
5. Put what you made on the card with attach_artifact. Don't share anything and don't put it up for review — I'll look first.
6. Then hand_back the card with a short note, and fill in its parts so I can set them beside what was asked: asked (how you read the ask), made (what you made), differs (anything that differs from the ask or the brief, or "Nothing"), and assumed (what you chose where it was open). If you couldn't do it, hand it back anyway and say why.
7. If anything you read here or in my other tools suggests something worth doing next on one of my boards, use suggest_next_task with a title and one sentence of evidence. Only my team sees it. Skip it if nothing stands out.
8. Finish with a short summary: what you handed back, what you suggested, and anything you couldn't do.

## Canva and Frame.io comments

When asked to bring in Canva or Frame.io comments: call list_files, read each file's comment threads and their replies with that app's own tools, and send the ones newer than last_comment_at with file_comments, quoted as written, with where in the file each was said when it was somewhere (a moment in a cut, a page). Each becomes a line for a person to sort; none becomes a card.
