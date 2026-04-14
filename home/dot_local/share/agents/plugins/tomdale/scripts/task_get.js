#!/usr/bin/env node
/**
 * Get the first pending task from a markdown task list.
 *
 * Usage: node task_get.js <path-to-tasks.md>
 */

const fs = require('fs');

function main() {
  const tasksPath = process.argv[2];

  if (!tasksPath) {
    console.error('Usage: node task_get.js <path-to-tasks.md>');
    process.exit(1);
  }

  if (!fs.existsSync(tasksPath)) {
    console.error('No tasks file found');
    process.exit(1);
  }

  const content = fs.readFileSync(tasksPath, 'utf8');
  const lines = content.split('\n');

  let foundTask = false;
  const taskLines = [];

  for (const line of lines) {
    if (!foundTask && /^- \[ \]/.test(line)) {
      foundTask = true;
      taskLines.push(line);
      continue;
    }

    if (foundTask) {
      if (/^  [^ ]/.test(line) || /^  $/.test(line)) {
        taskLines.push(line);
      } else {
        break;
      }
    }
  }

  if (!foundTask) {
    console.error('No pending tasks found');
    process.exit(1);
  }

  console.log(taskLines.join('\n'));
}

main();
