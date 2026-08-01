# Compat-First Fork Minimization Implementation Plan

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task in the current workspace. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the authoritative UE-spelled AngelScript fork under standalone CMake through a bounded compatibility include tree while removing fork-wide STL/host-service portability changes and retaining only independently justified semantic fixes.

**Architecture:** `AngelscriptMaintainedFork` receives `Standalone/Compat` as its first CMake include directory. UE-named headers and types resolve to standard-C++ subset implementations only for that target; UBT continues to resolve the real Unreal headers. Definitions that UE normally owns outside the fork are supplied by standalone-only translation units, while true parser/compiler/runtime behavior remains in the shared fork with focused tests.

**Tech Stack:** C++20, CMake 3.25, MSVC/CTest, Unreal Build Tool, AngelScript 2.33 fork with selective compatibility, OpenSpec.

## Global Constraints

- Work in the current checkout; do not create a worktree.
- Preserve all unrelated dirty changes, especially manual-binding architecture edits and unrelated AngelscriptTest edits.
- Use `apply_patch` for source and documentation edits.
- Add no `.uplugin` module, Build.cs dependency, public standalone toggle, `AS_STANDALONE`, or `WITH_ANGELSCRIPT_STANDALONE` branch.
- `Standalone/Compat` may be selected only by the CMake maintained-fork target.
- `AngelscriptLanguageCore`, bindings, ClassGenerator, and ordinary standalone host records remain independent of Compat UE types.
- UE-validation bytecode remains non-executable and non-UE-ABI.
- Every retained shared-fork change needs focused standalone evidence and a UE/NativeCore regression path.
- Do not commit unless the user explicitly requests a commit.

---

## File map

**Create under `Plugins/Angelscript/Standalone/Compat/`:**

- `UECompat.h`: primitive aliases, platform macros, traits, assertions, memory/math/string/hash helpers, containers, guards, and arena subset.
- `CoreMinimal.h`, `CoreTypes.h`, `Containers/Array.h`, `HAL/Platform.h`, `HAL/PlatformAtomics.h`, `UObject/Object.h`, `UObject/Script.h`: include-compatible entry points.
- `AngelscriptSettings.h`: the exact standalone policy fields read by the fork.
- `AngelscriptEngine.h`: minimal current-engine/policy and interface-cast facade used by the fork.
- `ClassGenerator/ASClass.h`: standalone raw-script-object type/reference registry facade.
- `Source/AngelscriptStandaloneMemoryCompat.cpp`: `FMemory` callback state plus the already-declared AngelScript global memory functions.
- `Source/AngelscriptStandaloneEngineCompat.cpp`: engine policy defaults, `asStringScanDouble/Float`, raw-object registry, and standalone `asIScriptObject::GetObjectType()`.
- `Source/AngelscriptStandaloneThreadCompat.cpp`: target-owned thread cleanup and lock API; it replaces the fork `as_thread.cpp` only in CMake if private TLS cleanup cannot be linked safely without a fork edit.

**Modify:**

- `Plugins/Angelscript/Standalone/CMakeLists.txt`: Compat include order, sources, packaging, and compatibility-test target.
- `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp`: invert the old portability policy and scan the new boundary.
- `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneCompatTests.cpp`: executable subset behavior tests.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`: restore UE includes/types while retaining only approved public semantic API.
- Mixed fork files: `as_compiler.cpp/.h`, `as_context.cpp`, `as_scriptengine.cpp`.
- Semantic fork files: `as_parser.cpp`, `as_restore.cpp`, `as_typeinfo.h` only if their already-added behavior remains covered.
- UE Core host files: restore `angelscript.cpp`, `AngelscriptEngine.cpp`, `AngelscriptRuntimeModule.cpp`; remove the untracked `AngelscriptSDKHostServices.*` implementation.

**Restore mechanical portability changes from the plugin submodule baseline:**

`as_atomic.cpp`, `as_builder.cpp`, `as_builder.h`, `as_callfunc.h`, `as_config.h`, `as_context.h`, `as_map.h`, `as_memory.cpp`, `as_memory.h`, `as_module.cpp`, `as_module.h`, `as_objecttype.h`, `as_parser.h`, `as_scriptengine.h`, `as_scriptfunction.h`, `as_scriptnode.cpp`, `as_scriptnode.h`, `as_scriptobject.cpp`, `as_string.cpp`, `as_string.h`, `as_string_util.cpp`, `as_thread.cpp`, and `as_thread.h`.

---

### Task 1: Freeze the architectural regression as a failing test

**Files:**

- Modify: `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp`
- Modify: `Plugins/Angelscript/Standalone/CMakeLists.txt`

**Interfaces:**

- Consumes: repository paths already supplied by `ANGELSCRIPT_STANDALONE_SOURCE_ROOT` and `ANGELSCRIPT_STANDALONE_BUILD_ROOT`.
- Produces: an architecture executable that distinguishes allowed Compat UE spellings from real UE build dependencies and fork portability contamination.

- [x] Replace `HasForbiddenCoreDependency` with separate checks:

```cpp
bool HasForkPortabilityContamination(std::string_view Text)
{
    static constexpr std::string_view Patterns[] = {
        "as_portable_containers.h",
        "as_memoryarena.h",
        "as_host_services.h",
        "asCStdArray<",
        "asCHashMap<",
        "asCMemoryArena",
        "std::atomic_ref",
    };
    for (const std::string_view Pattern : Patterns)
        if (Text.find(Pattern) != std::string_view::npos)
            return true;
    return false;
}
```

- [x] Require `Standalone/Compat/CoreMinimal.h`, `CoreTypes.h`, `UECompat.h`, `AngelscriptEngine.h`, and `ClassGenerator/ASClass.h` to exist; require the CMake text to place `${CMAKE_CURRENT_LIST_DIR}/Compat` before Runtime Core for `AngelscriptMaintainedFork`.
- [x] Require the generated `AngelscriptMaintainedFork.vcxproj` to contain the Compat path and no `Engine\\Source`, `.generated.h`, UE library, or Unreal installation path.
- [x] Scan Build.cs, `Language/`, `Binds/`, `ClassGenerator/`, and ordinary `Standalone/Source/` while excluding `Standalone/Compat`; fail if any imports the Compat directory or uses a standalone fork macro.
- [x] Run the existing architecture test and observe RED:

```powershell
cmake --build Plugins/Angelscript/Standalone/out/build --config Debug --target AngelscriptStandaloneArchitectureTests
ctest --test-dir Plugins/Angelscript/Standalone/out/build -C Debug -R AngelscriptStandalone.Architecture --output-on-failure
```

Expected: FAIL naming the absent Compat headers and existing `as_portable_containers.h`, `as_memoryarena.h`, or `as_host_services.h` contamination.

### Task 2: Add the minimal container/platform compatibility surface

**Files:**

- Create: `Plugins/Angelscript/Standalone/Compat/UECompat.h`
- Create: the compatibility entry headers listed in the file map.
- Create: `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneCompatTests.cpp`
- Modify: `Plugins/Angelscript/Standalone/CMakeLists.txt`

**Interfaces:**

- Produces: `TArray`, `TMap`, `TMultiMap`, `TSet`, `TPair`, `TInlineAllocator`, `TGuardValue`, `FMemStackBase`, `FMemory`, `FMath`, `FCStringAnsi`, `FCrc`, `FPlatformAtomics`, and the traits used by `FunctionCallers.h`.

- [x] Write tests that exercise only fork-observed operations: `Num`, `IsEmpty`, `Reset`, `Empty`, `Reserve`, `Add`, `Emplace`, `Emplace_GetRef`, `Contains`, `IndexOfByKey`, `RemoveSingleSwap`, `Remove`, `RemoveAtSwap`, `Pop(EAllowShrinking::No)`, iteration, map `Find/FindRef/FindChecked/Add/Remove`, multimap `AddUnique/CreateConstKeyIterator`, pair `.Key/.Value`, guard restore, aligned arena allocation, memory callbacks, CRC stability, and atomic increment/decrement.
- [x] Compile the new test against `Standalone/Compat` before implementations are complete and observe RED compiler errors for the missing types/operations.
- [x] Implement the subset in `UECompat.h` using `std::vector` storage and linear key lookup where existing fork semantics do not require UE hashing. Keep the UE names in the compatibility layer; do not introduce replacement names into the fork.
- [x] Run `AngelscriptStandaloneCompatTests` and require PASS with zero warnings promoted by the standalone target.

### Task 3: Add target-owned engine, object, memory, and thread definitions

**Files:**

- Create: `Standalone/Compat/AngelscriptSettings.h`
- Create: `Standalone/Compat/AngelscriptEngine.h`
- Create: `Standalone/Compat/ClassGenerator/ASClass.h`
- Create: the four compatibility `.cpp` files listed in the file map.
- Modify: `Standalone/Tests/AngelscriptStandaloneCompatTests.cpp`

**Interfaces:**

- `FAngelscriptEngine::Get()` and `TryGetCurrentEngine()` return the standalone policy singleton.
- `FAngelscriptEngine::IsSimulatingCookedForCurrentContext()` returns `false`.
- `FAngelscriptEngine::CanCastScriptObjectToUnrealInterface(...)` returns `false` unless the standalone registry records an exact supported relationship.
- `UASClass` exposes the static signatures already called by `as_scriptengine.cpp`; its registry is process-local, mutex-protected, engine-aware, and erased during engine shutdown.
- `FMemory::SetAllocationFunctions`, `Malloc`, `Free`, `Memcpy`, and `Memset` route counted engine allocations without modifying `as_memory.cpp`.

- [x] Add failing tests for aligned allocation/free accounting, allocator reset, raw object register/type/addref/release/unregister, default policies, `asStringScanDouble/Float`, lock no-op/balance under `AS_NO_THREADS`, and repeated cleanup.
- [x] Implement the minimal target-owned behavior; never emulate UObject, UClass layout, World, reflection, or GC.
- [x] Run compatibility tests and the existing lifecycle test; require PASS and zero tracked allocations after engine teardown.

### Task 4: Select Compat in CMake and restore portability-only fork files

**Files:**

- Modify: `Plugins/Angelscript/Standalone/CMakeLists.txt`
- Restore the 23 files listed in the file map by applying inverse hunks only for this standalone change.
- Remove: `as_portable_containers.h`, `as_memoryarena.h`, `as_host_services.cpp`, `as_host_services.h`.

**Interfaces:**

- `AngelscriptMaintainedFork` publishes Compat before Runtime Core because public `angelscript.h` includes `CoreMinimal.h` and `FunctionCallers.h`.
- Build-tree targets that link `AngelscriptMaintainedFork` inherit the compatibility include path needed to compile that header; the V1 installed package remains CLI-only, ships no headers or libraries, and no UBT target sees Compat.

- [x] Add Compat and target-owned sources to CMake and configure a fresh build directory.
- [x] Observe compilation failures one dependency family at a time after restoring the fork baseline.
- [x] Fill only the missing compatibility operation reported by the compiler; do not edit the fork to use a new portable type.
- [x] Build `AngelscriptMaintainedFork`, then `AngelscriptStandaloneCompatTests`, then `AngelscriptStandaloneSmokeTests` to GREEN.

### Task 5: Shrink mixed fork files to the semantic allowlist

**Files:**

- Modify: `Core/angelscript.h`, `as_compiler.cpp`, `as_compiler.h`, `as_context.cpp`, `as_scriptengine.cpp`, `as_typeinfo.h`.
- Test: `Standalone/Tests/AngelscriptSemanticObserverTests.cpp`, smoke/runtime/add-on tests.

**Interfaces:**

- Retain `asISemanticObserver`, observation PODs, typed engine/type user data, and exact observer call sites.
- Retain immediate abort after instruction callback changes context status.
- Retain separately tested generic parameter stack, template factory, script-struct restore, unnamed registration parameter, and engine teardown fixes.
- Restore UE policy, container, memory, assertion, logging, and raw object spellings around those changes.

- [x] Run semantic observer tests before editing to capture the current GREEN baseline.
- [x] Restore mechanical hunks, rebuild, and run the focused tests after each mixed file.
- [x] Use `git diff --word-diff=porcelain` to verify every remaining fork hunk maps to the allowlist and contains no `as_host_services`, `asCStdArray`, `asCHashMap`, or `asCMemoryArena` reference.

### Task 6: Remove UE Runtime host-service adaptation

**Files:**

- Restore: `Core/angelscript.cpp`, string scanners in `Core/AngelscriptEngine.cpp`, and Runtime module startup/shutdown.
- Remove: `Core/AngelscriptSDKHostServices.cpp`, `Core/AngelscriptSDKHostServices.h`.
- Preserve: unrelated `FunctionCallers.h`, binding-origin, manual-binding builder, and export work.

- [x] Add architecture assertions that RuntimeModule contains no `AngelscriptSDKHostServices::Configure/Reset` and fork CMake contains no `as_host_services.cpp`.
- [x] Run architecture test to RED while the old adapter remains.
- [x] Remove only the host-service integration and restore original UE-owned definitions.
- [x] Rebuild architecture and standalone smoke tests to GREEN.

### Task 7: Full verification and OpenSpec reconciliation

**Files:**

- Update: `openspec/changes/feature-ue-angelscript-standalone-compiler/tasks.md`
- Update: `openspec/changes/feature-ue-angelscript-standalone-compiler/verification/` records touched by the architecture change.

- [x] Configure/build Debug and Release standalone targets from a clean build directory.
- [x] Run CTest labels/targets for architecture, compat, smoke, semantic observer, add-ons, runtime, lifecycle, UE analysis, corpus, soak, CLI, and package inspection.
- [x] Run the project UE Development build through `Tools/RunBuild.ps1` using `AgentConfig.ini`.
- [x] Run focused NativeCore, Compiler, Preprocessor, Bindings, and OfflineContract suites through the documented test runner.
- [x] Record exact commands, pass/fail counts, build paths, and any environmental limitations.
- [x] Run:

```powershell
openspec validate feature-ue-angelscript-standalone-compiler --strict
git -C Plugins/Angelscript diff --check
git diff --check
```

- [x] Mark only evidenced Compat-first tasks complete and produce an explicit remaining-diff review list for the user.
