# refactor-as-audit-remove-with-angelscript-haze

> Record-only refresh on 2026-06-26. This OpenSpec records the planned removal of `WITH_ANGELSCRIPT_HAZE`; no source implementation is part of this update.
>
> Previous sequencing note: the old prerequisite `refactor-as-remove-autoaccessor` has already been archived at `openspec/changes/archive/2026-05-22-refactor-as-remove-autoaccessor`, so the future implementation is no longer blocked by that dependency. Category A still needs focused regression coverage because it changes script-visible method names.

## Why

`WITH_ANGELSCRIPT_HAZE` is a compile-time fork between the original Hazelight internal path and this repository's generic Unreal Engine plugin path. The macro is defaulted to `0` in `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`, and the current `*.Build.cs` / `*.Target.cs` scan shows no build-layer definition that enables it.

The active product direction is the generic UE plugin. Keeping the inactive Haze path imposes ongoing cost:

- Readers must reason about dead conditional branches in runtime, bindings, preprocessor, class generation, debugger, and tests.
- Hazelight-only RPC syntax (`NetFunction`, `CrumbFunction`, `DevFunction`) remains represented in descriptors, precompiled data, and dumps even though the fork should use standard UE RPC specifiers (`Server`, `Client`, `NetMulticast`, validation, reliability).
- The debug protocol still exposes `bUseAngelscriptHaze`, a field that always reports false in current builds.
- One active binding area carries non-UE method names (`GetActorInstigator`, `GetActorInstigatorController`) only because of historical auto-accessor collision concerns that no longer apply after `refactor-as-remove-autoaccessor`.

Current audit snapshot: `rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source` reports 24 macro-reference lines across 17 source/test files. Details are recorded in `audit.md`.

## What Changes

- **Remove macro definition**: delete the default macro block from `AngelscriptEngine.h`.
- **Delete Haze-only RPC path**: remove preprocessor support for `NetFunction`, `CrumbFunction`, and `DevFunction`; remove generated-UFunction handling for `FUNC_NetFunction`, `FUNC_DevFunction`, `HazeFunctionFlags`, and `HAZEFUNC_CrumbFunction`; remove descriptor/precompiled/dump fields that only existed to persist that path.
- **Preserve standard UE RPC path**: keep `Server`, `Client`, `NetMulticast`, validation, reliability, and UHT-tool generic RPC handling.
- **Strip non-Haze wrappers**: remove decorative `#if !WITH_ANGELSCRIPT_HAZE` wrappers around normal UE bindings while keeping the wrapped bindings.
- **Standardize behavior**: keep the current non-Haze behavior for `AS_ENSURE`, cooked exception handling, async trace namespace selection, and debugger protocol shape.
- **Restore UE-original actor names**: rename script bindings from `GetActorInstigator` / `GetActorInstigatorController` to `GetInstigator` / `GetInstigatorController`, then migrate active script/test call sites.
- **Update documentation**: update active docs that describe the Haze branch. Historical OpenSpec/archive records may still mention the removed macro as history.

## Capabilities

### New Capabilities

- `as-haze-macro-removal`: codifies the post-removal state: macro absent from active source, Hazelight-only RPC syntax absent, debugger Haze field absent, and UE-original actor names restored.

### Modified Capabilities

- None. No existing spec declares `WITH_ANGELSCRIPT_HAZE` as a supported behavior contract.

## Impact

- **Submodule source**: affects `Plugins/Angelscript/Source/AngelscriptRuntime` and `Plugins/Angelscript/Source/AngelscriptTest`.
- **Runtime areas**: preprocessor, class generator, binding registration, StaticJIT precompiled metadata, runtime state dump, debug server protocol, and selected binding modules.
- **Tests**: debugger database test drops the `bUseAngelscriptHaze` mirror assertion; actor tests migrate to UE-original instigator method names; networking tests verify standard UE RPC remains intact.
- **Documentation**: active docs under `Documents/` and root agent guides are updated when implementation lands. OpenSpec artifacts remain as historical records.
- **Repo shape**: source changes live in the `Plugins/Angelscript` submodule; OpenSpec docs live in the parent repository. Future implementation is a dual-repo change: submodule commit first, then parent gitlink plus OpenSpec/doc updates.
