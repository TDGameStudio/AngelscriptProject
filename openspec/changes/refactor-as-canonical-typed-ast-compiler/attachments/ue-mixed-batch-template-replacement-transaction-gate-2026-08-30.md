# UE mixed-batch template/replacement transaction gate — 2026-08-30

## Status

CTA-S71 is GREEN for the non-Standalone UE mixed success/failure batch
boundary covered by this gate. A rejected staged batch now restores the
last-good Engine-visible type/global/function indexes, never applies broad
reference replacement to a candidate already known to be failed, and excludes
new template instances requested only by failed candidates from deferred size
calculation and validation callbacks. Healthy, shared or conservatively
unknown template requests still receive normal deferred work, and the raw
deferred queue is drained before the compile call returns.

This advances the aggregate rollback part of Task 13.6. It does not close the
complete detached-artifact/full-language transaction, section 10 default
cutover, or the final validation matrix. The product default remains LEGACY;
the native AngelScript Parser AST, Builder and `asCCompiler` remain available
for explicit LEGACY, syntax/recovery, reference and differential use.

Plugin implementation commit:
`7d3ce33110a53478e980518b41fe11830e43e8e5`.

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S71 — UE mixed-batch active-index restore, failed-candidate replacement isolation and template provenance |
| Production owner | `FAngelscriptEngine::CompileModules`, `asCScriptEngine` template-instance registry, and the retained LEGACY compiler request path |
| Candidate failure source | per-module `FAngelscriptModuleDesc::bCompileError` after Stage 2 and before layout/Stage 3 publication |
| Required rollback | reset/discard every staged candidate, then restore every suppressed old active module to Engine lookup |
| Replacement rule | candidates already marked failed do not receive old-to-new reflection/dependency replacement writes |
| Template rule | process healthy/shared/unknown deferred instances; quarantine only newly created instances whose complete known requestor set is failed |
| Queue ownership | `unvalidatedTemplateInstances` is non-owning; rejected entries receive a temporary internal hold until candidate rollback finishes |
| Identity rule | numeric TypeIds and raw type/function pointers remain generation-local Runtime projections, never durable identity |
| Excluded | Standalone, Public AST V1 changes, Cache schema changes, HIR, dump input, final default flip and whole Task 13.6 closure |

## Three authenticated root causes

### 1. The old active module was suppressed but not restored

At the start of same-name staged compilation, the old active module calls
`RemoveTypesAndGlobalsFromEngineAvailability()` so candidate declarations can
be registered without colliding with generation A. The failure branch reset
and discarded generation B, but did not call the matching
`RestoreTypesAndGlobalsToEngineAvailability()` on generation A.

The module object and executable remained alive, so earlier execution-only
checks passed. Engine-wide type lookup and automatic-import function lookup
were nevertheless left incomplete. The correct rollback order is important:

```text
candidate registration suppresses generation A from Engine indexes
  -> any candidate in the aggregate batch fails
  -> reset/discard every candidate generation
  -> restore each suppressed generation-A module to Engine indexes
  -> release candidate-only template rollback holds
  -> return Error with generation A still active
```

Restoring generation A before candidate reset would temporarily publish both
old and new declarations in the same lookup tables, so the implementation
deliberately restores only after every staged candidate is abandoned.

### 2. Broad replacement loops still mutated failed candidates

CTA-S70 stopped a failed candidate's own Builder/layout/CodeGen phases, but a
different healthy candidate could still populate `ScriptUpdateMap`. The later
batch-wide replacement loop iterated every `CompiledModules` entry and applied
old-to-new reflection replacements even to a module whose `bCompileError` was
already set.

The permanent fixture establishes an exact A2 dependency on active B1, lets a
structural A change pull B2 into the same batch, then rejects the candidates.
Before the repair, A2's retained dependency was rewritten from B1 to the doomed
B2. Failed candidates are now skipped both when replacement template types are
generated and when broad reflection/dependency replacements are applied.

### 3. The deferred template queue had no requestor provenance

`asCScriptEngine::unvalidatedTemplateInstances` is an Engine-global,
non-owning raw-pointer queue. The Layout block calculates template size for
the entire queue, and the Stage 4 prelude validates/drains it. A simple global
`if (bHadCompileErrors) skip` would starve healthy requests and leave queue
state behind; a global drain would execute callbacks on types owned only by a
failed candidate.

CTA-S71 adds transaction-local provenance:

- the requesting `asCModule*` set;
- whether the instance was created during this build;
- whether any requestor is unknown;
- whether the instance was removed from the deferred queue as failed-only.

An instance is quarantined only when all of the following are proven:

1. it was created in the current aggregate build;
2. its requestor set is complete and non-empty;
3. it has no unknown requestor;
4. every known requestor is currently failed.

Missing provenance, a pre-existing queue entry, an unknown requestor, or at
least one healthy requestor is handled conservatively and remains eligible for
normal validation. If a new request arrives after the Layout partition, a
quarantined instance is requeued, its temporary hold is released, and the
Stage 4 partition decides again using the complete later requestor set.

## Template ownership and cleanup protocol

The deferred queue does not own its pointers. A newly generated template
instance can instead be owned by one or more subtype script modules and/or the
Engine template bucket registry. Removing a pointer from the queue without a
hold would allow candidate `InternalReset()` to destroy it before transaction
cleanup; retaining it without balancing module/registry ownership would leak
or double-release it.

The accepted protocol is:

1. `BeginTemplateInstanceBuildTracking()` marks pre-existing queue entries as
   unknown and begins recording requests.
2. `GetTemplateInstanceType()` records both existing and newly created
   instances with the actual requesting module. The retained LEGACY
   `ApplyDeterminesOutputType()` path now passes `builder->module` instead of a
   null requestor, so explicit LEGACY stays compatible with the shared
   transaction mechanism.
3. Before size calculation and again before Stage 4 validation,
   `PartitionDeferredTemplateInstances()` removes only proven failed-only new
   instances and takes one temporary internal reference.
4. The normal Stage 4 Builder drains successful/shared/unknown instances.
5. Candidate `InternalReset()`/discard removes failed module ownership and may
   already remove the template bucket entry.
6. `EndTemplateInstanceBuildTracking()` runs after candidate rollback. If the
   instance is still module-owned it uses `DiscardTemplateInstance()`; if it is
   registry-owned without script-module ownership it removes the bucket and
   releases the registry's original internal owner; it finally drops the
   temporary rollback hold.
7. A test-held external reference may keep the retired type shell alive long
   enough to prove that neither size calculation nor the real TOptional
   validation callback ran. The final external `Release()` is safe.

This protocol makes the candidate lifetime explicit without storing Engine
pointers or TypeIds in Public AST, sidecars, detached artifacts or cache keys.

## Risk-clustered TDD chronology

Three independent assertions were added to the existing BuilderIntegration
fixture and authenticated in one UE host cycle. The shared RED was **3 passed,
3 failed, 0 skipped**:

| Permanent test | Authenticated RED |
|---|---|
| `CanonicalStage2FailureAbandonsCandidateBeforeLayoutAndAllowsRetry` | `A failed staged replacement must restore the last-good type to Engine lookup` |
| `CanonicalMixedBatchSkipsReferenceReplacementOnFailedCandidate` | `A known-failed candidate must not receive broad dependency replacement from B1 to B2` |
| `CanonicalMixedBatchFailedTemplateSkipsDeferredWorkAndDrainsQueue` | `A failed-only requestor must not execute deferred template size work` |

Evidence:
`Saved/Tests/cta-s71-template-red-direct/20260830_021609_172_6f9ecb34/Report/index.json`.

One production transaction repair then closed the complete BuilderIntegration
prefix at **6/6 PASS**. This is the risk-clustered cadence recorded in
`reviews/tdd-execution-cadence-review-2026-08-30.md`: static review found the
complete reachable boundary, one matrix authenticated the problems, one
coherent implementation repaired them, and broad regressions ran once after
GREEN. It did not use one Editor launch per assertion.

## Fixture exploration retained as test-design evidence

Several candidate fixtures were rejected before the permanent test was
accepted. They are not product REDs and are recorded to prevent future
misclassification:

- the attempted parser-level `@` form was not accepted by the available
  fixture surface;
- a script template field failed earlier with
  `class-layout-field-type-unresolved`, so it could not prove the deferred
  queue boundary;
- a root automatic-import fixture did not isolate template ownership reliably;
- primitive `TOptional<int>` / `TOptional<float>` instances could already
  exist, so they did not prove current-transaction creation or callback
  isolation.

The permanent fixture uses the real registered `TOptional` template, two
distinct script payload classes and the production `GetTemplateInstanceType`
entry with exact requesting modules. It observes the size flag, real validation
callback state (`plainUserData`) and final queue count.

## GREEN evidence

| Gate | Result | Evidence |
|---|---:|---|
| Runtime/Editor/Test build | **PASS**, 164 actions | `Saved/Build/cta-s71-green1/20260830_022845_252_dd9d87cd` |
| Complete BuilderIntegration | **6/6 PASS** | `Saved/Tests/cta-s71-green1-builder/20260830_023110_307_8db6d200/Report/index.json` |
| Compiler event protocol | **7/7 PASS** | `Saved/Tests/cta-s71-green-events/20260830_023233_732_748863d9/Report/index.json` |
| Canonical ProductionCodeGen | **150/150 PASS** | `Saved/Tests/cta-s71-green-production-codegen/20260830_023310_840_d9cc0507/Report/index.json` |
| HotReload CanonicalAST | **12/12 PASS** | `Saved/Tests/cta-s71-green-hotreload/20260830_023346_484_15f1f5ac/Report/index.json` |
| Compiler CanonicalAST | **631/631 PASS** | `Saved/Tests/cta-s71-green-compiler-canonical/20260830_023512_747_f36e0662/Report/index.json` |
| Frontend CanonicalAST | **175/175 PASS** | `Saved/Tests/cta-s71-green-frontend-canonical/20260830_023557_220_c00aba79/Report/index.json` |
| Complete project Compiler | **85/85 PASS** | `Saved/Tests/cta-s71-green-compiler-integration/20260830_023631_172_27f34f60/Report/index.json` |

## Non-claims and remaining boundaries

- Task 13.6 remains open: this gate does not prove every declaration category,
  every Commit injection point, every full-language lowering form or all cache
  restore routes share one detached transaction.
- Tasks 9.1, 9.5 and 10.4 remain open for the same full-surface reason.
- Section 10 remains open and the default stays LEGACY. No production `dual`
  mode or silent fallback was added.
- Public AST V1, Sidecar/Cache schema, stable identity and generation binding
  contracts are unchanged.
- HIR was not recreated. Dumps remain diagnostics only and are not compilation
  input.
- Standalone was explicitly deferred by user direction. No Standalone-specific
  source/CMake change was made and no Standalone gate was run or claimed.

## Progress accounting

Mechanical OpenSpec progress remains **101/136 = 74.3%**, with **35** formal
tasks open. CTA-S71 closes a high-risk sub-boundary beneath Task 13.6 but does
not satisfy its complete sentence. `openspec status` artifact completeness is
not implementation-task completeness.
