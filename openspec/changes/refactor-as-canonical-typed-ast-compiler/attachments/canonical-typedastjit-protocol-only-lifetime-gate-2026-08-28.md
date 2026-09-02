# Canonical TypedASTJIT protocol-only lifetime gate — 2026-08-28

## Decision

CTA-S53 Task 15.8 is complete for the current non-Standalone scope.
TypedASTJIT now consumes the same verifier-authenticated Canonical lifetime
protocol/shared derived view used by Canonical Bytecode. It no longer chooses
cleanup semantics by scanning destructor declarations, reclassifying storage
from type kind, treating `DeclStmt` as activation, or decoding positional or
string cleanup encodings.

The detached AOT/provider boundary copies only a revisioned pointer-free
lifetime summary. A function whose authenticated protocol requires an object
frame or exit ABI that TypedASTJIT does not implement receives a typed
per-function VM fallback; it is never emitted with a partial cleanup plan.

This is not a product-default cutover. `ep.canonicalCompilerPipeline` remains
`false`, explicit CANONICAL remains fail-closed, the native AngelScript Parser
AST/Builder/Compiler remain available for explicit LEGACY, syntax, recovery,
reference and differential use, HIR remains absent, and Standalone is deferred
to a separate future OpenSpec.

## Implemented architecture

### Authenticated, pointer-free per-function summary

`AnalyzeAngelscriptTypedASTJITCanonicalLifetimeFacts()` requires a Frozen,
publishable snapshot and a successfully derived `asCASTLifetimeView`. It
filters the shared protocol records and exit plans to one exact function and
builds `FAngelscriptTypedASTJITCanonicalLifetimeSummary` with:

- the protocol revision;
- a typed structural `StableKey`;
- a distinct cleanup ABI `ABIKey`;
- typed action flags (`DestroyValue`, `ReleaseReference`,
  `CommitDeferredOut`, `DestroyElement`);
- typed exit-plan flags (`Normal`, `Transfer`, `ForEach`);
- supported exit mask and exact record/exit-plan counts;
- the explicit `bNativeObjectFrameABIAvailable` capability bit.

The structural key hashes stable declaration/type identities, typed protocol
fields and derived ordinals. The ABI key hashes the storage/action ABI needed
to execute the plan. Neither key contains a raw pointer, snapshot-local
Decl/Stmt/Expr/Type ID, Engine-local numeric TypeId, rendered AST dump, JSON,
DOT or diagnostic text.

The summary is copied through backend function facts, generation diagnostics,
generated-provider POD rows, provider validation, registry-owned immutable
copies and installed diagnostics. No provider row retains an AST snapshot,
`asCASTLifetimeView`, protocol record pointer or callback-owned memory.

### Typed fallback boundary

Eligibility first authenticates the lifetime summary. Missing, invalid or
incomplete facts return `InvalidCleanupPlan`. A non-empty authenticated plan
currently sets `bNativeObjectFrameABIAvailable=false`; eligibility returns
`UnsupportedLifetime` with the precise reason
`AuthenticatedLifetimeRequiresNativeObjectFrameABI` and includes the stable
key, ABI key, record count, exit-plan count and typed flags.

An authenticated empty plan remains native-eligible. This preserves useful
TypedASTJIT coverage without pretending that script value-object destruction,
owning-reference release, deferred-out commit or partial construction can be
executed by the current native object frame.

BytecodeJIT/VM remains the explicit per-function fallback backend. Provider
selection validates the copied summary shape: an eligible native row must
carry an authenticated summary and the native-object-frame bit; an unavailable
Canonical function must carry an absent summary and an unverified cleanup
state. Mixed or half-filled provider rows are rejected.

### Removal of AOT semantic reclassification

The previous private TypedASTJIT proof walked statements and reconstructed
cleanup requirements by:

- resolving typedef/type families;
- searching the AST for a destructor whose owner name matched the type;
- inferring release versus destruction from reference/value/funcdef kinds;
- treating declaration statements as lifetime activation;
- reading compatibility cleanup bindings and foreach child position.

That implementation has been deleted. TypedASTJIT now reads only typed records
and exit plans from the authenticated shared view. Source gates explicitly
reject reintroduction of `FindCanonicalLifetimeDestructor`, destructor-name
selection, `FindCleanupBinding`, magic `scope-exit`/`scope-release` decoding or
positional foreach cleanup routing.

## Provider and lifecycle boundary corrections

The 15.8 work also closed several integration errors exposed by running the
real AOT/Cache/Provider lifecycle instead of only the isolated Canonical
adapter.

### Independent Engine/provider state

Provider-set identity and lifecycle state are Engine-scoped. Destructor-only
generated provider rows participate in the provider set, cache-disabled
identity remains deterministic, source-authoritative and explicitly supplied
provider routes do not overwrite one another, and Engine shutdown flushes the
current Cache transaction without leaking route state to another Engine.

The same-pipeline gate proves that the generated provider compiled from the
current source can be consumed by a fresh Engine without an out-of-band dump
or a second semantic representation. An explicit host/provider override stays
an explicit test input; it is not a hidden production fallback.

The TypedASTJIT switch-invalid diagnostic position is now derived from the
last sealed top-level case statement that emitted a source position, matching
the VM compiler's observable failure location without consulting legacy
Parser/compiler nodes.

### Prepared Canonical restore was outside the Cache lifecycle

The first full Fresh Cache run restored **0/69** functions. Root cause:
prepared CANONICAL CodeGen created authored and generated function shells but
called the emitter directly; it never invoked the existing build-artifact
restore callback. Cache V2 therefore had valid function artifacts but no
admission point in the Canonical prepared transaction.

The prepared path now calls `TryRestoreBuildArtifact()` for authored functions,
generated lifecycle functions and factories before generating a body. This
improved the result to **68/69** and isolated the final missing function:
`~UStaticJITAotVirtualChild()`.

### Same-module child-to-parent dependency was not yet published

The remaining artifact referenced a same-module parent function. During
prepared compilation, both child and parent shells existed but were deliberately
detached until the entire transaction succeeded. The ordinary reader looked
only in published module/Engine function tables, so it could not remap the
child's stable dependency even though the exact target was present in the
pending transaction.

`asSBuildArtifactRestoreContext` now supplies a synchronous, non-owning view of
the complete pending function set to the restore callback. It is descriptor
version 1, never persisted, never included in invocation identity, never
retained by the callback and valid only for that callback. `asCReader` may use
it only for an exact same-module match after the published table has no match;
Engine, module, object owner, function kind, namespace and full signature must
all agree. Ambiguity is corruption, not transaction-order selection.

This is a transient restore coordinate, not HIR and not a second AST.

### Reference acquisition and rollback transaction

After symbol remap reached 69/69, restore crashed while acquiring bytecode
references: the restored function body contained the pending parent's numeric
FunctionId, but `AddReferences()` still indexed the published Engine table.
The pending parent was intentionally absent from that table.

`asCScriptFunction::AddReferences()` and `ReleaseReferences()` now accept the
same transient restore context. Published functions still resolve through the
Engine table first; only a missing ID may resolve to one unique pending
function with the same Engine and exact reserved FunctionId.

Prepared body state records whether references were already acquired during
restore. Commit does not add them a second time. Rollback releases them through
the same transient context before destroying the detached body. This preserves
the transaction invariant:

```text
restore body -> acquire refs against published + pending graph
commit        -> publish shells, do not double-add
rollback      -> release refs against the same graph, destroy detached body
```

The focused rollback regression restores only `First()` from Cache while its
callee `Second()` remains a pending shell, then forces CodeGen failure before
`Second()` emits. Removing the new rollback release produced the exact RED
`rollback must release the restored First-to-pending-Second call reference`;
restoring the production release returned the test to GREEN and preserved all
original bodies, globals, slots, free IDs, publishers and digests.

## Problems, hypotheses and TDD evidence

### Core lifetime/provider gate

- initial TypedASTJIT protocol GREEN:
  `Saved/Tests/cta-s53-15-8-typedastjit-green/20260828_212325_998_449c9c74`
- Canonical lifetime group, **19/19 PASS**:
  `Saved/Tests/cta-s53-15-8-canonical-lifetime-green/20260828_215301_214_a6ba5fde`
- independent Engine/provider state, **3/3 PASS**:
  `Saved/Tests/cta-s53-15-8-independent-state-green/20260828_213420_795_5ed647a6`
- same source/generation/consumption pipeline, **1/1 PASS**:
  `Saved/Tests/cta-s53-15-8-same-pipeline-green/20260828_221221_423_bdf1f5e8`
- provider route gate:
  `Saved/Tests/cta-s53-15-8-provider-route-green/20260828_215337_931_5800ef30`
- provider boundary and diagnostic gates:
  `Saved/Tests/cta-s53-15-8-provider-boundaries/20260828_221316_084_0ff4a438`
  and
  `Saved/Tests/cta-s53-15-8-provider-diagnostics/20260828_212846_869_1c795a99`
- explicit host and independent provider routes:
  `Saved/Tests/cta-s53-15-8-cache-explicit-host-green/20260828_221829_694_1d24a8c6`
  and
  `Saved/Tests/cta-s53-15-8-cache-independent-provider-route/20260828_220611_588_2d6d377d`

### Fresh Cache root-cause chain

1. Prepared restore omission exposed `0/69`; the provider-domain diagnostic
   run is retained at
   `Saved/Tests/cta-s53-15-8-cache-provider-domain-green/20260828_222619_182_94ce697e`.
2. Calling the restore hook for prepared authored/generated shells reached
   `68/69`:
   `Saved/Tests/cta-s53-15-8-prepared-restore-green/20260828_224225_025_177ba7ec`.
3. Instrumented reader runs disproved the initial trailing-byte/table-count
   hypothesis. The artifact was structurally complete; the missing row was a
   same-module generated child-to-parent function dependency that could not be
   resolved from published tables.
4. The first transient-function patch failed to compile because the new
   restore-context type lacked one forward declaration:
   `Saved/Build/cta-s53-15-8-transient-function-restore-build/20260828_230754_182_55f8385b`.
   The corrected build passed:
   `Saved/Build/cta-s53-15-8-transient-function-restore-build-2/20260828_230833_034_3c5556be`.
5. Symbol resolution then exposed the `AddReferences()` crash rather than a
   serialization defect:
   `Saved/Tests/cta-s53-15-8-transient-function-restore-green/20260828_231058_318_93daee51`.
6. Transaction-aware reference acquisition/release produced the first complete
   **69/69** pass:
   `Saved/Tests/cta-s53-15-8-transient-reference-transaction-green/20260828_231749_228_00651ac9`.
7. The final diagnostic-clean rerun remained **1/1 PASS**, `Modules=3/3`,
   `RestoredFunctions=69/69`, `CompiledMisses=4`, `NotCacheable=4`:
   `Saved/Tests/cta-s53-15-8-final-fresh-cache-green/20260828_233551_442_bcfff180`.

All temporary reader/writer/cache diagnostic prints used to isolate this chain
were removed before the final build.

### Focused rollback RED -> GREEN

- baseline with the corrected implementation, **1/1 PASS**:
  `Saved/Tests/cta-s53-15-8-restore-rollback-regression-baseline/20260828_232631_863_cae1ef90`
- intentional RED after temporarily removing pending-reference release:
  `Saved/Tests/cta-s53-15-8-restore-rollback-regression-red/20260828_232735_019_f435adaa`
- production code restored, final **1/1 PASS**:
  `Saved/Tests/cta-s53-15-8-restore-rollback-regression-green/20260828_232831_058_13cc6bf6`
- green build containing the regression:
  `Saved/Build/cta-s53-15-8-restore-rollback-regression-green-build/20260828_232817_817_7153fc96`

## Final verification

All supported commands were run from `D:\as-cta`. Standalone was not built or
tested.

| Gate | Result | Evidence |
|---|---:|---|
| UE build | PASS | `Saved/Build/cta-s53-15-8-final/20260828_234058_323_e11407f2` |
| StaticJIT TypedASTJIT focused gate | **48/48 PASS** | `Saved/Tests/cta-s53-15-8-final-typedastjit-lifetime-green/20260828_233658_399_9af5fa08` |
| ProductionCodeGen | **121/121 PASS** | `Saved/Tests/cta-s53-15-8-final-production-codegen-green/20260828_233901_713_d9e57676` |
| Fresh Cache V2 Engine/provider route | **1/1 PASS, 69/69 restored** | `Saved/Tests/cta-s53-15-8-final-fresh-cache-green/20260828_233551_442_bcfff180` |
| build-artifact restore hook | **3/3 PASS** | `Saved/Tests/cta-s53-15-8-cache-restore-hook-green/20260828_232922_405_60921d56` |
| function candidate lookup | **2/2 PASS** | `Saved/Tests/cta-s53-15-8-cache-candidate-lookup-green/20260828_233033_724_1b1c67a6` |
| function artifact corruption | **1/1 PASS** | `Saved/Tests/cta-s53-15-8-cache-corruption-green/20260828_233213_483_2e27c9fb` |
| invocation-family artifact | **1/1 PASS** | `Saved/Tests/cta-s53-15-8-cache-invocation-artifact-green/20260828_233346_107_b99845af` |
| clean-capture invocation families | **1/1 PASS** | `Saved/Tests/cta-s53-15-8-cache-clean-capture-invocation-families-green/20260828_233500_304_2fbf361b` |
| plugin diff check | PASS | `git -C Plugins/Angelscript diff --check` (line-ending warnings only) |

`Angelscript.TestModule.Cache.InvocationFamilyParity` was not counted as
evidence. The source test is deliberately `Disabled #cache-v2-redesign`, so a
normal Automation run correctly reports no matching active test. The active
`InvocationFamilyArtifact` and `CleanCaptureInvocationFamilies` gates above
cover the maintained artifact/capture boundary; complete cross-Engine
invocation-family parity remains deferred with Cache V2 redesign.

The UE startup health probe intermittently timed out while contacting
`https://www.google.com/generate_204`. The affected tests still completed and
their report totals were PASS; this is a non-failing environment warning, not
an implementation result.

## Explicit non-claims and remaining work

1. **Tasks 15.9 and 15.10 remain open.** Base/member/delegating/complete-object
   committed prefixes and array/aggregate committed cursors are not provided
   by this gate. Their current TypedASTJIT behavior is an explicit typed
   per-function fallback.
2. **Task 15.11 remains open.** The final combined boundary/source scan,
   complete section regression gate and typed structural identity audit still
   need their own acceptance run.
3. The section 5/7/9/13 umbrellas remain open. This gate does not claim full
   constructors, globals/imports, exception/suspend parity, every SDK language
   fixture, Hot Reload, or whole-language/default cutover.
4. Cache V2 remains default-disabled. This task fixed the explicitly enabled
   prepared restore lifecycle exercised by focused tests; it does not promote
   Cache V2 to a product-ready default.
5. The product compiler default remains LEGACY. No production dual path or
   silent LEGACY fallback was added.
6. The native `asCScriptNode`, `asCBuilder`, `asCCompiler`, Parser/Builder and
   compiler tests remain intentionally available for LEGACY, syntax, recovery,
   reference, differential and rollback roles. This gate does not delete the
   original AngelScript AST.
7. TypedSemantic HIR production symbols remain absent and no HIR/dump transport
   was reintroduced.
8. Standalone was neither modified nor run. Its adaptation remains deferred to
   a separate future OpenSpec.

## Next gate

Task 15.9 must add constructor subobject committed-prefix semantics and parity.
Task 15.10 must add array/aggregate committed progress. Task 15.11 then runs
the complete CTA-S53 boundary and proves the final artifact/default/identity
invariants before any broader section 5/7/9/13 closure or default replacement
can be considered.
