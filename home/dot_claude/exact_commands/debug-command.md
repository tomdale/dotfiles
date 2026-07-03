---
description: "Debug slash command for testing positional argument interpolation"
argument-hint: "[arg1?] [arg2?] [arg3?]"
---
OUTPUT:
---
Raw arguments:
  arg1 = "$1"
  arg2 = "$2"
  arg3 = "$3"

Inline command execution:
  Current directory: !`pwd`
  Date: !`date +%Y-%m-%d`
---

Print the contents within the dividers above **verbatim** and stop.
