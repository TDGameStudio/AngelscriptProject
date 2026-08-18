# Tasks 0–3 completion audit

## Purpose

This attachment is the evidence-first reconciliation of the unchecked early
compiler tasks against the current worktree on 2026-08-16. An unchecked box is
not treated as stale bookkeeping merely because later AOT tests are green.
Each task remains open unless its exact compiler/source/persistence boundary
has direct executable evidence.

## Closed by subsequent implementation

### 2.1 and 2.2 — expression capture and `asCExprContext` propagation

These tasks closed on 2026-08-16. Production evidence includes:

- invalid-by-default `asCExprContext::typedSemanticExpression`;
- a provisional `asCTypedSemanticIRBuilder` created during compiler reset and
  ordinary/global function compilation;
- final-type capture for scalar symbols, literals, binary/unary expressions,
  conversions, short-circuit values, resolved calls and mutation plans;
- exact RHS-before-LHS mutation ordering, one target expression, one store,
  and distinct prefix/postfix result semantics;
- reverse formal evaluation for the current three-argument ordinary call
  fixture;
- copy/merge/clear identity coverage and capture-on/off bytecode/VM equality
  for the currently captured fixtures;
- bounded capability files beneath `Compiler/TypedSemanticIR/` for scalar
  leaves/operators and context/conversion/call propagation instead of further
  growth of the legacy compiler HIR translation unit;
- direct cases for primitive/enum literals, parameter/local symbols, every
  requested primitive operator family, explicit and implicit conversions,
  converted return/call-argument/local-initializer shapes, void/value call
  discard, call initializer, and compiler-selected power conversions;
- maintained assignment/increment/eager-order coverage for one-evaluation
  mutation semantics and the maintained Power suite for its full conversion,
  rejection, recovery, and runtime oracle.

The final RED showed that local declarations captured their RHS before the
target-type conversion. Central scalar conversion capture fixed returns,
arguments, mixed operators, and power, while `CompileInitialization` now lets
the real `DoAssignment` path update only the current function arena's
initializer identity after final typing and before rvalue consumption. The
original member-level initial identity is retained for no-conversion binary,
call, and short-circuit paths. `AddLocalDeclaration` now reports the local
name, expression ID, arena size, and processed source position immediately if
that ownership invariant is violated.

Final focused evidence:

- `Saved/Build/typed-semantic-member-capture-green/20260816_190041_388_41618bdf/`
  — Editor build PASS;
- `Saved/Tests/typed-semantic-member-capture-exact/20260816_190058_216_f949aeeb/`
  — conversion plus ordinary/short-circuit initializer regression `3/3 PASS`;
- `Saved/Tests/typed-semantic-member-capture-group/20260816_190136_498_3c67afc6/`
  — complete bounded compiler HIR prefix `25/25 PASS`;
- `Saved/Tests/typed-semantic-power-regression/20260816_190223_465_77bdf504/`
  — maintained Power oracle `3/3 PASS`.

Adaptive non-unity compilation also exposed three pre-existing Conformance
translation units that relied on a sibling unity include for native case test
support. They now include that support header directly; this is a build
hermeticity fix, not AST JIT behavior.

## Already implemented but not yet sufficient to close the parent task

### 2.5 — typed unsupported markers

The model enumerates `Ternary`, `ObjectAccess`, `PropertyAccess`, `Reference`,
`Handle`, `Container`, `ConstructionOrLifetime`, `Lambda`,
`ExceptionCleanup`, `SuspendPoint`, and `CompilerSynthesizedFunction`.
Current compiler emission and executable tests directly cover only:

- ternary with three ordered operands and processed span;
- reference and handle type markers preserving the exact source symbol/type;
- verifier rejection for malformed marker shapes.

Object/property receiver identity, container, construction/lifetime, lambda,
suspend and dormant exception-region compiler emission remain real gaps. The
current try/catch/rethrow rejection is documented by research probes but still
needs capture-on/off executable coverage before this task closes.

The next bounded implementation slice keeps this matrix in a dedicated
`Compiler/TypedSemanticIR/AngelscriptNativeTypedSemanticIRUnsupportedTests.cpp`
translation unit. Its first RED case is direct object-property access: both
capture-off and capture-on builds must retain valid bytecode and identical VM
behavior, while the capture-on HIR must contain one `PropertyAccess` fallback
node whose operand is the already-captured receiver and whose immutable data
retains the resolved property name, final compiler type, and processed source
span. Later container/lifetime/lambda/suspend/exception cases extend this same
capability-owned file; publication-transaction and compiler-synthesized cases
remain separate translation units because they exercise different lifetime
and failure boundaries.

Fixture note: this maintained fork uses implicit script-object handles and
rejects the upstream-style explicit `Type@ Name` spelling. Executable object
fixtures must explicitly construct with `Type Name = Type();`; `Type Name;`
retains a null object and would turn a semantic-capture test into an unrelated
null-reference runtime failure.

Slice-1 result: direct `Receiver.Property` capture is now implemented. The
marker owns the earlier receiver expression, exact final result type,
processed span, and pointer-free `ReceiverType::PropertyName` detail. The
RED/green sequence is recorded in `implementation-progress.md`; the full 2.5
box remains open for the other categories listed above.

### 2.5 continuation — container, lifetime and future-language boundaries

The generic unsupported test translation unit was not allowed to become a
second monolith. Its two independent scenarios now live in
`AngelscriptNativeTypedSemanticIRUnsupportedContainerTests.cpp` and
`AngelscriptNativeTypedSemanticIRUnsupportedPropertyTests.cpp`; construction
and cleanup use `AngelscriptNativeTypedSemanticIRUnsupportedLifetimeTests.cpp`,
while syntax that is not currently accepted by the maintained fork uses
`AngelscriptNativeTypedSemanticIRUnsupportedLanguageBoundaryTests.cpp`.

Implemented compiler behavior now additionally covers:

- a container parameter emits both the existing `Reference` marker and an
  independent `Container` marker bound to the exact parameter symbol/type and
  processed span;
- valid managed construction emits `ConstructionOrLifetime`, and final
  compiler ownership inspection emits `ExceptionCleanup` with
  `cleanupPlanState=Unverified` and `hasExceptionCleanup=true` rather than
  fabricating a complete cleanup plan;
- capture on/off both preserve the current rejection of the future lambda
  spelling, `try`/`catch`, incomplete handler syntax and bare rethrow; failed
  sources publish no `Entry` and leave no retained module.

The lambda investigation is intentionally recorded as a boundary rather than
mislabelled RED evidence. Script-level `funcdef` is rejected, the maintained
token table disables explicit `@`, a registered funcdef cannot be instantiated
as a local or passed by value, and a system `const &in` parameter does not
trigger `ImplicitConvLambdaToFunc`. The compiler retains that conversion path
for a future/host-provided entry, but the raw SDK surface currently has no
valid source fixture that reaches it. A future full-Engine delegate fixture or
compiler-synthesized disposition may close this row; production language
rules were not changed merely to manufacture a marker.

Focused evidence:

- `Saved/Tests/typed-semantic-unsupported-container-red-valid-fixture/
  20260816_193213_605_f476704f/` — valid container RED `0/1` at the missing
  independent marker;
- `Saved/Tests/typed-semantic-unsupported-container-green-exact/
  20260816_193340_268_e387c385/` — container GREEN `1/1 PASS`;
- `Saved/Tests/typed-semantic-unsupported-lifetime-red-exact/
  20260816_193641_077_1561f94d/` — lifetime RED `0/1` at the unowned
  construction initializer;
- `Saved/Build/typed-semantic-unsupported-lifetime-green-02/
  20260816_194010_893_ce6f35c2/` and
  `Saved/Tests/typed-semantic-unsupported-lifetime-green-02-exact/
  20260816_194025_651_3ae903ba/` — build PASS and lifetime `1/1 PASS`;
- `Saved/Tests/typed-semantic-language-boundary-green-exact/
  20260816_195643_640_631dc928/` — capture-on/off future-language boundary
  `1/1 PASS` across five syntax families;
- `Saved/Build/typed-semantic-test-partition-container-property/
  20260816_195958_614_9b8e9a0f/` — UBT rediscovered and independently
  compiled the split translation units;
- `Saved/Tests/typed-semantic-test-partition-group/
  20260816_200019_388_815906bb/` — complete bounded prefix `29/29 PASS`.

Implicit object/member access is now closed by the dedicated
`AngelscriptNativeTypedSemanticIRUnsupportedImplicitMemberTests.cpp` owner.
The valid method fixture uses both unqualified `Value` and explicit
`this.Value`; capture-off/on preserve bytecode shape and VM result, while each
capture-on path records the same function-owned receiver symbol followed by a
pointer-free `ObjectAccess` marker and a `PropertyAccess` marker retaining the
resolved target/type/span. Removing either receiver hook leaves ordinary VM
execution valid but prevents HIR publication, so this is behavioral coverage
rather than a source-text detector.

- `Saved/Tests/typed-semantic-implicit-member-red-valid/
  20260816_201100_933_57a92da2/` — valid RED `0/1`, failing only because the
  capture-on method had no inspectable HIR;
- `Saved/Build/typed-semantic-implicit-member-green/
  20260816_201413_727_d4816e3e/` — production/test build PASS;
- `Saved/Tests/typed-semantic-implicit-member-green-exact/
  20260816_201434_191_cee391f1/` — exact receiver graph `1/1 PASS`;
- `Saved/Tests/typed-semantic-implicit-member-green-group/
  20260816_201513_804_07887686/` — complete bounded prefix `30/30 PASS`.

The reachable maintained-fork `__generated` function suffix now closes the
compiler/preprocessor-generated trait slice. Capture-on publishes one verified
HIR with the original `asTRAIT_GENERATED_FUNCTION` bit and exactly one
pointer-free `Unsupported/CompilerSynthesizedFunction` marker; capture-off/on
retain byte-for-byte equal bytecode and identical VM result. The verifier
requires the generated trait, `void` marker type, no executable payload and
the stable `__generated` disposition token.

- `Saved/Tests/typed-semantic-synthesized-red/
  20260816_202142_156_d1697d3d/` — valid RED `0/1`, failing only because the
  complete HIR lacked the deterministic synthesized-function marker;
- `Saved/Build/typed-semantic-synthesized-green/
  20260816_202237_297_55b8db73/` — production/test build PASS;
- `Saved/Tests/typed-semantic-synthesized-green-exact/
  20260816_202251_976_659817a6/` — exact generated-trait contract `1/1 PASS`;
- `Saved/Tests/typed-semantic-synthesized-green-group/
  20260816_202329_972_471d56fc/` — complete bounded prefix `31/31 PASS`.

Task 2.5 is now closed with a fail-honest maintained-fork boundary. The local
`Reference/angelscript-v2.38.0` comparison confirms that 2.38 implements
cooperative `Suspend()` by setting context request/register flags and consumes
them at `asBC_SUSPEND`, while the maintained fork's public `Suspend()` remains
an `asERROR` stub. The same bytecode opcode still exists here for line callbacks
and loop timeout polling, so treating every opcode as resumable state would
incorrectly make every ordinary loop ineligible. The dedicated
`AngelscriptNativeTypedSemanticIRSuspendBoundaryTests.cpp` case proves a real
loop has `asBC_SUSPEND` and `LoopBackedge`, bytecode/runtime parity, no
`hasSuspendState`, no fabricated `SuspendPoint`, and `Suspend()==asERROR`.

Compiler-internal exception regions are now consumed after normal bytecode
finalization. A non-empty `tryCatchInfo` sets
`cleanupPlanState=CompilerExceptionRegion`, `hasExceptionCleanup=true`, an
explicit non-universal plan and one pointer-free
`ExceptionCleanup/compiler-exception-region` marker. The verifier rejects a
region header without that marker or a mismatched marker shape. A unit-test-only
post-finalization metadata seam exercises the real production consumer without
adding tokenizer/parser support for `try`/`catch`; capture-off/on bytecode and
VM results remain identical. Existing dedicated lambda and language-boundary
owners continue proving that rejected 2.38-style syntax is not advertised as a
current source feature.

Focused evidence:

- valid RED: `Saved/Tests/typed-semantic-exception-region-red-exact/
  20260816_215636_300_670d1a8b/` — `0/1`, actual cleanup state remained
  `VerifiedEmpty` instead of `CompilerExceptionRegion`;
- exception-region build: `Saved/Build/typed-semantic-exception-region-green/
  20260816_215854_802_0b3e48ac/` — PASS;
- exception-region exact GREEN:
  `Saved/Tests/typed-semantic-exception-region-green-exact/
  20260816_215914_883_bc49e4d8/` — `1/1 PASS`;
- suspend-boundary build: `Saved/Build/typed-semantic-suspend-boundary/
  20260816_220100_331_b08e46f3/` — PASS;
- suspend-boundary exact:
  `Saved/Tests/typed-semantic-suspend-boundary-exact/
  20260816_220120_546_74616436/` — `1/1 PASS`;
- complete bounded regression:
  `Saved/Tests/typed-semantic-task25-green-group/
  20260816_220157_931_7fbf7256/` — `39/39 PASS`, zero failed/skipped.

The compiler-owned lifecycle functions now close three more rows of task 2.9.
`CompileDefaultConstructor`, `CompileDefaultDestructor` and `CompileFactory`
do not run the source-body HIR builder, so capture-on records stable
`default-constructor`, `default-destructor` and `factory` no-HIR dispositions
instead of exposing an unexplained empty sidecar. A nested script-class fixture
forces all three bytecode producers, verifies non-empty bytecode, and executes
the same owned-child construction/destruction path with capture off/on.

The explicit `__generated` test and automatic lifecycle test were separated
into independent capability owners before the former file crossed the
partition review threshold; the lifecycle case still uses one pair of Engines
for all three generated functions.

- `Saved/Tests/typed-semantic-synthesized-lifecycle-red/
  20260816_202654_360_d187e1ea/` — initial constructor/factory RED `0/1`,
  missing only their stable capture diagnostics;
- `Saved/Build/typed-semantic-synthesized-lifecycle-green/
  20260816_202752_680_8d7c0815/` and
  `Saved/Tests/typed-semantic-synthesized-lifecycle-green-exact/
  20260816_202807_074_da262368/` — constructor/factory build PASS and exact
  `1/1 PASS`;
- `Saved/Tests/typed-semantic-synthesized-destructor-red/
  20260816_203111_451_4d67f1e6/` — generated default-destructor RED `0/1`,
  while constructor/factory and real lifecycle execution already passed;
- `Saved/Build/typed-semantic-synthesized-destructor-green/
  20260816_203155_616_2d3be778/` and
  `Saved/Tests/typed-semantic-synthesized-destructor-green-exact/
  20260816_203209_945_ea8012a1/` — destructor build PASS and exact `1/1 PASS`;
- `Saved/Tests/typed-semantic-synthesized-lifecycle-green-group/
  20260816_203247_178_c5d5b63b/` — split bounded prefix `32/32 PASS`.

The generated `__InitDefaults` method is a separate reachable artifact row.
Its compiler entry went through ordinary `CompileFunction` capture without a
normal statement block, so otherwise valid default statements collapsed to
the generic `semantic capture encountered an unrepresentable compiler state`
diagnostic. A dedicated capability test compiles `default Value = 37` with
capture off/on, proves byte-for-byte equal `__InitDefaults` bytecode, manually
executes the generated instance method and observes the property change from 5
to 37 in both Engines. Production now records the stable capture-only
`init-defaults` no-HIR disposition and skips the builder that cannot own this
generated statement sequence.

- `Saved/Tests/typed-semantic-init-defaults-red/
  20260816_204737_654_c8632be5/` — valid RED `0/1`; compilation, bytecode and
  execution passed and only the generic diagnostic mismatched;
- `Saved/Build/typed-semantic-init-defaults-green/
  20260816_204831_895_daa46706/` — production/test build PASS;
- `Saved/Tests/typed-semantic-init-defaults-green-exact/
  20260816_204844_789_6e0a323f/` — exact contract `1/1 PASS`;
- `Saved/Tests/typed-semantic-init-defaults-green-group/
  20260816_204922_192_dede22ec/` — complete bounded prefix `33/33 PASS`.

Accessor and lambda were then separated from the general language-boundary
owner. This is an honest boundary characterization rather than fabricated HIR:
virtual-property accessor syntax is explicitly removed by the maintained
parser, while the internal lambda artifact path is not reachable through the
current public script source surface. Capture off/on therefore proves the same
compile rejection and zero partial HIR/type publication.

- `Saved/Build/typed-semantic-synthesized-boundary-partition/
  20260816_205540_756_aec01d17/` — partition build PASS;
- `Saved/Tests/typed-semantic-synthesized-accessor-exact/
  20260816_205552_057_b2f5c5fa/` — accessor `1/1 PASS`;
- `Saved/Tests/typed-semantic-synthesized-lambda-exact/
  20260816_205629_730_fc055492/` — lambda `1/1 PASS`;
- `Saved/Tests/typed-semantic-synthesized-boundary-partition-group/
  20260816_205706_789_ef45e33a/` — complete bounded prefix `35/35 PASS`.

The exhaustive current source-backed inventory is maintained in
`research/compiler-synthesized-function-dispositions.md`.

The final list-factory row is now closed by its own capability owner,
`AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedListFactoryTests.cpp`.
The raw SDK case registers a native list factory, proves the returned function
ID is the type's behavior slot, verifies the function remains `asFUNC_SYSTEM`
with no `scriptData`, build-artifact invocation or Typed Semantic HIR, and
executes `{11, 22, 33}` with identical capture-off/on results. Cross-Engine
bytecode is compared after zeroing only the pointer words of opcodes that the
maintained serializer already classifies as Engine-local pointer references;
opcodes and every non-pointer operand remain exact.

The first accepted registration RED exposed a null `listPattern`. Root-cause
tracing found that the fork declared `asCScriptFunction::listPattern` static,
while each constructor reset it. The field is now instance-owned, consistent
with the locally pulled fixed AngelScript 2.38 source at commit
`0601da029d846a658bf23f2888e953a45a94450a`. Delegate fields remain outside
this slice because their existing test records a separate known limitation.

- `Saved/Build/typed-semantic-list-factory-engine-local-normalization/
  20260816_212532_082_2172bed4/` — affected build PASS;
- `Saved/Tests/typed-semantic-list-factory-engine-local-normalization-exact/
  20260816_212549_262_5825c26c/` — exact contract `1/1 PASS`;
- `Saved/Tests/typed-semantic-list-factory-engine-local-normalization-group/
  20260816_212625_822_f4f1b01b/` — complete bounded prefix `36/36 PASS`.

### 2.8 — provisional transaction

This task closed on 2026-08-16. `asCCompiler::Reset()` now creates the optional
compile-local builder for ordinary functions and global initializers; generated
default constructor/destructor/factory and `__InitDefaults` paths retain their
explicit deterministic unsupported dispositions. No builder-owned model is
visible through `ScriptFunctionData` during compilation. Normal bytecode
finalization runs first, then `TakeVerifiedFunction()` verifies the completed
model, and only a valid result is transferred to the function owner.

`AngelscriptNativeTypedSemanticIRPublicationTransactionTests.cpp` owns the
compiler-level failure boundary separately from expression, unsupported and
synthesized-function tests. Its unit-test-only Engine user-data seam invalidates
the provisional root immediately before the real verifier. The valid script
still compiles; the invalid sidecar is not published; the stable diagnostic
contains `semantic verification failed` and `Function root is missing`; the
capture-off/on bytecode arrays remain exactly equal; and both VM executions
return `42`. Existing successful-publication and failed-module tests continue
to prove successful commit, script-error discard and zero partial publication.

- `Saved/Tests/typed-semantic-publication-transaction-red-exact/
  20260816_213808_821_eca5a698/` — valid behavioral RED `0/1`, failing only
  because verifier-invalid provisional HIR was still published;
- `Saved/Build/typed-semantic-publication-transaction-green/
  20260816_214029_939_ecf873ff/` — affected UBT build PASS;
- `Saved/Tests/typed-semantic-publication-transaction-green-exact/
  20260816_214050_382_8b6c3ab9/` — exact transaction contract `1/1 PASS`;
- `Saved/Tests/typed-semantic-publication-transaction-green-group/
  20260816_214127_680_9d2e33e3/` — complete bounded prefix `37/37 PASS`.

Adding the new translation unit also made Adaptive Unity repartition six
existing TypeSystem tests and exposed their dependency on a neighboring unity
unit for `AppendGeneratedAsLine` / `PrintGeneratedAsSource`. Only the six
compiler-reported files were repaired with direct
`AngelscriptNativeLanguageCaseTestSupport.h` includes. This is build hygiene,
not part of HIR transaction behavior, and reinforces the partition rule that
every test translation unit owns all of its includes.

### 2.10 and 2.11 — effective receivers

Standalone source compilation proves that an
`external_implicit_this` function and a `mixin` function retain distinct
parameter-zero receiver records, while verifier tests reject missing,
primitive and trait-inconsistent receiver shapes. This is not yet the complete
task evidence: real body resolution of explicit `this`, unqualified
field/property/method access, lookup precedence, null behavior, source-call
mixin evaluation, named/default/formal mapping and free-call rejection have
not all been joined to captured HIR and capture-on/off VM behavior.

### 2.12–2.14 — rewritten and ordered calls

The normalized header records compile-out kind, hidden-argument index and
determines-output-type index. Resolved calls currently store operands, formal
indices and reverse evaluation sequence. The HIR does not yet store explicit
source/default/hidden argument-origin records, so the named/default/hidden,
compile-out and ABI-only call requirements remain open even though later
StaticJIT entry planning carries some of the same host metadata.

### 2.16 — target kinds and mutable imports

Concrete script/system calls and imported slots are distinct. The native
compiler test binds, rebinds and unbinds an import and proves HIR retains the
`FUNC_IMPORTED` slot instead of either mutable `boundFunctionId`; generated
differential execution also follows the current slot. Shared/external body
declaration-owner/calling-module coverage is still incomplete, so the parent
task remains open.

### 2.17 — source provenance

Every current HIR node owns the processed compiler section/offset/length.
Typed AOT diagnostics normalize that processed section through the frozen
generation graph. Optional authored/generated fields exist in the
backend-neutral diagnostic and Provider ABI, but real compiler/preprocessor
mapping does not currently populate them: `BuildCallDiagnostic` supplies only
`ProcessedSource`. Synthetic diagnostics tests therefore do not close the HIR
provenance task. A real generated asset/singleton fixture and fail-honest
fallback test are still required.

## Directly missing tasks

- **0.7:** the named exception-cleanup test file is absent and the isolated
  BytecodeJIT cleanup-order candidate has not been treated as landed.
- **2.7:** there is no one capture-on/off matrix covering bytecode, line data,
  dependencies, traits/signature identity, VM, receiver/call-rewrite fixtures,
  and archive non-persistence together.
- **2.21:** the exact full Compiler and Standalone commands will be run as part
  of the final canonical gates; historical narrower results do not close this
  command task.

## Next implementation order

1. Complete the native expression/context matrix for 2.1/2.2 without changing
   bytecode behavior.
2. Complete the remaining typed unsupported-marker matrix for 2.5; the
   compiler-level invalid-provisional-HIR boundary in 2.8 and exhaustive 2.9
   synthesized-function disposition are now closed.
3. Extend call metadata for argument origins and shared/external ownership,
   then exercise receiver and call-order matrices for 2.10–2.16.
4. Add real preprocessor provenance and archive invariance coverage for
   2.7/2.17.
5. Revisit the isolated 0.7 cleanup-order candidate after the concurrent
   compiler/StaticJIT edits are green, then run the exact 2.21 gates.

This progressive audit closes tasks 2.8 and 2.9. Other task boxes remain
governed by their own missing evidence above.
