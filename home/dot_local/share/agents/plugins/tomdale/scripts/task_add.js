#!/usr/bin/env node
/**
 * Add a task to a markdown task list.
 *
 * Usage: node task_add.js <path-to-tasks.md> <task-text>
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

  const dir = path.dirname(tasksPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  const lines = taskText.split('\n');
  const title = lines[0];
  const contextLines = lines.slice(1);

  let formattedTask = `- [ ] ${title}`;

  for (const contextLine of contextLines) {
    if (contextLine.trim()) {
      formattedTask += `\n  ${contextLine}`;
    }
  }

  let existingContent = '';
  if (fs.existsSync(tasksPath)) {
    existingContent = fs.readFileSync(tasksPath, 'utf8');
  }

  const newContent = existingContent.trim()
    ? `${existingContent.trimEnd()}\n${formattedTask}\n`
    : `${formattedTask}\n`;

  fs.writeFileSync(tasksPath, newContent);
  console.log(`Added task: ${title}`);
}

main();
