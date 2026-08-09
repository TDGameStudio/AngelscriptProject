# Collision query params migration report

## Status

Implemented. This worker performed only file-local static checks; UBT builds and UE Automation were intentionally not run because serialized validation belongs to the root agent.

## Files changed

- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams_Functions.h` (new)
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams_Functions.cpp` (new)

## Legacy provider mapping

| Legacy provider | Direct phase and local callback |
| --- | --- |
| `Bind_QueryMobilityType` | `TypeDeclarations` → `BindCollisionQueryParamsTypeDeclarations` |
| `Bind_FCollisionQueryParams_Early` | `TypeDeclarations` / `TypeInfrastructure` → family callbacks; `ManualBindings` → `BindFCollisionQueryParamsEarly` |
| `Bind_FCollisionQueryParams_Late` | `ManualBindings` → `BindFCollisionQueryParamsLate` |
| `Bind_FCollisionEnabledMask_Early` | `TypeDeclarations` / `TypeInfrastructure` → family callbacks; `ManualBindings` → `BindFCollisionEnabledMaskEarly` |
| `Bind_FComponentQueryParams_Early` | `TypeDeclarations` / `TypeInfrastructure` → family callbacks; `ManualBindings` → `BindFComponentQueryParamsEarly` |
| `Bind_FComponentQueryParams_Late` | `ManualBindings` → `BindFComponentQueryParamsLate` |
| `Bind_FCollisionResponseParams_Early` | `TypeDeclarations` / `TypeInfrastructure` → family callbacks; `ManualBindings` → `BindFCollisionResponseParamsEarly` |
| `Bind_FCollisionResponseParams_Late` | `ManualBindings` → `BindFCollisionResponseParamsLate` (kept last in local composition, preserving the former `Late + 1` intent) |
| `Bind_FCollisionObjectQueryParams_InitType` | `TypeDeclarations` → `BindCollisionQueryParamsTypeDeclarations` |
| `Bind_FCollisionObjectQueryParams_Early` | `TypeDeclarations` / `TypeInfrastructure` → family callbacks; `ManualBindings` → `BindFCollisionObjectQueryParamsEarly` |
| `Bind_FCollisionObjectQueryParams_Late` | `ManualBindings` → `BindFCollisionObjectQueryParamsLate` |
| `Bind_FCollisionResponseContainer` | `ManualBindings` → `BindFCollisionResponseContainer` |

The three registered file-static callbacks are `BindCollisionQueryParamsTypeDeclarations`, `BindCollisionQueryParamsTypeInfrastructure`, and `BindCollisionQueryParamsManualBindings`. The manual callback composes the retained early, late, and former `Late + 1` surfaces in their original family order without dependency or priority metadata.

## Native/trivial parity

- `METHOD*_TRIVIAL` / `FUNC*_TRIVIAL` terms: **40 before → 40 after**.
- `SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR` terms: **16 before → 16 after**.
- No former ordinary lambda was given a native/trivial classification.

## Static checks run

- Compared AS-visible constructor, method, property, and global declaration strings against `HEAD`: **90 before → 90 after**, with no multiset difference.
- Compared native/trivial classification terms and constructor native terms against `HEAD`: exact parity above.
- Confirmed the companion owner has **20 declarations and 20 definitions**, with no unmatched method names.
- Confirmed all six enum enumerators remain present.
- Checked the migrated bind for legacy `FAngelscriptBinds::FBind`, `EOrder::`, `SetPreviousBindNoDiscard`, and lambda syntax; none remain.
- Confirmed direct target-scoped calls are used for enum/type/class/global registration, and all namespaces are constructed with `Binds.GetTargetEngine()`.
- Ran `git diff --check` for the three plugin files: no whitespace errors.

## Concerns

- The existing `FCollisionObjectQueryParams(ECollisionChannel)` constructor adapter deliberately retains the original `FCollisionQueryParams* Address` parameter type while placement-constructing `FCollisionObjectQueryParams`. This unusual address signature/cast behavior was preserved exactly as required; no compilation-based correction was attempted in this scope.
- UE/UBT compilation and Automation validation remain pending root-agent execution.

## Compile-blocker follow-up

- Root-agent UBT and reviewer evidence identified ambiguous C++ helper addresses at the four ignored-ID array registrations. The owner originally overloaded `GetIgnoredComponents` and `GetIgnoredActors` for both `FCollisionQueryParams` and `FComponentQueryParams`; the bind template cannot choose an overload from the runtime AS declaration string.
- Renamed the four owner helpers and their declaration/definition/registration references to `GetCollisionQueryParamsIgnoredComponents`, `GetCollisionQueryParamsIgnoredActors`, `GetComponentQueryParamsIgnoredComponents`, and `GetComponentQueryParamsIgnoredActors`.
- Static follow-up confirmed all four semantic names have exactly one header declaration, one companion definition, and one registration reference; no owner overload named `GetIgnoredComponents` or `GetIgnoredActors` remains, and no cast was introduced.
- Rechecked AS declaration and classification parity after the fix: declaration strings remain **90 before → 90 after**, native/trivial terms remain **40 before → 40 after**, and constructor native terms remain **16 before → 16 after**.
- No UBT or UE Automation rerun was performed by this worker; root-agent serialized validation remains authoritative.
