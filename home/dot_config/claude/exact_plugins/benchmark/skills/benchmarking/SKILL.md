---
name: benchmarking
description: This skill should be used when the user asks to "benchmark", "measure performance", "make faster", "optimize performance", "speed up", "profile", "why is this slow", "performance regression", or mentions timing, latency, throughput, or performance problems. Provides comprehensive guidance for creating, running, and optimizing benchmarks.
---

# Benchmarking

Orchestrate the full benchmarking and optimization pipeline: understand goals, assess current state, and delegate to specialized agents.

## Core Workflow

1. **Clarify Goals** - Interview user to understand what they want to optimize
2. **Assess State** - Determine what benchmarks/data exist
3. **Delegate** - Route to appropriate agent based on context

## Interview Questions

When performance questions arise, gather context:

1. **What code?** - Which function, module, or system to optimize
2. **What metric?** - Latency, throughput, memory, startup time
3. **What target?** - Specific improvement goal (e.g., "30% faster") or exploratory
4. **What constraints?** - Time budget, acceptable trade-offs, must-preserve behavior

For incomplete information, make reasonable assumptions and state them explicitly rather than blocking on perfect requirements.

## Delegation Decision Tree

Assess current state and delegate:

| State | Action |
|-------|--------|
| No benchmarks exist | Delegate to `benchmark-writer` |
| Benchmarks exist, no data | Delegate to `benchmark-runner` |
| Have baseline data, want optimization | Delegate to `benchmark-optimizer` |
| Benchmarks have insufficient coverage | Delegate to `benchmark-writer` to expand |
| Just want to measure (no optimization) | Delegate to `benchmark-runner` |

The agents handle further delegation automatically:
- `benchmark-optimizer` → `benchmark-runner` if no baseline
- `benchmark-runner` → `benchmark-writer` if no/insufficient benchmarks

## Language Detection

Detect project language and recommend appropriate tools:

| Language | Primary Tool | Alternative |
|----------|--------------|-------------|
| Rust | Criterion | cargo bench |
| Python | pytest-benchmark | timeit, cProfile |
| JavaScript | tinybench | Benchmark.js |
| TypeScript | tinybench | Benchmark.js |
| Go | testing.B | benchstat |
| Java | JMH | - |
| C/C++ | Google Benchmark | custom |
| Generic/CLI | hyperfine | time command |

For detailed tool usage, see `references/language-tools.md`.

## Statistical Concepts (Practical)

Apply best-effort statistics - inform decisions without blocking on perfection:

**Essential metrics:**
- **Median** - More robust than mean for skewed distributions
- **Standard deviation** - Understand variability
- **Min/Max** - Identify outliers

**Practical significance:**
- >10% difference with low variance → likely real improvement
- <5% difference or high variance → probably noise
- When uncertain, run more iterations rather than debating statistics

For deeper statistical guidance, see `references/statistics.md`.

## Common Pitfalls

Avoid these benchmarking mistakes:

1. **Cold vs warm** - Always include warmup runs
2. **Dead code elimination** - Ensure results are used (compiler may optimize away)
3. **Micro vs macro** - Micro-benchmarks don't always predict real-world performance
4. **System noise** - Close other applications, disable CPU throttling if possible
5. **Cherry-picking** - Report median/mean, not best-of-N

For complete pitfall guide, see `references/common-pitfalls.md`.

## Quick Start Patterns

**"Make this function faster":**
1. Ask for target improvement (or assume 20% as reasonable goal)
2. Check for existing benchmarks
3. Delegate to optimizer (will cascade to runner/writer as needed)

**"Why is this slow?":**
1. Delegate to writer to add instrumentation/logging with timestamps
2. Run instrumented code to identify bottleneck
3. Then decide if formal benchmarks needed

**"Benchmark this before I refactor":**
1. Delegate to writer to create benchmarks
2. Delegate to runner to establish baseline
3. User refactors, then runner compares

## Additional Resources

### Reference Files

- **`references/language-tools.md`** - Detailed per-language benchmark tool usage
- **`references/statistics.md`** - Statistical concepts for benchmarking
- **`references/common-pitfalls.md`** - Mistakes to avoid and how to fix them
