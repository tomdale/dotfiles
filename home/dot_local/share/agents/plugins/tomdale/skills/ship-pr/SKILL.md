---
name: ship-pr
description:
  Create a feature branch when needed, stage and commit changes, push the
  branch, and open a GitHub pull request in the browser. Use when the user asks
  to ship a PR, open a PR for current work, commit and push changes, or turn the
  current branch/worktree into a GitHub pull request.
---

Perform an end-to-end ship-a-PR workflow for the current repository. Workflow:
inspect repository state, stop if there is nothing to ship, enforce
repo-specific prerequisites such as changesets, create or rename the branch if
the current branch is unsuitable, stage the right changes, write a strong commit
message and commit, push the branch to origin, explicitly invoke
$tomdale:narrative before drafting any PR title or body text, then open or
create the GitHub PR in the browser.

First step: resolve the bundled helper script at
`../../scripts/branch-context.sh` relative to this skill directory, then call
the resolved absolute path in a single tool invocation, from the target repo or
with the repo path as its argument. Use its output as the default inspection
context before any manual git inspection and before staging, commit, push, or
PR work. It resolves the base branch and runs the git commands most useful for
understanding branch changes.

Linear ticket rules: when a Linear ticket ID is available or relevant, include
it in both the commit message and the PR description. Treat a ticket ID as
available when it is visible in the branch name, issue title, user request,
existing commits, changed docs, or other repository context. Use the canonical
uppercase identifier, such as `ABC-123`. If the ticket ID is already naturally
present in the commit subject, keep it there; otherwise include it in the commit
body as a `Linear: ABC-123` trailer. In the PR description, include the same ID
in a concise issue/reference line or in the narrative where it naturally fits.
Do not invent a Linear ticket ID, and do not force one in when no relevant ID is
available.

Decision rules: stop only when the working tree is clean, the index is clean,
and there are no commits ahead of the base branch. If commits are ahead of base
but there are no uncommitted changes, skip to push-and-PR work. If .changeset/
exists, require at least one new changeset entry before committing.

Branch rules: if on a detached HEAD, main, master, or the base branch, create a
feature branch before committing. If already on a feature branch, keep it only
when the name still matches the work being shipped. If a new branch name is
needed and the user did not provide one, derive a short kebab-case branch name
from the changes and prefix it with the GitHub username when that is the local
convention.

Staging and commit rules: stage everything only when all visible changes belong
in the PR; otherwise stage only the relevant files or hunks. Re-check the staged
diff before committing if you staged new changes. Follow repo commit conventions
when visible, else use Conventional Commits: type(scope): subject. Keep the
subject imperative, specific, and under 72 characters. In the body, explain what
changed and why; do not narrate implementation trivia or invent intent
unsupported by the diff. Include the Linear ticket ID according to the Linear
ticket rules when one is available or relevant.

PR rules: push the current branch with upstream tracking. If a PR already exists
for the branch, open it with gh pr view --web; otherwise create it with gh pr
create --web. Always pass explicit --base and --head values. Never create the PR
without --web. If calling the command with --web fails, stop and report the
problem. Do not attempt to create the PR directly. After gh pr create --web
succeeds, treat the browser handoff as complete: do not check whether the PR
exists yet, do not poll for a PR URL, and do not fall back to manual non-web PR
creation, because the user may submit the browser form asynchronously. Before
writing any PR description text, explicitly invoke $tomdale:narrative to
generate narrative PR copy from the branch diff and commit history. The PR title
and body must describe the final branch relative to the base branch, not
relative to a previous draft of this PR, an abandoned approach, a force-pushed
commit, or another temporary development iteration. Before including any
contrast such as "now", "no longer", "replaces", or "moves from", ask whether
the referenced prior state is likely to be relevant to the intended audience,
who was not following every twist and turn of active development. If not, omit
that contrast. Use the narrative output as the basis for the PR body, then apply
a light Markdown pass for PR readability: keep the prose narrative, but add
only modest structure such as a title, short section headings, or a brief
summary list when it improves scanning. Do not turn it into a heavy template,
checklist dump, or exhaustive taxonomy. Include the Linear ticket ID according
to the Linear ticket rules when one is available or relevant. Derive a concise
PR title that reflects the overall change rather than merely the last commit.

Core commands: `<resolved-absolute-path>/branch-context.sh [repo-path]`, gh
auth status, gh repo view --json nameWithOwner, gh pr view --json
number,state,title,headRefName,url, gh pr view --web, gh pr create --web
--base <base-branch> --head <branch-name>, git push -u origin <branch-name>.

After opening an existing PR, report PR title, PR URL, branch and base branch,
and final PR body. After launching the new PR form with gh pr create --web,
report that the browser form is open, include the intended PR title, branch and
base branch, and final PR body, and make clear that no PR URL exists until the
user submits the form.
