# Design: Code Coverage as Engine Extension

## Context

The current code coverage system is created during `FAngelscriptEngine` initialization through conditional compilation and a raw pointer:

```cpp
// AngelscriptEngine.cpp:1816-1821
#if WITH_AS_COVERAGE
    if (FAngelscriptCodeCoverage::CoverageEnabled())
    {
        CodeCoverage = new FAngelscriptCodeCoverage;
    }
#endif

// AngelscriptEngine.cpp:2007-2015
#if WITH_EDITOR && WITH_AS_COVERAGE
    FCoreDelegates::OnPostEngineInit.AddLambda([&]()
    {
        if (CodeCoverage != nullptr)
        {
            CodeCoverage->AddTestFrameworkHooks();
        }
    });
#endif
```

**Problems In The Current Architecture:**

1. **Unclear lifecycle**: `CodeCoverage` is a raw pointer member with no clear destruction path. A code search found no `delete CodeCoverage` call, so this may leak memory.

2. **Split initialization**: object creation happens in `Initialize_AnyThread()`, while test framework hook registration is delayed through a callback in `PostInitialize_GameThread()`. The logic is scattered.

3. **Lambda closure capture**: the `OnPostEngineInit` lambda captures `this`. If the engine is destroyed before the callback fires, the closure may hold a dangling reference.

4. **Poor engine-instance coupling**: coverage data is accessed through an engine member pointer, but multi-engine environments have no clear isolation.

5. **Extension mechanism unused**: the project already has `IAngelscriptExtension`, but code coverage does not use it, making architecture inconsistent.

**Existing Extension Mechanism:**

Using `FClassReloadHelperExtension` and the planned `FAngelscriptCrashSnapshotExtension` as references, the extension system provides:

- clear lifecycle hooks: `OnEngineAttached` / `OnEngineDetached`
- per-engine-instance management, with each extension instance associated with an engine instance
- a unified registration point during module startup

## Goals / Non-Goals

**Goals:**

- Manage the code coverage system through the `IAngelscriptExtension` interface.
- Remove the raw `CodeCoverage` pointer member from the engine.
- Remove the `OnPostEngineInit` lambda closure and initialize directly when the engine attaches.
- Support independent coverage tracking in multi-engine-instance environments.
- Ensure `FAngelscriptCodeCoverage` is destroyed correctly with no memory leak.
- Preserve existing coverage APIs and report generation behavior.

**Non-Goals:**

- Do not change coverage data collection logic or report format.
- Do not modify public APIs such as `MapExecutableLines`, `HitLine`, or `StartRecording`.
- Do not optimize coverage tracking performance as part of this refactor.
- Do not change `WITH_AS_COVERAGE` compile condition behavior.

## Decisions

### Decision 1: Coverage Object Ownership Strategy

**Choice: the extension owns `FAngelscriptCodeCoverage` through `TUniquePtr`.**

**Rationale:**

- `FAngelscriptCodeCoverage` is not managed through `TSharedPtr`; `TUniquePtr` gives clear exclusive ownership.
- Each engine instance should have independent coverage data and should not share it.
- `TUniquePtr` destroys automatically, solving the possible existing memory leak.
- The extension lifetime matches the engine instance lifetime, making exclusive ownership appropriate.

**Alternatives:**

- Global singleton: cannot support independent tracking across multiple engine instances.
- Raw pointer: requires manual lifecycle management and is error-prone.
- `TSharedPtr`: overdesigned because the coverage object does not need shared ownership.

**Implementation Sketch:**

```cpp
class FAngelscriptCodeCoverageExtension : public IAngelscriptExtension
{
private:
    TUniquePtr<FAngelscriptCodeCoverage> Coverage;
    FAngelscriptEngine* AttachedEngine = nullptr;
    
public:
    virtual void OnEngineAttached(FAngelscriptEngine& Engine) override
    {
        if (FAngelscriptCodeCoverage::CoverageEnabled())
        {
            Coverage = MakeUnique<FAngelscriptCodeCoverage>();
            AttachedEngine = &Engine;
            
            #if WITH_EDITOR
            Coverage->AddTestFrameworkHooks();
            #endif
        }
    }
    
    virtual void OnEngineDetached(FAngelscriptEngine& Engine) override
    {
        Coverage.Reset();
        AttachedEngine = nullptr;
    }
};
```

### Decision 2: Engine Access Strategy

**Choice: find the extension through the extension registry, then access the coverage object.**

**Rationale:**

- Removes the engine member pointer and decouples the engine from the coverage system.
- Makes coverage an optional extension rather than a core engine field.
- Preserves API compatibility by routing existing call sites through helper functions.

**Alternatives:**

- Keep the engine member pointer: violates the extension refactor goal.
- Global accessor: cannot support multiple engine instances.

**Implementation Sketch:**

```cpp
// AngelscriptCodeCoverage.h
class FAngelscriptCodeCoverageExtension : public IAngelscriptExtension
{
public:
    FAngelscriptCodeCoverage* GetCoverage() const { return Coverage.Get(); }
    
    // Static helper: find the coverage object for a specific engine.
    static FAngelscriptCodeCoverage* GetForEngine(FAngelscriptEngine& Engine);
};

// Engine call sites become:
FAngelscriptCodeCoverage* Coverage = FAngelscriptCodeCoverageExtension::GetForEngine(*this);
if (Coverage != nullptr)
{
    Coverage->MapExecutableLines(Module);
}
```

### Decision 3: Test Framework Hook Registration Timing

**Choice: call `AddTestFrameworkHooks()` immediately in `OnEngineAttached`.**

**Rationale:**

- Removes the dependency on `FCoreDelegates::OnPostEngineInit`.
- The automation test module should already be loaded in editor environments when the engine attaches.
- Avoids lifecycle problems caused by lambda closure captures.
- Keeps initialization local and straightforward.

**Alternatives:**

- Keep `OnPostEngineInit`: unnecessary delay and added complexity.
- Delay until first use: increases state management complexity.

**Risk Mitigation:**

- `AddTestFrameworkHooks()` should check whether the automation test module is available.
- If the module is not loaded, log a warning or fail silently, but do not block engine initialization.

### Decision 4: Coverage Object Access Boundary

**Choice: keep coverage access local to an engine instance and do not provide global access.**

**Rationale:**

- Each engine instance has independent coverage data.
- Avoids data confusion in multi-engine environments.
- Matches the extension system design principles.

**Implementation Details:**

- Engine internals access coverage through `FAngelscriptCodeCoverageExtension::GetForEngine(*this)`.
- External code must access coverage through an engine instance; no static global accessor is provided.
- Tests can directly create extension instances for unit testing.

### Decision 5: Extension Registration Location

**Choice: register the extension in `FAngelscriptRuntimeModule::StartupModule()`.**

**Rationale:**

- The extension must be registered before any engine instance is created.
- Module startup is the earliest initialization point.
- This keeps behavior consistent with the crash snapshot extension.

**Implementation Sketch:**

```cpp
void FAngelscriptRuntimeModule::StartupModule()
{
    #if WITH_AS_COVERAGE
    FAngelscriptEngineExtensionRegistry::Get().RegisterExtension(
        MakeShared<FAngelscriptCodeCoverageExtension>());
    #endif
}
```

## Risks / Trade-offs

### Risk 1: Test Framework Hook Registration Failure

**Risk:** if the automation test module is not loaded when `OnEngineAttached` runs, `AddTestFrameworkHooks()` may fail.

**Mitigation:**

- Check whether `IAutomationControllerModule` is available inside `AddTestFrameworkHooks()`.
- If unavailable, log a warning without blocking engine initialization.
- In editor environments, the automation module is usually loaded by the time engine subsystem initialization runs.

### Risk 2: Coverage Lookup Performance

**Risk:** finding the coverage object through the extension registry may add overhead.

**Mitigation:**

- Coverage tracking is a development-time feature, so performance is not the primary concern.
- The engine can cache the extension pointer if needed.
- `GetForEngine()` should be efficient, either direct lookup or O(N), where N is the extension count and normally small.

### Risk 3: Coverage Data Management Across Multiple Engines

**Risk:** behavior for merging or distinguishing coverage data across multiple engines is unclear.

**Acceptance Rationale:**

- The current implementation does not support merged multi-engine coverage data either.
- Each engine instance generating its own coverage report is expected behavior.
- Merging can be added later if needed and is out of scope for this refactor.

### Trade-off 1: Extension Lookup vs Direct Engine Member Access

**Trade-off:** removing the engine member pointer means coverage access uses an extension lookup and adds indirection.

**Acceptance Rationale:**

- The architectural decoupling is more valuable than the small performance cost.
- Coverage tracking calls already carry overhead and are not on a performance-critical path in normal builds.
- Caching remains available if lookup becomes a bottleneck.

### Trade-off 2: Per-Engine Instance Coverage vs Global Singleton

**Trade-off:** each engine instance owning its own coverage object increases memory use.

**Acceptance Rationale:**

- Per-engine-instance support is the correct architecture.
- In typical use, coverage is enabled in a single-engine environment.
- The added object memory is negligible compared with coverage data itself.

## Migration Plan

### Implementation Steps

1. **Create the extension class**
   - Add `FAngelscriptCodeCoverageExtension` to `AngelscriptCodeCoverage.h`.
   - Implement `OnEngineAttached` and `OnEngineDetached`.
   - Own the coverage object with `TUniquePtr<FAngelscriptCodeCoverage>`.

2. **Add access helper**
   - Implement static `FAngelscriptCodeCoverageExtension::GetForEngine(FAngelscriptEngine&)`.
   - Find the extension instance through the extension registry and return its coverage pointer.

3. **Remove engine member pointer**
   - Delete the `CodeCoverage` member from `FAngelscriptEngine`.
   - Delete `CodeCoverage = new FAngelscriptCodeCoverage` from `Initialize_AnyThread()`.
   - Delete the `OnPostEngineInit` lambda from `PostInitialize_GameThread()`.

4. **Update engine-internal call sites**
   - Find all `CodeCoverage` access.
   - Replace access with `FAngelscriptCodeCoverageExtension::GetForEngine(*this)`.
   - Main call sites: `MapExecutableLines`, `HitLine`, and state export.

5. **Register the extension**
   - Register the extension in `FAngelscriptRuntimeModule::StartupModule()`.
   - Guard registration with `#if WITH_AS_COVERAGE`.

6. **Build and verify**
   - Run `Tools\RunBuild.ps1` and confirm compilation succeeds.
   - Verify editor startup has no error logs.
   - Confirm coverage functionality works in tests.

7. **Test coverage behavior**
   - Run automation tests and generate a coverage report.
   - Verify report format and content are unchanged.
   - Test multi-engine scenarios if coverage tests exist.

8. **Cleanup and docs**
   - Check for stale references.
   - Update relevant documentation and comments.

### Rollback Strategy

If issues occur, rollback is straightforward:

1. Restore the `FAngelscriptEngine::CodeCoverage` member pointer.
2. Restore initialization code in `Initialize_AnyThread()` and `PostInitialize_GameThread()`.
3. Remove extension registration.
4. Delete the extension class.

All changes are additive around the existing core logic and should not affect the code coverage feature internals.

### Verification Checklist

- [ ] Code coverage initializes during editor startup when `CoverageEnabled()` is true.
- [ ] Test framework hooks register correctly and coverage tracks during test runs.
- [ ] Coverage report generation works and output format is unchanged.
- [ ] Repeated engine creation/destruction does not leak memory.
- [ ] `MapExecutableLines` and `HitLine` calls work correctly.
- [ ] State export includes coverage information when enabled.
- [ ] No memory leak remains from missing `delete CodeCoverage`.

## Open Questions

1. **Should coverage data be merged across engine instances?**
   - Current design keeps coverage data independent per engine instance.
   - If merging is needed, it can be implemented during report generation.
   - Recommendation: keep data independent for now and extend later if needed.

2. **Should a global accessor be provided for external tools?**
   - Current design requires access through an engine instance.
   - External tools such as coverage analyzers may need direct access.
   - Recommendation: implement engine-local access first, then add a global accessor only if external tools require it.

3. **Should the extension cache the engine pointer?**
   - Current design stores an `AttachedEngine` pointer.
   - This may be useful for future engine-instance association needs.
   - Recommendation: keep it even if unused initially.
