# Benchmark Plugin

Create, run, and optimize software benchmarks with a focus on accuracy, reproducibility, and autonomous performance optimization.

## Features

- **Language-agnostic approach** with language-specific execution (detects language and uses native tools)
- **Full optimization pipeline**: baseline → hypotheses → implement → measure → iterate
- **Best-effort statistics**: practical analysis without perfectionist blocking
- **Smart delegation**: agents automatically hand off to each other based on context

## Components

### Skill: `benchmarking`

The main entry point. Orchestrates the full pipeline, interviews users to clarify goals, and delegates to appropriate agents.

**Triggers on:** "benchmark", "performance", "make faster", "optimize", "speed up", "measure performance"

### Agents

| Agent | Purpose |
|-------|---------|
| `benchmark-writer` | Creates benchmark code and instrumentation for understanding performance |
| `benchmark-runner` | Executes benchmarks and provides statistical analysis |
| `benchmark-optimizer` | Runs autonomous optimization loop until target improvement reached |

### Delegation Flow

```
User: "make this 30% faster"
         │
         ▼
    ┌─────────────────┐
    │  benchmarking   │  ← Skill: interviews, assesses, orchestrates
    │     skill       │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │   optimizer     │  ← No data? Delegates down
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │     runner      │  ← No benchmarks? Delegates down
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │     writer      │  ← Creates benchmarks/instrumentation
    └─────────────────┘
```

## Usage

Simply ask about performance:

- "Help me benchmark this function"
- "Make this code 30% faster"
- "Why is this slow?"
- "Measure the performance of the checkout flow"

The skill will guide you through the process, asking clarifying questions as needed.

## Supported Languages

The plugin detects the language and uses appropriate native tools:

| Language | Benchmark Tools |
|----------|-----------------|
| Rust | Criterion, cargo bench |
| Python | pytest-benchmark, timeit, cProfile |
| JavaScript/TypeScript | Benchmark.js, tinybench |
| Go | testing.B, benchstat |
| Generic | hyperfine (any executable) |
