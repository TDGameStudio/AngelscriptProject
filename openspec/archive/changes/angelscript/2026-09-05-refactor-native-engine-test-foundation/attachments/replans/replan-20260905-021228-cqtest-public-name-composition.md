---
replan_id: replan-20260905-021228-cqtest-public-name-composition
status: applied
source: verification
source_ref: run-5d9a19e2e1564b8faae607bdd388fdb1
scope: CQTest public Automation name composition
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: 9f85760947054ee8f9bbfadbb31dbb5a8d88b16464fd55327ed7ef3845bf18fa
result_tasks_sha256: bdec893ae5c40b8b21a7637fe76f8afbf2923ef1b771446102d0257b84320dbf
created_at: 2026-09-05T02:12:28+08:00
resume_task: 1.2
---

# Replan: CQTest public name composition

## Trigger and Evidence

Fast run `5d9a19e2e1564b8faae607bdd388fdb1` proved that CQTest registers `<TestDir>.<ClassName>.<MethodName>`. The current class produced an extra `FNativeEngineTestFoundation` component, contradicting the accepted exact public identity.

## Decision

Keep `Angelscript.UnitTest.NativeEngine.<Area>.<Scenario>` unchanged. Map CQTest's directory to `Angelscript.UnitTest.NativeEngine`, its class identifier to the exact area token, and each method identifier to the scenario token.

## Impact

The delta specification gains precise framework mapping detail, the design records the actual CQTest composition, and ready Task `1.2` owns the implementation repair and exact-path assertions. No production code, macro policy, Change dependency, or final test prefix changes.

## Old Task Disposition

Task `1.1` remains complete because its CQTest dependency, replacement gate, legacy gate, and editor build evidence are valid. Its first discovery run becomes RED evidence for public identity. Task `1.2` remains incomplete and absorbs the correction before support-fixture GREEN.

## Diff Snapshot

- Affected status: parent `Plugins/Angelscript` gitlink dirty; Change directory untracked; plugin `AngelscriptTest.Build.cs` modified; Foundation test untracked.
- Plugin diff stat: `AngelscriptTest.Build.cs | 8 insertions`; the untracked test is not represented by Git diff stat.
- Task changes: `~1.2` context and acceptance detail; no tasks added or removed.
- Edge changes: none.
- Artifact changes: `~design`, `~delta spec`, `~tasks`, `~INDEX`; `+implementation issue`; `+applied replan`.

## Preserved Work

The expected missing-CQTest RED, replacement-only dependency change, compile-gate assertions, successful editor build, and two passing CQTest bodies remain valid evidence. Only the externally visible path composition requires repair.

## References and Result

- Issue: `implementation/issue-20260905-021118-cqtest-name-composition.md`.
- UE 5.8 source: `Engine/Source/Developer/CQTest/Public/CQTest.h`.
- Result: resume Task `1.2` with the same local DAG and exact Foundation prefix.
