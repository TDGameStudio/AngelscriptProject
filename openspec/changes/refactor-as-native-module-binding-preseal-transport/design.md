## Context

The UHT NativeModuleFunctionAddress profile emits Runtime-independent wrapper shards into target Unreal modules and publishes POD payloads through `IModularFeatures`. `AngelscriptRuntime` already depends on those target modules for the engine-facing surface; adding a target-module dependency back to Runtime would create a circular UBT dependency. The current bridge therefore supports module arrival, unload, pending payloads, object-construction notifications, and injection into already-created engines.

`refactor-as-manual-binding-architecture` seals direct callback providers before engine binding, but deliberately leaves this bridge intact. This follow-up owns the remaining lifecycle convergence and must begin with dependency/link/load-order evidence rather than assuming target shards can construct Runtime-owned provider objects.

## Goals / Non-Goals

**Goals:**

- Make eligible target-module native function-address payloads available before direct binding collection seal without a target-module dependency on `AngelscriptRuntime`.
- Preserve signature eligibility, RPC/Net reflective fallback, generated statistics, and target-module-local wrapper execution.
- Remove NativeModuleFunctionAddress pending injection, already-created-engine replay, and unload handling only after an equivalent pre-seal path is proven.
- Keep Runtime, UHT emitter, payload layout/version, and regression tests synchronized.

**Non-Goals:**

- Changing which modules or signatures are eligible for NativeModuleFunctionAddress generation.
- Moving target-module wrappers into `AngelscriptRuntime` or adding reverse Runtime dependencies.
- Changing the POD ABI without an explicit layout-version migration.
- Implementing this transport as part of `refactor-as-manual-binding-architecture`.

## Decisions

### Preserve the current bridge until a dependency-safe replacement is selected

The existing POD/`IModularFeatures` transport remains production behavior while candidates are evaluated. Removal is not an incremental cleanup step in the manual-binding change.

### Require a dependency and load-order proof before implementation

The selected transport must document where generated payload storage lives, which module owns its symbols, how Runtime discovers it before seal, how target modules remain Runtime-independent, and how installed/source engine profiles behave. Candidate approaches include a lower-level dependency-neutral interface module, generated aggregation in an already-safe owner, or build-time manifest/static aggregation; no candidate is selected by this record alone.

### Preserve fail-safe fallback

An unavailable or invalid native payload must retain current generated diagnostics and reflective fallback classification. RPC/Net UFunctions must never be routed through raw native wrappers.

## Risks / Trade-offs

- **Circular or hidden module dependency** → validate the UBT graph for every generated target module before changing code.
- **Static initialization or load-order coupling** → use deterministic pre-seal discovery tests with permuted module load order.
- **ABI drift across generated shards and Runtime** → compare layouts byte-for-byte and bump `native-module-function-binding-layout-version.txt` only for an intentional coordinated change.
- **Installed-engine incompatibility** → validate both source and installed generation profiles before removing the bridge.
- **Lost late-loaded coverage** → inventory all modules that currently arrive after engine construction and prove the replacement loads them before seal or intentionally excludes them with diagnostics.

## Migration Plan

1. Capture the current UBT dependency graph, generated shard ownership, module load timing, payload layout, and late-arrival coverage.
2. Evaluate dependency-safe transport candidates and record the selected design with a rollback path.
3. Add failing emitter/runtime/load-order tests for pre-seal discovery while retaining the current bridge.
4. Implement the selected transport and run both paths temporarily only inside tests needed for parity comparison.
5. Switch production consumption to pre-seal discovery, remove pending/replay/unload state, and remove the temporary comparison seam.
6. Validate source/installed profiles, RPC fallback, generated statistics, layout version, full binding regressions, and restart behavior.

## Open Questions

- Which existing dependency-neutral module, if any, may legally own the transport contract?
- Can UBT aggregate target-module payload references without requiring target modules to link Runtime symbols?
- Which current profile modules are not loaded before `UAngelscriptSubsystem` finalizes direct providers?
- Can the current POD layout remain unchanged, or does pre-seal enumeration require a versioned header field?
