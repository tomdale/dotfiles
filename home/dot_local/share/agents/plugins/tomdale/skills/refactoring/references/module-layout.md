# Module Layout And Decomposition

## Contents

- Greenfield tree design
- App layout heuristics
- Library layout heuristics
- Naming guidance
- God-file decomposition
- File tree examples
- Export discipline

## Greenfield Tree Design

Before changing code, sketch the tree you would create from scratch for the
same feature set.

Useful design questions:

- Which modules are domain concepts?
- Which modules are boundaries to the outside world?
- Which files only exist because the current code grew awkwardly?
- Which names would I never choose in a new repo?

Prefer trees that separate:

- transport
- schema and parsing
- domain types and policies
- persistence or external clients
- orchestration
- presentation

## App Layout Heuristics

For applications, optimize internal clarity over internal API stability.

Good layout tendencies:

- organize by feature or domain, not by generic layer names alone
- keep route or entrypoint files thin
- colocate state, selectors, and commands when they describe one feature
- move cross-cutting adapters to clear boundary modules

Example:

```text
before/
  user-dashboard.ts

after/
  dashboard/
    route.ts
    schema.ts
    state.ts
    selectors.ts
    load-dashboard.ts
    present-dashboard.ts
```

## Library Layout Heuristics

For libraries, preserve the real public API and reorganize internals freely.

Good layout tendencies:

- keep `index.ts` or public entry modules small and explicit
- put internal implementation behind clearly internal paths
- separate domain model from environment-specific adapters
- avoid re-exporting the entire repo accidentally

Example:

```text
before/
  src/index.ts
  src/client.ts

after/
  src/index.ts
  src/public/
    client.ts
    events.ts
  src/internal/
    request.ts
    response.ts
    transport.ts
    parse-event.ts
```

## Naming Guidance

Prefer names that tell the reader what role the file plays.

Good:

- `schema.ts`
- `parse-session.ts`
- `session-types.ts`
- `load-account.ts`
- `present-order.ts`
- `event-map.ts`
- `repository.ts`
- `adapter.ts`

Weak:

- `utils.ts`
- `helpers.ts`
- `common.ts`
- `service.ts` when there are multiple unrelated services
- `types.ts` when it contains half the runtime logic too

If a name is vague, the ownership is probably vague too.

## God-File Decomposition

When a file is monolithic, split by responsibility, not by arbitrary function
count.

Common decomposition slices:

- domain types
- validation or parsing
- pure derivation helpers
- orchestration
- side-effectful adapters
- view or response shaping

Questions to ask:

- Which parts can be pure?
- Which parts depend on I/O?
- Which parts define invariants?
- Which parts are merely assembly?

If a file answers all of those at once, it is almost certainly too broad.

## File Tree Examples

### API route monolith

```text
before/
  api/
    create-invoice.ts

after/
  api/
    create-invoice/
      route.ts
      schema.ts
      service.ts
      presenter.ts
      errors.ts
```

### Reducer and effects blob

```text
before/
  checkout-model.ts

after/
  checkout/
    state.ts
    events.ts
    reducer.ts
    selectors.ts
    effects.ts
```

### Utility pile

```text
before/
  utils.ts

after/
  currency/
    format-money.ts
    parse-money.ts
  cart/
    calculate-totals.ts
  dates/
    format-relative-date.ts
```

### Library implementation sprawl

```text
before/
  sdk.ts

after/
  public/
    index.ts
    client.ts
  internal/
    request.ts
    response.ts
    auth-header.ts
    parse-rate-limit.ts
```

## Export Discipline

Do not let the export surface drift into architecture.

- Keep public exports deliberate.
- Avoid barrel files that re-export unstable internals by default.
- Re-export only what matches the intended API surface.
- If internal callers need broad access, prefer local imports over growing the
  public surface.

In app code, internal path churn is acceptable if it leads to a better design.
In libraries, stable public exports matter, but internal module churn does not.
