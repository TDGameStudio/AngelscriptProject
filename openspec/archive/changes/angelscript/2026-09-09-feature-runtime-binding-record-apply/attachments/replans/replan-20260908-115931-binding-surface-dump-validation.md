---
replan_id: replan-20260908-115931-binding-surface-dump-validation
status: applied
source: user
source_ref: "2026-09-08 user: inspect which classes AS will contain, like previous AS dump; add Python validation scripts; explicitly replan"
scope: "Intended AS surface dump, global/snapshot ownership and offline validation"
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 3f4319e460510810db11bc657c963059265d58f11e21a6ae3156b54fdc024a01
result_tasks_sha256: 111a6e2ffbfd60f5ddb394bdb2ed9ca14d220f4a62bdd5cc412d1aaf8c06a325
created_at: 2026-09-08T11:59:31.025807+00:00
resume_task: "6.2"
---

## Trigger and Evidence

The user requested Store/Seal tests, full Binds information and global storage verification, then clarified the deliverable as a pre-installation AS class/surface dump with Python validators and explicitly requested replan. Existing 1.2-1.4 verify primitives; 8.2 verifies full integration without a standalone exporter/validator. Adding both products to 8.2 would invalidate its integration-only boundary.

Read-only evidence: Store owns Types/indices, Providers, Policy and ReflectedSnapshot; globals are Namespace members. Native callable, auxiliary and GlobalAddress are borrowed addresses; reflection pins UObject identities. Collection stores callbacks while Capture creates a fresh Store. Provider metadata currently has eligibility but lacks exclusion reasons. Dump/AngelscriptDumpCommand.cpp requires a global initialized Engine; StateDump Classes/RegisteredTypes/BindRegistrations query active modules/adapters. Their columns guide the new dump, but their engine dependency is unsuitable.

## Decision

Add 1.5 ownership/global tests, 1.6 intended-AS JSON/CSV and 1.7 independent stdlib Python validation/diff. Distinguish intended AS, reflection-only and excluded identities, and collection-only versus full scope. Extend 6.2 policy cases and 8.2 real-manifest validation/comparison/installation accounting. No product implementation in this replan.

## Impact

Candidate DAG was checked in memory before writes: 45 unique graph/body nodes, valid references, no self/cyclic edges, nine completed nodes preserved with no pending prerequisites. 1.5 consumes two-owner/reflection lifetime; 1.6 produces 1.7's schema; 8.2 consumes the validated tools. Proposal/spec/design and concrete test/CLI contracts change together.

## Old Task Disposition

1.2-1.4: needs_followup in 1.5/1.6 for added ownership/inspection acceptance; preserve checked states and original proof. 6.2 and 8.2: preserved pending with acceptance clarified. All other tasks preserved; none unchecked or cancelled.

## Diff Snapshot

- Before status: ?? openspec/changes/angelscript/feature-runtime-binding-record-apply/; affected Git diff stat empty because Change is untracked.
- Task +1.5, +1.6, +1.7; Task ~6.2, ~8.2; Task -none.
- Edge +(1.5 requires 1.4, 3.3, 6.2), +(1.6 requires 1.5), +(1.7 requires 1.6), +(8.2 requires 1.7); Edge -none.
- Artifacts ~proposal, ~runtime delta spec, ~design, ~tasks, ~INDEX; add this record and data/replans/replan-20260908-115931-binding-surface-dump-validation-before.patch.

## Preserved Work

Preserve all implementation source, existing proof, current 6.2 policy RED, full Runtime migration, dormant startup and the separate Harness issue. No builds, Automation, agents or Git publication occur.

## References and Result

Strict active Change validation follows. Implementation remains paused; resume 6.2 when authorized, then prioritize the ready ownership/dump/Python chain for later family migration. Exporter/scripts/tests are planned, not implemented or proven. This applied record is immutable.
