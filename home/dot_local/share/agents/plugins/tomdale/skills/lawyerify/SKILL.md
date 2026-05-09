---
name: lawyerify
description:
  Generate a lawyer-oriented Word document overview of the current GitHub PR
  for legal, counsel, compliance, privacy, security, licensing, contractual, or
  policy review. Use when the user asks to lawyerify a PR, prepare a legal
  review brief, create a counsel-facing PR overview, or produce a Word document
  summarizing legally relevant PR changes.
---

# Lawyerify

Generate a Microsoft Word document that explains the current GitHub PR for
legal review. The document is for lawyers, not engineers: include technical
details when they matter to legal review, and omit implementation trivia that
does not affect counsel's analysis.

## Output

- Save the document under the repository root at
  `.agent/PR-<number>-<short-slug>.docx`.
- Get `<number>` from the GitHub PR number, not from the branch name or user
  prompt.
- Derive `<short-slug>` from the PR title: lowercase, ASCII-safe, kebab-case,
  filesystem-safe, and capped at about eight meaningful words.
- Create `.agent/` if it does not exist.
- Use `python-docx` through `uv`, for example:
  `uv run --with python-docx python <generation-script>`.

## Workflow

1. Resolve the repository root with `git rev-parse --show-toplevel`.
2. Resolve the current PR with:
   `gh pr view --json number,title,url,baseRefName,headRefName,author,body`.
   If no PR exists for the current branch, stop and tell the user a real GitHub
   PR is required because the filename includes the PR number.
3. Gather review context from:
   - PR title, URL, body, author, base branch, and head branch
   - recent commit messages on the PR branch
   - changed files and diff stats
   - focused diffs for files that may be legally relevant
4. Identify legally relevant changes before drafting. Focus on:
   - user data, personal data, privacy, telemetry, retention, consent, or data
     deletion
   - authentication, authorization, access control, permissions, security
     posture, abuse prevention, or incident visibility
   - third-party services, APIs, dependencies, licenses, model/provider usage,
     data sharing, or subprocessors
   - user-facing copy, disclosures, policy terms, contractual commitments, or
     regulated workflows
   - billing, credits, refunds, notifications, availability, reliability, or
     customer-impacting operational behavior
5. Generate the DOCX with `python-docx`. Do not emit only Markdown or plain
   text unless the user explicitly asks for a draft instead of the file.
6. Report the output path and the source PR URL.

## Legal Stance

- Provide factual issue-spotting and questions for counsel.
- Do not give legal advice or state legal conclusions.
- Do not assign legal risk ratings unless the user explicitly asks.
- Be precise about what the diff shows and what remains unknown.
- If a technical detail is included, connect it to why counsel may care.

## Document Structure

Use clear headings and concise prose:

1. PR Overview
2. Legal Review Summary
3. Legally Relevant Technical Changes
4. Data, Privacy, And Security Considerations
5. Third-Party, Licensing, And Contractual Considerations
6. User-Facing Or Policy-Relevant Changes
7. Questions For Counsel
8. Source Materials Reviewed

If a section has no relevant findings, say so briefly instead of inventing
concerns.

## DOCX Formatting

- Use the PR title as the document title.
- Include the PR number, PR URL, base branch, head branch, author, and generated
  date near the top.
- Use heading styles for sections and normal paragraphs for analysis.
- Use bullets for short lists of findings and questions.
- Keep code identifiers, file paths, API names, and configuration keys in plain
  text. Do not paste large code blocks unless a short excerpt is essential for
  counsel's review.
