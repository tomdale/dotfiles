---
name: cruft
description: Audit a codebase for low-value compatibility code, stale defensive layers, narrow adapter shims, metadata rewrites, and “just-in-case” glue that may no longer have a real consumer. Use when the user wants to simplify compatibility layers, trace whether wrappers are still needed, remove the smallest safe shim first, and distinguish real product contracts from tests that only codify the shim itself.
---

# Cruft

Use this skill when the codebase feels padded with compatibility logic that may
have outlived the thing it was protecting.

The target is not broad cleanup. The target is to identify behavior that exists
only to preserve an old shape, optional metadata, defensive normalization, or a
wrapper contract that no longer has a real production consumer.

## What To Hunt For

Look for narrow layers such as:

- adapter or bridge modules with little domain logic
- normalization helpers that rewrite input into another nearby shape
- metadata mappers or pass-through transforms
- wrapper functions that only rename arguments or forward calls
- compatibility shims preserving legacy options, aliases, or payload fields
- defensive “accept anything” glue around already-strict libraries

## Workflow

1. Find the smallest suspicious layer first.
2. Trace who consumes the behavior today.
3. Separate real production consumers from tests that only encode the shim.
4. Check the underlying library or framework contract.
5. Form a falsifiable hypothesis about whether the code is still necessary.
6. Remove the smallest candidate instead of rewriting the whole area.
7. Run the narrowest relevant tests:
   - the closest unit tests
   - at least one higher-level flow that would fail if the behavior were truly
     required
8. Classify failures:
   - real product contract break
   - test that only asserted the removed implementation detail
9. If only implementation-detail tests fail, update or delete those tests and
   keep the simplification.

## Consumer Triage

For each candidate, answer explicitly:

- Which production call sites depend on this behavior?
- Which tests only exercise the shim in isolation?
- Is the behavior required by a documented external contract?
- Is it merely convenience, metadata preservation, or historical flexibility?

Do not treat test coverage as proof of a real consumer. Many tests only
memorialize a compatibility layer after its original reason disappeared.

## Removal Rules

- Prefer deleting a wrapper over preserving it “just in case.”
- Preserve real external contracts, not internal folklore.
- If the underlying library already accepts the current direct input shape, the
  normalization layer is suspect.
- If metadata is rewritten but no downstream consumer reads the rewritten form,
  remove it.
- If a fallback branch exists only for hypothetical callers, delete it unless a
  current shipped path still uses it.
- Keep the first removal narrow enough that a failing higher-level test would be
  meaningful.

## Failure Classification

Treat failures differently depending on what they prove.

A real break means:

- a production flow no longer works
- a documented public contract changed unintentionally
- the underlying dependency truly required the removed behavior

An implementation-detail failure means:

- only unit tests around the shim failed
- the failing assertion described the old wrapper behavior rather than a user
  outcome
- the higher-level flow still works without the removed code

Do not restore dead code just to satisfy tests that were only testing the dead
code.

## Output Expectations

Summarize:

- what was removed
- which real behavior was verified unchanged
- which tests were updated or deleted because they only asserted the shim
- any remaining suspicious compatibility cruft worth auditing next
