# Runtime GC assertion-depth implementation handoff

## Status and scope

- Implementation status: source work complete; the prior incomplete Exact Owner and helper call-signature risk are resolved.
- Modified source: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Runtime/AngelscriptNativeGarbageCollectorTests.cpp`.
- Modified record: this handoff only.
- Catalog, Support, and all other files were left unchanged.
- No build and no UE Automation test were run, as explicitly requested. Runtime pass/fail remains unverified.

## Resolved helper and cleanup risks

- `CreateSelfCycle` exposes its one `NotifyGarbageCollectorOfNewObject` result; every call site passes the output and asserts the fresh-engine sequence number is exactly `0`.
- `CreateTwoNodeCycle` exposes both notification results independently instead of folding them together; every call site passes both outputs and asserts exact sequence numbers `0` and `1`.
- All retained `TEST_METHOD` call sites now match the helper arity.
- `FGCProbeEngineScope` clears `GGCProbeScriptEngine` before destroying its engine.
- Each Exact Owner case proves that the callback pointer is bound to its case-owned engine and explicitly clears it before normal destruction.
- `FGCProbeCycleCleanupScope` safely breaks still externally owned cycles and drains registered GC objects on assertion/early-return unwinding. Explicit cleanup results remain observable through owner assertions; its destructor retries cleanup if an explicit attempt did not finish.

## `RT-GC-EMPTY-SERVICE-CONTRACTS` Exact Owner

`GarbageCollectorStatistics` now proves the complete empty-service contract in its own body:

1. all five direct-collector statistics outputs start at exact zero;
2. an empty direct `asGC_FULL_CYCLE` returns exact success;
3. internal/direct `GetObjectInGC` returns `asINVALID_ARG` and resets sequence, object, and type outputs;
4. public `asIScriptEngine::GetObjectInGC` independently returns `asINVALID_ARG` and resets all three outputs;
5. `ReportAndReleaseUndestroyedObjects` returns exact zero;
6. all five direct-collector statistics remain at zero after the empty operations and cleanup;
7. all five public engine GC statistics remain at zero, proving direct-collector operations do not mutate the engine-owned collector;
8. a distinct second standalone engine and direct collector bind to one another, start at the full zero baseline, complete empty collection and cleanup, and retain zero statistics;
9. the isolated direct collector leaves its engine-owned collector at the full zero baseline; and
10. isolated activity leaves both the primary direct collector and primary engine-owned collector unchanged.

Both engine cleanup actions are registered before the first nullable-engine early return.

## `RT-GC-CYCLE-TOPOLOGY-PHASES` Exact Owner

`ManualCycleCollection` now executes four sequential, independently owned cases with stable info names:

- `self_cycle_detect_then_full`
- `self_cycle_direct_full`
- `two_node_detect_then_full`
- `two_node_direct_full`

Every case:

- asserts incoming `FGCProbeObject::LiveCount == 0`;
- creates its own `FNativeTestEngine` and registers its own probe type;
- asserts all five fresh GC statistics outputs are exactly zero;
- asserts exact notify sequence result(s), exact created live count, exact `CurrentSize` increase, and all remaining post-create statistics outputs;
- releases all external references and proves tracked/live objects remain before collection;
- consumes and asserts every explicit collection return value;
- proves final `LiveCount == 0`, tracked size returns to the zero baseline, and `TotalDestroyed` increases by exactly the topology size; and
- observes successful cleanup and clears the callback engine before engine destruction.

The two detect-then-full cases additionally assert:

- the detect-only call returns exact success;
- `TotalDetected` increases by at least one for the self cycle and at least two for the two-node cycle;
- `CurrentSize` and `LiveCount` remain exactly at the created topology size after detection;
- destruction counters remain unchanged during detection; and
- a later ordinary full collection destroys the retained objects.

The two direct-full cases do not make a prior detect-only call. They invoke an ordinary `asGC_FULL_CYCLE` directly and prove detection/destruction occurs within that call.

The retained `GarbageCollectorCycleDetection` and `TwoNodeCycleCollection` methods remain non-product support smokes. Their descriptions now state that `ManualCycleCollection` is the Exact Owner, and their helper calls/assertions were updated without removing the prior behaviors.

## Fork semantics used

Current `as_gc.cpp` establishes:

- `asGC_FULL_CYCLE | asGC_DETECT_GARBAGE` selects `doDetect=true`, `doDestroy=false`;
- detect-only processing breaks cyclic references but leaves the GC-owned objects tracked/live until a later destroy-capable call;
- ordinary `asGC_FULL_CYCLE` performs both detection and destruction; and
- `NotifyGarbageCollectorOfNewObject` returns the assigned sequence number, beginning at zero for each fresh engine.

These source-level semantics support the exact owner assertions, but do not replace runtime verification.

## Static-review result

- Scoped submodule `git diff --check` reports no whitespace errors.
- Cycle-helper search finds one definition plus three fully populated call sites for each helper; no old-arity call remains.
- `ManualCycleCollection` contains exactly four stable case-info entries, two detect-only calls, and four ordinary full-collection calls.
- Case naming uses product/theme terminology only.
- Matcher search finds no bare CQTest matcher line outside `ASSERT_THAT`; helper-local `FNoDiscardAsserter` results are explicitly consumed.
- GC notification, collection, lookup, undestroyed-report, and statistics outputs are consumed by assertions in the owner flow; cleanup-only fallback collection is folded into a boolean returned to the owner.
- Product tags remain on `GarbageCollectorStatistics` and `ManualCycleCollection` with their original product IDs.
- Build/test result: not run by instruction; no compilation or runtime pass claim is made.

## Concentrated build follow-up

- A later concentrated build at `Saved/Build/as-native-sdk-runtime-assertion-depth/20260727_132050_459_31b8690e/` reached `ProcessExitCode 6` / final exit `1`.
- The reported blocker was MSVC C4458 at `AngelscriptNativeGarbageCollectorTests.cpp:258`: `FGCProbeEngineScope::Initialize(FNoDiscardAsserter& Assert, ...)` shadowed the CQTest base-class `Assert` member, and warnings are treated as errors.
- The helper parameter is now named `Asserter`, with its two function-body uses updated. No behavior changed.
- This build fix has only received scoped static verification. The concentrated build was not rerun, and no runtime test was run.

## Remaining verification

When execution is authorized, run the prescribed build, the narrow `Angelscript.TestModule.AngelScriptSDK.Runtime.GarbageCollector` prefix, and the full `Angelscript.TestModule.AngelScriptSDK` prefix. Record exact pass/fail counts and report paths before closing the coverage row.
