# Canonical call-argument provenance and ABI-consumption gate — 2026-08-30

## Status

CTA-S72 is a completed and verified non-Standalone semantic-authority slice.
It was developed RED-first and closes the gap between Sema's selected call
plan and Canonical Bytecode's Runtime ABI consumption for positional, named,
default, hidden and implicit-mixin-receiver arguments.

The current source compiler already selects the exact callee, arranges
arguments into formal slots, converts them, stores `CallExpr.children` in
reverse-formal order and emits production Bytecode without invoking
`asCCompiler`. The missing contract is that the reason and exact formal owner
of each stored argument are not first-class sealed facts. Named/default/hidden
provenance is currently visible mainly through diagnostic `literal` spellings,
while `EmitCall()` still pairs children with formal parameters by parallel
array position.

This slice does not change the product default, remove the native AngelScript
AST, recreate HIR, adapt Standalone, or claim complete Tasks 5.3, 9.5, 10.3,
13.2 or 13.6.

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S72 — sealed call-argument provenance, exact formal identity and mechanical ABI consumption |
| Sema owner | `ArrangeCallArguments`, `ConvertCallArgumentsToFormalTypes`, `asCSema::ActOnCall` and deferred-call reconciliation |
| Canonical fact | one immutable argument record per formal child, stored in the same reverse-formal order as `CallExpr.children` |
| Required fields | final expression ID, formal ordinal, exact parameter `DeclId` where the selected declaration owns one, origin, optional authored name, authored source ordinal and source range |
| Origins | positional, named, default, hidden, implicit mixin receiver and Sema-generated internal argument |
| Receiver rule | an ordinary method receiver stays on the dedicated receiver edge and is not a Runtime formal record; a mixin receiver is formal zero and has an explicit implicit-receiver record |
| Verifier rule | every resolved publishable call has a complete one-to-one formal-slot mapping; record expression/order/formal/origin/name/source facts must agree with the selected callee and call children; indirect funcdef calls use an explicit ordinal because their resolved variable/parameter is not the owner of invocation ParamDecls |
| CodeGen rule | `EmitCall()` resolves each sealed formal through the record's exact `DeclId`; Runtime parameter arrays authenticate ABI compatibility but do not reconstruct source-level argument meaning |
| Persistence | Sidecar V9 preserves the pointer-free records and includes them in structural identity; V8 is rejected as an ordinary previous-schema miss |
| Public ABI | Public AST V1 remains unchanged; this is an internal Frozen/Publishable compiler fact until a separately justified append-only public revision exists |
| Excluded | Standalone-specific source/CMake/tests, Cache V2 enablement, HIR, dump-as-input, final default cutover and general Runtime signature-shell projection |

## Authenticated root cause to reproduce

### 1. Provenance is encoded as presentation text

`ArrangeCallArguments()` currently rewrites authored literals to forms such as
`named:b=2` and synthesized literals to `default:7` or `hidden:4`. Those strings
are useful diagnostics, but they do not identify the exact formal declaration,
cannot express authored source order independently of stored order, and must
not become a backend protocol.

Deleting or changing those strings should not alter CodeGen semantics. A
sealed call plan therefore needs typed records independent of dump spelling.

### 2. Child position and Runtime shell position are still paired implicitly

`asCBytecodeCodeGen::EmitCall()` collects Canonical parameter declarations but
then chooses both the sealed and Runtime formal with
`formalCount - 1 - childIndex`. That is correct only if all upstream rewrites,
generated arguments, receiver handling and Runtime shell normalization stay in
perfect positional lockstep. The AST does not currently authenticate that
assumption.

A forged graph can exchange two same-typed formal meanings without producing a
dangling ID, wrong arity or type mismatch. The verifier must reject that graph
before detached emission, and CodeGen must consume the authenticated exact
formal edge rather than reproduce the positional rule independently.

### 3. Sidecar round trip cannot reconstruct authored provenance

Sidecar V8 stores the call's callee, receiver, literal, dispatch and expression
children. It cannot reconstruct whether an equal-valued child was authored,
named, defaulted or hidden, nor the exact authored source ordinal. Re-parsing a
literal prefix would make diagnostics a compilation input and is forbidden.

CTA-S72 therefore records a required semantic fact that is otherwise lost and
meets the recorded condition for an append-only Sidecar schema bump.

## Locked internal representation

Each `asCExpr` may own an array of `asSASTCallArgument` records. The array is
non-empty only for `asAST_EXPR_CALL` and is stored in reverse-formal order so
record index `i` corresponds to formal child `children[i]`. Each record owns:

- `expression`: the final converted/wrapped expression used by CodeGen;
- `formalIndex`: the selected callable-signature slot in forward-formal order;
- `formal`: the exact snapshot-local `ParamDecl` selected by Sema for direct
  declaration calls, or invalid only for an authenticated indirect funcdef
  call whose variable/parameter target owns no invocation ParamDecls;
- `origin`: one typed enum value, never inferred from `literal`;
- `authoredName`: non-empty only for a named source argument;
- `sourceOrdinal`: source-order ordinal for authored arguments, otherwise the
  explicit synthesized sentinel;
- `range`: the authored expression range or the call range for synthesized
  defaults/hidden values.

The records contain no raw pointer, Engine-local numeric TypeId/FunctionId,
Runtime slot or backend label. Snapshot-local IDs are legal because the array
is owned and serialized by the same AST snapshot; foreign-owner IDs are
rejected on admission and verification.

An ordinary method's non-formal receiver remains solely the dedicated
`receiver` edge plus its established compatibility child. It is excluded from
`callArguments`. A mixin receiver is a real declared formal and receives an
`IMPLICIT_RECEIVER` record. Existing internal Sema-generated calls that do not
come from authored call syntax receive `GENERATED`; they still bind an exact
formal and cannot bypass completeness verification.

An indirect funcdef call is the only invalid-`formal` exception: its
`resolvedDecl` is a callable variable or parameter rather than the declaration
that owns the funcdef's invocation parameters. Such a record still carries an
exact `formalIndex`; verifier and CodeGen authenticate that ordinal against the
sealed funcdef type/signature. Direct function/method/mixin/import/native and
lambda calls must carry exact `ParamDecl` IDs. Runtime wildcard `?` TypeId
projections remain backend-generated ABI operands and are not extra Canonical
source arguments.

## Risk-clustered TDD matrix

All permanent tests are added before production implementation and are run in
one compile/RED cluster rather than one UE process per assertion.

| Test | Production mutation caught | Required RED |
|---|---|---|
| `DefaultArgumentSealsExactFormalAndOrigin` | dropping the default argument's exact parameter edge or relabeling it authored | missing structured record/API at compile RED, then absent/wrong record at SemaAuthority RED |
| `NamedArgumentsSealAuthoredOrderAndFormalSlots` | deriving named binding from reverse child order or diagnostic literal text | missing authored name/source ordinal/exact formal facts |
| `HiddenArgumentSealsExactFormalAndOrigin` | accepting an authored child in the Runtime hidden slot | missing hidden origin/exact hidden formal fact |
| `RejectsCallArgumentFormalMismatchAndDuplicateFormal` | verifier accepts exchanged or duplicate formal identities with valid same-typed children | publication verification unexpectedly succeeds |
| `SidecarRoundTripPreservesCallArgumentProvenance` | encode/decode drops origin/name/source order/formal edge or identity hash ignores it | round-trip/shadow comparison or mutation hash unexpectedly agrees |
| `CanonicalDefaultNamedAndHiddenCallsExecuteAuthenticatedPlans` | CodeGen uses Runtime positional inference or invokes LEGACY despite a sealed plan | wrong execution/publisher/invocation result; forged plan reaches emission instead of failing closed |

The first compile RED is valid because the wished-for internal AST record and
context mutation API do not yet exist. After the smallest data-model skeleton
compiles, the same permanent tests must still produce behavioral REDs for
missing Sema population, verifier admission, Sidecar preservation and CodeGen
consumption before those production layers are changed.

## RED chronology

### RED 1 — missing structured contract, authenticated

Command:

```powershell
Tools\RunBuild.ps1 -Label cta-s72-call-argument-red-compile -TimeoutMs 1800000 -NoXGE
```

Result: **expected failure**, 2026-08-30. Evidence:
`Saved/Build/cta-s72-call-argument-red-compile/20260830_030016_490_1f272525`.

The added test translation units entered UBT successfully. Compilation then
failed on the intended missing production contract:

- `asSASTCallArgument` was undeclared;
- `asAST_CALL_ARGUMENT_*` origins and the no-source-ordinal sentinel were
  undeclared;
- `asCExpr::callArguments` did not exist;
- `asCASTContext::AddCallArgument()` did not exist.

No Sema, verifier, Sidecar or CodeGen implementation had been changed before
this RED. The next permitted implementation step is therefore only the typed
record, expression storage and ownership-preserving Context admission API.

### RED 2 — missing semantic population and consumers, authenticated

After the minimum record/storage API compiled, the permanent tests produced
three independent behavior RED clusters on 2026-08-30:

- Compiler CanonicalAST: `629/633 PASS`, four expected failures. Default,
  named and hidden calls had no structured records, while the hidden-middle
  named fixture failed before arrangement. Evidence:
  `Saved/Tests/cta-s72-call-argument-red-compiler/20260830_030432_745_cf458a16`.
- Frontend CanonicalAST: `175/178 PASS`, three expected failures. Publication
  accepted a wrong formal, a duplicate formal and the corresponding CodeGen
  transaction. Evidence:
  `Saved/Tests/cta-s72-call-argument-red-frontend/20260830_030535_707_814b99a4`.
- Cache ASTBodySidecar: `23/24 PASS`, with only the structured call-argument
  round trip missing. Evidence:
  `Saved/Tests/cta-s72-call-argument-red-sidecar/20260830_030611_504_ea1207c3`.

The hidden-middle fixture exposed a prerequisite Sema bug rather than a
CodeGen failure. For the Runtime declaration
`NativePack(int A, int Hidden, int C)` with hidden formal one defaulting to
`7`, source `NativePack(C: 3, A: 1)` reached overload ranking as source-order
expressions `[3, 1]`. `FindBestCallee()` did not receive names and ranked them
positionally as `[A, Hidden]`, then rejected the required `C` formal as
missing. `ArrangeCallArguments()` therefore never had a chance to construct
the valid `[A=1, Hidden=7, C=3]` plan.

The root fix is a pure, non-mutating source-to-formal plan shared with
candidate ranking. It reserves hidden formals before positional assignment,
binds names before type ranking, distinguishes an ordinary method receiver
from a mixin formal-zero receiver, and treats default/hidden omissions as
candidate-valid without creating AST nodes. The focused production fixture
then passed `2/2`, including native result `173`, with the CANONICAL publisher
and zero LEGACY compiler invocations:

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.CallArguments" `
  -Label cta-s72-call-binding-plan-green `
  -TimeoutMs 900000
```

Evidence:
`Saved/Tests/cta-s72-call-binding-plan-green/20260830_031336_423_ba657cf9`.
This closes only candidate viability. Sema record population, publication
verification, Sidecar V9 and mechanical CodeGen consumption remain RED.

### Sema population checkpoint — build GREEN, focused regression still RED

The first Sema-population implementation now shares the pure binding plan
with selected-callee arrangement, stores final converted expression IDs,
exact formal declaration IDs, origin, authored name/source ordinal and range,
and keeps ordinary receivers outside the formal-record array. The Runtime,
Editor and Test build passed all `171` actions:

`Saved/Build/cta-s72-sema-provenance-build/20260830_031654_828_fc677533`.

The complete focused SemaAuthority cluster then finished `425/436 PASS` with
`11` failures rather than a false GREEN:

`Saved/Tests/cta-s72-sema-provenance-focused/20260830_031928_324_9216c66f`.

Static inspection and the read-only subagent audit refined the failures into
three root-cause groups:

- four stale presentation assertions: default, named and two qualified-named
  fixtures still expected Sema to rewrite expression `literal` text. Their
  actual structured `callArguments` were already correct; the tests and dump
  must inspect those records instead of restoring semantic literal mutation;
- six indirect funcdef/lambda fixtures: an indirect `VAR`/`PARAM` callable has
  a Runtime funcdef signature but no shared Canonical formal-signature view,
  so the direct-declaration binding helper reported
  `call-argument-plan-invalid`;
- one real lookup regression: receiver-bearing syntax such as `v.Get(3)` could
  discard the receiver while considering a same-named free function, allowing
  a false same-arity candidate. Qualified named-call binding itself was not a
  semantic regression once its structured records were inspected directly.

This checkpoint proves that the record layout and direct production execution
are viable, but the Sema population step is not complete. No task is checked
off and no plugin/parent commit is permitted until the regression cluster is
green. The fix must add a callable-signature view for indirect funcdefs,
close receiver/free-function fallback, and render structured provenance for
diagnostics; it must not restore semantic `literal` parsing.

### Sema population and structured dump GREEN

The follow-up implementation keeps one pure binding plan for overload
viability, selected-callee arrangement and conversion. For direct calls each
record owns the exact `ParamDecl` plus its canonical type. For indirect
`VAR`/`PARAM + FUNCDEF` calls, Sema first uses a unique matching Canonical
`FuncDefDecl` when present; otherwise it reads the transient Runtime funcdef
signature and immediately projects each parameter through
`FromScriptParameterABI()` into a pointer-free Canonical `formalType` and
`formalIndex`. It does not synthesize a foreign `ParamDecl`.

Receiver treatment is now candidate-specific: an ordinary method receiver is
outside the formal array, a mixin receiver is formal zero, and a receiver
cannot be silently removed when evaluating a free-function candidate. The AST
dump renders `callArgs` and each record's expression, formal/formal index,
formal type, origin, source ordinal and authored name; it remains diagnostic
output and is not a compiler input.

The full Editor build passed `171/171` actions:

`Saved/Build/cta-s72-callable-formal-view-build/20260830_033035_394_89126c0e`.

The complete SemaAuthority risk cluster then passed `436/436`:

`Saved/Tests/cta-s72-callable-formal-view-focused/20260830_033308_524_d5592ac6`.

This closes the eleven-failure checkpoint without restoring literal parsing
or expanding Public AST V1.

### Publication verifier GREEN

Two permanent forged-AST tests authenticated that ordinary structural
`Seal()` must retain malformed call facts for diagnostics while
`asCASTVerifyPublication()` rejects them before CodeGen:

- a record whose `formalIndex` claims slot B while its exact declaration is A;
- two otherwise well-formed records claiming the same formal identity.

The initial verifier RED was `51/53 PASS`, with exactly those two tests failing:

`Saved/Tests/cta-s72-call-argument-verifier-red/20260830_033411_029_a5f35816`.

The publication-only verifier now authenticates record/child parallelism,
direct exact formal identity, indirect no-`ParamDecl` identity, unique formal
ordinals, and valid/equal canonical formal types. The incremental Runtime and
test builds passed, followed by `53/53 PASS`:

- `Saved/Build/cta-s72-call-argument-verifier-build/20260830_033553_187_3a36aff3`;
- `Saved/Build/cta-s72-call-argument-verifier-fixture-build/20260830_033652_054_fab7e496`;
- `Saved/Tests/cta-s72-call-argument-verifier-green2/20260830_033708_606_2087e275`.

The first GREEN attempt reached `52/53`; the remaining duplicate-formal
fixture had omitted the newly mandatory `formalType` from its supposedly
well-formed first record and was correctly rejected earlier as
`call-argument-formal-type`. The fixture was completed rather than weakening
the verifier. Evidence:
`Saved/Tests/cta-s72-call-argument-verifier-green/20260830_033604_411_d0a66d1c`.

At this historical checkpoint, the remaining CTA-S72 work was mechanical
CodeGen consumption of these records, Sidecar V9 round-trip preservation, then
focused/broad non-Standalone gates and commit ordering. No formal OpenSpec
checkbox was claimed by those intermediate gates alone.

One completeness edge remained open for that consumer step: the publication
helper authenticated every present record, but still needed to prove that a
non-zero direct formal set could not publish with an empty or partial
`callArguments` array. The final implementation closes that edge at the same
publication firewall; `EmitCall()` has no positional fallback for incomplete
records.

## Final implementation and GREEN closure

The final non-Standalone implementation now has one authority chain:

1. Sema builds a pure source-to-formal binding plan and seals one immutable
   `asSASTCallArgument` record for every stored formal child.
2. Publication verification rejects missing/partial coverage, wrong or
   duplicate formals, invalid direct/indirect ownership, mismatched canonical
   types, impossible origin/name/source-ordinal combinations, duplicate source
   ordinals and receiver-shape drift.
3. `EmitCall()` reads the authenticated record expression, formal index,
   exact direct formal or indirect canonical type, and uses Runtime parameter
   arrays only to authenticate/project the current Engine ABI. It does not
   reconstruct source argument meaning from child position or diagnostic
   literal text.
4. Sidecar V9 stores every pointer-free record field, verifies the decoded
   graph before publication, includes the facts in structural identity and
   rejects V8 as an ordinary previous-schema miss.

Permanent verifier coverage includes valid-enum semantic corruption, not only
byte corruption: named arguments require the exact authored formal name and a
source ordinal; positional arguments cannot carry a name; synthesized origins
cannot carry authored source metadata; source-backed ordinals are unique and
bounded; empty and partial formal coverage fail closed.

The `__generated` trait and Cache restore work performed in the adjacent slice
exposed one prepared-dispatch regression after CTA-S72 was otherwise green. A
source-declared `__generated` method already had a Stage 2 Runtime shell but was
omitted from the expected method inventory. The preflight now defers only a
generated method without an exact prepared binding. This preserves strict
dispatch graph equality and is recorded in
`cta-s72-cache-staticclass-canonical-rebuild-progress-2026-08-30.md`.

Final evidence:

```text
Saved/Build/cta-s72-generated-method-dispatch-green-build/20260830_055706_228_a7828365
Result: Succeeded

Saved/Tests/cta-s72-compiler-canonical-full-green2/20260830_055753_393_d0744e2a
Compiler.CanonicalAST: 634/634 PASS

Saved/Tests/cta-s72-frontend-canonical-full-green/20260830_055835_628_06315015
Frontend.CanonicalAST: 181/181 PASS

Saved/Tests/cta-s72-cache-full-green/20260830_054157_730_86347fca
Cache: 584/584 PASS
```

This completes the CTA-S72 call-argument gate, but Task 5.3 and the aggregate
cutover tasks remain open: constructor provenance, the complete import/mixin/
native/call-family matrix, remaining lifetime/control forms, default selection
and final All-suite evidence are not claimed here.

## Expected source fixtures

### Default

```angelscript
int F(int A, int B = 7)
{
    return A * 10 + B;
}

int Entry()
{
    return F(3);
}
```

The final stored children are reverse-formal, but their records bind exact
`B`/`A` parameter declarations. `B` is `DEFAULT`; `A` is authored positional.
Execution returns `37`.

### Named

```angelscript
int F(int A, int B)
{
    return A * 10 + B;
}

int Entry()
{
    return F(B: 2, A: 1);
}
```

The source ordinals remain `B=0`, `A=1` while stored record order is formal
`B`, formal `A`. Execution returns `12`, never `21`.

### Hidden native parameter

The existing generic native fixture registers
`int MetadataHidden(int Visible, int Hidden)`, sets
`hiddenArgumentIndex=1` and `hiddenArgumentDefault=4`, and calls
`MetadataHidden(3)`. The native observer must receive `(3, 4)` and return `34`.
The second record is exact formal `Hidden` with origin `HIDDEN`.

## Required verification before GREEN is recorded

1. one test-only compile RED naming the absent structured contract;
2. one focused SemaAuthority/verifier/Sidecar/ProductionCodeGen RED with the
   expected failures after the data-model skeleton compiles;
3. Runtime/Editor/Test build;
4. focused SemaAuthority, Frontend verifier, Cache ASTBodySidecar and complete
   ProductionCodeGen GREEN;
5. complete Compiler CanonicalAST and Frontend CanonicalAST regressions;
6. static scans proving no `literal` prefix parsing in verifier/CodeGen and no
   `asCCompiler` use on the CANONICAL path;
7. `openspec validate`, parent/plugin `git diff --check`, plugin commit first,
   then parent OpenSpec/gitlink commit.

## Non-claims

- This does not finish all call forms, containers, exceptions, suspension or
  the complete lifetime matrix.
- This does not retire `GetParsedFunctionDetails()` from CANONICAL Stage 2;
  Runtime signature-shell projection remains the adjacent CTA-S72B boundary.
- This does not change Public AST V1 or make Cache V2 production-default.
- This does not make CANONICAL the product default or remove LEGACY.
- The native Parser AST remains for explicit LEGACY, syntax/recovery,
  differential testing and reference.
- HIR remains physically absent, and dumps remain diagnostics only.
- Standalone remains deferred and receives no adaptation or claimed gate.
