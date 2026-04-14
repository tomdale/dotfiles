# Refactoring Case Studies

## Contents

- Case study 1: React state god file
- Case study 2: API route monolith
- Case study 3: Published library internals

## Case Study 1: React State God File

### Problem

A single feature file owns state, reducer logic, fetch orchestration, selectors,
and component rendering.

```text
before/
  billing-dashboard.tsx
```

### Ideal Greenfield Tree

```text
after/
  billing-dashboard/
    types.ts
    state.ts
    reducer.ts
    selectors.ts
    effects.ts
    BillingDashboard.tsx
```

### Before

```ts
// billing-dashboard.tsx
type State = {
  isLoading: boolean;
  invoices: Array<{ id: string; totalCents: number; status: string }>;
  error?: string;
};

export function BillingDashboard() {
  const [state, setState] = useState<State>({
    isLoading: false,
    invoices: [],
  });

  async function load() {
    setState((current) => ({ ...current, isLoading: true }));
    try {
      const invoices = await fetchInvoices();
      setState({ isLoading: false, invoices });
    } catch {
      setState({ isLoading: false, invoices: [], error: "Failed" });
    }
  }

  const outstanding = state.invoices
    .filter((invoice) => invoice.status !== "paid")
    .reduce((sum, invoice) => sum + invoice.totalCents, 0);

  return <Dashboard state={state} outstanding={outstanding} onLoad={load} />;
}
```

### After

```ts
// billing-dashboard/types.ts
type Brand<T, Name extends string> = T & { readonly __brand: Name };

export type InvoiceId = Brand<string, "InvoiceId">;
export type InvoiceStatus = "draft" | "issued" | "paid" | "failed";

export type Invoice = Readonly<{
  id: InvoiceId;
  totalCents: number;
  status: InvoiceStatus;
}>;
```

```ts
// billing-dashboard/state.ts
import type { Invoice } from "./types";

export type BillingDashboardState =
  | { readonly status: "idle" }
  | { readonly status: "loading" }
  | { readonly status: "loaded"; readonly invoices: readonly Invoice[] }
  | { readonly status: "failed"; readonly message: string };
```

```ts
// billing-dashboard/selectors.ts
import type { BillingDashboardState } from "./state";

export function selectOutstandingTotal(
  state: BillingDashboardState,
): number {
  if (state.status !== "loaded") return 0;

  return state.invoices
    .filter((invoice) => invoice.status !== "paid")
    .reduce((sum, invoice) => sum + invoice.totalCents, 0);
}
```

```ts
// billing-dashboard/effects.ts
import type { BillingDashboardState } from "./state";
import type { Invoice } from "./types";

export type LoadInvoices = () => Promise<readonly Invoice[]>;

export async function loadBillingDashboard(
  loadInvoices: LoadInvoices,
): Promise<BillingDashboardState> {
  try {
    const invoices = await loadInvoices();
    return { status: "loaded", invoices };
  } catch {
    return { status: "failed", message: "Failed to load invoices" };
  }
}
```

### Why This Is Better

- The state machine is explicit.
- Selectors are pure and reusable.
- Effects are isolated from rendering.
- The component becomes assembly, not a god object.

## Case Study 2: API Route Monolith

### Problem

A route file mixes parsing, validation, auth, business rules, and response
formatting.

```text
before/
  api/create-project.ts
```

### Ideal Greenfield Tree

```text
after/
  api/create-project/
    route.ts
    schema.ts
    service.ts
    presenter.ts
    errors.ts
```

### Before

```ts
// create-project.ts
export async function post(request: Request): Promise<Response> {
  const body = await request.json();

  if (!body.name || typeof body.name !== "string") {
    return Response.json({ error: "invalid_name" }, { status: 400 });
  }

  const session = await requireSession(request);
  if (!session) {
    return Response.json({ error: "unauthorized" }, { status: 401 });
  }

  const project = await db.project.create({
    data: { name: body.name, ownerId: session.userId },
  });

  return Response.json({
    id: project.id,
    name: project.name,
    ownerId: project.ownerId,
  });
}
```

### After

```ts
// api/create-project/schema.ts
export type CreateProjectRequest = Readonly<{
  name: string;
}>;

export async function parseCreateProjectRequest(
  request: Request,
): Promise<CreateProjectRequest> {
  const body: unknown = await request.json();

  if (
    typeof body !== "object" ||
    body === null ||
    !("name" in body) ||
    typeof body.name !== "string"
  ) {
    throw new InvalidCreateProjectRequestError();
  }

  return { name: body.name };
}
```

```ts
// api/create-project/service.ts
type Brand<T, Name extends string> = T & { readonly __brand: Name };

export type ProjectId = Brand<string, "ProjectId">;
export type UserId = Brand<string, "UserId">;

export type Project = Readonly<{
  id: ProjectId;
  name: string;
  ownerId: UserId;
}>;

export async function createProject(
  input: CreateProjectRequest,
  ownerId: UserId,
): Promise<Project> {
  return db.project.create({
    data: { name: input.name, ownerId },
  }) as Promise<Project>;
}
```

```ts
// api/create-project/presenter.ts
export type CreateProjectResponse = Readonly<{
  id: ProjectId;
  name: string;
  ownerId: UserId;
}>;

export function presentCreateProject(
  project: Project,
): CreateProjectResponse {
  return {
    id: project.id,
    name: project.name,
    ownerId: project.ownerId,
  };
}
```

```ts
// api/create-project/route.ts
export async function post(request: Request): Promise<Response> {
  const input = await parseCreateProjectRequest(request);
  const session = await requireSession(request);
  const project = await createProject(input, session.userId as UserId);

  return Response.json(presentCreateProject(project));
}
```

### Why This Is Better

- The route is thin.
- Validation is reusable and testable.
- Service logic is explicit and transport-agnostic.
- Response shaping is isolated.
- External contract stays stable while internals are cleaned up.

## Case Study 3: Published Library Internals

### Problem

A library has one public `index.ts`, but internal implementation details are
mixed together in a broad client file. The public API must stay stable because
it is already published.

```text
before/
  src/
    index.ts
    client.ts
```

### Ideal Greenfield Tree

```text
after/
  src/
    index.ts
    public/
      client.ts
      events.ts
    internal/
      request.ts
      response.ts
      transport.ts
      parse-event.ts
```

### Before

```ts
// client.ts
export type Event = {
  type: string;
  payload: unknown;
};

export class Client {
  async send(path: string, body: unknown) {
    const response = await fetch(path, {
      method: "POST",
      body: JSON.stringify(body),
    });
    return response.json();
  }

  parseEvent(input: any): Event {
    return { type: input.type, payload: input.payload };
  }
}
```

### After

```ts
// public/events.ts
export type EventMap = {
  "job.queued": { readonly jobId: JobId };
  "job.completed": { readonly jobId: JobId; readonly durationMs: number };
};

export type Event =
  {
    [TName in keyof EventMap]: Readonly<{
      type: TName;
      payload: EventMap[TName];
    }>;
  }[keyof EventMap];
```

```ts
// internal/request.ts
export type RequestBody = Readonly<Record<string, unknown>>;

export async function postJson<TResponse>(
  path: string,
  body: RequestBody,
): Promise<TResponse> {
  const response = await fetch(path, {
    method: "POST",
    body: JSON.stringify(body),
  });

  return (await response.json()) as TResponse;
}
```

```ts
// internal/parse-event.ts
import type { Event, EventMap } from "../public/events";

export function parseEvent<TName extends keyof EventMap>(
  type: TName,
  payload: EventMap[TName],
): Event {
  return { type, payload };
}
```

```ts
// public/client.ts
import { postJson } from "../internal/request";
import type { Event } from "./events";

export class Client {
  async send<TResponse>(
    path: string,
    body: Readonly<Record<string, unknown>>,
  ): Promise<TResponse> {
    return postJson<TResponse>(path, body);
  }

  parseEvent(event: Event): Event {
    return event;
  }
}
```

### Compatibility Decision

- Preserve `Client` as the public entrypoint.
- Do not preserve `client.ts` as the home for every concern.
- Reorganize internals freely because callers should not depend on them.

### Why This Is Better

- Public API stability and internal cleanup are separated.
- Event typing becomes exact.
- Transport logic no longer dictates library structure.
- Internal modules gain clear ownership.
