---
name: pr-feedback
description: Draft and post GitHub PR review feedback with user approval. Use when the user asks to review a PR, turn review notes into PR feedback, draft inline GitHub comments, create a pending PR review, approve comments one at a time, or submit a final general review comment.
---

# PR Feedback

## Overview

Turn a checked-out PR or existing review notes into high-signal GitHub review
feedback. Prefer precise inline comments for code-specific concerns, save
cross-cutting feedback for the final general review comment, and post nothing
until the user approves the exact wording.

## Prepare

Before drafting comments:

1. Identify the PR with `gh pr view --json number,url,headRefName,baseRefName,title`.
2. Identify the review base, usually the PR base branch or merge base.
3. Read the diff, surrounding implementation, relevant tests, and any local
   review notes. If the user has not already built review context, use the
   `walkthrough` or `narrative` skill patterns to understand the PR first.
4. Keep a local list of candidate feedback, grouped as inline comments first and
   general review themes second.

Do not post discovery notes, rough drafts, or unapproved comments to GitHub.

## Draft Inline Comments

Draft one proposed inline comment at a time. For each proposal, show:

- The file and nearby code or line being commented on.
- The exact Markdown body to post.
- A short prompt asking the user to approve, edit, or skip.

Wait for the user's response before proposing or posting the next comment.
Apply requested wording changes and ask for approval again if the final text
changed materially.

Good comments:

- Cite specific code and behavior.
- Ask the contract, ownership, lifecycle, state, failure-mode, or test-coverage
  question that the code raises.
- Explain why the question matters without overstating certainty.
- Tag requested reviewers exactly as the user asks.

Avoid:

- Vague architectural discomfort without code evidence.
- Long lists of unrelated concerns in one inline comment.
- Nitpicks unless they point at a real modeling or maintainability issue.
- Rephrasing local environment workarounds as verification instructions.

## Use Pending Reviews

Use a pending GitHub PR review for approved inline comments. Do not create
standalone PR comments unless the user explicitly asks.

Recommended flow:

1. Create the first pending review with the first approved inline comment using
   the GitHub REST review creation endpoint.
2. Keep the pending review id and node id.
3. For later approved inline comments, append to the existing pending review
   instead of deleting and recreating it.
4. Use GitHub GraphQL `addPullRequestReviewComment` when REST cannot append:
   provide `pullRequestReviewId`, `commitOID`, `path`, `position`, and `body`.
5. Compute GitHub diff positions from `gh pr diff --patch` or
   `git diff --unified=3 <base>...HEAD -- <path>`.

If a GitHub API call fails, explain the failure briefly, preserve the approved
comment text locally, and choose the least surprising recovery path. Do not
submit the pending review while recovering from comment-posting failures.

## Final Review Comment

After all inline candidates have been approved, skipped, or exhausted:

1. Summarize the pending inline comments for the user.
2. Draft one general review comment for concerns that do not attach cleanly to a
   diff line.
3. Ask the user to approve, edit, or skip the general comment.
4. Submit the pending review only after the user approves the final general
   review body or explicitly asks to submit without one.

The general comment should connect the inline comments into the larger review
theme. Keep it concise and focused on the contract needed to evaluate the PR,
not a second full walkthrough.

## Completion

When finished, report:

- The submitted review URL or pending review id.
- The number of inline comments included.
- Whether a general review comment was submitted.

