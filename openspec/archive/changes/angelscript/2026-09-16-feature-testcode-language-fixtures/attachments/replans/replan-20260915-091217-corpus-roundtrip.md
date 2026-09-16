---
replan_id: replan-20260915-091217-corpus-roundtrip
status: applied
source: user
source_ref: current conversation request for full handwritten-library dump and source comparison
scope: aggregate verification of the 47 handwritten containers
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: 4cb54da23fd6bb869adadf7f1e6d5728e0a3981f4ed1a7e08033a0bff4c4df67
result_tasks_sha256: f10138ce6a3d646c86770f8b4e9937ebe6d3e84ceb68673b8c35de1692ec9aa9
created_at: 2026-09-15T09:12:17.471915+00:00
resume_task: 1.1
---

## Trigger and Evidence

User explicitly requested fewer unit tests and whole-library dump/comparison. Existing catalog enumeration and exact source-byte APIs support one compiled-database dump.

## Decision

One new Automation dump method, one independent authored-clean-source comparison and two aggregate .as artifacts plus one report. Expected and actual branches cannot consume each other's output. Preserve existing framework regressions through maintenance only.

## Impact

Revise proposal, source-preservation specification, design and task 7.3 proof/deliverables. Clarify shared per-file static checks and retained task 7.1 tests. Add indexed decision evidence. Task IDs and DAG remain unchanged.

## Old Task Disposition

~ 7.3 replaces AllFilesAndVersionsAreAdmitted with DumpsAllAuthoredSources plus the Python/PowerShell comparison operation.
~ 7.1 clarifies adaptation of existing test methods only.
All 50 tasks remain pending; no completed work is invalidated.

## Diff Snapshot

Affected pre-write status: `?? openspec/changes/angelscript/feature-testcode-language-fixtures/`
Tracked pre-write diff stat: empty (this Change is untracked).
Task +0/-0/~2; edge +0/-0. Artifact updates: proposal, spec, design, tasks, INDEX, planning-validation; new talk and this record.

## Preserved Work

All 47 identities, source anchors, 624-source census, Counter replacement, private parser fixtures, scope exclusions and generator independence remain. Creation validation is historical evidence, not proof of the updated plan or implementation.

## References and Result

[Decision](../talks/talk-20260915-091217-corpus-roundtrip.md); [tasks](../../tasks.md); [design](../../design.md). Candidate identities and unchanged DAG were checked before writes. Resume source-material task 1.1; no implementation ran during replan.
