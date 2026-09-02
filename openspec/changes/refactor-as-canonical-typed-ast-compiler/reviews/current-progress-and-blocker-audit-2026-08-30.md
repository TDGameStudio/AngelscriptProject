# Current progress and blocker audit — 2026-08-30

## Executive status

`refactor-as-canonical-typed-ast-compiler` remains active and is not ready for
archive or the final product-default switch.

- Formal OpenSpec progress is **102/136 = 75.0%**, with **34** unchecked rows.
- The formal ratio is deliberately conservative because many remaining rows
  are overlapping umbrella/cutover/final-verification obligations.
- A current architecture-weighted estimate is **about 98%** for the requested
  non-Standalone implementation. The end-to-end overall estimate, including
  remaining cutover and verification work, is **about 93%**. These are
  engineering estimates, not task completion claims.
- Safe product-default CANONICAL readiness is lower, **about 92%**. CTA-S92
  closes constructor formal provenance, Sidecar V11 persistence, Cache
  current-module authority and the PreClass `Super::` publication defect.
  CTA-S93 through CTA-S97 additionally close generation-local Runtime
  type-binding authentication, reviewed nested-native callable signatures and
  post-freeze root/helper body-signature authority. CTA-S98 closes the
  derived-funcdef source-formal producer/reuse/consumer relation. Remaining
  constraints are led by unsupported call/language/provider breadth, the
  default cutover scans and focused/All verification. Product default is
  deliberately still LEGACY.

CTA-S91 now closes the central Runtime default-argument ownership and typed
projection defect, including registered-native factory construction with a
named argument and an omitted default. Direct shells and imports own
independent strings; `CompileFunction`, automatic imports and
registered-native projections parse defaults through Canonical Parser/Sema;
and the numeric text fallback is no longer a call-materialization path. The
factory case went from exact `0/1` RED (`unresolved-callee` for the authored
type name) to `1/1 PASS` without renaming the internal `$behN` Runtime
behaviour. The complete CallArguments group is **10/10 PASS**.

The first broad rerun also exposed and closed a native-AST compatibility crash:
CANONICAL full default-expression parsing had inserted raw `snAssignment` into
the parameter list where Builder's retained native syntax route requires the
original `snExpression` wrapper. Restoring the transparent wrapper while
keeping the full parsed assignment as its child makes the isolated import case
**1/1 PASS**, ProductionCodeGen **167/167 PASS**, and CodeGen
transaction/rollback **21/21 PASS**. This fix explicitly preserves the
original AS AST for Stage-2 registration, LEGACY/reference and syntax use;
HIR remains absent.

CTA-S92 has now closed the focused producer/verifier/persistence/execution-
consumer portion of the remaining constructor-provenance gap. An ordinary
`asAST_EXPR_CONSTRUCT` preserves the same complete source-to-formal
`asSASTCallArgument` relation as CALL while retaining its existing
evaluation/storage order; Verifier rejects a resolved constructor with missing
formal coverage. The named-plus-default source gate went from exact **0/1
RED** to **1/1 PASS**, the forged/missing-relation verifier gate likewise went
from **0/1 RED** to **1/1 PASS**, and a same-typed adversarial consumer mutation
went from the wrong Runtime value `0` to the correct `427`. The pre-final-Sema
ProductionCodeGen prefix is **168/168 PASS**.

CTA-S93 through CTA-S96 close the next generation/TypedASTJIT authority chain.
Generation now freezes and authenticates exact Runtime type-binding coordinates
without using dynamic TypeId as durable identity; Runtime default projection
and generation-snapshot lease lifetime are closed; and nested direct native
calls consume the structurally validated reviewed descriptor C++ signature
rather than a Runtime type-name spelling helper. The Runtime Print
`FLinearColor` failure is closed without adding a type-name special case. A
subsequent `ReviewedUEHeaderInline` failure was an old test-only manually
assembled emission plan, not a production backend gap. The final combined
Compiler CanonicalAST + ProjectGeneration Engine + TypedASTJIT + NativeBridge
matrix is now **778/778 PASS**, with zero failures and zero skips. Evidence is
in
`attachments/cta-s96-reviewed-native-cpp-callable-signature-gate-2026-08-30.md`.

CTA-S97 closes the independent root/helper body-signature consumer that
remained after CTA-S96. A real `const FString&in` root now emits from the
authenticated frozen EntryPlan even when the live Runtime TypeInfo display name
is changed after capture. Root eligibility, helper dependency analysis and
provider-body emission reuse one frozen function shape, and EntryPlan
structural admission now recomputes its complete V2 hash instead of accepting
any nonzero value. The exact RED gates are **0/1 + 0/1**, the focused GREENs
are **1/1 + 1/1**, ProjectGeneration Engine is **40/40**, EntryPlan is **2/2**,
TypedASTJIT is **56/56**, and the final Compiler CanonicalAST +
ProjectGeneration Engine + TypedASTJIT + NativeBridge matrix is **779/779
PASS**, with zero failures/skips. Evidence is in
`attachments/cta-s97-frozen-root-helper-body-signature-gate-2026-08-30.md`.

CTA-S98 closes the non-invertible derived-funcdef boundary identified by
CTA-S90. Source by-value value objects and explicit `const T&inout` formals may
share one normalized Runtime ABI, but now cannot reuse an empty-metadata host
funcdef or each other's source-distinct derived funcdef. New derived funcdefs
copy the complete source qualifier vector, and explicit lambda viability,
omitted lambda inference and indirect funcdef call planning consume it through
the function-aware Runtime bridge. The valid semantic gate went **0/1 RED ->
1/1 PASS**; SemaAuthority is **458/458** and the complete native SDK Compiler
prefix is **798/798**. The initial `LNK2019` fixture build is explicitly
excluded from semantic evidence. Details are in
`attachments/cta-s98-derived-funcdef-source-formal-relation-gate-2026-08-30.md`.
The post-closure disposition of unsupported breadth, coarse registered-
callable resolver hardening and the historical shared `funcdefType` boundary is
recorded separately in
`reviews/cta-s98-post-closure-next-blocker-audit-2026-08-30.md`.

The wider regression matrix is now green. The temporary reference-class
`AUTO_HANDLE` defect is closed; latest SemaAuthority is **457/457**. Sidecar V11
persists/authenticates the relation (**25/25**), the five initially exposed
Cache failures were resolved at their actual fixture/authority/`Super::` roots
and the complete Cache prefix is **585/585**. Module is **65/65**. Full Hot
Reload first exposed two stale duplicate-diagnostic expectations at **132/134**;
the functional rollback assertions were already green, both focused expectation
repairs are **1/1**, and the complete prefix is now **134/134**. Evidence and
non-claims are in
`attachments/cta-s92-construct-call-argument-provenance-gate-2026-08-30.md`.

The remaining call-related architecture gap is therefore narrower again:
complete unsupported-family coverage, production-entry/default-cutover scans
and final verification keep product-default readiness at **about 92%** and the
formal task count unchanged until the enclosing umbrella requirements are
fully demonstrated. The derived-funcdef relation and the post-freeze
root/helper type-spelling gap are both closed.

The current worktree is green for these latest implemented Canonical slices:
Frontend CanonicalAST is **183/183**, Compiler CanonicalAST is **673/673**,
SemaAuthority is **458/458**, complete native SDK Compiler is **798/798**,
ProductionCodeGen is **168/168**, Cache is
**585/585**, Module is **65/65**, and Hot Reload is **134/134**. CTA-S77 additionally records
SemaAuthority **438/438** and the current TypedASTJIT prefix **54/54**. CTA-S80
records the full StaticJIT ProjectGeneration Engine class at **34/34** and the
combined Compiler CanonicalAST plus TypedASTJIT matrix at **693/693**. CTA-S81
subsequently records NativeBridge **10/10** and ProjectGeneration Engine plus
AOT Diagnostics Generation **38/38**, followed by the combined Compiler
CanonicalAST, TypedASTJIT and NativeBridge matrix at **703/703** with zero
failures/skips. CTA-S82 removes the remaining reviewed declaration-string
native-target reconciliation and records the complete ProjectGeneration Engine
class at **37/37**, the exact identity gates at **3/3**, and the same broad
Compiler CanonicalAST, TypedASTJIT and NativeBridge matrix at **703/703** with
zero failures/skips. CTA-S83 removes live Runtime global-name reconstruction
from folded/global semantic dependencies and records the exact correct plus
wrong/missing/duplicate relation matrix at **1/1**, the complete generation
Engine class at **37/37**, and the broad matrix at **703/703**, all green.
CTA-S84 then removes reverse-child-position argument placement from the
TypedASTJIT direct-call emitter. Its exact same-typed reordered relation is
**1/1**, the complete adapter class is **26/26**, and the broad matrix is now
**704/704**, all green with zero failures/skips. CTA-S85 closes the matching
callee-entry defect: explicit sealed `ParamDecl.formalIndex` now drives
verifier/signature/Runtime/Snapshot/Sidecar/TypedASTJIT root binding. CTA-S92
subsequently advances the current Sidecar schema to V11 for constructor
call-argument relations. The
adapter is **27/27**, verifier **53/53**, Sidecar **24/24**, Snapshot **12/12**,
and the broad matrix is **705/705**, all green with zero failures/skips.
CTA-S86 now makes registered/prepared/import/method/constructor/list-factory
lookup, Runtime signature materialization and VM callee-entry binding consume
exact formal ordinals. The same-typed VM fixture went **0/1 RED -> GREEN**;
ProductionCodeGen is **137/137**, CodeGen transaction **21/21**, and the broad
matrix is **706/706**, all green. CTA-S87 then closes the reviewed production
Sema consumers across call planning/records, override/interface matching,
lambda/funcdef contextualization, constructor/operator conversion,
native/external projection, mixin receiver origin and exact diagnostic order.
Its final grouped relation gate is **6/6**, ProductionCodeGen **137/137**,
transaction/rollback **21/21**, and the broad Compiler CanonicalAST +
TypedASTJIT + NativeBridge matrix is **713/713 PASS**, with zero failures or
skips. CTA-S88 then separates script source-formal identity from Runtime shell
ABI, preserves exact native `in/out/inout`, fixes a script template-factory
double hidden-formal skip, and makes current-module/automatic-import CodeGen
perform exact normalized script-ABI authentication. Its four SemaAuthority
gates are **4/4**, ProductionCodeGen is **154/154**, transaction/rollback is
**21/21**, and the broad Compiler CanonicalAST + TypedASTJIT + NativeBridge
matrix is **719/719 PASS**, all with zero failures/skips. The
CTA-S89 registered native method gate then went from an exact **0/1 RED** at
CodeGen relocation to **1/1 PASS**, and the complete ProductionCodeGen prefix
is **155/155 PASS**. The broad Compiler CanonicalAST + TypedASTJIT +
NativeBridge matrix is now **720/720 PASS**, with zero failures/skips. The
prior default-timeout Cache
run is explicitly not counted as evidence; the complete 30-minute-budget rerun
is. The blocker is incomplete breadth and final cutover evidence, not a known
Canonical compiler assertion failure.

## Latest verified implementation slices

CTA-S91 closes the central default-argument ownership and projection defect.
Detached authored functions and explicit imports now deep-copy non-empty
Canonical default strings into owning Runtime shells with leak-safe partial
failure handling. Runtime-to-Canonical projection is centralized across
`CompileFunction`, automatic imports, native globals, methods and behaviours;
each projected default is parsed and typed by the existing Canonical
Parser/Sema in a generated stable source section, after which the surrounding
authored parse context is restored. The old text-only numeric fallback has
been removed. A `40 + 2` registered-native default proves typed expression
materialization. The first broad run exposed a separate detached-import
primitive ABI mismatch (**161/162**); exact diagnosis showed import `int`
versus provider `const int`, and normalization of only the live import shell
closed it. The final build passes, the focused import is **1/1**, and complete
ProductionCodeGen is **162/162 PASS**. Evidence, invalid-run exclusions and
remaining breadth are in
`attachments/runtime-default-argument-ownership-and-projection-audit-2026-08-30.md`.

CTA-S89 closes the confirmed registered-native method Runtime identity defect.
`FindExactRegisteredMethod` now authenticates the exact receiver readonly
state, complete specialized return/parameter datatypes, vector lengths and
every passing flag including `none`, without applying script-shell ABI
normalization to native functions. A mutable `Read()` plus const poison
`Read() const` fixture went from **0/1 RED** at `missing callable relocation`
to **1/1 PASS**, executes 42 through only the mutable Runtime function ID, and
the complete ProductionCodeGen prefix is **155/155 PASS**. The broad Compiler
CanonicalAST + TypedASTJIT + NativeBridge gate is **720/720 PASS**. An exploratory
registered-global const-parameter test failed earlier in Sema and was removed,
not counted as a resolver RED. Evidence, exclusion reasoning and the remaining
global/constructor/list-factory scope are in
`attachments/cta-s89-registered-method-exact-runtime-identity-gate-2026-08-30.md`.

CTA-S88 closes the reviewed current-module, automatic-import, native-method
and native-behaviour parameter-ABI defects. Script projections recover source
identity with `FromScriptParameterABI`; script Runtime-shell lookup performs
the inverse `NormalizeScriptParameterABI` plus full datatype and exact passing
comparison. Native projections do not use script normalization and derive
direction only from exact Runtime `inOutFlags`. A real template-factory
fixture additionally exposed and closed a second skip of the first authored
formal after the script stub had already removed TypeInfo. The four grouped
SemaAuthority fixtures are **4/4 PASS**, ProductionCodeGen is **154/154**,
transaction/rollback is **21/21**, and Compiler CanonicalAST + TypedASTJIT +
NativeBridge is **719/719 PASS**. Exact RED/GREEN evidence, excluded fixture
errors and residual non-claims are in
`attachments/cta-s88-exact-parameter-passing-signature-gate-2026-08-30.md`.

CTA-S87 closes every high-risk positional production-Sema consumer identified
by the formal-ordinal audit. The repair does not sort declaration or call
children: exact `ParamDecl.formalIndex` determines ABI/formal identity while
the sealed record order continues to determine evaluation. Seven adversarial
fixtures cover named/default plans, generated records, override/interface,
lambda/funcdef, constructor selection/conversion, native projection dedup and
mixin receiver origin. The grouped projection/origin gate is **6/6 PASS**,
ProductionCodeGen **137/137**, transaction/rollback **21/21**, and Compiler
CanonicalAST + TypedASTJIT + NativeBridge **713/713 PASS**. A residual
read-only review found only name/count/singleton/kind parameter scans, which
are order-neutral. Evidence and non-claims are in
`attachments/cta-s87-production-sema-formal-ordinal-consumption-gate-2026-08-30.md`.

CTA-S86 closes the reviewed Canonical Bytecode/VM formal-order consumers.
Incoming Runtime slot N now binds to `GetFormalDecl(callable, N)`, and the same
exact relation drives callable lookup, method/constructor/list-factory matching,
generated setters, Runtime signature/name publication and detached imports.
Function-local `VarDecl` traversal and lambda capture relations remain separate,
and sealed call records still preserve evaluation order. The same-type fixture
proved the old result 24 and the corrected result 42 (**0/1 RED -> 1/1 GREEN**).
ProductionCodeGen is **137/137**, CodeGen transaction **21/21**, and Compiler
CanonicalAST plus TypedASTJIT plus NativeBridge is **706/706 PASS**. Evidence is
in `attachments/cta-s86-bytecode-formal-ordinal-consumption-gate-2026-08-30.md`.
The independent review in
`reviews/formal-ordinal-production-consumer-audit-2026-08-30.md` now records
the CTA-S87 closure and keeps the remaining Verifier/Sidecar/public-view and
direct projection fixtures as test-hardening rather than known product bugs.

CTA-S85 closes the TypedASTJIT root-entry positional formal-binding defect.
Canonical parameters now publish a zero-based `formalIndex`; exact lookup and
publication verification reject missing, duplicate, out-of-range or wrong-
owner relations. Stable signatures and the Runtime bridge enumerate exact
formal order, the append-only public view exposes it with old-capacity
compatibility, and Sidecar V10 persists/authenticates it. TypedASTJIT root
emission resolves Runtime slot N through the sealed relation and verifies the
Canonical/Runtime ABI spelling rather than taking the nth `DECL_PARAM` child.
The adversarial same-typed reordered-child case went **0/1 RED -> GREEN**; the
complete adapter is **27/27**, verifier **53/53**, Sidecar **24/24**, Snapshot
**12/12**, and Compiler CanonicalAST plus TypedASTJIT plus NativeBridge is
**705/705 PASS**. Evidence, including the non-semantic CQTest selector no-match,
is in
`attachments/cta-s85-sealed-formal-ordinal-relation-gate-2026-08-30.md`.

CTA-S84 closes a silent same-typed argument-placement defect in the direct-call
emitter. Canonical Sema and the verifier already owned exact argument
arrangement through `Expr.callArguments`: the stored child/record order is the
evaluation order, while `formalIndex` identifies the invocation slot and
`formalType` identifies the formal ABI. TypedASTJIT had ignored that relation
and derived a slot from reverse child position. A sealed two-`int` graph proved
the old route could exchange values without a type error (**0/1 RED**). The
emitter now requires sealed direct dispatch and one complete, unique, in-range
relation per argument, evaluates in stored order, and places temporaries by the
sealed formal index. The exact test is **1/1 PASS**, the adapter class is
**26/26 PASS**, and Compiler CanonicalAST plus TypedASTJIT plus NativeBridge is
**704/704 PASS**. Evidence and non-claims are in
`attachments/cta-s84-direct-call-argument-relation-consumption-gate-2026-08-30.md`.

CTA-S83 closes the folded/global dependency identity defect left after the
native-target relation was corrected. Canonical Sema/CodeGen now publishes the
sealed global `VarDecl.stableKey` to the current Runtime property; the Runtime
bridge authenticates the exact module/TU/namespace/name/type structure;
generation carries the same key through global and semantic-dependency rows;
and TypedASTJIT consumes that key directly. Stable artifact reference,
current-Engine property ID, expected ABI and expected content/value remain
separate coordinates. Runtime name mutation cannot redirect the relation, while
wrong, missing and duplicate keys select per-function
`SemanticDependencyMismatch` without emission. The exact matrix is **1/1
PASS**, the complete ProjectGeneration Engine class is **37/37 PASS**, and
Compiler CanonicalAST plus TypedASTJIT plus NativeBridge is **703/703 PASS**
with zero failures/skips. Evidence, the corrected negative-test fixture issue
and non-claims are in
`attachments/cta-s83-exact-global-dependency-relation-gate-2026-08-30.md`.

CTA-S82 closes the exact native-target relation defect left explicit by
CTA-S81. Canonical Sema now publishes the selected projected system function's
stable declaration key; the Runtime type bridge authenticates that key against
the exact owner/namespace/return/parameter/passing/const structure; generation
snapshot capture freezes the same key; and TypedASTJIT closure matches only the
resolved call target's stable key. `CanonicalDeclaration` and `origin` are
diagnostic-only, while Engine-local FunctionId remains a current-generation
execution coordinate after stable relation selection. Diagnostic spelling
mutation remains eligible; wrong, missing, duplicate or ambiguous keys fail
closed. The exact gates are **3/3 PASS**, the complete ProjectGeneration Engine
class is **37/37 PASS**, and Compiler CanonicalAST plus TypedASTJIT plus
NativeBridge is **703/703 PASS** with zero failures/skips. Evidence and
non-claims are in
`attachments/cta-s82-exact-native-target-relation-gate-2026-08-30.md`.

CTA-S81 closes the structured exception payload and aggregate diagnostic defect
left explicit by CTA-S80. Bound-call infrastructure failures now retain the
same direct first-failure record contract as other generated native guards,
while an already-adopted nested VM failure remains authoritative. Successful
direct/CurrentNative closures report `DirectFailureRecord`; any emitted VM
bridge additionally reports nested adoption through
`DirectFailureRecordAndNestedBridgeAdoption`. The reducer consumes structured
emitted call-site metadata, not generated source text. The exact gates are
**3/3 PASS**, NativeBridge is **10/10 PASS**, ProjectGeneration Engine plus
AOT Diagnostics Generation is **38/38 PASS**, and the broad Compiler
CanonicalAST plus TypedASTJIT plus NativeBridge matrix is **703/703 PASS** with
zero failures/skips. The same audit corrected the
stale suspend interpretation: current `bHasSuspendState=false` is a truthful
Canonical language fact because the current compiler has no cooperative
resumable frame; native `MaySuspend` remains a call-edge fallback capability.
Evidence and non-claims are in
`attachments/cta-s81-typedjit-exception-payload-aggregate-gate-2026-08-30.md`.

CTA-S80 closes a native-call safety and typed-diagnostic boundary in
TypedASTJIT closure planning. `MaySuspend` now selects exact per-function
`SuspendOrExceptionState` before generic descriptor rejection, while a
direct-callable descriptor with `MaySetScriptException` selects
`ExceptionPayloadUnavailable` before it can become a bare native call. VM
scalar bridge + MaySet remains eligible because its nested-context first-
failure adoption path already exists. The focused gates went **0/2 RED -> 2/2
GREEN**, the complete ProjectGeneration Engine class is **34/34 PASS**, and
Compiler CanonicalAST plus TypedASTJIT is **693/693 PASS**. CTA-S81 subsequently
corrects the language-level suspend interpretation and closes the structured
payload/aggregate diagnostic issue. CTA-S80 evidence and non-claims are in
`attachments/cta-s80-typedjit-native-exception-suspend-fallback-gate-2026-08-30.md`.

CTA-S79 removes the broader expression-Sema short-name owner fallback exposed
by the CTA-S78 audit. The shared lookup used by properties, members, operators,
conversions, native projection and base convertibility previously attached an
unqualified `FValue` receiver to `Wrong::FValue` by short declaration name.
It now requires complete declaration/type stable-key equality. The behavior
and source guards went **0/2 RED -> 2/2 GREEN**, and Compiler CanonicalAST plus
TypedASTJIT is **693/693 PASS** (**639+54**). Evidence and non-claims are in
`attachments/cta-s79-exact-expression-type-owner-gate-2026-08-30.md`.

CTA-S78 closes the remaining known short-name fallback in Canonical lifetime
authoring. The verifier had already required exact destructor-owner stable-key
equality, but lexical, aggregate-element and declaration Sema producers could
still select `Wrong::FValue::~FValue` for an unqualified `FValue` type. All
three producers now require the same complete stable-key relation. The
adversarial/source-guard pair went **0/2 RED -> 2/2 GREEN**, and Compiler
CanonicalAST plus TypedASTJIT is **691/691 PASS** (**637+54**). Complete
RED/GREEN evidence and the explicitly unclosed 7.5 boundary are in
`attachments/cta-s78-exact-lifetime-author-owner-gate-2026-08-30.md`.

CTA-S76 and CTA-S77 close two newly exposed safety/architecture defects:

- receiver-bearing TypedASTJIT calls now select exact per-function
  `UnsupportedReceiver` fallback before typed closure can omit receiver-side
  effects, nested dependencies or ABI facts;
- an authored script base and a host PreClass native shadow now coexist as
  orthogonal sealed relations across Sema, verification, Runtime registration
  and prepared CodeGen authentication;
- Builder Seal failures now publish the exact verifier category/invariant and
  compact node path before the rejected pending graph is destroyed.

The original BytecodeIsolation symptom and both existing PreClass gates are
**3/3 PASS**, full TypedASTJIT is **54/54 PASS**, SemaAuthority is
**438/438 PASS**, and the combined Frontend+Compiler CanonicalAST matrix is
**817/817 PASS**. Complete root cause and RED/GREEN evidence are in
`attachments/cta-s76-s77-typedjit-receiver-and-preclass-dual-relation-gates-2026-08-30.md`.

CTA-S73 through CTA-S75 close four boundaries that were open in the earlier
version of this review:

- snapshot publication fails closed when no pending Context exists;
- public CANONICAL `CompileFunction()` proves node-free source authority and
  zero legacy compiler invocations;
- globals/enumerators and classes/interfaces carry their exact producer-bound
  Canonical DeclId/stable key into late Builder consumers, deleting the old
  global `name + file + offset` scan and class-node reattachment;
- cleanup lifetime authoring and verification require complete owner stable-key
  equality rather than accepting an unqualified same-name class.

The direct-carrier change exposed one masked enum omission: enumerators had not
completed the same parsed-declaration identity binding as ordinary globals.
That producer-boundary defect was fixed in `ParseEnumeration()` and the final
Compiler prefix returned to **634/634**. Complete evidence and issue details are
in
`attachments/cta-s73-s75-snapshot-builder-authority-cache-lifetime-and-typedjit-audit-2026-08-30.md`.

CTA-S72 made call arguments first-class sealed semantic facts:

- Sema owns the source-to-formal plan for positional, named, default, hidden,
  indirect and implicit-mixin-receiver arguments;
- publication verification rejects missing/partial coverage, wrong or
  duplicate formals, invalid origin/name/source-ordinal combinations, type
  drift and receiver-shape drift;
- Canonical CodeGen consumes the authenticated records mechanically and uses
  Runtime signatures only to authenticate/project the current Engine ABI;
- Sidecar V9 preserves the pointer-free records and rejects V8 as an ordinary
  prior-schema miss;
- generated `StaticClass()` Cache restore rebuilds the body from the sealed
  Canonical AST through a focused transactional CodeGen boundary rather than
  persisting bytecode, using a dump, or hand-authoring opcodes;
- `__generated` is now a sealed Canonical trait, and prepared dispatch retains
  authored generated methods when an exact Stage 2 Runtime shell already
  exists.

Latest evidence:

| Gate | Result |
| --- | --- |
| Runtime/Editor/Test build | PASS — `Saved/Build/cta-s72-generated-method-dispatch-green-build/20260830_055706_228_a7828365` |
| Compiler CanonicalAST | **634/634 PASS** — `Saved/Tests/cta-s72-compiler-canonical-full-green2/20260830_055753_393_d0744e2a` |
| Frontend CanonicalAST | **181/181 PASS** — `Saved/Tests/cta-s72-frontend-canonical-full-green/20260830_055835_628_06315015` |
| Cache | **584/584 PASS** — `Saved/Tests/cta-s72-cache-full-green/20260830_054157_730_86347fca` |
| PackagedRuntimeReload | **7/7 PASS** — `Saved/Tests/cta-s72-packaged-runtime-cache-fixture-green/20260830_054054_364_041d5d05` |
| RootClassRestore | **1/1 PASS** — `Saved/Tests/cta-s72-generated-trait-root-green-probe/20260830_053609_214_dff11233` |
| ClassGraphInheritanceRestore | **1/1 PASS** — `Saved/Tests/cta-s72-classgraph-staticclass-restore/20260830_053700_857_224803bc` |

The exact RED/GREEN trail and issues are recorded in
`attachments/canonical-call-argument-provenance-gate-2026-08-30.md` and
`attachments/cta-s72-cache-staticclass-canonical-rebuild-progress-2026-08-30.md`.

## Current compiler lifecycle

The current split is structurally sound:

```text
module entry chooses exactly one pipeline
  |
  +-- LEGACY
  |     Parser/native asCScriptNode
  |       -> Builder registration/layout
  |       -> asCCompiler bytecode publication
  |
  `-- CANONICAL
        Parser typed actions
          -> asCSema / Canonical Decl-Type-Stmt-Expr-Lifetime facts
          -> verifier + Frozen/Publishable snapshot
          -> Stage 1/2 Runtime shell registration and exact identity binding
          -> asCBytecodeCodeGen detached emission or authenticated restore
          -> relocation/runtime-binding resolution
          -> atomic executable + snapshot + identity + binding publication
```

`asCCompiler` remains confined to the explicitly selected LEGACY compile
route. Canonical whole-module `Build()` and Canonical `CompileFunction()` seal
and consume a Canonical AST; there is no observed Canonical fallback call into
`asCCompiler`.

The native AngelScript AST remains intentionally available for parsing,
syntax/recovery, the explicit LEGACY path, differential/reference coverage and
Builder compatibility. HIR remains physically absent. Diagnostic dump/JSON is
not an AOT or Cache input.

## Corrected `asCScriptNode` diagnosis

The older statement that CANONICAL Sema still walks `asCScriptNode` through a
naming adapter is stale.

Current `asCSema` stores only a copied, pointer-free parse action identity:

```text
section + nodeKind + offset + length
    -> exact DeclId / ExprId / QualType binding
```

`as_sema.h/.cpp` no longer expose `asCScriptNode*`, and the declaration,
expression and statement Sema units have no whole-tree/node-based semantic
replay adapter. Parser-local `Build*Action` helpers may still decode the
retained syntax tree into typed action payloads; that is syntax decoding, not
Sema replay.

The late global/class authority defect described by the previous review is now
closed. Builder global and class records carry exact generation-local DeclIds
and stable keys from their registration producer boundaries.
`RegisterGlobalVariables()` no longer scans by `name + file + offset`, and
`FindCanonicalObjectDeclaration()` no longer rereads the native class node.

`BindCanonicalFunctionIdentity()`, `BindCanonicalTypeIdentity()` and member
access-specifier binding may still receive a retained parser node at the
registration boundary. They immediately persist the exact Canonical identity
into a Runtime shell; later Canonical body emission is node-free. This is an
intentional producer bridge while the native AST remains available for LEGACY
and syntax/reference use, not late backend semantic reconstruction.

## Corrected Task 3.4 snapshot diagnosis

Task 3.4 is not missing a snapshot owner implementation. The concrete
`asCASTSnapshot` already fulfills the originally named
`asCASTSnapshotStorage` role:

- it owns the `asCASTContext` and Runtime generation lease;
- module policy freezes at build start;
- `AcquireASTSnapshot()` AddRefs under the same lock used by publication;
- CANONICAL `Build()` stages a publishable snapshot, emits CodeGen from that
  exact Context, and exchanges executable/snapshot/generation under the
  publication protocol only after success;
- discard consumes the same pending Context through CodeGen and releases it
  without exposing a public snapshot;
- old leases survive replacement while their current-generation bit changes;
- failed candidate publication preserves the complete last-good generation.

Task 3.4 is now closed for the successful **CANONICAL** source-build scope.
The strengthened discard test proves Canonical publisher, zero legacy
invocations and no public retained snapshot. Snapshot-preparation failure
proves the previous executable and exact snapshot remain current; successful
replacement and public lease tests cover the complementary route. The generic
publisher now fails closed when no pending Context exists instead of
fabricating an empty translation unit.

The explicit LEGACY path remains independent and is not forced through
Canonical CodeGen. The native AngelScript AST is intentionally retained; its
physical deletion belongs to a separate future OpenSpec.

## Dynamic TypeId status

Dynamic numeric AngelScript TypeId is no longer the primary architecture
blocker.

The implemented boundary is:

```text
durable Canonical type key + expected ABI/profile key
    -> detached stable relocation
    -> candidate generation Runtime binding table
    -> resolve current asCDataType / asCTypeInfo / numeric TypeId / slot
    -> patch only candidate-owned executable operands
    -> atomically publish generation
```

Public AST, semantic sidecars, provider records and detached relocation
identity do not use Engine pointers or numeric TypeId as durable identity. Old
snapshot/executable generations keep their own immutable Runtime binding
leases. TypedASTJIT has not yet made the generation-local immutable Runtime
type-binding table an admission/authentication dependency and still derives
some supported ABI shapes from live Runtime objects or spelling. That consumer
gap is recorded in
`attachments/typed-ast-jit-runtime-type-binding-authentication-audit-2026-08-30.md`.
Remaining work is consumer authentication/breadth and final scans, not
replacement of the public AngelScript numeric TypeId API in this change. The
larger public/VM identity redesign remains correctly deferred to a later
dedicated OpenSpec.

## Real remaining critical path

### 1. Preserve receiver-safe TypedASTJIT fallback while completing coverage

CTA-S76 closes the unsafe omission: every receiver-bearing Canonical call now
selects per-function `UnsupportedReceiver` fallback before typed closure, and
the adversarial receiver-with-nested-call test proves dependency loss cannot be
hidden. Complete receiver provenance/evaluation/ABI lowering remains optional
feature coverage for 7.2/7.4; it must land atomically before this safe fallback
is relaxed.

### 2. Complete call and uncommon language-family coverage

CTA-S72 closes structured ordinary/named/default/hidden/mixin-receiver argument
authority, but the umbrella call and language rows remain open for complete
constructor, import, mixin, native, property, delegate/funcdef, lambda,
container/template, mutable-global and uncommon generated-body matrices.
Unsupported executable forms must fail closed until each has a sealed semantic
contract and mechanical backend lowering.

CTA-S84 closes the previously confirmed call-site exact-relation defect:
TypedASTJIT now directly consumes verifier-authenticated
`callArguments[].formalIndex` while preserving stored evaluation order. The
separate root-entry issue is now closed by CTA-S85: typed root wrappers resolve
the exact sealed `ParamDecl.formalIndex`, and same-typed parameter-child
reordering cannot redirect Runtime input slots. Remaining work is breadth of
the unsupported call/language/provider families, not these two positional
relations.

CTA-S86 closes the reviewed Bytecode consumer set, including VM callee entry
and Runtime signature/import lookup/materialization. CTA-S87 closes the
matching production Sema set: common call plans/records, method relations,
lambda/funcdef, constructor/operator, Runtime projection, mixin origin and
diagnostic ordering all consume exact formal slots. There is no remaining
known high-risk structural-child/formal-slot conflation in the reviewed Sema,
Bytecode, verifier, Runtime bridge, Cache/Sidecar or TypedASTJIT paths.
Remaining work is unsupported language/provider breadth and hardening evidence,
not this positional identity defect.

CTA-S88 closes the next exact-signature layer for script current-module and
automatic-import resolution plus native method/behaviour projection. CTA-S89
now closes the confirmed native `Read()`/`Read() const` registered-method
case with full datatype, exact passing and receiver-readonly authentication.
Registered global, constructor and list-factory CodeGen resolvers remain
statically coarse; each still needs an independently reachable RED before
behavior changes, with constructor/list-factory hidden prefixes preserved.

Runtime default arguments are a separate production boundary. Prepared Stage
2 authored function/import shells own them correctly, but detached function/
import materialization stores null and Runtime-to-Canonical projections omit
typed defaults. Named calls that omit a defaulted formal can therefore fail in
`CompileFunction`, automatic import or registered-native projection. The
ownership, Cache/Hot Reload effects and typed-reparse requirement are recorded
in
`attachments/runtime-default-argument-ownership-and-projection-audit-2026-08-30.md`.

### 3. Preserve the complete production-entry matrix

Whole-module `Build()` and public `CompileFunction()` now both have publisher,
zero-legacy-invocation and node-free Canonical authority evidence. Prepared-
body/Hot Reload publication and normal whole-module Generate remain separate
transaction entries and must still be included in the final cutover matrix;
passing one entry must not be used as evidence for another.

### 4. Finish direct TypedASTJIT consumption/fallback closure

TypedASTJIT already consumes sealed Canonical AST and the authenticated
lifetime view; it does not need or use a dump. Tasks 7.2/7.4/7.5 remain open
for complete eligibility/dependency/call/provider coverage and precise per-
function fallback for unsupported object-frame, exception, suspend,
global/import and cross-TU facts. Receiver-bearing
calls are now explicitly safe fallback. A native object-frame ABI is not
required merely to finish this change; unsupported shapes may remain explicit
fallback rather than partial native cleanup.

CTA-S78 additionally aligns the lifetime producers with verifier-side exact
owner identity, so short-name cleanup binding is no longer part of this open
list. The remaining lifetime-related work is explicit capability/fallback
coverage, not rediscovery of destructor ownership by spelling.

CTA-S79 applies the same rule to general expression type ownership, so the
remaining native/call work no longer includes this known short-name recovery
path. It still includes immutable Runtime target binding and complete
receiver/import/native dependency coverage.

CTA-S80 now guarantees that unsupported native suspend state and direct native
exception payload requirements are explicit typed per-function fallback,
rather than generic rejection or unsafe direct emission. Remaining
exception/suspend work is uncovered language/runtime families, not this native
route safety boundary. CTA-S81 closes the previously open diagnostic-authority
defect: infrastructure failures now retain structured first-failure payloads,
and emitted bridge closures report the combined direct+nested mechanism set.
Current `bHasSuspendState=false` remains truthful because the Canonical language
model has no resumable suspension frame.

CTA-S82 now closes the reviewed immutable native-target identity gap: Sema,
Runtime binding, generation snapshot and closure share one exact stable
declaration key, and no consumer reconstructs this relation from declaration
or owner spelling. Remaining native/call work is receiver lowering and the
uncovered import/mixin/property/constructor/delegate/lambda/global/cross-TU
families, not target rediscovery by text.

CTA-S83 applies the same separation to the supported folded hard-value global
route. TypedASTJIT consumes the frozen Canonical global declaration key directly
and keeps the artifact-stable global reference, current Engine property ID, ABI
and expected value/content as orthogonal coordinates. Live Runtime spelling no
longer reconstructs the relation; malformed keys fail closed. Remaining global
work is mutable-global/import lifecycle and provider coverage, not folded-global
rediscovery by namespace/name.

The known dynamic-TypeId/TypedASTJIT enforcement gate is now closed for the
supported production slice. CTA-S93 authenticates every non-primitive
return/formal/receiver coordinate against the immutable generation-local
Runtime binding view and fails per root on missing, duplicate, wrong-profile,
wrong-environment, wrong-layout, wrong-behaviour, wrong-kind, null or foreign
coordinates. CTA-S97 then closes the post-freeze root/helper ABI consumer:
eligibility, dependency analysis and body emission use one hash-authenticated
EntryPlan shape rather than live TypeInfo names. Numeric TypeId and Runtime
pointers remain generation-local execution coordinates. Remaining type-related
work is unsupported-family breadth and capture-time reviewed-registry design,
not a known stable-identity or post-freeze ABI reconstruction defect.

### 5. Reconcile stale umbrella tasks and run the final cutover matrix

The 34 unchecked rows are not 34 independent missing components. They collapse
into Sema/language breadth, Bytecode/AOT breadth, snapshot acceptance,
default-selection/cutover, and final verification. After the focused gaps above
are closed:

- run the complete AST-first gate matrix required by 0.3;
- switch the product default to CANONICAL while retaining explicit LEGACY;
- prove no silent/dual fallback for every in-scope UE build purpose;
- run every focused prefix required by 12.2/13.12;
- run the final All suite required by 12.4;
- reconcile each umbrella row against exact evidence.

Standalone adaptation and verification remain deferred by user scope and are
not a completion gate for this pass.

## Encountered issues and disposition

| Issue | Disposition |
| --- | --- |
| Call meaning encoded partly in literal strings/parallel child order | Fixed by typed `asSASTCallArgument`, verifier firewall, mechanical CodeGen and Sidecar V9 |
| Hidden parameter between authored formals could make a later formal appear missing | Fixed by the Sema-owned complete source-to-formal plan |
| Cache restore could not authenticate generated `StaticClass()` | Fixed by carrying `__generated` as a Canonical trait and rebuilding through focused Canonical CodeGen |
| PackagedRuntimeReload asserted Cache V2 lifecycle while Cache V2 was disabled | Fixed in the test fixture by explicit enablement and isolated cache root; production default unchanged |
| Prepared dispatch excluded every generated method | Fixed to defer only generated methods without an exact Stage 2 binding |
| Sema native-node dependency audit described an already-retired pointer bridge | Corrected: Sema is pointer-free; late Builder authority reattachment is the actual remaining boundary |
| Late globals/classes reconstructed Canonical identity from native-node coordinates | Fixed by producer-carried exact DeclId/stable key; enum regression exposed and fixed a missing parser identity bind |
| Task 3.4 described snapshot storage as absent and LEGACY as a universal blocker | Closed for CANONICAL after discard, missing-pending and last-good snapshot/executable acceptance; explicit LEGACY remains intentional |
| Cache clean capture traversed a raw Canonical Context | Fixed with a public snapshot lease and an explicit compile-transaction lifetime contract; long-timeout full Cache rerun is tracked separately |
| Lifetime verifier was exact but three Sema authors still accepted an unqualified same-name destructor owner | Fixed across lexical, aggregate-element and declaration authors; adversarial pair and combined Compiler/TypedASTJIT **691/691** pass |
| Expression Sema could attach an unqualified type to a namespaced same-name property/operator owner | Fixed by complete type/declaration stable-key equality; adversarial pair and combined Compiler/TypedASTJIT **693/693** pass |
| Direct native `MaySetScriptException` could remain TypedASTJIT-eligible without an exception payload route | Fixed by exact `ExceptionPayloadUnavailable` per-function fallback before direct disposition; bridge adoption remains eligible; generation Engine **34/34** pass |
| Native `MaySuspend` was collapsed to generic `UnsupportedCall` | Fixed by pre-validation `SuspendOrExceptionState` fallback; native call-edge capability is deliberately separate from the currently false language-lifetime suspend fact |
| Bound-call infrastructure failures set only the control bit, and VM-bridge closures were diagnosed as direct-only payload state | Fixed by structured direct first-failure publication plus `DirectFailureRecordAndNestedBridgeAdoption`; exact **3/3**, NativeBridge **10/10**, Generation/AOT **38/38**, and broad Compiler/TypedASTJIT/NativeBridge **703/703** pass |
| Native target capture and TypedASTJIT closure reconstructed one resolved Canonical relation through `GetDeclaration()`/`origin` text | Fixed by producer-carried `CanonicalTargetDeclKey`, structural Runtime authentication, frozen exact-key snapshot rows and exact closure lookup; diagnostic spelling is non-semantic, invalid keys fail closed, generation Engine **37/37** and broad **703/703** pass |
| Folded-global TypedASTJIT dependency capture reconstructed a sealed declaration from live Runtime namespace/name | Fixed by producer-carried `CanonicalASTDeclKey` across the Runtime property, generation global, semantic dependency and backend graph; wrong/missing/duplicate keys are `SemanticDependencyMismatch`, generation Engine **37/37** and broad **703/703** pass |
| Negative duplicate-key fixture inserted a `TArray` element by reference back into the same reallocating array | Test-only fixture defect fixed by copying the row before insertion; the assertion run is retained as diagnostic evidence and the corrected relation matrix is **1/1 PASS** |
| TypedASTJIT call emission ignored authoritative `callArguments[].formalIndex` and derived formal placement from reverse child position | Fixed by CTA-S84 direct relation consumption; same-typed adversarial RED→GREEN, adapter **26/26** and broad **704/704** pass |
| Typed root entry binding associated nth `DECL_PARAM` child with nth Runtime parameter slot | Fixed by sealed `ParamDecl.formalIndex` across verifier/signature/Runtime/public view/Sidecar/TypedASTJIT; same-typed RED→GREEN, adapter **27/27** and broad **705/705** pass. The current Sidecar schema is V11 after CTA-S92 |
| Canonical Bytecode rebuilt callable signatures and VM entry slots from ParamDecl child order | Fixed by CTA-S86 exact formal lookup across lookup/materialization/entry binding; same-typed VM RED→GREEN, ProductionCodeGen **137/137**, transaction **21/21**, broad **706/706** pass |
| Production Sema treated nth ParamDecl child as formal slot in call planning and related matchers | Fixed by CTA-S87 exact formal joins across plans/records, method/lambda/constructor/native projection and diagnostics; seven adversarial fixtures, grouped **6/6**, ProductionCodeGen **137/137**, transaction **21/21**, broad **713/713** pass |
| Script source formal identity was compared directly with normalized Runtime shell ABI | Fixed by paired `FromScriptParameterABI`/`NormalizeScriptParameterABI`, full datatype equality and exact passing; CTA-S88 grouped **4/4**, ProductionCodeGen **154/154**, transaction **21/21**, broad **719/719** pass |
| Native method/behaviour OUT direction was inferred from reference shape and could become INOUT | Fixed by exact Runtime `inOutFlags` projection and source-ordinal mapping; covered by CTA-S88 grouped gate |
| Script template-factory visible formal was skipped after its Runtime stub had already removed hidden TypeInfo | Fixed by applying the secondary template-factory skip only to non-script Runtime functions; real factory fixture RED to GREEN |
| Registered-native CodeGen method resolver ignored method readonly and used coarse datatype/passing checks | Fixed by CTA-S89 full Runtime signature and receiver-readonly authentication; exact relocation RED→GREEN, ProductionCodeGen **155/155** and broad **720/720** pass |
| Registered global, constructor and list-factory CodeGen resolvers retain coarse datatype/passing comparisons | Open; the global const-reference exploratory fixture was Sema-ambiguous and was removed, so each route still requires a genuine staged or naturally reachable RED before repair |
| Source by-value value-object and explicit `const T&inout` collapse to the same normalized Runtime ABI | Fixed across the currently reachable relation: CTA-S90 publishes/authenticates exact source qualifiers for direct CodeGen/current-module, prepared Builder, direct import and constructor factory; CTA-S98 makes derived-funcdef reuse include that source identity and moves explicit/omitted lambda plus indirect-call consumers to the function-aware bridge. Exact **0/1 RED -> 1/1 PASS**, SemaAuthority **458/458**, native SDK Compiler **798/798**. Future source-owned template-funcdef donors and wider generated-copy families remain explicit breadth items, not a known current misreuse |
| Runtime default arguments are lost by detached shell materialization and Runtime-to-Canonical projections lack typed defaults | Fixed centrally: detached shells/imports own independent default text, current-module/automatic-import/native projections rebuild typed defaults through Canonical Parser/Sema, scoped enum/float/null-handle/method/factory cases execute, and CallArguments is **10/10**. CTA-S92 additionally closes missing global-route `CurrentModuleAuthority`; exact **1/1** and full Cache **585/585** pass. CTA-S98 independently closes the adjacent derived-funcdef source-qualifier consumption item |
| Ordinary CONSTRUCT executed named/default operands without publishing an exact source-to-formal relation | Fixed by CTA-S92: distinct CONSTRUCT kind plus complete `asSASTCallArgument`, verifier coverage, Sidecar V11 and formal-index-driven Bytecode; ProductionCodeGen **168/168**, Sidecar **25/25** and Compiler CanonicalAST **672/672** pass |
| PreClass class graphs exposed authored script base plus native shadow as two apparent direct bases, leaving `Super::` unresolved at publication | Fixed by ignoring only `CANONICAL_NATIVE_TYPE_VIEW_ORIGIN` for authored direct-base selection; multiple authored bases still fail closed and verifier remains strict. SemaAuthority **457/457**, exact UE regression **1/1**, full Cache **585/585** pass |
| Full Hot Reload negative tests expected duplicate copies of one deterministic compile diagnostic | Test-only expectation corrected to one file location, one exact diagnostic and one rollback message; functional no-broadcast/old-code/diagnostic assertions remain. Focused **1/1 + 1/1**, full Hot Reload **134/134** pass |
| TypedASTJIT did not authenticate ABI-relevant types through the generation-local immutable Runtime binding table and later re-inferred root/helper body spelling from live TypeInfo names | Fixed by CTA-S93 through CTA-S97: exact negative binding-row authentication, clean generation ownership/teardown, descriptor-owned nested-native signatures, one hash-authenticated frozen root/helper shape, poison-name RED→GREEN, ProjectGeneration Engine **40/40**, TypedASTJIT **56/56**, and broad **779/779** pass. Capture-time reviewed-type recognition and unsupported container-family classification remain explicit non-claims |
| TypedASTJIT skipped call receiver subgraphs | Fixed by explicit pre-closure `UnsupportedReceiver` fallback; complete receiver lowering remains optional coverage |
| Script base + PreClass native shadow was represented inconsistently | Fixed as two orthogonal sealed relations: script `derivedFrom` versus native `shadowType`; Sema, verifier, detached registration and prepared authentication now agree |
| Builder Seal collapsed verifier failures to `-17` with no useful message | Fixed by formatting the exact verifier result and compact node/path diagnostic before the rejected graph is destroyed |

## Merge and completion status

The current slice is verified but not yet committed. Plugin source/test changes
and parent OpenSpec records are both dirty. When a deliberate checkpoint is
requested, commit the plugin submodule first, then the parent gitlink and
OpenSpec records. Do not archive the change or claim product-default readiness
until the remaining cutover and final matrix gates are complete.

The formal count remains **102/136 = 75.0%** because CTA-S88 through CTA-S98 are evidence under
the still-open family-wide 7.2/7.4 rows rather than a reason to prematurely
check either umbrella task. After the CTA-S88 and audit attachments were
written, strict OpenSpec validation and both parent/plugin diff checks passed.
After the CTA-S89 final attachment write, strict validation passed again and
both parent/plugin `git diff --check` exited zero; their only output was the
repository's existing LF-to-CRLF checkout warnings.

CTA-S90 now has valid direct, prepared-Builder, direct-import and constructor-
factory RED-to-GREEN evidence. CTA-S91 closes central Runtime-default ownership
and projection, including the registered-native factory type-name call plan;
CallArguments is **10/10**. CTA-S92 closes the adjacent constructor formal
relation, Sidecar V11 persistence, Parser reference-object `AUTO_HANDLE`, Cache
global current-module authority and PreClass `Super::` native-shadow ambiguity.

CTA-S98 closes the remaining reachable CTA-S90 derived-funcdef
producer/consumer relation. Unsupported-family breadth, production-entry scans
and final cutover matrices keep the conservative
non-Standalone overall estimate at **93%**, architecture-weighted implementation
at approximately **98%**, and safe default-cutover readiness at approximately
**92%**. Formal task completion
remains **102/136 = 75.0%** until the family-wide umbrella rows have complete
evidence. The product default remains LEGACY and the original native AST is
retained intentionally; HIR remains absent.

Fresh stopping-point verification:

- latest implementation build: PASS at
  `Saved/Build/cta-s92-hotreload-diagnostic-expectation-build-20260830/20260830_163609_987_f432895d`;
- SemaAuthority: **457/457 PASS** at
  `Saved/Tests/cta-s92-super-sema-authority-full-green-20260830/20260830_161843_468_13d7a77c/Report/index.json`;
- Frontend CanonicalAST: **183/183 PASS** at
  `Saved/Tests/cta-s92-frontend-canonicalast-final-green-20260830/20260830_152639_587_a0642b0c/Report/index.json`;
- ProductionCodeGen: **168/168 PASS** at
  `Saved/Tests/cta-s92-production-codegen-final-green-20260830/20260830_152602_619_c373de1e/Report/index.json`;
- Compiler CanonicalAST: **672/672 PASS** at
  `Saved/Tests/cta-s92-compiler-canonicalast-final-green-20260830/20260830_152837_724_6725fd4c/Report/index.json`;
- ASTBodySidecar V11: **25/25 PASS** at
  `Saved/Tests/cta-s92-astbodysidecar-v11-full-green-20260830/20260830_154008_648_79e2ec06/Report/index.json`;
- Cache: **585/585 PASS** at
  `Saved/Tests/cta-s92-cache-v11-super-full-green-20260830/20260830_161926_505_ec756f82/Report/index.json`;
- Module: **65/65 PASS** at
  `Saved/Tests/cta-s92-module-snapshot-regression-20260830/20260830_163156_522_6913d039/Report/index.json`;
- Hot Reload: **134/134 PASS** at
  `Saved/Tests/cta-s92-hotreload-full-green-20260830/20260830_163742_094_9af69e89/Report/index.json`.
- CTA-S97 ProjectGeneration Engine: **40/40 PASS** at
  `Saved/Tests/cta-s97-generation-engine-green/20260830_195139_849_bca187c8/Report/index.json`;
- CTA-S97 complete TypedASTJIT: **56/56 PASS** at
  `Saved/Tests/cta-s97-typed-ast-jit-green/20260830_195706_790_85417418/Report/index.json`;
- CTA-S97 Compiler CanonicalAST + ProjectGeneration Engine + TypedASTJIT +
  NativeBridge: **779/779 PASS** at
  `Saved/Tests/cta-s97-frozen-signature-final-regression/20260830_195920_029_55f09360/Report/index.json`.
- CTA-S98 focused derived-funcdef relation: **1/1 PASS** at
  `Saved/Tests/cta-s98-derived-funcdef-focused-green/20260830_202918_330_55f084e5/Report/index.json`;
- CTA-S98 SemaAuthority: **458/458 PASS** at
  `Saved/Tests/cta-s98-sema-authority-full-green/20260830_203001_171_7341344c/Report/index.json`;
- CTA-S98 complete native SDK Compiler: **798/798 PASS** at
  `Saved/Tests/cta-s98-native-compiler-full-green/20260830_203057_000_4ec043cf/Report/index.json`;
- CTA-S98 complete Cache: **585/585 PASS** at
  `Saved/Tests/cta-s98-cache-full-green/20260830_203148_759_46a9fb5c/Report/index.json`;
- CTA-S98 complete TypedASTJIT: **56/56 PASS** at
  `Saved/Tests/cta-s98-typed-ast-jit-full-green/20260830_204642_992_cb045361/Report/index.json`;
- CTA-S98 Compiler CanonicalAST + ProjectGeneration Engine + TypedASTJIT +
  NativeBridge: **780/780 PASS**, zero failures/skips, at
  `Saved/Tests/cta-s98-derived-funcdef-final-regression/20260830_204911_328_d22c4771/Report/index.json`;
- CTA-S98 complete native SDK Module: **65/65 PASS** at
  `Saved/Tests/cta-s98-native-module-full-green/20260830_205650_554_aa366d59/Report/index.json`.
