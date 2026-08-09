## 1. Lifecycle Contract and Regression Tests

- [ ] 1.1 <!-- TDD --> Add focused Runtime/Functional tests proving `UScriptEngineSubsystem` stops ticking after collection-driven deinitialization, then normalize its initialized-state transition in `Subsystem/ScriptEngineSubsystem.h`.
- [ ] 1.2 <!-- TDD --> Add an Editor automation test for `UScriptEditorSubsystem` lifecycle/base-call behavior, then make `BaseClasses/ScriptEditorSubsystem.h` call `Super::Initialize` and `Super::Deinitialize` while preserving `FEditorScriptExecutionGuard`.
- [ ] 1.3 <!-- TDD --> Add collection-owned lifecycle tests for script World, GameInstance, and LocalPlayer subsystems: creation filtering, callback ordering, exact generated `Get()` result, scope isolation, and teardown.
- [ ] 1.4 <!-- Non-TDD --> Audit and normalize initialized-state visibility, callback ordering, and defensive Outer handling across the five script subsystem bases without changing their scope semantics.

## 2. Script Dependency Declaration

- [ ] 2.1 <!-- TDD --> Add a failing functional test for declaring a compatible subsystem dependency during script `Initialize`, including direct retrieval of the initialized instance.
- [ ] 2.2 <!-- TDD --> Add failing misuse tests for dependency requests outside initialization, null classes, and incompatible subsystem classes; assert diagnostics and no collection mutation.
- [ ] 2.3 Implement the initialization-scoped dependency bridge in the Runtime subsystem bases or a narrow shared helper, without binding or retaining `FSubsystemCollectionBase` in AngelScript.
- [ ] 2.4 Document the final public dependency API and its lifecycle restriction in the script subsystem example and Chinese-first user guidance.

## 3. Public Subsystem Boundary

- [ ] 3.1 <!-- TDD --> Update `AngelscriptSubsystemBindingsTests.cpp` so it proves ordinary native subsystem `::Get()` accessors remain available while `UAngelscriptSubsystem::Get()` is absent from AngelScript.
- [ ] 3.2 Exclude `UAngelscriptSubsystem` from generic native Subsystem accessor generation in `Binds/Bind_Subsystems.cpp` without changing its C++ engine-owner use sites.
- [ ] 3.3 <!-- Non-TDD --> Update examples and documentation to recommend `UScriptEngineSubsystem` for project-global script state and to accurately describe the supported World and Editor subsystem status.

## 4. Verification and Follow-up Boundaries

- [ ] 4.1 Run focused Binding, Functional Subsystem, HotReload Subsystem, Engine Subsystem, and Editor Subsystem automation prefixes through `Tools/RunTests.ps1`; record exact results in a verification note.
- [ ] 4.2 Run `Tools/RunBuild.ps1 -NoHotReloadFromIDE`; distinguish any unrelated existing `Bind_Primitives` build failure from subsystem regressions.
- [ ] 4.3 Reassess `UScriptDynamicSubsystem` and a tickable LocalPlayer variant only after the supported five-family lifecycle matrix passes; record a separate proposal if either needs new UE lifecycle semantics.
