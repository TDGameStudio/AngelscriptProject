## Context

Research is in `research/ue-uobject-backend-patterns.md`. The user confirmed the subsystem list is an **active operational set**, not a hidden catalog: MIR and LLVM (and fakes in tests) must be usable together, switchable, and comparable.

Current host facts that this design keeps:

- `FAngelscriptJITCoordinator` is the only `asIJITCompiler` (`OnFunctionReady`, `OnJITEntry`, `ReleaseFunctionBinding`).
- `OnFunctionReady` only bumps a publication ordinal; compilation starts at `ProcessRuntimeSafePoint` after a verified function-route snapshot.
- `OnJITEntry` is a lazy-compile claim and may run off the game thread; the claiming call always stays on VM.
- `FAngelscriptRuntimeJITRequestStateMachine::Reconfigure` advances backend **and** cancellation generations and drops every published result. That is the wrong hammer for “switch MIR → LLVM”.
- `asSJITFunctionBinding` has one `VMEntry`. Two backends cannot execute the same call. Simultaneous use means **both stay compiled**; dispatch chooses which Binding is current.
- `UAngelscriptSubsystem` is process-global and owns the primary `FAngelscriptEngine`. Tests and StaticJIT generation create more Engines.

## Goals / Non-Goals

**Goals:**

- Plugin backends are `UCLASS` subclasses of `UAngelscriptRuntimeJIT`.
- The subsystem holds `TArray<TObjectPtr<UAngelscriptRuntimeJIT>>` of discovered backends.
- One Engine can warm two or more Runtime backends, switch dispatch without destroying the other code, and compare compile/steady-state metrics.
- Host callbacks report catalog, compile, dispatch, retirement, and compare outcomes on the game thread.
- Script hot reload, backend enable/disable, dispatch switch, and plugin unload use distinct update generations.
- Snapshot immutability, worker isolation from UObject, and code leases remain.

**Non-Goals:**

- Dual-issuing one AngelScript call through two native entries.
- Auto-picking MIR vs LLVM per function, or silent fallback chains (compare is explicit).
- Changing `asIJITCompiler` in the maintained fork in this change.
- Merging MIR/LLVM plugins, widening the scalar subset, Raw/Parms Runtime entries.
- Making Static AOT a UObject plugin.
- Blueprint-authorable JIT backends.
- Sampling every VM call for ns/op (compare uses an explicit pass).

## Architecture

```text
Plugin module (MIR / LLVM / test fake)
  UAngelscriptRuntimeJIT subclass (CDO discovered)

UAngelscriptSettings.RuntimeJITName     // ini: dispatch name if registered
UAngelscriptSubsystem
  AvailableJITs[]                       // process catalog, Outer = subsystem
  multicast host events                 // game thread only

FAngelscriptEngine (many)
  FAngelscriptJITCoordinator            // sole asIJITCompiler
    WarmSessions[BackendId]             // Engine-local session + state machine
    WarmHandles[FunctionKey][BackendId] // owning compiled-function handles
    DispatchHandle[FunctionKey]         // handle currently SetJITBinding'd
    HostEventQueue                      // flushed at safe point / Tick

asIJITCompiler callbacks (unchanged)
  OnFunctionReady -> new publication ordinal, retire previous ordinal
  OnJITEntry      -> lazy claim on dispatch backend only
  ReleaseFunctionBinding -> drop Binding context / lease reader
```

Bytecode is captured **once** per function revision at the safe point, then stamped with each warm BackendId for that backend’s session. Workers still never see UObjects.

## Decisions

### 1. UObject is the catalog/factory; the session stays an F-object

`UAngelscriptRuntimeJIT` is `UCLASS(Abstract, Transient)`:

- `GetBackendId()` (stable ini token; do **not** name this `GetName()`, which is `UObject::GetName`)
- `GetDisplayName()` (UI only)
- `IsAvailable()`, `GetMetadata()`
- `CreateSession(Config) -> TUniquePtr<IAngelscriptRuntimeJITBackendSession>`

`IsAvailable()` is false when a plugin is loaded but its SDK is missing (LLVM). Discovery still lists it; warm/dispatch reject it with `BackendUnavailable`.

`NewObject<UAngelscriptRuntimeJIT>(Subsystem, Class)` with `RF_Transient` for non-abstract subclasses found by `GetDerivedClasses`. Skip abstract classes and CDOs as live sessions. If a CDO is used only for metadata, Mass-style `AddToRoot` applies when GC disregard windows disagree.

Alternative rejected: the UObject **is** the live compiler. Subsystem is process-global; Engines are many; workers and GC cannot own RWX code.

### 2. Warm set versus dispatch

| Knob | Meaning |
| --- | --- |
| Warm set | Backends that have an Engine-local session and may compile/retain leases |
| Dispatch BackendId | The only Runtime Binding `SetJITBinding` will publish |

Rules:

- Dispatch MUST be in the warm set (or warm set auto-includes it).
- Warm set may contain backends that are not dispatch.
- Duplicate BackendIds across UObject classes are a configuration error; Runtime is disabled until unique.
- Order of `GetDerivedClasses` never selects dispatch. Settings / API names do.
- `Auto` still prefers exact Static AOT for **dispatch**. Warm Runtime compiles only if `bWarmRuntimeWhenStaticAOTPresent` is true (default false).
- `RuntimeOnly` ignores AOT for dispatch and uses the dispatch Runtime backend.
- `VMOnly` / `StaticAOTOnly` do not publish Runtime Bindings; they may still keep warm sessions idle or tear them down. Default: tear down Runtime sessions in `VMOnly`/`StaticAOTOnly` so compare/`RuntimeOnly` is explicit.

### 3. Do not extend `asIJITCompiler` this change

The fork already has the three callbacks the VM can call. Extra virtuals would churn the maintained fork without giving a game-thread observer.

Host events are **derived**:

| Fork / coordinator point | Host event (game thread) |
| --- | --- |
| Catalog rebuild | `CatalogChanged` |
| `OnFunctionReady` | queued `FunctionObserved` (ordinal assigned; no compile yet) |
| Safe-point capture + `ObserveFunction` | `CompileQueued` per warm backend |
| `ProcessPendingResults` / eager finish | `CompileCompleted` per backend (outcome, latency, code size) |
| `SetJITBinding` for dispatch | `BindingPublished` |
| Clear Runtime Binding | `BindingCleared` |
| `SetDispatchBackend` | `DispatchChanged` (old, new) |
| `RetireFunction` / module discard | `FunctionRevisionRetired` |
| Compare pass finished | `CompareCompleted` |
| Plugin/module unload after drain | `BackendUnregistered` |

`OnJITEntry` may run on a VM worker. It MUST NOT broadcast UObject delegates. It only claims lazy compile on the **dispatch** backend; the resulting `CompileQueued`/`CompileCompleted` flush on the next safe point.

Subsystem exposes a multicast delegate plus a pointer-free diagnostic snapshot. Tests subscribe without ticking the editor.

### 4. Update generations are split

Current bug-shaped behavior: `Reconfigure` bumps one cancellation generation and drops every result.

New generations, all Engine-local:

| Generation | Advances when | Effect |
| --- | --- | --- |
| `PublicationOrdinal` | `OnFunctionReady` for that function pointer | Retire that function’s previous ordinal on **all** warm backends |
| `FunctionRevision` | bytecode/content identity changes | Old results stale; new snapshot compiled on every warm backend |
| `WarmGeneration` | warm set membership or compile policy changes | Create/destroy only the affected backend sessions; cancel **that** backend’s in-flight work |
| `DispatchGeneration` | dispatch BackendId changes | Republish Bindings from already-published cache; **no** compile cancel |
| `CancellationGeneration` | per backend session | Same as today, but not shared across backends |

Switch MIR → LLVM: `DispatchGeneration++` only. If LLVM has a published result for the current `(FunctionKey, FunctionRevision, PublicationOrdinal)`, attach it at the next safe point. If not, calls stay on VM (or previous dispatch Binding until the safe point) until LLVM completes.

Hot reload: `OnFunctionReady` + route snapshot. All warm backends compile the new revision. Old leases stay with retired Bindings until readers exit.

Disable a backend that is currently dispatch: refuse, or require an atomic switch to another warm backend / VM first. Chosen: refuse disable-of-dispatch; caller switches dispatch then removes from warm set.

### 5. Compare is an explicit pass, not a second Binding

`FAngelscriptRuntimeJITCompareRequest`:

- Engine must be `RuntimeOnly` (or a dedicated compare Engine). `Auto` would mix AOT into the numbers.
- Backends: two or more, all must be warm (compare warms them for the pass if needed, then restores the previous warm/dispatch config).
- Per function: compile each backend (or reuse published revision), then for each backend: switch dispatch, warmup N calls, measure M calls, record exceptions vs VM oracle.
- Rows: BackendId, outcome, compile microseconds, code bytes, steady ns/op, vs-VM ratio, vs-other-backend ratio.
- One function, one Binding at a time. Never two VMEntries live on the same function during a measured call.

Correctness compare (return value / exception) already exists in the MIR plugin tests as VM vs Runtime. This host API is the Engine-local version for any warm pair, including two fakes.

Default compare does **not** instrument the production tick path.

### 6. Settings INI selects the Runtime JIT by name

Each backend’s **name** is its BackendId from `GetBackendId()`, unique lowercase ASCII (`angelsea-mir`, `angelsea-llvm`). `GetDisplayName()` is UI-only and is not stored in ini. Do not add a `GetName()` override; that would collide with `UObject::GetName()`.

Fields go on existing `UAngelscriptSettings` (`Config=Engine`, so `DefaultEngine.ini` / `BaseEngine.ini`, **not** `DefaultAngelscriptCompileOptions.ini`):

```ini
[/Script/AngelscriptRuntime.AngelscriptSettings]
RuntimeJITName=angelsea-mir
+RuntimeJITWarmNames=angelsea-llvm
```

Apply order for the **primary** Engine:

1. `UAngelscriptSettings::RuntimeJITName` / `RuntimeJITWarmNames`
2. Command line `-as-runtime-jit-backend=` / `-as-runtime-jit-warm=` override settings for that process

- `RuntimeJITName` empty or `none`: no Runtime JIT (default).
- If the name parses as a BackendId, is registered, and `IsAvailable()`: it is dispatch and is auto-included in the warm set.
- If the name is unknown, unparsable, or unavailable: diagnostic only; VM/Static AOT continue; Engine init does not fail.
- An unknown extra entry in `RuntimeJITWarmNames` diagnoses that name only and MUST NOT disable a valid `RuntimeJITName`.
- `RuntimeJITName` is **not** `ConfigRestartRequired`. Editor/property changes apply to the primary Engine at the next safe point, same as console commands.
- Isolated test Engines do not read these fields unless they opt in.
- Editor combo `GetOptions` lists `none` plus currently registered names; the stored string MAY name a backend that is not loaded yet so ini can be authored before the plugin is enabled.
- If that named plugin loads later, the primary Engine applies it at the next safe point. Catalog rebuild does not warm unnamed new subclasses.
- PIE copies the Editor primary Engine’s live warm/dispatch at PIE start; it does not share sessions.

`FAngelscriptEngineConfig` grows an optional warm-id list. `FromCurrentProcess()` merges settings then CLI into that config for the primary Engine only.

Non-Shipping commands:

- `as.RuntimeJIT.List`
- `as.RuntimeJIT.Warm <id>|none|all-available`
- `as.RuntimeJIT.Dispatch <id>`
- `as.RuntimeJIT.Compare <idA> <idB>` (primary Engine: isolated child Engine)

See `research/ini-runtime-jit-name.md`.

### 7. IModularFeatures becomes a shim then dies

Coordinator lookup order during migration:

1. UObject catalog (`IsAvailable()` + metadata validation)
2. Existing `IModularFeatures` factories (current fake tests and worktree plugins)

Once in-tree tests use `UAngelscriptRuntimeJIT` fakes, step 2 is removed. Worktree MIR/LLVM adapters land in their own changes.

### 8. Capture once, compile many

`FAngelscriptRuntimeJITCompileSnapshot::Capture` today bakes `BackendId` into the header. The safe point SHALL capture bytecode/frame/CFG once, then produce per-backend snapshot views that only differ by BackendId (and session namespace). Backends still validate the view independently.

### 9. Compiled functions are owning handles, not UObjects or raw entries

Host code SHALL name a compiled result as `FAngelscriptRuntimeJITFunctionHandle`: a small copyable value with pointer-free identity (`BackendId`, `EngineNamespace`, `PublicationOrdinal`, `FunctionKey`, `FunctionRevision`, `EntryAbiHash`) and a private `TSharedPtr` to the immutable artifact (lease + session keep-alive + `VMEntry` + metrics).

`IsValid()` means the artifact is still mapped. Cache lookup is `WarmHandles[FunctionKey][BackendId]`. Dispatch is `DispatchHandle[FunctionKey] = that handle`, then `SetJITBinding` from it. Compare and host events pass handles. Binding.UserData holds the same shared artifact the handle owns.

Rejected alternatives:

- **UObject per compiled function** — scale, GC, and workers.
- **`FDelegateHandle` / index-only id** — does not keep RWX memory alive.
- **Exposing `asJITFunction` on the subsystem API** — no identity, easy UAF after retire.
- **Using only `FAngelscriptRuntimeJITPublishedCode`** — already exists internally; too fat and too pointer-heavy for switch/compare/events.

CodeLease stays inside the artifact. The handle does not replace it.

See `research/jit-function-handles.md`.

## Risks / Trade-offs

- **Memory: two native copies of every eligible function** → Warm set is explicit and default stays one backend; compare is opt-in.
- **EagerSync with two backends lengthens the compile safe point** → Compile warm non-dispatch backends as `EagerBackground` even when dispatch is `EagerSync`. Dispatch remains the policy the caller asked for.
- **OnJITEntry thread** → No UObject delegates there; lazy claim dispatch-only.
- **Plugin unload of a warm non-dispatch backend** → Drain that backend’s sessions/leases; dispatch Bindings stay if they used another backend.
- **Settings name a backend whose plugin is disabled** → Configuration diagnostic; VM/AOT still work.
- **Mass CDO GC disregard** → Follow Mass `AddToRoot` for late plugin classes.
- **Handle copies keep code mapped after cache drop** → intended; same as BindingContext copying the lease. Drain still waits for refcount zero.

## Migration Plan

1. Land UObject catalog + two in-plugin fake backends + host events (this change).
2. Extend state machine to `WarmSessions[BackendId]` + dispatch switch tests.
3. Add compare pass tests (correctness + metrics rows) on fakes.
4. Point diagnostics/console at warm/dispatch.
5. Remove coordinator `IModularFeatures` lookup after tests migrate.
6. Separate changes: MIR/LLVM `UCLASS` adapters.

Rollback: single-BackendId coordinator path remains behind “warm set of size 1”.

## Open Questions

None blocking. Architecture is implementable. Last operational locks (INI naming, late plugin load, PIE copies live primary, CDO-safe catalog methods) are in `research/remaining-gaps.md`.
