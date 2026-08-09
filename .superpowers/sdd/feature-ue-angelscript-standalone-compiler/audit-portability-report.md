# Portability audit — maintained AngelScript fork

Date: 2026-07-31  
Scope: read-only inspection of `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript`, with the public header at `Core/angelscript.h`. No build was run.

## Conclusion

A small **source selection** is possible, but a small **no-Unreal build** is not. The maintained fork's minimal compile/build/save-load/execute path still requires 29 common AngelScript translation units. Those units include, or acquire through the public `angelscript.h`, Unreal headers and use UE containers, memory, policy, class-generation, and diagnostic facilities. `AS_MAX_PORTABILITY` successfully removes the native-call/assembly requirement, but it does not remove the UE dependencies.

Therefore the smallest realistic first target is a Win64 static CMake library made from the 29 files below, compiled with generic calls only, after extracting a small portable core surface and a narrow optional host adapter. It must not be attempted by giving the target Unreal include paths or by adding a broad fake `CoreMinimal.h`; both violate task 0.1.

## 1. Exact minimal source set

The following source list is the full non-platform core list in the maintained fork. It is the smallest realistic *link-complete* set for `asCreateScriptEngine`, module compilation, `SaveByteCode`/`LoadByteCode`, context preparation, and interpreted script execution. Omitting apparently secondary files creates unresolved references or removes mandatory engine subsystems (GC, type system, output, or save/restore).

```cmake
set(ANGELSCRIPT_STANDALONE_CORE_SOURCES
  ${AS_FORK}/as_atomic.cpp
  ${AS_FORK}/as_builder.cpp
  ${AS_FORK}/as_bytecode.cpp
  ${AS_FORK}/as_callfunc.cpp
  ${AS_FORK}/as_compiler.cpp
  ${AS_FORK}/as_configgroup.cpp
  ${AS_FORK}/as_context.cpp
  ${AS_FORK}/as_datatype.cpp
  ${AS_FORK}/as_gc.cpp
  ${AS_FORK}/as_generic.cpp
  ${AS_FORK}/as_globalproperty.cpp
  ${AS_FORK}/as_memory.cpp
  ${AS_FORK}/as_module.cpp
  ${AS_FORK}/as_objecttype.cpp
  ${AS_FORK}/as_outputbuffer.cpp
  ${AS_FORK}/as_parser.cpp
  ${AS_FORK}/as_restore.cpp
  ${AS_FORK}/as_scriptcode.cpp
  ${AS_FORK}/as_scriptengine.cpp
  ${AS_FORK}/as_scriptfunction.cpp
  ${AS_FORK}/as_scriptnode.cpp
  ${AS_FORK}/as_scriptobject.cpp
  ${AS_FORK}/as_string.cpp
  ${AS_FORK}/as_string_util.cpp
  ${AS_FORK}/as_thread.cpp
  ${AS_FORK}/as_tokenizer.cpp
  ${AS_FORK}/as_typeinfo.cpp
  ${AS_FORK}/as_variablescope.cpp
)
```

The immediate source-level path is:

| Required capability | Required implementation roots |
|---|---|
| Public engine factory / registration / module API | `as_scriptengine.cpp`, `as_configgroup.cpp`, `as_generic.cpp`, `as_callfunc.cpp`, `as_atomic.cpp`, `as_thread.cpp` |
| Parse and build a module | `as_builder.cpp`, `as_parser.cpp`, `as_tokenizer.cpp`, `as_compiler.cpp`, `as_bytecode.cpp`, `as_scriptcode.cpp`, `as_scriptnode.cpp`, `as_variablescope.cpp` |
| Module and type lifetime | `as_module.cpp`, `as_typeinfo.cpp`, `as_datatype.cpp`, `as_objecttype.cpp`, `as_scriptfunction.cpp`, `as_globalproperty.cpp`, `as_scriptobject.cpp`, `as_gc.cpp` |
| Save/load bytecode | `as_restore.cpp`, plus module/type/function/bytecode/string sources above |
| Run an interpreted function | `as_context.cpp`, `as_callfunc.cpp`, type/function/object/bytecode sources above |
| Core utility and allocation | `as_memory.cpp`, `as_string.cpp`, `as_string_util.cpp`, `as_outputbuffer.cpp` |

`as_restore.cpp` is non-negotiable: the public `asIScriptModule::SaveByteCode` and `LoadByteCode` path uses its reader/writer implementation. `as_gc.cpp` and `as_globalproperty.cpp` are likewise still required even if the first smoke script has no objects or globals, because engine/module destruction and linked methods reference them.

### Deliberately excluded sources

With `AS_MAX_PORTABILITY`, do **not** compile any native ABI implementation or assembly. In this checkout the excluded C++ files are:

```text
as_callfunc_arm.cpp          as_callfunc_arm64.cpp
as_callfunc_e2k.cpp          as_callfunc_mips.cpp
as_callfunc_ppc.cpp          as_callfunc_ppc_64.cpp
as_callfunc_riscv64.cpp      as_callfunc_sh4.cpp
as_callfunc_x64_gcc.cpp      as_callfunc_x64_mingw.cpp
as_callfunc_x64_msvc.cpp     as_callfunc_x86.cpp
as_callfunc_xenon.cpp
```

No `as_callfunc_x64_msvc_asm.asm` is present in the maintained-fork directory, and none may be added to the standalone target. The upstream v2.38 CMake project includes native `as_callfunc_*.cpp` variants and enables MASM for Win64; that is specifically the path this target must avoid.

## 2. Exact Unreal dependencies in that source set

### Direct Unreal and project-header inclusions

The public header consumed by `as_config.h` is not portable:

| File | Direct include / dependency | Consequence |
|---|---|---|
| `Core/angelscript.h:42-45` | `CoreMinimal.h`, `UnrealAngelscriptVersion.h`, `FunctionCallers.h` | Every internal source reaches Unreal through `as_config.h -> angelscript.h`; version constants and UE function-caller header also enter the API surface. |
| `as_atomic.cpp:38` | `HAL/PlatformAtomics.h` | `FPlatformAtomics::InterlockedIncrement/Decrement`. |
| `as_memory.h:103` | `Containers/Array.h` | `TArray<void*>` memory pools. |
| `as_memory.cpp:49` | `AngelscriptMemoryTags.h` | `LLM_SCOPE_BYTAG(Angelscript)`. |
| `as_map.h:42` | `CoreTypes.h` | Unnecessary direct UE core-type include for this generic map header. |
| `as_builder.cpp:51,53` | `AngelscriptEngine.h`, `AngelscriptSettings.h` | UE compile/editor policy checks. |
| `as_compiler.cpp:51-52` | `AngelscriptEngine.h`, `AngelscriptSettings.h` | UE compile warnings/editor policy. |
| `as_context.h:49`; `as_context.cpp:50-51` | `AngelscriptEngine.h`, `AngelscriptSettings.h` | interface casting and world-context policy. |
| `as_scriptengine.cpp:55-56` | `AngelscriptEngine.h`, `ClassGenerator/ASClass.h` | UE-interface casting and raw-script-object registry/lifetime. |

The normal runtime module gives all of these code paths UE definitions through its module/PCH build. A CMake target that merely includes the fork source directory fails earlier, at the public `Core/angelscript.h` `CoreMinimal.h` inclusion.

### Referenced Unreal types, macros, and functions

The following are actual references in the 29-file set, not merely headers accidentally present in the include graph.

| Family | References and locations | Portable disposition |
|---|---|---|
| Containers / moves | `TArray`, `TMap`, `TPair`, `TInlineAllocator`, and `MoveTemp` in `as_builder.*`, `as_compiler.*`, `as_module.*`, `as_scriptengine.*`, `as_memory.*`, `as_context.h`, `as_string.cpp`; e.g. engine template buckets, module reload maps, and parser/compiler temporary lists. | **Unconditional refactor.** These are in data-member layout and unguarded core flows. Substitute maintained/portable equivalents (`asCArray`, `asCMap`, or carefully selected `std::vector`/`std::unordered_map`) rather than shim all of UE's container API. |
| Allocation / copying | `FMemory::Malloc`, `Free`, `Memcpy`, `Memset` in `as_memory.cpp`, `as_scriptengine.cpp`, and `as_scriptobject.cpp`; `LLM_SCOPE_BYTAG(Angelscript)` in `as_memory.cpp`. | **Narrow allocator adapter.** Replace the existing `AngelscriptSDK::SDKAlloc/SDKFree` UE gateway with `StandaloneHost::Alloc/Free` (or restore the upstream public allocator hooks). Map copy/fill to `std::memcpy`/`std::memset`; make memory tagging a no-op or optional observer outside the core. |
| Atomics | `FPlatformAtomics::InterlockedIncrement/InterlockedDecrement` in `as_atomic.cpp`. | **Narrow platform adapter.** Use `std::atomic_ref<int>` / platform-independent atomic wrappers, or retain a two-function adapter. Do not include `HAL/PlatformAtomics.h`. |
| Math / stack allocation | `FMath::Max` in `as_builder.cpp` and `as_objecttype.h`; `FMath::Pow` in `as_context.cpp`; `FMath::Min3` in `as_string.cpp`; `FMemStackBase` in `as_builder.h`, `as_parser.h`, `as_scriptnode.*`. | **Unconditional refactor.** `std::max`, `std::pow`, and a local three-way min are straightforward. `FMemStackBase` is embedded in parser/builder state and needs a portable arena/allocator or the upstream allocation implementation—not a fake UE class. |
| Diagnostics and build flags | `WITH_EDITOR` in builder/compiler/context/property/function/engine paths; `UE_BUILD_SHIPPING` and `FORCEINLINE` in `as_context.h`; `ensureMsgf`/`TEXT` in `as_context.cpp` under `AS_REFERENCE_DEBUGGING`; `SIZE_T` under that same optional debug feature. | **Source selection / conditional cleanup.** Compile the first target with `WITH_EDITOR=0`, `UE_BUILD_SHIPPING=0`, `DO_BLUEPRINT_GUARD=0`, and `AS_REFERENCE_DEBUGGING=0`; then replace `FORCEINLINE` with `inline` and `SIZE_T` with `size_t`, and remove the UE assertion in favour of `asASSERT`/a host diagnostic hook. The unguarded `WITH_EDITOR && FAngelscriptEngine...` expression in `as_compiler.cpp:1051` must still be refactored: `WITH_EDITOR=0` does not prevent name lookup of the referenced static method. |
| Blueprint stack guard | `FBlueprintContextTracker::TryGet()` and `GetCurrentScriptStack().Num()` in `as_context.cpp:548-553`, under `DO_BLUEPRINT_GUARD`. | **Removed by source configuration.** Set `DO_BLUEPRINT_GUARD=0` for standalone; no adapter is needed for the initial target. |
| Editor/world compile policy | `FAngelscriptEngine::IsSimulatingCookedForCurrentContext`, `TryGetCurrentEngine`, `Get().ConfigSettings` and settings fields such as `bWarnOnDivergentComparisonOperatorOverloads`, `bWarnOnImplicitSignedUnsignedConversion`, `bWarnOnIncrementDecrementInComplexExpression`, `bWarnOnUnusedReturnValueForConstMethods`, and `bErrorOnIncorrectEditorOnlyCode`. | **Narrow compiler-policy adapter.** Initial standalone policy should return false/defaults or only expose a host-neutral warning-policy struct. Do not link the Unreal engine singleton or settings UObject. The world-context field `bErrorWhenUsingInvalidWorldContext` is separately part of the context adapter. |
| UE object/interface semantics | `FAngelscriptEngine::CanCastScriptObjectToUnrealInterface` in `as_context.cpp:3412` and `as_scriptengine.cpp:5161,5174`. | **Narrow host adapter.** Standalone implementation returns false; UE implementation delegates to the present engine function. This preserves native AngelScript inheritance/interface casting while removing UE-only cross-interface behavior. |
| UE raw script-object registry | `UASClass::UnregisterRawScriptObjectsForEngine`, `UnregisterRawScriptObject`, `GetRawScriptObjectType`, `AddRawScriptObjectReference`, `BeginReleaseRawScriptObjectReference`, and `FinishReleaseRawScriptObjectReference` in `as_scriptengine.cpp:895,4784-4845`. | **Narrow object-lifetime adapter or restoration of upstream raw-object behavior.** It is unguarded and must be replaced even if the first smoke script avoids script classes. For the first simple script, the standalone implementation can report no external raw-object registration and use stock `asCScriptObject` allocation/release. |

`as_criticalsection.h` is already a no-op implementation in this fork, so its `DECLARECRITICALSECTION`, `ENTERCRITICALSECTION`, and `LEAVECRITICALSECTION` macros do not currently require UE. This is not proof of thread safety; a portable target should either keep `AS_NO_THREADS` for the first single-thread smoke or replace those macros with a real standard-mutex implementation before claiming multi-thread support.

### Public-header coupling that must be removed first

`Core/angelscript.h` is the only `angelscript.h` reachable by the fork and it forces `CoreMinimal.h`. It must be made C++-standard-only for the standalone build (preferably by extracting the public product/version and caller extensions into host-neutral headers, not by copying the fork). The bare `FunctionCallers.h` inclusion is not needed to define the header's own `asFunctionCaller` struct at lines 732-749; it adds UE UObject and platform headers without supplying that type. `UnrealAngelscriptVersion.h` must be replaced by a small product-version constants header with no UE include, preserving the current compatibility check in `asCreateScriptEngine` (`as_scriptengine.cpp:243-247`).

The `FScriptExecution` JIT types in `angelscript.h:1504-1506` are a custom extension. The no-JIT smoke can leave those declarations in a standard-only public header, but the standalone target must not register a JIT compiler. `AS_MAX_PORTABILITY` does not by itself disable this API declaration; the adapter should simply leave JIT entries null.

## 3. Removal versus refactor versus adapter

### Removed by source selection or fixed target definitions

* The 12 native `as_callfunc_*` architecture translation units listed above, every assembler input, native ABI probing, and the MSVC MASM requirement.
* Blueprint guard code with `DO_BLUEPRINT_GUARD=0`.
* Editor-only blocks with `WITH_EDITOR=0`. This reduces the footprint but does **not** remove all UE engine-policy source references, because some occur in ordinary expressions.
* Reference-debug tracking with `AS_REFERENCE_DEBUGGING=0`; it removes `TArray<void**>`, `SIZE_T`, `ensureMsgf`, and `TEXT` use from the context debug-only path.
* Profiling/debug-only platform headers by leaving `AS_PROFILE` and `AS_DEBUG` undefined for the first proof. `as_debug.h` otherwise pulls Windows/POSIX timing and directory APIs, but this is not Unreal coupling.

### Required portable core refactors

These cannot be solved by target compile definitions or by a narrow two-function adapter because their types are embedded in the engine/compiler/module ABI and used throughout normal compilation:

1. Replace UE containers and their idioms in the required source set. Start from the affected members in `as_scriptengine.h` (template buckets / type-ID map), `as_module.h` (hot-reload maps and `PreClassData`), `as_memory.h` (pools), `as_compiler.h` (inline initialized-variable array), `as_builder.h` (editor-only container when enabled), and `as_context.h` (optional debug tracking). The first implementation should not change public C API ABI or serialize these implementation containers.
2. Replace `FMemStackBase` in parser/builder/script-node copy code with a local portable arena. It is an internal implementation type, so a standalone `std::pmr`/vector-backed arena can be selected without changing consumer API.
3. Make `Core/angelscript.h`, `as_config.h`, `as_memory.h`, `as_map.h`, and visibility/version plumbing include only standard headers for the standalone configuration. `ANGELSCRIPTRUNTIME_API` must not be the standalone export mechanism; static target code should use `ANGELSCRIPT_EXPORT` and `_LIB` (or a deliberately empty standalone visibility macro), not UE module exports.
4. Replace `FMath` / `FMemory` operations with standard equivalents or the allocator adapter. This is small in line count but mandatory because the references are unguarded.

### Narrow adapter boundary

Keep this boundary deliberately small and in new portable host files, not in a fake Unreal include tree:

```text
Portable core
  ├─ Allocation: Allocate(size, alignment), Free(ptr)
  ├─ Atomics: Increment(int&), Decrement(int&)
  ├─ Compiler policy: optional warning/editor/world-context decisions
  ├─ Object bridge: external raw-script-object lookup/addref/release; otherwise no-op/false
  └─ Interface bridge: CanCastToHostInterface(...) -> false in standalone
```

For UE builds the current `FMemory`, `FPlatformAtomics`, `FAngelscriptEngine`, `UASClass`, settings, and LLM operations can implement this boundary. For standalone, the atomics/allocator use standard C++, policy defaults are deterministic, and the object/interface hooks return the non-UE behavior. The core must not include UE headers to obtain those implementations.

## 4. `AS_MAX_PORTABILITY` finding and compile definitions

**Yes.** The maintained `as_callfunc.cpp` has a complete generic branch:

* `PrepareSystemFunction` returns the generic-only configuration result under `AS_MAX_PORTABILITY` (`as_callfunc.cpp:213-218`).
* `CallSystemFunction` uses `context->CallGeneric(func)` for `ICC_GENERIC_FUNC` / `ICC_GENERIC_METHOD` and rejects native calling (`as_callfunc.cpp:406-425`).
* The native implementation is in the `#else` branch and terminates at line 803.
* `as_scriptengine.cpp:2083-2085`, `2726-2728`, and `2855-2857` reject registration call conventions other than `asCALL_GENERIC`.

The maintained fork has additionally replaced the old native body with a function-caller path in the non-portability branch, but the portability branch remains self-contained and does not reference a platform `CallSystemFunctionNative` implementation. This lets the target omit every native `as_callfunc_*` source.

For a first Win64 MSVC static target, use these definitions deliberately rather than allowing UE build definitions to leak in:

```cmake
target_compile_definitions(angelscript_standalone_core PRIVATE
  ANGELSCRIPT_EXPORT=1
  _LIB=1
  AS_MAX_PORTABILITY=1
  AS_NO_THREADS=1
  AS_NO_EXCEPTIONS=1
  WITH_EDITOR=0
  UE_BUILD_SHIPPING=0
  DO_BLUEPRINT_GUARD=0
  AS_REFERENCE_DEBUGGING=0
  _CRT_SECURE_NO_WARNINGS
)
```

Notes:

* `_LIB`/`ANGELSCRIPT_EXPORT` are the fork's existing library export selection; do not define `ANGELSCRIPT_DLL_LIBRARY_IMPORT` on the producer target.
* `AS_NO_EXCEPTIONS` is already forced late in `as_config.h`, but specifying it makes the CMake contract explicit.
* `AS_NO_THREADS` is appropriate only for the first single-thread proof because this fork's critical-section header is intentionally no-op. It does not remove `as_atomic.cpp`; that translation unit still needs its standard-atomic refactor.
* `AS_MAX_PORTABILITY` means the smoke must use no native `asCALL_CDECL`, `asCALL_THISCALL`, or UE binding. Any host function used by the test must be registered with `asCALL_GENERIC`, or the smoke can be entirely self-contained (`int main() { ... }`) and needs no registered callback.
* Do not define `AS_DEBUG`/`AS_PROFILE` in the initial proof. They are not necessary for compile/save/load/execute and broaden platform-header needs.

## 5. Recommended first TDD slice

### Red test first

Add a standalone CTest executable that includes only the new standalone-facing public header and a trivial `asIBinaryStream` implementation backed by `std::vector<asBYTE>`. Its one test should:

1. call `asCreateScriptEngine(ANGELSCRIPT_VERSION)` and require a non-null engine;
2. create module `roundtrip` with `asGM_ALWAYS_CREATE`;
3. add exactly one source section, for example `int main() { return 42; }`, and call `Build()`;
4. find `main`, create a context, `Prepare`, and `Execute`; require `asEXECUTION_FINISHED` and return value `42`;
5. save that built module's bytecode to the vector stream;
6. create a second module, load the same bytecode from a reset/read stream, find and execute `main` again, and require `42`;
7. release function/context/modules/engine in a defined order.

This uses the required parser, builder, compiler, module, context, and restore paths without needing add-ons, generated bindings, UObjects, or a native call bridge. It is also a direct future regression for Phase 0's bytecode proof without prematurely asserting deterministic identity (task 0.2 owns that contract).

### Expected initial failures, in useful order

1. `Core/angelscript.h` cannot find `CoreMinimal.h`; even if found, it brings the UE dependency the source scan must reject.
2. `as_memory.h`/`as_map.h` cannot find `Containers/Array.h` / `CoreTypes.h`, followed by unknown `TArray`, `TMap`, `TPair`, `TInlineAllocator`, `MoveTemp`, `FMemStackBase`, `FMemory`, and `FMath` symbols across the mandatory implementation headers.
3. Missing `HAL/PlatformAtomics.h`, `AngelscriptMemoryTags.h`, `AngelscriptEngine.h`, `AngelscriptSettings.h`, and `ClassGenerator/ASClass.h` in their direct translation units.
4. After headers are bypassed, unresolved or undeclared UE-only operations: allocator/tagging, atomics, `UASClass` raw-object registry calls, `FAngelscriptEngine` cast/policy calls, and the compiler's unguarded `WITH_EDITOR && FAngelscriptEngine...` expression.
5. After a clean compile, registration tests written with `asCALL_CDECL` will return `asNOT_SUPPORTED` under `AS_MAX_PORTABILITY`; this is expected and should be covered as a negative test, not treated as a linker error.
6. If CMake accidentally adds an upstream-style Win64 source list, it will either ask for MASM or get native-call link failures. The architecture/source-list test must fail first if any `as_callfunc_*.cpp` / `.asm` enters the target.

## 6. Risks against OpenSpec Phase 0 task 0.1

Task 0.1 requires a minimal CMake proof from the maintained parser/builder/compiler/module/save-restore/context sources **and** scans proving no Unreal header, library, generated code, installation path, copied fork, or broad fake Unreal header enters the target.

The following facts conflict with interpreting 0.1 as "add a CMake source list and compile the fork unchanged":

1. The maintained fork's only public header directly includes `CoreMinimal.h`; every required source reaches it through `as_config.h`. A source-only CMake target cannot pass a no-UE-header scan without a portability refactor before compilation.
2. The mandatory units contain unguarded UE data structures and behavior—not merely optional editor features—including `TMap`/`TArray`, `FMemStackBase`, `FMemory`, `FPlatformAtomics`, `UASClass`, and `FAngelscriptEngine` interface casting. A broad fake Unreal header would conceal, rather than solve, this and is explicitly forbidden.
3. Some UE code is hidden behind editor/debug preprocessor flags and can be excluded; the engine-policy checks and raw-object bridge cannot. Treating all dependencies as removable by `WITH_EDITOR=0` would create an inaccurate feasibility result.
4. `AS_MAX_PORTABILITY` has an intentional functional limitation: ordinary native/manual bindings cannot be used. The first proof must use pure script or generic callbacks and must state that it does not establish the later generic-trap/replay binding requirements of task 0.4.
5. Replacing embedded containers and memory-stack behavior can alter ordering, allocation, and bytecode identity. The Phase 0.1 smoke must not claim task 0.2 determinism; preserve current iteration/order semantics and introduce the 0.2 normalized two-run test immediately afterward.
6. The fork's current no-op critical-section implementation and UE allocation instrumentation mean that an initial single-thread, no-telemetry proof is realistic, but it does not validate production allocation accounting, shutdown leaks, or parallel use. Those claims belong to later task 0.9 / Phase 1 work.

### Recommended task interpretation/update

Phase 0.1 is still feasible, but it must explicitly include a *minimal, maintained-source portability extraction* as part of the proof, before CMake can compile. Record the following as the Phase 0.1 dependency families: public-header/version plumbing; containers; memory/atomics; parser arena; compiler/world/editor policy; raw-object lifecycle; interface casting; optional diagnostics/threading; and native-call elimination. Do not call the result a thin build-system exercise or a zero-refactor feasibility check.

The source/link architecture scans should inspect the CMake compile command database and link command for: UE include roots; `Unreal*`, `Core`, `Engine`, `UObject`, and generated-code libraries; `CoreMinimal.h` / all direct UE headers named above; copied `angelscript` trees; native callfunc/assembly files; and broad fake headers. They should allow only the maintained fork paths plus new standalone-owned portable adapter files.

## Evidence consulted

* Maintained fork source: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/`.
* Current public header: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`.
* Runtime module include setup: `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`.
* Upstream CMake baseline and `AS_MAX_PORTABILITY` project configuration: `Reference/angelscript-v2.38.0/sdk/angelscript/projects/cmake/CMakeLists.txt` and `projects/msvc2022/angelscript.vcxproj`.
* OpenSpec Phase 0 contract: `openspec/changes/feature-ue-angelscript-standalone-compiler/tasks.md:3`.
