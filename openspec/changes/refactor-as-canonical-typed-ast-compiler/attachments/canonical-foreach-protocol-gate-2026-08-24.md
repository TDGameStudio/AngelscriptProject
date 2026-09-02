# Canonical foreach protocol gate — 2026-08-24

## Outcome

The source `foreach` path now preserves a first-class `asAST_STMT_FOREACH`
node while Sema seals the complete resolved protocol and source-order control
phases into the canonical AST. Production Canonical CodeGen consumes those
already-resolved phases without invoking the legacy compiler or rediscovering
the protocol methods.

This is a focused control-flow and protocol-lookup closure. It advances Tasks
5.6, 5.9, 9.5, 13.2, and 13.6, but does not complete any of those full-language
umbrella tasks.

## Architecture decision

Before this slice the canonical node retained a syntax-shaped range and body:

```text
ForEach
  expr     = Range
  children = [source variables, source body]

CodeGen or another consumer would still have to know how foreach works.
```

The sealed form is now:

```text
.as source foreach (Value : Range)
               |
               v
        incremental Parser
        (recovery syntax may remain)
               |
               v
              Sema
               |
               +-- evaluate Range once -> OpaqueValue receiver
               +-- init: generated Iterator = Range.opForBegin()
               +-- cond: !Range.opForEnd(Iterator)
               +-- body: Value = Range.opForValue(Iterator)
               |         + authored source body
               +-- incr: Range.opForNext(Iterator)
               |
               v
        sealed ForEach AST
          children[0] = init
          expr        = condition
          children[1] = body
          children[2] = increment
               |
               +-- AST dump names init=/body=/incr=
               |
               v
       Canonical Bytecode CodeGen
          reuses structured EmitFor
               |
               v
           VM result = 41
       legacy compiler calls = 0
```

The four protocol calls carry exact resolved callees and share the same
`asAST_EXPR_OPAQUE_VALUE` receiver. This is the semantic single-evaluation
fact; the backend is forbidden to reconstruct it from method names. The
generated iterator has the `GENERATED` trait and the stable diagnostic prefix
`__foreach_iterator_`.

## AST-first gate card

### Source fixture

The fixture declares `FCanonicalForeachRange` with:

- `opForBegin()` returning iterator `0`;
- `opForEnd(int)` ending at iterator `2`;
- `opForNext(int& inout)` advancing with `Iterator = Iterator + 1`;
- `opForValue(int)` returning `20 + Iterator`;
- `CanonicalForeachSum()` summing the two values and returning `41`.

The permanent AST-first test is
`SourceForeachSealsResolvedProtocolPlanBeforeCodeGen` in
`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`.

It asserts all of the following before execution evidence is counted:

- the retained context is sealed;
- exactly one source `ForEach` node exists;
- its three children are the ordered init, body, and increment phases;
- the debug dump names `init=`, `body=`, and `incr=` and does not describe the
  sealed node with the retired syntax field `vars=`;
- iterator initialization is an exact call to resolved `opForBegin`;
- the condition is an exact unary `!` over resolved `opForEnd`;
- the source value declaration is initialized by resolved `opForValue`;
- the increment statement is an exact call to resolved `opForNext`;
- all four calls share one exact opaque receiver;
- every reference to `Value`, including incremental-Parser placeholders, is
  rebound to the exact source value declaration.

### AST RED and GREEN

1. `cta-foreach-sema-red-group` built successfully, then produced **272/273
   PASS**. The new test failed because `ForEach` still exposed `expr=Range`
   and syntax children `variables/body`.
   Report: `Saved/Tests/cta-foreach-sema-red-group/20260824_225804_816_810dfeb6`.
2. The first Sema implementation exposed a same-source-range interning bug:
   convenience actions reused the `opForBegin` call as unary condition and
   reused the iterator initialization assignment as increment assignment.
   The repair uses the exact unary and assignment construction actions for
   these generated semantic nodes instead of range-deduplicating wrappers.
3. Focused AST GREEN:
   `Saved/Tests/cta-foreach-sema-green2/20260824_230603_231_dbc1cc16`,
   **1/1 PASS**.
4. After the dump contract was added, `cta-foreach-debug-dump-red` failed
   exactly because the dump still printed syntax-shaped `vars/body`.
   Report: `Saved/Tests/cta-foreach-debug-dump-red/20260824_231450_542_82755a9f`.
5. Final focused AST/debug GREEN:
   `Saved/Tests/cta-foreach-sema-final-focused/20260824_231558_856_98c1eaa7`,
   **1/1 PASS**.
6. Complete SemaAuthority regression:
   `Saved/Tests/cta-foreach-sema-regression/20260824_231644_847_65b07eb8`,
   **273/273 PASS**.

## CodeGen and publisher gate

The permanent execution test is
`CanonicalForeachExecutesSealedProtocolWithoutLegacyCompiler` in
`AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`.

It explicitly selects the CANONICAL pipeline, builds the source, executes
`CanonicalForeachSum() == 41`, requires publisher
`asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, and requires
`GetLastLegacyCompilerInvocationCount() == 0`.

The diagnostic sequence was intentionally kept because it separated three
different ownership gaps:

1. `cta-foreach-codegen-red` failed before CodeGen with
   `unresolved-identifier:Value`. The incremental Parser had parsed the body
   reference before the foreach source declaration existed. Sema now rebinds
   only matching unresolved `Value` placeholders within the exact authored
   body source range and removes only the corresponding stale diagnostic.
   Unrelated unresolved identifiers remain fail-closed.
2. `cta-foreach-codegen-red2` reached an unrelated primitive-reference
   increment limitation when the fixture used `Iterator++`. The fixture was
   narrowed to the already-supported, semantically equivalent
   `Iterator = Iterator + 1`; this gate does not claim reference inc/dec
   support.
3. `cta-foreach-codegen-red3` then failed exactly in the `EmitStmt` default for
   `asAST_STMT_FOREACH`. This was the desired backend RED: the graph was green,
   but the canonical backend did not yet consume it.
4. Adding one lowering route from sealed `ForEach` to the existing structured
   `EmitFor` made the focused production test green:
   `Saved/Tests/cta-foreach-codegen-green/20260824_231319_213_c27ad224`,
   **1/1 PASS**.
5. Complete ProductionCodeGen regression:
   `Saved/Tests/cta-foreach-codegen-regression/20260824_231725_860_4b60b27a`,
   **81/81 PASS**.

The final build used the project wrapper and passed:
`Saved/Build/cta-foreach-debug-dump-green-build/20260824_231544_991_c596d315`.

## Keyed protocol extension

The follow-up slice extends the same sealed control shape to the language's
two-declaration form:

```text
foreach (Value, Key : Range)
  init: Iterator = Range.opForBegin()
  cond: !Range.opForEnd(Iterator)
  body:
    Value = Range.opForValue(Iterator)
    Key   = Range.opForKey(Iterator)
    authored body
  incr: Range.opForNext(Iterator)
```

The permanent AST-first test is
`SourceKeyedForeachSealsBothDeclarationsAndResolvedKeyProtocol`. The RED at
`Saved/Tests/cta-keyed-foreach-sema-red/20260824_233109_644_493e6a3e`
proved the exact ownership bug: Parser and declaration Sema had created the
`Key` declaration, but both foreach syntax walks retained only the first
declaration. The sealed body therefore contained only the value declaration,
`Key` references remained unresolved, and no `opForKey` call existed.

Sema now carries the second declaration through both parser-recovery entry
points, resolves exact `opForKey(iterator)`, records the key declaration's
initializer fact, emits the key assignment in source order, and applies the
same exact-body-range placeholder rebinding used by the value declaration.
All five protocol calls share the same opaque receiver. Focused AST GREEN:
`Saved/Tests/cta-keyed-foreach-sema-green/20260824_233609_674_b34cfd91`
(**1/1 PASS**).

The permanent production test is
`CanonicalKeyedForeachExecutesSealedKeyProtocolWithoutLegacyCompiler`. It
executes `(2*10+7)+(3*10+8) == 65`, requires publisher
`CANONICAL_CODEGEN`, and requires zero legacy compiler invocations. It passed
without a new backend branch: the existing sealed `ForEach -> EmitFor` route
was already general enough. Focused execution GREEN:
`Saved/Tests/cta-keyed-foreach-codegen-gate/20260824_233818_668_d5339b55`
(**1/1 PASS**).

Final focused-group regressions:

- SemaAuthority **274/274 PASS** at
  `Saved/Tests/cta-keyed-foreach-sema-regression/20260824_233858_789_ea51c15e`;
- ProductionCodeGen **82/82 PASS** at
  `Saved/Tests/cta-keyed-foreach-codegen-regression/20260824_233940_584_b124763e`.

The complete Compiler CanonicalAST gate initially produced **388/389 PASS**.
The only failure was the older generated-accessor field-offset negative, whose
expectation predated the stronger `class-field-layout` Seal firewall. The test
was aligned to assert the exact verifier node/edge/detail and the CodeGen
`UNSEALED_PUBLICATION` refusal; no production verifier or foreach behavior was
weakened. The final broad gate is **389/389 PASS** at
`Saved/Tests/cta-keyed-foreach-canonicalast-green/20260824_234903_919_e1766cc0`.
The contract evolution is recorded in
`attachments/wave-b-field-offset-fail-closed.md`.

The flat/structured diagnostic graph exposes the retained `Key` declaration,
its exact `opForKey` callee, both value/key assignments, and the named
`init/body/incr` phases. This makes a missing key declaration, unresolved body
reference, wrong protocol callee, and backend execution defect distinguishable
without first reading VM bytecode.

## Debugging value

The AST dump now makes an incomplete and a consumer-ready foreach graph
visually distinct:

```text
syntax/recovery fallback: ForEach ... vars=<id> body=<id>
sealed canonical plan:    ForEach ... init=<id> body=<id> incr=<id>
```

When a future failure occurs, this supports a fast first split:

- `vars=` means the protocol could not be sealed and Sema/diagnostics own the
  investigation;
- `init=/body=/incr=` with wrong callees or receiver identity means Sema facts
  are malformed;
- a correct sealed dump plus execution failure means CodeGen/VM lowering owns
  the investigation.

## Scope and non-claims

This slice originally proved the one-value and two-declaration value/key
foreach forms with primitive/enum iterator protocol values. The 2026-08-25
extension below additionally proves exact lifetime cleanup for a value-object
iterator. It does **not** claim:

- generic container/template coverage;
- reference `++`/`--` support;
- complete HIR control-test migration;
- all-language Canonical CodeGen coverage;
- default-pipeline cutover or physical HIR removal.

Cache V2 is default-disabled and scheduled for redesign. No Cache V2 test or
restore claim is part of this gate, and Cache V2 is not a completion condition
for this semantic slice.

## 2026-08-25 extension: value-object iterator lifetime

The object-iterator extension closes a materially different semantic boundary.
A primitive iterator only needs an init/body/increment plan; a value-object
iterator also owns live storage whose exact destructor must run once when the
loop lifetime ends, including structured transfers out of the loop.

```text
authored foreach
      |
      v
Sema resolves one opaque range receiver
      |
      +-- init:    generated Iterator = exact opForBegin()
      +-- cond:    !exact opForEnd(Iterator)
      +-- body:    Value = exact opForValue(Iterator) + authored body
      +-- incr:    exact opForNext(Iterator)
      `-- cleanup: exact ~Iterator(), literal=scope-exit
                       |
                       v
                verifier firewall
                       |
                       v
       CodeGen structured transfer cleanup
          natural exit / break / return / nested transfer
                       |
                       v
               common epilogue cannot destroy twice
```

### AST-first authority

The permanent source test is
`SourceObjectIteratorForeachSealsExactLifetimeCleanupPlan`. It requires the
retained source-built graph to contain a generated value-object iterator, the
exact resolved and materialized `opForBegin` result, and a fourth ordered
cleanup phase. That phase must be an expression statement containing a
`Cleanup` expression whose:

- literal is exactly `scope-exit`;
- sole target is a `DeclRef` to the generated iterator declared by the init
  subtree;
- `resolvedDecl` is the exact destructor of the iterator's owning class;
- debug dump is explicit as `cleanup=<id>`.

This exposed a retained-LEGACY-snapshot defect that was independent of legacy
Bytecode emission. The LEGACY build path compiled old Bytecode and then
published a Canonical AST without running the Canonical layout/lifecycle
finalization used by the canonical path. The result was a sealed half-product:
classes had no final layout and could not safely carry storage-copy/lifetime
traits. The retained comparison snapshot now calls `SealCanonicalAST()` before
publication. This finalizes and verifies the Canonical AST but does not route
LEGACY Bytecode through Canonical CodeGen.

Sema now computes the conservative public trait
`asAST_TRAIT_TRIVIAL_STORAGE_COPY`. It is present only when exact byte storage
copy is semantically valid: no authored non-trivial copy constructor,
assignment, or destructor; no unsupported embedding prefix; trivial base; and
only primitive/enum, native POD, or recursively proven trivial value fields.
The trait permits copying already-live values. It never suppresses required
construction or destruction.

### Verifier and CodeGen firewall

The verifier accepts exactly three foreach phases for an iterator with no
scope-exit action, or four phases when the fourth is the exact cleanup plan
above. It rejects malformed graphs with stable details including
`foreach-phase-count`, `foreach-cleanup-stmt`, `foreach-cleanup-expr`,
`foreach-cleanup-literal`, `foreach-cleanup-dtor`,
`foreach-cleanup-target`, and `foreach-cleanup-type`.

`VerifierRejectsForgedForeachScopeExitCleanupLiteral` is the permanent
hand-built negative test. It forges the fourth phase and proves the graph is
rejected as `asAST_VERIFY_INVALID_CHILD` with detail
`foreach-cleanup-literal` before CodeGen can consume it.

Two Parser-action tests deliberately use the non-executable syntax fixture
`foreach (int x : intValue)` only to verify callback ordering and node
deduplication. They now explicitly assert the verifier's
`foreach-phase-count` rejection instead of pretending that this unresolved
syntax-shaped graph is backend-ready. Real primitive and object protocol
sources remain separately sealed and executed.

Production CodeGen consumes the sealed storage-copy trait for every
value-object copy, including one-dword values; small structs no longer bypass
the semantic firewall through a raw `CopyVar`. It tracks whether owned storage
is still live, emits the exact iterator destructor on natural exit and every
transfer that crosses the lifetime (`break`, `return`, and nested-loop exits),
and retires that storage so the common function epilogue cannot destroy it a
second time. `continue` remains inside the iterator lifetime and therefore
does not run the scope-exit cleanup.

The permanent production test is
`CanonicalObjectIteratorForeachExecutesSealedScopeExitCleanup`. It selects the
CANONICAL pipeline, breaks after the first value, calls a following function,
and returns `21`. Besides execution, it asserts the iterator destructor call
appears in Bytecode before that following call and requires canonical
publication with zero legacy compiler invocations.

### Red/green and final regression evidence

- First production RED: the graph reached Canonical CodeGen but non-POD value
  return failed the old POD-only copy route —
  `Saved/Tests/cta-object-iterator-codegen-red/20260825_001817_170_e39c9422`.
- Second production RED: storage copy succeeded, but the destructor appeared
  after the first post-loop call (`52` versus `46`) —
  `Saved/Tests/cta-sealed-storage-copy-codegen-red2/20260825_004349_873_cb012395`.
- Focused production GREEN: **1/1 PASS** —
  `Saved/Tests/cta-foreach-scope-exit-codegen-green/20260825_004559_020_8b52cd45`.
- Forged-cleanup verifier RED: the new negative assertion failed before the
  verifier firewall was implemented —
  `Saved/Tests/cta-foreach-cleanup-verifier-red/20260825_005029_809_43fee114`.
- Focused verifier GREEN: **1/1 PASS** —
  `Saved/Tests/cta-foreach-cleanup-verifier-green/20260825_005224_970_f80c5888`.
- Final SemaAuthority regression: **276/276 PASS** —
  `Saved/Tests/cta-object-foreach-final-sema-regression-v2/20260825_005713_261_c3ca55df`.
- Final complete Compiler CanonicalAST regression: **392/392 PASS** —
  `Saved/Tests/cta-object-foreach-final-canonicalast-regression/20260825_005755_677_3558cfaf`.
- Final incremental test build: **PASS** —
  `Saved/Build/cta-foreach-action-verifier-test-fix/20260825_005655_771_8512377b`.

Earlier full-group evidence before the final negative test was
SemaAuthority **275/275** and ProductionCodeGen **83/83**. The final broad
CanonicalAST run includes the object-lifetime execution and both verifier
contracts, so it supersedes those counts for this slice.

This extension advances Tasks 5.7, 5.8, 9.5, 13.2, and 13.6, but does not
complete their full-language umbrella requirements. Containers, stored
closures, exceptional cleanup, suspend/resume lifetime, complete transfer
matrices, default cutover, and physical HIR removal remain separate work.
