#!/usr/bin/env node
/**
 * task_add.js - Add a task to tasks.md
 *
 * Usage: node task_add.js <path-to-tasks.md> <task-text>
 *
 * Task text can be multiline - first line is the task title,
 * subsequent lines are context (will be indented with 2 spaces)
 *
 * Exit codes: 0 = success, 1 = error
 */

const fs = require('fs');
const path = require('path');

function main() {
  const tasksPath = process.argv[2];
  const taskText = process.argv[3];

  if (!tasksPath || !taskText) {
    console.error('Usage: node task_add.js <path-to-tasks.md> <task-text>');
    process.exit(1);
  }

  // Ensure directory exists
  const dir = path.dirname(tasksPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  // Parse task text - first line is title, rest is context
  const lines = taskText.split('\n');
  const title = lines[0];
  const contextLines = lines.slice(1);

  // Format the task
  let formattedTask = `- [ ] ${title}`;

  // Add context lines with proper indentation
  for (const contextLine of contextLines) {
    if (contextLine.trim()) {
      formattedTask += `\n  ${contextLine}`;
    }
  }

  // Read existing content or start fresh
  let existingContent = '';
  if (fs.existsSync(tasksPath)) {
    existingContent = fs.readFileSync(tasksPath, 'utf8');
  }

  // Append task with proper spacing
  let newContent;
  if (existingContent.trim()) {
    // Ensure there's a newline before the new task
    newContent = existingContent.trimEnd() + '\n' + formattedTask + '\n';
  } else {
    newContent = formattedTask + '\n';
  }

  fs.writeFileSync(tasksPath, newContent);
  console.log(`Added task: ${title}`);
  process.exit(0);
}

main();
