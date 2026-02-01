# Language-Specific Benchmark Tools

Detailed guidance for benchmarking in each language ecosystem.

## Rust

### Criterion (Recommended)

Statistical benchmarking with automatic warmup, outlier detection, and comparison.

**Setup:**
```toml
# Cargo.toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "my_benchmark"
harness = false
```

**Basic benchmark:**
```rust
// benches/my_benchmark.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn fibonacci(n: u64) -> u64 {
    match n {
        0 => 1,
        1 => 1,
        n => fibonacci(n-1) + fibonacci(n-2),
    }
}

fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("fib 20", |b| b.iter(|| fibonacci(black_box(20))));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
```

**Run:** `cargo bench`

**Key features:**
- `black_box()` prevents dead code elimination
- Automatic warmup and iteration count
- Statistical analysis with confidence intervals
- HTML reports in `target/criterion/`
- Comparison against previous runs

### cargo bench (Built-in)

Simpler but less sophisticated. Requires nightly for `#[bench]` attribute.

```rust
#![feature(test)]
extern crate test;

#[bench]
fn bench_fib(b: &mut test::Bencher) {
    b.iter(|| fibonacci(test::black_box(20)));
}
```

## Python

### pytest-benchmark (Recommended)

Integrates with pytest, provides statistical analysis.

**Setup:**
```bash
pip install pytest-benchmark
```

**Basic benchmark:**
```python
# test_benchmark.py
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

def test_fib_benchmark(benchmark):
    result = benchmark(fibonacci, 20)
    assert result == 6765
```

**Run:** `pytest test_benchmark.py --benchmark-only`

**Useful options:**
- `--benchmark-compare` - Compare against saved results
- `--benchmark-save=NAME` - Save results for later comparison
- `--benchmark-warmup=on` - Enable warmup
- `--benchmark-min-rounds=10` - Minimum iterations

### timeit (Quick Measurements)

Built-in, good for quick checks.

```python
import timeit

# Time a statement
timeit.timeit('fibonacci(20)', globals=globals(), number=1000)

# From command line
# python -m timeit -s "from mymodule import func" "func()"
```

### cProfile (Profiling)

Find where time is spent, not just total time.

```python
import cProfile
import pstats

# Profile a function
cProfile.run('my_function()', 'output.prof')

# Analyze results
stats = pstats.Stats('output.prof')
stats.sort_stats('cumulative')
stats.print_stats(10)  # Top 10 functions
```

**Visualization:** Use `snakeviz` for interactive flame graphs:
```bash
pip install snakeviz
snakeviz output.prof
```

## JavaScript/TypeScript

### tinybench (Recommended)

Modern, lightweight, accurate.

**Setup:**
```bash
npm install tinybench
```

**Basic benchmark:**
```javascript
import { Bench } from 'tinybench';

const bench = new Bench({ time: 1000 });

bench
  .add('fibonacci iterative', () => {
    fibIterative(20);
  })
  .add('fibonacci recursive', () => {
    fibRecursive(20);
  });

await bench.warmup();
await bench.run();

console.table(bench.table());
```

### Benchmark.js (Alternative)

More mature, widely used.

```javascript
const Benchmark = require('benchmark');

const suite = new Benchmark.Suite;

suite
  .add('RegExp#test', () => /o/.test('Hello World!'))
  .add('String#indexOf', () => 'Hello World!'.indexOf('o') > -1)
  .on('cycle', (event) => console.log(String(event.target)))
  .on('complete', function() {
    console.log('Fastest is ' + this.filter('fastest').map('name'));
  })
  .run({ async: true });
```

### Node.js Built-in (Quick)

```javascript
console.time('operation');
// ... code to measure
console.timeEnd('operation');

// Or with performance API
const { performance } = require('perf_hooks');
const start = performance.now();
// ... code
const end = performance.now();
console.log(`Took ${end - start}ms`);
```

## Go

### testing.B (Built-in)

Go's standard benchmark framework.

**Basic benchmark:**
```go
// fib_test.go
package main

import "testing"

func BenchmarkFibonacci(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Fibonacci(20)
    }
}

func BenchmarkFibonacciParallel(b *testing.B) {
    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            Fibonacci(20)
        }
    })
}
```

**Run:** `go test -bench=. -benchmem`

**Useful flags:**
- `-benchtime=5s` - Run for 5 seconds
- `-benchmem` - Include memory allocations
- `-count=10` - Run 10 times for statistics
- `-cpu=1,2,4` - Test with different GOMAXPROCS

### benchstat (Analysis)

Compare benchmark results statistically.

```bash
go install golang.org/x/perf/cmd/benchstat@latest

# Run benchmarks multiple times
go test -bench=. -count=10 > old.txt
# Make changes
go test -bench=. -count=10 > new.txt

# Compare
benchstat old.txt new.txt
```

## Java

### JMH (Java Microbenchmark Harness)

The standard for JVM benchmarking.

**Setup (Maven):**
```xml
<dependency>
    <groupId>org.openjdk.jmh</groupId>
    <artifactId>jmh-core</artifactId>
    <version>1.37</version>
</dependency>
```

**Basic benchmark:**
```java
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@State(Scope.Thread)
public class MyBenchmark {

    @Benchmark
    public int testMethod() {
        return fibonacci(20);
    }
}
```

**Key annotations:**
- `@Warmup(iterations = 5)` - Warmup runs
- `@Measurement(iterations = 10)` - Measurement runs
- `@Fork(2)` - JVM forks to reduce variance
- `@BenchmarkMode` - Throughput, AverageTime, SampleTime

## Generic / CLI Tools

### hyperfine (Any Executable)

Excellent for benchmarking any command-line program.

**Install:**
```bash
# macOS
brew install hyperfine

# Linux
cargo install hyperfine
```

**Basic usage:**
```bash
# Simple benchmark
hyperfine 'sleep 0.3'

# Compare implementations
hyperfine 'python fib.py' 'node fib.js' 'cargo run --release'

# With warmup
hyperfine --warmup 3 'my-command'

# Export results
hyperfine --export-json results.json 'my-command'
```

**Useful options:**
- `--warmup N` - Run N warmup iterations
- `--min-runs N` - Minimum number of runs
- `--parameter-scan SIZE 1 10` - Vary a parameter
- `--prepare 'command'` - Run before each benchmark

### time (Quick Check)

Built into shells, useful for quick measurements.

```bash
# Simple timing
time my-command

# More detailed (GNU time)
/usr/bin/time -v my-command
```

## Instrumentation Techniques

When formal benchmarks aren't enough, add instrumentation:

### Timestamp Logging

```python
import time

def operation():
    t0 = time.perf_counter()
    step_one()
    t1 = time.perf_counter()
    print(f"Step 1: {(t1-t0)*1000:.2f}ms")

    step_two()
    t2 = time.perf_counter()
    print(f"Step 2: {(t2-t1)*1000:.2f}ms")

    step_three()
    t3 = time.perf_counter()
    print(f"Step 3: {(t3-t2)*1000:.2f}ms")
    print(f"Total: {(t3-t0)*1000:.2f}ms")
```

### Decorator-Based Timing

```python
import functools
import time

def timed(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__}: {elapsed*1000:.2f}ms")
        return result
    return wrapper

@timed
def my_function():
    # ...
```

### Span-Based Tracing

For complex operations, use tracing libraries:
- Python: `opentelemetry`, `structlog`
- JavaScript: `performance.mark/measure`
- Rust: `tracing` crate
