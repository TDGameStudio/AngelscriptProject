## Why

The plugin already moved the maintained AngelScript SDK from `Source/AngelscriptRuntime/ThirdParty/angelscript/source/` to `Source/AngelscriptRuntime/angelscript/` (flattened; no nested `source/`). That tree is first-party reconstruction source, not an unmodified vendor drop.

Live include roots, current specs, capability knowledges, and fork-strategy guidance still name the deleted ThirdParty organization. Unreal Build Tool and later tasks will keep targeting a directory that is gone, so the Editor target cannot compile the moved tree.

This Change retargets those live contracts. It does not move files again and does not change SDK behavior.

## What Changes

- Point `AngelscriptRuntime.Build.cs` public include roots at `ModuleDirectory/angelscript` and drop `ThirdParty/angelscript`.
- Update current spec path language in `angelscript/language/ast/core` and `angelscript/language/frontend/reflection-dependencies`, plus matching current knowledges that still cite the old tree as the source location.
- Retarget live ForkStrategy guidance, plugin license attribution, and the parent README architecture row that still present ThirdParty as the current kernel location.
- List other active Changes whose Files still name `ThirdParty/angelscript`; those Changes replan themselves.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/language/ast/core`: reconstructed language headers are organized under `Source/AngelscriptRuntime/angelscript/frontend/`. Directory organization remains independent of C++ scope.
- `angelscript/language/frontend/reflection-dependencies`: fork-internal frontend leaves MAY live under `Source/AngelscriptRuntime/angelscript/frontend/`. C++ naming inside `BEGIN_AS_NAMESPACE` is unchanged.

## Impact

Plugin submodule: `AngelscriptRuntime.Build.cs`, `LICENSE.md`. Parent repository: this OpenSpec record, current specs and knowledges, `Documents/Guides/AngelscriptForkStrategy.md`, `Documents/Guides/ASBindFreeCompletenessVerification.md`, and the parent `README.md` architecture/license path language. `Source/AngelscriptProject` stays untouched.

`angelscript/refactor-standalone-lsp-layout` owns `AngelscriptLSP/` CMake. It depends on the new SDK path string and does not own Runtime.Build.cs.

Active Changes that still list `ThirdParty/angelscript` in Files must replan; this Change does not edit their `tasks.md`:

- `angelscript/feature-frontend-diagnostics-tooling`
- `angelscript/refactor-sdk-drop-native-gc`
- `angelscript/refactor-bindings-two-stage-pipeline`

## Boundaries

- Do not restore `ThirdParty/angelscript` or a nested `source/` folder.
- Do not move `Core/angelscript.h`.
- Do not change `BEGIN_AS_NAMESPACE`, public C API, bytecode, or Automation identities.
- Do not rewrite immutable `openspec/archive/` records or historical `Documents/Knowledges/ZH/` dumps.
- Do not own `AngelscriptLSP/` CMake or `Source/AngelscriptTest/TestCode/` / `TestFramework/`.

## Acceptance

After this Change:

1. `AngelscriptRuntime.Build.cs` adds `ModuleDirectory/angelscript` and contains no `ThirdParty/angelscript`.
2. Incremental Harness `ue.build` of `AngelscriptProjectEditor` (Win64, Development) succeeds against the moved tree.
3. Current specs and listed knowledges describe `Source/AngelscriptRuntime/angelscript/` as the organization; remaining `ThirdParty/angelscript` hits in live specs/guides are historical or out of this Change.
4. The consumer-replan attachment lists the active Changes above and does not rewrite their Task DAGs.
