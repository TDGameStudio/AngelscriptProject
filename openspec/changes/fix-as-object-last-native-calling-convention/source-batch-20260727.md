# Coherent Source Batch — 2026-07-27

## Scope written

- Expanded raw SDK object-last coverage across default, scalar, wide,
  multi-argument, copy, destructor, external-method, value-return-storage,
  native-exception, cleanup, context-reuse, and engine-isolation behavior.
- Added a stable invalid caller/convention registration rejection.
- Added compatible source-save to separately registered destination-load native
  call identity coverage.
- Added a generated StaticJIT AOT object-last constructor entry with explicit
  sentinels and generated-entry counters.
- Added a raw SDK regression for no-count implicit handles passed by value to a
  generic callback.
- Repaired generic preparation/cleanup so no-count implicit handles do not
  dispatch a nonexistent release behavior, while counted implicit handles keep
  their ownership cleanup.

## New crash evidence folded into the batch

Artifact:
`Saved/Tests/as-native-sdk-comprehensive-all_05_Actor/20260727_205217_945_aafa102c`

Observed stack:

```text
asCScriptEngine::CallObjectMethod (as_scriptengine.cpp:4013)
asCContext::CallGeneric (as_context.cpp:5391)
GetAttachedActors
```

Root cause: `PrepareSystemFunctionGeneric` classified
`asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE` as a transferred counted
owner. `CallGeneric` then attempted to call its absent release behavior.

## Verification boundary

Per the requested batching policy, this pass did not build or run Automation.
No task requiring fresh build/runtime evidence is marked complete.

## Static checks completed

- `git -C Plugins/Angelscript diff --check`: passed; only line-ending
  advisories were emitted.
- `git diff --check`: passed; only line-ending advisories were emitted.
- `openspec validate fix-as-object-last-native-calling-convention --strict`:
  passed.
- `openspec/changes/test-as-native-sdk-comprehensive-coverage/scripts/AuditInlineAsFormatting.ps1`:
  `305` raw sources, `305`
  conforming sources, `0` violations. Evidence:
  `../test-as-native-sdk-comprehensive-coverage/audits/inline-source-baseline.csv`.
- `openspec/changes/test-as-native-sdk-comprehensive-coverage/scripts/ValidatePlanningRecords.ps1`:
  `0` violations. Evidence:
  `../test-as-native-sdk-comprehensive-coverage/audits/planning-record-violations.csv`.

The generic preparation predicate was checked directly:

- `asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE` does not enter
  `cleanArgs`, so it acquires no release ownership; its normal argument slot is
  discarded when the VM retires the call stack rather than explicitly cleared
  by ownership cleanup.
- A counted implicit handle does enter `cleanArgs` and retains `clean.op == 0`
  release cleanup.
- For entries that do reach `CallGeneric` cleanup, release is invoked only when
  the behavior ID is nonzero and the moved slot is cleared in either case. This
  is a defensive fallback for stale or malformed no-count cleanup metadata, not
  the normal no-count path and not a change to counted-handle ownership.

## Deferred runtime evidence

- Compile the complete source batch.
- Regenerate and compile the StaticJIT AOT fixture outputs.
- Run the focused object-last, generic no-count, save/load, and StaticJIT tests.
- Run the native SDK prefix and confirm the previously crashing Actor segment.
- Confirm counted implicit-handle cleanup with fresh runtime evidence.
