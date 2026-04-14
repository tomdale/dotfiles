#!/usr/bin/env node

const { execFileSync } = require("child_process");

function textResult(payload, isError = false) {
  return {
    content: [
      {
        type: "text",
        text: JSON.stringify(payload),
      },
    ],
    structuredContent: payload,
    isError,
  };
}

function parseSessionUuid() {
  const sessionId = process.env.ITERM_SESSION_ID;
  if (!sessionId) {
    return { ok: false, reason: "not_in_iterm2" };
  }

  const parts = sessionId.split(":");
  const uuid = parts[1];
  if (!uuid) {
    return { ok: false, reason: "invalid_session_id" };
  }

  return { ok: true, uuid };
}

function buildAppleScript(uuid, updates) {
  const goal = Object.prototype.hasOwnProperty.call(updates, "goal")
    ? JSON.stringify(updates.goal)
    : null;
  const task = Object.prototype.hasOwnProperty.call(updates, "task")
    ? JSON.stringify(updates.task)
    : null;

  const lines = [
    'tell application "iTerm2"',
    "  repeat with w in windows",
    "    repeat with t in tabs of w",
    "      repeat with s in sessions of t",
    `        if unique ID of s is ${JSON.stringify(uuid)} then`,
  ];

  if (goal !== null) {
    lines.push(`          tell s to set variable named "user.currentGoal" to ${goal}`);
  }
  if (task !== null) {
    lines.push(`          tell s to set variable named "user.currentActivity" to ${task}`);
  }

  lines.push("          return true");
  lines.push("        end if");
  lines.push("      end repeat");
  lines.push("    end repeat");
  lines.push("  end repeat");
  lines.push("end tell");
  lines.push("return false");

  return lines.join("\n");
}

function applyStatus(argumentsObject) {
  const updates = {};

  if (Object.prototype.hasOwnProperty.call(argumentsObject, "goal")) {
    if (typeof argumentsObject.goal !== "string") {
      return { ok: false, reason: "invalid_goal_type" };
    }
    updates.goal = argumentsObject.goal;
  }

  if (Object.prototype.hasOwnProperty.call(argumentsObject, "task")) {
    if (typeof argumentsObject.task !== "string") {
      return { ok: false, reason: "invalid_task_type" };
    }
    updates.task = argumentsObject.task;
  }

  const hasGoal = Object.prototype.hasOwnProperty.call(updates, "goal");
  const hasTask = Object.prototype.hasOwnProperty.call(updates, "task");
  if (!hasGoal && !hasTask) {
    return { ok: false, reason: "missing_updates" };
  }

  const session = parseSessionUuid();
  if (!session.ok) {
    return {
      ok: true,
      applied: false,
      reason: session.reason,
      updated: { goal: hasGoal, task: hasTask },
    };
  }

  try {
    const output = execFileSync("osascript", ["-"], {
      input: buildAppleScript(session.uuid, updates),
      encoding: "utf8",
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    const applied = output === "true";
    return {
      ok: true,
      applied,
      reason: applied ? undefined : "session_not_found",
      updated: { goal: hasGoal, task: hasTask },
    };
  } catch (error) {
    return {
      ok: true,
      applied: false,
      reason: "osascript_failed",
      updated: { goal: hasGoal, task: hasTask },
      details:
        typeof error?.stderr === "string" && error.stderr.trim()
          ? error.stderr.trim()
          : undefined,
    };
  }
}

async function main() {
  const [{ McpServer }, { StdioServerTransport }, { z }] = await Promise.all([
    import("@modelcontextprotocol/sdk/server/mcp.js"),
    import("@modelcontextprotocol/sdk/server/stdio.js"),
    import("zod"),
  ]);

  const server = new McpServer({
    name: "tomdale-status-mcp",
    title: "tomdale status",
    version: "0.1.0",
  });

  server.tool(
    "set_status",
    "Set the current iTerm2 goal and/or task for the active terminal session.",
    {
      goal: z
        .string()
        .optional()
        .describe("Stable high-level objective for the current session. Empty string clears it."),
      task: z
        .string()
        .optional()
        .describe("Current step in progress. Empty string clears it."),
    },
    async (argumentsObject) => {
      const result = applyStatus(argumentsObject);
      return textResult(result, !result.ok);
    }
  );

  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  process.stderr.write(`${String(error?.stack || error)}\n`);
  process.exit(1);
});
