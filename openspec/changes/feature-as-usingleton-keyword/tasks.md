## 1. Parser contract and descriptors

- [ ] 1.1 Read `attachments/syntax-and-lowering.md` into the implementation checklist and add failing `AngelscriptPreprocessorSingletonTests.cpp` cases for no macro, `USINGLETON()`, Global, World, namespace placement and comments/strings.
- [ ] 1.2 Add failing parser diagnostics for macro-without-keyword, unsupported scope, malformed `of`, duplicate definition ID, generated namespace collision, duplicate lifecycle blocks and wrong lifecycle shapes.
- [ ] 1.3 Replace regex-only singleton/literal assumptions with token-aware recognition in `Preprocessor/AngelscriptPreprocessor.h/.cpp`, preserving source lines and diagnostics through lowering.
- [ ] 1.4 Add `FAngelscriptSingletonDesc` and key/scope enums to Runtime Core, including source location, stable definition ID, declared class reference, lifecycle entries, descriptor hash, type dependency and per-body hashes.
- [ ] 1.5 Extend `FAngelscriptModuleDesc` and `StaticJIT/PrecompiledData.h/.cpp` archive round trips for Singleton descriptors, bumping any affected archive/schema version and adding round-trip tests.
- [ ] 1.6 Lower named declarations to collision-proof hidden lifecycle functions plus `Name::Get` overloads; user Init/Reload/Deinit blocks remain parameterless, but each hidden global is exactly `void __Lifecycle(Type __Receiver) external_implicit_this`, and compilation/module activation no longer schedules them through `PostInitFunctions`.
- [ ] 1.7 Add post-compile lowering assertions for every lifecycle entry: global `objectType`, one declared-Type parameter zero, external-implicit-this trait, stable descriptor target, no native object slot, and explicit Registry argument-zero invocation; cover unqualified member/method/accessor, explicit `this`, normal name shadowing, malformed lowering rejection, bytecode/cache round trip, and Typed Semantic AOT receiver-alias/fallback compatibility.

## 2. Default API and Engine-owned Registry

- [ ] 2.1 Add failing bind-surface tests for `Singleton::GetGlobal(UClass)` and `Singleton::GetWorld(UClass, UObject)`, including `DeterminesOutputType`, null Type and explicit invalid Context.
- [ ] 2.2 Add new `Core/AngelscriptSingletonRegistry.h/.cpp` with separate named/default key types, weak World keys, per-scope creation sequences and `Empty/Creating/Initializing/Ready/Releasing` states.
- [ ] 2.3 Add the Registry as a unique member of each `FAngelscriptEngine`; initialize it after core bindings, register World cleanup hooks, and release it before script engine teardown.
- [ ] 2.4 Implement the GC ownership bridge for candidates and Ready instances without `RF_MarkAsRootSet`, and add an isolation test proving one Engine shutdown cannot release another Engine's slots.
- [ ] 2.5 Add `Binds/Bind_Singleton.cpp` (and helper header/source only if the bind requires them) for the generic default API and the generated named Getter bridge.
- [ ] 2.6 Implement strict explicit/ambient World resolution using the current Engine context only; add tests that no path reads `GWorld` or selects a World from the global World-context list.

## 3. Creation and lifecycle state machine

- [ ] 3.1 Add failing runtime tests for lazy first Get, repeated identity, same-Type/different-name instances, named/default separation and multi-Engine Global isolation.
- [ ] 3.2 Implement ordinary Global and World UObject creation with validated Type, Outer/World ownership and Game Thread guards.
- [ ] 3.3 Add failing World tests, then implement Actor deferred spawn/finalization, UserWidget creation and ActorComponent NewObject/Register paths.
- [ ] 3.4 Add compile/runtime rejection for abstract, CDO/archetype, subsystem/collection-owned, cross-World and Scope-incompatible Types with actionable diagnostics.
- [ ] 3.5 Implement validated custom Create for Global and World, rejecting null, borrowed, duplicate-owned, wrong-Type and wrong-World candidates.
- [ ] 3.6 Implement Init-before-publish, retry after Create/Init failure, complete recursive creation-chain diagnostics, and no partial-object visibility.
- [ ] 3.7 Implement reverse creation-order Deinit for per-World cleanup and Engine shutdown; make Deinit exceptions non-blocking for remaining cleanup.
- [ ] 3.8 Add GC, direct/indirect cycle, failure retry, two-World and Multiplayer PIE runtime tests described in `attachments/test-plan.md`.

## 4. Hot reload and PIE safety

- [ ] 4.1 Add descriptor/body/type dependency comparison to the Runtime reload planner and write failing classification tests for unchanged, body-only, compatible structure, identity change and Type change.
- [ ] 4.2 Implement non-PIE body-only routing that preserves object identity without replaying Init/Reload/Deinit.
- [ ] 4.3 Implement compatible structural replacement, reflected-property migration, Actor World/Level/Transform preservation and default-slot UClass pointer remapping by stable class path.
- [ ] 4.4 Publish one authoritative old-to-new singleton object map to `AngelscriptEditor/HotReload/ClassReloadHelper.h/.cpp`; ensure the Editor replaces references but never independently spawns a second object.
- [ ] 4.5 Implement delete+add reconciliation for named Name/Namespace/ModuleStableId/Scope/Type changes, with old Deinit and a new Empty lazy slot.
- [ ] 4.6 Add pre-commit failure rollback and post-commit Reload-failure invalidation tests so last-good module/slot behavior is explicit at both boundaries.
- [ ] 4.7 Add PIE pre-swap rejection for descriptor, lifecycle body, named Type and active default Type changes; queue the latest full reload without partially swapping related modules.
- [ ] 4.8 Add single-PIE and two-player PIE tests proving last-good Getter/object/lifecycle stability, unrelated soft reload allowance and one latest-source reload after PIE.

## 5. Tooling, migration and documentation

- [ ] 5.1 Add read-only singleton definition/slot rows to `Dump/AngelscriptStateDump.h/.cpp`, snapshots/diffs and tests; prove dumping an Empty definition does not create it.
- [ ] 5.2 Extend offline export/bundle schema with Singleton descriptors and add Standalone UE-validation signature checks plus non-executable runtime traps.
- [ ] 5.3 Add `Script/Examples/Core/Singletons.as` covering default Global, named Global, named World, Init, custom Create and explicit World Context.
- [ ] 5.4 Update Chinese-first plugin docs and generated API documentation, including exact literal-asset migration examples shared with `refactor-as-runtime-asset-model`.
- [ ] 5.5 Remove or rename obsolete literal-asset Getter expectations only in coordination with the Asset sibling; keep ownership of every deleted test explicit.

## 6. Verification checkpoints

- [ ] 6.1 Run `Tools\RunBuild.ps1` after Runtime/Editor compile surfaces and descriptor archives are complete.
- [ ] 6.2 Run `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Preprocessor.Singleton"` and `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Singleton"`.
- [ ] 6.3 Run `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.GC.Singleton"`, `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.HotReload.Singleton"` and all World/MultiplayerPIE Singleton prefixes from the test attachment.
- [ ] 6.4 Run `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Dump.Singleton"` and `Tools\RunTestSuite.ps1 -Suite Standalone`.
- [ ] 6.5 Run `Tools\RunTestSuite.ps1 -Suite All`, record exact discovered/pass/skip/fail counts, and compare them with the live testing guide rather than copying a stale baseline.
- [ ] 6.6 Run `openspec validate feature-as-usingleton-keyword --strict`, inspect `git diff --check`, and verify every requirement/scenario is covered by a test row before marking implementation tasks complete.
