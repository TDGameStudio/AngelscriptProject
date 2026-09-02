# CTA-S59 — template-qualified parent-type QualType gate

Date: 2026-08-29
Worktree: `D:\as-cta`
Scope: OpenSpec Task 4.3 template-bearing qualified scope and parent-type
lookup only. Standalone remains excluded by the approved deferral.

## Gate card

| Field | Value |
|---|---|
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| RED method | `ParserTemplateQualifiedParentTypeResolvesExactChildFuncdefWithoutDynamicTypeIdIdentity` |
| Real source path | register an application template plus its child funcdef, then parse an ordinary declaration whose type is `TScopedParent<int>::FChild`; flow is `asCParser -> structured QualType syntax action -> asCSema -> asCASTContext` |
| Required Canonical fact | the variable type is `FUNCDEF` with exact stable key `TScopedParent<int>::FChild`; the action preserves the `TScopedParent` scope segment, its `int` template argument, the `::` relationship and the final `FChild` name as indexed owned facts |
| Expected RED | Parser grammar accepts an innermost template scope, but `FormatQualTypeActionBaseSpelling` recursively concatenates the scope leaves without authored angle/scope delimiters; Sema also treats any spelling containing `<` as a template root, so the child type cannot retain its exact kind/identity |
| Production change | extend the short-lived pointer-free QualType action with structured scope-segment metadata and resolve the exact parent instance/child type in Sema before interning the final stable QualType |
| Downstream gates | focused method, complete SemaAuthority, Frontend Parser Declarations, Frontend Type/TypeIdentity/TypeSema, ProductionCodeGen, Module Snapshot and TypedASTJIT |

## Evidence-backed gap

The maintained Parser grammar explicitly permits the innermost `SCOPE`
component to be a template type. `ParseOptionalScope` stores the template name
and each parsed subtype beneath `snScope`, then consumes the following `::`.
LEGACY `GetNameSpaceFromNode` distinguishes this shape from a namespace,
resolves the exact template instance as `parentType`, and
`CreateDataTypeFromNode` looks for the final child type under that parent.

The current Canonical action does not preserve the same structure:

1. `AppendQualTypeActionLeafText` recursively concatenates `snScope` leaves;
   angle brackets are not native child nodes and the template-closing `::` is
   consumed without its own node, so `TScopedParent<int>::FChild` cannot be
   reconstructed faithfully.
2. `asSQualTypeSyntaxNode` describes only the final nominal node and its direct
   template arguments; it has no role/index metadata for qualified scope
   segments or template arguments owned by a scope segment.
3. `ActOnQualType` classifies any text containing `<` as `TEMPLATE` before it
   can bridge an exact Runtime child funcdef. Even a correctly reconstructed
   qualified spelling would therefore receive the wrong type kind.
4. A numeric child TypeId would identify only the current Engine allocation and
   is forbidden as Canonical/snapshot identity. The durable identity must be
   parent stable type key plus child stable name.

## Locked design

1. Parser keeps grammar ownership and copies only recognized source facts into
   owned indexed action values. No `asCScriptNode*`, Builder/Runtime pointer or
   numeric TypeId crosses the action boundary.
2. Every QualType node records whether its scope is absolute and identifies
   each scope segment in source order. A template-bearing segment owns an exact
   indexed subtree for its template arguments; qualifiers remain local to the
   node on which they were authored.
3. Sema validates action topology before resolving types. Wrong indices,
   overlapping/out-of-subtree children, missing template arguments and
   malformed scope layout fail closed with a deterministic diagnostic.
4. Sema resolves the parent template instance first, then the final child type.
   The final Canonical kind comes from the exact resolved child (`FUNCDEF` in
   the gate), not from punctuation in the complete spelling.
5. Stable identity is `TScopedParent<int>::FChild`; current Runtime TypeId and
   object pointers remain transient resolution inputs only.
6. Existing simple namespace-qualified types and root/nested template types
   retain their current semantics. A scope subtype such as `const int` must be
   rejected by the same template-subtype qualifier rules as a root template.
7. Native Parser AST, Builder and `asCCompiler` remain for LEGACY,
   syntax/recovery, differential/reference and rollback use. HIR remains
   physically absent.

## Mutation checks

The permanent gate must fail if a later change:

- flattens `TScopedParent`, `int`, `::` and `FChild` into one Parser spelling;
- interns the final child as `TEMPLATE`, `VALUE_OBJECT` or a bare `FChild`;
- drops the template argument from the parent stable key;
- uses the current numeric TypeId or a Runtime pointer as AST identity;
- promotes a scope-template subtype qualifier to the final child type;
- silently falls back to LEGACY meaning when the structured action is invalid.

## Required evidence ledger

- [x] gate card written before production edits;
- [x] test registration contract and unchanged-production semantic RED proven;
- [x] structured scope action and Sema parent/child resolution implemented;
- [x] focused and complete SemaAuthority GREEN;
- [x] Parser declaration, Frontend Type and downstream consumer regressions
  GREEN;
- [x] source-boundary scans, parent/plugin `git diff --check`, and strict
  OpenSpec validation pass;
- [x] all issues and final non-claims recorded.

## Non-claims

- CTA-S59 does not close Task 4.3. Contextual lambda/funcdef inference,
  fully AST-local template declaration authority and final Builder-adapter
  reconciliation remain.
- It does not implement script templates; this fork's source-level `funcdef`
  rejection boundary remains unchanged.
- It does not close Tasks 4.4-4.6, 5.x, 7.x, 9.x, 10.x, 13.2 or default
  cutover.
- Standalone is neither adapted nor run. Default remains LEGACY; there is no
  production `dual` backend or silent LEGACY fallback.

## TDD / issue ledger

### Registration-contract exploration — not a semantic RED

The permanent test was added before production changes, and both test-only
builds passed. The first two executions nevertheless stopped before parsing or
Canonical Sema because the public `RegisterFuncdef` fixture declaration was
rejected:

1. `void TScopedParent::FChild(T)`
   - test-only build:
     `Saved/Build/cta-s59-template-qualified-parent-red-build/20260829_095625_979_b371b35f`
     — PASS;
   - execution:
     `Saved/Tests/cta-s59-template-qualified-parent-red/20260829_095647_696_bdb1898e`
     — `0/1`, failed at child-funcdef registration.
2. `void TScopedParent<T>::FChild(T)`
   - corrected test-only build:
     `Saved/Build/cta-s59-template-qualified-parent-red-build-correct/20260829_095740_595_77219030`
     — PASS;
   - execution:
     `Saved/Tests/cta-s59-template-qualified-parent-red-correct/20260829_095805_494_53b350c8`
     — `0/1`, failed at
     `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:3741` with
     `template-qualified parent fixture must register its child funcdef`.

These failures are fixture/registration-contract exploration, not accepted TDD
RED evidence: neither run reached the real source declaration, structured
QualType action, or Canonical Sema assertion. They therefore do not satisfy the
second evidence-ledger checkbox and do not advance Task 4.3. No production file
was changed in response.

The maintained fork's
`RegisterFuncdef -> ParseFunctionDeclaration -> GetNameSpaceFromNode ->
GetTemplateInstanceFromNode -> SetTemplateRestrictions` contract was then
traced. That investigation produced the supported zero-argument fixture below;
only its run counts as semantic RED evidence.

### Valid semantic RED

Tracing `SetTemplateRestrictions` established why the second registration
attempt failed: this fork rejects a template subtype passed by value because
the concrete subtype changes the native ABI. That restriction is unrelated to
qualified-type identity. The permanent fixture now registers the zero-argument
child funcdef `void TScopedParent<T>::FChild()`, which exercises the same
template parent/child lookup without introducing that separate ABI boundary.

- test-only build:
  `Saved/Build/cta-s59-template-qualified-parent-red-build-zero-arg/20260829_100347_151_7996fce7`
  — PASS;
- unchanged-production execution:
  `Saved/Tests/cta-s59-template-qualified-parent-red-zero-arg/20260829_100410_278_ea613564`
  — expected `0/1` RED;
- the application template and its child funcdef registered successfully;
- `GetTypeInfoByDecl("TScopedParent<int>")` and
  `GetTypeInfoByDecl("TScopedParent<int>::FChild")` proved the exact Runtime
  parent/child contract before Parser/Sema assertions;
- Parser accepted `TScopedParent<int>::FChild Callback;`;
- the failing Canonical dump recorded
  `type=TScopedParentintFChild` and `deps=TScopedParentintFChild` instead of
  kind `FUNCDEF` with stable key `TScopedParent<int>::FChild`;
- Runtime's transient diagnostic TypeId was `67108877`; it was evidence that
  the child existed in this Engine allocation, not Canonical identity.

This is the accepted semantic RED because execution reached the unchanged
structured QualType/Sema boundary and failed only the sealed Canonical fact.
## Implemented architecture

### Parser-owned recognized syntax

`asSQualTypeSyntaxNode` now carries `absoluteScope`,
`firstScopeSegment` and `scopeSegmentCount` in addition to its direct template
argument indices. `AppendQualTypeScopeSegments` copies every recognized scope
identifier into the same owned pre-order array. A template-bearing innermost
scope owns its `snDataType` argument subtrees by index; its source range is
extended across the recognized argument tokens. The removed
`AppendQualTypeActionLeafText` helper can no longer flatten this syntax into
`TScopedParentintFChild`.

This remains a short-lived Parser action rather than an AST node. It contains
owned strings, primitive/qualifier facts, indices, subtree sizes and processed
source offsets only. It contains no `asCScriptNode*`, Builder/Engine/type-info
pointer, Runtime TypeId or snapshot-local AST ref.

### Sema-owned validation and identity

`ActOnQualTypeSyntaxNode` consumes scope subtrees before the final type's direct
template arguments and validates every owner/child boundary. A template-bearing
scope is permitted only in the grammar-supported innermost position. Sema then:

1. recursively resolves each template argument as its own Canonical QualType;
2. resolves the exact parent instance (`TScopedParent<int>`);
3. resolves the complete child declaration;
4. proves `child->GetParentType() == exact parent instance`;
5. derives only the Runtime type kind and effective qualifiers through the
   existing bridge; and
6. interns the authored stable key `TScopedParent<int>::FChild`.

The Runtime Engine pointer and numeric TypeId are transient resolution inputs.
They do not cross the action boundary or become Canonical/snapshot identity.
The same stable-spelling override also protects non-template scoped child
funcdefs from losing a namespace in Runtime `asCDataType::Format`.

Malformed first-child indices, template-child overlap and out-of-subtree scope
children are permanent fail-closed tests. Direct root templates, nested
templates, namespace-qualified types, implicit handles and configured primitive
widths remain covered by the unchanged Frontend/Sema regression surfaces.

## GREEN and regression evidence

| Gate | Result | Evidence |
|---|---:|---|
| First implementation build | PASS | `Saved/Build/cta-s59-template-qualified-parent-green-build-1/20260829_101202_817_c1311a08` |
| Exact semantic method after implementation | **1/1 PASS** | `Saved/Tests/cta-s59-template-qualified-parent-green-1/20260829_101228_970_d160c39d` |
| Test/topology build | PASS | `Saved/Build/cta-s59-template-qualified-parent-tests-build/20260829_101446_589_61ec8d77` |
| First complete SemaAuthority diagnostic run | **408/410 PASS** | `Saved/Tests/cta-s59-sema-authority-green-1/20260829_101514_288_5ee8fccf`; all previous 408 methods passed, while the two new topology assertions exposed only test-shape/diagnostic-contract issues recorded below |
| Diagnostic-fix build | PASS | `Saved/Build/cta-s59-topology-diagnostic-build/20260829_101650_514_9acef5a5` |
| Second complete SemaAuthority diagnostic run | **409/410 PASS** | `Saved/Tests/cta-s59-sema-authority-green-2/20260829_101712_609_994e8c9f`; only the reused diagnostic-context assertion remained |
| Final implementation/test build | PASS | `Saved/Build/cta-s59-diagnostic-isolation-and-range-build/20260829_102021_555_e3a56b6b` |
| Malformed-topology focused gate | **1/1 PASS** | `Saved/Tests/cta-s59-malformed-topology-green/20260829_102057_619_1f31a346` |
| Complete SemaAuthority | **410/410 PASS** | `Saved/Tests/cta-s59-sema-authority-green-3/20260829_102138_445_9102721a` |
| Parser Declarations + Frontend Type/TypeIdentity/TypeSema + ProductionCodeGen + Module Snapshot + TypedASTJIT | **224/224 PASS** | `Saved/Tests/cta-s59-template-qualified-parent-regression/20260829_102249_193_42c7fcbd` |
| Final defensive-ordering build | PASS | `Saved/Build/cta-s59-final-build/20260829_102723_508_54c12803` |
| Final exact semantic method | **1/1 PASS** | `Saved/Tests/cta-s59-final-focused/20260829_102736_220_6423bd86` |

The combined regression decomposes to Parser Declarations **18**, Frontend
Type/TypeIdentity/TypeSema **20**, and downstream ProductionCodeGen + Module
Snapshot + TypedASTJIT **186**. The provider tests emitted their existing
`https://www.google.com/generate_204` connectivity-probe timeout warnings; the
run still had zero failures and zero skips.

Final static verification also passed:

- the `asSQualTypeSyntaxNode`/`asSQualTypeSyntaxAction` payload bodies contain
  zero Parser-node, Builder, Engine, Runtime type-info, TypeId or pointer fields;
- production Runtime source contains zero references to the removed flattening
  helper or the malformed `TScopedParentintFChild` key;
- `as_hir.h/.cpp` remain absent;
- native `as_parser.h`, `as_builder.h` and `as_compiler.h` all remain present;
- the only `asCOMPILER_PIPELINE_DUAL` text is the permanent test sentinel that
  proves no production dual symbol exists;
- `asCScriptEngine::GetCompilerPipeline()` still returns LEGACY unless the
  explicit Canonical flag is enabled;
- plugin and parent `git diff --check` both exited zero (line-ending notices
  only); and
- `openspec validate refactor-as-canonical-typed-ast-compiler --type change
  --strict --no-interactive` reported the change valid.

## Issues encountered and disposition

### I1 — template subtypes by value are an unsupported registration ABI

Both early funcdef declarations tried to pass `T` by value. The maintained
`SetTemplateRestrictions` explicitly rejects this because concrete template
subtypes can have different native ABI. CTA-S59 uses a zero-argument child
funcdef so the gate isolates qualified parent/child type identity. It does not
change or weaken that ABI restriction.

### I2 — failed `RegisterFuncdef` can leave provisional registration state

Code audit found that `RegisterFuncdef` allocates the function ID and
`asCFuncdefType`, appends it to the global/registered/parent child collections,
and only then calls `SetTemplateRestrictions`. A restriction failure returns
without visibly rolling those insertions back. Every exploratory execution used
a fresh Engine, so this did not contaminate accepted evidence. This appears to
be pre-existing registration transaction debt and is recorded here rather than
expanded into Task 4.3.

### I3 — Runtime formatting loses exact child ownership

The Runtime bridge correctly recovers the child's semantic kind, but
`asCDataType::Format` uses the bare `parentClass->name` for child funcdefs and
does not reproduce the concrete parent template arguments (and can omit a
namespace). Reusing that formatted text as stable identity produced an
incomplete key. CTA-S59 therefore uses Runtime only for kind/effective
qualifiers and interns the Parser/Sema-proven exact stable spelling.

### I4 — raw Parser topology assertion over-specified the primitive token

The first complete Sema run showed that a raw `ParseDataType` wrapper does not
guarantee the leaf node exposes `ttInt` in the exact place the test initially
assumed. The production semantic path already resolved the leaf spelling to the
configured Canonical primitive. The test now asserts the architectural contract
that `int` is a separate owned leaf, while existing configured-width tests keep
the token/width contract independently sealed.

### I5 — compound fail-closed checks emitted duplicate diagnostics

The first negative topology implementation used a compound condition that
could emit a specific child error followed by a second structure error. The
checks now return immediately after the first failed append/validation step,
preserving one deterministic diagnostic per invalid action.

### I6 — diagnostic de-duplication invalidated a reused test context

The second complete Sema run reached all three malformed actions, but the test
reused one Sema context without parsed source ranges. Identical diagnostics at
the same empty location are intentionally de-duplicated, so the second and
third calls did not increase the count. Each malformed action now runs in its
own diagnostic context; this tests independent fail-closed behavior without
changing production de-duplication.

## Closure

CTA-S59 closes the template-bearing qualified parent-type slice of Task 4.3.
It does not check Task 4.3 itself: contextual lambda/funcdef inference, fully
AST-local template declaration authority, the remaining namespace/type parity
and final Builder-comparison-adapter reconciliation remain. Default remains
LEGACY, native AngelScript AST remains available for LEGACY/reference/rollback,
HIR remains physically absent, and Standalone was not adapted or executed.
