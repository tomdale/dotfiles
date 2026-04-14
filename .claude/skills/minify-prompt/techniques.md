Techniques are ordered by typical token savings, highest first. Each shows a
before/after pair. The "after" form is what the output should look like.

STRIP ALL MARKDOWN FORMATTING
This is the single highest-impact operation. Remove every heading, bold/italic
marker, code fence, bullet, table pipe, and horizontal rule. These tokens exist
for visual rendering and carry zero information for an agent reader.
Before:
  ## Configuration
  **Important:** Always set `NODE_ENV` to `production` before deploying.
  - Run `npm run build`
  - Run `npm start`
After:
  Always set NODE_ENV=production before deploying. Build: npm run build, then
  npm start.

REMOVE REDUNDANCY
Scan for instructions restated in different words across the file. Merge into
one statement.
Before:
  Always run tests after making changes. It's important to verify your work by
  running the test suite. Make sure you don't skip testing. After any code
  modification, execute the tests to confirm nothing is broken.
After:
  Run tests after every code change.

FACTOR OUT COMMON STRUCTURE
When multiple items share a prefix, parent path, or repeated pattern, state the
shared part once.
Before:
  /Users/tom/.config/claude/skills/foo/SKILL.md
  /Users/tom/.config/claude/skills/bar/SKILL.md
  /Users/tom/.config/claude/skills/baz/SKILL.md
After:
  ~/.config/claude/skills/{foo,bar,baz}/SKILL.md
Or when items share a common base:
Before:
  home/dot_config/claude/exact_plugins/tasks/commands/list.md
  home/dot_config/claude/exact_plugins/tasks/commands/create.md
  home/dot_config/claude/exact_plugins/tasks/skills/manage.md
After:
  base: home/dot_config/claude/exact_plugins/tasks/
    commands/: list.md, create.md
    skills/: manage.md

COLLAPSE EXAMPLES
Keep only the minimum example that demonstrates the point. If multiple examples
show the same concept, keep the most concise one. If an example just restates
the instruction concretely, cut it — the instruction alone suffices.

CONVERT LISTS AND TABLES TO INLINE PROSE
Bulleted lists and tables spend tokens on structural markup. Convert to
comma-separated or semicolon-separated prose.
Before:
  | OS | Package Manager | Install Command |
  |----|----------------|-----------------|
  | macOS | Homebrew | brew install foo |
  | Ubuntu | apt | apt install foo |
  | Fedora | dnf | dnf install foo |
After:
  Install foo: macOS brew install foo, Ubuntu apt install foo, Fedora dnf
  install foo.

ELIMINATE FILLER
Delete phrases that add no information. Common fillers and their replacements:
"it is important to note that" → delete, "in order to" → to, "make sure that
you" → just state the action, "please note that" → delete, "you should always"
→ always, "keep in mind that" → delete, "the reason for this is" → because,
"due to the fact that" → because, "in the event that" → if, "at this point in
time" → now.

REMOVE HEDGING AND POLITENESS
Agents don't need social lubrication. Be direct.
Before: You might want to consider possibly checking if the file exists before
attempting to read it, as this could potentially cause an error.
After: Check file existence before reading.

DROP REDUNDANT NEGATIVES
If a positive instruction is clear, negative restatements ("don't do X") are
redundant.
Before: Use snake_case for variables. Don't use camelCase. Don't use PascalCase.
After: Use snake_case for variables.

COMPRESS CONDITIONAL PATTERNS
When the same structure repeats with small variations, use compact notation.
Before:
  If on macOS, the config is at ~/Library/Preferences/foo.plist.
  If on Linux, the config is at ~/.config/foo/config.toml.
After:
  Config path: macOS ~/Library/Preferences/foo.plist, Linux
  ~/.config/foo/config.toml.

DEDUPLICATE ACROSS SECTIONS
If a concept is explained in multiple places in the file, keep the fullest
version and delete the others. Don't add "as noted above/below" — just state
the fact once.

USE IMPLICIT STRUCTURE
Instead of explicit structural markers (headings, bullets), rely on consistent
conventions that an agent can parse. Separate topics with a single blank line.
Use key: value for definitions. Use parenthetical annotations for metadata.
The agent doesn't need visual hierarchy cues — it processes the full text
sequentially.
