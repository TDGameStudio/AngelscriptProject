---
replan_id: replan-20260903-172102-complete-live-entry-and-spec-sync-scope
status: applied
source: verification
source_ref: "authoring subagent report followed by coordinator scan of live entrypoints and current hardness specs"
scope: Task 2.1 live README coverage and Task 3.3 complete durable sync coverage
base_commit: 2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27
base_tasks_sha256: 115ee98e5df2d01912c28b3a361a8b4432fbdb66defdf48b9a3cd80c53f0017d
result_tasks_sha256: 47c00cd91004ab3df7d81e8c6626e9ddd8b37fb47ea00e38e85f95aed9f8e0eb
created_at: 2026-09-03T17:21:02+08:00
resume_task: "2.1"
---

# Complete Live Entrypoint and Spec-Sync Coverage

## Trigger and Evidence

The authoring subagent's post-edit scan found a broken `New-HardnessContext -Mode Current` example in `openspec/README.md`. A coordinator scan across live project entrypoints then found the same removed API in root `README.md`. The scan also showed that Task 3.3's durable sync list omitted `hardness/workspace/spec.yaml` and `core/knowledges/change-registration-checkpoint.md`, both of which still encode the retired repository-mode model.

## Decision

Add both live README files to Task 2.1 and add the affected spec metadata and capability-knowledge files to Task 3.3. Keep current delta specs, current spec synchronization, and live user guidance consistent. Archived evidence and active Change text that explicitly explains the prior state remain untouched.

## Impact

- Task 2.1 gains two command-entry documentation surfaces.
- Task 3.3 gains the metadata and knowledge surfaces required for a complete durable sync.
- No task, dependency edge, verification command, implementation route, executable, or submodule boundary changes.

## Old Task Disposition

- `1.1`, `1.2`, `1.3`: preserved complete.
- `2.1`: preserved pending; two live README paths added before gate completion.
- `3.1`, `3.2`: preserved pending.
- `3.3`: preserved pending; durable sync path list completed before execution.
- `4.1`: preserved pending.

## Diff Snapshot

```text
base commit: 2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27
live entry evidence: openspec/README.md, README.md
durable sync evidence: openspec/specs/hardness/workspace/spec.yaml, openspec/specs/hardness/core/knowledges/change-registration-checkpoint.md

Task ~: 2.1 Files adds two README entrypoints
Task ~: 3.3 Files adds complete spec metadata/knowledge sync surfaces
Edge +/-: none
Artifact +: this Replan
Artifact ~: tasks.md, attachments/INDEX.md
```

## Preserved Work

- Every completed implementation and focused gate.
- Both prior applied Replans and all current Task 2.1 authoring work.
- Archived records, `_ZH` content, deferred Unreal implementation, OpenSpec source/package identity, and unrelated dirty workspace data.

## References and Result

- Live-surface audit excludes archived Changes because their historical wording is immutable evidence.
- Result Task DAG SHA-256: `47c00cd91004ab3df7d81e8c6626e9ddd8b37fb47ea00e38e85f95aed9f8e0eb`.
- Resume at Task `2.1`.
