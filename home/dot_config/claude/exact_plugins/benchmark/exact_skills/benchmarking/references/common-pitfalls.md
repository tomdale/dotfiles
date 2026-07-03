# Common Benchmarking Pitfalls

Mistakes that lead to misleading benchmark results and how to avoid them.

## 1. Dead Code Elimination

### The Problem

Compilers optimize away code whose results aren't used:

```rust
// BAD: Compiler may eliminate the entire loop
fn benchmark_bad() {
    for _ in 0..1000 {
        fibonacci(20);  // Result unused, may be optimized away
    }
}
```

### The Fix

Use the result in a way the compiler can't optimize away:

```rust
// GOOD: Use black_box or consume the result
fn benchmark_good(b: &mut Bencher) {
    b.iter(|| {
        black_box(fibonacci(black_box(20)))
    });
}
```

**Language-specific solutions:**
- Rust: `std::hint::black_box()` or `criterion::black_box()`
- C/C++: `benchmark::DoNotOptimize()`
- Java: JMH's `Blackhole.consume()`
- JavaScript: Store result in array or global

## 2. Cold vs Warm Execution

### The Problem

First runs are often slower due to:
- JIT compilation
- CPU cache misses
- Memory allocation
- Lazy initialization

```python
# BAD: First iteration includes startup costs
times = [measure(func) for _ in range(10)]
# times[0] might be 10x slower than times[9]
```

### The Fix

Always include warmup iterations that aren't measured:

```python
# GOOD: Warmup before measuring
for _ in range(5):  # Warmup (not measured)
    func()

times = [measure(func) for _ in range(10)]  # Actual measurement
```

**Warmup guidelines:**
- JVM/JavaScript: 5-10 iterations
- Python: 2-5 iterations
- Native code: 1-3 iterations
- When in doubt, plot first 20 runs and look for stabilization

## 3. Measuring the Wrong Thing

### The Problem

Micro-benchmarks don't always predict real-world performance:

```python
# Micro-benchmark shows implementation A is 2x faster
# But in real app, I/O dominates and A vs B makes no difference
```

### The Fix

1. **Profile first** - Identify actual bottlenecks before optimizing
2. **Benchmark at appropriate level** - Function, module, or system
3. **Include realistic workloads** - Test with production-like data
4. **Measure what matters** - End-to-end latency, not just CPU cycles

**Questions to ask:**
- Does this code actually impact user experience?
- What percentage of total time does this represent?
- Are there I/O, network, or other dominant factors?

## 4. System Interference

### The Problem

Background processes, CPU throttling, and system state affect results:

```bash
# Results vary wildly between runs
Run 1: 150ms
Run 2: 890ms  # Something else was running
Run 3: 160ms
Run 4: 2100ms # CPU throttled due to heat
```

### The Fix

**Reduce interference:**
- Close unnecessary applications
- Disable CPU frequency scaling if possible
- Run on dedicated hardware for important benchmarks
- Use process priority (`nice -n -20` on Unix)

**Account for interference:**
- Run many iterations (50+)
- Use median instead of mean
- Report standard deviation
- Identify and investigate outliers

**For CI environments:**
- Accept higher variance
- Use longer benchmarks to amortize noise
- Compare relative performance (A vs B) not absolute times
- Consider dedicated benchmark runners

## 5. Inadequate Sample Size

### The Problem

Too few iterations lead to unreliable conclusions:

```python
# BAD: 3 runs is not enough
times = [measure(func) for _ in range(3)]
print(f"Average: {sum(times)/3}")  # Meaningless
```

### The Fix

Run enough iterations for statistical reliability:

```python
# GOOD: Enough runs for meaningful statistics
times = [measure(func) for _ in range(100)]
print(f"Median: {statistics.median(times)}")
print(f"Std Dev: {statistics.stdev(times)}")
```

**Minimum iterations by context:**
- Quick sanity check: 10
- Comparative benchmark: 30
- Publication/decision: 100+
- CI regression detection: 50+

## 6. Ignoring Variability

### The Problem

Reporting only mean/median hides important information:

```
Implementation A: 100ms average
Implementation B: 100ms average

# But A is consistent (95-105ms) while B is erratic (50-200ms)
# A is probably better for user experience
```

### The Fix

Always report variability:

```
Implementation A: 100ms median, σ=5ms, p99=110ms
Implementation B: 100ms median, σ=40ms, p99=195ms
```

**Key variability metrics:**
- Standard deviation
- Coefficient of variation (σ/mean)
- p95 and p99 percentiles
- Min/max range

## 7. Cherry-Picking Results

### The Problem

Selecting favorable runs or conditions:

```python
# BAD: Taking best of 10
times = [measure(func) for _ in range(10)]
print(f"Best time: {min(times)}")  # Misleading
```

### The Fix

Report representative statistics:

```python
# GOOD: Report typical case
times = [measure(func) for _ in range(100)]
print(f"Median: {statistics.median(times)}")
print(f"Mean: {statistics.mean(times)}")
print(f"Min: {min(times)}, Max: {max(times)}")
```

**Transparency:**
- Report methodology
- Share raw data when possible
- Acknowledge limitations
- Run on multiple machines if claiming generality

## 8. Incorrect Time Measurement

### The Problem

Using wall-clock time when CPU time matters, or vice versa:

```python
import time

# This includes time when process was sleeping/waiting
start = time.time()
result = func_with_io()
elapsed = time.time() - start
```

### The Fix

Use appropriate timing method:

```python
import time

# For CPU-bound work
start = time.perf_counter()  # High-resolution, includes sleep
# or
start = time.process_time()  # CPU time only, excludes sleep

result = func()
elapsed = time.perf_counter() - start
```

**Timing method choice:**
- `perf_counter()`: General purpose, high resolution
- `process_time()`: CPU time only (excludes I/O wait)
- `monotonic()`: Guaranteed never to go backwards

## 9. Testing Different Code Paths

### The Problem

Benchmarking different inputs exercises different code:

```python
# Fast path for small inputs
def process(data):
    if len(data) < 100:
        return fast_path(data)
    return slow_path(data)

# Benchmark only tests fast path
benchmark(process, small_data)  # Misleading
```

### The Fix

Benchmark representative workloads:

```python
# Test realistic distribution of inputs
small_inputs = generate_small_data(100)
medium_inputs = generate_medium_data(100)
large_inputs = generate_large_data(100)

benchmark_suite([
    ("small", lambda: process(random.choice(small_inputs))),
    ("medium", lambda: process(random.choice(medium_inputs))),
    ("large", lambda: process(random.choice(large_inputs))),
])
```

## 10. Forgetting Memory and Allocations

### The Problem

Focusing only on time while ignoring memory:

```
Implementation A: 50ms, allocates 10MB
Implementation B: 60ms, allocates 100KB

# A looks faster but may cause GC pressure
# In a loop, B might be faster overall
```

### The Fix

Measure memory alongside time:

```bash
# Go
go test -bench=. -benchmem

# Python
pip install memory_profiler
python -m memory_profiler script.py

# Rust with Criterion
# Memory tracking built into benchmarks
```

**Memory metrics to consider:**
- Peak memory usage
- Allocation count
- Allocation rate
- GC pause frequency

## Quick Checklist

Before trusting benchmark results, verify:

- [ ] **Warmup:** Did you run warmup iterations?
- [ ] **Sample size:** At least 30 iterations?
- [ ] **Dead code:** Are results actually used?
- [ ] **Variability:** Is standard deviation reasonable?
- [ ] **Outliers:** Investigated any anomalous results?
- [ ] **Realistic input:** Testing representative workloads?
- [ ] **Environment:** Minimal interference from other processes?
- [ ] **Memory:** Considered allocation overhead?
- [ ] **Right metric:** Measuring what actually matters?
- [ ] **Honest reporting:** Not cherry-picking results?
