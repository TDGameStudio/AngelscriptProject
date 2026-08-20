# Remaining host gaps (locked vs deferred)

Recorded: 2026-08-18. Review of `refactor-as-runtime-jit-uobject-host` against the landed coordinator, Engine CLI, test harness, and UE process shape.

The architecture (UObject catalog, warm/dispatch, handles, split generations) is enough to implement. These items were unspecified. Recommendations below are now the working decisions unless overturned.

## Locked in this change

### CLI and defaults stay compatible

Today: `-as-jit-mode=`, `-as-runtime-jit-backend=`, `-as-runtime-jit-compile=`. Empty / `none` means no Runtime JIT.

Keep those flags. `-as-runtime-jit-backend=` is **dispatch** and is auto-included in the warm set. Optional `-as-runtime-jit-warm=a,b` names extra warm backends. Default warm set is empty. No backend is chosen by `GetDerivedClasses` order.

`UAngelscriptSettings` is the ini/defaults surface (`RuntimeJITName`, `RuntimeJITWarmNames`). Command line `-as-runtime-jit-backend=` overrides `RuntimeJITName` for that process. Console commands mutate the **primary** Engine live and do not require editor restart.

### Catalog works without `UAngelscriptSubsystem`

Automation and StaticJIT generation construct `FAngelscriptEngine` without the engine subsystem. Discovery MUST be a coordinator-callable helper (`GetDerivedClasses` + `IsAvailable` + duplicate-id check), not “read subsystem.AvailableJITs or fail”. The subsystem array is a cached editor view of the same helper.

### Fake backends live in `AngelscriptTest`

Do not ship `UAngelscriptFakeAlphaRuntimeJIT` in `AngelscriptRuntime`. Test module load makes them visible to `GetDerivedClasses` in Editor tests only.

### Global dispatch, per-function VM fallback, no silent steal

Dispatch BackendId is Engine-global. If that backend returns `Unsupported` for one function, that function stays VM. The coordinator MUST NOT attach the other warm backend’s handle unless the caller switches dispatch.

### LazyFirstCall only claims dispatch

`OnJITEntry` still claims only the dispatch backend. Extra warm backends are queued as `EagerBackground` from the safe point that first observes the function, not from the JIT-entry hook.

### Debugger and coverage suppress attach, keep warm cache

Existing bytecode-visibility gates remain: do not `SetJITBinding` a Runtime handle while debugger/coverage requires VM. Do not destroy warm handles; after the gate lifts, the next safe point may republish the dispatch handle. New compiles may be skipped while the gate is active.

### Dispatch and compare are game-thread, safe-point operations

`SetDispatchBackend` / compare / warm-set edits run on the game thread and take effect at `ProcessRuntimeSafePoint`. They MUST NOT run from `OnJITEntry`.

### Compare on the primary Editor Engine uses an isolated Engine

In-place compare would flip dispatch under live script. Test Engines created as `RuntimeOnly` may compare in-place. The primary Engine owned by `UAngelscriptSubsystem` SHALL spawn a temporary isolated `RuntimeOnly` Engine, run the pass, destroy it, and leave primary dispatch/warm unchanged.

Compare metrics are wall-clock; v1 does not pin CPU or claim noise-free ns/op. Rows include handle identity (BackendId, FunctionKey, Revision, Ordinal) plus latency/size/ns/op.

### PIE / extra Engines

Process catalog is shared. Each `FAngelscriptEngine` has its own sessions, handles, and dispatch. A new Engine copies settings (or explicit test config) at creation. PIE MUST NOT share sessions or leases with the Editor Engine.

### Snapshot stamping

Implement `CloneForBackend(BackendId)` (or equivalent) so one capture yields N views. Do not recapture bytecode per backend. Header BackendId remains part of the session ABI.

### Handle equality

Two handles compare equal when the identity tuple matches. `IsValid()` additionally requires the artifact `TSharedPtr` to be alive. Do not compare `VMEntry` pointers in host tests.

### Shipping, Standalone, commandlets

Shipping keeps current “no Runtime JIT factory / no host commands” exclusion. Standalone CMake host has no UObject catalog and is unchanged. Editor commandlets that create an Engine use the same helper as tests.

### Editor UI and Blueprint

v1 is `UAngelscriptSettings` details (already under Project Settings → Plugins → Angelscript) + console + C++. No custom editor tab and no extra `UDeveloperSettings` class. Dispatch/warm are not Blueprint-writable. `RuntimeJITName` is not `ConfigRestartRequired`.

### Config merge

Primary Engine: settings, then CLI. Test Engines: explicit `FAngelscriptEngineConfig` only. An unknown `RuntimeJITWarmNames` entry does not disable a valid `RuntimeJITName`. `bWarmRuntimeWhenStaticAOTPresent` is not an INI field in this change; it stays false.

## Second review (INI name)

Closed: `GetBackendId()` vs `UObject::GetName` clash; Engine config ini not compile-options; CLI after settings; unknown extra warm names; live apply without restart; stale `UAngelscriptRuntimeJITSettings` diagram.

## Third review (still worth locking)

These were the last real holes. They do not change the architecture.

### Late plugin load honors an already-configured name

Catalog rebuild MUST NOT warm every newly appeared subclass. If the newly available BackendId is already the primary Engine’s desired dispatch or an extra warm name (settings then CLI, or a live console mutation still in effect), the primary Engine SHALL apply it at the next safe point. Isolated test Engines still ignore settings.

This contradicts an earlier research note that said “wait for restart”; restart is not required.

### PIE copies live primary state

A PIE Engine copies the **Editor primary Engine’s current** warm set and dispatch at PIE start. It does not re-merge ini, and it does not share sessions or leases. Commandlets and constructed test Engines keep `FromCurrentProcess()` / explicit `FAngelscriptEngineConfig`.

### Catalog methods are CDO-safe

`GetBackendId()`, `GetDisplayName()`, `IsAvailable()`, and `GetMetadata()` MUST be callable on the CDO and on the catalog instance, with the same BackendId. `CreateSession()` runs on the game thread against the catalog instance, never on a worker.

`IsAvailable()` is sampled at catalog rebuild and at session create. v1 does not poll it on a timer. If LLVM SDK appears later, the next rebuild or explicit warm API sees it.

### CLI warm list

`-as-runtime-jit-warm=` overrides `RuntimeJITWarmNames` for that process, after settings, same merge as `-as-runtime-jit-backend=` vs `RuntimeJITName`. Dispatch is still auto-included in the warm set.

### Handles are not UPROPERTY

`FAngelscriptRuntimeJITFunctionHandle` is not serialized, not a Blueprint type, and not stored in ini.

### Memory budget

v1 has no eviction cap. Diagnostics report per-backend live code bytes. A later change may add a budget.

## Deferred to other changes (do not implement here)

- MIR/LLVM `UCLASS` adapters (`feature-as-angelsea-runtime-jit-plugin` / `feature-as-angelsea-llvm-jit-plugin`).
- Data-driven corpus profile `runtime-jit` switching from `IModularFeatures` skip to UObject-catalog skip (`test-as-data-driven-engine-harness`). Record a one-line compatibility note only.
- `as.DumpEngineState` CSV columns for warm/dispatch (follow existing dump-as-observer rule when diagnostics land).
- Wiki / `AGENTS.md` Runtime JIT host section after the code exists.
- Per-backend compile policy, per-function dispatch maps, auto fallback chains, CPU-pinned benchmarks.

## Spec holes this review closed

Scenarios added under host/multi-backend/lifecycle for: empty default, CLI dispatch flag, catalog without subsystem, isolated primary compare, debugger keep-warm, test-module fakes.
