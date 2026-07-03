# Statistical Concepts for Benchmarking

Practical statistics for making informed performance decisions without getting stuck on perfection.

## Core Metrics

### Central Tendency

**Mean (Average):**
- Sum of all values divided by count
- Sensitive to outliers
- Use when distribution is roughly symmetric

**Median:**
- Middle value when sorted
- Robust to outliers
- **Prefer for benchmark results** - more representative of typical performance

**Mode:**
- Most frequent value
- Rarely useful for benchmarks (continuous data)

### Variability

**Standard Deviation (σ):**
- How spread out values are from the mean
- Low σ = consistent performance
- High σ = variable performance (investigate why)

**Coefficient of Variation (CV):**
- Standard deviation divided by mean (σ/μ)
- Expressed as percentage
- Allows comparing variability across different scales
- CV < 5% = very consistent, CV > 20% = high variability

**Interquartile Range (IQR):**
- Range between 25th and 75th percentiles
- Robust to outliers
- IQR / median gives relative spread

### Percentiles

**Common percentiles for benchmarks:**
- **p50 (median):** Typical case
- **p95:** Most users' experience
- **p99:** Tail latency
- **p99.9:** Worst case (SLA-relevant)

For latency-sensitive systems, p99 often matters more than mean.

## Practical Decision Making

### Is This Improvement Real?

**Quick heuristic (use this):**

| Observed Difference | Variability (CV) | Verdict |
|---------------------|------------------|---------|
| >10% | <10% | Likely real improvement |
| >10% | >10% | Probably real, run more iterations |
| 5-10% | <5% | Possibly real, worth investigating |
| 5-10% | >10% | Probably noise |
| <5% | any | Likely noise |

**When uncertain:** Run more iterations rather than debating. 100 iterations with clear separation beats 10 iterations with statistics.

### Sample Size Guidelines

**Minimum runs by context:**
- Quick check: 10 runs
- Meaningful comparison: 30 runs
- Publication/decision: 100+ runs

**Diminishing returns:** Beyond 100 runs, you're unlikely to learn more. If results are still unclear, the difference probably doesn't matter.

### Warmup

**Why warmup matters:**
- JIT compilation (JVM, V8, etc.)
- CPU cache warming
- Memory allocation patterns
- OS scheduling settling

**How much warmup:**
- JVM/JavaScript: 5-10 iterations minimum
- Native code: 1-3 iterations usually sufficient
- If first run is >20% different from later runs, increase warmup

## Outlier Handling

### Identifying Outliers

**IQR method:**
- Calculate Q1 (25th percentile) and Q3 (75th percentile)
- IQR = Q3 - Q1
- Outliers: values < Q1 - 1.5×IQR or > Q3 + 1.5×IQR

**Z-score method:**
- Calculate mean and standard deviation
- Z-score = (value - mean) / σ
- Outliers: |Z| > 3

### What To Do With Outliers

1. **Investigate first** - Outliers may indicate real issues:
   - GC pauses
   - System interference
   - Thermal throttling
   - Resource contention

2. **Report both** - Show results with and without outliers

3. **Don't blindly remove** - If outliers are consistent, they're part of real performance

4. **Use robust statistics** - Median and IQR naturally handle outliers

## Comparing Two Implementations

### Visual Check

Plot both distributions. If they clearly don't overlap, the difference is real.

### Practical Approach

1. Run both implementations N times (N ≥ 30)
2. Compare medians
3. Check if distributions overlap

**No overlap:** Clear winner
**Some overlap:** Difference may not be meaningful in practice
**Significant overlap:** Probably equivalent

### Statistical Tests (When Needed)

**Mann-Whitney U test:**
- Non-parametric (doesn't assume normal distribution)
- Compares whether one distribution tends to be larger
- p < 0.05 suggests significant difference

**t-test:**
- Assumes roughly normal distributions
- Compares means
- Use Welch's t-test (doesn't assume equal variance)

**Effect size (Cohen's d):**
- How big is the difference in practical terms?
- |d| < 0.2: negligible
- |d| 0.2-0.5: small
- |d| 0.5-0.8: medium
- |d| > 0.8: large

A statistically significant but small effect size may not be worth the complexity.

## Confidence Intervals

### What They Mean

A 95% confidence interval means: if we repeated this experiment many times, 95% of the intervals would contain the true value.

**Practical interpretation:**
- Narrow CI = precise measurement
- Wide CI = uncertain, need more data
- Non-overlapping CIs = likely real difference

### Calculating (Simplified)

For large samples (N > 30):
```
CI = mean ± 1.96 × (σ / √N)
```

Most benchmark tools calculate this automatically.

## Regression Detection

### Detecting Performance Regressions

Compare current results against baseline:

1. **Establish baseline:** Run benchmark 50-100 times, save results
2. **Set threshold:** Typically 5-10% degradation triggers alert
3. **Statistical comparison:** Is current median significantly worse than baseline?

### Practical Thresholds

| Context | Alert Threshold |
|---------|-----------------|
| Hot path | >5% regression |
| Normal code | >10% regression |
| Cold path | >20% regression |

### Avoiding False Positives

- Run enough iterations (50+)
- Use same hardware/environment
- Account for system noise
- Consider time-of-day effects
- Use relative comparisons (A/B) not absolute times

## Best-Effort Philosophy

**Don't let statistics block progress:**

1. **Make a decision** - Even imperfect data beats no data
2. **Be honest about uncertainty** - "Probably 15-20% faster" is fine
3. **Iterate** - Optimize, measure, adjust
4. **Focus on big wins** - 2x improvements are obvious, 5% improvements may not matter

**When statistics matter more:**
- Customer-facing SLAs
- Regression detection in CI
- Comparing fundamentally different approaches
- Publishing results

**When to trust your gut:**
- Exploratory optimization
- Clear visual separation
- >50% improvements
- Internal development iteration
