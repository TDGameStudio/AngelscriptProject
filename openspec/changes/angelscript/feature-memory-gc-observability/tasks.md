---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

## Creation boundary

This is a research and feature-record delivery. The workflow requires tasks.md; the sole current node completes detailed planning. It is not an implementation-ready product DAG. No collector, allocator, runtime or profiling output has been changed, and no product test has been executed here. Design and scenario artifacts remain absent until this node is continued through the corresponding OpenSpec lifecycle Skills.

Read tasks.md and attachments/INDEX.md first, then proposal.md and the two indexed matrices. Consume the existing VM/GC owners without changing their semantics or task state. Maintain dormant legacy startup; replacement instrumentation must not depend on publishing an ambient legacy engine.

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
```

## 1. Complete observation contracts and the implementation DAG

- [ ] 1.1 Produce the memory/GC observation design, durable scenarios and exact proving cards — verify: `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/feature-memory-gc-observability', '--type', 'change', '--strict', '--json')`
  > Files: `openspec/changes/angelscript/feature-memory-gc-observability/design.md`, `openspec/changes/angelscript/feature-memory-gc-observability/specs/angelscript/runtime/memory-observability/spec.md`, `openspec/changes/angelscript/feature-memory-gc-observability/tasks.md`, `openspec/changes/angelscript/feature-memory-gc-observability/attachments/INDEX.md`, `openspec/changes/angelscript/feature-memory-gc-observability/attachments/data/planning-contracts.md`

  Produce executable observation boundaries and task-specific proof contracts, not product implementation. The strict command proves record structure; completing this node additionally requires all outcomes below to have exact owners, supported APIs, bounded paths and real verification selectors. Do not mark it complete solely because the record validates.

  1. Finish a current allocation/free inventory for maintained source/frontend, shared types/metadata, executable/binding images, VM objects, contexts/stacks, collector storage and runtime support. Record covered gateways, owner versus consumer, capacity/used metrics, allocator basis, worker attribution and actual dormant/absent families. Define the smallest required replacement-safe snapshot APIs and observer lifecycle; keep observation independent of Engine creation for detached metadata.
  2. Specify counters and exporter types, units, consistency/epoch rules, fixed category/tag names, coverage flags and the policy for per-owner detail. Define exact successful alloc/free/realloc/rollback arithmetic, logical pool acquire/return versus backing release, shared-image attribution and retirement. Resolve generic SDK scope shadowing and cross-thread final frees without installing a second global allocator. A default probe must not allocate, recursively trace itself or retain its measured objects.
  3. Specify public and automatic GC insertion points, skipped/reentrant attempt semantics, phase work units, cycle/step IDs and actual known-owner frees. Separate UE-GC timing/schema work and AS cycle GC; exclude all collector-policy changes. Choose supported UE 5.8 feature gates and a concrete low-overhead publication cadence, plus an explicitly bounded detailed mode. Set the overhead acceptance method/threshold before measurements.
  4. Author durable scenarios and bounded implementation cards for the metric core, allocation/owner coverage, GC observations, UE output adapters, and actual capture/overhead verification. Keep test preparation, grouped behavioral RED, implementation and GREEN in each feature group. Select exact replacement Automation identities and Harness commands after reading the test guide and verification policy; reuse VMGC as controls rather than claim its old results prove new instrumentation. No normal completion requires an unsolicited Review.
  5. Define actual .utrace verification: prove native allocation/free records, LLM category, semantic counters and CPU phases in real providers with matching symbols where necessary. Distinguish headless data checks from stat-panel display checks. Reuse the verified ExtraArguments route, unique workspace trace paths and bounded runs. Record source/binary identity, actual RunId, trace provenance and a trimmed result; do not promote PlanOnly to execution evidence.
  6. Map every proposal acceptance condition to a new permanent product node with exact owned files and consumed/produced APIs. Preserve this node's ID and complete it only after the design, scenarios, coverage map and full executable DAG are present. Validate and index the planning-contract summary.

  Required independently derived cases for future cards:

  - Covered 64+128-byte allocation reports 192 live requested bytes and two blocks; freeing 64 reports 128/one; final release returns to baseline. Failed allocation/reallocation does not corrupt successful-event counts. The reallocation convention is specified before the test.
  - Four 64-byte pool slots reserve 256 bytes; logical return reduces occupancy, not reservation. Reuse creates no new backing allocation. Only actual trimming changes backing counters.
  - One image shared by two consumers counts once; storage remains when one consumer retires and returns after the final owner releases. Worker allocation and cross-thread free retain attribution; observations do not prolong lifetime.
  - A rooted two-node cycle is retained, then both nodes finalize once after root release. Full/incremental modes reach the same destruction set. Automatic phase work is visible, and a skipped/reentrant request does not falsely increment completed cycles or scanned work.
  - Ordinary release and GC release distinguish logical object death, payload released and physical backing release. No UObject or referenced asset is counted again as AS heap; unavailable host probes are marked unavailable.
  - One coherent known snapshot produces equal values/units in all enabled exporters. Disabled Stats/LLM/Trace combinations do not invent zeros, create an engine or change object/collector behavior.
  - A distinctive actual native allocation appears once in Memory Insights with the intended LLM category, including a worker allocation; no duplicate manual FMemory event exists. The captured session also contains the corresponding counters and collector phase spans.
  - Paired disabled/basic/detailed workloads report repeatable overhead and diagnostic storage against a predeclared threshold, with raw artifacts kept in ignored Saved and a concise provenance summary indexed here.
