# Attachment Index

## Data

- `data/ue58-ubt-evidence.md` — accepted local UE 5.8, UBT, and legacy-runner evidence for Task 1.1.
- `data/workflow-evaluation.md` — accepted retained timing and workflow evaluation for Task 4.2.

## Knowledges

- `knowledges/unreal-runner-migration.md` — promoted to `hardness/unreal/knowledges/runner-boundaries.md` after implementation, integration, actual read-only, and performance verification.

## Implementation

- No material implementation issue is registered.

## Replans

- `replans/replan-20260903-182347-serialize-same-engine-ubt.md` — applied historical decision; its blanket installed-build serialization was superseded by the controlled lane below.
- `replans/replan-20260903-194511-restore-parallel-build-observability.md` — applied; restores policy-owned installed-project build concurrency and adds active-build progress while retaining serialization for uncertain UBT work.

## Lifecycle

- Change state: all Task DAG nodes completed before archive. The final complete Unreal fixture gate passed in 57.484 seconds and the concurrent Hardness Quick gate passed 7/7 in 98.928 seconds. Formal public-operation sampling fell from 81.967 to 17.595 seconds after replacing repeated single-key configuration validation with one fresh guarded batch read; no safety fact is cached. Actual main-workspace status, source target scan, process observation, suite plan, and build PlanOnly passed 5/5 without starting UE/UBT or invoking root `Tools`.
- Review state: no Review was requested; no Review record exists.
- Spec sync: `hardness/core` and `hardness/workspace` named requirements were reconciled; `hardness/unreal` and its CLI-owned manifest were added; all five current specs pass strict validation.
- Knowledge disposition: `unreal-runner-migration.md` was promoted to current `hardness/unreal/knowledges/runner-boundaries.md` and indexed there.
- Closure state: archived as `completed` on 2026-09-03; doctor, strict change/spec validation, exact Integration, complete Unreal, and Hardness Quick gates passed with no unresolved implementation issue.
