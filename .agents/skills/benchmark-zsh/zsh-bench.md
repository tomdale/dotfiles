# zsh-bench reference

End-to-end measurements of an interactive login shell through a virtual TTY. It sends keystrokes
and measures behavior that ordinary wall-clock timing misses: when the first prompt appears, when
the first command executes, and how responsive typing and accept-line are.

## Hard requirements

- Zsh 5.8 or newer (checked directly against `ZSH_VERSION`).
- Normally benchmarks the user's login shell, and it must be the login shell —
  `zsh-bench` invokes the shell in login mode by default.

## Install / update

Keep the checkout outside the dotfiles tree, e.g. `~/.cache/zsh-bench`.

```zsh
mkdir -p "$HOME/.cache"
git clone --depth=1 https://github.com/romkatv/zsh-bench.git "$HOME/.cache/zsh-bench"
```

Update an existing checkout with `git -C "$HOME/.cache/zsh-bench" pull --ff-only`. Do not run a
network operation automatically if an existing checkout has local changes; inspect and ask first.

## Flags

- `--iters NUM` — iterations. Default `16`. Use at least 16 for comparisons.
- `--login yes|no` — include login behavior. Default `yes`. Set `--login no` to isolate
  non-login setup; compare the two to attribute cost to login-specific files.
- `--git yes|no|empty` — the Git fixture state (default `yes`):
  - `yes` — working tree inside a populated Git repo (realistic).
  - `no` — no Git repo at all.
  - `empty` — an empty Git repo (no commits); isolates Git-prompt/repo-specific cost without
    the data of a real checkout.
  Use the same value across runs you compare.
- `--config-dir DIR` — benchmark a predefined config fixture (see Config fixtures).
- `--scratch-dir DIR` — retain temporary TTY data for later replay/debugging.
- `--isolation docker|user` — benchmark configs in isolation:
  - `docker` — container isolation; reproducible, requires Docker.
  - `user` — a local system user; faster and no daemon, less strict isolation.
  Prefer `docker` when reproducibility matters; `user` for quick local runs.
- `--standalone` — run a single shell without the normal comparison harness when appropriate.
- `--no-compare` (where applicable) — disable automatic comparison output when you only want the
  raw shell behavior.
- `--raw` — emit raw metrics in shell-assignable form across all iterations (see Raw vs capped).

## Standard benchmark

```zsh
"$HOME/.cache/zsh-bench/zsh-bench" --iters 16 --login yes
# quick check
"$HOME/.cache/zsh-bench/zsh-bench" --iters 3 --login yes
# machine-readable comparison
"$HOME/.cache/zsh-bench/zsh-bench" --iters 16 --login yes --raw
```

## Metrics

Five metrics are reported, in order:

- `first_prompt_lag_ms` — time until the first prompt is visible.
- `first_command_lag_ms` — time until the first interactive command can execute. This includes
  `first_prompt_lag` plus everything up to when the shell becomes interactive; a command typed
  before `first_command_lag` completes will not execute.
- `command_lag_ms` — from accepting an empty command line to the next prompt.
- `input_lag_ms` — time from a keystroke to the character appearing while editing a long command
  line. Reported as the minimum of multiple keystroke samples (not a single measurement), so it
  reflects the best-observed render.
- `exit_time_ms` — process exit time. Report only as a secondary diagnostic, never as the
  primary startup result (see How not to benchmark).

`zsh-bench` also detects capabilities and prints them as flags:

- `creates_tty=1` — the shell creates its own TTY by invoking `tmux` or `screen`. Steer clear of
  benchmarking a shell that auto-launches `tmux` unless that is the behavior under test.
- `has_compsys=1` — completion system initialized (detected from an internal binary field).
- `has_syntax_highlighting=1` — syntax highlighting active.
- `has_autosuggestions=1` — autosuggestions active.
- `has_git_prompt=1` — Git prompt configured.

A change that removes any of these capabilities is not an improvement.

## Raw vs capped output

- Default (non-raw): across `--iters` runs, per metric only the **minimum** value is kept. This
  silently selects the fastest iteration and can hide variability.
- `--raw`: values from **all** iterations are accumulated in shell arrays, printed as
  `name=( v1 v2 v3 ... )`. Post-process these (median, percentiles) for a robust comparison.
  If the skill instructs "use median and spread, not just the fastest", that means running
  `--raw` and computing the median yourself — non-raw output already collapses to the minimum.

## Config fixtures

`--config-dir DIR` benchmarks a predefined configuration. The upstream repo ships dozens under
`configs/`, including: `no-rcs`, `tmux`, `compsys`, `zsh-syntax-highlighting`,
`zsh-autosuggestions`, `git-branch`, `prezto`, `ohmyzsh`, `zim`, `zsh4humans`, `agnoster`,
`starship`, `powerlevel10k`, and various plugin-manager setups. Check the repo's `configs/`
directory for the current list and use them as comparison baselines. Notable upstream findings:

- Well-configured plugin managers (ohmyzsh+, prezto+, zim+, zinit, zcomet, zplug) reach similar
  performance; none beats a minimal `diy++` by much. Don't pick a manager on stale "fastest"
  benchmarks.
- Every config achieving near-instant startup (roughly 10-19% of the first-prompt threshold) uses
  Instant Prompt or an equivalent trick — "the closest thing to a silver bullet".

## Instant Prompt

The highest-impact technique for fast `first_prompt_lag`. Achieve it by printing a pre-rendered
snapshot of the prompt before the shell blockingly renders it. The `.zshrc` must be split into
three ordered sections so nothing important depends on interactive-only behavior being available
too early:

1. Write the prompt snapshot and print it (instant prompt shows immediately).
2. Initialize completion and other setup that can run without interactive features.
3. Activate and load the real prompt (e.g. powerlevel10k's), which replaces the snapshot.

The precise split and reserved-variable names are defined by the prompt engine (powerlevel10k's
`POWERLEVEL9K_INSTANT_PROMPT`). If a config uses Instant Prompt, benchmark with it; the technique
is measured through `first_prompt_lag`, not `exit_time`.

## Function-level profiling

When `zsh-bench` shows startup lag, use `zprof` to locate shell-function costs without editing
managed configuration:

```zsh
zsh -dfic '
  zmodload zsh/zprof
  source "$HOME/.config/zsh/env.zsh"
  source "$HOME/.config/zsh/.zshrc"
  zprof
'
```

If startup files need normal interactive setup, use a temporary `ZDOTDIR` wrapper that loads
`zsh/zprof` before sourcing the managed files, and capture stderr separately (integrations may
print terminal-control sequences). `zprof` covers shell functions only; pair it with focused
command timing for external process launches or filesystem waits.

## Debugging: dbg/replay and dbg/timeline

The upstream repo ships a debugging harness under `dbg/` for inspecting a recorded run:

- `dbg/replay` — replay a recorded TTY transaction captured with `--scratch-dir`. Options
  include `--pause-at-ms`, `--delay-multiplier`, and `--max-delay-ms` to slow/step through the
  interaction.
- `dbg/timeline` — view the timestamped TTY transactions to see exactly what happened when.

Use these when a metric is unexpectedly slow and you need to see the actual keystroke/prompt
timeline to attribute the cost.

## How not to benchmark

`exit_time_ms` (what `time zsh -lic exit` measures) is essentially uncorrelated with perceived
startup lag. Concrete upstream examples: agnoster has a 32 ms first prompt but 2 ms exit; while a
leaner config can have a 2 ms first prompt yet 6 ms exit. Trusting `exit_time` has misled plugin
managers into optimizing the wrong thing. Always report `first_prompt_lag`/`first_command_lag`
as the primary results.

## Human-perception thresholds

The upstream author established these via a blind study (using the bundled `human-bench`,
which can randomize multiple latency values) — they are human-derived, not universal numbers.
As rough reference points approximately indistinguishable from zero for the author:

- `first_prompt_lag_ms` around 50 ms
- `first_command_lag_ms` around 150 ms
- `command_lag_ms` around 10 ms
- `input_lag_ms` around 20 ms

## Caveats

- **tmux hang**: if the startup files under test start `tmux`, the benchmark may hang unless the
  tmux build includes a specific fix for a known bug. If you must benchmark such a config, either
  fix/update tmux or avoid the auto-launch; don't silently drop the measurement.
- **History pollution**: if the shell under test enables history but not `histignorespace`,
  benchmark keystrokes can land in your history. Set `setopt histignorespace` in the config under
  test, or expect stray commands in history.
- Login shell + Zsh 5.8+ is a hard requirement when benchmarking the default login shell.
- Keep machine, terminal, working directory, Git fixture, Proto/toolchain state, environment,
  and options constant across runs; alternate order; use median and spread.
