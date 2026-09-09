---
replan_id: replan-20260908-120118-sealed-store-validation
status: applied
source: user
source_ref: "2026-09-08 follow-up: also validation after Store sealing"
scope: "Explicit read-only sealed-Store validation and pre-Engine gate"
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 111a6e2ffbfd60f5ddb394bdb2ed9ca14d220f4a62bdd5cc412d1aaf8c06a325
result_tasks_sha256: c0a9f98e190ab102585d203da0e7f30dc661415f1e85efad51f3de1f76c93e02
created_at: 2026-09-08T12:01:18.972935+00:00
resume_task: "6.2"
---

## Trigger and Evidence

After the applied binding-surface-dump-validation replan the user explicitly added post-Seal validation. Current Store::Seal only checks FailureDiagnostic then sets bSealed. Immutability tests and exported JSON validation alone do not establish a direct engine-free pre-installation validation contract. Existing parser/layout/member rules supply reusable semantic checks.

## Decision

Add 1.8 ValidateSealed and a before-allocation CreateForBindings gate. Preserve read-only snapshot contents; expose deterministic failure diagnostics for inspection. 1.6 consumes this result and cannot label a merely sealed or partial surface ready. Runtime call/ABI/GC proof remains separate.

## Impact

Validated candidate in memory before writes: 46 unique body/graph nodes, nine completed nodes preserved, valid references, no self/cyclic edges and no completed-to-pending dependency. New 1.8 consumes 1.5 ownership and 2.4 semantic foundations; 1.6 now consumes 1.8.

## Old Task Disposition

1.6 preserved pending with validation-report input added. Completed recording, parsing and creation tasks need follow-up only through new 1.8; their checked state/evidence remain valid. All other nodes preserved.

## Diff Snapshot

- Status: Change remains untracked; affected Git diff stat remains empty.
- Task +1.8; ~1.6; -none.
- Edge +(1.8 requires 1.5, 2.4), +(1.6 requires 1.8); -(1.6 requires 1.5), now transitive.
- Artifacts ~runtime delta spec, ~design, ~tasks, ~INDEX; add this record and data/replans/replan-20260908-120118-sealed-store-validation-before.patch.

## Preserved Work

Preserve previous applied replan unchanged, all implementation, task proofs, current 6.2 RED and architecture-discussion pause. No C++/Python implementation or UE work occurs here.

## References and Result

Strict validation follows. Resume 6.2 only after implementation continuation; then prioritize 1.5, 1.8, 1.6, 1.7 as their prerequisites permit. Post-Seal validation is planned, not claimed implemented. This applied record is immutable.
