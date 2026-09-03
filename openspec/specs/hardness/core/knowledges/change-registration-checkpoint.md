# Active Change Registration Checkpoint

## Execution boundary

For work explicitly governed by OpenSpec, a decision-complete handoff is planning input, not execution state. Before the first implementation mutation in the selected `WorkspaceRoot`:

1. Resolve one exact Git-registered `WorkspaceRoot`; repository selection never comes from a repository mode.
2. Resolve the canonical active Change through the project-local OpenSpec route in that workspace.
3. Read its current proposal, design, delta specs, and attachment index as applicable.
4. Resolve `task.status` and select a stable Ready node from the canonical Task DAG.
5. Mutate only the scope owned by that node.

The primary checkout and linked worktrees follow the same checkpoint. Codex `/goal` may continue authorized work unattended, but it neither selects a repository mode nor changes workspace, Git, integration, push, or removal authority. Deep Explore belongs only before creation of the target Change. After creation, revise invalid truth through update and an evidence-gated Hardness replan.

## Recovery when the checkpoint was missed

Preserve the working tree and actual chronology. Do not fabricate an earlier Change, discard useful in-scope work by default, or restart deep Explore after the target Change exists.

```text
detect missing registration before commit
  -> stop new implementation scope
  -> register an honest recovery Change
  -> record one material issue
  -> map the existing diff to stable Task DAG nodes
  -> validate, verify, and independently review
  -> resolve the issue and promote only the reusable rule
```

If existing evidence invalidates requirements, design, verification, a dependency edge, or a required artifact, update current truth and apply one replan before resuming. Otherwise, keep the repair within the recovered task boundary.

## Provenance

The registration recovery rule was generalized from `issue-20260903-111408-change-created-after-implementation-start` and independently approved by `review-20260903-113000-exploration-authoring-independent`. The exact-`WorkspaceRoot` clarification comes from `hardness/refactor-unified-workspace-core` and is admitted through that Change's verification and completed closure gate. Source records remain authoritative for incident chronology and fixed-snapshot evidence.
