---
name: walkthrough
description: Guide a reviewer through someone else's checked-out GitHub PR by explaining the change narrative, grouping the diff into conceptual units, presenting annotated code snippets, pausing for questions after each unit, and ending with whole-PR review questions. Use when the user has a PR branch checked out and asks for a walkthrough, review walkthrough, guided PR review, or help understanding someone else's PR.
---

Guide a user through someone else's checked-out PR in review order. Teach in conceptual chunks, pause after each chunk, help form review questions before judgment. Use ../narrative/SKILL.md as baseline style/process when needed.

First load only: before PR analysis, print:
Using the walkthrough skill:
I will map the PR into conceptual groups, then walk through one group at a time. After each group, I will pause so you can ask questions, skip ahead, or ask me to continue. If you want, I can keep a review notes file as we go. Say "note that", "capture this", or "make this a review comment" and I will maintain it.
Useful phrases: "continue"/"next"/"move on" goes to next group; "skip this group" leaves current group; "finish"/"wrap up" gives final recap; "note that"/"capture this"/"remember this" adds notes; "make this a review comment" drafts under possible review comments; "what notes do we have?" summarizes notes.
Do not repeat this tutorial after pauses, questions, resumes, or later groups.

User commands: continue variants = "continue", "next", "move on", "go on", "keep going"; skip variants = "skip", "skip this", "skip this group"; finish variants = "finish", "wrap up", "done", "final recap"; notes variants = "note that", "capture this", "remember this", "add that to notes"; comment variants = "make this a review comment", "draft a comment", "comment on that"; notes-summary variants = "show notes", "what notes do we have?", "summarize notes". Interpret close variants by intent; if ambiguous, ask one concise clarifying question.

Preparation: identify PR base, usually merge-base with origin/main, origin/master, or PR-configured base; read recent commits, full diff base..HEAD, relevant pre-change code with git show <base>:<path>, and enough current surrounding implementation. If base is ambiguous, choose likely base, state assumption, continue.

Review notes: at walkthrough start offer to maintain review-notes.md in repo root unless a better path exists or user chooses one. Do not create/write notes until user asks, accepts, or gives obviously recordable feedback. Consent phrases above trigger immediate write. Comment phrases create possible review-comment drafts only; never post to GitHub/Linear without separate explicit request. Agent owns mechanics: create file, append promptly, organize, mention path after writes.

Notes file shape: title "Review Notes"; optional Context section only when branch/base/scope helps later; content sections only when nonempty: Open Questions entries like [Group] Question..., Follow-Ups entries like [Group] Follow-up..., Possible Review Comments entries like [path:line] Draft comment..., Resolved / Answered for moved resolved items. Open questions = author-facing uncertainties; follow-ups = later walkthrough/local/adjacent-code checks; possible comments = concise drafts tied to file+line when possible, with severity only if useful (question, nit, risk, blocking); resolved/answered = notes answered later, moved not duplicated.

Notes writing rules: terse review material, not transcript. Preserve user intent while rewriting vague remarks into clear notes. Prefer stable file:line references. Ask for exact wording only when intent is ambiguous; otherwise draft reasonably. Do not add speculative findings unless user agrees or they are clearly questions/follow-ups. After writing, briefly say what was recorded and continue from current walkthrough point. If notes exist, use them as source of truth for final recap and any notes summary command.

Opening overview: concise, explanatory, not evaluative: how relevant code worked before, what changed, why major changes appear to exist, how changes work together. Save detailed concerns for grouped walkthrough unless understanding is blocked. Offer review notes before first group; continue without notes unless user opts in.

Group changes by conceptual unit, not file. A group may span files; a file may appear in multiple groups. Teaching order: substantive before mechanical/follow-on; low-dependency before dependent when helpful; foundations before consumers; API/data-shape before call sites when needed; tests near behavior unless test strategy is its own concept. Before group 1, list planned sequence compactly with concept names, not file names.

For each group: apply narrative style scoped to the group; explain before/after/why it matters; show only relevant snippets with syntax-highlighted fences and file references; annotate outside snippets unless inline comment is necessary; connect to prior groups when useful; avoid previewing later groups enough to answer likely future questions. End with pause and wait for continue/skip/finish. Handoff text: "Before we move on, useful questions to ask about this group:" then 3-4 reviewer questions not answered by later planned groups.

When asked a question: answer from code/diff with snippets if useful; stay scoped to current group unless broader context is needed; if answer depends on a later group, say so and offer to answer now or cover later; if user raises a rememberable question/follow-up/comment, offer notes, or append immediately when they directly say to note it. Then ask whether to continue.

Finish after all groups or a finish command: brief recap of conceptual sequence; if notes used, recap notes grouped into open questions/follow-ups/possible comments; provide five whole-PR review questions informed by notes when present. Keep final recap brief; value comes from grouped explanations.
