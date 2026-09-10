---
name: openspec-apply-change
description: Implement ready nodes from an active OpenSpec tasks.md with TDD, exact verification, evidence, and Harness-controlled review/replan. Use when an approved change is implementation-ready or must resume.
---

# Apply a Change

Read the task as one complete owned Markdown card: short title, concrete context/interfaces and cases, implementation order, Files and Verification. Execute the direct Verification command with its stated conditions; do not extract commands from titles or examples. Keep completion evidence inside the owning task or its linked attachment. An unsupported old-format diagnostic requires a separately authorized record migration, not a fallback parser.

1. Select the explicit Change or resolve the canonical active Change in the selected workspace, then call `Invoke-Harness -Command task.status -Context $context -Parameters @{ Change = '<id>' }` before implementation mutation. An accepted exploration handoff is not an active Change or Ready Task DAG.
2. Read proposal, relevant specs/design, `tasks.md`, and `attachments/INDEX.md`. Load only attachments linked by the current task. Before editing, check the node's goal, `Files`, prerequisites, linked context, exact verification, and design assumptions for local coherence. Apply the [Task authoring preflight](../openspec/references/tasks.md): require a bounded outcome, concrete cases/expected RED, interface handoffs and completion proof. Replan a demonstrated oversized or unprovable task boundary before implementation; do not keep appending independent work to its tail.
3. Select nodes whose OpenSpec-derived `ready` field is true. Parallelize only nodes with disjoint Files, artifacts, and resource leases; never infer an edge from display order or parse the YAML again.
4. Select and expand task checks through the Harness [impact-scoped verification policy](../harness/references/verification.md), beginning with the smallest direct proof. For behavior changes, prepare one bounded feature group's cases, observe their expected RED together, implement the group, then verify GREEN. Run the exact proving command or a documented shared run that maps its cases to the same source/binary identity, then change `[ ]` to `[x]`. No passing evidence means no completed checkbox; an aggregate count or successful dispatch is not case-level proof.
5. If investigation crosses the [material implementation issue](../openspec/references/implementation-issues.md) threshold, record one root-cause lifecycle and update INDEX in the same edit. Keep ordinary RED/GREEN cycles and immediate corrections out of attachments. Record a non-obvious decision in talk/current design and reusable knowledge only when it passes the admission test.
6. Run strict validation and report completed/total plus the next Ready nodes.

```text
task.status -> read current truth -> choose Ready feature group -> grouped RED -> implement -> grouped GREEN -> check proven task
```

Do not invoke deep pre-change Explore from a Ready task. Use lightweight task-local investigation and fix in-scope technical failures autonomously, including during Codex `/goal` continuation. A finding is triaged before replan; use `openspec-update-change` only when the plan boundary is invalid. Codex `/goal` is not a repository mode or workspace selector. Stop only for a real authorization boundary, not ordinary ambiguity, test failure, or review feedback. Never weaken specified behavior to make a task pass.
