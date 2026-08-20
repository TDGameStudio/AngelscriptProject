## 1. Explore and decide the host shape

- [x] 1.1 <!-- Non-TDD --> Survey UE UObject plugin/strategy patterns (Mass processors, Game Feature Actions, Movie Pipeline settings, RigVM compiler) and record them under `research/`.
- [x] 1.2 <!-- Non-TDD --> Compare those patterns with the landed coordinator, Runtime JIT factory ABI, `UAngelscriptSubsystem`, and the unmerged MIR/LLVM worktree plugins.
- [x] 1.3 <!-- Non-TDD --> Decide the subsystem `TArray` is an operational warm set plus one dispatch backend (not a hidden catalog-only list, and not dual-issue of one call).
- [x] 1.4 <!-- Non-TDD --> Decide discovery (`GetDerivedClasses` + settings BackendIds), host events without new `asIJITCompiler` virtuals, split update generations, and write specs.
- [x] 1.5 <!-- Non-TDD --> Record compiled-function handles (`research/jit-function-handles.md`): owning value type wrapping CodeLease, not UObject, not raw `VMEntry`.
- [x] 1.6 <!-- Non-TDD --> Close remaining host gaps (`research/remaining-gaps.md`): CLI compat, catalog without subsystem, isolated primary compare, debugger keep-warm, test fakes, INI name, late-load apply, PIE copies live primary.

## 2. UObject catalog

- [ ] 2.1 <!-- TDD --> Add abstract `UAngelscriptRuntimeJIT` and rebuild `UAngelscriptSubsystem::AvailableJITs` from `GetDerivedClasses`; skip the abstract base.
- [ ] 2.2 <!-- TDD --> Add two in-plugin fake subclasses with distinct BackendIds; duplicate-id disables Runtime only.
- [ ] 2.3 <!-- TDD --> Late module load rebuilds the catalog; unnamed new subclasses are not auto-warmed; an already-configured `RuntimeJITName` applies at the next safe point; unavailable (`IsAvailable()==false`) stays listed.
- [ ] 2.4 <!-- TDD --> Catalog helper works for a test `FAngelscriptEngine` with no `UAngelscriptSubsystem`; fake UCLASS types live in `AngelscriptTest`.
- [ ] 2.5 <!-- TDD --> Add `UAngelscriptSettings::RuntimeJITName` and optional `RuntimeJITWarmNames` on Engine config (not compile-options). `GetBackendId()` is the ini token, not `UObject::GetName`. Settings then CLI for the primary Engine; missing extra warm names do not drop a valid dispatch; not ConfigRestartRequired.

## 3. Warm set, dispatch, switch

- [ ] 3.1 <!-- TDD --> Coordinator owns one session/state machine per warm BackendId; only dispatch publishes `SetJITBinding`.
- [ ] 3.2 <!-- TDD --> Capture bytecode once per function revision and stamp per-backend snapshot views.
- [ ] 3.3 <!-- TDD --> Dispatch switch advances only `DispatchGeneration` and reuses published results; it does not cancel the other backend.
- [ ] 3.4 <!-- TDD --> Removing dispatch from the warm set is refused; removing a non-dispatch backend drains only that session.
- [ ] 3.5 <!-- TDD --> Dispatch `EagerSync` still returns before non-dispatch warm compiles finish (`EagerBackground` for extras).
- [ ] 3.6 <!-- TDD --> Introduce `FAngelscriptRuntimeJITFunctionHandle`; warm cache and dispatch/compare/events use handles; Binding.UserData shares the same artifact; raw `VMEntry` stays internal.

## 4. Host events and update generations

- [ ] 4.1 <!-- TDD --> `OnFunctionReady` assigns a new ordinal, queues `FunctionObserved`, and does not compile.
- [ ] 4.2 <!-- TDD --> `OnJITEntry` claims lazy compile for dispatch only and never fires UObject delegates off-thread; events flush at the safe point.
- [ ] 4.3 <!-- TDD --> Hot reload retires the old ordinal on every warm backend; old leases survive until readers exit.
- [ ] 4.4 <!-- TDD --> Unload of a non-dispatch backend waits for its readers, then catalog removal, without detaching the dispatch Binding.

## 5. Compare and diagnostics

- [ ] 5.1 <!-- TDD --> Compare requires `RuntimeOnly`; test Engines may compare in place; the primary Editor Engine uses an isolated child Engine and is unchanged after the pass.
- [ ] 5.2 <!-- TDD --> Compare records handle identity, compile latency, code size, and ns/op rows; unsupported backends become rows, not aborted passes.
- [ ] 5.3 <!-- TDD --> Non-Shipping diagnostics and `as.RuntimeJIT.*` commands list warm set, dispatch, per-backend state, and compare output. Keep `-as-runtime-jit-backend=` as dispatch; default warm set empty.
- [ ] 5.4 <!-- TDD --> Debugger/coverage detaches Runtime Bindings but retains warm handles for republish after the gate lifts.
- [ ] 5.5 <!-- Non-TDD --> Stop coordinator `IModularFeatures` lookup after fake tests use UObject backends. MIR/LLVM `UCLASS` adapters stay out of this change.
