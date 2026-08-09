# Parallel wave: Bind_FCollisionQueryParams

Migrate only the collision-query-parameter bind family to the direct callback architecture.

## Exclusive edit scope

- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams.cpp`
- new `Bind_FCollisionQueryParams_Functions.h`
- new `Bind_FCollisionQueryParams_Functions.cpp`
- this task's report: `collision-query-params-report.md`

Do not edit core APIs, tests, OpenSpec matrices/tasks, other bind families, or build files. Other agents are editing the shared checkout concurrently.

## Requirements

- Replace all 12 legacy providers/order expressions with semantic file-static `FAngelscriptBind` callbacks receiving explicit `FAngelscriptBinds&`.
- Split enum/value-class declarations into `TypeDeclarations`, adapter registration into `TypeInfrastructure`, and constructors/properties/methods/namespaced globals into `ManualBindings`.
- Preserve the old ordering intent by local callback composition/merging. No dependency API, priority, numeric name, or escape hatch.
- Route type registration through `Binds.RegisterTypeForTarget`, class creation/lookup through `ValueClassForTarget`/`ExistingClassForTarget`, enums through `EnumForTarget`, namespaces through `FNamespace(Binds.GetTargetEngine(), ...)`, and globals through explicit-target facades.
- Move all project-owned constructor/conversion helper lambdas and ignored-id array wrappers into one `FAngelscriptFCollisionQueryParamsBinds` owner declared in the companion header and defined in the companion cpp. Keep Unreal member/free pointers and `METHOD*`/`FUNC*` expressions direct.
- Convert PreviousBind no-discard writes to fluent `.NoDiscard()` on the exact constructor result.
- Preserve all declaration strings, properties, global constants, type adapters, semantics, and every existing native/trivial term exactly: the baseline inventory records 40 native/trivial terms. Do not add native/trivial classification to former ordinary lambdas.
- Note and preserve the existing constructor address signature/cast behavior unless compilation proves a correction is required; report any such issue instead of broadening scope.
- Chain formatting must match `Bind_FVector.cpp`: short chains on one line; trait chains registration line followed by aligned `.NoDiscard()` / native traits.
- Run only static/file-local checks (`rg`, counts, diff/self-review). Do not run UBT or UE automation; the root agent owns serialized validation.

## Evidence already established

The root agent added and ran a red source-layout test. It currently fails because the direct provider/companion family does not exist.

## Report

Write `collision-query-params-report.md` beside this brief with: status, files changed, mapping of the 12 legacy providers to phases/callbacks, native/trivial before/after count, static checks run, and concerns. Return only the status and a compact summary to the root agent. Do not commit.
