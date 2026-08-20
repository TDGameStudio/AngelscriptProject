## ADDED Requirements

### Requirement: Host events flush on the game thread

The coordinator SHALL derive host events from existing `asIJITCompiler` callbacks and Engine safe points. It SHALL NOT add virtuals to `asIJITCompiler`. `OnJITEntry` MAY run off the game thread and MUST NOT invoke UObject delegates. Queued events SHALL flush at `ProcessRuntimeSafePoint` or subsystem Tick onto a multicast delegate on `UAngelscriptSubsystem`.

#### Scenario: Function becomes ready

- **WHEN** the fork calls `OnFunctionReady` for an installed coordinator
- **THEN** that function receives a new publication ordinal
- **AND** a `FunctionObserved` event is queued
- **AND** no backend `Compile` runs inside `OnFunctionReady`

#### Scenario: Lazy first call stays on VM

- **WHEN** `OnJITEntry` claims a lazy compile for the dispatch backend
- **THEN** the claiming invocation continues through VM
- **AND** `CompileQueued` is visible only after the next game-thread flush

#### Scenario: Compile completion is observable

- **WHEN** a warm backend finishes a compile and the safe point processes the result
- **THEN** a `CompileCompleted` event names BackendId, function identity, outcome, compile latency, and code size
- **AND** a `Compiled` outcome includes a valid `FAngelscriptRuntimeJITFunctionHandle`

### Requirement: Update generations are independent

The coordinator SHALL track `PublicationOrdinal`, `FunctionRevision`, `WarmGeneration`, `DispatchGeneration`, and a per-backend `CancellationGeneration`. Script replacement SHALL retire one function ordinal on every warm backend. Warm-set changes SHALL cancel only the affected backend. Dispatch changes SHALL not cancel compiles.

#### Scenario: Hot reload retires all warm backends for one function

- **WHEN** `OnFunctionReady` runs for a replaced function that had published `fake-alpha` and `fake-beta` results
- **THEN** both previous ordinals are retired
- **AND** both backends may compile the new revision
- **AND** retired leases remain until Binding readers exit

#### Scenario: Policy change cancels compiles, dispatch switch does not

- **WHEN** compile policy changes from `EagerSync` to `EagerBackground`
- **THEN** `WarmGeneration` advances and in-flight compiles of warm backends are cancelled
- **WHEN** only dispatch changes from `fake-alpha` to `fake-beta`
- **THEN** `DispatchGeneration` advances
- **AND** neither backend’s cancellation generation advances

### Requirement: Plugin unload drains one backend

Unloading a backend module SHALL unregister its UObject from the catalog, refuse new sessions for that BackendId, and wait until that backend’s sessions and code leases have no active readers. Other warm backends and Static AOT SHALL keep running.

#### Scenario: Unload non-dispatch backend while a call uses its old Binding

- **WHEN** dispatch has already switched off `fake-beta` but an old `fake-beta` Binding reader is still in the function
- **THEN** module shutdown does not return until that reader exits and the `fake-beta` lease releases once
- **AND** current `fake-alpha` Bindings stay attached

### Requirement: Debugger and coverage keep warm handles detached

While debugger or coverage requires bytecode visibility, the coordinator SHALL NOT attach a Runtime Binding. It SHALL keep already-valid warm handles. After the gate lifts, the next safe point MAY republish the dispatch handle.

#### Scenario: Debugger attaches while Runtime is dispatched

- **WHEN** a function has a dispatch Runtime Binding and coverage or debugger then requires VM
- **THEN** the Runtime Binding is cleared
- **AND** the dispatch handle remains valid in the warm cache
- **AND** after the gate lifts, a later safe point may attach that handle again

### Requirement: Host mutations run at Engine safe points

Warm-set, dispatch, and compare APIs SHALL run on the game thread and SHALL take effect at `ProcessRuntimeSafePoint`. They SHALL NOT be invoked from `OnJITEntry`.

#### Scenario: Dispatch change is not applied inside OnJITEntry

- **WHEN** `OnJITEntry` runs on a VM thread
- **THEN** it may claim lazy compile for the current dispatch backend only
- **AND** it does not change dispatch or the warm set

