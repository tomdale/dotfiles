Launch an autonomous agent for complex, multi-step tasks.

Default: omit isolation. Read-only exploration and planning never use isolation: "worktree"; background or parallel read-only work needs no filesystem isolation. If the target is known, use read, bash, grep, find, or ls directly instead of an agent. Before delegating repository work, identify the actual repository or Workforest task directory; a workspace may contain multiple repositories and may not itself be Git-managed. Never initialize Git just to satisfy isolation. Do not use raw Git worktrees here: use the documented Workforest workflow. For concurrent modifications, first run wf task new, then assign each agent one task/worktree path via absolute cwd; do not ask pi-subagents to create a raw worktree. Use isolation: "worktree" only when the user explicitly requests a raw Git worktree, after verifying cwd is the intended repository and has an existing commit. run_in_background does not imply isolation.

Read-only example: Agent({ subagent_type: "Explore", prompt: "...", description: "Inspect repository", run_in_background: true }). For Workforest changes, pass cwd: "/path/to/task" and omit isolation; Workforest already provides isolation. Use isolated: true only to restrict tools (no extensions/MCP); it is unrelated to filesystem isolation.

Always provide a 3-5-word description. Make prompts self-contained. Launch independent background agents in one message. Summarize completions without polling or sleeping, and verify claimed changes. Use resume for completed agents, steer_subagent for running agents, and inherit_context only when needed.

{{scheduleGuideline}}
