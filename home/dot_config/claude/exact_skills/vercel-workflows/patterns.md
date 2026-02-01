# Common Patterns

Practical patterns for building workflows with the Workflow DevKit.

## AI Agent Patterns

### Long-Running RAG Pipeline

Process documents over extended periods with checkpoint recovery.

```typescript
import { sleep } from "workflow";

export async function ragPipeline(documentIds: string[]) {
  "use workflow";

  const embeddings: Record<string, number[]> = {};

  for (const docId of documentIds) {
    // Each document processed as separate step
    embeddings[docId] = await processDocument(docId);

    // Rate limit between API calls
    await sleep("1 second");
  }

  await storeEmbeddings(embeddings);

  return { processed: documentIds.length };
}

async function processDocument(docId: string) {
  "use step";

  const doc = await fetchDocument(docId);
  const embedding = await generateEmbedding(doc.content);
  return embedding;
}
```

### AI Agent with Tool Calls

Build agents that pause between reasoning steps.

```typescript
import { DurableAgent } from "@workflow/ai";
import { defineHook } from "workflow";

const confirmationHook = defineHook<{ confirmed: boolean }>();

export async function researchAgent(query: string) {
  "use workflow";

  const agent = new DurableAgent({
    model: "gpt-4",
    tools: [
      {
        name: "search",
        execute: async (params) => searchWeb(params.query),
      },
      {
        name: "request_approval",
        execute: async (params) => {
          // Human-in-the-loop for sensitive actions
          const events = confirmationHook.create({ token: params.actionId });
          for await (const event of events) {
            return event.confirmed;
          }
        },
      },
    ],
  });

  return agent.run(query);
}
```

## E-Commerce Patterns

### Order Fulfillment Workflow

Handle multi-day order processing with payment and shipping.

```typescript
import { sleep, defineHook } from "workflow";

const paymentHook = defineHook<{ status: "success" | "failed"; txId?: string }>();
const shippingHook = defineHook<{ status: "shipped"; trackingNumber: string }>();

export async function orderWorkflow(orderId: string) {
  "use workflow";

  const order = await fetchOrder(orderId);

  // Step 1: Process payment
  await initiatePayment(orderId, paymentHook);

  const paymentEvents = paymentHook.create({ token: `payment-${orderId}` });
  let paymentResult;
  for await (const event of paymentEvents) {
    paymentResult = event;
    break;
  }

  if (paymentResult.status === "failed") {
    await cancelOrder(orderId);
    return { status: "cancelled", reason: "payment_failed" };
  }

  // Step 2: Reserve inventory
  await reserveInventory(orderId);

  // Step 3: Wait for shipping (could take days)
  const shippingEvents = shippingHook.create({ token: `shipping-${orderId}` });
  let shippingResult;
  for await (const event of shippingEvents) {
    shippingResult = event;
    break;
  }

  // Step 4: Send confirmation
  await sendShippingConfirmation(orderId, shippingResult.trackingNumber);

  // Step 5: Wait 30 days then request review
  await sleep("30 days");
  await sendReviewRequest(orderId);

  return { status: "completed", trackingNumber: shippingResult.trackingNumber };
}
```

### Subscription Billing

Recurring billing with retry logic.

```typescript
import { sleep, FatalError } from "workflow";

export async function billingWorkflow(subscriptionId: string) {
  "use workflow";

  while (true) {
    const subscription = await getSubscription(subscriptionId);

    if (subscription.status === "cancelled") {
      return { status: "ended" };
    }

    // Attempt billing with retries
    const billed = await attemptBilling(subscriptionId);

    if (!billed.success) {
      // Notify customer, wait for payment update
      await notifyPaymentFailed(subscriptionId);
      await sleep("3 days");

      const retryBilled = await attemptBilling(subscriptionId);
      if (!retryBilled.success) {
        await cancelSubscription(subscriptionId);
        return { status: "cancelled", reason: "payment_failed" };
      }
    }

    // Wait until next billing cycle
    await sleep("1 month");
  }
}
```

## Batch Processing Patterns

### Parallel Batch Processing

Process large batches efficiently.

```typescript
export async function batchWorkflow(items: string[]) {
  "use workflow";

  // Process in batches of 10
  const batchSize = 10;
  const results: any[] = [];

  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);

    // Each batch is a step (recoverable checkpoint)
    const batchResults = await processBatch(batch);
    results.push(...batchResults);
  }

  return { processed: results.length, results };
}

async function processBatch(items: string[]) {
  "use step";

  // Process batch items in parallel
  return Promise.all(items.map(processItem));
}
```

### ETL Pipeline

Extract, transform, load with checkpoints.

```typescript
import { sleep } from "workflow";

export async function etlWorkflow(sourceId: string) {
  "use workflow";

  // Extract (checkpoint after)
  const rawData = await extractFromSource(sourceId);

  // Transform (checkpoint after)
  const transformed = await transformData(rawData);

  // Load (checkpoint after)
  await loadToDestination(transformed);

  // Schedule next run
  await sleep("1 hour");

  // Recursively continue (or use external scheduler)
  return { status: "completed", nextRun: new Date(Date.now() + 3600000) };
}

async function extractFromSource(sourceId: string) {
  "use step";
  // ... extraction logic
}

async function transformData(data: any) {
  "use step";
  // ... transformation logic
}

async function loadToDestination(data: any) {
  "use step";
  // ... loading logic
}
```

## Notification Patterns

### Multi-Channel Notification Sequence

Send notifications across channels with delays.

```typescript
import { sleep } from "workflow";

export async function notificationSequence(userId: string, message: string) {
  "use workflow";

  const user = await getUser(userId);

  // Immediate: in-app notification
  await sendInAppNotification(userId, message);

  // Wait 5 minutes, check if read
  await sleep("5 minutes");

  const read = await checkNotificationRead(userId);
  if (read) return { channel: "in_app" };

  // Send email
  await sendEmail(user.email, message);

  // Wait 1 hour
  await sleep("1 hour");

  const emailRead = await checkEmailRead(userId);
  if (emailRead) return { channel: "email" };

  // Final: SMS for urgent matters
  if (user.phone && user.smsEnabled) {
    await sendSMS(user.phone, message);
    return { channel: "sms" };
  }

  return { channel: "email", escalated: false };
}
```

## Approval Workflow Patterns

### Multi-Level Approval

Sequential approvals with escalation.

```typescript
import { sleep, defineHook } from "workflow";

const approvalHook = defineHook<{
  approved: boolean;
  approver: string;
  notes?: string;
}>();

export async function approvalWorkflow(requestId: string, amount: number) {
  "use workflow";

  const approvers = getApproverChain(amount);

  for (const approver of approvers) {
    await notifyApprover(approver, requestId);

    const events = approvalHook.create({ token: `${requestId}-${approver}` });

    // Set timeout for approval
    const timeout = sleep("24 hours").then(() => ({ timeout: true }));

    let result;
    for await (const event of events) {
      result = event;
      break;
    }

    // Handle timeout
    if (!result) {
      await escalateApproval(requestId, approver);
      continue;
    }

    if (!result.approved) {
      return { status: "rejected", rejectedBy: approver, notes: result.notes };
    }
  }

  return { status: "approved" };
}

function getApproverChain(amount: number): string[] {
  if (amount < 1000) return ["manager"];
  if (amount < 10000) return ["manager", "director"];
  return ["manager", "director", "vp"];
}
```

## Scheduled Task Patterns

### Cron-like Scheduling

Implement recurring tasks.

```typescript
import { sleep } from "workflow";

export async function dailyReportWorkflow() {
  "use workflow";

  while (true) {
    const now = new Date();

    // Generate daily report
    await generateDailyReport();
    await sendReportEmail();

    // Calculate time until next 9 AM
    const next9AM = new Date(now);
    next9AM.setDate(next9AM.getDate() + 1);
    next9AM.setHours(9, 0, 0, 0);

    const msUntilNext = next9AM.getTime() - now.getTime();
    await sleep(msUntilNext);
  }
}
```

### Delayed Job

Execute a task after a specific delay.

```typescript
import { sleep } from "workflow";

export async function delayedJobWorkflow(
  taskType: string,
  payload: any,
  delayMs: number
) {
  "use workflow";

  // Wait for specified delay
  await sleep(delayMs);

  // Execute the delayed task
  switch (taskType) {
    case "send_reminder":
      await sendReminder(payload);
      break;
    case "cleanup_temp_files":
      await cleanupTempFiles(payload);
      break;
    case "expire_session":
      await expireSession(payload);
      break;
  }

  return { executed: taskType, at: new Date().toISOString() };
}
```

## Error Recovery Patterns

### Saga Pattern

Compensating transactions for distributed operations.

```typescript
import { FatalError } from "workflow";

export async function sagaWorkflow(orderId: string) {
  "use workflow";

  const completedSteps: string[] = [];

  try {
    // Step 1: Reserve inventory
    await reserveInventory(orderId);
    completedSteps.push("inventory");

    // Step 2: Charge payment
    await chargePayment(orderId);
    completedSteps.push("payment");

    // Step 3: Create shipment
    await createShipment(orderId);
    completedSteps.push("shipment");

    return { status: "success" };
  } catch (error) {
    // Compensate in reverse order
    await compensate(orderId, completedSteps);
    throw new FatalError(`Saga failed: ${error.message}`);
  }
}

async function compensate(orderId: string, steps: string[]) {
  "use step";

  for (const step of steps.reverse()) {
    switch (step) {
      case "shipment":
        await cancelShipment(orderId);
        break;
      case "payment":
        await refundPayment(orderId);
        break;
      case "inventory":
        await releaseInventory(orderId);
        break;
    }
  }
}
```

### Circuit Breaker

Prevent cascading failures.

```typescript
import { sleep, RetryableError, FatalError } from "workflow";

let consecutiveFailures = 0;
const FAILURE_THRESHOLD = 5;
const RECOVERY_TIME = "30 seconds";

export async function circuitBreakerWorkflow(request: any) {
  "use workflow";

  // Check circuit state
  if (consecutiveFailures >= FAILURE_THRESHOLD) {
    // Circuit is open - wait before retrying
    await sleep(RECOVERY_TIME);
    consecutiveFailures = 0;
  }

  try {
    const result = await callExternalService(request);
    consecutiveFailures = 0;
    return result;
  } catch (error) {
    consecutiveFailures++;

    if (consecutiveFailures >= FAILURE_THRESHOLD) {
      throw new FatalError("Circuit breaker opened - service unavailable");
    }

    throw new RetryableError(error.message);
  }
}
```
