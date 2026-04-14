# Refactoring Conceptual Model

## Contents

- Behavior before aesthetics
- Greenfield first, retrofit second
- Compatibility is evidence-based
- Types are part of the architecture
- Prefer seams over piles
- When to split a file
- When not to split a file
- Smell to action guide

## Behavior Before Aesthetics

Refactoring is structural improvement under stable behavior. Formatting,
renaming, and helper extraction are not enough if the system still has poor
boundaries and weak invariants.

Work from these questions:

1. What must continue to work exactly as before?
2. What inputs and outputs are externally observable?
3. Which parts are currently coupled for accidental reasons?
4. Which invariants belong in the type system rather than in comments or
   conventions?

## Greenfield First, Retrofit Second

Agent-powered refactors often get trapped in the current architecture. Counter
that by requiring an explicit greenfield pass first.

The pass should produce:

- the ideal folder and file tree
- the ownership of each module
- a list of modules that should vanish
- the clean names you would choose without legacy baggage

Then retrofit toward that target.

This prevents local optimization of bad architecture. It also makes it easier
to spot when the current layout is forcing unrelated responsibilities into one
place.

## Compatibility Is Evidence-Based

Preserve compatibility only when there is evidence that someone depends on it.

Good evidence:

- a shipped route or API payload
- a persisted format
- a published library export
- a CLI command already in use
- code already merged to `main` and versioned or deployed

Weak evidence:

- “this file imports that file today”
- “this function is exported so maybe it is public”
- “this branch has had this shape for a while”

Default rule:

- preserve external contracts
- discard accidental internal structure

For libraries, use git history, tags, and release points to determine what
actually shipped. If a compatibility shim only preserves an unshipped or
internal shape, it is usually noise.

## Types Are Part Of The Architecture

In TypeScript, architecture lives partly in the type system.

Good refactors usually tighten one or more of these:

- state representation
- boundary validation
- identifier discipline
- event naming
- configuration shape
- mapping between transport and domain layers

Type-driven refactoring patterns:

- boolean flags -> discriminated unions
- open string keys -> finite exact maps
- plain IDs -> branded IDs
- nullable state -> explicit `pending | ready | failed` unions
- dynamic payload conventions -> typed event maps
- giant structural objects -> smaller named domain types

## Prefer Seams Over Piles

Healthy modules compose through explicit seams.

Typical seam types:

- schema / parser / validated input
- domain types / domain service
- repository or external client
- presentation or response shaping
- orchestration that wires the parts together

When these are mixed into a single file, the file becomes a god object even if
the functions are individually short.

## When To Split A File

Split when a file has more than one reason to change.

Common triggers:

- runtime logic and type declarations evolve for different reasons
- parsing rules change independently of business decisions
- API response formatting changes independently of data fetching
- view helpers change independently of effects or state transitions
- a module exports many unrelated names to support unrelated callers

Use cohesion, not line count alone. A 60-line file can still be a god object if
it mixes transport, validation, and policy.

## When Not To Split A File

Do not split purely to create ceremony.

Keep a file intact when:

- it owns one narrow concept end to end
- the responsibilities truly change together
- splitting would create indirection without clarifying boundaries
- the file is small and already strongly typed with a coherent API

The goal is focused composition, not maximal file count.

## Smell To Action Guide

### Boolean control matrix

Smell:

```ts
type Job = {
  isRunning: boolean;
  hasError: boolean;
  isStale: boolean;
};
```

Action:

- model the state machine explicitly with a discriminated union
- move state-specific logic next to that union

### Stringly identifiers

Smell:

```ts
type Session = { id: string; userId: string };
```

Action:

- introduce branded IDs
- keep transport-to-domain conversion at the boundary

### Giant options bag

Smell:

- one function accepts a wide object with loosely related optional fields

Action:

- split command types by mode
- use discriminants or distinct functions
- make illegal combinations unrepresentable

### Route or handler blob

Smell:

- request parsing, auth, domain logic, and response formatting live together

Action:

- separate schema, handler, service, and presenter modules
- keep the route thin

### React state god file

Smell:

- component contains data fetching, state normalization, reducers, effects, and
  rendering helpers

Action:

- split state model, actions, selectors, effects, and presentational helpers
- keep component assembly thin

### Utility junk drawer

Smell:

- `utils.ts` holds unrelated behavior that share no domain concept

Action:

- move helpers to the modules that own the concept
- or create a small focused module with a precise name

## Sequencing Strategy

Good order for substantial refactors:

1. Write the greenfield target tree.
2. Identify contract boundaries that must remain stable.
3. Extract pure types and invariants first.
4. Split boundary code from core logic.
5. Split large orchestrators into composed modules.
6. Rename files and exports to match the target architecture.
7. Remove temporary shims that no longer earn their keep.

If a refactor starts with local helper extraction but never revisits the module
layout, it is probably under-scoped.
