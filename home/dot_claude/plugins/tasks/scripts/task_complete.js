#!/usr/bin/env node
/**
 * task_complete.js - Mark the first pending task as complete
 *
 * Usage: node task_complete.js <path-to-tasks.md> [--blocked]
 *
 * Without --blocked: Changes first [ ] to [x]
 * With --blocked: Changes first [ ] to [!]
 *
 * Exit codes: 0 = success, 1 = error or no pending tasks
 */

const fs = require('fs');

function main() {
  const tasksPath = process.argv[2];
  const isBlocked = process.argv.includes('--blocked');

  if (!tasksPath) {
    console.error('Usage: node task_complete.js <path-to-tasks.md> [--blocked]');
    process.exit(1);
  }

  if (!fs.existsSync(tasksPath)) {
    console.error('Tasks file not found');
    process.exit(1);
  }

  const content = fs.readFileSync(tasksPath, 'utf8');
  const lines = content.split('\n');

  let found = false;
  let taskTitle = '';

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Look for first pending task
    const match = line.match(/^- \[ \] (.+)$/);
    if (match) {
      taskTitle = match[1];
      const newStatus = isBlocked ? '[!]' : '[x]';
      lines[i] = line.replace('- [ ]', `- ${newStatus}`);
      found = true;
      break;
    }
  }

  if (!found) {
    console.error('No pending tasks found');
    process.exit(1);
  }

  fs.writeFileSync(tasksPath, lines.join('\n'));

  const action = isBlocked ? 'Blocked' : 'Completed';
  console.log(`${action}: ${taskTitle}`);
  process.exit(0);
}

main();
