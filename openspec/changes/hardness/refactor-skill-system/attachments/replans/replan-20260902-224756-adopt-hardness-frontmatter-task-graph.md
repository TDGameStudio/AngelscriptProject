---
replan_id: replan-20260902-224756-adopt-hardness-frontmatter-task-graph
status: applied
source: user
source_ref: "User direction to place the DAG in tasks.md YAML frontmatter, recognize it through Hardness, and naturally sort task presentation"
scope: hardness-task-graph-authority-and-openspec-input-contract
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: e7047637324e591e53c28ce2c3a93311a1c89b208927e8ba862276b8944657c0
result_tasks_sha256: d338576f04ef58d1cadac00fdd0dae98de280f88b47eab39497ab0ddf13d8a6a
created_at: 2026-09-02T22:47:56.1746423+08:00
resume_task: "1.5"
---

# Replan — Adopt the Hardness frontmatter Task Graph

## Trigger and Evidence

The user rejected per-task `After:` as the current authoring surface and clarified three boundaries: the exact DAG belongs at the start of `tasks.md` in Skill-style YAML frontmatter, Hardness must recognize and schedule it, and task presentation should use natural stable-ID order instead of being rearranged into topological order.

Read-only comparison showed that stages/waves lose cross-branch dependencies, string arrow syntax requires an ambiguous custom grammar, and edge objects cannot explicitly account for roots without a second node list. A versioned incoming adjacency map expresses every current edge exactly, maps directly to existing `TaskNode.after/ready`, and lets the Graph key set equal the Markdown checkbox ID set. The current OpenSpec 0.7.4 parser cannot read that format, so migrating the active file before a compatible release would make the change unverifiable.

## Decision

- Make YAML `task_graph.version: 1` plus `depends_on` the single current dependency source; keep checkbox state, description, `Files:`, verification, and steps in the Markdown body.
- Make Hardness the discovery/scheduling entry through one static `task.status` route. Reuse OpenSpec as the deterministic parser primitive instead of duplicating YAML or execution state in PowerShell.
- Use dual-read/single-write compatibility: current/new records write frontmatter, historical `After:`-only records remain readable, and mixed syntax fails closed.
- Quote every `X.Y` ID, explicitly write roots as `[]`, require exact Graph/body node parity, and preserve stable `after/ready` JSON.
- Sort Graph keys and Markdown task blocks naturally by numeric ID components. Ordering is presentation only and never creates an edge.
- Preserve immutable 0.7.4 and add Task `1.6` to publish the new contract as 0.8.0. Add Task `2.6` for the Hardness route, Skill contract, and active-record migration.
- Keep the active file in the validated legacy dialect until Task 1.6 passes RED/GREEN and publishes the compatible parser; Task 2.6 then performs the one-time active migration.

## Impact

The DAG grows from 14 to 16 nodes while retaining six completed nodes and Ready `1.5`/`2.5`. Task `1.3` moves behind new Task `1.6`; Task `2.4` also waits for new Task `2.6`; and Task `3.1` waits for the Hardness contract rather than the superseded completed protocol node alone. Existing task blocks are presentation-sorted without renumbering, reopening, or changing completed evidence.

Proposal, design, delta spec, tasks, INDEX, and one talk are updated. Rust source/package work belongs to Task 1.6; Hardness route and active migration work belongs to Task 2.6. Existing Replans, reviews, archives, and their historical task hashes remain byte-unchanged.

## Old Task Disposition

| Task | Previous state | Disposition | Reason |
|---|---|---|---|
| 1.1, 1.2, 1.4, 2.1, 2.2, 2.3 | done | preserved unchanged | Historical completion, IDs, and evidence remain valid |
| 1.5, 2.5 | pending/Ready | preserved Ready | 0.7.4 closure and reviewed UE repair remain the independent current frontier |
| 1.6 | absent | added | Publish the compatible frontmatter parser and immutable 0.8.0 package |
| 2.6 | absent | added | Expose Task Graph recognition through Hardness and migrate the current record |
| 1.3 | pending | dependency changed to 1.6 | OpenSpec review must inspect the actual 0.8.0 distributed contract |
| 2.4 | pending | adds predecessor 2.6 | Harness review must include the Hardness Task Graph entry and migration |
| 3.1 | pending | replaces predecessor 2.2 with 2.6 | Package/Skill integration must follow the implemented Hardness contract |
| 3.2, 4.1, 4.2 | pending | preserved unchanged | Their downstream boundaries remain valid |

## Diff Snapshot

```text
affected path/status: 95 worktree entries at trigger; OpenSpec current records plus future Tools/openspec and Hardness task-route surfaces
tasks: +1.6 +2.6; ~1.3 ~2.4 ~3.1; 16 nodes and six completed checkboxes
edges: +1.5->1.6 +1.6->1.3 +1.6->2.6 +2.2->2.6 +2.6->2.4 +2.6->3.1; -1.5->1.3 -2.2->3.1
presentation: numeric natural order for task blocks; no edge is inferred from position
artifacts: ~proposal ~design ~delta-spec ~tasks ~INDEX +talk +replan
```

## Preserved Work

All immutable OpenSpec 0.7.0–0.7.4 tags, release evidence, containment fixes, deterministic-link proof, existing Review/Replan history, completed task states, Harness/Workspace/UE implementation, and the user's no-automatic-integration boundary remain intact. No historical attachment or archive is migrated. No patch sidecar is needed.

## References and Result

- `attachments/talks/talk-20260902-224756-hardness-frontmatter-task-graph.md`
- `attachments/replans/replan-20260902-221551-preserve-073-and-enforce-reproducible-074.md`
- `attachments/replans/replan-20260902-220447-repair-goal-and-unreal-review-boundaries.md`
- Candidate validation passed strictly with the preserved 0.7.4 legacy reader before this record was finalized.
- The DAG advances from 14/6/8 to 16/6/10; Ready remains `1.5`/`2.5`, with zero task issues.
- The tasks hash advances from `e7047637324e591e53c28ce2c3a93311a1c89b208927e8ba862276b8944657c0` to `d338576f04ef58d1cadac00fdd0dae98de280f88b47eab39497ab0ddf13d8a6a`.
