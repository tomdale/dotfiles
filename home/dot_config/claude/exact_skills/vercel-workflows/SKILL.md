---
name: vercel-workflows
description: Build durable, reliable TypeScript applications and AI agents with the Vercel Workflow Development Kit (WDK). Use when the user wants to create long-running workflows, durable functions, AI agents that pause/resume, human-in-the-loop flows, or mentions Workflow DevKit, "use workflow", "use step", durable functions, or workflow orchestration.
---

# Vercel Workflow Development Kit

The Workflow Development Kit (WDK) is a TypeScript framework for building durable applications and AI agents that can pause, resume, and maintain state. It introduces two directives that turn ordinary async functions into workflows that survive deployments, crashes, and long pauses.

## Core Concepts

### Two Directives

| Directive | Purpose |
|-----------|---------|
| `"use workflow"` | Marks a function as durable - remembers progress and resumes where it left off |
| `"use step"` | Marks a function as a step - isolated unit of work with built-in retries |

### Key Capabilities

- **Resumable**: Pause for minutes or months, then resume exactly where stopped
- **Durable**: Survive deployments and crashes with deterministic replays
- **Observable**: Built-in logs, metrics, and tracing
- **Idiomatic**: Write async/await JavaScript - no YAML or state machines

## Installation

```bash
npm install workflow
# or
pnpm add workflow
```

## Quick Start

### Basic Workflow

```typescript
// app/workflows/content-workflow.ts
export async function contentWorkflow(topic: string) {
  "use workflow";

  const draft = await generateDraft(topic);
  const summary = await summarizeDraft(draft);

  return { draft, summary };
}
```

### Steps with Retries

```typescript
// Steps run in isolation with automatic retries
async function generateDraft(topic: string) {
  "use step";

  const response = await fetch("https://api.openai.com/v1/completions", {
    method: "POST",
    body: JSON.stringify({ prompt: `Write about ${topic}` }),
  });

  return response.json();
}

async function summarizeDraft(draft: string) {
  "use step";

  // If this fails transiently, it automatically retries
  const summary = await aiSummarize({ text: draft });
  return summary;
}
```

### Sleep (Pause Without Resources)

```typescript
import { sleep } from "workflow";

export async function reminderWorkflow(userId: string) {
  "use workflow";

  await sendWelcomeEmail(userId);

  // Pause for 7 days - no compute resources consumed
  await sleep("7 days");

  await sendFollowUpEmail(userId);
}
```

### Hooks (Human-in-the-Loop)

```typescript
import { defineHook } from "workflow";

// Define a hook for external events
const approvalHook = defineHook<{
  decision: "approved" | "rejected";
  notes?: string;
}>();

export async function approvalWorkflow(documentId: string) {
  "use workflow";

  const document = await fetchDocument(documentId);

  // Create hook and wait for external event
  const events = approvalHook.create({ token: documentId });

  for await (const event of events) {
    if (event.decision === "approved") {
      await publishDocument(document);
      break;
    } else {
      await archiveDocument(document, event.notes);
      break;
    }
  }
}

// Resume from external API
// POST /api/approve
export async function POST(req: Request) {
  const { documentId, decision, notes } = await req.json();

  await approvalHook.resume(documentId, { decision, notes });

  return new Response("OK");
}
```

### Webhooks (Wait for External Callbacks)

```typescript
import { createWebhook } from "workflow";

export async function paymentWorkflow(orderId: string) {
  "use workflow";

  const webhook = createWebhook();

  // Start payment, provide callback URL
  await fetch("https://payment-provider.com/charge", {
    method: "POST",
    body: JSON.stringify({
      orderId,
      amount: 100,
      callbackUrl: webhook.url,
    }),
  });

  // Wait for payment provider callback (could be seconds or hours)
  const { request } = await webhook;
  const paymentResult = await request.json();

  if (paymentResult.status === "success") {
    await fulfillOrder(orderId);
  }
}
```

## Framework Integration

WDK works with multiple frameworks:

| Framework | Status |
|-----------|--------|
| Next.js | Supported |
| Vite | Supported |
| Astro | Supported |
| Express | Supported |
| Fastify | Supported |
| Hono | Supported |
| Nitro | Supported |
| Nuxt | Supported |
| SvelteKit | Supported |
| NestJS | Coming Soon |
| TanStack | Coming Soon |

## Execution Environments ("Worlds")

| Environment | Use Case |
|-------------|----------|
| Local World | Development - virtual infrastructure, no external services |
| Vercel World | Production - automatic queues, persistence, routing |
| Custom Worlds | Self-hosted - community implementations (e.g., Postgres) |

## Detailed Documentation

- **[API Reference](api-reference.md)** - Complete API including sleep, hooks, webhooks, errors, and metadata
- **[Patterns](patterns.md)** - Common patterns for AI agents, batch processing, and complex workflows

## External Resources

- [Official Documentation](https://useworkflow.dev)
- [GitHub Repository](https://github.com/vercel/workflow)
- [Example Projects](https://github.com/vercel/workflow-examples)
- [Vercel Workflow (Managed)](https://vercel.com/docs/workflow)
