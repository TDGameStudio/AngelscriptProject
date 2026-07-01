## Context

`AngelscriptHotReloadDelegateTests.cpp` now has broad delegate reload coverage for primitive values, native structs, containers, and AS-defined structs. `HotReload/Delegate/AngelscriptHotReloadDelegateRuntimeTests.cpp` owns the heavier Blueprint/runtime scenarios. The remaining narrow gap is delegate parameter replacement for reference-like values that use different reflected property classes.

## Goals / Non-Goals

**Goals:**
- Add a focused V1 to V2 hot reload test for reference-like delegate parameters.
- Validate reflected parameter property classes for UObject, UClass, TSubclassOf, TSoftObjectPtr, and TSoftClassPtr.
- Execute the reloaded delegate path after signature replacement so the test covers real marshaling, not just metadata.

**Non-Goals:**
- Do not change runtime hot reload behavior in this change.
- Do not duplicate Blueprint/world-tick runtime cases already covered in the dedicated Delegate runtime test file.
- Do not add broad nested-container stress tests until there is a concrete failure mode or runtime cost budget.

## Decisions

- Keep parameter matrix coverage in `AngelscriptHotReloadDelegateTests.cpp` because it already owns `ReloadDelegates.Parameters`.
- Keep runtime scene coverage in `HotReload/Delegate/AngelscriptHotReloadDelegateRuntimeTests.cpp`; this change only adds a focused reference parameter matrix case.
- Use V1 baseline execution before registering `GetOnDelegateReload`, then V2 full reload with metadata and execution assertions. This preserves existing test shape and avoids counting first compile events as reload events.

## Risks / Trade-offs

- Reference-like values require more engine bindings than primitive values. Mitigation: use binding patterns already covered by `AngelscriptClassBindingsTests.cpp` and `AngelscriptObjectBindingsTests.cpp`.
- The focused test is still larger than a primitive case. Mitigation: keep it in one method with inline V1/V2 fixtures so the reload sequence remains visible.
