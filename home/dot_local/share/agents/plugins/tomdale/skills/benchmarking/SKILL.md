---
name: benchmarking
description: Measure performance and improve code methodically. Use when the user asks to benchmark, profile, optimize, speed up, or investigate a performance regression.
---

# Benchmarking

Use this skill when the task is about performance rather than correctness
alone.

## Workflow

1. Clarify the target.
2. Check for existing benchmarks or instrumentation.
3. Establish a baseline.
4. Improve one thing at a time.
5. Re-measure after each change.
6. Keep only changes that produce meaningful gains.

## Clarify First

Gather or infer:

- What code path matters
- What metric matters: latency, throughput, memory, startup, CPU
- Whether the goal is exploratory or target-based
- What tradeoffs are unacceptable

State assumptions explicitly if the user did not specify them.

## Language-Specific Defaults

- Rust: `cargo bench`, Criterion
- Python: `pytest --benchmark-only`, `timeit`, `cProfile`
- JavaScript/TypeScript: `tinybench`, project `bench` scripts
- Go: `go test -bench=. -benchmem -count=10`
- Generic CLI workflows: `hyperfine --warmup 3 --min-runs 30`

## Measurement Rules

- Warm up before judging results.
- Prefer medians over single best runs.
- Capture enough runs to distinguish signal from noise.
- Measure the user-relevant path, not only a tiny micro-benchmark.

## Practical Statistics

Always report:

- Median
- Mean
- Spread: standard deviation, variance, or percentile range
- Before/after percentage change when comparing runs

Useful heuristics:

- More than 10% with low variance is usually real
- Less than 5% is often noise unless the benchmark is very stable
- High variance means the setup may be flawed or under-sampled

## Common Mistakes

- Comparing cold and warm runs as if they were equivalent
- Benchmarking code the compiler can eliminate
- Measuring too small a unit and inferring too much
- Running on a noisy machine and over-reading the results
- Making several optimizations at once and losing causality

## Optimization Rules

- Establish a baseline before changing code.
- Make one meaningful change at a time.
- Revert changes that do not help.
- Keep notes about which hypothesis each change was testing.

## Output Style

When reporting results:

- Lead with the concrete outcome
- Separate measured facts from interpretation
- Call out whether the change looks real, uncertain, or negative
- Mention remaining risks such as insufficient coverage or noisy results
