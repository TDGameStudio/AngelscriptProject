---
name: openspec-apply-change
description: Implement ready nodes from an active OpenSpec tasks.md with TDD, exact verification, evidence, and Hardness-controlled Review/Replan. Use when an approved change is implementation-ready or must resume.
---

# Apply a Change

1. Select the explicit/Goal change and call `Invoke-Hardness -Command task.status -Context $context -Parameters @{ Change = '<id>' }`.
2. Read proposal, relevant specs/design, `tasks.md`, and `attachments/INDEX.md`. Load only attachments linked by the current task.
3. Select nodes whose OpenSpec-derived `ready` field is true. Parallelize only nodes with disjoint Files, artifacts, and resource leases; never infer an edge from display order or parse the YAML again.
4. For each node, follow TDD for behavior changes, run its exact verify command, then change `[ ]` to `[x]`. No passing evidence means no completed checkbox.
5. Record a material diagnosis in implementation, a non-obvious decision in talk/current design, and reusable knowledge only when it passes the admission test. Update INDEX in the same edit.
6. Run strict validation and report completed/total plus the next Ready nodes.

```text
task.status -> read current truth -> choose Ready node -> RED -> GREEN -> verify -> check task
```

In Goal mode, investigate and fix in-scope technical failures autonomously. A finding is triaged before Replan; use `openspec-update-change` only when the plan boundary is invalid. Stop only for a real authorization boundary, not ordinary ambiguity, test failure, or review feedback. Never weaken specified behavior to make a task pass.
