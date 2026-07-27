# Current Progress Baseline

## Review date and interpretation

This baseline was re-established on 2026-07-27 from source, generated catalogs,
audit outputs, and the latest retained test report. It deliberately separates
green execution from coverage closure. Counts are evidence about the current
implementation, not a substitute for reviewing each theme's declared behavior.

The source state has advanced beyond the retained 673/673 binary. After the
independently reviewed Tokenizer Deep semantic split, the current pre-build
checkpoint contains 317 products, 46,140 expected IDs, 260 `.cpp` files, 15
headers, and 688 CQTest methods. Source reconciliation reports 316 Implemented
plus one DisabledImplemented product and zero unresolved methods. The
receiver-aware public API inventory contains 357 Observed, one ContractCovered,
and seven Deferred rows. These current-source counts supersede the older
318-product and pre-split source states; the 673/673 result remains only the
latest verified runtime baseline until all physical source moves are stable
and the coherent batch is built and executed.

The synthetic Support umbrella product was removed because its 288 labels did
not select receiver-specific behavior. Independent domain reviews and repairs
have now closed every ordinary assertion-depth gap: the final disposition is
314 Complete, zero ordinary ChangeRequired, and three prerequisite-backed
Deferred products. Physical owner splits, linked production-change ownership,
and final execution gates remain separate work and are not inferred from that
assertion result.

The former 200,000-line expectation is retired. There is no replacement line
quota. Deterministic generation is appropriate when it preserves stable case
IDs, complete printed source, independent expectations, and per-cell failure
evidence.

## Verified execution baseline

| Evidence | Current reviewed value | Meaning |
| --- | ---: | --- |
| Active SDK prefix | 673/673 PASS | All currently active registered SDK tests passed after the seven direct internal-method products and all case-owned fixture conversions entered the binary; selected 2.38 fixtures remain discoverable and Disabled. |
| Failed / not run / in process / warnings | 0 / 0 / 0 / 0 | The current report is terminal and clean. |
| Process state | Exit 0, 151,256 ms, normal shutdown, no fatal/assert/unhandled/access-violation/timeout marker | No crash was observed in the accepted current run. The log ends with normal test completion and status-zero process exit. Earlier diagnostic failures and test-fixture crashes remain retained in `issues.md` and are not erased by this result. |
| Unique printed generated-source IDs | 31,213 | The final log contains 62,438 `[AS-SOURCE-BEGIN]` records; complete generated source and comment-only native-input review sources were visible for the implemented generated cases. |

Current authoritative report:
`Saved/Tests/as-native-sdk-after-internal-lifecycle-batch/20260727_090633_843_741d9740/Report/index.json`.
It contains 673 successful results and no other state. Runner metadata and
generated-source reconciliation are terminal: process/wrapper exit 0,
`TimedOut=false`, 151,256 ms, 62,438 source-begin records, and 31,213 unique
source IDs. This is execution evidence for the implemented subset and does
not close the inventories below.

## Source and catalog baseline

| Scope | Current reviewed value | Closure caveat |
| --- | ---: | --- |
| SDK source | 260 `.cpp`, 15 headers | Current source includes the independently reviewed Compiler, Parser, and Tokenizer physical splits and requires a new coherent build after the five remaining moves. |
| CQTest methods | 688 total: 674 active and 14 Disabled by static registration state | Every method has a product, product-part, or explicit non-product disposition; runtime discovery totals require the next aggregate run. |
| Method/product reconciliation | 688 final rows | Every method has an individually reviewable product, product-part, or non-product disposition and zero method-region gaps. |
| Catalog products | 317 | 316 enabled products and one selected-2.38 Disabled product; catalog validity does not prove runtime success. |
| Expected IDs | 46,140 | 45,994 CurrentFork, 81 RejectByFork, and 65 Future238Disabled IDs. |
| Reconciled product state | 316 Implemented, 1 DisabledImplemented | This reconciles declared products only; there are zero incomplete declared products. |
| Public API rows | 365 | The receiver-aware scanner reports 357 Observed, one ContractCovered, 7 `ApiDeferred` with concrete source-backed prerequisites, and 0 unresolved `DirectOrContract` rows. Direct execution remains intentionally absent for cleanup setters without dispatch, no-op `ClearImports`, unsafe zero-count `GetInterface`, and delegate getters whose required positive lifecycle is unsafe. |
| Predecessor scenarios | 222 | All have terminal dispositions: 7 Implemented, 205 Superseded by exact stronger products, 8 `ApiDeferred` selected-2.38 expectations, and 2 Obsolete requirements. The scanner still reports 24 predecessor names present and 198 missing, but name presence is no longer confused with semantic coverage. |
| Internal methods | 1,002 | Final: 171 `DirectCovered`, 803 `PublicContractCovered`, 28 `ApiDeferred`, and 0 pending. Every deferred row has a stable ID and concrete source-backed prerequisite. |
| Raw-AS wrappers | 301 sources, plus 2 registered escaped exact inputs | The latest synchronized inline audit reports 301 conforming sources and 0 violations. |

## Coverage depth interpretation

Strong generated products already exist for several Language, Frontend, Engine,
Compiler, TypeSystem, Runtime.Debug, and control/lifetime themes. They prove
that deterministic complete local products can work at this repository's
scale. They do not make the remaining domains complete:

- Every domain now has method-level product/non-product ownership, including
  all current Compiler methods. Predecessor and internal-method inventories
  have terminal dispositions; assertion depth, deferred production
  prerequisites, lifecycle quality, and final execution still prevent
  whole-domain closure.
- Public API disposition is now closed at the inventory level, but seven
  source-backed `ApiDeferred` rows remain runtime implementation work and must
  not be described as executable positive behavior.
- Predecessor and internal-method records are final semantic mappings, but
  their deferred entries are not enabled positive behavior and do not waive
  their recorded production or selective-backport prerequisites.
- A product annotation can cover many methods, but every method still needs a
  traceable product or an explicit non-product disposition.
- Green aggregate execution cannot replace assertion-layer review for runtime,
  metadata, debug, lifecycle, cleanup, isolation, save/load, and recovery
  evidence.

## Predecessor terminal-disposition checkpoint — 2026-07-27

All 222 predecessor scenarios now have a final, individually reviewable
disposition. Seven surviving method names are exact current product owners.
Two hundred and five broader or renamed scenarios map to 215 distinct current
product IDs with exact catalog owner, owner method, and expected contract
evidence. Eight selected-2.38 positive semantics remain discoverable Disabled
under `V238-DESIRED-BEHAVIOR` with `#as-v238-backport`; they are not reported
as current-fork success. Two requirements are obsolete because their runtime
surface no longer exists: the removed builder `enumDescriptions` temporary
table and a nonexistent global memory-callback registration API.

`ReconcilePredecessorScenarios.ps1 -RequireFinalDisposition` passes all 222
rows. No source-missing predecessor name was automatically classified as a
coverage gap, and the final audit found no predecessor that independently
requires a new product after mapping to the current deeper owners. This closes
task 1.7 but does not close any domain whose internal-method or assertion-depth
review remains open.

## Internal-method terminal-disposition checkpoint — 2026-07-27

All 1,002 frozen source-internal method records now have a reproducible,
method-level terminal disposition. `FinalizeInternalMethodDispositions.ps1`
joins the 570-row Engine/Frontend/Compiler review, the 431-row
Runtime/Language review, the missing `asCDataType::CreatePrimitive` addendum,
the five Runtime/TypeSystem direct owners, and the six-method Compiler
feasibility follow-up. It refuses an inventory other than the reviewed 1,002
rows, duplicate keys, missing review keys, blank stable IDs, or deferred rows
without a concrete rationale.

The resulting `audits/internal-method-dispositions.csv` contains 171
`DirectCovered`, 803 `PublicContractCovered`, and 28 `ApiDeferred` rows.
`ReconcileInternalMethods.ps1 -RequireComplete` produces 1,002 Final and zero
Pending rows in `audits/internal-method-reconciliation.csv`.

Ten former deferred gaps now have direct focused owners: primitive type-ID
reconstruction; object-type destruction, function release, and property
release; script-function reference release; compiler construction, reset, and
destruction; and both template-covariance classifiers. The remaining 28 rows
stay deferred because the production path is unwired or broken, the compile
configuration is unreachable, a narrow test seam is required, or a selected
2.38 feature such as lambda conversion has not been ported. This closes task
1.8 without misreporting those prerequisites as enabled current-fork success.
The seven new products and 47 new stable cases now have coherent build,
focused execution, and complete 673/673 SDK evidence. Their source-level
internal ownership remains distinct from the 28 prerequisite-backed deferred
rows; a green aggregate run does not convert those deferred behaviors into
current-fork positives.

## Fixture ownership and large-file quality checkpoint — 2026-07-27

The 232-file source review applies the native-core rule from
`Documents/UnitTest/UnitTest.md`: each case owns its raw engine, modules, and
contexts unless several methods intentionally share an immutable registration
surface. It found 120 compliant files and 112 requiring lifecycle work. The
open set consisted of 12 case-local create paths without complete engine
destruction and 100 mutable or unjustified class-owned engines. Eight
class-owned fixtures have a proven immutable shared registration surface and
complete hooks; one additional fixture destroys and recreates its member
engine in `BEFORE_EACH`. Every discovered raw context has an explicit release
or scoped owner.

The first repair batch adds immediate multiline destruction guards to all 29
previously unguarded ordinary create paths across the 12 files. Together with
three existing ordinary guards, static accounting is now 32 creates / 32
destroy guards. Scope declaration order leaves module/context cleanup before
engine destruction. Inline-AS and raw-SDK boundary audits remain clean.

The case-ownership batches convert all 100 unjustified shared fixtures:
Frontend 11, Runtime 13, Module 8, Compiler 16, Language 43, TypeSystem 5,
Engine 3, and Embedding 1. Runtime/Module have 49/49 affected methods,
Compiler has 69/69, Language has 50/50, and the Engine/TypeSystem/Embedding
batch has 22/22 with method-local raw engines and immediate multiline destroy
guards. Special cases retain explicit semantics: the Module API deliberate
destroy/recreate path remains balanced; Language's three former shared power
contexts are case-owned and released; native callback observers reset at case
entry and scope exit; and JIT/message callback owners detach callbacks before
their backing objects and engines are destroyed.

The coherent lifecycle/internal-owner build passes after two retained
test-fixture diagnostics were repaired. All seven new product owners pass
their focused prefixes, and the complete current-source SDK prefix is
673/673 PASS with process/wrapper exit 0, `TimedOut=false`, normal shutdown,
and no crash marker. This closes task 4.5 without using aggregate success as
evidence for the still-open assertion-depth or semantic-file-split work.

The size review identifies 42 files above 1,000 lines. Twenty-eight remain
cohesive generated owners or tightly coupled semantic families and are not
split merely to reduce line count. Fourteen mix independent catalog products,
positive/rejection protocols, internal classes, or failure responsibilities
and require semantic splits; seven overlap the lifecycle conversion work.
Task 4.5 is closed. Task 4.7 remains open until the 14 semantic splits
preserve their product owners, IDs, printed sources, assertions, and
focused/full verification.

## Engine method-ownership checkpoint

The Engine method-region inventory is now closed without claiming the whole
Engine domain closed. Fourteen previously unowned methods gained independent
products and four predecessor/aggregate methods gained explicit stronger-owner
dispositions. The enabled products cover default and transition-level atomic
behavior, batched concurrency, cross-engine callback reuse, module enumeration
including one-past-end lookup, all empty-engine GC modes with their exact return
contract, exact overload rejection, two-allocation LIFO reuse for both internal
memory pools, populated bulk release, and simultaneous three-worker TLS
isolation.

The first Engine parent run exposed one test-oracle defect: this fork's
non-full `asGC_ONE_STEP` path returns `1` to mean the cycle remains unfinished,
even for an empty engine. The exact current-fork return is now asserted rather
than treating all successful calls as zero. The repaired Lifecycle run is 4/4,
the Engine parent is 40/40, and the complete SDK prefix is 659/659. Engine
internal-method and predecessor records remain open, so task 5.1 is not checked.

## Conformance method-ownership checkpoint

Conformance's fourteen unowned methods are now terminal at the method-region
layer. Ten focused selected-2.38 fixtures remain compiled, discoverable,
Disabled, and tagged; they are explicit predecessors of the stronger
`V238-DESIRED-BEHAVIOR` feature-by-evidence product rather than duplicate
products. The metadata-only concrete inheritance predecessor maps to
`LANG-INH-CLASS-RULE`.

The three independent enabled products retain behavior that was not owned
elsewhere. Data-stack limits now prove property installation/readback, exact
`Stack overflow` text, exception function, callstack metadata, unprepare, and
same-context recovery. Application-interface registration proves exact
type/function IDs, flags, zero size, function kind, TypeInfo ownership, and
cross-engine absence. The former call-limit test was corrected after source
review showed `asEP_INIT_CALL_STACK_SIZE`, `asEP_MAX_CALL_STACK_SIZE`, and
`asEP_MAX_NESTED_CALLS` are stored but never consumed by context execution in
this fork: the enabled regression sets all three to one and requires depth-four
recursion to finish.

Conformance focused execution is 4/4 and the complete SDK prefix is 659/659.
This reduces global unresolved methods from 235 to 221 without changing the
active/Disabled split.

## Embedding method-ownership checkpoint

Embedding's twenty-three previously unowned CQTest methods are now terminal at
the method-region layer. Five independent products cover nine native call ABI
shapes, four calling-convention dispatch surfaces, five global callback
argument shapes, two global registration surfaces, and three object
registration contracts. All generated script fixtures use stable IDs and are
printed in full; the latest inline and raw-SDK boundary audits report zero
violations.

The first Embedding parent run was 17/27. Nine CallFunction cases exposed that
the old shared registration helper used unnamed application-function
parameters; this fork rejects those declarations with
`asINVALID_DECLARATION` (`-10`). The old tests collapsed every registration
into shared booleans and returned before compiling or executing the nine ABI
paths. Each case now owns its raw engine, exact named declaration, automatic
caller, module, context, and cleanup. The focused CallFunction prefix is 9/9.

Global registration exposed a distinct current-fork lookup mismatch. A
registered system function publishes `int DoubleValue(int)`, but
`GetGlobalFunctionByDecl` reparses by-value primitive parameters through script
normalization and cannot round-trip either that declaration or the
`const int` spelling. The enabled regression retrieves the positive function
through the registration-returned ID, proves its exact metadata and runtime
dispatch, and asserts the declaration lookup limitation without falling back
to a name-only guess.

The final Embedding prefix is 27/27 and the complete SDK prefix is 659/659,
both with normal shutdown and no crash marker. Method reconciliation is now
673 = 261 product-owned + 214 explicit non-product + 198 unresolved, reducing
the global method gap from 221 to 198 and leaving zero Embedding method-region
gaps. Embedding predecessor/internal-method and assertion-depth review remain
open, so task 5.7 is not yet checked.

## Runtime method-ownership checkpoint

Runtime's twenty-five prior method-region gaps are now terminal through ten
focused products plus source-backed helper/predecessor dispositions. The new
invocation owner executes arity zero through three crossed with void and integer
returns, prints all eight complete sources, validates every argument slot and
return path, and uses a native observer because this fork rejects mutable script
globals. Arithmetic exception coverage separately crosses divide/modulo with
direct/nested calls using runtime local operands, because literal zero division
is rejected during constant folding.

ContextInvocation is 6/6, ContextControl is 6/6, Runtime is 43/43, and the
complete SDK prefix is 660/660. The accepted full log contains 62,048 printed
source-begin records for 31,019 unique IDs, terminates normally, and has no
crash marker. Reconciliation is now 674 = 271 product-owned + 230 explicit
non-product + 173 unresolved, leaving zero Runtime method-region gaps.

This does not close Runtime as a domain: predecessor and internal-method
dispositions, assertion-depth review, and whole-change final gates remain open.
The current 660/660 result proves the implemented subset only.

## TypeSystem method-ownership checkpoint

TypeSystem's thirty-three prior method-region gaps are now terminal through
seven focused products and source-backed stronger-owner dispositions. The new
owners cover exact configuration-group storage-only behavior, native reference
handle metadata and variable-storage shapes, default-trait metadata crossed
with runtime dispatch, native/script enum registration and execution, scalar
global-property read/write/read-modify-write paths, typedef registration plus
bytecode save/load, and block/for/while/if variable-scope acceptance and
rejection boundaries.

The first TypeSystem parent run was 36/40. It exposed four independent
test-oracle or harness defects rather than runtime crashes: native
configuration-group execution omitted the fork-required automatic caller;
handle metadata size had been conflated with handle variable-storage size; the
boolean read-modify-write cell started from the wrong sentinel; and typedef
declaration lookup assumed the public declaration retained the alias spelling.
After source-backed repairs, the focused typedef owner is 1/1 and the complete
TypeSystem parent is 40/40.

The authoritative SDK prefix is now 662/662 with zero warnings, failures,
not-run, or in-process tests, normal shutdown, and no crash marker. Its log has
62,134 generated-source begin records and 31,062 unique source IDs.
Reconciliation is 676 = 278 product-owned + 258 explicit non-product + 140
unowned. TypeSystem has no remaining method-region gap; the remaining 140 are
Compiler 61, Language 40, and Module 39.

This does not close TypeSystem as a domain: predecessor and internal-method
dispositions, assertion-depth review, and whole-change final gates remain open.
The current 662/662 result proves the implemented subset only.

## Module method-ownership checkpoint

Module's thirty-nine prior method-region gaps are now terminal through nine
new products and one existing bytecode-stream owner. The new products separate
failed-build recovery, function inventory and scalar/argument ABI, global
inventory/reset/removal, import metadata and binding transitions, module
creation/discard/replacement identity, namespace lookup, public function
save/load, section diagnostics/resolution, and rich top-level table rebuild.
Six primitive restore methods map to the existing
`MOD-BYTECODE-STREAM-RESTORE` scenarios rather than duplicating that product.

The first Module parent run was 48/49 with no crash. The only red assertion was
an intentional depth addition in `ModuleGlobalResetState`: after mutating two
pure-constant storage slots through the public address API, `ResetGlobalVars()`
returned success but retained both mutations. Source review confirms
`asCModule::CallInit()` deliberately skips `isPureConstant`. The enabled
contract now asserts the exact retained values and prints a visible fork
limitation instead of reverting to the historical return-code-only smoke.
Globals is 3/3 and the final Module parent is 49/49.

The complete SDK report remains 662/662 with zero warnings, failures, not-run,
or in-process tests, normal status-zero shutdown, and no crash marker. The log
has 62,134 generated-source begin records and 31,062 unique source IDs. Static
reconciliation is 676 = 287 product-owned + 288 explicit non-product + 101
unowned. Module has no remaining method-region gap; the remaining 101 are
Compiler 61 and Language 40.

This does not close Module as a domain: linked restore-runtime reconciliation,
predecessor and internal-method dispositions, assertion-depth review, and
whole-change final gates remain open. The current aggregate result proves the
implemented subset only.

## Linked runtime repairs

Production semantic repairs discovered while building this suite are no longer
owned implicitly by the coverage change. Their contracts and verification live
in:

- `fix-as-reference-bytecode-ownership-persistence`;
- `fix-as-script-class-restore-lifecycle`;
- `fix-as-object-last-native-calling-convention`;
- `fix-as-engine-property-default-initialization`;
- `fix-as-static-jit-debug-text-whitespace`;
- `fix-as-switch-int-max-lowering`;
- `fix-as-double-int64-bytecode-execution`.

See `runtime-change-map.md` for hunk ownership and overlap rules.

## Production-hunk ownership closure — 2026-07-27

The current plugin production diff contains 23 files, 166 zero-context
hunks, and 166 unique file/new-line keys. Reconciliation now gives every row a
terminal classification:

| Primary disposition | Hunks | Current linked verification state |
| --- | ---: | --- |
| `fix-as-reference-bytecode-ownership-persistence` | 64 | P022, P138/P142/P149/P150/P151, P165, and P166 are explicitly included; fresh broad linked gates remain. |
| `fix-as-script-class-restore-lifecycle` | 56 | Open linked verification. |
| `fix-as-object-last-native-calling-convention` | 34 | Open linked verification. |
| `fix-as-engine-property-default-initialization` | 1 | Linked change complete. |
| `refactor-as-native-sdk-regression-suite` | 2 | Completed exact string-scan export owner. |
| `fix-as-static-jit-debug-text-whitespace` | 1 | Source/regression and historical AOT evidence present; fresh linked gates remain. |
| `fix-as-switch-int-max-lowering` | 4 | Source/regression and historical red/green evidence present; fresh linked gates remain. |
| `fix-as-double-int64-bytecode-execution` | 2 | Linked change complete: exact interpreter owners pass Parameters `1/1` and Numeric `4/4`; exact generated owner `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter` passes in canonical regenerated/built AOT `11/11`; complete SDK passes `674/674`; strict/planning/whitespace gates pass; standalone coherent `-NoXGE` build passes with process/runner exit `0/0`, `TimedOut=false`, and an up-to-date zero-action result. |
| Explicit user-authorized non-semantic terminology cleanup | 2 | Terminal without behavioral root-cause ownership; no runtime regression required. |
| **Total** | **164** | **Zero `Unowned`; task 2.6 complete.** |

The corrected classification separates lowercase-leading
`asBCTYPE_wW_rW_ARG` numeric conversions from uppercase
`asBCTYPE_W_rW_ARG` GETOBJ/reference persistence. The retained 673/673 SDK
baseline predates this record closure and is not fresh final evidence for all
linked changes. Task 2.7 therefore remains open.

## Language method-ownership checkpoint

Language's prior 40 method-region gaps are closed without converting legacy
methods into nominal product owners. Thirty-eight methods now carry explicit,
source-backed dispositions to stronger products. Two independent behavior
owners were retained and deepened:

- `LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT` owns seven generated and printed
  factory-local, overwrite, null-assignment, parameter/return,
  exception-frame, save/load, and parameter/return-save/load transitions. The
  owner compares source/restored bytecode and object metadata where applicable,
  exact construction/AddRef/Release/destruction counts and identities,
  exception or return state, same-context recovery, and zero live references;
- mixin behavior is split by what the fork actually supports:
  `LANG-FN-MIXIN-DIRECT-DISPATCH` owns global and nested extension-member
  execution, while `LANG-FN-MIXIN-FREE-CALL-REJECTION` owns global and nested
  ordinary free-call rejection with exact signature diagnostics and no
  partially published entry.

The generated-source registry initially named the instance operation as
`FString::ReplaceInline`. Exact builder validation correctly stopped before
regenerating audits, leaving the previous 293-product CSV in place. The
registry now names the source token `ReplaceInline`; fresh expansion and
reconciliation report 294 products, 46,251 unique IDs, 293 Implemented plus
one DisabledImplemented, and zero incomplete products. ID classification is
46,112 CurrentFork, 74 RejectByFork, and 65 Future238Disabled.

The final coherent build passes. Focused mixin and counted-reference owners are
both 1/1, the Language parent is 162/162, and the complete SDK prefix is
662/662 with zero warnings, failures, not-run, or in-process tests. The SDK log
has 62,142 generated-source begin records and 31,066 unique IDs, ends with
`GIsCriticalError=0` and status-zero test completion, and has no crash marker.

Static method reconciliation is now 676 = 289 product-owned + 326 explicit
non-product + 61 unowned. Language has 127 product-owned and 38 explicit
non-product methods with zero method-region gaps; Compiler owns all remaining
61 gaps. This checkpoint does not close Language as a domain: all-language
predecessor/internal-method dispositions, assertion-depth review, and final
whole-change gates remain open.

## Complete pre-repair assertion-depth review — 2026-07-27

Five independent handoffs now cover every one of the 318 catalog products by
exact Owner rather than by theme name or file proximity:

| Review scope | Products | Complete | ChangeRequired | Deferred |
| --- | ---: | ---: | ---: | ---: |
| Engine + TypeSystem + Embedding | 62 | 31 | 29 | 2 |
| Frontend + Compiler | 70 | 23 | 47 | 0 |
| Runtime + Module | 53 | 26 | 27 | 0 |
| Language + Conformance | 132 | 124 | 7 | 1 |
| Support | 1 | 0 | 1 | 0 |
| **Total** | **318** | **204** | **111** | **3** |

The three Deferred products retain concrete prerequisites: unsafe positive
delegate lifecycle, unsafe reference-cast mismatch/cross-engine boundaries,
and selected-2.38 desired behavior whose entire class remains discoverable
Disabled under `#as-v238-backport`. No ordinary assertion gap is hidden as
Deferred.

The 111 ChangeRequired rows are a pre-repair baseline, not a remaining-count
claim. The active first repair batch has already addressed all nine
TypeSystem findings and the JIT/generic portion of Embedding. Each repaired
product still requires source re-review, catalog regeneration, build, focused
execution, and aggregate execution before its final disposition changes.

The reviews also expose a synthetic Support product:
`NATIVE-DOMAIN-API-LIFECYCLE` generates 288 domain/operation/evidence labels,
but most cells execute the same engine/module path. Its domain labels do not
select receiver-specific APIs, and four operation labels do not change the
behavior at all. This product must be replaced by exact owners or removed in
favor of existing stronger products; adding more nominal cells would deepen
only the count, not the contract.

The dominant missing oracles are observable cleanup and isolation, followed
by owner/Expected range mismatch, lifecycle, runtime, compile publication, and
exact diagnostics. A scope guard, a `Destroy`/`Release` call, case-owned
engine, or compile success is never credited as the missing postcondition by
itself. Existing but undeclared SaveLoad and Recovery evidence is also
recorded so the final catalogs can state what the tests actually prove.

## First assertion-depth repair runtime checkpoint — 2026-07-27

The synthetic Support product has been deleted, leaving 317 real products and
an interpreted pre-repair baseline of 204 Complete, 110 ChangeRequired, and
three prerequisite-backed Deferred. TypeSystem's nine staged repairs now
compile and its complete parent passes 45/45. Embedding's nine staged repairs
now compile and its complete parent passes 27/27 after retained 14/27 and 25/27
diagnostic runs.

The runtime work found one confirmed production defect: registered enum
TypeInfo user-data cleanup callbacks are not dispatched at engine destruction.
It also reconfirmed the application-global declaration round-trip defect.
These and the broader current-fork findings now have a dedicated triage index
in `fork-defect-analysis.md`, with production defects separated from
compatibility limitations and test-oracle defects.

The Embedding failures exposed incorrect test assumptions rather than product
registration leaks: every `FNativeTestEngine` control intentionally owns
`assert(bool)`; default method declarations include their owner; construction
behaviors publish owner-shaped declarations; and the double-backed scalar
publishes as `float`. Repaired tests preserve registration input, exact
reflection, runtime dispatch/ABI, cleanup, and engine isolation as independent
evidence.

This checkpoint does not automatically convert all eighteen reviewed
TypeSystem/Embedding products to Complete. Each changed product still requires
independent source re-review against its declared evidence. Approximately 85
original ChangeRequired products outside the staged 25-product batch remain
untouched.

## Engine assertion-depth closure — 2026-07-27

Engine's eleven pre-repair `ChangeRequired` products now have independent
post-repair dispositions in
`handoffs/assertion-depth-engine-repair-review.csv`: all eleven are Complete.
Together with the 23 previously Complete products and two prerequisite-backed
Deferred object-service products, Engine is now 34 Complete, 0 ChangeRequired,
and 2 Deferred.

The first coherent build passed. The first Engine parent was 39/40 and exposed
that `DiscardModule()` removes name lookup publication while
`GetModuleCount()` and `GetModuleByIndex()` retain discarded entries. The
owner now asserts both sides of that current-fork contract and logs
`[AS-FORK-LIMITATION]`; it does not falsely claim an empty indexed inventory.
The final build
`Saved/Build/as-native-sdk-engine-assertion-depth-final/20260727_110729_584_ba0ce727/`
passes, and the final Engine report
`Saved/Tests/as-native-sdk-engine-assertion-depth-final/20260727_110821_901_8768de0c/`
is 40/40 PASS with zero failed/skipped tests, process/wrapper exit 0,
`TimedOut=false`, normal shutdown, and no crash marker.

Catalog expansion is now 317 products and 46,140 unique expected IDs:
45,994 CurrentFork, 81 RejectByFork, and 65 Future238Disabled. Engine closure
raises the proven post-review floor to 215 Complete, 99 not-yet-finalized
ChangeRequired, and 3 Deferred products. The TypeSystem, Embedding, and
Language/Conformance source repairs are not promoted by this Engine review.

## TypeSystem and Embedding assertion-depth closure — 2026-07-27

The eighteen repaired TypeSystem/Embedding products now have independent
post-repair dispositions in
`handoffs/assertion-depth-typesystem-embedding-repair-review.csv`. All eighteen
are Complete:

- TypeSystem is 17 Complete, 0 ChangeRequired, 0 Deferred;
- Embedding is 9 Complete, 0 ChangeRequired, 0 Deferred.

This review accepts only evidence present in the current owner. Four products
were narrowed to remove unsupported lifecycle/cleanup labels; no generated
cell or runtime path was removed. Typedef SaveLoad is now declared, JIT paths
execute exact entries, generic/callback/ABI products assert post-discard
baselines, and aggregate Embedding products use explicit product-part owners
instead of claiming unrelated methods by file proximity.

Accepted parents remain TypeSystem 45/45 and Embedding 27/27, both with normal
shutdown and no crash. The registered-enum zero-callback behavior remains an
enabled negative contract and does not close `AS-FORK-DEFECT-001`.

The proven post-review floor is now 233 Complete, 81 not-yet-finalized
ChangeRequired, and 3 prerequisite-backed Deferred products. The seven staged
Language/Conformance repairs still await their independent review.

## Language and Conformance assertion-depth repair review — 2026-07-27

The seven ordinary repaired products now have independent final dispositions
in `handoffs/assertion-depth-language-conformance-repair-review.csv`. All seven
are Complete. The original 132-row Language/Conformance review is therefore
131 Complete, 0 ChangeRequired, and one prerequisite-backed Deferred
`V238-DESIRED-BEHAVIOR` product.

ControlFlow cleanup is explicit and no longer double-releases context/module
owners. Every generated cell detaches its native observer and proves module
absence before the next cell. Mixin member dispatch and free-call rejection
remain separate enabled products with an independent native sentinel.
Conformance call-limit properties remain an enabled stored-but-unenforced
negative contract, while real data-stack recursion owns the actual exception
and recovery path.

Accepted runs are ControlFlow 12/12, Language 162/162, and active Conformance
4/4, all with normal shutdown and no crash after the retained diagnostic crash
was repaired. Selected 2.38 sources remain discoverable Disabled and tagged;
they are not counted as active current-fork success.

The proven whole-change disposition floor is now 240 Complete,
74 not-yet-finalized ChangeRequired, and 3 Deferred products.

## Frontend assertion-depth closure — 2026-07-27

All thirty original Frontend `ChangeRequired` products now have independent
final dispositions in
`handoffs/assertion-depth-frontend-repair-review.csv`: all thirty are
Complete. Together with the 23 previously Complete products, Frontend is now
53 Complete, 0 ChangeRequired, and 0 Deferred.

Fourteen lexer/internal products remove unsupported `Compile` evidence because
their complete input products intentionally contain malformed, unterminated,
split, or non-module text, or directly exercise protected classification
helpers. `FRONTEND-SCRIPT-CODE-ROW-COLUMN` removes unsupported Cleanup because
the value-owned `asCScriptCode` path exposes no parser/module cleanup surface.
No axis, generated cell, diagnostic, metadata assertion, or printed source was
removed.

Parser and script-node owners now release parser/builder/tree state before
requiring successful module discard and null name lookup. Products that claim
Isolation run independent clean controls and assert exact AST or diagnostic
state. Both string owners release the owned string/view graph before asserting
external buffers, independent copies, and fresh empty baselines. The
generated-source registry includes every added control source.

The initial build retained one test-source diagnostic: two `[[nodiscard]]`
assertion results in the diagnostic cleanup helper were not consumed. The
corrected and final builds pass. The final Frontend parent at
`Saved/Tests/as-native-sdk-frontend-assertion-depth-final/20260727_113923_886_aaa6ab57/`
is 169/169 PASS with zero failed/skipped, process/wrapper exit 0,
`TimedOut=false`, 34,171 ms duration, normal status-zero shutdown, and no
fatal/assert/unhandled/access-violation marker. Its log contains 1,198
source-begin records and 599 unique printed IDs.

The proven whole-change disposition floor is now 270 Complete,
44 not-yet-finalized ChangeRequired, and 3 prerequisite-backed Deferred
products. The remaining ordinary assertion gaps are Compiler 17, Runtime 11,
and Module 16.

## Compiler assertion-depth closure — 2026-07-27

All seventeen original Compiler `ChangeRequired` products now have independent
final dispositions in
`handoffs/assertion-depth-compiler-repair-review.csv`: all seventeen are
Complete. Together with the twelve previously Complete products, Compiler is
now 29 Complete, 0 ChangeRequired, and 0 Deferred.

The review accepts only current source evidence. Builder shape and recovery
products now require the exact failed stage, diagnostic section, row, and
message fragment; rejected modules are removed before same-name recovery.
Four builder-application products give all 84 generated cells independent
case/control module identities and two-sided explicit cleanup. Warning and
direct `CompileFunction` products assert engine-property or clean-control
isolation. Declaration, global, layout, and parse owners release transient
builder/parser/AST observations before exact module cleanup. Bytecode owners
retain runtime, opcode, metadata/debug, and optimization-property restoration
evidence.

The first complete Compiler parent after this batch was 118/120 PASS. Both
failures were test-oracle mismatches in the new Cartesian-depth owner: the
fork reports missing-type failure at the Functions stage, unterminated source
as `Unexpected end of file`, and a malformed class member as
`Expected method or property`. After correcting only those exact expectations,
the focused owner is 2/2 PASS and the final Compiler parent at
`Saved/Tests/as-native-sdk-compiler-assertion-depth-final/20260727_120756_181_372e963a/`
is 120/120 PASS with zero failed/skipped tests, process/wrapper exit 0,
`TimedOut=false`, 30,947 ms runner duration, 678 source-begin records,
338 unique printed source IDs, normal shutdown, and no
fatal/assert/unhandled/access-violation marker.

The proven whole-change disposition floor is now 287 Complete,
27 not-yet-finalized ChangeRequired, and 3 prerequisite-backed Deferred
products. The remaining ordinary assertion gaps are Runtime 11 and Module 16.

## Runtime assertion-depth implementation and red/green repair — 2026-07-27

All eleven Runtime products from the independent `ChangeRequired` review now
have direct source implementations:

- six Context products cover control execution, arithmetic fault metadata,
  suspend rejection, return ABI/control paths, stack overflow, same-context
  recovery, and independent controls;
- three ScriptObject products cover construction/copy/assignment isolation,
  public retain/release ownership, weak-flag fork behavior, TypeInfo/type-ID/
  engine identity, exact destruction, and explicit module/userdata cleanup;
- two GC products cover empty service contracts and four independent
  self/two-node detect-then-full/direct-full lifecycle scenarios.

The first concentrated build exposed and repaired one test-only C4458 parameter
shadowing issue. The first Runtime parent then ran 44 tests and failed only the
two ScriptObject owners: every final public release observed zero destructor
callbacks. Independent source tracing confirmed `AS-FORK-DEFECT-013`: the
fork's raw-object registry had VM ownership consumers but the public
`AddRefScriptObject()` / `ReleaseScriptObject()` entry points still became
no-ops for no-count script classes. The linked
`fix-as-script-class-restore-lifecycle` change now owns the minimal public-API
bridge. The tests retain the original exact lifecycle contract and add
per-origin increments plus a no-repeat assertion after module discard.

The repaired ScriptObject prefix is 3/3 PASS. The complete Runtime prefix at
`Saved/Tests/as-native-sdk-runtime-assertion-depth-final/20260727_133118_732_878ed5f4/`
is 44/44 PASS, process/wrapper exit zero, `TimedOut=false`, normal shutdown, and
has no fatal/assert/unhandled/access-violation marker. Runtime still requires
the final independent eleven-row disposition file after the strengthened
per-origin assertions are compiled in the coherent Module batch; the proven
aggregate floor therefore remains 287 Complete / 27 ChangeRequired /
3 Deferred until that review is materialized.

## Runtime and Module final assertion execution — 2026-07-27

The final Module assertion batch is now green. The corrected global metadata
owner separates internal primitive type IDs from public declaration spelling:
the two script `double` globals retain `asTYPEID_FLOAT64` while the fork
publishes them as `const float`. The incremental build succeeds, the focused
Globals prefix is 3/3 PASS, and the complete Module prefix at
`Saved/Tests/as-native-sdk-module-assertion-depth-green/20260727_142001_126_13598b04/`
is 51/51 PASS with status-zero normal shutdown and no crash.

The first final Runtime parent exposed a real access violation instead of a
test-only assertion failure. A derived raw script object stored through a
base-typed local was not retained because the new registry required exact
dynamic/static TypeInfo equality. Releasing the temporary left the base slot
dangling and virtual dispatch crashed in `asIScriptObject::GetObjectType()`.
This is retained under `SDK-DEPTH-235` as an incomplete
`AS-FORK-DEFECT-013` repair.

The runtime ownership transition now resolves the registered dynamic type,
accepts only exact, derived-to-base, or implementation-to-interface
compatibility, rejects unrelated TypeInfo, and runs final destruction against
the dynamic type. The repair build succeeds. The formerly crashing ThisPointer
owner is 1/1 PASS, the ScriptObject prefix is 4/4 PASS, and the complete Runtime
prefix at
`Saved/Tests/as-native-sdk-runtime-assertion-depth-final-green/20260727_142630_908_5de63093/`
is 44/44 PASS. All focused and parent runs exit zero, shut down normally, retain
their generated source in the log, and contain no crash marker.

These results close the runtime execution portion of the eleven Runtime and
sixteen Module assertion repairs. Independent row-level finalization is being
recorded separately. They do not close the fourteen semantic file splits,
four linked production-change reconciliation tasks, StaticJIT/cross-execution
acceptance, complete SDK rerun after this repair, or the final
NativeCore/full-suite/unit-tests-disabled gates.

## Runtime and Module independent assertion-depth closure — 2026-07-27

The independent final row-level reviews are now materialized in
`handoffs/assertion-depth-runtime-repair-review.csv` and
`handoffs/assertion-depth-module-repair-review.csv`. Runtime's eleven former
`ChangeRequired` products and Module's sixteen former `ChangeRequired`
products are all `Complete`; every cited owner and source range resolves in
the current tree. The final whole-change assertion disposition is therefore
314 Complete, 0 ordinary ChangeRequired, and 3 prerequisite-backed Deferred
products.

Runtime's direct execution evidence remains ThisPointer 1/1, ScriptObject 4/4,
and Runtime 44/44. Module's direct execution evidence remains Globals 3/3 and
Module 51/51. All accepted runs exit zero, shut down normally, and contain no
crash marker. The interface-compatible raw-object predicate is confirmed in
source, but a separate positive interface-view runtime cell is not fabricated:
this fork rejects core script-interface declarations, and the suite cannot
import an add-on solely to manufacture that fixture.

This closes tasks 5.4 and 5.10. It does not close physical test-file
organization, linked production-change reconciliation, StaticJIT parity, or
the final aggregate execution gates.

## Final production hunk ownership reconciliation — 2026-07-27

The current non-test plugin diff contains 23 production files and 166
zero-context hunks. Independent hunk-by-hunk review records every one in
`handoffs/production-hunk-ownership-final.csv`, with zero missing or duplicate
keys:

- 64 reference-bytecode ownership/persistence hunks;
- 56 script-class restore/lifecycle hunks;
- 34 object-last native-calling hunks;
- one deterministic engine-property-default hunk;
- two string-scan Runtime export hunks under the completed regression-suite
  owner;
- one StaticJIT debug-text hunk;
- four upper-bound switch-lowering hunks;
- two double-to-64-bit interpreter hunks; and
- two explicitly user-authorized non-semantic terminology hunks.

There are zero `Unowned` rows. P138/P142/P150/P151 and P149's invariant comment
are GETOBJ/reference persistence, not numeric conversion; P022 is the narrow
production-reader export required by the same exact regression owner. Task 2.6
is complete. Task 2.7 remains open because the newly linked records and other
open runtime changes still require fresh final build/runtime evidence.

## Historical implementation-ledger reconciliation — 2026-07-27

The historical ledger's 159 unchecked rows now have one explicit terminal
disposition each in
`handoffs/implementation-ledger-final-dispositions.csv`, with a human review
summary beside it. The original 315/474 checkboxes remain unchanged as a
historical snapshot and are no longer an ambiguous second completion counter.

The reconciled set is 86 `CompletedWithEvidence`, 49 `SupersededBy`, 14
`DeferredWithPrerequisite`, and 10 `StillActionable`. The CSV matches the
unchecked ledger IDs exactly, retains every original task sentence, resolves
all referenced task/issue/change/path evidence, and passes required-field,
forbidden-term, strict OpenSpec, and scoped whitespace validation.

This resolves `SDK-QUALITY-236`; it does not close the seven remaining physical
source splits, linked production repairs, deferred StaticJIT/2.38 behavior, or
the final NativeCore/full-suite/unit-tests-disabled and documentation gates.

## P166 retained-function GC red/green and Module oracle transition — 2026-07-27

The current catalog has 319 products and 46,156 stable IDs. Static catalog
validation and complete source reconciliation pass with 318 implemented
products plus one Disabled-implemented selected-2.38 owner, 697 methods, and
zero unresolved methods. These are structural ownership results, not a final
runtime verdict.

P166 selectively restores the pinned-2.38 successful-GC discarded-module
retirement branch. The concentrated build at
`Saved/Build/as-native-sdk-reference-gc-linked-batch/20260727_220317_222_5e28cc76`
passes. Variables Lifetime is 3/3 at
`Saved/Tests/as-native-sdk-reference-gc-green1/20260727_220353_534_b8c79428`,
including exact TypeInfo baseline restoration after final retained-function
release. Engine is 40/40 at
`Saved/Tests/as-native-sdk-reference-gc-engine-regression/20260727_220549_122_6a296834`.
Both runs exit normally with no crash.

The first Module regression at
`Saved/Tests/as-native-sdk-reference-gc-module-regression/20260727_220629_726_b1e6e120`
is 51/52 with a normal failure exit and no crash. Its only failure is the old
`MOD-USERDATA-LIFECYCLE` negative oracle: shutdown now retires the discarded
module and invokes its cleanup callback. The source is corrected to require
exactly one callback with exact owner/data identity and no repeat in a successor
engine. The coherent build at
`Saved/Build/as-native-sdk-module-userdata-gc-green/20260727_221434_267_8020fc8b`
passes 4/4 actions with process/final exit 0/0. The exact owner at
`Saved/Tests/as-native-sdk-module-userdata-gc-green-focused/20260727_221458_828_727cac44`
is 1/1 PASS and prints both registered review sources. The complete Module
parent at
`Saved/Tests/as-native-sdk-module-userdata-gc-green-parent/20260727_221533_694_52383ad1`
is 52/52 PASS, zero failed/skipped, normal shutdown, and no crash marker.

Module's catalog, assertion depth, script-class save/load lifecycle, P166
user-data consequence, generated-source visibility, and parent execution are
therefore closed. Cross-execution and whole-change gates remain under tasks 2.7
and 6.5–6.7 rather than keeping the Module theme itself artificially open.

## Current Language final parent and review reconciliation — 2026-07-27

The current Language source has 166 CQTest methods: 163 active methods and three
selected-2.38 property owners that remain discoverable Disabled with
`#as-v238-backport`. A direct comparison of the expanded catalog with
`assertion-depth-language-conformance-review.csv` and its repair review resolves
all 127 `LANG-*` products, with zero product missing from row-level assertion
review.

`Saved/Tests/as-native-sdk-language-current-final-review/20260727_222034_130_ae36933a`
is 163/163 PASS, zero failed/skipped, process/test exit 0, `TimedOut=false`, and
121,311 ms. The editor reports `GIsCriticalError=0`, status-zero shutdown, and
no fatal/assert/unhandled/access-violation marker. Its log contains 58,866
source-boundary records and 29,433 unique generated-source IDs, including the
latest retained-function, destructor declaration, script-object interaction,
and all generated language combination owners.

This closes Language task 5.8 at the active-fork layer. The three Disabled
property owners remain future 2.38 evidence rather than active passes.
StaticJIT/cross-execution and whole-change SDK/environment gates remain under
tasks 2.7 and 6.5–6.7.

## StaticJIT, complete SDK, and NativeCore final-stage results — 2026-07-27

The first canonical AOT run retained at
`Saved/Tests/as-native-sdk-comprehensive-current-final_04_tests/20260727_222551_452_b668f156`
crashed because the diagnostics loader did not register the newly shared
`FAotObjectLastProbe` native surface before loading paired precompiled data.
That fixture defect is recorded as `SDK-DEPTH-248`; it was not hidden by
skipping diagnostics or by crediting generated compilation as execution.

After the diagnostics loader registered the same surface as the main AOT
loader, the complete canonical workflow regenerated all four paired artifacts,
rebuilt the generated C++, and passed 12/12 AOT tests at
`Saved/Tests/as-native-sdk-comprehensive-current-final-green1_04_tests/20260727_222852_888_6d5de814`.
The exact generated explicit-argument object-last owner passes. The complete
StaticJIT parent then passed 30/30 at
`Saved/Tests/as-native-sdk-comprehensive-current-staticjit-full/20260727_222954_004_8d8fb9d3`,
including reference-copy TypeInfo remapping across precompiled load. Both runs
exit normally with no crash.

The final current-source SDK prefix at
`Saved/Tests/as-native-sdk-comprehensive-current-sdk-final/20260727_223150_574_a4d2f49c`
is 683/683 PASS, zero failed/skipped, process/final exit 0,
`TimedOut=false`, 127,752 ms, `GIsCriticalError=0`, normal shutdown, and no
crash marker. It prints 61,906 source-begin records representing 30,946 unique
generated-source IDs. Fourteen additional methods remain discoverable
Disabled with `#as-v238-backport`.

The configured `NativeCore` runner repeats its single heavy SDK prefix and is
683/683 PASS at
`Saved/Tests/as-native-sdk-comprehensive-current-nativecore-post-handle-slot-final_01_AngelScriptSDK/20260727_235231_209_42a6bbe3`.
It is recorded as the required configured-suite result, not misrepresented as
coverage of unrelated project prefixes.

## Final environment, aggregate, and record closure — 2026-07-28

The unit-test-disabled gate first exposed a real compile-surface defect:
`AngelscriptNativeCaseTestSupport.h` placed ordinary shared helper declarations
behind `WITH_ANGELSCRIPT_UNITTESTS`. Seven downstream translation units still
needed those declarations outside registration blocks, causing 792 cascading
compile errors. The support header contains no CQTest registration, so only
that outer helper gate was removed. The disabled build at
`Saved/Build/as-native-sdk-unit-tests-disabled-final-fix1/20260728_000123_165_e509239d`
then passes. With tests disabled, the editor reports 9,031 unrelated tests and
zero matches for `Angelscript.TestModule.*`; the runner's exit 255 is the
documented no-match result, not a crash. The configuration was immediately
restored to `bCompileAngelscriptUnitTests=true`.

The restored coherent build at
`Saved/Build/as-native-sdk-unit-tests-restored-final/20260728_000229_699_38a673dd`
passes 56 actions with process/final exit 0/0 in 96,112 ms. The restored SDK
run at
`Saved/Tests/as-native-sdk-comprehensive-restored-final/20260728_000418_207_c7795abc`
is 683/683 PASS, zero failed/skipped, process/final exit 0/0,
`TimedOut=false`, 137,150 ms, `GIsCriticalError=0`, normal shutdown, and no
crash marker.

The final configured All suite runs all 35 prefixes from the restored binary.
Every prefix has a `Summary.json`: 2,396/2,396 tests pass, zero fail or skip,
all process/final exits are zero, and no prefix times out. The artifacts are
`Saved/Tests/as-native-sdk-comprehensive-restored-all-final_01_Editor` through
`Saved/Tests/as-native-sdk-comprehensive-restored-all-final_35_WorldSubsystem`.
The suite wall time is 2,418.1 seconds.

Final generated audits report 271 SDK `.cpp` files, 697 methods, 683 active
methods, 14 Disabled methods, 8,359 assertions, and 165,064 physical lines.
Catalog/source closure is 319 products and 46,156 stable IDs:
46,010 CurrentFork, 81 RejectByFork, and 65 FutureDisabled. Method ownership is
314 ProductOwned + 57 ProductPart + 326 ExplicitNonProduct; API disposition is
357 Observed + 1 ContractCovered + 7 Deferred; predecessor disposition is
terminal for all 222 rows; internal disposition is 1,002 Final / 0 Pending.
Boundary, inline-AS formatting, and planning audits each report zero
violations. All eight main/linked changes pass strict OpenSpec validation,
the scoped forbidden-term scan has zero matches, the generated AOT fixture has
zero trailing-whitespace matches, and parent/plugin `git diff --check` both
exit zero.

All implementation and mandatory verification tasks are complete. The user
subsequently gave an explicit commit request, so the handoff was executed in
dependency order. The plugin submodule was split into five reviewable commits:
runtime fixes (`35e4b00`), Engine/Frontend/Compiler coverage (`50a9ac7`),
Language coverage (`708ce1b`), Conformance/Embedding/Module/Runtime/TypeSystem
coverage (`ea1316d`), and StaticJIT coverage (`cca79e9`). Parent OpenSpec,
baseline-document, and submodule-gitlink records follow as separate scoped
commits. Unrelated dirty files in both repositories remain unstaged.
