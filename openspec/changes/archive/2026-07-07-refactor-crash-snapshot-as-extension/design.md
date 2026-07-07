# Design: Crash Snapshot as Engine Extension

## Context

The current crash snapshot system is globally initialized in `FAngelscriptRuntimeModule::StartupModule()` through the static `FAngelscriptCrashSnapshot::Startup()` function, which registers an `FCoreDelegates::OnHandleSystemError` callback. The callback is unregistered through `Shutdown()` when the module unloads.

**Problems In The Current Architecture:**

1. **Incorrect lifecycle coupling**: crash snapshots are tied to module lifecycle rather than engine instance lifecycle. A process can contain multiple `FAngelscriptEngine` instances, such as in tests or editor contexts, but there is only one global crash handler.

2. **No engine instance awareness**: on crash, the system uses `FAngelscriptEngine::TryGetCurrentEngine()` to get the current engine, but this depends on the engine context stack being correct. In crash scenarios, the stack may already be corrupted or point at the wrong instance.

3. **Cannot be disabled on demand**: as a globally initialized system, crash snapshots cannot be enabled or disabled for a specific engine instance.

4. **Violates the extension architecture**: the project already has `IAngelscriptExtension` / `FAngelscriptEngineExtensionRegistry` for engine lifecycle management, but the crash snapshot system does not use it.

**Existing Extension Mechanism:**

- `IAngelscriptExtension` interface: `OnEngineAttached(FAngelscriptEngine&)` and `OnEngineDetached(FAngelscriptEngine&)`.
- `FAngelscriptEngineExtensionRegistry::Get().RegisterExtension(Extension)` registers an extension.
- Extensions automatically attach when an engine is created and detach when it is destroyed.
- Runtime reference implementation: `FAngelscriptCodeCoverageExtension`.
- Registry detail: `UnregisterExtension()` removes the extension from future attach/detach replay but does not call `OnEngineDetached()` for currently attached engines.

## Goals / Non-Goals

**Goals:**

- Manage the crash snapshot system through the `IAngelscriptExtension` interface.
- Register the crash handler when the first engine instance attaches and unregister it when the last instance detaches.
- Preserve the existing crash snapshot JSON format and output logic.
- Preserve compatibility for testing interfaces: `WriteSnapshotForTesting` and `ConfigureForTesting`.
- Support multi-engine-instance environments, where each engine instance is tracked independently but shares one global crash handler.

**Non-Goals:**

- Do not change crash snapshot output format or content structure.
- Do not modify crash snapshot write logic or performance characteristics.
- Do not support one crash handler per engine instance because UE's `OnHandleSystemError` is global.
- Do not add new diagnostic data collection in this refactor.

## Decisions

### Decision 1: Engine Reference Ownership Strategy

**Choice: keep weak engine association in the extension and resolve the current engine through the engine context stack during crashes.**

**Rationale:**

- `IAngelscriptExtension::OnEngineAttached` receives a raw `FAngelscriptEngine&`.
- Crash snapshots can trigger from any thread at any time, and the engine object may already be tearing down.
- Weak association, such as a raw pointer plus flags, avoids extending engine lifetime.
- The crash handler still uses `FAngelscriptEngine::TryGetCurrentEngine()` because a crash can occur in any engine context.

**Alternatives:**

- Strong `TSharedPtr<FAngelscriptEngine>`: impossible because `FAngelscriptEngine` is not managed through `TSharedPtr`.
- Store a list of engine pointers: requires thread-safe management and still cannot identify the active engine at crash time.

**Implementation:**

- Maintain a static reference counter inside the extension, similar to the `ClassReloadHelper` pattern.
- Register the global crash handler when the first engine attaches.
- Unregister the handler when the last engine detaches.
- Continue using `FAngelscriptEngine::TryGetCurrentEngine()` inside the crash handler.

### Decision 2: Global State Migration Strategy

**Choice: preserve existing global state and migrate only initialization timing.**

**Rationale:**

- Existing global state such as `GSystemErrorHandle`, `GOverrideOutputDir`, `GMarker`, and `GHandlingCrash` already lives in the `AngelscriptCrashSnapshot_Private` namespace.
- These values are process-level by nature and do not need per-engine separation.
- Crash handling must remain process-level because UE's `FCoreDelegates::OnHandleSystemError` is global.
- Moving this state into the extension class would add complexity without practical benefit.

**Alternatives:**

- Move global state into extension static members: adds complexity with no meaningful improvement.
- Per-engine crash configuration: not feasible because `OnHandleSystemError` is global.

**Implementation:**

- Keep global state in `AngelscriptCrashSnapshot_Private` unchanged.
- Make `Startup()` / `Shutdown()` internal-use methods called by the extension, or keep them public with documentation.
- Keep test interfaces such as `ConfigureForTesting` public and have them operate on the global state directly.

### Decision 3: Extension Registration Location

**Choice: register the extension in `FAngelscriptRuntimeModule::StartupModule()`.**

**Rationale:**

- The extension must be registered before any engine instance is created.
- Module startup is the earliest initialization point.
- This follows the `FClassReloadHelper::Init()` pattern, which registers in the `AngelscriptEditor` module startup.

**Alternatives:**

- Register during first engine initialization: too late and may miss engine creation events.
- Delayed registration plus `ReplayCurrentEngine()`: adds complexity and diverges from the current pattern.

**Implementation:**

```cpp
void FAngelscriptRuntimeModule::StartupModule()
{
    CrashSnapshotExtensionHandle = FAngelscriptCrashSnapshotExtension::Startup();
}
```

### Decision 4: Reference Counting And Multi-Engine Support

**Choice: use an atomic active-engine count plus an attached-engine set.**

**Rationale:**

- The global crash handler should be active while any engine instance exists and inactive only after all instances are destroyed.
- A `std::atomic<int32>` count provides thread-safe visibility for tests and lifecycle checks.
- A `TSet<FAngelscriptEngine*>` guarded by `FCriticalSection` prevents duplicate attach or unknown detach from corrupting the count.
- Module shutdown must unregister the extension and then force-clean the attached-engine set/count because registry unregister does not detach current engines.

**Implementation:**

```cpp
class FAngelscriptCrashSnapshotExtension : public IAngelscriptExtension
{
public:
    virtual void OnEngineAttached(FAngelscriptEngine& Engine) override
    {
        if (Engine was already attached)
        {
            return;
        }

        if (++GActiveEngineCount == 1)
        {
            FAngelscriptCrashSnapshot::Startup();
        }
    }
    
    virtual void OnEngineDetached(FAngelscriptEngine& Engine) override
    {
        if (Engine was not attached)
        {
            return;
        }

        if (--GActiveEngineCount == 0)
        {
            FAngelscriptCrashSnapshot::Shutdown();
        }
    }

    static void Shutdown(FDelegateHandle& Handle)
    {
        UnregisterExtension(Handle);
        ClearAttachedEngineState();
        FAngelscriptCrashSnapshot::Shutdown();
    }
};
```

## Risks / Trade-offs

### Risk 1: Crash Handler Unregistration Timing

**Risk:** if a crash occurs during engine destruction, the crash handler might already be unregistered.

**Mitigation:**

- Engine destruction triggers `OnEngineDetached` while the engine is still valid.
- The handler unregisters only after the final engine detaches, when no script execution should remain active.
- This remains close to the current module-unload unregistration timing.

### Risk 2: Multithreaded Crash Scenario

**Risk:** one thread may trigger a crash while another thread is attaching or detaching an engine.

**Mitigation:**

- `GHandlingCrash` ensures the crash handler executes only once.
- Reference count operations should be atomic, using `FPlatformAtomics` or `std::atomic`.
- The crash handler itself should stay lock-free and not depend on extension object state.

### Trade-off 1: Global Crash Handler Limitation

**Trade-off:** there is still only one global crash handler, so it cannot directly identify which engine instance caused the crash.

**Acceptance Rationale:**

- UE's `OnHandleSystemError` is global.
- `FAngelscriptEngine::TryGetCurrentEngine()` is already the best available mechanism for finding the active engine.
- Stronger multi-engine isolation would require deeper architecture changes and is out of scope.

### Trade-off 2: Static Testing Interfaces

**Trade-off:** testing interfaces such as `ConfigureForTesting` and `WriteSnapshotForTesting` remain static and cannot target a specific engine instance.

**Acceptance Rationale:**

- Preserves backward compatibility.
- Tests usually run with a single engine instance.
- If multi-engine tests need this later, they can control the active context used by `FAngelscriptEngine::TryGetCurrentEngine()`.

## Migration Plan

### Implementation Steps

1. **Create the extension class**
   - Add `FAngelscriptCrashSnapshotExtension` to `AngelscriptCrashSnapshot.h`.
   - Implement `OnEngineAttached` and `OnEngineDetached`.
   - Add a static reference counter.

2. **Refactor initialization logic**
   - Make `Startup()` / `Shutdown()` private, or keep them public but document them as internal-use.
   - Call these methods from the extension.

3. **Register the extension**
   - Register the extension in `FAngelscriptRuntimeModule::StartupModule()`.
   - Remove the direct `Startup()` call.

4. **Clean module code**
   - Remove the `Shutdown()` call from `FAngelscriptRuntimeModule::ShutdownModule()`.
   - Store the extension handle and call `FAngelscriptCrashSnapshotExtension::Shutdown(Handle)` during module unload.
   - Ensure shutdown force-cleans handler state even if engines are still alive.

5. **Verify tests**
   - Run CrashSnapshot focused tests.
   - Run CrashOnly child-process verification.

### Rollback Strategy

If issues occur, rollback is straightforward:

1. Restore direct calls in `FAngelscriptRuntimeModule::StartupModule()` and `ShutdownModule()`.
2. Remove extension registration.
3. Delete the extension class.

All changes are additive around the existing feature internals and should not affect core crash snapshot logic.

### Verification Checklist

- [ ] Crash snapshot registers correctly during editor startup.
- [ ] Crashes in PIE generate snapshots correctly.
- [ ] Crash snapshot JSON format is unchanged.
- [ ] Test interface `WriteSnapshotForTesting` still works.
- [ ] Repeated engine creation/destruction does not leak or double-register.
- [ ] Crash handler unregisters correctly during module unload.

## Open Questions

1. **Should crash snapshot configuration be per engine instance?**
   - Current design keeps configuration global because `ConfigureForTesting` is static.
   - Per-engine configuration storage can be added later if needed.
   - Recommendation: keep global configuration for now and extend later if required.

2. **Should crash snapshots record engine instance ID?**
   - The JSON output could include the engine instance pointer or ID.
   - This would help debugging multi-engine environments.
   - Recommendation: treat this as a later improvement and keep it out of this refactor.

3. **Should extension registration failure have explicit error handling?**
   - Current design assumes extension registration succeeds.
   - Recommendation: add logging, but do not block module startup.
