#!/usr/bin/env node
/**
 * task_archive.js - Archive completed tasks file
 *
 * Usage: node task_archive.js <path-to-tasks.md>
 *
 * Renames tasks.md to YYYY-MM-DD-tasks.md
 * Only archives if all tasks are complete (no [ ] remaining)
 *
 * Exit codes: 0 = success, 1 = error or has pending tasks
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

  // Check for any pending tasks
  if (/^- \[ \]/m.test(content)) {
    console.error('Cannot archive: pending tasks remain');
    process.exit(1);
  }

  // Check for any blocked tasks
  if (/^- \[!\]/m.test(content)) {
    console.error('Cannot archive: blocked tasks remain');
    process.exit(1);
  }

  // Check if there are any completed tasks
  if (!/^- \[x\]/m.test(content)) {
    console.error('No completed tasks to archive');
    process.exit(1);
  }

  // Generate archive filename with date
  const now = new Date();
  const dateStr = now.toISOString().split('T')[0]; // YYYY-MM-DD
  const dir = path.dirname(tasksPath);
  const archivePath = path.join(dir, `${dateStr}-tasks.md`);

  // Handle case where archive already exists (add suffix)
  let finalArchivePath = archivePath;
  let suffix = 1;
  while (fs.existsSync(finalArchivePath)) {
    finalArchivePath = path.join(dir, `${dateStr}-tasks-${suffix}.md`);
    suffix++;
  }

  // Rename the file
  fs.renameSync(tasksPath, finalArchivePath);
  console.log(`Archived to: ${path.basename(finalArchivePath)}`);
  process.exit(0);
}

main();
