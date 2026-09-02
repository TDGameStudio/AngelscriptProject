# UE Stage 2 failed-candidate abandon gate — 2026-08-30

## Status

CTA-S70 is GREEN for the non-Standalone direct per-module lifecycle boundary
covered by this gate. After a UE-staged source candidate has failed at or
immediately after Stage 2, the candidate no longer enters its own class layout,
destructor synthesis, global storage allocation, function layout, Canonical
Seal/Bytecode CodeGen or JIT handoff. The Stage 3 wrapper still releases the
Builder deterministically and the compiler still emits failed Layout and
CompileCode milestone events. Engine-global deferred-template operations are
explicitly excluded below.

The last-good active generation remains executable, the failed candidate is
discarded, and a corrected same-name generation can be compiled and published.
This advances Task 13.6; it does not close the complete detached-artifact,
full-language or default-cutover work.

Plugin implementation commit:
`9cba53be77583cea8e3cc449a6db692ac06e2d64`.

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S70 — UE staged failed-candidate abandon after Stage 2 |
| Production owner | `FAngelscriptEngine::CompileModules` and `CompileModule_Code_Stage3` |
| Failure boundary | `FAngelscriptModuleDesc::bCompileError` after `BuildGenerateFunctions` and before class/global/function layout |
| Forbidden work | reference-diff collection by the failed module, class/destructor layout, global allocation, function layout, Seal, CodeGen, AST adoption/publication and JIT notification |
| Required cleanup | Builder released before the failed CompileCode milestone; candidate removed/discarded by the existing batch rollback path |
| Required publication behavior | no candidate swap; retain executable generation A; allow corrected same-name generation C |
| Event contract | failed Layout and CompileCode milestones remain observable; Globals is absent |
| Product selection | tested with CANONICAL; the general error gates also protect the independent LEGACY path |
| Excluded | Standalone, final default flip, whole-engine template-validation queue isolation, complete multi-module transaction closure |

## Root cause

Direct SDK `asCModule::Build()` guards each successive Builder phase with the
previous result. The UE staged compiler had split those phases across outer
loops, but only recorded Stage 2 failure in `Module->bCompileError` and the
batch aggregate `bHadCompileErrors`. It did not use that state to gate the
later per-module work.

Before this repair the UE sequence was effectively:

```text
BuildGenerateFunctions
  -> set bCompileError
  -> CollectUpdatedTypeReferences / DiffForReferenceUpdate
  -> BuildLayoutClasses
  -> BuildAllocateGlobalVariables
  -> BuildLayoutFunctions
  -> SealCanonicalAST / GeneratePreparedModule
  -> delete Builder
  -> JITCompile (unconditional)
  -> suppress final swap and discard candidate
```

The final swap suppression prevented the failed candidate from becoming the
active generation, but it did not prevent partial materialization, mutation or
JIT observation of the doomed candidate.

`asCModule::InternalReset()` intentionally does not delete the Builder. Merely
skipping the whole Stage 3 loop would therefore defer Parser/Sema/AST ownership
cleanup until candidate module destruction. The correct boundary keeps the
Stage 3 wrapper call and makes its failed entry an explicit Builder-abandon
operation.

## TDD chronology and diagnostic timing findings

### Fixture correction: unresolved call is not a Stage 2 failure

The first proposed source used an unresolved call. Static and runtime tracing
showed that this fixture reaches Canonical Seal/Stage 3 before it fails; it is
therefore not evidence for a Stage 2-abandon contract. The permanent lifecycle
test instead uses a valid candidate and injects a one-shot failure from the
synchronous `CompileModuleGenerateFunctions` callback after the event has
authenticated successful Stage 2 completion.

This is a test-only fault seam over a retained
`TSharedRef<FAngelscriptModuleDesc>`. No production fault flag or asynchronous
event behavior was added.

### RED 1: natural Stage 2 class failure still entered Layout

A candidate containing a class field with an unknown type failed during Stage
2, but the outer compiler still emitted and executed candidate class layout.

| Phase | Result | Evidence |
|---|---:|---|
| RED | intended lifecycle assertion failed: Stage 2 failure entered layout | `Saved/Tests/cta-s70-stage2-abandon-red3/20260830_011851_052_05ae21ca/Report` |

### RED 2: authenticated post-Stage 2 failure partially materialized

The permanent aggregate test first publishes generation A, prepares a fully
valid generation B containing a class, const integer global, object global and
function body, then sets the retained candidate descriptor's compile-error bit
inside the synchronous successful GenerateFunctions event.

Before the repair it observed all of the following forbidden effects:

- `sClassDeclaration::hasLayouted` became true;
- default-destructor evaluation ran;
- the recording `asIJITCompiler` received candidate functions;
- the aggregate abandon assertion failed.

| Phase | Result | Evidence |
|---|---:|---|
| RED | intended class-layout, destructor, JIT and aggregate-abandon failures | `Saved/Tests/cta-s70-stage2-abandon-red5/20260830_012225_563_b4414f1f/Report` |

### RED 3: mutable-global rejection crashed in allocation

Review-derived source with a mutable global is rejected by the current
CANONICAL Stage 2 contract (`must be const`). Stage 2 leaves a global
description whose Runtime property shell is null. The outer compiler then
called `BuildAllocateGlobalVariables()` anyway and hit:

```text
Assertion failed: gvar->property != nullptr
as_builder.cpp:4452
BuildAllocateGlobalVariables()
  -> FAngelscriptEngine::CompileModules()
```

This was a real engine assertion rather than a test expectation failure.

| Artifact | Evidence |
|---|---|
| Automation log | `Saved/Tests/cta-s70-stage2-abandon-red6/20260830_012357_358_ab36fcd4/Automation.log` |
| Crash snapshot | `Saved/Angelscript/CrashSnapshots/27784_20260830_012424_768/AngelscriptCrashSnapshot.json` |

The permanent regression now uses that same product diagnostic and proves a
corrected const-global source can compile and execute through the same logical
module name.

## Implementation boundary

The repair applies the same failure predicate at every relevant per-module
phase:

1. failed modules do not collect or diff their own recompile-avoidance type
   replacements;
2. failed modules do not call `BuildLayoutClasses`;
3. class-layout failure is promoted immediately to both module and batch error;
4. failed modules do not call `BuildAllocateGlobalVariables`;
5. allocation diagnostics are promoted to both module and batch error;
6. failed modules do not call either function-layout variant;
7. function-layout failure is promoted immediately;
8. Stage 3 entry on an already-failed module deletes and nulls its Builder and
   returns before Seal, CodeGen, AST adoption, JIT or snapshot publication;
9. a failure produced inside Stage 3 also suppresses JIT notification;
10. Stage 4 globals remain batch-gated by `bHadCompileErrors`.

The event protocol is deliberately unchanged. Layout and CompileCode events
mean the batch considered/reached those phase milestones, not that a failed
candidate executed the underlying Builder operation. Both events carry failed
state; CompileCode carries no JIT handoff. This preserves existing synchronous
listeners while making mutation behavior honest.

## Permanent regression tests

`AngelscriptCompilerBuilderIntegrationTests.cpp` now contains:

- `CanonicalStage2FailureAbandonsCandidateBeforeLayoutAndAllowsRetry`
  - authenticates Stage 2 success before one-shot fault injection;
  - inspects class layout and destructor-evaluation flags;
  - inspects object-global allocation state;
  - records JIT callbacks;
  - requires Builder release at the failed CompileCode milestone;
  - requires no Globals milestone;
  - requires failed-candidate discard;
  - requires generation A to remain active and executable;
  - requires same-name generation C to compile and execute.
- `CanonicalRejectedMutableGlobalSkipsAllocationAndAllowsRetry`
  - locks the real Stage 2 `must be const` diagnostic;
  - prevents the former null-property allocation assertion;
  - requires failed Layout/CompileCode milestones without JIT/Globals;
  - requires a corrected const-global retry to execute.

## GREEN evidence

| Gate | Result | Evidence |
|---|---:|---|
| Focused aggregate lifecycle test | **1/1 PASS** | `Saved/Tests/cta-s70-stage2-abandon-green3/20260830_012821_582_4cca3782/Report` |
| Incremental Runtime/Editor/Test build | **PASS** | `Saved/Build/cta-s70-stage2-abandon-green4/20260830_012947_224_e18739ba` |
| Complete BuilderIntegration prefix | **4/4 PASS** | `Saved/Tests/cta-s70-stage2-abandon-green4/20260830_013058_970_e16f8373/Report` |
| Compiler event protocol | **7/7 PASS** | `Saved/Tests/cta-s70-stage2-abandon-events-green/20260830_013227_740_e3e212c4/Report` |
| Complete project Compiler prefix | **83/83 PASS** | `Saved/Tests/cta-s70-stage2-abandon-compiler-green/20260830_013312_162_67a8059c/Report` |
| Canonical ProductionCodeGen | **150/150 PASS** | `Saved/Tests/cta-s70-stage2-abandon-production-green/20260830_013422_895_e1575116/Report` |
| Final post-review build | **4/4 actions; PASS** | `Saved/Build/cta-s70-stage2-abandon-final/20260830_014010_456_5001ae03` |
| Final post-review BuilderIntegration | **4/4 PASS** | `Saved/Tests/cta-s70-stage2-abandon-final/20260830_014027_834_67538d6d/Report` |

## Remaining boundaries discovered by static review

This gate closes the reachable per-module Builder/JIT crash and mutation
routes. It does not claim the following broader transaction work:

- the engine-global `unvalidatedTemplateInstances` queue still has two batch
  operations after a module has failed Stage 2: the Layout block first runs
  `CalculateTemplateSize()` over the complete queue, and the Stage 4 prelude
  later calls `EvaluateTemplateInstances(false)` to move/drain, validate and
  potentially calculate size again. The queue is shared across modules and
  cannot be safely filtered by a simple per-descriptor `continue`; ownership
  and rollback need a separate multi-module/template test before changing it;
- when another successful module contributes a non-empty `ScriptUpdateMap`,
  the broad dependency-reflection replacement loops need a dedicated mixed
  success/failure batch gate to prove that no failed candidate receives
  indirect replacement writes;
- module-wide type/funcdef/global/function publication is not one universal
  detached transaction yet;
- errors first produced during layout or Stage 3 have their later phases gated,
  but the complete rollback matrix for every declaration category remains Task
  13.6;
- Standalone was explicitly deferred and was neither modified nor run.

These boundaries are not evidence of an active-generation leak in the covered
tests. They are the next risk-cluster inputs and keep Tasks 9.1, 9.5, 10.4 and
13.6 unchecked.

## Progress accounting

Mechanical OpenSpec progress remains **101/136 = 74.3%**, with **35** tasks
open. CTA-S70 repairs a high-severity sub-boundary beneath Task 13.6 but does
not satisfy the complete Task 13.6 sentence. `openspec status` artifact
completion is likewise not task completion.
