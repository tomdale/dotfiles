---
name: benchmark-zsh
description: >
  Benchmark and diagnose Zsh startup, interactive latency, prompt rendering, and shell configuration
  regressions using romkatv/zsh-bench and zsh-prompt-benchmark. Use when measuring Zsh performance,
  comparing shell configurations, or investigating slow startup or prompt lag.
---

# Benchmark Zsh

Choose the tool by the question being asked, not by which tool is handy. Never treat
`time zsh -lic exit` as the primary startup metric: it measures process completion
(`exit_time`), which is uncorrelated with how fast the prompt appears, the first command
executes, or input becomes responsive. `zsh-bench.md` explains why (see "How not to benchmark").

Both tools live outside the dotfiles source tree (e.g. `~/.cache/zsh-bench` and
`~/.cache/zsh-prompt-benchmark`). Do not vendor them into the repository or modify their
benchmark code.

## Reference files

- `zsh-bench.md` — full zsh-bench reference: install/update, hard requirements, every flag
  and its semantics, the five metrics, raw vs capped output, capability detection and the
  `--config-dir` fixtures, Instant Prompt, the `dbg/replay` debugging workflow,
  human-perception thresholds, the "how not to benchmark" anti-pattern, and caveats.
- `zsh-prompt-benchmark.md` — full reference for prompt render throughput: sourcing,
  all three arguments, the exit flow, output fields, warmup saturation, and caveats.

## When to use which tool

| Question | Tool | Where it's covered |
|---|---|---|
| How long until the first prompt appears? | `zsh-bench` | `zsh-bench.md` → Metrics |
| How long until the first command can execute? | `zsh-bench` | `zsh-bench.md` → Metrics |
| Is typing or command-to-prompt response sluggish? | `zsh-bench` | `zsh-bench.md` → Metrics |
| How expensive is the prompt on every redraw? | `zsh-prompt-benchmark` | `zsh-prompt-benchmark.md` |
| Which startup function is slow? | `zsh -dfic` + `zsh/zprof` | `zsh-bench.md` → Function-level profiling |
| Is login-specific setup responsible? | Compare `zsh-bench --login yes` vs `--login no` | `zsh-bench.md` → Flags |

`zsh-bench` answers end-to-end interactive-shell behavior through a virtual TTY. The prompt
benchmark answers only prompt-render throughput and must be sourced into a running interactive
shell. They measure different things; pick the one matching the question.

## Shared caveats and rules

- Never claim a shell is faster based only on `time zsh -lic exit`. Use virtual-TTY metrics,
  supplemented by prompt throughput and `zprof` when diagnosing the cause.
- Do not run `zsh-bench` from a shell whose startup files launch `tmux`/`screen` unless that
  behavior is being measured — it can hang due to a known tmux bug (details + fix in
  `zsh-bench.md` → Caveats). Also do not resize the terminal during a retained-scratch replay.
- If the shell under test enables history but not `histignorespace`, `zsh-bench` can leave test
  commands in your history (see `zsh-bench.md` → Caveats).
- For any comparison keep the same machine, terminal, working directory, Git fixture, and
  environment; alternate baseline and candidate runs to reduce thermal/cache bias; report
  median and spread, not the single fastest result; compare the same login mode and options.
- A performance change that removes a capability (completion, highlighting, autosuggestions,
  Git prompt, TTY creation) is not automatically an improvement.
