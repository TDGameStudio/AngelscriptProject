# Misc Systems Coverage Matrix, CVar / AnimInstance

> **This matrix is the design specification header for CVar / AnimInstance tests**: each row is a concrete verifiable scenario. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, 🟡 means partially covered, and 🚫 means fork unsupported.
>
> - Test files: `CVar`(11) / `AnimInstance`(3) Tests.cpp
> - Automation prefixes: `Angelscript.TestModule.Coverage.CVar`, `...Animation.AnimInstance`
> - See `../coverage-matrix.md` for the legend.

## 1. Console Variables, CVarTests 11

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| All-type Get/Set | ✅ | `CVarGetSetAllTypes` |
| Safe access and existing variables / existing variables preserve native metadata | ✅ | `CVarSafeAccessAndExistingVariable` `CVarExistingVariablePreservesNativeMetadata` |
| Existing engine CVar smoke, preserve and restore value / render and scalability CVar preserve and restore | ✅ | `ExistingEngineCVarSmokePreservesAndRestoresValues` `ExistingEngineRenderAndScalabilityCVarsPreserveAndRestoreValues` |
| Registered CVar name matrix / common usage patterns | ✅ | `RegisteredCVarNameMatrix` `CommonCVarUsagePatterns` |
| Console command registration, arguments, unload / common string matrix dispatch | ✅ | `ConsoleCommandRegistrationArgumentsAndUnload` `ConsoleCommandCommonStringMatrixDispatch` |
| Console command execution APIs unsupported | 🚫 | `ConsoleCommandExecutionApisUnsupported` |
| Console command string construction compile boundary | 🚫 | `ConsoleCommandStringConstructionCompileBoundary` |

## 2. Animation Instance, AnimInstanceTests 3

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| UAnimInstance subclass and variable declarations | ✅ | `AnimInstanceSubclassAndVariables` |
| Query functions compile | ✅ | `AnimInstanceQueryFunctionsCompile` |
| Asset-free owner / montage / curve query runtime behavior | ✅ | `AnimInstanceQueryFunctionsExecute` |
| Runtime paths requiring real animation assets or graphs, such as state machines / animation notifies | 🚫 | Out of scope for this headless asset-free Coverage pass; add a row later if dedicated test assets are introduced |

---

## Summary

| File | Methods |
|------|------|
| CVar | 11 |
| AnimInstance | 3 |
| **Total** | **14** |

**Closed**: G1 — `AnimInstanceQueryFunctionsExecute` instantiates an AS `UAnimInstance` through a transient `USkeletalMeshComponent` outer, executes owner / montage / curve queries through reflection, and asserts asset-free state. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Animation.AnimInstance"` -> `3/3`.
