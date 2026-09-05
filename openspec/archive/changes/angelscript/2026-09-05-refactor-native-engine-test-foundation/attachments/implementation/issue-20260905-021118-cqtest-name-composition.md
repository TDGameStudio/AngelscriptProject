---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-021118-cqtest-name-composition
status: resolved
source: verification
source_ref: run-5d9a19e2e1564b8faae607bdd388fdb1
affected_tasks: ["1.1", "1.2"]
created_at: 2026-09-05T02:11:18+08:00
resolved_at: 2026-09-05T02:21:22+08:00
resolution_ref: run-6963d59f5b874c3396cc7fc0b9be079f
---

# CQTest inserts its C++ class name into the public Automation path

## Symptom

The first real Foundation prefix run passed both gate scenarios, but registered them as `Angelscript.UnitTest.NativeEngine.Foundation.FNativeEngineTestFoundation.<Scenario>`. The accepted requirement allows only `Angelscript.UnitTest.NativeEngine.<Area>.<Scenario>`.

## Investigation Log

1. Build run `7f8a14e018154327b370bde6d943c47d` proved the explicit CQTest dependency and replacement/legacy compile gates.
2. Fast test run `5d9a19e2e1564b8faae607bdd388fdb1` discovered two tests and retained their complete paths in the Automation report and Unreal log.
3. UE 5.8 `CQTest.h` passes `_TestDir` and `#_ClassName` to `TTestRunner`; test discovery then appends each method name. The extra class component is therefore framework behavior, not a Harness display artifact.

## Root Cause

The original design treated the `TEST_CLASS_WITH_FLAGS` directory argument as the complete area prefix and assumed only `TEST_METHOD` would be appended. CQTest actually composes directory, C++ class identifier, and method identifier.

## Disposition

Task `1.2` was replanned without changing the durable public-name requirement. The implementation now uses `Angelscript.UnitTest.NativeEngine` as the CQTest directory, `Foundation` as the C++ class identifier, and each method identifier as the scenario token. The final report proves that no extra class component remains.

## Evidence

### Failure Evidence (RED)

- Run: `5d9a19e2e1564b8faae607bdd388fdb1`.
- Report: `Saved/Harness/Unreal/Runs/5d9a19e2e1564b8faae607bdd388fdb1/AutomationReport/index.json`.
- Observed path: `Angelscript.UnitTest.NativeEngine.Foundation.FNativeEngineTestFoundation.LegacyGateRemainsDisabled`.

### Resolution Evidence (GREEN)

- Fresh build: `96b26c7ff9944f7bb37faf222ddc3ee2`.
- Exact Fast test: `6963d59f5b874c3396cc7fc0b9be079f`.
- Result: four of four tests passed with zero warnings and zero errors; every report path matched `Angelscript.UnitTest.NativeEngine.Foundation.<Scenario>`.

### What This Proves

- CQTest's class identifier is externally observable and must be intentionally selected as the area token.
- A passing prefix run alone is insufficient unless the report paths are checked against the durable identity contract.

### What This Does Not Prove

- It does not invalidate CQTest as the replacement assertion library.
- It does not require changing the stable public prefix, restoring legacy macros, or adding a custom Harness route.

## Links

- `design.md`, Public identity decision.
- `specs/angelscript/testing/baseline/spec.md`, NativeEngine CQTest identity Scenario.
- `attachments/replans/replan-20260905-021228-cqtest-public-name-composition.md`.
