#!/usr/bin/env node
/**
 * Mark the first pending task complete or blocked.
 *
 * Usage: node task_complete.js <path-to-tasks.md> [--blocked]
 */

const fs = require('fs');

function main() {
  const tasksPath = process.argv[2];
  const blocked = process.argv.includes('--blocked');

  if (!tasksPath) {
    console.error('Usage: node task_complete.js <path-to-tasks.md> [--blocked]');
    process.exit(1);
  }

  if (!fs.existsSync(tasksPath)) {
    console.error('Tasks file not found');
    process.exit(1);
  }

  const lines = fs.readFileSync(tasksPath, 'utf8').split('\n');
  let title = null;

  for (let i = 0; i < lines.length; i += 1) {
    const match = lines[i].match(/^- \[ \] (.+)$/);
    if (!match) {
      continue;
    }

    title = match[1];
    lines[i] = blocked ? lines[i].replace('- [ ]', '- [!]') : lines[i].replace('- [ ]', '- [x]');
    break;
  }

  if (!title) {
    console.error('No pending tasks found');
    process.exit(1);
  }

  fs.writeFileSync(tasksPath, lines.join('\n'));
  console.log(`${blocked ? 'Blocked' : 'Completed'}: ${title}`);
}

main();
