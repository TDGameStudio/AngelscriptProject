> Implementation status: source, docs, and focused verification have landed in this workspace. Historical OpenSpec/archive mentions are intentionally preserved.

## 0. Preflight

- [x] 0.1 <!-- Non-TDD --> Re-run `rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source` and compare with `openspec/changes/refactor-as-audit-remove-with-angelscript-haze/audit.md`.
- [x] 0.2 <!-- Non-TDD --> Confirm no build-layer opt-in exists: `rg -n "WITH_ANGELSCRIPT_HAZE|HAZE|Haze" Plugins\Angelscript\Source -g "*.Build.cs" -g "*.Target.cs"`.
- [x] 0.3 <!-- Non-TDD --> Check dirty state before editing: `git status --short` in the parent repo and `git status --short` in `Plugins\Angelscript`.

## 1. Category E - strip decorative non-Haze wrappers

- [x] 1.1 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`, remove the `#if !WITH_ANGELSCRIPT_HAZE` wrapper around the `GetAllActorsOfClass` global function block; keep the binding code.
- [x] 1.2 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_APlayerController.cpp`, remove the three `#if !WITH_ANGELSCRIPT_HAZE` wrappers around `AController`, `APlayerController`, and `APawn` binding blocks.
- [x] 1.3 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionShape.cpp`, remove the wrapper around `FCollisionShape` POD value-class registration.
- [x] 1.4 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Subsystems.cpp`, remove the wrapper around the `ULocalPlayerSubsystem::Get(LocalPlayer)` global function block.
- [x] 1.5 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UGameInstance.cpp`, remove the wrapper around local-player creation and management bindings.
- [x] 1.6 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ULocalPlayer.cpp`, remove the wrapper around `GetGameInstance` / `GetControllerId`.
- [x] 1.7 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp`, remove both wrappers around `IsSupportedForNetworking` and `LoadObject`.
- [x] 1.8 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UWorld.cpp`, remove the wrapper around `ServerTravel`, `GetNetMode`, and `GetGameState`.
- [x] 1.9 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`, remove the wrapper around `Replicated`, `ReplicationCondition`, and `NotReplicated` UPROPERTY specifier handling.
- [x] 1.10 <!-- TDD --> Run build verification through the final build gates listed in section 5.
- [x] 1.11 <!-- TDD --> Covered by focused actor, UFUNCTION, networking, and debugger database tests listed in section 5.

## 2. Category B - delete Haze-only RPC syntax and metadata

- [x] 2.1 <!-- Non-TDD --> In `AngelscriptPreprocessor.cpp`, delete the `NetFunction` / `CrumbFunction` / `DevFunction` UFUNCTION branch and remove `PP_NAME_NetFunction`, `PP_NAME_CrumbFunction`, and `PP_NAME_DevFunction` if no longer referenced.
- [x] 2.2 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`, remove `FAngelscriptFunctionDesc::bNetFunction`, `bDevFunction`, and related equality comparisons.
- [x] 2.3 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp`, delete the `#if WITH_ANGELSCRIPT_HAZE` block that sets `FUNC_NetFunction`, `FUNC_DevFunction`, `HazeFunctionFlags`, and `HAZEFUNC_CrumbFunction`; remove `FUNCMETA_CrumbFunction`.
- [x] 2.4 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`, remove both `FUNC_NetFunction` BlueprintEvent binding branches.
- [x] 2.5 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h` and `.cpp`, remove `bNetFunction` / `bDevFunction` storage, serialization, load, and restore logic, and bump the precompiled cache schema identifier.
- [x] 2.6 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.cpp`, remove the `bNetFunction` dump column/value if it only reflects the removed Haze-only descriptor field.
- [x] 2.7 <!-- Non-TDD --> Sweep active scripts/tests for Haze-only specifiers: `rg -n "NetFunction|CrumbFunction|DevFunction" Script Plugins\Angelscript\Source\AngelscriptTest Plugins\Angelscript\Source\AngelscriptRuntime`; remaining hits are standard UE RPC helper names or intentional negative tests.
- [x] 2.8 <!-- TDD --> Run build verification through the final build gates listed in section 5.
- [x] 2.9 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Networking" -Label haze-networking -TimeoutMs 900000`.

## 3. Category C/D - keep non-Haze behavior and remove debugger flag

- [x] 3.1 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_WorldCollision.cpp`, keep the current `System` namespace branch and delete the `AsyncTrace` alternative branch.
- [x] 3.2 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.cpp`, replace the conditional `AS_ENSURE` definition with an unconditional `#define AS_ENSURE ensureMsgf`.
- [x] 3.3 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`, delete the Haze-only cooked exception dialog branch guarded by `WITH_ANGELSCRIPT_HAZE`.
- [x] 3.4 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h`, remove `FAngelscriptDebugDatabaseSettings::bUseAngelscriptHaze`, remove its serialization, and bump the message version.
- [x] 3.5 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp`, remove the assignment to `DebugSettings.bUseAngelscriptHaze`.
- [x] 3.6 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerDatabaseTests.cpp`, remove the assertion that mirrors `bUseAngelscriptHaze` against `!!WITH_ANGELSCRIPT_HAZE`.
- [x] 3.7 <!-- TDD --> Run build verification through the final build gates listed in section 5.
- [x] 3.8 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Debugger.Database" -Label haze-debugger-database -TimeoutMs 900000`.

## 4. Category A - restore UE-original actor names

- [x] 4.1 <!-- TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`, rename the script binding signature from `"APawn GetActorInstigator() const"` to `"APawn GetInstigator() const"`.
- [x] 4.2 <!-- TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`, rename the script binding signature from `"AController GetActorInstigatorController() const"` to `"AController GetInstigatorController() const"`.
- [x] 4.3 <!-- TDD --> In `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorPropertyInterfaceTests.cpp`, migrate inline AS calls to `GetInstigator()` and `GetInstigatorController()` and keep behavior assertions.
- [x] 4.4 <!-- Non-TDD --> Sweep active source/scripts for old names: `rg -n "GetActorInstigator|GetActorInstigatorController" Plugins\Angelscript\Source Script`; remaining hits are intentional negative-test source/diagnostics.
- [x] 4.5 <!-- TDD --> Run build verification through the final build gates listed in section 5.
- [x] 4.6 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Actor.PropertyInterface" -Label haze-actor -TimeoutMs 900000`.
- [x] 4.7 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Networking" -Label haze-networking -TimeoutMs 900000`.

## 5. Final macro removal, docs, and validation

- [x] 5.1 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`, delete the `#ifndef WITH_ANGELSCRIPT_HAZE` / `#define WITH_ANGELSCRIPT_HAZE 0` / `#endif` block.
- [x] 5.2 <!-- Non-TDD --> Verify active source is clean: `rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source` returns zero matches.
- [x] 5.3 <!-- Non-TDD --> Update active documentation references in `Documents/Knowledges/ZH/Syntax_UFUNCTION.md` and related guides to state that the Haze macro path was removed by this OpenSpec change.
- [x] 5.4 <!-- Non-TDD --> Verify active docs/config/scripts are clean, excluding OpenSpec history. Historical/generated Reports, Temp notes, and deprecated Plans still retain historical references.
- [x] 5.5 <!-- Non-TDD --> Add a "Recently Completed Milestones" entry to `AGENTS.md` and `AGENTS_ZH.md` when the implementation lands.
- [x] 5.6 <!-- TDD --> Final build: `Tools\RunBuild.ps1 -Label haze-precommit -TimeoutMs 900000`; earlier pass also covered `Tools\RunBuild.ps1 -Label haze-after-actor-test-fix -TimeoutMs 900000` after the negative-test adjustment.
- [x] 5.7 <!-- TDD --> Focused final suites: actor property interface 7/7, UFUNCTION coverage 44/44, networking coverage 27/27, debugger database 1/1. Full Functional suite was not run in this turn.
- [x] 5.8 <!-- Non-TDD --> Validate OpenSpec: `openspec validate refactor-as-audit-remove-with-angelscript-haze --strict --json`.
