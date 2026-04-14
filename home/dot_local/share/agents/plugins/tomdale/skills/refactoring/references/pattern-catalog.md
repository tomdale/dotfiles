# TypeScript Refactoring Pattern Catalog

## Contents

- State and control flow
- Domain and identifiers
- APIs and configuration
- Events and maps
- Boundaries and validation
- Composition and layout

Every example is TypeScript-only and uses original code.

## State And Control Flow

### 1. Boolean flags to explicit request state

Problem: impossible states are representable.

```ts
// before
type LoadUserState = {
  isLoading: boolean;
  hasLoaded: boolean;
  error?: string;
  user?: { id: string; email: string };
};
```

```ts
// after
type UserId = string & { readonly __brand: "UserId" };

type User = Readonly<{
  id: UserId;
  email: string;
}>;

type LoadUserState =
  | { readonly status: "idle" }
  | { readonly status: "loading" }
  | { readonly status: "loaded"; readonly user: User }
  | { readonly status: "failed"; readonly message: string };
```

Why better: invalid combinations disappear. TypeScript feature: discriminated
union with branded IDs.

### 2. Nullable branch soup to exact result type

Problem: null means too many things.

```ts
// before
async function findTeam(slug: string): Promise<Team | null> {
  const raw = await db.lookup(slug);
  return raw ?? null;
}
```

```ts
// after
type LookupResult<T> =
  | { readonly kind: "found"; readonly value: T }
  | { readonly kind: "missing" };

async function findTeam(slug: TeamSlug): Promise<LookupResult<Team>> {
  const raw = await db.lookup(slug);
  return raw
    ? { kind: "found", value: raw }
    : { kind: "missing" };
}
```

Why better: caller control flow becomes explicit. TypeScript feature:
discriminated result union.

### 3. String mode switch to command union

Problem: behavior depends on loosely related optional fields.

```ts
// before
type SaveInput = {
  mode: "draft" | "publish";
  publishAt?: string;
  notifyFollowers?: boolean;
};
```

```ts
// after
type ISODateTime = string & { readonly __brand: "ISODateTime" };

type SaveInput =
  | { readonly mode: "draft" }
  | {
      readonly mode: "publish";
      readonly publishAt: ISODateTime;
      readonly notifyFollowers: boolean;
    };
```

Why better: mode-specific requirements are encoded in the type. TypeScript
feature: discriminated union.

## Domain And Identifiers

### 4. Plain string IDs to branded domain IDs

Problem: unrelated identifiers can be mixed accidentally.

```ts
// before
type Payment = { id: string; accountId: string };
```

```ts
// after
type Brand<T, Name extends string> = T & { readonly __brand: Name };

type PaymentId = Brand<string, "PaymentId">;
type AccountId = Brand<string, "AccountId">;

type Payment = Readonly<{
  id: PaymentId;
  accountId: AccountId;
}>;
```

Why better: cross-domain mixups become type errors. TypeScript feature: branded
types.

### 5. Open record to exact map with `satisfies`

Problem: keys drift without review.

```ts
// before
const statusToTone: Record<string, string> = {
  pending: "gray",
  failed: "red",
  paid: "green",
};
```

```ts
// after
type InvoiceStatus = "pending" | "failed" | "paid";

const statusToTone = {
  pending: "gray",
  failed: "red",
  paid: "green",
} satisfies Record<InvoiceStatus, "gray" | "red" | "green">;
```

Why better: missing or extra keys are caught immediately. TypeScript feature:
`satisfies`.

### 6. Giant model to transport/domain split

Problem: one type tries to model API and business logic simultaneously.

```ts
// before
type Order = {
  id: string;
  total_cents: number;
  customer_email: string;
};
```

```ts
// after
type OrderId = string & { readonly __brand: "OrderId" };

type OrderDto = Readonly<{
  id: string;
  total_cents: number;
  customer_email: string;
}>;

type Order = Readonly<{
  id: OrderId;
  totalCents: number;
  customerEmail: string;
}>;
```

Why better: boundary translation becomes explicit. TypeScript feature: distinct
transport and domain types.

## APIs And Configuration

### 7. Overload sprawl to exact parameter object

Problem: too many call signatures hide the actual API shape.

```ts
// before
function openReport(id: string): Promise<void>;
function openReport(id: string, preview: boolean): Promise<void>;
function openReport(id: string, preview?: boolean) {
  return run(id, preview ?? false);
}
```

```ts
// after
type OpenReportInput = Readonly<{
  reportId: ReportId;
  mode?: "preview" | "full";
}>;

function openReport({
  reportId,
  mode = "full",
}: OpenReportInput): Promise<void> {
  return run(reportId, mode === "preview");
}
```

Why better: the API is readable and extensible. TypeScript feature: exact
parameter object.

### 8. Wide options bag to mode-specific config

Problem: unrelated flags create invalid combinations.

```ts
// before
type QueryOptions = {
  cache?: boolean;
  revalidateSeconds?: number;
  bypassAuth?: boolean;
  serviceToken?: string;
};
```

```ts
// after
type QueryOptions =
  | {
      readonly auth: "session";
      readonly cache: "default" | "no-store";
    }
  | {
      readonly auth: "service";
      readonly serviceToken: ServiceToken;
      readonly cache: "default" | "revalidate";
      readonly revalidateSeconds: number;
    };
```

Why better: invalid combinations are eliminated. TypeScript feature:
discriminated config union.

### 9. Implicit return shape to generic envelope

Problem: response metadata is copied ad hoc across functions.

```ts
// before
type LoadProjectsResult = {
  projects: Project[];
  nextCursor?: string;
};
```

```ts
// after
type Cursor = string & { readonly __brand: "Cursor" };

type Page<TItem> = Readonly<{
  items: readonly TItem[];
  nextCursor?: Cursor;
}>;

type LoadProjectsResult = Page<Project>;
```

Why better: pagination semantics become reusable and consistent. TypeScript
feature: generic reusable envelope.

## Events And Maps

### 10. String event names to template-literal event map

Problem: event names and payloads drift apart.

```ts
// before
function emit(event: string, payload: unknown) {
  bus.emit(event, payload);
}
```

```ts
// after
type Domain = "invoice" | "account";
type Action = "created" | "updated";
type EventName = `${Domain}.${Action}`;

type EventPayloadMap = {
  "invoice.created": { readonly invoiceId: InvoiceId };
  "invoice.updated": { readonly invoiceId: InvoiceId };
  "account.created": { readonly accountId: AccountId };
  "account.updated": { readonly accountId: AccountId };
};

function emit<TName extends keyof EventPayloadMap>(
  event: TName,
  payload: EventPayloadMap[TName],
): void {
  bus.emit(event, payload);
}
```

Why better: event names and payloads stay in sync. TypeScript feature:
template-literal types plus indexed access.

### 11. Repeated switch logic to typed handler table

Problem: logic duplicates across many branches.

```ts
// before
function renderStatus(status: InvoiceStatus): string {
  switch (status) {
    case "pending":
      return "Pending";
    case "paid":
      return "Paid";
    case "failed":
      return "Failed";
  }
}
```

```ts
// after
type InvoiceStatus = "pending" | "paid" | "failed";

const statusLabel = {
  pending: "Pending",
  paid: "Paid",
  failed: "Failed",
} satisfies Record<InvoiceStatus, string>;

function renderStatus(status: InvoiceStatus): string {
  return statusLabel[status];
}
```

Why better: one exact map replaces duplicated branching. TypeScript feature:
`satisfies` with exact keyed table.

### 12. Non-exhaustive reducer to `never`-checked handling

Problem: new events can silently fall through.

```ts
// before
function reduce(state: State, event: Event): State {
  switch (event.type) {
    case "loaded":
      return { ...state, data: event.data };
    default:
      return state;
  }
}
```

```ts
// after
function assertNever(value: never): never {
  throw new Error(`Unhandled event: ${JSON.stringify(value)}`);
}

function reduce(state: State, event: Event): State {
  switch (event.type) {
    case "loaded":
      return { ...state, data: event.data };
    case "failed":
      return { ...state, error: event.message };
    default:
      return assertNever(event);
  }
}
```

Why better: adding a new event forces the reducer to acknowledge it.
TypeScript feature: exhaustive `never` checking.

## Boundaries And Validation

### 13. `unknown` everywhere to reusable parser

Problem: every caller hand-rolls validation.

```ts
// before
function readFeatureFlag(input: unknown): boolean {
  if (typeof input === "object" && input && "enabled" in input) {
    return Boolean((input as any).enabled);
  }
  return false;
}
```

```ts
// after
type FeatureFlag = Readonly<{
  enabled: boolean;
}>;

function isFeatureFlag(input: unknown): input is FeatureFlag {
  return (
    typeof input === "object" &&
    input !== null &&
    "enabled" in input &&
    typeof input.enabled === "boolean"
  );
}

function readFeatureFlag(input: unknown): FeatureFlag | null {
  return isFeatureFlag(input) ? input : null;
}
```

Why better: the boundary logic becomes reusable and typed. TypeScript feature:
user-defined type guard.

### 14. Ad hoc DTO conversion to mapped transformer

Problem: repeated property mapping drifts.

```ts
// before
function normalizeUser(dto: UserDto) {
  return {
    id: dto.id,
    firstName: dto.first_name,
    lastName: dto.last_name,
  };
}
```

```ts
// after
type UserDto = Readonly<{
  id: string;
  first_name: string;
  last_name: string;
}>;

type User = Readonly<{
  id: UserId;
  firstName: string;
  lastName: string;
}>;

function normalizeUser(dto: UserDto): User {
  return {
    id: dto.id as UserId,
    firstName: dto.first_name,
    lastName: dto.last_name,
  };
}
```

Why better: boundary conversion is explicit and isolated. TypeScript feature:
named DTO and domain types.

### 15. Mutable arrays to readonly input boundary

Problem: callers and callee can mutate shared data unexpectedly.

```ts
// before
function sortProjects(projects: Project[]) {
  return projects.sort((a, b) => a.name.localeCompare(b.name));
}
```

```ts
// after
function sortProjects(projects: readonly Project[]): readonly Project[] {
  return [...projects].sort((a, b) => a.name.localeCompare(b.name));
}
```

Why better: mutation becomes explicit instead of accidental. TypeScript feature:
readonly array boundaries.

## Composition And Layout

### 16. Route blob to thin entrypoint plus service

Problem: route file owns schema, auth, policy, and response formatting.

```ts
// before
export async function post(req: Request): Promise<Response> {
  const body = await req.json();
  if (!body.email) return badRequest();
  const user = await createUser(body.email);
  return Response.json({ id: user.id, email: user.email });
}
```

```ts
// after
type CreateUserRequest = Readonly<{ email: string }>;
type CreateUserResponse = Readonly<{ id: UserId; email: string }>;

export async function post(req: Request): Promise<Response> {
  const input = await parseCreateUserRequest(req);
  const user = await createUser(input);
  return Response.json(presentCreateUser(user));
}
```

Why better: the route becomes assembly; parsing and presentation move to focused
modules. TypeScript feature: explicit boundary request/response types.

### 17. Generic `utils.ts` to focused modules

Problem: unrelated helpers live together because they are “useful.”

```ts
// before
// utils.ts
export function formatMoney(...) {}
export function buildAvatarUrl(...) {}
export function clamp(...) {}
```

```ts
// after
// money/format-money.ts
export function formatMoney(amount: number, currency: CurrencyCode): string {}

// avatar/build-avatar-url.ts
export function buildAvatarUrl(userId: UserId): URL {}

// math/clamp.ts
export function clamp(value: number, range: NumberRange): number {}
```

Why better: ownership becomes explicit and the file tree reflects the domain.
TypeScript feature: domain-specific parameter types instead of generic
primitives.

### 18. One giant React model file to state/selectors/effects split

Problem: one module knows the entire feature.

```ts
// before
// billing-dashboard.ts
export type State = ...
export function reducer(...) ...
export async function loadInvoices(...) ...
export function selectTotal(...) ...
export function BillingDashboard() ...
```

```ts
// after
// billing-dashboard/state.ts
export type BillingDashboardState = ...

// billing-dashboard/reducer.ts
export function reduceBillingDashboard(...) ...

// billing-dashboard/selectors.ts
export function selectOutstandingTotal(...) ...

// billing-dashboard/effects.ts
export async function loadBillingDashboard(...) ...
```

Why better: the module layout mirrors responsibility boundaries. TypeScript
feature: feature-specific named state and reducer types.
