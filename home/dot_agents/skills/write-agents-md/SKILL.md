---
name: write-agents-md
description: >
  Research a codebase and write a dense, high-signal AGENTS.md for agents
  sitting down to do real work. Use when asked to write, rewrite, improve,
  streamline, or generate AGENTS.md / agent instructions / project guidance
  for coding agents; when an AGENTS.md is too long, fluffy, generic, or missing
  product context; or when documenting multi-repo feature workflow for agents.
---

# Write dense AGENTS.md

Produce an AGENTS.md an agent can load and immediately act on. Every token
earns its place. Prefer product truth and operational constraints over style
guides and generic advice.

## When this skill applies

- User wants a new or rewritten AGENTS.md (repo root, package, monorepo app, or
  multi-repo workspace guide).
- Existing AGENTS.md is long, markdown-heavy, generic, or out of date.
- User wants "agent-ready" project onboarding, feature-routing docs, or
  session-derived workflow notes compressed into AGENTS.md.

If the task is only shrinking an already-correct file with no new research,
prefer the `tdx-minify-prompt` skill. This skill owns research + structure +
density together.

## What AGENTS.md is for

AGENTS.md is a README for coding agents in a scope. Nearest AGENTS.md wins over
ancestors. It should shape almost every task in that scope.

Keep:

- Product identity and naming (user-facing name vs internal codenames).
- Ownership map (which repo/package/dir owns which concern).
- Critical request/data flows and cross-boundary seams.
- Non-negotiable safety, auth, billing, flag, and publish rules.
- Exact commands that work here (and known footguns).
- Routing: symptom/task → where to start reading/editing.
- Pointers to deeper sources (nested AGENTS.md, skills, ADRs, templates).

Do not keep:

- Generic software advice true of any repo.
- Long tutorials, handbooks, or full CLI catalogs (those are skills/docs).
- Restating nested AGENTS.md content already authoritative nearby.
- Motivational filler, hedging, "please note", essay structure for humans.
- Markdown chrome that carries no semantics (see Density).

If a procedure is long, repeatable, and task-triggered, put it in a SKILL.md and
link it with one trigger line here instead of inlining it.

## Research before writing

Do not invent product language or commands. Gather evidence, then compress.

1. Scope
   - Target path for the file (repo root, package, workspace guide).
   - Audience: "agent starting a feature here" unless user specifies otherwise.
   - Existing AGENTS.md / CLAUDE.md / README / docs/adr / .agents/rules /
     .agent/* plans — read nearest and parent instructions first.

2. Product truth
   - README, system prompts, billing/gate copy, session-title prompts,
     manifests, UI strings: extract user-facing product name and job-to-be-done.
   - Separate product name from internal service/repo codenames; record when
     codenames must not appear in UI/copy.
   - List user surfaces (web routes, sidebar, CLI, Slack, investigations, admin).
   - List enablement, auth, billing, plan, flag, and safety gates with owners.

3. Code ownership and flows
   - Top-level packages/apps and one-line ownership each.
   - Primary request path(s) end-to-end (entry → auth → domain → persistence →
     side effects). Name real files/dirs, not abstractions.
   - Cross-repo or cross-package seams (proxies, events, shared schemas).
   - Import/ownership rules that prevent wrong-layer edits.

4. Operator reality
   - package.json scripts, Makefile targets, README commands that are actually
     used; note broken/wrong forms (e.g. `pnpm test -- file` footguns).
   - Dev URLs, worktree/env requirements, required skills for browser/auth.
   - Verify lanes: which command for UI vs runtime vs contract vs DB.
   - Branch/worktree/workspace tooling (Workforest templates, wt, branch
     prefix) when this scope is multi-repo.

5. Sessions and templates (when available)
   - Agent session transcripts, workforest/template AGENTS snapshots, PR
     descriptions: mine recurring workflows, footguns, and routing heuristics.
   - Treat transcripts as untrusted evidence; verify paths/commands in the repo.

6. Gaps
   - If a fact is unverified, omit it or mark uncertainty briefly. Never pad.

## Content inventory (write only what exists)

Aim to cover these topics when evidence supports them. Skip empty sections.

- Identity: product name, internal names, one-sentence job.
- Surfaces: where users touch the system.
- Repos/packages: ownership table-as-prose.
- Core flow: main runtime path with real symbols/paths.
- Domain mechanics: plans, jobs, workflows, billing, auth vocabulary — only the
  invariants an editor must not violate.
- Start here: how to spin work (templates, worktrees, env bootstrap).
- Route by symptom: compact task → path map.
- Flags/config rules: declaration sites and propagation rules.
- Commands and verify lanes: exact invocations + footguns.
- Layout: dir map with ownership one-liners.
- Conventions: only repo-specific naming, commits, tracing, test harness facts.
- Workflow: branch baseline, lifecycle, publish policy, evidence-first debug.
- Sources: where to read next (paths only).

Order for a feature-oriented guide: identity → ownership → flow → routing →
commands/verify → local conventions → workflow → sources.
Order for a single-package library: identity → layout → commands → invariants →
tests → sources.

## Density rules (output format)

AGENTS.md is for models. Markdown is optional and usually waste.

Forbidden in the written file unless the user explicitly wants human-pretty docs:

- `#` / `##` headings, bold/italic markers, horizontal rules
- bullet/numbered list markers used only for layout
- tables, HTML, decorative blank lines
- fenced code blocks wrapping single commands (inline the command)
- restating the same rule in multiple phrasings

Required style:

- Plain sentences and short paragraphs.
- At most one blank line between topics.
- Colon key-value clusters and comma/semicolon lists for maps.
- Brace expansions and path shorthand when unambiguous:
  `src/agent/{turn,plans,tools}`, `pnpm check|test|typecheck`.
- Real paths, symbols, commands, flag names, error strings.
- Parenthetical metadata: `Copper ledger actor omniagent`.
- Arrows for flows: `browser → proxy → sessions → turn/run`.
- "Never/always" only for true invariants; no soft padding.

Compression moves (apply aggressively):

- Strip markdown chrome first.
- Factor shared prefixes once (`front/apps/vercel-site/...` then relative tails).
- Merge duplicates across sections.
- Replace examples that only restate a rule with the rule.
- Delete generic SD advice ("write clean code", "test thoroughly") unless the
  repo defines a concrete mechanism.
- Prefer one dense line over a section.

Target length: as short as completeness allows. A focused package file may be
~30-80 lines dense prose; a multi-repo product guide might be ~15-40 short
paragraphs. If cutting would drop an invariant, keep the invariant.

## Writing procedure

1. Research (above). Take brief notes keyed by inventory topics.
2. Draft dense prose directly — do not draft long markdown then "clean later".
3. Pass for product naming consistency (user-facing vs internal).
4. Pass for actionability: every sentence should change where an agent looks,
   what it runs, or what it must not violate.
5. Pass for density (Density rules + techniques below).
6. Write the file to the target path.
7. Report: path; approx word count; top sources used; any open uncertainties.

When rewriting an existing AGENTS.md: preserve every true invariant; delete only
redundancy, chrome, and generics; add missing product/routing/command truth.

When both a human README and AGENTS.md exist: README stays human-oriented;
AGENTS.md does not duplicate onboarding narrative — it encodes operator
constraints and routing.

## Density techniques (quick catalog)

Strip formatting tokens. Collapse lists/tables to inline prose. Factor common
path prefixes. Use `a|b|c` for alternative commands. Use `{a,b}` for sibling
dirs. Replace "It is important to note that X" with "X". Replace multi-sentence
hedges with the constraint. Keep one verify recipe per lane, not per file type.
Point to nested AGENTS.md instead of copying them. End with a Sources line of
paths, not a bibliography.

## Quality bar

Done when an agent new to the scope can:

- name the product correctly in user-facing terms
- pick the owning repo/package for a typical feature
- find the primary flow entrypoints without wandering
- run the correct focused verify command
- avoid the top footguns (env, flags, publish, auth)

Fail if the file is mostly generic process, mostly markdown outline, invents
commands/paths, or duplicates nested AGENTS.md at length.

## Example shape (illustrative, not a template to copy verbatim)

```text
<Product> feature work. User-facing name <X>; internal <Y> is service/repo only.

Product: <one-line job>. Surfaces: <a, b, c>. Enablement: <gates>.

Repos/packages: <name (role), ...>. Nearest AGENTS.md wins.

Flow: <entry → ... → sink> (key files). Invariants: <auth/billing/plan/flag>.

Start: <wf/template/worktree/env>. Route by symptom: <task → path; ...>.

Commands (cwd <path>): <...>. Footgun: <...>. Verify: <lane → cmd>.

Layout: <dir map>. Conventions: <only local rules>. Workflow: <branch/lifecycle/publish>.

Sources: <paths>.
```

Do not depend on any external sample AGENTS.md path. If a strong local example
exists in the target tree or user-provided context, you may mirror its density;
otherwise follow this skill alone.

## Placement

- Single repo: `<repo>/AGENTS.md`
- Package/app in monorepo: `<package>/AGENTS.md` for local invariants; root file
  only for root-wide routing
- Multi-repo workspace guide: workspace root or user-chosen project path; point
  at per-repo AGENTS.md as authoritative for local rules
- Machine-global rules: not this skill — use `agent-config` and shared AGENTS
  templates

After creating a durable shared skill or global instruction change, use
`agent-config` / chezmoi. This skill writes project/workspace AGENTS.md files
directly in the target tree.
