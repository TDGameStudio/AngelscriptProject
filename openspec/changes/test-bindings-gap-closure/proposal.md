## Why

The `Bindings` test surface still contains a cluster of silent skips and placeholder coverage gaps across geometry, platform, string, delegate, memory, and component-adjacent binding files. Those gaps make it hard to tell whether a case is intentionally unsupported, blocked by a headless harness limit, or simply missing coverage, so the suite stops being a reliable contract for the binding layer.

## What Changes

- Replace the covered `TODO(binding-gap)` and `#if 0 // Disabled: binding gap` cases with explicit executable assertions or explicit negative contract tests that name the missing binding or environment constraint.
- Restore coverage for the most visible binding clusters already identified by the audit: geometry/math, platform/path/profiler, and string/delegate/memory/component-adjacent surfaces.
- Keep the existing `Angelscript.TestModule.Bindings.*` discovery path and the current file ownership model intact.
- Update the test catalog and test guide so the restored binding coverage surface and any remaining explicit limitations are visible to future contributors.

## Capabilities

### New Capabilities
- `bindings-gap-coverage`: Covers the restoration of binding coverage for the currently skipped or placeholder binding tests.

### Modified Capabilities
- None.

## Impact

- Targeted test files under `Plugins/Angelscript/Source/AngelscriptTest/Bindings/`, especially `AngelscriptBox3fBindingsTests.cpp`, `AngelscriptSphere3fBindingsTests.cpp`, `AngelscriptCpuProfilerBindingsTests.cpp`, `AngelscriptFileAndDelegateBindingsTests.cpp`, `AngelscriptFStringBindingsTests.cpp`, `AngelscriptMemoryReaderBindingsTests.cpp`, `AngelscriptMeshComponentBindingsTests.cpp`, `AngelscriptPathsBindingsTests.cpp`, and `AngelscriptPlatformMiscBindingsTests.cpp`.
- Runtime binding files that may need coverage-aligned additions or overloads, including the relevant `Bind_FApp.cpp`, `Bind_FBox.cpp`, `Bind_FBox3f.cpp`, `Bind_FCpuProfilerTraceScoped.cpp`, `Bind_FGenericPlatformMisc.cpp`, `Bind_FMemoryReader.cpp`, `Bind_FPlane.cpp`, `Bind_Delegates.cpp`, `Bind_FString.cpp`, and `Bind_UProjectileMovementComponent.cpp` surfaces.
- `Documents/Guides/TestCatalog.md` and `Documents/Guides/Test.md` for the coverage map and verification entry points.
