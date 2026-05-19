---
name: documentation-comments
description: Write or review documentation comments for code. Use when adding JSDoc, module comments, inline comments, or API comments, especially when comments should explain architecture, invariants, durability, compatibility, security indirection, serialization constraints, prompt assembly, tool descriptions, or other intent that names and types cannot express.
---

# Documentation Comments

Use this skill to write comments that explain what code cannot say itself.

The core rule is: orient, then explain. Start by telling a new reader, in plain
English, what the thing is in runtime terms, what role it plays, or where it
sits in the architecture. After that, explain the invariant, constraint,
compatibility promise, dependency direction, or failure mode the code cannot
encode on its own. If the description is still abstract, add one short concrete
example.

## What To Document

Write comments when a future maintainer could make the wrong change without
the context:

- A module boundary exists for architectural reasons, not incidental file
  organization.
- Dependency direction matters.
- Durable workflow state, serialization, replay, or resume behavior constrains
  the implementation.
- Backward compatibility accepts an older shape, and callers or in-flight work
  may still depend on it.
- A strange encoding, placeholder, transport choice, or fake value is
  intentional.
- Security indirection hides the real credential, token, or policy from the
  visible code.
- A type property has short domain language that the name cannot carry by
  itself.
- Prompt or policy assembly needs an architectural explanation separate from
  the prompt text.
- Inline sequencing protects an invariant that is not obvious from control
  flow.

Do not write comments that only restate identifiers, signatures, or visible
control flow. If deleting a sentence loses no information beyond what names,
types, and code already say, delete it. Orientation counts as information;
line-by-line narration usually does not.

## Shape Of A Good Comment

Most JSDoc should be one to three sentences:

1. First sentence: concrete orientation in runtime terms.
2. Second sentence: why the boundary or implementation is shaped that way,
   often using "so" or "because".
3. Optional third sentence: a small example that makes an abstract policy
   visible.

Good:

```ts
/**
 * Maps each session surface to the agent capabilities and runtime modes it is allowed to expose.
 * For example, Slack and GitHub sessions enable the Done tool, while dashboard sessions can opt into plan mode.
 * Keeping this policy separate prevents turn execution from hard-coding channel behavior.
 */
```

Bad:

```ts
/** Chooses the model-facing runtime contract for a session surface. */
```

The bad version starts with internal vocabulary and forces the reader to decode
the architecture before they can picture the behavior.

## Syntax And Scope

Use comment syntax to make ownership obvious:

- `/** ... */` belongs only to the next declaration: a function, constant, type,
  class, or other symbol that follows immediately.
- `/* ... */` is for file-level or module-level rationale.
- Do not put an untagged JSDoc block at the top of a file when the intent is to
  document the module.
- If a symbol immediately follows a module comment and also needs
  documentation, give that symbol its own `/** ... */` block.

Avoid mechanical `@param`, `@returns`, `@example`, `@see`, and `@throws` tags.
TypeScript already describes ordinary parameters and returns. If a parameter
has surprising semantics, explain it as prose: "Pass undefined to skip the
cache," "must be a ULID, not a UUID," or "callers must supply the unredacted
command because redaction happens downstream."

## Common Patterns

Module boundary:

```ts
/*
 * Shared workflow event context types and parsing. This file stays free of
 * workflow runtime imports so durable workflow files and step modules can
 * depend on the same context shape without analyzer confusion.
 */
```

Durable state:

```ts
/**
 * Minimal workflow shell state needed to choose the next action after a turn step returns.
 * Everything here must be reconstructable on resume without re-reading step-local implementation details.
 */
```

Compatibility shim:

```ts
/**
 * Normalizes workflow event context into the current typed shape while still accepting older flat token fields.
 * In-flight workflows may resume after deploy, so this branch cannot disappear until those events age out.
 */
```

Intentional placeholder:

```ts
/**
 * Placeholder auth files satisfy CLIs' local credential checks.
 * The real token is injected later by network policy header transformation.
 */
```

Prompt assembly:

```ts
/**
 * Joins prompt fragments while dropping empty values so prompt assembly stays declarative.
 * The orchestration layer can add optional policy text without accumulating trim checks.
 */
```

Inline comments should clear local fog, not shadow every line:

```ts
// Persist the message before appending stream parts so resume logic never observes orphaned output.
await saveMessage(message);
```

## Tool Descriptions

`tool({ description: "..." })` strings and Zod `.describe()` text are
instructions for the model, not documentation for engineers. Write them as
imperative guidance to the AI. Do not duplicate that content in JSDoc unless
the human reader needs separate architectural context the model-facing
description does not provide.

## Style

Write in direct, present-tense, architectural prose. Prefer verbs like owns,
stays free of, avoids, normalizes, preserves, and isolates. Use comments to
protect invariants, dependency boundaries, compatibility promises, and
intentionally unusual choices. Keep comments current; stale comments are worse
than none.
