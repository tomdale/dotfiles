# Stack AI-generated code in pull requests

Source: [Stack AI-generated code in pull requests](https://docs.github.com/en/copilot/tutorials/stack-ai-generated-code-in-pull-requests)

Public preview. Pattern for agents (Copilot CLI and others) producing high
volume code without dumping one unreviewable PR.

## Install for agents

```shell
gh extension install github/gh-stack
gh skill install github/gh-stack   # official gh-stack agent skill
```

Needs `gh` ≥ 2.90.0, Git ≥ 2.20, auth, push access. Copilot CLI optional if the
human runs `gh stack` manually.

## 1. Design the stack before generating code

Own the shape; do not let the model invent an unbounded monolith.

- One coherent, independently reviewable change per layer
- If a layer needs a long review essay, split it
- Order by **dependency** (foundation → dependents)

Example auth feature:

1. Data model + migration  
2. CRUD endpoints  
3. JWT middleware / guards  
4. Integration + unit tests  

Example prompts:

- `Propose a layered approach to add user authentication. Order by dependency; each layer independently reviewable.`
- `Review my planned layers; flag any too large or that depend on a branch above them.`

## 2. Build the bottom layer first

Mistakes at the bottom poison every branch above.

- Tell the agent you are building a **stacked** PR; build **only** layer 1
- Or: `gh stack init BRANCH-NAME-1` then implement
- **Human-review the foundation** before stacking more

Prompts:

- `Start the pr-stack and build only the first layer: user data model and migration.`
- `Confirm this branch contains only the data model and migration.`

## 3. Stack each new layer on top

```shell
gh stack add BRANCH-NAME-NEXT   # if driving CLI yourself
# agent should add branch + commit per layer
gh stack submit                 # when ready for PRs
```

- New branch per layer; keep diffs self-contained
- If a layer balloons, split into two layers
- Titles/descriptions describe **this** layer only

Prompts:

- `Add the next layer on a new branch: CRUD endpoints using the user model below.`
- `This branch is large. Suggest a split into two independently reviewable layers.`

## 4. Author self-review before teammate review

Small layers make self-review cheap. Run tests/linters/scanning per branch.
See also GitHub’s “Review AI-generated code” tutorial.

## 5. Request reviews (often bottom-up)

- Tight coupling → review from bottom so fixes land before upper review
- Different owners → parallel review per layer

## 6. Iterate on feedback

Fix on the **owning** branch; rebase dependents.

```shell
gh stack checkout BRANCH-NAME
# fix + commit
gh stack rebase --upstack
gh stack push
```

Prompts:

- `Reviewer: auth service ignores expired tokens. Fix on BRANCH-NAME and test.`
- `After rebase, check endpoints branch still matches the fix; flag follow-ups.`

## 7. Merge bottom-up

- Merge one layer or a contiguous prefix; GitHub retargets the next PR to trunk
- Stacks do **not** support auto-merge; merge queue is OK
- Whole feature is done when the top layer lands

## Agent operating rules (checklist)

1. Plan layers + order before coding  
2. One branch / one PR per layer  
3. Never put dependent code below its dependency  
4. Never “quick fix” a lower concern on a higher branch  
5. After lower commits: rebase upstack + push  
6. Prefer `gh stack submit --auto` only in non-interactive automation; humans
   usually want real titles/bodies  
7. Do not extend a fully merged stack — start a new one  

## Related

- Concepts: [concepts.md](concepts.md)
- Review ops: [reviewing.md](reviewing.md)
- Managing: [managing.md](managing.md)
