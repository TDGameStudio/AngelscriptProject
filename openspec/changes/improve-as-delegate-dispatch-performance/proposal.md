## Why

AngelScript `delegate` and `event` deliberately use Unreal dynamic-delegate semantics so that script-declared signatures can participate in `UPROPERTY`, Blueprint, reflection, and hot reload. The interpreter path adds argument marshalling and defensive per-dispatch validation around that UE dispatch, while StaticJIT already has dedicated native-form fast paths that bypass much of this glue. The current behavior has no focused benchmark or explicit performance contract, making it difficult to identify safe improvements or explain the boundary between dynamic delegates and native C++ delegates.

## What Changes

- Establish a repeatable performance and correctness matrix for script-declared single-cast delegates and multicast events in interpreter and StaticJIT configurations.
- Document the dispatch boundary: StaticJIT SHALL optimize script-side marshalling and invocation glue, but dynamic delegate execution SHALL retain UE `FScriptDelegate` / `FMulticastScriptDelegate` semantics.
- Investigate and, if measurement justifies it, reduce repeated interpreter-path signature validation and multicast preflight work without weakening hot-reload, Blueprint reinstance, object-lifetime, or error-reporting guarantees.
- Record a separate future option for non-reflected, pure-script callbacks based on AngelScript `funcdef`; it is not a replacement for `delegate` / `event`.
- Keep generated delegate wrapper source separation/debug provenance as a related but independent follow-up, unless benchmark work requires shared generated-code metadata.

## Capabilities

### New Capabilities

- `as-delegate-dispatch-performance`: Measurable, correctness-preserving execution behavior for script-declared delegates and events across interpreter and StaticJIT paths.

### Modified Capabilities

- None.

## Impact

- Candidate runtime code: `AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp`, `AngelscriptRuntime/Binds/Bind_Delegates.cpp`, and StaticJIT native-form code under `AngelscriptRuntime/StaticJIT/`.
- Candidate tests: a new focused automation benchmark/regression suite under `AngelscriptTest/StaticJIT/` and/or `AngelscriptTest/Bindings/`, using the existing test harness.
- Affects interpreter and StaticJIT dispatch, hot reload, generated `UDelegateFunction` signatures, Blueprint-facing delegate properties, and performance documentation.
- No public syntax, delegate/event semantics, or Blueprint contract changes are proposed by this record.
