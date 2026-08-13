# Runtime Request State Machine Notes

## 2026-08-14 — Tasks 5.5–5.7 TDD Start

### Scope

This increment adds the Engine-local Runtime JIT request/publication state machine only. It does not install or replace `asIJITCompiler`, mutate maintained-fork `Binding` objects, or move ownership from the temporary `FAngelscriptStaticJIT` facade; those remain group 6 work.

The state machine composes the current-revision Runtime backend registry/session contract and consumes only owned `FAngelscriptRuntimeJITCompileSnapshot` values. Its publication output is an immutable `VMEntry` plus `FAngelscriptRuntimeJITCodeLease` value for the future Coordinator to attach at an Engine safe point.

### Required State And Retry Rules

- Identity is exact across stable FunctionKey, FunctionRevision, Entry ABI hash, publication ordinal, backend/configuration selection generation, and cancellation generation.
- One exact request may be active. Same-revision observations coalesce; published revisions are reused; terminal deterministic outcomes are memoized.
- Reconfiguration must advance both backend/configuration and cancellation generations. It invalidates pending/published state and is the only retry trigger for unavailable/cancelled selections in this increment.
- `EagerSync` compiles and finalizes at the observing Engine safe point.
- `EagerBackground` compiles off-thread while calls continue through VM; only `ProcessPendingResults()` may publish.
- `LazyFirstCall` allows one concurrent claimant to compile on the caller thread, but that invocation still uses VM. The result remains queued until a later safe point.
- Replacement is guarded by the exact identity tuple. A completed old revision is stale, never attaches to the replacement function, and releases its code lease exactly once.
- Worker captures contain only the owned snapshot and a shared session owner. Session/code destruction is carried back through the completion queue so backend lifetime release does not occur accidentally on a worker.

### RED Evidence

Initial build:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label runtime-jit-state-red -TimeoutMs 1800000 -NoXGE
```

Result: expected missing `RuntimeJIT/AngelscriptRuntimeJITState.h`, plus an independent adaptive/non-unity compile failure in `AngelscriptJITBindingPublicationTests.cpp`: `ASTEST_AS_ANSI` was used without directly including `AngelscriptTestMacros.h`.

Root cause: the file had depended on a Unity neighbor's transitive include since its original multi-provider introduction. Adding the new test source changed the Unity grouping and exposed the undeclared dependency. The narrow fix adds the direct macro header include, matching the other StaticJIT tests.

Clean RED build:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label runtime-jit-state-red-clean -TimeoutMs 1800000 -NoXGE
```

Result: failed only at `AngelscriptRuntimeJITStateTests.cpp:1` because `RuntimeJIT/AngelscriptRuntimeJITState.h` does not exist. The earlier macro error did not recur. Logs:

- `Saved/Build/runtime-jit-state-red/20260814_021302_113_a3393852/Build.log`
- `Saved/Build/runtime-jit-state-red-clean/20260814_021409_202_26cbedd5/Build.log`

The RED package contains six focused cases under `Angelscript.TestModule.RuntimeJIT.Coordinator.Policy`: eager coalescing/publication, terminal retry generation, unavailable/cancelled no-spin behavior, background safe-point publication, one-claim lazy compilation with VM for the current call, and real module-replacement stale-result rejection.

## 2026-08-14 — Review RED And Lifecycle Hardening

The first implementation compiled and passed its initial focused suites:

- build: `Saved/Build/runtime-jit-state-green/20260814_022041_709_5add0171`
- policy: `6/6 PASS`, `Saved/Tests/runtime-jit-state-policy/20260814_022102_347_5a25c37e`
- backend contract regression: `9/9 PASS`, `Saved/Tests/runtime-jit-state-contract-regression/20260814_022216_450_bfaab2bf`
- snapshot regression: `9/9 PASS`, `Saved/Tests/runtime-jit-state-snapshot-regression/20260814_022317_229_69791fb8`

An independent read-only review then found two lifecycle/contract defects:

1. Background work was launched before its future was registered, while synchronous and lazy compiles were not tracked at all. Shutdown could therefore close an apparently empty task set and return while an admitted compile still referenced the state-machine implementation.
2. Individual function replacement and retirement called `Session->Cancel(generation)`. The backend ABI has no per-function cancellation token, so this API is generation-wide and could cancel unrelated same-generation functions or the replacement request itself.

Two focused tests captured these defects before the fix. The review RED run was `5/7 PASS` at `Saved/Tests/runtime-jit-state-review-red/20260814_023803_447_014dbc7a`:

- `ShutdownWaitsForClaimedLazyCompilation` proved Shutdown returned while a claimed lazy compile remained blocked.
- `ModuleReplacementRejectsTheCompletedOldRevision` proved replacement issued one generation-wide cancellation when it must issue none.

The corrected lifecycle now uses one Engine-local admission protocol:

- every accepted eager-sync, eager-background, or lazy compile increments an in-flight count while holding the state lock;
- background futures are registered before the admission lock is released;
- Shutdown serializes callers, closes admission, removes Engine-visible records, issues one generation cancellation for the selected session, waits for all admitted operations, joins registered futures, drains queued completions on the shutdown thread, and only then marks teardown complete;
- reconfiguration issues one cancellation for the retired selection generation;
- single-function replacement and retirement only detach the exact record and stale-drop its eventual completion; they never use the generation-wide cancellation API.

The review also tightened two observable result boundaries: invalid Entry ABI snapshots now report `EntryAbiMismatch`, and an eager synchronous observer reports `StaleRevision` when its own identity was replaced instead of borrowing the replacement record's state.

### Review GREEN Evidence

- first lifecycle-fix build: `Saved/Build/runtime-jit-state-review-green/20260814_024433_635_19b3f0e3`
- original plus review-RED policy cases: `7/7 PASS`, `Saved/Tests/runtime-jit-state-review-green/20260814_024459_597_ec855627`
- expanded review coverage build: `Saved/Build/runtime-jit-state-review-coverage-green/20260814_024837_469_8517f7de`
- expanded policy suite: `11/11 PASS`, `Saved/Tests/runtime-jit-state-review-coverage-green/20260814_024855_243_5f98e06d`

The final eleven policy tests additionally cover typed Entry ABI rejection, exact eager-sync replacement reporting, Shutdown racing an admitted eager-sync compile, and two same-generation functions where retiring one cannot cancel the other. During this expansion, one test-only build failed because `MoveTemp` was applied to a captured `const` snapshot; replacing that with an ordinary owned-value copy fixed the fixture without changing production behavior. The failure is retained at `Saved/Build/runtime-jit-state-review-coverage/20260814_024818_922_b6ce4e0b`.

The final independent re-review found no Critical, Important, or Minor issue and marked tasks 5.5–5.7 ready. It specifically rechecked admission accounting for all three policies, background registration under the state lock, lock ordering, generation-only cancellation sites, exact synchronous identity reporting, and typed Entry ABI diagnostics. A separately named background/Shutdown race fixture remains a non-blocking future coverage improvement because the same registered-operation path is statically shared and the existing background safe-point test executes it.
