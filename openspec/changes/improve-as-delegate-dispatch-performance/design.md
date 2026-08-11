## Context

Script-declared `delegate` and `event` declarations are lowered by the preprocessor into value structs containing `_FScriptDelegate` or `_FMulticastScriptDelegate`. The generated `Execute`, `ExecuteIfBound`, and `Broadcast` methods push a reflected parameter list and execute the UE dynamic delegate. Class generation derives a `UDelegateFunction` from the generated `Execute` or `Broadcast` signature so the type can be used by reflection, `UPROPERTY`, Blueprint, and hot reload.

The interpreter path uses `FScriptCall`: it stores constructed argument values in an internal buffer, resolves bound `UFunction` objects, validates signature compatibility, then uses UE dynamic-delegate dispatch. Multicast execution additionally enumerates listeners and validates each target before dispatch.

StaticJIT registers specialized native forms for delegate execution and argument pushes. Its generated C++ emits the parameter struct directly and calls `FScriptDelegate::ProcessDelegate<UObject>` or `FMulticastScriptDelegate::ProcessMulticastDelegate<UObject>` directly. It therefore removes the interpreter-side `FScriptCall` state machine and its preflight validation, but intentionally retains UE dynamic-delegate / `ProcessEvent` semantics.

There is no dedicated benchmark currently establishing the relative cost of these paths, their listener-count scaling, or their post-hot-reload correctness behavior.

## Goals / Non-Goals

**Goals:**

- Establish measured baselines for interpreter and StaticJIT delegate/event dispatch.
- Preserve existing UFunction, Blueprint, dynamic delegate, weak-object, and hot-reload behavior while evaluating optimizations.
- Make the semantic performance boundary explicit: StaticJIT may approach UE dynamic delegate cost but cannot make reflected delegates equivalent to native `TDelegate` / `TMulticastDelegate`.
- Identify whether interpreter-path per-dispatch validation and multicast preflight are material enough to justify a guarded cache or another targeted optimization.
- Keep a future pure-script callback path (`funcdef`) distinct from the reflected delegate design.

**Non-Goals:**

- Do not replace `delegate` / `event` with `funcdef`.
- Do not remove `UDelegateFunction`, `FDelegateProperty`, `FMulticastInlineDelegateProperty`, BlueprintAssignable behavior, or dynamic delegate lifetime semantics.
- Do not claim native `TDelegate`-level performance for the existing reflected API.
- Do not introduce a benchmark-driven semantic regression, including after script signature changes, Blueprint reinstancing, or object destruction.
- Do not combine this work with the generated-code source-section/debug provenance refactor unless a shared metadata change becomes necessary.

## Decisions

### 1. Benchmark before optimizing

The first implementation task SHALL measure both correctness and throughput/allocation behavior before changing the dispatch path. The benchmark matrix will include single-cast and multicast delegates; 1, 4, 16, and 64 listeners; primitive, value-struct, and reference/container parameter forms; interpreter and StaticJIT execution; and C++ dynamic/native delegate baselines where the test harness can represent them fairly.

**Rationale:** the current source proves there are distinct code paths, but does not quantify whether signature validation, argument construction, or `ProcessEvent` dominates in supported configurations.

**Alternatives considered:**

- Remove validation immediately. Rejected because it would weaken hot-reload diagnostics without knowing whether it materially improves common workloads.
- Optimize only StaticJIT. Rejected because StaticJIT already has dedicated fast paths and the unmeasured interpreter path may have the larger opportunity.

### 2. Preserve UE dynamic delegate semantics as the contract

Existing `delegate` / `event` execution remains based on `FScriptDelegate` / `FMulticastScriptDelegate`. StaticJIT fast paths may remove script VM and generic binding work, but they SHALL still dispatch through the UE dynamic delegate API.

**Rationale:** this preserves reflected property compatibility, Blueprint binding, UFunction-based targets, runtime binding, weak object behavior, and hot reload.

**Alternatives considered:**

- Devirtualize script delegates into cached direct target calls. Rejected for the existing API because target object/function identity can change at runtime and because this would bypass Blueprint/`ProcessEvent` semantics.
- Reimplement script delegates as native `TDelegate`. Rejected because it would be a new non-reflected callback type, not a transparent optimization of the current public type.

### 3. Treat validation caching as a guarded optimization candidate

If benchmarks show the interpreter validation path is material, evaluate a cache keyed by delegate signature identity, target `UFunction` identity, and an invalidation generation covering script signature reload, Blueprint reinstance, and target lifecycle changes. The cache MUST fall back to full validation when identity is unknown or stale.

For multicast events, assess whether preflight validation can be cached per listener and invalidated safely rather than recomputed for every broadcast.

**Rationale:** binding already validates compatibility. Repeated validation protects dynamic environments, but a cache can preserve that protection only when invalidation is complete and tested.

**Alternatives considered:**

- Trust bind-time validation forever. Rejected because full reload and Blueprint reinstance can replace signature/target functions.
- Skip all validation in Shipping only. Rejected until measured because it creates build-configuration semantic divergence and can hide invalid binding failures.

### 4. Keep pure-script callbacks as a separate future capability

Document `funcdef` / script function handles as the likely model for high-frequency callbacks that do not require UE reflection. Any implementation must specify ownership, hot reload, cross-module behavior, and StaticJIT support separately.

**Rationale:** it is the route that can plausibly approach native callback costs; it must not dilute the reliable semantics of UE dynamic delegates.

## Risks / Trade-offs

- **Incomplete cache invalidation after hot reload or Blueprint reinstance** → retain a conservative fallback path; add runtime tests that mutate delegate signatures and target functions across reload.
- **Benchmark noise or unfair baselines** → warm up allocations/JIT entry, report median and distribution, separate setup from dispatch, and compare dynamic vs native C++ delegate semantics explicitly.
- **Optimization removes useful diagnostics** → retain a forced validation mode and test invalid bindings before and after reload.
- **Multicast optimization mishandles listener mutation during broadcast** → preserve Unreal delegate mutation semantics and test add/remove/destroy behavior around dispatch.
- **Expanding scope into source-map work** → keep generated source provenance tracked as a separate change; only share metadata if implementation evidence requires it.

## Migration Plan

1. Add benchmark and regression coverage without changing public behavior.
2. Record baseline results in this change directory.
3. Implement one measured optimization at a time behind the existing delegate API.
4. Run focused interpreter, StaticJIT, hot reload, and binding tests before accepting each optimization.
5. Revert an optimization by removing its cache/fast path; the fallback remains the existing validated dynamic-delegate execution.

## Open Questions

- Which workload dominates real projects: single-cast `Execute`, multicast `Broadcast`, or UFUNCTION event invocation?
- Can UObject/class replacement and Blueprint reinstance expose a stable generation/invalidation signal suitable for cache keys?
- Does the current StaticJIT AOT suite exercise generated delegate wrapper methods themselves, or only their underlying native forms?
- Which allocation/profiling instrumentation is practical and stable in the UE automation environment?
- Should a future `funcdef` callback capability support captured script state, and how should that state participate in hot reload?
