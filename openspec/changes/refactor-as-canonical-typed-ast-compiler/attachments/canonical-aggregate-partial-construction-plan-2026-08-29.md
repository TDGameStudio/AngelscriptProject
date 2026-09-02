# CTA-S53 15.10: Canonical aggregate partial-construction gate

Date: 2026-08-29
Status: Complete — Task 15.10 accepted; Task 15.11 owns the decoded-Sidecar boundary gate
Scope: `refactor-as-canonical-typed-ast-compiler` Task 15.10 only
Explicitly deferred: Standalone adaptation and Standalone validation

## Required outcome

Canonical Sema must author one exact, snapshot-owned aggregate element cleanup
fact before either backend lowers an initializer-list/array aggregate. The
shared lifetime view must reconstruct a pointer-free aggregate plan and derive
the exact reverse cleanup sequence from a backend-owned committed element
count. A failed current element is never included. Nested aggregate progress is
independent: an inner aggregate cleans its own committed prefix, and the parent
cursor advances only after the complete inner value succeeds.

Task 15.10 is complete only when fresh evidence proves:

- zero, one and many committed elements;
- middle-element failure and strict reverse cleanup;
- committed-count overflow rejection;
- nested aggregate parent/child composition;
- deterministic view reconstruction and structural identity;
- Sema-authored exact element destructor/action facts;
- Canonical Bytecode maintains a backend-local committed count and never
  treats the full aggregate as live before all elements succeed;
- TypedASTJIT copies only stable pointer-free facts and produces a precise
  per-function fallback where native element-frame ABI is unavailable.

## Approved semantic shape

The existing lifetime record schema is sufficient and remains protocol
revision 1. One homogeneous array/list-pattern aggregate owns one record:

```text
subjectKind       = AGGREGATE_ELEMENT
subject           = aggregate Construct Expr
actionKind        = DESTROY_ELEMENT
actionTarget      = exact element Destructor Decl
activationPoint   = the same aggregate Construct Expr (progress identity)
semanticRegion    = exact owning Function/Method/Constructor Decl
phase             = AGGREGATE_ELEMENT
supportedExitMask = EXCEPTION
constructionStep  = 0
completeCommit    = false
```

The record does not persist a Runtime cursor, stack slot, address, pointer,
numeric TypeId, VM label, or native frame offset. The transient shared view
derives the ordered element commit expressions from the aggregate's already
typed children. A backend maps the aggregate expression identity to its own
counter/frame storage.

The derived aggregate plan contains only snapshot-local typed identities and
ordinals:

```text
aggregate expression
optional parent aggregate expression
semantic owner declaration
record index
exact element cleanup action/target
ordered element commit expressions
```

Given `committedCount`, the view produces actions for element ordinals
`committedCount-1 .. 0`. `committedCount == 0` produces no action and a count
larger than the authenticated element count fails closed.

## Why the record is aggregate-wide

AngelScript list-pattern arrays are homogeneous. One exact element destructor
is therefore the semantic cleanup action for every committed element while the
runtime count is dynamic. Persisting one record per runtime element would
duplicate facts, cannot represent a runtime-sized array, and would incorrectly
turn backend progress state into snapshot state. Nested homogeneous aggregates
compose by giving each aggregate expression its own record and derived plan.

Heterogeneous object base/member construction remains represented by the
constructor committed-prefix protocol completed in Task 15.9; this task does
not replace that model.

## Static audit findings

### I1 — enum vocabulary exists but is not legal yet

`as_ast_lifetime.h` already declares `AGGREGATE_ELEMENT`, `DESTROY_ELEMENT`
and the aggregate phase. `ValidateLifetimeRecord` still accepts only
constructor records or Decl-subject local/foreach records, so a genuine
aggregate record cannot authenticate and the shared view has no aggregate
plan API.

### I2 — Canonical list lowering publishes the full size too early

`asCBytecodeCodeGen::EmitListFactoryInto` writes the list count before all
elements have succeeded. This count cannot serve as a constructed-prefix
cursor. For non-trivial elements, the lowering must initialize progress to
zero and advance it only after each element commit.

### I3 — current raw writes are not ownership-correct for non-POD values

Canonical list lowering currently has direct 1/2/4/8-byte writes suitable for
the scalar cases covered today. Raw copying a non-trivial value object is not
an element construction or ownership transfer. Supporting such values needs
the Sema-authored constructor/assignment shape and exact cleanup protocol; any
shape not yet representable must fail closed rather than publish a partial
artifact.

### I4 — LEGACY exception cleanup uses an initialization heuristic

`asCScriptEngine::DestroySubList` contains an explicit TODO and guesses value
construction success by looking for any non-zero byte. A successfully
constructed all-zero value and a failed partially-written non-zero value both
invalidate that guess. Some repeated element destruction also runs in forward
order. Canonical must not inherit or re-express this heuristic.

### I5 — TypedASTJIT assumes lifetime subjects are declarations

The lifetime summary writer currently rejects a lifetime record whose subject
is an Expr. Aggregate identity must be hashed from stable typed expression
structure, not a pointer or snapshot-local numeric ID. The current generic
partial-construction fallback is constructor-specific and must distinguish a
missing native element-frame ABI.

### I6 — nested aggregate commit cannot share the parent cursor

If an inner element fails, the inner plan first destroys only its committed
children. The parent aggregate must not count the inner aggregate as committed
until the inner value completes. A single flattened cursor would either leak
inner elements or destroy an incomplete parent element.

### I7 — Task 15.10 had not yet justified a Sidecar schema bump

All required semantic facts fit the existing lifetime record fields and typed
AST child edges. Aggregate plans and cursor-specific cleanup lists are
transient reconstructions. At the Task 15.10 boundary this justified no schema
change yet, but it did not prove that Sidecar V6 actually encoded those
records. Task 15.11 subsequently added the required decoded-snapshot RED and
proved V6 erased the entire Sema-authored lifetime protocol; Sidecar V7 is the
minimal accepted repair. The evidence and rationale are recorded in
`attachments/canonical-lifetime-boundary-regression-gate-2026-08-29.md`.

### I8 — the first verifier draft incorrectly required a value-object container

The source-path RED used a production-shaped implicit-handle reference object
as the list-factory return container and non-trivial value objects as its
elements. Sema authored the exact element progress record, but the first GREEN
attempt failed during `SealCanonicalAST`: the shared verifier reused its
element-only `ValueTypeMatchesClass` predicate for the aggregate container.
That assumption was wrong. AngelScript list factories commonly return
reference/implicit-handle containers; only the repeated element needs the
exact value-object destructor in this 15.10 slice.

The verifier now authenticates the aggregate's named value/reference type
against the exact list-factory owner while retaining the stricter non-reference
value-object check for every element and its destructor. No handle/pointer is
persisted by this correction.

### I9 — Canonical list buffers are not tracked by exception stack cleanup

The current Canonical list lowering allocates the list buffer through a
pointer-variable slot and publishes the slot only in `pointerVariablePos`.
It does not add the allocation to the function's heap-object cleanup table
(`objVariablePos` / `objVariableTypes`). Consequently `CleanStackFrame`
cannot see or free that list-pattern allocation when element evaluation or
the list factory raises an exception. Combined with I2, the current path can
both claim the complete element count before construction succeeds and omit
the allocation from exception unwinding.

The Canonical fix must transactionally register the relocated list-pattern
helper and buffer slot as an exception-owned heap object, initialize its
committed count to zero, and let exact aggregate cleanup metadata destroy only
the committed prefix in reverse before freeing the buffer. This is a
Canonical backend correction; the preserved LEGACY `DestroySubList`
heuristic is not the implementation target for Task 15.10.

### I10 — CQTest exact selectors include the generated test-class segment

The first Bytecode RED command targeted the declared test directory followed
directly by the method name. CQTest's production registration path inserts the
generated runner/class name between them, so both the new fixture and a known
adjacent control method produced `No automation tests matched` even though the
source had been rebuilt into `UnrealEditor-AngelscriptTest.dll`.

Historical exported reports and a control comparison established the actual
shape:

```text
<declared test directory>.
FCanonicalASTProductionCodeGenTests.
<method name>
```

The corrected selector found exactly one test and produced the required
semantic RED. The two no-match runs remain infrastructure evidence only and
must never be counted as a behavioral test result.

### I11 — list-pattern relocation did not previously name its owning function

The first Bytecode GREEN build added a second relocation responsibility:
besides patching the `FREE` operand with the anonymous list-pattern helper, the
same validated relocation now patches the buffer's unresolved heap-object
directory entry. The existing loop addressed the relocation function only
through an inline array expression, so the initial implementation referred to
an undeclared `function` while updating that directory.

This was a compile-time integration error rather than a semantic result. The
loop now binds the already-validated relocation function to one explicit local
and uses that same function for the bytecode coordinate and cleanup-directory
coordinate. The failed build remains evidence that no stale DLL was tested;
it is not counted as either the required semantic RED or a GREEN.

### I12 — TypedASTJIT lifetime admission assumed every subject was a Decl

The pre-15.10 TypedASTJIT lifetime adapter authenticated a lifetime record by
resolving its subject through the declaration table. An aggregate lifetime is
owned by the exact list expression, so the correct subject is an Expr. The
generic declaration-only assumption consequently classified a valid sealed
aggregate plan as `Unverified`/`InvalidCleanupPlan`.

TypedASTJIT now consumes the already-authenticated shared lifetime view and
admits the aggregate Expr subject without reclassifying it as a declaration.
The backend copies only stable, pointer-free plan shape. It retains no Context,
Expr, lifetime-record or shared-view pointer after analysis.

### I13 — Typed lifetime identity omitted the aggregate plan shape

The lifetime StableKey/ABIKey originally covered ordinary and constructor
cleanup actions but not aggregate element count, committed-cursor shape or the
nested-parent relationship. A two-element and three-element aggregate could
therefore alias, and two nested aggregates with different parent ordinals
could produce the same typed identity.

The stable summary now includes the authenticated aggregate plan count, maximum
element count, action identity and nested parent ordinal. Tests prove that
changing element count or parent ordinal changes both stable identity and the
precise fallback summary. Snapshot-local Expr/Decl IDs are not copied into the
provider record.

### I14 — the first nested fixture persisted a dynamic cursor value as structure

The initial nested fixture wrote a runtime committed count into
`constructionStep`. The verifier correctly rejected this because
`constructionStep` is structural ordering, while the committed count is a
dynamic execution value reconstructed against that ordering.

The fixture and implementation now keep these domains separate: lifetime
records carry deterministic element ordinals, while Bytecode owns the mutable
committed cursor. No runtime cursor is persisted into the AST snapshot.

### I15 — `AddLifetimeRecord` returns status, not the inserted record index

One test attempted to use the successful return value from
`AddLifetimeRecord()` as a record index when constructing a nested relation.
The API returns an `asAST_VERIFY_*` status. The fixture now obtains the stable
ordinal from the Context record count after successful insertion. Production
code was not weakened and the API contract remains unchanged.

### I16 — SaveByteCode conflated structural repeat count with runtime progress

The original `SListAdjuster` expected list offsets to advance monotonically and
treated every `SetListSize` as structural list-pattern control. Canonical
aggregate Bytecode deliberately emits `0..N` committed progress during
construction and `N-1..0` retirement during cleanup, so SaveByteCode entered
the list-pattern stack with runtime cursor writes and crashed in
`SListAdjuster::AdjustOffset`.

Writer and reader adjustment now receive the authenticated aggregate repeat
count and cursor presence explicitly. They replay the same encoded/runtime
offset mapping for the reverse cleanup sequence instead of interpreting the
cursor as a new structural repeat. Ordinary LEGACY list encoding retains its
existing path.

### I17 — aggregate cleanup metadata was absent from both restore protocols

`asCScriptFunction::ScriptFunctionData::aggregateCleanupInfo` is required by VM
exception unwinding, but the first implementation neither wrote nor restored
it. A saved function therefore lost the exact element type, cleanup action,
buffer coordinate and maximum element count even though its bytecode survived.

Full module stream version 3 and detached Function Artifact V6 now use a
previously unused function-state presence bit and encode only semantic type,
action and count facts. Physical cursor/element coordinates are authenticated
and reconstructed from decoded bytecode. No raw pointer or numeric TypeId is
serialized, and no schema-version bump is required for this slice.

### I18 — restore recognized synthetic `$list` but not registered `$beh4`

The restored aggregate action dependency named the real registered list
factory behavior (`$beh4`). The module reader's special behavior lookup only
recognized the synthetic `$list` spelling, so `LoadByteCode` failed while
resolving an otherwise valid used function.

Restore now recognizes the registered list-factory behavior by its semantic
behavior role rather than requiring the synthetic spelling. This is a lookup
compatibility correction; it does not persist or compare a runtime function
pointer.

### I19 — `AllocMem` translation ran before legacy object metadata rebuild

The reader translated aggregate `AllocMem` before
`objVariablePos/objVariableTypes` had been rebuilt. Canonical aggregate buffers
also do not have the legacy `OBJTYPE/ALLOC` operand pattern used by the old
lookup, so the list-pattern type was unavailable at the translation point.

The reader now reconstructs the aggregate buffer type from the authenticated
matching `FREE` type use and verifies the buffer coordinate before translating
`AllocMem`. This is generation-local rebinding; durable identity remains the
semantic type reference carried by the stream/artifact.

### I20 — restored VM heap metadata omitted the aggregate buffer

After I19, bytecode translation succeeded but `Unprepare()` crashed in
`asCContext::DetermineLiveObjects()`: restored `objVariableInfo` contained the
aggregate `asOBJ_INIT`, while the rebuilt `objVariablePos/objVariableTypes`
directory omitted its buffer and `liveObjects` was empty.

`RebuildLegacyObjectVariableMetadata()` now admits a matching `FREE` operand
as one owning heap object only when an authenticated aggregate cleanup record
names the same buffer and the resolved type is an `asOBJ_LIST_PATTERN`. The
restored function consequently has exactly one typed heap entry before VM
liveness analysis and unwinds only its committed prefix.

### I21 — malformed aggregate metadata could reach an invalid writer stack

A forged artifact changed `maxElementCount` from three to two while retaining
three encoded elements. Before hardening, `WriteFunctionArtifact()` trusted the
metadata long enough for `SListAdjuster` to pop an empty pattern stack and
crash.

Writer preflight now authenticates the complete executable shape before list
adjustment or artifact publication: exactly one `AllocMem`, one matching
`FREE`, one stable cursor coordinate, commit sequence `0..N`, retire sequence
`N-1..0`, exact `SetListSize`/`PshListElmnt` counts, forward construction
offsets, reverse cleanup offsets and valid instruction bounds. The forged
candidate now returns an error and leaves no published artifact.

## AST-first gate card

Owning test source:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp`

Implemented methods:

- `BuildsDeterministicAggregateCommittedPrefixPlan`
- `RejectsForgedAggregateSubjectActionOwnerAndProgress`

The first production mutation that each test protects is:

- deleting/flattening the aggregate plan or advancing cleanup past the
  authenticated committed count;
- accepting a wrong aggregate subject, non-list-factory target, mismatched
  element destructor, foreign semantic owner, invalid exit mask, or cyclic
  nested aggregate relation.

### TDD evidence ledger

| Stage | Evidence | Result |
|---|---|---|
| Shared view API RED | `Saved/Build/cta-s53-15-10-shared-view-red-build/20260829_042207_101_7f9de509` | Expected compile failure on missing `asSASTLifetimeAggregatePlan`, `GetAggregatePlanCount` and `DeriveAggregateAbortCleanup`. The earlier `Saved/Tests/cta-s53-15-10-shared-view-red/20260829_042127_887_84ef0ae1` no-match run used the old DLL and is infrastructure evidence only, not a semantic RED. |
| Shared view nested-plan RED | `Saved/Tests/cta-s53-15-10-nested-progress-red/20260829_043905_885_4697afe0` | **0/1**, expected assertion failure because a nested list-factory aggregate without an independent committed-prefix plan was accepted. |
| Shared view GREEN | Build: `Saved/Build/cta-s53-15-10-shared-view-matrix-build/20260829_044313_262_956860b9`; test: `Saved/Tests/cta-s53-15-10-shared-view-matrix-green/20260829_044330_686_7a4b84be` | **45/45 PASS**, zero failures/skips. Covers deterministic reconstruction, zero/one/many committed elements, middle failure, overflow rejection, strict reverse cleanup, nested parent/child plans, missing nested plan rejection, and forged subject/action/owner/list-factory/exit/step/action-kind rejection. |
| Sema source-path RED | Build: `Saved/Build/cta-s53-15-10-sema-source-red3-build/20260829_045338_759_074b9a9c`; test: `Saved/Tests/cta-s53-15-10-sema-source-red3/20260829_045401_108_2f784db5` | **0/1**, expected failure after a sealed pre-Bytecode source build proved the exact list-pattern, three typed value elements, native destructor and `Entry` owner existed while the aggregate lifetime record alone was absent. Earlier compile/no-match and unresolved-constructor attempts are fixture/infrastructure evidence only. |
| Sema verifier-shape finding | Build: `Saved/Build/cta-s53-15-10-sema-source-green-build/20260829_045557_073_45fa2054`; test: `Saved/Tests/cta-s53-15-10-sema-source-green/20260829_045609_417_95458c42` | **0/1**, useful secondary RED: Sema authored the record, then seal rejected a valid implicit-handle list container because the verifier incorrectly required a value-object container. Recorded as I8. |
| Sema source-path GREEN | Build: `Saved/Build/cta-s53-15-10-sema-source-green2-build/20260829_045711_244_ccf5c99f`; test: `Saved/Tests/cta-s53-15-10-sema-source-green2/20260829_045724_109_80bbed9f` | **1/1 PASS**. Before Bytecode, Canonical Sema seals one aggregate-wide record with the exact Expr subject/activation, native element destructor Decl, function owner, exception-only phase and three ordered element commits; the shared view reconstructs the same plan. |
| Sema focused regressions | Trivial list: `Saved/Tests/cta-s53-15-10-sema-trivial-list-regression/20260829_045827_687_86f99df7`; verifier class: `Saved/Tests/cta-s53-15-10-sema-verifier-regression/20260829_045909_564_38ad7ec2` | Existing scalar list remains **1/1 PASS** without a spurious element cleanup requirement; complete verifier matrix remains **45/45 PASS**, zero failures/skips after accepting a reference-object list container. |
| Canonical Bytecode fixture build | `Saved/Build/cta-s53-15-10-bytecode-cursor-red-build/20260829_051252_293_30d8be8e`; discovery run: `Saved/Tests/cta-s53-15-10-bytecode-cursor-red/20260829_051318_200_2f040061` | Build **PASS**. The first discovery run did not execute the fixture because its exact Automation selector matched no registered test; this is test-infrastructure evidence only and is not counted as the required semantic RED. Production Bytecode remains unchanged at this point. |
| Canonical Bytecode selector control | `Saved/Tests/cta-s53-15-10-discovery-control/20260829_051838_702_f104a7e9` | A known adjacent method also produced no match when the selector omitted `FCanonicalASTProductionCodeGenTests`, proving the issue was path construction rather than the new method's registration. Recorded as I10. |
| Canonical Bytecode semantic RED | `Saved/Tests/cta-s53-15-10-bytecode-cursor-semantic-red/20260829_051921_488_1d736775` | **0/1**, expected assertion failure. The real published bytecode contains only the final list size `3`; it does not publish committed progress `0,1,2,3`. Production Bytecode was still unchanged. |
| Canonical Bytecode first GREEN build integration | `Saved/Build/cta-s53-15-10-bytecode-green-build/20260829_053455_831_d318dcdd` | Expected implementation-stage compile failure: the extended list-pattern relocation path had not yet named its owning function before patching the exception directory. Recorded as I11 and corrected before any GREEN test execution. |
| Canonical Bytecode GREEN | Build: `Saved/Build/cta-s53-15-10-bytecode-green2-build/20260829_053731_358_675406d0`; behavior: `Saved/Tests/cta-s53-15-10-bytecode-green/20260829_053752_587_2c555206`; list regressions: `Saved/Tests/cta-s53-15-10-bytecode-list-regressions/20260829_053839_720_2ec3df51`; Sema/verifier: `Saved/Tests/cta-s53-15-10-bytecode-sema-verifier-regression/20260829_053927_626_45ad8062` | Build **PASS**; aggregate behavior **1/1 PASS**; adjacent list regressions **2/2 PASS**; Sema/verifier **46/46 PASS**. The VM buffer starts at zero, advances after each successful element, retires in reverse and participates in the ordinary heap cleanup directory. |
| Canonical Bytecode zero-element GREEN | Build: `Saved/Build/cta-s53-15-10-bytecode-zero-build/20260829_055106_744_528033dc`; test: `Saved/Tests/cta-s53-15-10-bytecode-zero-green/20260829_055122_716_d15721b3` | **1/1 PASS**. Zero repeated elements publish a zero cursor and do not invoke the element destructor. |
| TypedASTJIT aggregate RED/GREEN | RED: `Saved/Tests/cta-s53-15-10-aot-aggregate-red/20260829_054835_599_8398cfd6`; GREEN: build `Saved/Build/cta-s53-15-10-aot-aggregate-green-build/20260829_054952_534_0ea07a08`, test `Saved/Tests/cta-s53-15-10-aot-aggregate-green/20260829_055006_607_82ce4d51` | RED proved the declaration-only subject assumption. GREEN is **1/1 PASS**: a verified pointer-free aggregate summary is published and the missing native element-frame ABI yields exact `UnsupportedLifetime` fallback. |
| TypedASTJIT cursor identity RED/GREEN | RED: `Saved/Tests/cta-s53-15-10-aot-cursor-identity-red/20260829_055357_275_cd096497`; GREEN: `Saved/Tests/cta-s53-15-10-aot-cursor-identity-green2/20260829_055928_937_17667283` | RED proved two/three-element plans aliased. GREEN is **1/1 PASS**: count/progress shape changes StableKey and ABIKey without copying snapshot-local IDs. |
| TypedASTJIT nested identity GREEN | Build: `Saved/Build/cta-s53-15-10-aot-nested-green3-build/20260829_060356_175_685412f0`; test: `Saved/Tests/cta-s53-15-10-aot-nested-green3/20260829_060414_848_e4b332b0` | **1/1 PASS**. Child and parent plans remain independently authenticated; the parent ordinal participates in typed identity and fallback. |
| Full-module restore diagnostic chain | Save crash: `Saved/Tests/cta-s53-15-10-bytecode-restore-red/20260829_061122_465_fdc2d750`; unresolved behavior: `Saved/Tests/cta-s53-15-10-bytecode-restore-stage5/20260829_063255_842_ff09a897`; `AllocMem` ordering: `Saved/Tests/cta-s53-15-10-bytecode-restore-translate-stage/20260829_063603_634_40e5f19a`; missing heap directory: `Saved/Tests/cta-s53-15-10-bytecode-restore-heapdir-red2/20260829_064423_441_706cc085` | Expected RED sequence that isolated I16–I20. The intermediate no-match command `cta-s53-15-10-bytecode-restore-heapdir-red` was a selector typo and is not semantic evidence. |
| Full-module restore GREEN | Build: `Saved/Build/cta-s53-15-10-bytecode-restore-heapdir-green-build/20260829_064518_495_314a6564`; test: `Saved/Tests/cta-s53-15-10-bytecode-restore-heapdir-green/20260829_064532_279_42581b99` | **1/1 PASS**. Version-3 module restore rebuilds one typed heap entry and executes middle-element/factory failures with exact committed-prefix reverse cleanup. |
| Detached Function Artifact V6 and malformed-input gate | RED/crash run: `Saved/Tests/cta-s53-15-10-aggregate-artifact-red/20260829_064814_380_806306d2`; GREEN build: `Saved/Build/cta-s53-15-10-aggregate-artifact-green-build/20260829_065003_980_6d42d8af`; GREEN test: `Saved/Tests/cta-s53-15-10-aggregate-artifact-green/20260829_065020_502_687e4ff4` | RED exposed I21 in `SListAdjuster::AdjustOffset`; its transient crash snapshot was observed at `82876_20260829_064841_914` but was later cleaned from `Saved`, so the retained RED run and call stack are the durable evidence. GREEN is **1/1 PASS**: V6 roundtrip restores and executes the aggregate, while forged count/bytecode disagreement fails before publication without crashing. |
| Restore/transaction regression gate | `Saved/Tests/cta-s53-15-10-aggregate-runtime-regression/20260829_065234_084_5347f602` | **150/150 PASS**, zero failures/skips. Covers ProductionCodeGen, RestorePrimitives and Canonical CodeGen.Transaction, including commit/abandon rollback and anonymous list-pattern ownership. |
| Task 15.10 complete four-prefix gate | `Saved/Tests/cta-s53-15-10-full-gate/20260829_065734_072_ceed217a` | **752/752 PASS**, zero failures/skips. This is the complete Frontend CanonicalAST, SemaAuthority, ProductionCodeGen and StaticJIT TypedASTJIT surface after the final restore/writer hardening, not a focused-method substitute. |

## Nonclaims

- This task does not remove the native Parser AST, `asCBuilder` or
  `asCCompiler`; they remain for explicit LEGACY, syntax/recovery, reference,
  differential testing and rollback.
- HIR remains physically absent and is not recreated as an aggregate adapter.
- Product default remains LEGACY until the section 10 cutover gate.
- This task does not perform Standalone adaptation or Standalone validation.
- This task does not claim every container/template/value form is already
  executable through Canonical Bytecode; unsupported non-trivial shapes must
  remain explicit fail-closed cases until their exact lowering exists.
