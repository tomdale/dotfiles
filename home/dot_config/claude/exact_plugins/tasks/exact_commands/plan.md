---
description: Break down a goal into multiple self-contained tasks
allowed-tools:
  - Task
argument-hint: [goal description]
---

# Plan Tasks

Break down a goal into discrete, self-contained tasks and add them to `.agent/tasks.md`.

## Instructions

1. Determine the goal:
   - If `$ARGUMENTS` is provided, use that as the goal
   - *If in plan mode*, use the current plan file as the goal
   - Otherwise, ask the user what goal they want to accomplish

2. Spawn the `task-planner` agent with the goal:
   - Pass the full goal description
   - The agent will search the codebase and create tasks
   - Wait for the agent to complete

3. Report what tasks were created

## Goal

$ARGUMENTS
