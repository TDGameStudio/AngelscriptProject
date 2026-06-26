# Design: refactor-as-audit-remove-with-angelscript-haze

## Context

`WITH_ANGELSCRIPT_HAZE` currently defaults to `0` and is not enabled by any scanned `*.Build.cs` or `*.Target.cs` file. The macro exists only as an inactive compatibility fork for Hazelight-internal behavior.

The current source scan records:

- 24 macro-reference lines in `Plugins/Angelscript/Source`.
- 20 conditional-compilation blocks.
- 2 non-conditional debug/test references to the macro.
- 1 macro definition block in `AngelscriptEngine.h` (2 lines).

The implementation should remove the inactive Haze fork while preserving the current non-Haze runtime behavior. The archived `refactor-as-remove-autoaccessor` change has removed the earlier blocker for restoring `AActor.GetInstigator()`-style names, but that rename still needs targeted test coverage because it changes script-visible API names.

## Goals / Non-Goals

**Goals:**

- Remove every `WITH_ANGELSCRIPT_HAZE` reference from active source files.
- Remove Hazelight-only UFUNCTION specifiers and their runtime/precompiled/dump metadata path.
- Preserve standard UE RPC behavior and tests.
- Remove debugger protocol exposure of `bUseAngelscriptHaze`.
- Restore UE-original actor instigator binding names after migrating active call sites.
- Leave historical OpenSpec/archive records intact as history.

**Non-Goals:**

- Do not add new RPC features or redesign replication.
- Do not remove generic UE/UHT RPC helpers such as methods named `IsRpcNetFunction`; those describe standard UE network UFunctions, not the Hazelight-only `FUNC_NetFunction` path.
- Do not clean up unrelated Hazelight attribution, license text, reference docs, or historical reports.
- Do not implement this change as part of the record-only OpenSpec refresh.

## Decisions

- **D1 - Use existing OpenSpec change.** `refactor-as-audit-remove-with-angelscript-haze` already exists and matches the requested scope, so the record is refreshed instead of creating a duplicate change.

- **D2 - Treat `refactor-as-remove-autoaccessor` as satisfied.** The prerequisite exists under `openspec/changes/archive/2026-05-22-refactor-as-remove-autoaccessor`. Future implementation can proceed, but Category A still runs late because it changes script-visible names and requires focused migration.

- **D3 - Remove descriptor metadata, not only macro guards.** `bNetFunction` and `bDevFunction` are still persisted through `FAngelscriptFunctionDesc`, StaticJIT precompiled data, and state dump output. Removing only the guarded generator/preprocessor branches would leave dead schema fields behind. The implementation must remove the descriptor/precompiled/dump metadata together with the Haze-only specifier path.

- **D4 - Keep standard UE RPC untouched.** Any code that handles `FUNC_Net`, `FUNC_NetServer`, `FUNC_NetClient`, `FUNC_NetMulticast`, validation, reliability, or UHT-tool generic RPC detection remains in scope only for verification, not deletion.

- **D5 - Keep current non-Haze behavior.** Where the macro selected between behaviors, the future implementation keeps the behavior currently active with the macro at `0`: `ensureMsgf` for `AS_ENSURE`, non-Haze cooked exception behavior, `System::` async trace namespace, and no debugger Haze flag.

- **D6 - Restrict zero-match gates to active surfaces.** OpenSpec records and archive notes may mention `WITH_ANGELSCRIPT_HAZE` as historical context. Final verification should require zero matches in active source/config/script/docs surfaces, while allowing the current OpenSpec record to remain readable.

## Implementation Categories

- **Category A - Script-visible actor rename.** `Bind_AActor.cpp` currently exposes `GetActorInstigator` and `GetActorInstigatorController`. These should become `GetInstigator` and `GetInstigatorController`, with tests migrated.

- **Category B - Haze-only RPC deletion.** Remove preprocessor specifiers, function descriptor fields, StaticJIT precompiled fields, dump columns, class generator Haze flags, and BlueprintType `FUNC_NetFunction` branches.

- **Category C - Namespace branch.** `Bind_WorldCollision.cpp` keeps the current non-Haze `System::` async trace namespace and removes the `AsyncTrace::` alternative branch.

- **Category D - Behavioral branch.** Remove Haze-side `AS_ENSURE`, cooked exception, debug setting, and debugger test branches.

- **Category E - Decorative non-Haze wrappers.** Remove normal UE binding wrappers guarded by `#if !WITH_ANGELSCRIPT_HAZE`; keep the wrapped code unchanged.

## Risks / Trade-offs

- **Risk: actor rename misses inline AS call sites.** Mitigation: sweep `Plugins/Angelscript/Source`, `Script`, and active docs for `GetActorInstigator` / `GetActorInstigatorController`, then run actor tests.

- **Risk: generic RPC code is mistaken for Haze-only RPC code.** Mitigation: only remove Hazelight-only specifier/flag names (`NetFunction`, `CrumbFunction`, `DevFunction`, `FUNC_NetFunction`, `FUNC_DevFunction`, `HazeFunctionFlags`, `HAZEFUNC_CrumbFunction`) and explicitly leave standard UE RPC helpers intact.

- **Risk: StaticJIT precompiled format changes.** Mitigation: remove the dead Haze fields in a single phase, rebuild, and run networking plus relevant StaticJIT/precompiled coverage if available.

- **Risk: debugger protocol clients expected `bUseAngelscriptHaze`.** Mitigation: field was always false in current builds. Removing it aligns the protocol with supported behavior; debugger database tests verify the new shape.

## Migration Plan

1. Strip Category E wrappers first to reduce macro footprint without changing behavior.
2. Delete Category B Haze-only RPC syntax/metadata and verify standard networking tests.
3. Resolve Category C/D behavior and debugger protocol cleanup.
4. Restore Category A actor names and migrate active script/test callers.
5. Delete the macro definition, update active docs, and validate OpenSpec plus build/test gates.

## Open Questions

- None for record scope. Implementation details should be rechecked against the then-current source before editing because line numbers may drift.
