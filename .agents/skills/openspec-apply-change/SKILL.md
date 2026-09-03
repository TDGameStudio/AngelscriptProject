---
name: openspec-apply-change
description: Implement ready nodes from an active OpenSpec tasks.md with TDD, exact verification, evidence, and Hardness-controlled review/replan. Use when an approved change is implementation-ready or must resume.
---

# Apply a Change

1. Select the explicit Change or resolve the canonical active Change in the selected workspace, then call `Invoke-Hardness -Command task.status -Context $context -Parameters @{ Change = '<id>' }` before implementation mutation. An accepted exploration handoff is not an active Change or Ready Task DAG.
2. Read proposal, relevant specs/design, `tasks.md`, and `attachments/INDEX.md`. Load only attachments linked by the current task. Before editing, check the node's goal, `Files`, prerequisites, linked context, exact verification, and design assumptions for local coherence.
3. Select nodes whose OpenSpec-derived `ready` field is true. Parallelize only nodes with disjoint Files, artifacts, and resource leases; never infer an edge from display order or parse the YAML again.
4. For each node, follow TDD for behavior changes, run its exact verify command, then change `[ ]` to `[x]`. No passing evidence means no completed checkbox.
5. If investigation crosses the [material implementation issue](../openspec/references/implementation-issues.md) threshold, record one root-cause lifecycle and update INDEX in the same edit. Keep ordinary RED/GREEN cycles and immediate corrections out of attachments. Record a non-obvious decision in talk/current design and reusable knowledge only when it passes the admission test.
6. Run strict validation and report completed/total plus the next Ready nodes.

```text
task.status -> read current truth -> choose Ready node -> RED -> GREEN -> verify -> check task
```

Do not invoke deep pre-change Explore from a Ready task. Use lightweight task-local investigation and fix in-scope technical failures autonomously, including during Codex `/goal` continuation. A finding is triaged before replan; use `openspec-update-change` only when the plan boundary is invalid. Codex `/goal` is not a repository mode or workspace selector. Stop only for a real authorization boundary, not ordinary ambiguity, test failure, or review feedback. Never weaken specified behavior to make a task pass.
