---
name: abstraction-boundaries
description: Identify places where APIs, helper functions, and module boundaries operate at the wrong level of abstraction, then refactor them into a cleaner shape. Use when the user asks to make function signatures more honest, expose hidden setup or conversion work, remove repeated preparation steps, or separate orchestration from lower-level operational logic.
---

# Abstraction Boundaries

Use this skill when the code works, but the design is lying about where the
real work happens.

The target is not generic cleanup. The target is to move each piece of logic to
the abstraction level where it actually belongs, then make that boundary
obvious in signatures, module layout, and names.

## Focus Questions

1. Are function signatures honest?
   If a helper accepts one shape but immediately performs conversion, lookup,
   initialization, or another boundary-crossing step before its real work,
   consider whether it should accept the post-conversion value directly.

2. Are responsibilities split cleanly?
   Separate orchestration, state management, persistence, coordination, and
   low-level operational logic when they are mixed in the same file or module.

3. Is important work hidden inside convenience helpers?
   Make expensive or architecturally meaningful work explicit at the right
   boundary unless there is a strong reason to hide it.

4. Is the same setup or conversion repeated within a single flow?
   When one request or execution path prepares the same value multiple times,
   perform that step once at the boundary and pass the prepared value through.

5. Are module boundaries aligned with what the code fundamentally does?
   Keep low-level operational code near the domain it manipulates. Keep
   coordination and orchestration in higher-level modules.

6. Are names revealing the abstraction level?
   Rename functions so boundary-level orchestration and lower-level operations
   are clearly distinguished. Do not let one name cover multiple levels of
   behavior.

## Workflow

1. Inspect the relevant call sites before editing.
2. Quantify the pattern:
   - how many times it occurs
   - whether it sits on a hot or central flow
   - whether the main problem is readability, hidden work, duplication, or
     runtime overhead
3. Propose the smallest coherent abstraction split that fixes the design.
4. Refactor the boundary, not just one call site.
5. Prefer removing hidden behavior over adding a blurrier “flexible” API.
6. Avoid thin wrappers unless they materially improve clarity.
7. If two layers remain necessary, make the boundary explicit in both naming
   and module placement.

## Design Rules

- Move setup, conversion, and lookup work outward toward the boundary that owns
  it.
- Pass prepared values inward explicitly.
- Do not let convenience files become grab-bags for mixed abstraction levels.
- Treat repeated preparation inside one flow as a design smell.
- Preserve real external contracts, but do not preserve internal convenience
  APIs just because they already exist.

## Output Expectations

Explain:

- the abstraction problem in concrete terms
- the boundary you introduced or clarified
- what now belongs to the higher-level orchestration layer
- what now belongs to the lower-level operational layer
- which cases you intentionally left alone and why

Prioritize architectural clarity over cleverness or local convenience.
