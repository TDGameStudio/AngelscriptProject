# CTA-S57 — implicit-handle QualType derivation gate

Date: 2026-08-29
Worktree: `D:\as-cta`
Scope: OpenSpec Task 4.3 implicit-handle parity only; Standalone remains
excluded by the approved deferral.

## Gate card

| Field | Value |
|---|---|
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| RED method | `ParserRuntimeImplicitHandleTypesBecomeCanonicalHandleQualTypesWithoutAuthoredSuffix` |
| Real source path | register a named reference type and `array<class T>` with `asOBJ_IMPLICIT_HANDLE`, then parse bare `CImplicitQualHandle Object;` and `array<int> Values;` through `asCParser -> asCSema -> asCASTContext` |
| Required Canonical fact | both declarations retain their exact stable type key/kind and carry `asAST_QUAL_HANDLE` even though the source contains no explicit `@` suffix |
| Expected RED | LEGACY `CreateDataTypeFromNode` derives a handle from the Runtime type flag, but current `ActOnQualType` and structured-template interning preserve only authored qualifier bits |
| Production change | during Sema resolution, derive the effective qualifier mask from the exact Runtime type declaration/instance, apply implicit handle before the Runtime bridge, and persist only the resulting qualifier bit plus stable key |
| Downstream gates | focused method, complete SemaAuthority, Frontend Type/TypeIdentity/TypeSema, ProductionCodeGen, Module Snapshot and TypedASTJIT |

## Evidence-backed gap

`asCBuilder::CreateDataTypeFromNode` records `isImplicitHandle` when the
resolved `asCTypeInfo` has `asOBJ_IMPLICIT_HANDLE` and invokes
`asCDataType::MakeHandle(true)` after parsing suffixes. This is language type
semantics, not a backend convenience.

The CANONICAL named-type path currently creates a non-handle `asCDataType`
unless the Parser action already contains `asAST_QUAL_HANDLE`. The structured
template path validates `GetTypeInfoByDecl(completeSpelling)` but interns the
parent using only `node.qualifiers`. Bare Runtime implicit-handle declarations
can therefore enter the AST as reference/template types without their owning
handle qualifier.

## Locked design

1. Parser continues to copy only authored spelling/token/qualifier/range
   facts. It must not query or carry Runtime flags.
2. Sema owns effective type semantics. After resolving one exact Runtime type,
   `asOBJ_IMPLICIT_HANDLE` contributes `asAST_QUAL_HANDLE` to the local
   effective qualifier mask.
3. Named types and exact template instances use the same derivation rule.
4. A Runtime pointer or numeric TypeId may be consulted only during the call;
   neither enters the action, AST, snapshot, Cache identity or backend DTO.
5. Explicit handle syntax remains idempotent at the QualType bit level.
6. Native Parser AST, Builder and `asCCompiler` remain intact for LEGACY,
   syntax/recovery, reference, differential and rollback use. HIR remains
   physically absent.

## Mutation checks

The permanent test must fail if a later change:

- drops the implicit handle on a named Runtime reference type;
- drops it on an exact template instance;
- changes the stable key or type kind while adding the qualifier;
- requires Parser to manufacture an authored `@` token;
- persists a Runtime pointer or dynamic TypeId in the action/AST;
- restores Builder/native-node semantic replay in CANONICAL Sema.

## Required evidence ledger

- [x] gate card written before production edits;
- [x] test-only build passes and focused semantic RED is observed;
- [x] named and template implicit-handle derivation implemented in Sema;
- [x] focused and complete SemaAuthority GREEN;
- [x] Frontend Type and downstream consumer regressions GREEN;
- [x] source-boundary scans, parent/plugin `git diff --check`, and strict
  OpenSpec validation pass;
- [x] all runner/build/design issues and final non-claims are recorded.

## Implemented slice

`as_sema_decl.cpp` now computes an effective qualifier mask from the exact
Runtime declaration resolved during the current Sema call. If that declaration
has `asOBJ_IMPLICIT_HANDLE`, Sema adds `asAST_QUAL_HANDLE` before constructing
the transient `asCDataType` and before interning the final Canonical QualType.
The same helper is used for:

- named Runtime object types resolved by exact declaration or namespace-aware
  lookup;
- the retained flat template-spelling entry point; and
- structured template syntax after the exact completed instance spelling has
  been accepted by `GetTypeInfoByDecl`.

The Runtime object is a local semantic oracle only. The Parser action remains
`spelling + primitive token + qualifier mask + indexed child/range values`;
the AST receives only stable kind/key plus the effective qualifier bits. No
`asITypeInfo*`, `asCTypeInfo*`, numeric TypeId or Builder node is added to the
action, AST, snapshot or backend contract.

## Non-claims

- This slice does not close Task 4.3. Complete namespace/parent-type lookup,
  template-bearing scope segments, contextual lambda/funcdef inference,
  template-declaration authority and final Builder reconciliation remain.
- It does not close Tasks 4.4-4.6, 5.x, 6.x, 13.2 or default cutover.
- Standalone is not adapted or run. Default remains LEGACY; there is no
  production `dual` backend or silent LEGACY fallback.

## TDD / issue ledger

### RED and build evidence

1. The test-only build passed before production changes:
   `Saved/Build/cta-s57-implicit-handle-red-build/20260829_091958_478_6eb2c538`.
2. The new real Parser-to-Sema gate failed **0/1** at the first named-type
   qualifier assertion, with an empty diagnostics list:
   `Saved/Tests/cta-s57-implicit-handle-red/20260829_092019_843_d4a5c2e2`.
   This proves parsing and fixture registration succeeded while the Canonical
   QualType lost Runtime-derived handle semantics. CQTest stops after the first
   failed assertion, so the template assertion was not separately observed in
   the RED run; it remains in the permanent test as an independent mutation
   check.
3. The first production implementation build passed:
   `Saved/Build/cta-s57-implicit-handle-first-fix-build/20260829_092208_802_c2048352`.

### GREEN evidence

| Gate | Result | Artifact |
|---|---:|---|
| focused implicit-handle method | **1/1 PASS** | `Saved/Tests/cta-s57-implicit-handle-focused-green/20260829_092221_449_dea44c86` |
| complete Canonical SemaAuthority | **407/407 PASS** | `Saved/Tests/cta-s57-implicit-handle-sema-authority/20260829_092258_705_15d9d047` |
| Frontend Type + TypeIdentity + TypeSema | **20/20 PASS** | `Saved/Tests/cta-s57-implicit-handle-frontend-types/20260829_092453_180_d800f455` |
| ProductionCodeGen + Module Snapshot + TypedASTJIT | **186/186 PASS** | `Saved/Tests/cta-s57-implicit-handle-consumer-regression/20260829_092529_769_98a0085c` |

### Issues and interpretation

- The semantic defect was the mismatch between LEGACY
  `CreateDataTypeFromNode`, which calls `MakeHandle(true)` for
  `asOBJ_IMPLICIT_HANDLE`, and Canonical `ActOnQualType`, which previously
  retained only authored `@` qualifier bits.
- Exact Runtime lookup is intentionally retained inside Sema for this slice:
  implicit handle is a declaration semantic property and cannot be inferred
  from spelling alone. This is not dynamic identity persistence; the pointer
  dies at the call boundary and only the stable qualifier bit is published.
- The combined TypedASTJIT run emitted existing environment warnings for
  missing optional profiler DLLs and `google.com/generate_204` timeouts. They
  did not fail a test or affect the **186/186** result.
- No Standalone build, test or adaptation was performed, per the approved
  deferral.

### Boundary and record validation

- The `asSQualTypeSyntaxNode` / `asSQualTypeSyntaxAction` contract contains
  only owned spelling/token/qualifier/index/range values; it contains no
  `asITypeInfo`, `asCTypeInfo`, TypeId or `asCScriptNode*` field.
- `as_parser.cpp` has no `asITypeInfo`, `asCTypeInfo`, TypeId,
  `GetTypeInfoByDecl` or `asOBJ_IMPLICIT_HANDLE` reference. Runtime semantic
  derivation therefore stays behind the Sema boundary.
- Plugin and parent `git diff --check` both passed. The reported LF-to-CRLF
  messages are Git working-copy conversion warnings, not whitespace errors.
- `openspec validate refactor-as-canonical-typed-ast-compiler --strict`
  passed.
- Formal task accounting remains **101/136 = 74.3%** because this verified
  slice advances, but does not complete, Task 4.3.

### Residual boundary after this slice

Runtime-declared named types and exact Runtime template instances now match
LEGACY implicit-handle behavior. Script-only lexical class/interface implicit-
handle derivation is not claimed here because it does not necessarily have an
exact Runtime declaration at the same phase. Complete namespace/parent-type
lookup, template-bearing scope segments, contextual lambda/funcdef inference,
AST-local template declaration authority and final Builder-adapter
reconciliation remain the closure conditions for Task 4.3.
