---
replan_id: replan-20260908-074025-bounded-binding-outcomes
status: applied
source: user
source_ref: "2026-09-08 user: task splitting is too coarse; followed by questions about candidate JSON and the replan record"
scope: "Replace milestone-sized tasks with independent binding outcomes and real dependency edges"
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 61c448104635bf42477f7445ba0cb0299b750b59ae762ee8f741a26630db5230
result_tasks_sha256: 33f43f4eaf94f357728d1246a9963a1023791d31d1c562275b47b8e77e2aba9b
created_at: 2026-09-08T07:40:25.956313+00:00
resume_task: "1.2"
---

## Trigger and Evidence

The user questioned whether eight tasks were too few. Authoring preflight confirms that old 2.1 combines independently acceptable declaration parsing, layout resolution, metadata installation and native linkage; old 4.1/6.1 combine many independently testable families. The inventory has 253 source declarations and 247 distinct provider names. Actual FString signatures reference TArray<FString>; FText references TArray and TMap formatting arguments, invalidating a blanket values-before-containers edge.

## Decision

Replace the eight pending milestones with 42 bounded outcomes. Each names concrete inputs/results, owned paths, an exact proving selector and grouped RED/GREEN. Keep parsing, layout, member installation and native calls separate. Extract real declaration/lifetime and template-instance foundations to satisfy cross-family signatures, then migrate full member families. Shared files constrain scheduling rather than inventing dependencies. All provider source rows receive one primary migration owner.

## Impact

Proposal scope and durable behavior remain unchanged: all Runtime bindings, serial production record/apply, explicit Engines, default dormant startup. Design clarifies the real dependency prepass. Only tasks, design, inventory and attachment navigation change. No product code has been edited and no UE tests/builds are claimed. Candidate JSON was transient authoring data under ignored Saved, not a task-state store; it is removed after the applied plan is validated.

## Old Task Disposition

| Old ID | Disposition | Replacement outcomes |
|---|---|---|
| 1.1 | superseded | 1.2–1.4 |
| 2.1 | superseded | 2.2–2.5 |
| 3.1 | superseded | 3.2–3.3 |
| 4.1 | superseded | 4.2–4.9 |
| 5.1 | superseded | 5.2–5.6 |
| 6.1 | superseded | 6.2–6.8 |
| 7.1 | superseded | 7.2–7.10 and 8.2 |
| 8.1 | superseded | 8.3–8.5 |

## Diff Snapshot

- Affected status before application: `?? openspec/changes/angelscript/feature-runtime-binding-record-apply/`; the Change is new and untracked. Its tracked diff stat is empty. Angelscript submodule has no uncommitted product changes.
- Tasks: remove eight pending milestone nodes from the active graph; add 42 new permanent IDs. No completed node or valid test evidence is discarded.
- Edges: remove the old seven-edge linear chain; add actual producer/consumer edges recorded in tasks.md. Initial Ready node is 1.2. The candidate graph has no cycles, duplicate IDs or unknown dependencies.
- Artifacts: tasks.md replaced; design.md clarifies declaration/lifetime composition; provider-inventory.md gains owner mappings; INDEX registers this record and the small unrecoverable original-task patch.

## Preserved Work

Preserve the accepted full Runtime scope, proposal, complete specification deltas, current/reference source hashes, dormant baseline, and all unrelated working-tree changes. No implementation task was marked complete. The original uncommitted tasks are recoverable from `data/replans/replan-20260908-074025-bounded-binding-outcomes-before.patch` because Git cannot recover their contents.

## References and Result

- `data/provider-inventory.md`: all 253 source rows mapped; 247 distinct names include conditional alternatives.
- `Binds/Bind_FString.cpp`: Join and ParseIntoArray declarations depend on TArray<FString>.
- `Binds/Bind_FText.cpp`: Format/Join declarations depend on format-argument arrays and maps.
- Candidate validation before tracked writes: 42 unique IDs, known dependencies, acyclic graph, one proving command and owned paths per task, exactly one primary owner per provider source row.
- Resume at 1.2 after strict OpenSpec and canonical task.status validation. Actual command results belong to the following validation output, not a retroactive test claim.
