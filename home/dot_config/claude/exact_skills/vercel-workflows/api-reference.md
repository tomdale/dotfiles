# API Reference

Complete API reference for the Workflow Development Kit.

## Directives

### `"use workflow"`

Marks a function as a durable workflow. The function remembers its progress and resumes exactly where it left off after pauses, deployments, or crashes.

```typescript
export async function myWorkflow(input: string) {
  "use workflow";

  // Workflow body - state is persisted automatically
  const result = await someStep(input);
  return result;
}
```

**Behavior:**
- Compiles into an orchestration route
- All inputs/outputs recorded in event log
- Deterministic replay on recovery

### `"use step"`

Marks a function as an isolated step with automatic retries.

```typescript
async function fetchData(url: string) {
  "use step";

  const response = await fetch(url);
  if (!response.ok) throw new Error("Fetch failed");
  return response.json();
}
```

**Behavior:**
- Compiles into isolated API route
- Workflow suspends during step execution
- Automatic retry on transient failures
- Step results are persisted (idempotent)

## Core Functions

### `sleep(duration)`

Pause workflow execution without consuming compute resources.

```typescript
import { sleep } from "workflow";

// String durations
await sleep("30 seconds");
await sleep("5 minutes");
await sleep("2 hours");
await sleep("7 days");
await sleep("1 month");

// Numeric (milliseconds)
await sleep(60000);  // 1 minute
```

**Duration Formats:**
- `"N seconds"` / `"N second"` / `"Ns"`
- `"N minutes"` / `"N minute"` / `"Nm"`
- `"N hours"` / `"N hour"` / `"Nh"`
- `"N days"` / `"N day"` / `"Nd"`
- `"N weeks"` / `"N week"` / `"Nw"`
- `"N months"` / `"N month"`
- Numeric value in milliseconds

### `start(workflow, input)`

Programmatically start a workflow run.

```typescript
import { start } from "workflow/api";

// Start and get run ID
const run = await start(myWorkflow, { topic: "AI" });
console.log(run.id);

// Start and wait for result
const result = await start(myWorkflow, { topic: "AI" }).then(r => r.result);
```

## Hooks API

Hooks enable human-in-the-loop workflows by waiting for external events.

### `defineHook<T>()`

Define a typed hook for external event handling.

```typescript
import { defineHook } from "workflow";

const approvalHook = defineHook<{
  approved: boolean;
  reviewer: string;
  comments?: string;
}>();
```

### `hook.create(options)`

Create a hook instance within a workflow.

```typescript
export async function reviewWorkflow(docId: string) {
  "use workflow";

  // Create hook with unique token
  const events = approvalHook.create({
    token: docId,  // unique identifier for resumption
  });

  // Iterate over events (usually just one)
  for await (const event of events) {
    if (event.approved) {
      await publish(docId);
    }
    break;
  }
}
```

### `hook.resume(token, data)`

Resume a waiting workflow with event data.

```typescript
// From API route or external system
await approvalHook.resume("doc-123", {
  approved: true,
  reviewer: "jane@example.com",
  comments: "Looks good!",
});
```

## Webhooks API

Webhooks provide URLs for external services to call back.

### `createWebhook()`

Create a webhook URL for external callbacks.

```typescript
import { createWebhook } from "workflow";

export async function integrationWorkflow() {
  "use workflow";

  const webhook = createWebhook();

  // Send webhook URL to external service
  await fetch("https://external-api.com/subscribe", {
    method: "POST",
    body: JSON.stringify({ callbackUrl: webhook.url }),
  });

  // Wait for callback (suspends workflow)
  const { request } = await webhook;

  // Process callback data
  const data = await request.json();
  return data;
}
```

**Webhook Properties:**
- `webhook.url` - URL for external service to POST to
- `await webhook` - Returns `{ request }` when callback received

## Error Handling

### `FatalError`

Non-retryable error that terminates the workflow.

```typescript
import { FatalError } from "workflow";

async function validateInput(data: unknown) {
  "use step";

  if (!isValid(data)) {
    // Will NOT retry - terminates workflow
    throw new FatalError("Invalid input format");
  }

  return data;
}
```

### `RetryableError`

Explicitly signal that an error should trigger retry.

```typescript
import { RetryableError } from "workflow";

async function callExternalAPI() {
  "use step";

  const response = await fetch("https://api.example.com/data");

  if (response.status === 503) {
    // Explicitly request retry
    throw new RetryableError("Service temporarily unavailable");
  }

  if (response.status === 400) {
    // Bad request - don't retry
    throw new FatalError("Bad request");
  }

  return response.json();
}
```

**Default Behavior:**
- Most errors trigger automatic retry
- After retry limit, workflow fails
- Use `FatalError` to skip retries

## Metadata Functions

### `getWorkflowMetadata()`

Access metadata about the current workflow run.

```typescript
import { getWorkflowMetadata } from "workflow";

export async function trackedWorkflow() {
  "use workflow";

  const metadata = getWorkflowMetadata();
  console.log(metadata.runId);
  console.log(metadata.startedAt);

  // Use for logging/tracing
  await logToObservability({
    workflowRunId: metadata.runId,
    event: "workflow_started",
  });
}
```

### `getStepMetadata()`

Access metadata about the current step.

```typescript
import { getStepMetadata } from "workflow";

async function trackedStep() {
  "use step";

  const metadata = getStepMetadata();
  console.log(metadata.stepId);
  console.log(metadata.attemptNumber);

  // Track retries
  if (metadata.attemptNumber > 1) {
    console.log(`Retry attempt ${metadata.attemptNumber}`);
  }
}
```

## Streaming

### `getWritable()`

Access writable stream for the current workflow run.

```typescript
import { getWritable } from "workflow";

export async function streamingWorkflow() {
  "use workflow";

  const writable = getWritable();
  const writer = writable.getWriter();

  // Stream data to client
  await writer.write(new TextEncoder().encode("Progress: 25%\n"));
  await someStep();

  await writer.write(new TextEncoder().encode("Progress: 50%\n"));
  await anotherStep();

  await writer.write(new TextEncoder().encode("Progress: 100%\n"));
  await writer.close();
}
```

## AI Integration

The `@workflow/ai` package provides durable AI agent primitives.

### Installation

```bash
npm install @workflow/ai
```

### `DurableAgent`

Create AI agents that survive interruptions.

```typescript
import { DurableAgent } from "@workflow/ai";

export async function agentWorkflow(query: string) {
  "use workflow";

  const agent = new DurableAgent({
    model: "gpt-4",
    tools: [searchTool, calculatorTool],
  });

  // Agent can pause between tool calls
  const result = await agent.run(query);

  return result;
}
```

### `WorkflowChatTransport`

Manage durable chat sessions.

```typescript
import { WorkflowChatTransport } from "@workflow/ai";

const transport = new WorkflowChatTransport();

export async function chatWorkflow(sessionId: string, message: string) {
  "use workflow";

  const session = await transport.getOrCreateSession(sessionId);

  session.addMessage({ role: "user", content: message });

  const response = await generateResponse(session.messages);

  session.addMessage({ role: "assistant", content: response });

  return response;
}
```

## Built-in Fetch

Workflows have access to a durable `fetch` function.

```typescript
export async function fetchWorkflow(url: string) {
  "use workflow";

  // Built-in fetch with automatic retry
  const response = await fetch(url);

  return response.json();
}
```

**Behavior:**
- Automatically retries on network failures
- Results are memoized (same call returns cached result on replay)
