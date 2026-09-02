# Canonical template declaration snapshot gate (CTA-S64)

Date: 2026-08-29

## Scope

This gate advances Task 4.3 by removing Runtime template-instance creation
from Canonical type Sema. Parser already copies complete type syntax into the
pointer-free `asSQualTypeSyntaxAction`; CTA-S64 makes the other side of that
boundary equally explicit: Sema may consume a copied view of host-registered
template declarations, but it must not ask Builder/Runtime to instantiate a
template merely to decide Canonical type identity.

Standalone remains explicitly deferred by user direction and is neither
changed nor run. The product default remains `LEGACY`; the native
`asCScriptNode`/Builder/Compiler graph remains available to LEGACY,
syntax/recovery, differential/reference and rollback paths. HIR remains
physically absent.

## Evidence-backed defect

`asIScriptEngine::GetTypeInfoByDecl` is declared `const`, but its maintained-
fork implementation constructs an `asCBuilder` through `const_cast` and calls
`ParseDataType`. For a previously unseen spelling such as
`array<int>`, that path reaches `asCBuilder::GetTemplateInstanceFromNode` and
`asCScriptEngine::GetTemplateInstanceType`.

`GetTemplateInstanceType` is not a read-only query. It can:

- allocate a new `asCObjectType`;
- attach module ownership and subtype references;
- invoke an application template callback;
- insert the instance into `templateInstanceBuckets`;
- generate child funcdefs, methods, factory stubs and behaviours;
- retain generation-local Runtime objects that may later receive numeric
  TypeIds.

The current structured type path calls this nominally-const query for a final
template instance and for a template-bearing parent scope. Therefore a pure
Canonical Sema action can currently mutate the Runtime before CodeGen/install,
even though the AST itself publishes only a stable key.

## Locked authority boundary

1. At Sema construction and again at translation-unit start, the Engine copies
   each registered template declaration into an owned, pointer-free fact:
   exact namespace-qualified stable key, arity, object flags,
   value/reference subtype restrictions, whether a Runtime callback remains
   to be validated, and child-funcdef names. The translation-unit refresh is
   the last snapshot point; Sema does not consult live template declarations
   while resolving individual type actions.
2. The copied facts contain no `asCTypeInfo*`, `asCObjectType*`, function
   pointer, numeric TypeId, template-instance pointer or Parser node.
3. Relative template names use the same current/enclosing-namespace search as
   other Canonical nominal types; an authored leading `::` uses only the exact
   global/qualified key.
4. Sema validates arity, direct subtype qualifier rules, the declarative
   value/reference restrictions and child-funcdef membership from those facts.
   It interns only the resolved stable instance/child key, type kind and
   effective implicit-handle qualifier.
5. Sema never calls `GetTypeInfoByDecl`, `IsTemplateType` or
   `GetTemplateInstanceType` for a template decision.
6. An arbitrary application template callback cannot be evaluated without a
   Runtime instance and may have application side effects. It is therefore a
   generation-install validation, not Canonical identity. Runtime binding or
   CodeGen must fail closed if the callback rejects the instance; no executable
   generation may be published from that failure.
7. Registration remains immutable during one Engine build. A Sema instance
   consumes one construction-time declaration snapshot; later Engine
   reconfiguration requires a new Sema/build generation.

## AST-first gate card

Owning suite:

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

### `SemaTemplateDeclarationSnapshotDoesNotInstantiateRuntimeType`

The test registers a unique implicit-handle host template, constructs Sema,
then resolves a pointer-free `TSemaSnapshot<int>` action. It requires:

- a valid `asAST_TYPE_TEMPLATE` with exact stable key
  `TSemaSnapshot<int>`;
- the implicit-handle bit copied from the template declaration;
- no growth of `templateInstanceBuckets` across the Sema action;
- no Runtime instance lookup in the assertion path itself.

Expected RED on the pre-CTA-S64 implementation: the QualType is produced, but
`GetTypeInfoByDecl("TSemaSnapshot<int>")` creates a Runtime instance and grows
the template bucket set.

### Existing template-qualified parent gate

`ParserTemplateQualifiedParentTypeResolvesExactChildFuncdefWithoutDynamicTypeIdIdentity`
will be strengthened so `TScopedParent<int>::FChild` resolves from the copied
base-template child declaration before any Runtime parent/child instance is
requested. Runtime compatibility may be checked only after the Canonical
no-instantiation assertion.

## Required evidence

- test-only Runtime/Editor build;
- focused causal RED for the exact new method;
- focused GREEN for final-template and template-parent cases;
- complete SemaAuthority prefix;
- Parser declaration, Frontend type, ProductionCodeGen, Module Snapshot and
  TypedASTJIT regression matrix;
- static scan of the structured template Sema region;
- strict OpenSpec validation and plugin/parent `git diff --check`;
- plugin commit first, then parent gitlink/OpenSpec commit.

## Non-claims and remaining Task 4.3 debt

- This gate does not make CANONICAL the default and does not introduce a
  production dual/fallback mode.
- It does not delete the native AngelScript AST or LEGACY Builder.
- It does not make Runtime template callbacks pure or move application code
  into Canonical Sema.
- Ordinary non-template host type projection still has indirect Builder
  lookup through `GetTypeInfoByDecl`; final Builder-adapter reconciliation and
  any parity exposed by its removal keep Task 4.3 open after CTA-S64.

## Evidence log

### Build and causal RED

- Test-only Runtime/Editor build: PASS.
  Evidence:
  `Saved/Build/cta-s64-template-snapshot-red-build/20260829_125932_841_9b4ea209`.
- The first focused invocation selected zero tests because its filter did not
  match the exact CQTest path. It is invalid discovery evidence and is
  explicitly excluded:
  `Saved/Tests/cta-s64-template-snapshot-red/20260829_125958_748_8e2eaae9`.
- Corrected exact snapshot gate: expected `0/1 RED`. The Canonical QualType was
  produced, but the old `GetTypeInfoByDecl` path grew the Runtime template
  bucket count from zero to one.
  Evidence:
  `Saved/Tests/cta-s64-template-snapshot-red-exact/20260829_130053_555_76d84c53/Summary.json`.
- Parent-gate test build: PASS.
  Evidence:
  `Saved/Build/cta-s64-template-parent-red-build/20260829_130242_885_e66eedd0`.
- Combined final-template and template-parent gate: expected `0/2 RED`.
  Evidence:
  `Saved/Tests/cta-s64-template-snapshot-parent-red/20260829_130304_127_3bd4efb3/Summary.json`.

### Partial GREEN and lifecycle localization

- First implementation build: PASS (`163` actions).
  Evidence:
  `Saved/Build/cta-s64-template-snapshot-green-build/20260829_130626_333_af2ef527`.
- First implementation run: `1/2 PASS`. Direct final-template Sema was now
  side-effect free, but the full Parser declaration path still instantiated
  the template parent.
  Evidence:
  `Saved/Tests/cta-s64-template-snapshot-parent-green/20260829_130843_562_ddb5fc01/Summary.json`.
- Phase-assert build: PASS.
  Evidence:
  `Saved/Build/cta-s64-template-parent-phase-red-build/20260829_131331_057_e7397579`.
- Phase RED proved that syntax extraction, direct structured Sema, Sema
  construction and Parser construction preserved the bucket count, while the
  complete `ParseScript` declaration lifecycle grew it.
  Evidence:
  `Saved/Tests/cta-s64-template-parent-phase-red/20260829_131353_768_03b57147/Summary.json`.
- A temporary localization probe was compiled successfully:
  `Saved/Build/cta-s64-template-parent-probe-red-build/20260829_131711_549_95f57a1b`.
  Its RED run proved virtual-property and variable-declaration lookahead were
  side-effect free and isolated the mutation to `ParseDeclaration` itself:
  `Saved/Tests/cta-s64-template-parent-probe-red/20260829_131733_961_c843e314/Summary.json`.
  The temporary probe API was removed after localization; only durable
  behavior assertions remain in the final test.

### Root cause and correction

`ActOnVariableInitializerAction(asVARIABLE_INITIALIZER_NONE)` still resolved
the already-canonical variable QualType through `asCRuntimeTypeBridge` to
decide whether a namespace/global variable needed the
`DEFAULT_INITIALIZED` trait. For
`TScopedParent<int>::FChild Callback`, that apparently unrelated declaration
lifecycle query round-tripped the stable child key into
`GetTypeInfoByDecl`, which instantiated the parent template.

The correction derives the one required declaration-level storage fact from
Canonical type kind plus the copied base-template flags. It does not resolve a
Runtime application type. This preserves the existing default-initialization
policy for non-primitive VALUE objects and VALUE templates, while funcdefs and
reference templates remain non-default-initialized.

- Root-correction build: PASS.
  Evidence:
  `Saved/Build/cta-s64-template-lifecycle-green-build/20260829_132002_148_d20e155f`.
- Exact final-template + template-parent gate: `2/2 PASS`.
  Evidence:
  `Saved/Tests/cta-s64-template-lifecycle-green/20260829_132030_106_7c43c0af/Summary.json`.
- Focused gate plus existing VALUE default-initialization policy:
  `3/3 PASS`.
  Evidence:
  `Saved/Tests/cta-s64-template-lifecycle-value-green/20260829_132123_635_07a8af82/Summary.json`.

### Topology regression and final GREEN

- The first complete SemaAuthority run was `422/423 PASS`. The only failure,
  `SemaTemplateQualifiedParentTypeRejectsMalformedScopeTopology`, exposed
  that a malformed `firstTemplateArgument` index was semantically traversed
  before the structural-topology check, so the action produced the wrong
  diagnostic class.
  Evidence:
  `Saved/Tests/cta-s64-sema-authority-green/20260829_132158_599_9561ff2a/Summary.json`.
- The fix validates each scope-segment and final-template child anchor before
  resolving any argument. This retains fail-closed structure authority and
  avoids semantic work over malformed topology.
- Final topology build: PASS.
  Evidence:
  `Saved/Build/cta-s64-template-topology-green-build/20260829_132314_489_ba933529`.
- Exact topology gate: `1/1 PASS`.
  Evidence:
  `Saved/Tests/cta-s64-template-topology-green/20260829_132327_730_7b3dcb06/Summary.json`.
- Complete SemaAuthority: `423/423 PASS`, zero failures, skips and timeout.
  Evidence:
  `Saved/Tests/cta-s64-sema-authority-final/20260829_132402_497_d72942f0/Summary.json`.
- Parser Declarations + Frontend Canonical type + ProductionCodeGen + Module
  Snapshot + TypedASTJIT: `224/224 PASS`, zero failures and skips.
  Evidence:
  `Saved/Tests/cta-s64-cross-surface-final/20260829_132502_188_bbd0ddcb/Summary.json`.
  Repeated `generate_204` HTTP timeout warnings were unrelated environment
  probes; the automation process exited `0` and the report contains no failed
  tests or failure hints.

### Static architecture evidence

- The exact `ActOnQualTypeSyntaxNode` structured-type Sema region has zero
  occurrences of `GetTypeInfoByDecl`, `IsTemplateType`,
  `GetTemplateInstanceType` or `asCRuntimeTypeBridge::Resolve`.
- Template decisions now use only the copied declaration facts and Canonical
  `QualType`/stable keys. No live type pointer, template-instance pointer,
  numeric TypeId, Parser node or HIR fact is added to the AST or snapshot.
- Three `GetTypeInfoByDecl` call sites remain in `as_sema_decl.cpp` for
  ordinary qualified nominal host projection, ordinary named host fallback
  and Runtime base-type projection. They are deliberately not claimed by this
  slice and keep Task 4.3 open for final non-template Builder-adapter
  reconciliation.
- Application template callbacks are represented only by the copied
  `requiresRuntimeValidation` marker. The callback itself remains Runtime
  install/build validation and must fail closed before executable publication;
  it is not executed during Sema lookup.
- The default remains LEGACY, native AngelScript AST/Builder/Compiler sources
  remain present, HIR remains absent, and no production dual/fallback mode is
  introduced.

### Accounting

CTA-S64 is a bounded Task 4.3 slice. It closes template declaration identity,
arity, declarative subtype restrictions, implicit-handle projection and
template-parent child-funcdef membership without Runtime instantiation, but it
does not close all ordinary host/script type projection and comparison-adapter
work in the broad Task 4.3 text. The formal task ledger therefore remains
`101/136 = 74.3%`, with `35` tasks open.
