# refactor-as-audit-remove-with-angelscript-haze

> Implementation update on 2026-07-06. This OpenSpec now records the applied removal of `WITH_ANGELSCRIPT_HAZE` from active Angelscript source.
>
> Sequencing note: the old prerequisite `refactor-as-remove-autoaccessor` has already been archived at `openspec/changes/archive/2026-05-22-refactor-as-remove-autoaccessor`; the actor instigator rename was implemented with focused regression coverage.

## Why

`WITH_ANGELSCRIPT_HAZE` was a compile-time fork between the original Hazelight internal path and this repository's generic Unreal Engine plugin path. The macro previously defaulted to `0` in `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`, and the `*.Build.cs` / `*.Target.cs` scan showed no build-layer definition that enabled it.

The active product direction is the generic UE plugin. Keeping the inactive Haze path imposed ongoing cost:

- Readers had to reason about dead conditional branches in runtime, bindings, preprocessor, class generation, debugger, and tests.
- Hazelight-only RPC syntax (`NetFunction`, `CrumbFunction`, `DevFunction`) remained represented in descriptors, precompiled data, and dumps even though the fork uses standard UE RPC specifiers (`Server`, `Client`, `NetMulticast`, validation, reliability).
- The debug protocol exposed `bUseAngelscriptHaze`, a field that always reported false in current builds.
- One active binding area carried non-UE method names (`GetActorInstigator`, `GetActorInstigatorController`) only because of historical auto-accessor collision concerns that no longer apply after `refactor-as-remove-autoaccessor`.

Initial audit snapshot: `rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source` reported 24 macro-reference lines across 17 source/test files. The implementation status and verification evidence are recorded in `audit.md`.

## What Changes

- **Remove macro definition**: deleted the default macro block from `AngelscriptEngine.h`.
- **Delete Haze-only RPC path**: removed preprocessor support for `NetFunction`, `CrumbFunction`, and `DevFunction`; removed generated-UFunction handling for `FUNC_NetFunction`, `FUNC_DevFunction`, `HazeFunctionFlags`, and `HAZEFUNC_CrumbFunction`; removed descriptor/precompiled/dump fields that only existed to persist that path.
- **Preserve standard UE RPC path**: kept `Server`, `Client`, `NetMulticast`, validation, reliability, and UHT-tool generic RPC handling.
- **Strip non-Haze wrappers**: removed decorative `#if !WITH_ANGELSCRIPT_HAZE` wrappers around normal UE bindings while keeping the wrapped bindings.
- **Standardize behavior**: kept the current non-Haze behavior for `AS_ENSURE`, cooked exception handling, async trace namespace selection, and debugger protocol shape.
- **Restore UE-original actor names**: renamed script bindings from `GetActorInstigator` / `GetActorInstigatorController` to `GetInstigator` / `GetInstigatorController`, then migrated active script/test call sites and added negative coverage for the old names.
- **Update documentation**: updated active docs that describe the Haze branch. Historical OpenSpec/archive records may still mention the removed macro as history.

## Capabilities

### New Capabilities

- `as-haze-macro-removal`: codifies the post-removal state: macro absent from active source, Hazelight-only RPC syntax absent, debugger Haze field absent, and UE-original actor names restored.

### Modified Capabilities

- None. No existing spec declares `WITH_ANGELSCRIPT_HAZE` as a supported behavior contract.

## Impact

- **Submodule source**: affects `Plugins/Angelscript/Source/AngelscriptRuntime` and `Plugins/Angelscript/Source/AngelscriptTest`.
- **Runtime areas**: preprocessor, class generator, binding registration, StaticJIT precompiled metadata, runtime state dump, debug server protocol, and selected binding modules.
- **Tests**: debugger database test drops the `bUseAngelscriptHaze` mirror assertion; actor tests migrate to UE-original instigator method names; networking tests verify standard UE RPC remains intact.
- **Documentation**: active docs under `Documents/` and root agent guides were updated. OpenSpec artifacts remain as historical records.
- **Repo shape**: source changes live in the `Plugins/Angelscript` submodule; OpenSpec docs live in the parent repository. This is a dual-repo change: submodule commit first, then parent gitlink plus OpenSpec/doc updates when committing.
