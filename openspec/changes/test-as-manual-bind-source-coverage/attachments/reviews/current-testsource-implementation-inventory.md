# Current TestSource implementation inventory

- Date: 2026-08-24
- Mode: read-only corpus audit; OpenSpec record only
- Source scope: `TestSource/**/*.as` and `TestSource/Generation/**`
- Implementation scope for this audit: none

## 1. Executive conclusion

`TestSource` already contains a large and broadly distributed AngelScript corpus, but it is not yet a standalone replacement for the paired UE Automation tests.

- The disk corpus contains **3,041 `.as` files**, **2,923 unique CaseIds**, and **11,987 authored callable declarations**.
- All 3,041 current source paths and file hashes match the canonical reconciliation ledger. There is no current inventory drift.
- The paired C++ automation tests normally compile equivalent inline AngelScript fixtures and retain ownership of the real World, Blueprint, TimerManager, ProcessEvent, delegate, HotReload, debugger, assertion, and cleanup phases.
- The repository audit did not find a general C++ path that loads these disk `TestSource` files as the current UE Automation fixture source.
- Many later-added `Observe_*` helpers are therefore audit/generation inputs rather than currently executed automation entry points.
- Some paired C++ tests provide strong engine-driven coverage even when their disk `Observe_*` helper is shallow or wrong. The helper must not be promoted to the new oracle without preserving the C++ driver and raw identity/state checks.
- Contract V2 infrastructure is implemented and has **97/97 Python tests passing**, but **0/3,041 sources have a per-source V2 contract**, **0 domains are strict-clean**, and no `.as` migration has started.

The correct status is therefore:

> The physical case corpus is complete, the Contract V2 tooling exists, and several paired C++ tests are strong; however, the disk callable contracts remain an unmigrated mixture of real fixture code, aggregate boolean observations, default-state helpers, compile diagnostics, version fragments, and externally driven markers.

## 2. Current corpus baseline

Authority:

- `attachments/contracts/audit-coverage-reconciliation.json`
- schema: `testsource-audit-coverage-reconciliation-v1`
- SHA-256: `85795ed20a569017441acbaafda5bfd9ee55a02db570e6709d39bb4679f9b72c`

Fresh disk reconciliation:

```text
disk .as files                         3041
canonical source rows                 3041
canonical callable rows               11987
unique CaseIds                        2923
multi-file/version CaseId expansions  118
missing disk paths                    0
extra disk paths                      0
source hash drift                     0
```

The 118 additional files beyond unique CaseIds are primarily HotReload before/after or Version_01/02/03/04 fragments. A file count is therefore not the same as a semantic test-case count, and a callable count is not the same as a UE Automation test count.

## 3. Domain inventory and current source shape

`Bindings` and `Containers` below exclude their separately listed `TArray` subtrees.

| Domain | `.as` files | Callables | `Observe_*` | `Surface` names | `_Nominal` suffix | `ExerciseExpectedFailure` | Immediate function comments | Zero-callable files |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Bindings/TArray | 8 | 45 | 40 | 2 | 40 | 5 | 7 / 45 (15.56%) | 0 |
| Containers/TArray | 58 | 98 | 31 | 0 | 6 | 0 | 0 / 98 (0.00%) | 12 |
| Bindings | 568 | 2,511 | 2,380 | 340 | 2,380 | 69 | 569 / 2,511 (22.66%) | 0 |
| Containers | 128 | 383 | 204 | 0 | 23 | 0 | 9 / 383 (2.35%) | 2 |
| Optional | 116 | 382 | 306 | 0 | 23 | 0 | 0 / 382 (0.00%) | 0 |
| Language | 642 | 2,221 | 959 | 4 | 267 | 0 | 21 / 2,221 (0.95%) | 33 |
| Definitions | 519 | 2,073 | 1,194 | 9 | 66 | 0 | 10 / 2,073 (0.48%) | 84 |
| Feature | 367 | 1,946 | 856 | 9 | 18 | 0 | 6 / 1,946 (0.31%) | 56 |
| World | 123 | 376 | 137 | 0 | 0 | 0 | 0 / 376 (0.00%) | 7 |
| Gameplay | 262 | 1,463 | 794 | 4 | 82 | 0 | 1 / 1,463 (0.07%) | 5 |
| HotReload | 209 | 273 | 0 | 0 | 0 | 0 | 0 / 273 (0.00%) | 50 |
| TestFramework | 38 | 212 | 0 | 0 | 0 | 0 | 0 / 212 (0.00%) | 0 |
| Debugger | 3 | 4 | 0 | 0 | 0 | 0 | 0 / 4 (0.00%) | 0 |
| **Total** | **3,041** | **11,987** | **6,901** | **368** | **2,905** | **74** | **623 / 11,987 (5.20%)** | **249** |

The 249 zero-callable sources must not be treated uniformly as missing tests. They include intentional declaration-only sources, type/property/enum fixtures, HotReload version fragments, compile-diagnostic sources, and cases whose oracle is entirely external. Each needs one explicit disposition rather than an invented reader.

## 4. What the current observation functions actually expose

Current `Observe_*` population:

```text
Observe_* callables                       6901
Observe_* returning bool                  5508
Observe_* returning typed non-bool value  1376
Observe_* returning void                  17
Observe_* with zero parameters            4642
Observe_* bool + zero parameters          3968
Observe_* with explicit &out              0
Observe_* with explicit &inout            0
Observe_* with Expected*/bExpect* input    150
```

This confirms the original concern: the current observation layer rarely models explicit argument input plus raw return/writeback channels. It usually does one of the following:

1. constructs all inputs inside a zero-argument function;
2. compares several results inside the script;
3. returns one aggregate `bool`;
4. accepts an `Expected*` parameter and compares inside the source;
5. observes only the default/pre-dispatch state;
6. directly invokes a callback rather than the real engine dispatcher.

Fresh Contract V2 audit diagnostics:

```text
compound-bool-oracle             3523
expected-value-wrapper             72
legacy-source-name               6975
missing-callable-comment        11364
missing-contract                 3041
unspecified-reference-direction   464
total diagnostics               25439
```

Only **623/11,987** callables have an immediately adjacent function-level knowledge comment. File headers do not satisfy the requested per-function documentation rule.

## 5. Current scenario polarity recorded by inventory

The current inventory explicitly records:

```text
positive-only sources             1171
negative-diagnostic-only sources   695
mixed positive/negative sources     73
polarity not explicitly recorded  1102
```

The 1,102 unspecified rows are not necessarily missing behavior. They are mainly:

- 871 `WorldStory` rows;
- 215 HotReload/framework version-pair rows;
- 13 framework-suite rows;
- 3 debugger markers.

`WorldStory` text must not substitute for an explicit scenario polarity. The future contract needs an exact disposition such as `Positive`, `NegativeDiagnostic`, `MixedPositiveNegative`, `VersionTransition`, `DeclarationOnly`, `ExternalDriverFixture`, or `DebuggerMarker`.

## 6. Current runtime architecture: C++ truth versus disk helper

Typical paired automation flow:

```text
C++ compiles inline AngelScript
  -> C++ creates Engine/World/Blueprint/Actor/Component fixture
  -> C++ triggers lifecycle, ProcessEvent, Broadcast, TimerManager, reload, or debugger operation
  -> AngelScript callback writes raw UPROPERTY state
  -> C++ verifies raw values, identity, address, flags, or diagnostic
  -> C++ RAII/ON_SCOPE_EXIT performs cleanup
```

Typical disk-only helper flow:

```text
Observe_*_DefaultEmpty
Observe_*_DefaultFalse
Observe_*_CopyIndependence
Observe_*_DirectCallback
```

The second flow may be a useful boundary subcase, but it cannot replace the first flow. A refactor must preserve the paired driver/oracle and redesign the disk callable around raw channels that the future runner can consume.

## 7. Theme-by-theme implementation assessment

### 7.1 Bindings and TArray

Bindings are the largest legacy-observer concentration: 2,380 `Observe_*` callables outside TArray, plus 40 in Bindings/TArray.

`TestSource/Bindings/TArray/Test_Behavior_01.as` is useful as a feature inventory and has immediate comments on its seven functions, but it still compresses multiple facts into compound booleans. For example, empty construction currently combines `IsEmpty`, `Num`, and a second element type in one return.

The target shape should publish raw values or containers:

```angelscript
TArray<int32> ConstructEmptyIntArray()

void SwapArrayElements(
    TArray<int32>&inout Values,
    int FirstIndex,
    int SecondIndex)

int32 ReadArrayElementFromEnd(
    const TArray<int32>&in Values,
    int IndexFromEnd = 0)
```

Runner vectors should own expected order, `Num`, default-argument omission, invalid-index diagnostics, and before/after writebacks.

Current assessment: **broad surface inventory, but mostly legacy aggregate observations; not yet V2 executable**.

### 7.2 Language, Definitions, Feature, Containers, and Optional

These areas provide broad syntax, type-system, UClass/UFunction/UProperty, delegates, inheritance, default component, container, optional extension, and negative-diagnostic fixtures.

Strengths:

- broad file coverage and canonical CaseIds;
- many real declaration/compile-diagnostic fixtures;
- current scanner sees constructors, delegates, events, imports, mixins, lambdas, methods, operators, and owner-qualified identities;
- negative cases often preserve the authoritative invalid declaration.

Weaknesses:

- immediate function comments are below 3% in all of these domains except Bindings;
- many positive observations remain aggregate booleans;
- 249 total zero-callable sources need intentional classification;
- external preprocessor/compiler/metadata cases are sometimes paired with irrelevant runtime observers;
- generic `Surface`, `Nominal`, numbered helper, and `ObservedCondition` terminology remains prevalent in the plan inputs.

Current assessment: **large and useful authored fixture corpus, but mixed compile/runtime/external roles are not yet normalized into executable contracts**.

### 7.3 Actor

Scope: 40 World/Actor files and 75 callables.

Strong paired coverage includes:

- `Test_DestroyLifecycleOrder.as`: real spawn, engine BeginPlay, `Destroy`, world tick, EndPlay/Destroyed order and count checks;
- `Test_TickRegisteredDispatch.as`;
- `Test_ReceiveEndPlay.as`;
- `Test_ReceiveDestroyed.as`;
- typed/deferred spawn parameter behavior;
- runtime invalid-class spawn exception.

The main risk is not the existing paired C++ lifecycle test. The risk is a future plan that replaces real engine dispatch with direct AS callback invocation or an insufficient reader.

Current assessment: **paired C++ lifecycle coverage is often real; disk callable contracts remain incomplete**.

### 7.4 Component and DefaultComponent

Scope: 72 World/Component files, 281 callables, including 124 `Observe_*`; 49 high-risk DefaultComponent files map to 207 callables.

Strong paired coverage exists for component lookup, exact tick dispatch, registration/unregistration, EndPlay reason, manual NewObject registration, and native collision broadcast.

Example: paired C++ coverage for `Test_GetComponent.as` verifies exact RootScene/Mesh/Billboard identities, parent-class queries, missing/wrong-class null behavior, and component count. The disk helper `Observe_GetComponent_DefaultNull` does not carry that identity oracle and treats all default components as null.

Other helpers that would be wrong as the main post-spawn oracle include:

- `Observe_FourLevelAttach_DefaultComponentsNull`;
- `Observe_ManualNewObject_DefaultNull`;
- `Observe_TimerDestroyedComponent_DefaultEmpty`;
- many `CopyIndependence` helpers that manually mutate a counter.

Every runtime component output ultimately needs non-null, exact class, owner/Outer/world, registration, attachment, and template-versus-spawned identity as applicable.

Current assessment: **paired tests range from strong to shallow; disk helper layer is the highest false-positive risk area**.

### 7.5 NewObject, Outer, and flags

The broad corpus contains 91 files that mention or call `NewObject`; the focused core includes UObject binding, manual component registration, GC NewObject, flag mutation, and Outer-chain tests.

Strong paired coverage exists for:

- manual component creation and owner/world identity;
- registration transitions;
- component tags and activate/deactivate state;
- custom method result 42;
- `RF_Transient`/`RF_Transactional` mutation;
- root/child/leaf Outer and path chains.

The current `Bindings/UObject` NewObject observation is still shallow because it compresses multiple object identities, names, classes, Outers, and flags into one boolean. Several `DefaultEmpty` helpers are only valid before the action and are wrong after successful creation.

Current assessment: **core paired behavior is real, but the disk contract lacks a raw object-identity matrix and explicit GC cleanup ownership**.

### 7.6 Blueprint, CDO, inheritance, and ProcessEvent

World/Blueprint contains six sources but only two callables; five are intentional external/source fixtures.

Strong paired coverage includes:

- Blueprint child default preservation across child CDO and spawned child;
- destroy/recreate isolation (`48` on the first mutated actor, `11/1` on a fresh second actor);
- native `UObject::ProcessEvent` dispatch to a child override with raw `(ParentCount, ChildCount, ChildHash) = (0, 1, 777)`.

Risks:

- the disk Recreate source has only `BeginPlay` and `BumpState`, with no typed reader;
- default preservation has no disk reader for script CDO, Blueprint child CDO, and spawned instance identities;
- direct `Actor.OnPickedUp(...)` observation helpers do not prove native ProcessEvent dispatch;
- source-only BlueprintImpact fixtures must not receive invented no-op readers.

Current assessment: **paired C++ coverage is generally meaningful; future disk contracts must retain external Blueprint/ProcessEvent drivers and distinct identities**.

### 7.7 GC

The core nine `Test_GC*.as` files contain 19 callables: nine BeginPlay callbacks, nine default-state `Observe_*` helpers, and one Tick. They have no separate prepare/release/read API.

The paired C++ tests do execute real GC, weak pointer, UPROPERTY container, root, and NewObject APIs. However, most cases perform create, release, collect, and inspect inside one BeginPlay invocation.

This proves the current helper behavior but not a host-separated lifecycle. The future contract should use independent phases:

```angelscript
void PrepareCandidate()
void ReleaseStrongReference()
bool IsWeakReferenceValid() const
```

The runner must regain control between prepare, release, host GC, and read. Root cleanup must cover success, assertion failure, diagnostic, timeout, and early exit.

Current assessment: **real GC API execution, but shallow cross-invocation/lifetime coverage; default-false helpers are not post-GC readers**.

### 7.8 Timer

The broad timer set contains 37 files and 147 callables. Gameplay/Timer contains 24 files and 97 callables; the high-risk real-TimerManager set contains 16 files and 88 callables.

Two cases clearly advance TimerManager after setup:

- actor destruction stops callbacks;
- destroyed component stops callbacks.

Several other cases genuinely test handle state transitions such as set, pause, unpause, clear, and invalidation, but they do not prove deadline callback execution.

Cases whose title currently overstates the implemented behavior include multiple timers, basic usage, delay execution, UI/AI timer patterns, delayed spawn, and component callbacks on owner World. They mainly verify setup, active handles, remaining time, or pre-deadline zero counts.

`Observe_*_DirectCallback` helpers prove only callback body mutation, not TimerManager dispatch.

Current assessment: **two strong deadline/destruction cases, several valid handle-state cases, many setup-only cases, and multiple misleading direct-callback helpers**.

### 7.9 Delegate

Feature/Delegates contains 127 files and 1,089 callables, including 285 delegate declarations, 55 events, and 28 explicit compile-negative files. The broader delegate corpus spans 234 files and 1,725 callables.

Strong paired Broadcast coverage exists for actor/component collision delegates and several widget delegates. Many Feature/Delegate sources also exercise script-side Broadcast, Execute, Bind, Clear, and Unbind.

Known shallow paired cases:

- `Gameplay/Physics/Test_CollisionEvents.as` checks binding but does not Broadcast and verify handler counts;
- `World/Component/Test_PrimitiveHitEvents.as` checks zero hit count without producing a physics hit or native Broadcast.

Known misleading helpers directly call handlers or manually mutate counts. They must not replace the actual delegate property Broadcast.

Current assessment: **substantial real Broadcast/Bind coverage exists, but direct-handler and copy-independence helpers need separation from the primary oracle**.

### 7.10 HotReload

HotReload contains 209 version/fixture files and 273 callables; 50 files are source-only. It has no `Observe_*` naming debt and is structurally healthier than most other domains.

Strong paired tests exercise old/new class, CDO, instance, default component, Blueprint child, delegate receiver, function/property/struct/enum, and failed-reload retention behavior.

The source-only files are often intentional before/after definitions. Their truth lives in the external generation/reload matrix; adding a generic reader to every file would be incorrect.

Current assessment: **real external-driver coverage with intentional version fragments; must remain blocked until each before/after identity relation is frozen, but should not be mechanically rewritten as ordinary runtime observers**.

### 7.11 Debugger

Debugger contains three marker sources and four callables. Paired C++ tests genuinely verify internal debugger-value evaluation guards, evaluation count, and exact inherited/base property address tracking.

This is meaningful internal debugger coverage, but it is not a complete DAP request/response or IDE presentation test. The line-sensitive source markers also need atomic line-map handling when comments are inserted.

Current assessment: **strong internal debugger-value coverage; DAP/line-map external coverage remains separate**.

## 8. Contract V2 infrastructure already implemented

Earlier work in this session implemented or strengthened the following under `TestSource/Generation/**`:

- owner-qualified callable inventory;
- exact declaration, annotations, return, parameter/default/direction, and immediate-comment extraction;
- current lambda, import, event, mixin, constructor, destructor, method, operator, and delegate recognition;
- Contract V2 schema;
- typed arguments, raw returns, before/after writebacks, exception, and compile-diagnostic channels;
- fixture, cleanup, review metadata, and verification evidence chain;
- source parity and global uniqueness checks;
- deterministic index/task projections;
- fail-closed projection writes;
- active V2-only authored export;
- explicit legacy-v1 audit-only adapter.

Fresh verification:

```text
python -B -m pytest TestSource/Generation/python/tests -q
97 passed in 1.88s
```

Current generated-state truth:

```text
Contracts physical files      1 (index.json only)
per-source V2 contracts       0
contract index entries        0
contract index domains        306, all unmigrated
TestSource/Generation/Tasks   0 files
strict-clean domains          0
```

The 97 tests validate the tooling. They do not mean any real `.as` source has been renamed, commented, compiled, run, or externally verified.

## 9. Required planning classifications before source migration

Every source must receive one explicit implementation role:

1. `RunnerCallableContract` — the future disk runner invokes typed inputs and reads raw result/writebacks.
2. `ExternalDriverFixture` — C++ or a host fixture owns World, Blueprint, ProcessEvent, Broadcast, TimerManager, GC, HotReload, or debugger dispatch.
3. `CompileDiagnostic` — the invalid declaration and exact diagnostic are the test.
4. `RuntimeDiagnostic` — compilation succeeds and invocation throws or reports a runtime error.
5. `VersionTransition` — before/after generations form one HotReload case.
6. `DeclarationOnlyIntentional` — a type/property/enum/source fragment is the required fixture.
7. `DebuggerMarker` — line/address/evaluation semantics are externally owned.
8. `MissingCallableEntry` — the source genuinely requires a new callable; this must be evidence-backed rather than mechanically generated.

For each callable retained or added, the plan must state:

- semantic name and exact annotation-plus-declaration;
- immediate English knowledge comment;
- exact typed inputs, including default-argument omission vectors;
- raw return and out/inout before/after state;
- expected exception or compile diagnostic, never mixed with a normal return;
- exact external driver and prohibited direct calls;
- fixture identity and ordered phases;
- cleanup owner and all completion paths;
- coverage transfer from every retired helper.

## 10. Recommended migration order

1. Finish semantic validation of the OpenSpec normalized plan and remove false-ready rows.
2. Use Bindings/TArray and Containers/TArray as the first callable-contract pilot, while correcting their remaining compound booleans and vector gaps.
3. Migrate Component/DefaultComponent and focused NewObject cases with exact object identity and lifecycle matrices.
4. Migrate Actor, Blueprint/CDO, ProcessEvent, and GC while preserving external drivers.
5. Separate Timer handle-state tests from real deadline/callback tests; separate Delegate direct-handler controls from real Broadcast tests.
6. Migrate broad Bindings, Containers, Optional, Language, Definitions, Feature, Gameplay, and TestFramework in deterministic batches.
7. Treat HotReload and Debugger as dedicated external-driver/version-marker migrations rather than ordinary reader generation.

No `.as` source should be edited until its role, exact declaration, vector channels, external driver, and cleanup are accepted in the OpenSpec row.

## 11. Verification evidence for this inventory

Fresh commands executed during this inventory:

```powershell
python -B -m pytest TestSource/Generation/python/tests -q
# 97 passed in 1.88s

python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode audit --max-diagnostics 0
# exit 1 by design
# sources=3041 contracts=0 callables=11987 diagnostics=25439
```

The non-zero audit result is the truthful migration backlog, not a tooling failure.

## 12. Scope boundary

- No `TestSource/**/*.as` file was modified by this inventory.
- No plugin, host, C++ runner, or product source was modified.
- Earlier work in this session did modify Contract V2 infrastructure under `TestSource/Generation/**`; those changes are listed in the task-1 implementation report.
- The parent repository currently reports the entire `TestSource` directory as untracked, so Git cannot provide a committed per-file baseline. Current path and SHA reconciliation proves that the 3,041 `.as` files match the frozen canonical audit, and no `.as` file has a 2026-08-24 modification timestamp.
