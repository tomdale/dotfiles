#!/usr/bin/env node
/**
 * task_get.js - Get the first pending task from tasks.md
 *
 * Usage: node task_get.js <path-to-tasks.md>
 * Output: First pending task ([ ]) with its indented context
 * Exit codes: 0 = success, 1 = error or no pending tasks
 */

const fs = require('fs');
const path = require('path');

function main() {
  const tasksPath = process.argv[2];

  if (!tasksPath) {
    console.error('Usage: node task_get.js <path-to-tasks.md>');
    process.exit(1);
  }

  // Check if file exists
  if (!fs.existsSync(tasksPath)) {
    console.error('No tasks file found');
    process.exit(1);
  }

  const content = fs.readFileSync(tasksPath, 'utf8');
  const lines = content.split('\n');

  let taskStart = -1;
  let taskLines = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Look for first pending task (- [ ])
    if (taskStart === -1 && /^- \[ \]/.test(line)) {
      taskStart = i;
      taskLines.push(line);
      continue;
    }

    // If we found a task, collect indented context lines
    if (taskStart !== -1) {
      // Check if this is an indented line (part of current task context)
      if (/^  [^ ]/.test(line) || /^  $/.test(line)) {
        taskLines.push(line);
      } else {
        // Hit a non-indented line, we're done with this task
        break;
      }
    }
  }

  if (taskStart === -1) {
    console.error('No pending tasks found');
    process.exit(1);
  }

  // Output the task with its context
  console.log(taskLines.join('\n'));
  process.exit(0);
}

main();
