---
replan_id: replan-20260910-083124-vm-performance-preservation
status: applied
source: user
source_ref: "User requires no performance impact from the ownership refactor; source inspection of linked VM operands"
scope: "VM hot-path preservation and before/after execution acceptance"
base_commit: 0f0cf23ee78e563bf93dcf20b43a55381948273d
base_tasks_sha256: 56e9b64378fc93cd8a2a4efa92dedd63934419400fe5b1ccb06df27efb688794
result_tasks_sha256: 1c15a37ec78abbb3a50d11413e87edee01462c61e2023b2e02239edcffc891df
created_at: 2026-09-10T08:31:24+00:00
resume_task: 1.1
---

# Preserve VM execution performance

## Trigger and Evidence

The user explicitly requires no performance impact and asks whether bytecode TypeIds are pointers. Inspection confirms mixed representations: linker lines 43-48 resolve symbolic slots; 171-211 emit type pointers for ALLOC/FREE/REFCPY/OBJTYPE; 154-160 emit Cast's numeric TypeId. Context lines 2896/3031/3121/3225 consume pointers, 3232 pushes a DWORD for TYPEID, and 3826-3858 resolves Cast through GetObjectTypeFromTypeId. ScriptEngine lines 5350-5390 take the Engine registration mutex and find the ID map. CALL at Context:2152 uses GetScriptFunction (ScriptEngine:1571), which also takes the Engine registration mutex. Existing executable snapshots retain metadata; VM objects already retain Type plus Engine. These are source observations, not measured performance results.

The prior cost plan measured setup and queries and validated call results, but did not time execution as a non-regression gate. The user constraint therefore invalidates the prior performance acceptance coverage.

| SDK source (under maintained ThirdParty/angelscript/source) | SHA-256 |
| --- | --- |
| `as_context.cpp` | `6178e01e459d47e20f7c16d4ebf970a87d2d8b10fe6bd30dc99a691aa407373e` |
| `as_bytecode_linker.cpp` | `2c001da9cb9f4c60e6ce071b7438168230b6fa312cb62f39237824ebb469b299` |
| `as_scriptengine.cpp` | `ece591599a60b9cc835eaac10a51d2b2b57d0bb3f9d850ee57e1ee381b88640b` |
| `as_vm_object.cpp` | `487c766edde8d420f4161401c8b15aaca738741c62960c8b26d244c02227540c` |
| `as_execution_snapshot.cpp` | `5e902e2e580e4b00a876e4b12601ee9488407857a44cea5aa5c123cc2f5adb53` |

## Decision

Preserve direct linked operands and keep global registration outside VM dispatch. Do not add global Registry traffic, weak locking or metadata reference churn for already retained executable operands. Audit Cast, CALL and per-Engine sidecars as well as direct type operations. Public global IDs must not become sparse execution-array indices. Keep existing retirement, object-lifetime and foreign-Engine safety checks. Measure actual VM execution and matched setup/query phases separately; repeatable attributable slowdown blocks completion, with no invented tolerance or unmeasured zero-impact claim.

## Impact

Update proposal, bytecode delta, design and task acceptance for 1.1/4.1/5.2. No product implementation, Harness repair, broad optimization project or opcode rewrite is authorized by this planning edit. No new benchmark pass is claimed. The existing binding handoff consumes the strengthened producer contract without task changes.

## Old Task Disposition

All 13 IDs, DAG edges, unchecked states and exact proving commands are unchanged. Candidate frontmatter, checklists and command blocks were compared before writes. Task 1.1 establishes the execution baseline before migration; 4.1 proves hot-path structure and lifetime; 5.2 owns the matched performance gate. Tests remain under their existing selectors.

## Diff Snapshot

Affected Change was already untracked: ?? openspec/changes/angelscript/feature-types-explicit-ownership/. No tracked Change diff stat exists. Artifacts ~ proposal/design/bytecode delta/tasks/INDEX; + this replan. Tasks ~ 1.1/4.1/5.2; task and edge +/- none. The prior closed plan review remains historical evidence of its exact snapshot and is superseded for the changed deliverable without rewriting its verdict/findings.

## Preserved Work

Ownership, Registry API, reference contracts, atomic registration, numeric bounds, shared preparation, Engine isolation and GC safety remain. Existing snapshot contents and digests remain unchanged. Harness issue and evolution diagnostics are still deferred.

## References and Result

See current design's VM execution performance section and tasks. Resume 1.1. Planning strict validation follows application; runtime/performance verification is pending. No automatic new formal Review is started.
