---
name: refactoring
description: Refactor TypeScript codebases aggressively. Use when the user asks to refactor, clean up, extract, decompose monolithic files, improve module layout, redesign naming, preserve behavior while improving structure, or make a TypeScript codebase look like it was designed well from scratch.
---

# Refactoring

Use this skill for structural TypeScript refactors, especially when the current
module layout is anchoring the work too much.

The goal is not “make the code nicer in place.” The goal is to identify the
best greenfield design for the same functionality, then retrofit the current
repo toward that target while preserving only the compatibility surfaces that
actually matter.

## Core Model

- Preserve behavior first.
- Preserve compatibility only where it is real, external, and shipped.
- Treat current file boundaries as suspect, not sacred.
- Prefer explicit domain models over control flow encoded in booleans,
  nullable fields, or stringly conventions.
- Decompose large mixed-responsibility files into smaller modules that compose
  cleanly.
- Tighten TypeScript types as part of the refactor rather than as a cosmetic
  cleanup at the end.

## Refactor Workflow

1. Identify the behavior that must remain stable.
2. Identify the actual compatibility boundary.
3. State the ideal greenfield layout explicitly before editing.
4. Compare the current layout against that target and name the structural
   mismatches.
5. Refactor toward the target architecture, not merely within the current
   files.
6. Split monolithic files by responsibility.
7. Tighten the type model after each structural step.
8. Re-verify behavior, exports, and boundary contracts after each stage.

## Greenfield-First Pass

Before making non-trivial edits, write down:

- The ideal file tree if this repo were created today
- The ownership of each file or module
- Which current files should disappear entirely
- Which names would change in a clean design
- Which seams should exist between parsing, validation, domain logic,
  orchestration, I/O, rendering, and transport

Do not skip this step because the current layout feels “good enough.”

## Compatibility Triage

Do not preserve compatibility blindly.

Preserve real external contracts such as:

- HTTP or JSON API routes and payloads
- persisted storage formats
- database schema expectations
- published library APIs
- CLI interfaces already in user hands

Usually do not preserve these just because they already exist:

- app-internal import paths
- internal service/module entrypoints
- ad hoc helper names
- file layout that has never shipped

Decide based on context:

- If the work is unmerged or unshipped, optimize for the best architecture now.
- If this is a user-facing application, internal module compatibility rarely
  matters.
- If this is a published library, determine what has actually shipped before
  adding shims.
- If an interface only exists on a feature branch, treat it as disposable.

## Module Decomposition Rules

Treat “god object” files as a primary smell.

Split aggressively when one file mixes:

- type definitions and runtime behavior
- transport and domain logic
- parsing and orchestration
- state modeling and side effects
- rendering and data fetching
- unrelated utility functions that only cohabit for convenience

After refactoring, every large file should be either:

- decomposed into smaller cohesive modules, or
- explicitly justified as the correct single unit

If a large file remains, be able to explain why it still has one clear reason
to change.

## TypeScript Quality Bar

All refactors and examples should use strong production-quality TypeScript.

- Use advanced types when they improve the design, not to show off.
- Prefer discriminated unions over boolean flag matrices.
- Prefer branded identifiers over plain `string` or `number` IDs.
- Prefer explicit boundary types over giant implicit object shapes.
- Use `satisfies`, template-literal types, mapped types, conditional types,
  generic constraints, readonly boundaries, and exhaustive `never` checks when
  they materially improve safety or maintainability.
- Avoid `any` and avoid “after” snippets that are only cosmetically cleaner.

## Naming Rules

Name files for their role, not for vague reuse:

- `schema`
- `parser`
- `types`
- `state`
- `events`
- `service`
- `repository`
- `adapter`
- `client`
- `presenter`
- `selectors`
- `commands`

Be skeptical of:

- `utils.ts`
- `helpers.ts`
- `misc.ts`
- `common.ts`
- giant `index.ts` files doing real work

## Review Questions

Before finishing, check:

- Did I describe the ideal greenfield layout first?
- Did I preserve only the compatibility boundaries that matter?
- Did I remove anchoring to the current file layout?
- Did I split monolithic files by responsibility?
- Did I improve the type model, not just the formatting?
- Would a strong TypeScript codebase choose these file names and module seams
  if written from scratch?

## References

Load these as needed:

- `references/conceptual-model.md`: refactor philosophy, sequencing, and
  compatibility triage
- `references/module-layout.md`: file decomposition heuristics, naming, and
  greenfield tree design
- `references/pattern-catalog.md`: many concise TypeScript before/after
  examples
- `references/case-studies.md`: longer end-to-end decomposition examples with
  file trees
