> Record-only status: this checklist is for a future implementation. Do not mark items complete until source/docs are actually changed and verified.

## 0. Preflight

- [ ] 0.1 <!-- Non-TDD --> Re-run `rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source` and compare with `openspec/changes/refactor-as-audit-remove-with-angelscript-haze/audit.md`.
- [ ] 0.2 <!-- Non-TDD --> Confirm no build-layer opt-in exists: `rg -n "WITH_ANGELSCRIPT_HAZE|HAZE|Haze" Plugins\Angelscript\Source -g "*.Build.cs" -g "*.Target.cs"`.
- [ ] 0.3 <!-- Non-TDD --> Check dirty state before editing: `git status --short` in the parent repo and `git status --short` in `Plugins\Angelscript`.

## 1. Category E - strip decorative non-Haze wrappers

- [ ] 1.1 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`, remove the `#if !WITH_ANGELSCRIPT_HAZE` wrapper around the `GetAllActorsOfClass` global function block; keep the binding code.
- [ ] 1.2 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_APlayerController.cpp`, remove the three `#if !WITH_ANGELSCRIPT_HAZE` wrappers around `AController`, `APlayerController`, and `APawn` binding blocks.
- [ ] 1.3 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionShape.cpp`, remove the wrapper around `FCollisionShape` POD value-class registration.
- [ ] 1.4 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Subsystems.cpp`, remove the wrapper around the `ULocalPlayerSubsystem::Get(LocalPlayer)` global function block.
- [ ] 1.5 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UGameInstance.cpp`, remove the wrapper around local-player creation and management bindings.
- [ ] 1.6 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ULocalPlayer.cpp`, remove the wrapper around `GetGameInstance` / `GetControllerId`.
- [ ] 1.7 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp`, remove both wrappers around `IsSupportedForNetworking` and `LoadObject`.
- [ ] 1.8 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UWorld.cpp`, remove the wrapper around `ServerTravel`, `GetNetMode`, and `GetGameState`.
- [ ] 1.9 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`, remove the wrapper around `Replicated`, `ReplicationCondition`, and `NotReplicated` UPROPERTY specifier handling.
- [ ] 1.10 <!-- TDD --> Run `Tools\RunBuild.ps1 -Label haze-cat-e -TimeoutMs 900000`.
- [ ] 1.11 <!-- TDD --> Run focused binding/preprocessor tests with `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings" -Label haze-cat-e-bindings -TimeoutMs 900000`.

## 2. Category B - delete Haze-only RPC syntax and metadata

- [ ] 2.1 <!-- Non-TDD --> In `AngelscriptPreprocessor.cpp`, delete the `NetFunction` / `CrumbFunction` / `DevFunction` UFUNCTION branch and remove `PP_NAME_NetFunction`, `PP_NAME_CrumbFunction`, and `PP_NAME_DevFunction` if no longer referenced.
- [ ] 2.2 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`, remove `FAngelscriptFunctionDesc::bNetFunction`, `bDevFunction`, and related equality comparisons.
- [ ] 2.3 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`, delete the `#if WITH_ANGELSCRIPT_HAZE` block that sets `FUNC_NetFunction`, `FUNC_DevFunction`, `HazeFunctionFlags`, and `HAZEFUNC_CrumbFunction`; remove `FUNCMETA_CrumbFunction` if it becomes unused.
- [ ] 2.4 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`, remove both `FUNC_NetFunction` BlueprintEvent binding branches.
- [ ] 2.5 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h` and `.cpp`, remove `bNetFunction` / `bDevFunction` storage, serialization, load, and restore logic.
- [ ] 2.6 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.cpp`, remove the `bNetFunction` dump column/value if it only reflects the removed Haze-only descriptor field.
- [ ] 2.7 <!-- Non-TDD --> Sweep active scripts/tests for Haze-only specifiers: `rg -n "NetFunction|CrumbFunction|DevFunction" Script Plugins\Angelscript\Source\AngelscriptTest Plugins\Angelscript\Source\AngelscriptRuntime`.
- [ ] 2.8 <!-- TDD --> Run `Tools\RunBuild.ps1 -Label haze-cat-b -TimeoutMs 900000`.
- [ ] 2.9 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Networking" -Label haze-cat-b-networking -TimeoutMs 900000`.

## 3. Category C/D - keep non-Haze behavior and remove debugger flag

- [ ] 3.1 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_WorldCollision.cpp`, keep the current `System` namespace branch and delete the `AsyncTrace` alternative branch.
- [ ] 3.2 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.cpp`, replace the conditional `AS_ENSURE` definition with an unconditional `#define AS_ENSURE ensureMsgf`.
- [ ] 3.3 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`, delete the Haze-only cooked exception dialog branch guarded by `WITH_ANGELSCRIPT_HAZE`.
- [ ] 3.4 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h`, remove `FAngelscriptDebugDatabaseSettings::bUseAngelscriptHaze` and its serialization.
- [ ] 3.5 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp`, remove the assignment to `DebugSettings.bUseAngelscriptHaze`.
- [ ] 3.6 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerDatabaseTests.cpp`, remove the assertion that mirrors `bUseAngelscriptHaze` against `!!WITH_ANGELSCRIPT_HAZE`.
- [ ] 3.7 <!-- TDD --> Run `Tools\RunBuild.ps1 -Label haze-cat-cd -TimeoutMs 900000`.
- [ ] 3.8 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor.Debugger" -Label haze-cat-cd-debugger -TimeoutMs 900000`.

## 4. Category A - restore UE-original actor names

- [ ] 4.1 <!-- TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`, rename the script binding signature from `"APawn GetActorInstigator() const"` to `"APawn GetInstigator() const"`.
- [ ] 4.2 <!-- TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`, rename the script binding signature from `"AController GetActorInstigatorController() const"` to `"AController GetInstigatorController() const"`.
- [ ] 4.3 <!-- TDD --> In `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorPropertyInterfaceTests.cpp`, migrate inline AS calls to `GetInstigator()` and `GetInstigatorController()` and keep behavior assertions.
- [ ] 4.4 <!-- Non-TDD --> Sweep active source/scripts for old names: `rg -n "GetActorInstigator|GetActorInstigatorController" Plugins\Angelscript\Source Script`; expected result after migration is zero active-code hits.
- [ ] 4.5 <!-- TDD --> Run `Tools\RunBuild.ps1 -Label haze-cat-a -TimeoutMs 900000`.
- [ ] 4.6 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Actor" -Label haze-cat-a-actor -TimeoutMs 900000`.
- [ ] 4.7 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Networking" -Label haze-cat-a-networking -TimeoutMs 900000`.

## 5. Final macro removal, docs, and validation

- [ ] 5.1 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`, delete the `#ifndef WITH_ANGELSCRIPT_HAZE` / `#define WITH_ANGELSCRIPT_HAZE 0` / `#endif` block.
- [ ] 5.2 <!-- Non-TDD --> Verify active source is clean: `rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source` returns zero matches.
- [ ] 5.3 <!-- Non-TDD --> Update active documentation references in `Documents/Knowledges/ZH/Syntax_UFUNCTION.md` and related guides to state that the Haze macro path was removed by this OpenSpec change.
- [ ] 5.4 <!-- Non-TDD --> Verify active docs/config/scripts are clean, excluding OpenSpec history: `rg -n "WITH_ANGELSCRIPT_HAZE" Documents AGENTS.md AGENTS_ZH.md Script Source Config`.
- [ ] 5.5 <!-- Non-TDD --> Add a "Recently Completed Milestones" entry to `AGENTS.md` and `AGENTS_ZH.md` when the implementation lands.
- [ ] 5.6 <!-- TDD --> Final build: `Tools\RunBuild.ps1 -Label haze-final -TimeoutMs 900000`.
- [ ] 5.7 <!-- TDD --> Final functional suite: `Tools\RunTests.ps1 -Suite Functional -Label haze-final-functional -TimeoutMs 900000`.
- [ ] 5.8 <!-- Non-TDD --> Validate OpenSpec: `openspec validate refactor-as-audit-remove-with-angelscript-haze --strict --json`.
