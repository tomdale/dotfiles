#!/usr/bin/env node
/**
 * Archive a completed markdown task list.
 *
 * Usage: node task_archive.js <path-to-tasks.md>
 */

const fs = require('fs');
const path = require('path');

function main() {
  const tasksPath = process.argv[2];

  if (!tasksPath) {
    console.error('Usage: node task_archive.js <path-to-tasks.md>');
    process.exit(1);
  }

  if (!fs.existsSync(tasksPath)) {
    console.error('Tasks file not found');
    process.exit(1);
  }

  const content = fs.readFileSync(tasksPath, 'utf8');

  if (/^- \[ \]/m.test(content)) {
    console.error('Cannot archive: pending tasks remain');
    process.exit(1);
  }

  if (/^- \[!\]/m.test(content)) {
    console.error('Cannot archive: blocked tasks remain');
    process.exit(1);
  }

  if (!/^- \[x\]/m.test(content)) {
    console.error('No completed tasks to archive');
    process.exit(1);
  }

  const dateStr = new Date().toISOString().split('T')[0];
  const dir = path.dirname(tasksPath);
  const basePath = path.join(dir, `${dateStr}-tasks.md`);

  let archivePath = basePath;
  let suffix = 1;
  while (fs.existsSync(archivePath)) {
    archivePath = path.join(dir, `${dateStr}-tasks-${suffix}.md`);
    suffix += 1;
  }

  fs.renameSync(tasksPath, archivePath);
  console.log(`Archived to: ${path.basename(archivePath)}`);
}

main();
