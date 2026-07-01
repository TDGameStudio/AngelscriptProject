# Tasks: refactor-as-engine-inline-hook-accessors

## 1. Sanity-check accessor name collisions

- [x] 1.1 <!-- Non-TDD --> grep the 19 `Get*()` accessor names (`GetPreCompile` / `GetDynamicSpawnLevel` / `GetDebugBreakFilters`, etc.) against existing `FAngelscriptEngine` methods and confirm **no collisions**. Conclusion: 0 collisions; the original names can be used directly.

## 2. Merge AngelscriptEngine.h Declarations

- [x] 2.1 <!-- Non-TDD --> Move the 13 `DECLARE_*_DELEGATE_*` macros from `Core/AngelscriptEngineHooks.h`, `typedef ... EnumNameList`, `FAngelscriptDebugBreakOptions/Filters` typedefs, and 9 forward declarations (UClass/UEnum/UScriptStruct/UDelegateFunction/UActorComponent/ULevel/UASClass/FAngelscriptClassDesc/FAngelscriptModuleDesc) into `AngelscriptEngine.h` after the existing top forward-declaration block. Remove the old `#include "Core/AngelscriptEngineHooks.h"`.

## 3. Add Fields + Accessors to FAngelscriptEngine

- [x] 3.1 <!-- Non-TDD --> Add the 19 delegate fields to the private section of `FAngelscriptEngine`, preserving one-to-one order with the old hooks struct to keep git blame clean.
- [x] 3.2 <!-- Non-TDD --> Add 19 pairs of `Get*()` accessors (mutable + const overload) to the public section of `FAngelscriptEngine`; every implementation is `return FieldName;`.
- [x] 3.3 <!-- Non-TDD --> Delete the old `Hooks` field and `GetHooks()` method pair.

## 4. Delete Hooks Files

- [x] 4.1 <!-- Non-TDD --> Delete `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineHooks.h`.
- [x] 4.2 <!-- Non-TDD --> Delete `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineHooks.cpp` (it was only a one-line empty implementation).
- [x] 4.3 <!-- Non-TDD --> Remove every `#include "Core/AngelscriptEngineHooks.h"`.

## 5. Replace 133 Call Sites

- [x] 5.1 <!-- Non-TDD --> Runtime: 36 call sites across 10 files: `Bind_AActor.cpp` / `Bind_BlueprintType.cpp` / `Bind_Console.h` / `Bind_FString.cpp` / `Bind_UActorComponent.cpp` / `Bind_UObject.cpp` / `AngelscriptDebugServer.cpp` / `AngelscriptPreprocessor.cpp` / `AngelscriptEngine.cpp` / `AngelscriptClassGenerator.cpp`. Rule: replace `GetHooks().` with an empty prefix.
- [x] 5.2 <!-- Non-TDD --> Editor: 16 call sites across 7 files. Eliminate local variables such as `FAngelscriptEngineHooks& Hooks = Engine.GetHooks();` in `ClassReloadHelper.h` and call `Engine.GetXxx()` directly.
- [x] 5.3 <!-- Non-TDD --> Test: 81 call sites across 11 files (including the new MultiEngineHooks test, 5 ClassReloadHelper Tests, 4 HotReload Tests, and Debugger / Compiler / Preprocessor hook-related tests). Also eliminate any local `FAngelscriptEngineHooks&` references.
- [x] 5.4 <!-- Non-TDD --> grep `GetHooks\(\)` must be zero in plugin source (archive docs excluded); grep `FAngelscriptEngineHooks` must be zero except for the retained `FAngelscriptEngineHooksTests` test class name.

## 6. Spec Revision + OpenSpec Change

- [x] 6.1 <!-- Non-TDD --> Update `openspec/specs/as-engine-owned-hooks/spec.md` line 64 calling-pattern wording from `FAngelscriptEngine::Get().GetHooks().GetOnXxx()` to `FAngelscriptEngine::Get().GetOnXxx()` as a MODIFIED delta.
- [x] 6.2 <!-- Non-TDD --> Create OpenSpec change `refactor-as-engine-inline-hook-accessors` with `proposal.md` / `tasks.md` / `specs/as-engine-owned-hooks/spec.md` MODIFIED delta.

## 7. Verification

- [x] 7.1 <!-- Non-TDD --> `Tools\RunBuild.ps1` fully clean (incremental build, target already ready).
- [x] 7.2 <!-- Non-TDD --> Smoke / RuntimeCpp / Bindings / HotReload suites all green (60 + 105 + 258 + 42 tests).
- [x] 7.3 <!-- Non-TDD --> Engine prefix tests 97/97.

## 8. Commit + Archive

- [ ] 8.1 <!-- Non-TDD --> Submodule commit: `[Angelscript] Refactor: inline FAngelscriptEngineHooks fields onto FAngelscriptEngine`.
- [ ] 8.2 <!-- Non-TDD --> Parent commit: gitlink bump + spec amendment + change archive.
- [ ] 8.3 <!-- Non-TDD --> `openspec archive refactor-as-engine-inline-hook-accessors -y`.
