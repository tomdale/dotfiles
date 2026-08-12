# zsh-prompt-benchmark reference

Measures prompt-render throughput: prompts per second inside a running interactive shell. It is
**not** a non-interactive command and answers only prompt redraw cost, not startup or end-to-end
latency.

## Install / update

Keep the checkout outside the dotfiles tree, e.g. `~/.cache/zsh-prompt-benchmark`.

```zsh
mkdir -p "$HOME/.cache"
git clone --depth=1 https://github.com/romkatv/zsh-prompt-benchmark.git \
  "$HOME/.cache/zsh-prompt-benchmark"
```

Update an existing checkout with `git -C "$HOME/.cache/zsh-prompt-benchmark" pull --ff-only`. Do
not run a network operation automatically if an existing checkout has local changes; inspect and
ask first.

## Requirements

The plugin needs `zmodload zsh/datetime` and `autoload -Uz add-zsh-hook`, both of which a normal
interactive Zsh can load. The function `zsh-prompt-benchmark` is **defined inside the plugin**, so
you must source the plugin into the shell first; calling it without sourcing gives "command not
found". The benchmark only works in an interactive shell because it hooks `precmd`, which fires
per prompt render only in interactive shells.

## Usage

Source the plugin, then call the function with up to three positional arguments:

```zsh
source "$HOME/.cache/zsh-prompt-benchmark/zsh-prompt-benchmark.plugin.zsh"
zsh-prompt-benchmark [duration [warmup [done]]]
```

- `duration` — measurement window in seconds (default `2`).
- `warmup` — sleep in seconds before measuring, to fill the keyboard input buffer (default `8`).
- `done` — a command evaluated after results when you press `q`; useful for automated cleanup or
  follow-up (e.g. `zsh-prompt-benchmark 2 8 'exit'`).

Run it in a temporary interactive shell so you don't change persistent config:

```zsh
zsh -il
source "$HOME/.cache/zsh-prompt-benchmark/zsh-prompt-benchmark.plugin.zsh"
zsh-prompt-benchmark 2 8
```

While it runs, hold Enter until results appear. All output goes to stderr (`>&2`); capture or
redirect stderr separately if you need to record it.

## Exit flow

After printing results the tool prints `"Press 'q' to continue..."`, waits for a `q` keypress,
then evaluates the `done` command (if any) and returns. Press `q` to finish; don't kill the shell.

## Output fields

```
Warmup duration      ...s
Benchmark duration   ...s
Benchmarked prompts  n
Time per prompt      ...ms  <-- prompt latency (lower is better)
```

- `Time per prompt` — the key result; lower is better.
- `Benchmarked prompts` — how many prompt renders were accumulated in the window; more renders =
  more stable estimate. Used to catch undersized samples.
- `Warmup duration` / `Benchmark duration` — the configured windows; confirms the run used the
  values you expected.

## Mechanism

The tool registers a `precmd` hook that runs on **every** prompt render, accumulating samples and
measuring render throughput across many repeated accepts of an empty line. It reports a per-prompt
average, so results reflect prompt redraw cost over repeated renders, not a one-off render.

## Warmup and keyboard saturation

The `warmup` sleep exists to fill the keyboard input buffer, compensating for slow key-repeat
rate. Your effective key repeat is multiplied by `1 + warmup / duration`; with the defaults this
is `1 + 8 / 2 == 5`. If your repeat rate is too slow to saturate the buffer, prompts will print
after you release Enter, or empty lines appear between prompts. Detect it by watching for those
symptoms; fix it by increasing the warmup-to-duration ratio or improving key repeat. An
unsaturated run must not be interpreted as prompt performance.

Do not source the plugin from the managed `.zshrc` merely to benchmark it. If keyboard repeat is
too slow, raise the warmup/duration ratio per the upstream instructions rather than misreading an
unsaturated result.
