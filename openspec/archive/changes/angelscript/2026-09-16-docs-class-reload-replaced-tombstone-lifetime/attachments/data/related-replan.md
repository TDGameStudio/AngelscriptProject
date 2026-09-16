# Related materials for a later replaced-UClass lifetime replan

Inspected 2026-09-11. This list is intake for a later lifetime-policy Change. This Change does not edit the listed Task DAGs or plugin files.

## Code that owns the tombstone

| Path | Why a later policy must replan it |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp` | `CreateFullReloadClass` / struct / delegate: rename to `_REPLACED_N`, keep RootSet, set `NewerVersion`. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Reinstancing.cpp` | `CleanupRemovedClass` is the unroot path; `DetectAngelscriptReferences` is host GC schema. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp` | Post-FullReload: `OnClassReload`, null `ScriptTypePtr`, `ForceGarbageCollection(true)` for old instances. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.h` | `NewerVersion`, `ScriptTypePtr`, `GetMostUpToDateClass`. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass_Metadata.cpp` | `GetMostUpToDateClass` walk. |
| `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/ClassReloadHelper.cpp` | Reinstance Blueprint children and editor assets off `OnClassReload` / `OnFullReload`. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` | `SwapInModules`; Engine teardown unroots owned `UASClass`. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_linker.cpp` | `BodyConflict` refuses implicit executable replacement; host swap is still required. |

## Tests

| Path | Why |
| --- | --- |
| `TestSource/HotReload/` FullReload / class-change fixtures | Live UClass identity, CDO, Blueprint child, PIE deferral. |
| `Plugins/Angelscript/Source/AngelscriptTest/Legacy/HotReload/` | Legacy Automation around `FileChangesDetectedForReload` and compile type. |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/` ClassGenerator / HotReload if present | NewVersion identities must not be assumed to cover tombstone GC. |

A later policy Change must add an explicit case for whether `APlayer_REPLACED_N` remains reachable after reinstancing and after `ForceGarbageCollection`.

## Historical knowledge (not current specs)

| Path | Why |
| --- | --- |
| `Documents/Knowledges/ZH/Type_ClassGeneration.md` | States the `NewerVersion` chain and that old `UASClass` is not destroyed immediately. |
| `Documents/Knowledges/ZH/RT_HotReload.md` | Host FileList → CompileModules → Soft/Full → ClassReloadHelper. |
| `README.md` editor hot-reload row | Product description of Reinstance. |

Do not treat these dumps as live SHALLs. A later Change that owns lifetime may promote or replace them.

## Current specs

No current `openspec/specs/` requirement names `_REPLACED_N`, `NewerVersion`, or replaced-UClass linger. Nearby contracts that stay silent and must be revisited:

| Spec | Why |
| --- | --- |
| `openspec/specs/angelscript/runtime/startup/spec.md` | DirectoryWatcher / hot reload remain dormant under reconstruction. |
| `openspec/specs/angelscript/runtime/binding-engine/spec.md` | Creating a binding Engine does not start hot reload. |
| `openspec/specs/angelscript/runtime/bytecode/spec.md` | Linker `BodyConflict`; no implicit body replace. |

A lifetime-policy Change should add a host/class-generation requirement rather than overloading bytecode or binding-engine.

## Active Changes that must replan themselves

| Change | Why |
| --- | --- |
| `angelscript/refactor-sdk-drop-native-gc` | Keeps Unreal `CollectGarbage` during class reload; Files `ClassReloadHelper.cpp`; must not confuse tombstone linger with native AS GC. |
| `angelscript/feature-memory-gc-observability` | UObject occupancy is a host view; replaced `UASClass` generations are currently uncounted. |
| `angelscript/refactor-defaults-constructor-unification` | CDO replay and reinstancing after FullReload; tombstones still hold old CDOs until instances move. |

Not rewritten here. `angelscript/refactor-runtime-owned-sdk-layout` and `angelscript/refactor-standalone-lsp-layout` are path-layout Changes, not UClass lifetime.

## Later Change intake

A later Change that chooses unroot, collect, or keep-until-shutdown should:

1. Replan the ClassGenerator replacement path without removing `NewerVersion` until reinstancing has moved live objects.
2. Add a proving command that observes `*_REPLACED_N` reachability after FullReload.
3. Replan the three active Changes above.
4. Leave SDK `BodyConflict` and dormant startup as separate owners unless that Change explicitly takes them.
