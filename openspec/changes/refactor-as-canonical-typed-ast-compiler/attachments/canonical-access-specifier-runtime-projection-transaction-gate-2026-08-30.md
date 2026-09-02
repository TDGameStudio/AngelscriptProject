# Canonical AccessSpecifier Runtime projection transaction gate — 2026-08-30

## Status

CTA-S69 is GREEN for the non-Standalone product boundary covered by this
change. A CANONICAL-selected source build now consumes the exact typed
`AccessSpecifierDecl` / `AccessPermissionDecl` graph, prepares generation-local
Runtime access metadata, authenticates exact field and ordinary-method edges,
and publishes the per-class aggregate only after all entries validate.

This closes the known custom-access Stage 2 projection blockers. It does not
close the full `refactor-as-canonical-typed-ast-compiler` change or authorize
the final product-default flip.

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S69 — custom access metadata producer integrity and Runtime projection transaction |
| AST-first owner | `FCanonicalASTSemaAuthorityTests` |
| Stage 2 owner | `FCanonicalASTProductionCodeGenTests` |
| Semantic input | exact record-local AccessSpecifier DeclIds, ordered permission DeclIds, typed traits and explicit field/method access edges |
| Runtime output | one `asSAccessSpecifier` DTO per Canonical definition plus generation-local exact-identity bindings borrowed by fields/methods |
| Atomicity boundary | one class's complete access metadata aggregate; failed validation publishes no aggregate and member-edge failure occurs before the affected member shell |
| Durable identity | Canonical DeclIds/stable producer identity only; numeric Runtime pointers remain generation-local and are not persisted |
| Product selection | CANONICAL only for this projection; explicit LEGACY keeps native `RegisterAccessSpecifier` and the native Parser/Builder/Compiler |
| Excluded | Standalone, final default flip, HIR, public AST V1 changes, general module-wide transaction closure |

## Resulting architecture

```text
Parser typed access action
  -> Sema exact record-local declarations and member edges
  -> compiler-owned Canonical context during prepared Stage 2
  -> prepared Runtime class shell (before final Seal)
  -> validate and stage every access DTO
  -> one allocation-free SwapWith commit
  -> generation-local DeclId -> Runtime DTO bindings
  -> resolve field/method edge before publishing that member shell
```

The retained `snAccessDeclaration` tree is still produced for syntax,
recovery, LEGACY, reference and differential tests. Its spelling, permission
children and modifier nodes are not consulted by the CANONICAL Runtime
projection function. Class/member native nodes still provide a build-local
completed-coordinate key used to retrieve the already-created exact Canonical
DeclId; they are not replayed for access meaning. The projection also does not
call the LEGACY source/name decoder `RegisterAccessSpecifier`.

This projection runs during Builder Stage 2 before `SealCanonicalAST()`. It is
therefore a compiler-owned mutable-context consumer with local shape/owner
authentication, not a Frozen/Publishable snapshot backend. Final verifier and
Seal remain the later publication boundary. This is allowed only because the
Stage 2 shell mechanically materializes existing Sema facts and does not choose
new access semantics.

## Implementation closure

### Parser producer

- `ParseAccessDecl` publishes its typed aggregate only at the complete
  terminating semicolon.
- Permission-array growth no longer uses `asCArray::PushLast`, whose `void`
  contract can silently ignore allocation failure.
- The producer now uses checked `SetLength` followed by exact-index assignment.
  A failed growth reports a Parser error and returns without invoking
  `ActOnAccessSpecifierAction`.
- A `WITH_ANGELSCRIPT_UNITTESTS` one-shot seam addresses the precise append
  ordinal and proves a partially accumulated permission prefix is never
  published. The seam is absent from production behavior.

### Canonical-to-Runtime projection

- Access-definition inventory and order come from the Canonical record owner's
  exact child list, not retained native-node coordinates.
- A dangling owner child is rejected before the zero-definition fast path, so
  malformed input cannot masquerade as an empty access inventory.
- Every AccessSpecifier child must have the exact child DeclId, correct owner,
  correct declaration kind, valid base trait and non-empty name.
- Duplicate definition DeclIds and different DeclIds with the same definition
  name are rejected, preserving Parser/Sema and LEGACY uniqueness semantics.
- Every permission child must have the exact listed DeclId, parent and kind.
  Repeating one permission DeclId is rejected. Different permission DeclIds
  with the same authored name remain permitted because that is the existing
  language behavior.
- Repeated wildcard entries accumulate `readonly` and `editdefaults` with OR
  semantics rather than overwriting an earlier trait.
- All Runtime DTOs are staged in private ownership. The class aggregate is
  installed with one `SwapWith` only after the complete set validates and all
  allocations succeed.
- Generation-local bindings retain exact Canonical specifier/owner DeclIds and
  borrow the corresponding current-generation Runtime DTO. They are not a
  cache format or cross-generation identity model.

### Member publication ordering

- Field access is resolved before `AddPropertyToClass`, so a foreign,
  wrong-owner or wrong-kind edge cannot leave a property shell behind.
- Ordinary method access is resolved before method registration, so the same
  class of failure cannot publish a method shell.
- `BuildGenerateFunctions` stops before its internal `CompileClasses()` and
  `RegisterGlobalVariables()` calls when CANONICAL `ParseScripts()` has recorded
  an error, including access aggregate projection failure. The outer UE staged
  compiler currently still calls later failed-candidate layout, allocation and
  Stage 3 entry points before final swap suppression/discard; CTA-S69 does not
  claim a module-lifecycle early stop.
- CANONICAL does not silently retry through LEGACY or merge the two sources of
  meaning.

## Batched TDD evidence

### Cluster A — field-shell publication order

The permanent negative test first reproduced a foreign Canonical field edge
that was rejected only after `AddPropertyToClass` had already published one
property shell.

| Phase | Result | Evidence |
|---|---:|---|
| RED | **125/126 PASS; one intended failure** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.FCanonicalASTProductionCodeGenTests/20260830_000529_415_11532058/Report` |
| GREEN | **126/126 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.FCanonicalASTProductionCodeGenTests/20260830_000751_322_3b0c3f0f/Report` |

### Cluster B — Canonical inventory and wildcard accumulation

Static review grouped two reachable defects: definition inventory/order still
depended on native access nodes, and repeated wildcard traits overwrote rather
than accumulated.

| Phase | Result | Evidence |
|---|---:|---|
| RED | **125/127 PASS; two intended failures** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.FCanonicalASTProductionCodeGenTests/20260830_000933_320_46d750e8/Report` |
| GREEN | **127/127 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.FCanonicalASTProductionCodeGenTests/20260830_001239_795_80a3a439/Report` |

### Cluster C — Stage 2 graph integrity and no partial member shell

Four tests were added in one matrix. Three were intended REDs; the foreign
method test was already GREEN and authenticated the existing method ordering.

| Phase | Result | Evidence |
|---|---:|---|
| Test build | **4/4 actions PASS** | `Saved/Build/cta-s69-access-integrity-red/20260830_002130_682_f2b9b7da` |
| RED | **128/131 PASS; exactly three intended failures** | `Saved/Tests/cta-s69-access-integrity-red/20260830_002146_141_804c4f0a/Report` |
| Repair build | **4/4 actions PASS** | `Saved/Build/cta-s69-access-integrity-green/20260830_002510_525_83d04448` |
| GREEN | **131/131 PASS** | `Saved/Tests/cta-s69-access-integrity-green/20260830_002522_227_f50ffc24/Report` |

The three REDs were:

- dangling owner child incorrectly accepted through zero-definition success;
- duplicate AccessSpecifier names with distinct DeclIds accepted;
- one permission DeclId listed twice and published twice.

The fourth test proves a foreign method edge leaves no method shell and passed
before and after the repair.

### Cluster D — Parser permission-append OOM

The test was written first against the intended deterministic append boundary.
The RED build failed only because the two test-only seam methods did not yet
exist. Production then gained checked growth and the seam, after which the
complete owning class passed.

| Phase | Result | Evidence |
|---|---:|---|
| Compile-time RED | expected missing seam methods; no unrelated compile error | `Saved/Build/cta-s69-access-parser-oom-red/20260830_002741_716_2727e0e2` |
| GREEN build | **44/44 actions PASS** | `Saved/Build/cta-s69-access-parser-oom-green/20260830_002816_011_cbbe1006` |
| SemaAuthority GREEN | **423/423 PASS** | `Saved/Tests/cta-s69-access-parser-oom-green/20260830_002913_226_64ccab5a/Report` |

### Cluster E — indexed declaration self-identity mutation

Two review-derived tests mutate an unsealed declaration object's embedded ID
while leaving its arena index/owner-child key unchanged. The production self-ID
guards were then temporarily removed together. The same focused class produced
exactly the two intended failures; restoring the guards closed both without a
new semantic implementation.

| Phase | Result | Evidence |
|---|---:|---|
| Mutation build | **7/7 actions PASS** | `Saved/Build/cta-s69-access-self-id-mutation-red/20260830_004413_715_89274dbf` |
| Mutation RED | **131/133 PASS; exactly two intended failures** | `Saved/Tests/cta-s69-access-self-id-mutation-red/20260830_004429_813_392a1f43/Report` |
| Restored-guard build | **4/4 actions PASS** | `Saved/Build/cta-s69-access-self-id-green/20260830_004512_817_4334d788` |
| GREEN | **133/133 PASS** | `Saved/Tests/cta-s69-access-self-id-green/20260830_004526_833_0fc2a58e/Report` |

The two authenticated mutations were:

- an `AccessSpecifierDecl` whose embedded `id` disagreed with its owner child
  DeclId;
- an `AccessPermissionDecl` whose embedded `id` disagreed with its specifier
  child DeclId.

Duplicate AccessSpecifier child identity remains a production defense-in-depth
check. It is not claimed as an independently observable test branch because the
same malformed graph necessarily also violates definition-name uniqueness.

### Cluster F — owner/member indexed-object self-identity

Final independent review found that the owner lookup and field/method access
edge resolver authenticated arena/index, declaration kind and parent, but did
not authenticate the retrieved object's embedded `asCDecl::id`. Three tests
were added together and mutated one owner, field or method object while keeping
the requested DeclId's arena/index and parse coordinate unchanged.

| Phase | Result | Evidence |
|---|---:|---|
| Test build | **4/4 actions PASS** | `Saved/Build/cta-s69-owner-member-self-id-red/20260830_005821_956_063a0adb` |
| RED | **147/150 PASS; exactly three intended failures** | `Saved/Tests/cta-s69-owner-member-self-id-red/20260830_005837_195_de11d284/Report` |
| Repair build | **4/4 actions PASS** | `Saved/Build/cta-s69-owner-member-self-id-green/20260830_005925_558_70329001` |
| GREEN | **150/150 PASS** | `Saved/Tests/cta-s69-owner-member-self-id-green/20260830_010025_366_326f33e8/Report` |

The repair is deliberately narrow: exact owner lookup now requires the record
object to self-identify with the requested DeclId, and member-edge resolution
requires the field/method object to self-identify before checking kind, parent
or publishing a Runtime shell.

## Permanent regression tests

Stage 2 matrix in
`AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`:

- `PreparedDanglingAccessOwnerChildFailsBeforeZeroDefinitionSuccess`;
- `PreparedDuplicateAccessDefinitionNamesPublishNoRuntimeAggregate`;
- `PreparedDuplicateAccessPermissionDeclIdPublishesNoRuntimeAggregate`;
- `PreparedAccessSpecifierSelfIdMismatchPublishesNoRuntimeAggregate`;
- `PreparedAccessPermissionSelfIdMismatchPublishesNoRuntimeAggregate`;
- `PreparedAccessOwnerSelfIdMismatchPublishesNoRuntimeAggregate`;
- `PreparedAccessFieldSelfIdMismatchPublishesNoPropertyShell`;
- `PreparedAccessMethodSelfIdMismatchPublishesNoMethodShell`;
- `PreparedForeignMethodAccessEdgePublishesNoMethodShell`;
- the existing exact-identity, source-poisoning, transaction, field, method,
  definition-order and repeated-wildcard tests in the same fixture.

Parser producer matrix in
`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`:

- `ParserAccessPermissionAppendOomFailsWithoutPublishingTruncatedAggregate`;
- the existing complete-action, exact-identity and no-node-replay tests.

## Broad GREEN and static boundary evidence

| Gate | Result | Evidence |
|---|---:|---|
| Final focused ProductionCodeGen matrix | **150/150 PASS** | `Saved/Tests/cta-s69-owner-member-self-id-green/20260830_010025_366_326f33e8/Report` |
| Final owner/member self-ID incremental build | **4/4 actions PASS** | `Saved/Build/cta-s69-owner-member-self-id-green/20260830_005925_558_70329001` |
| Final pre-review incremental build | target up-to-date; PASS | `Saved/Build/cta-s69-precommit-final/20260830_005436_988_deb8ddea` |
| Complete SemaAuthority | **436/436 PASS** | `Saved/Tests/cta-s69-review-fixes-sema-green/20260830_010111_836_d0a66558/Report` |
| Complete Compiler CanonicalAST | **631/631 PASS** | `Saved/Tests/cta-s69-review-fixes-compiler-green/20260830_010156_845_70311738/Report` |
| Complete Frontend CanonicalAST | **175/175 PASS** | `Saved/Tests/cta-s69-review-fixes-frontend-green/20260830_010244_221_3ee320c2/Report` |

Static source inspection of the exact functions reports:

- `ProjectCanonicalAccessSpecifiersForClass`: zero
  `RegisterAccessSpecifier` calls, zero `snAccessDeclaration` references and
  exactly one `SwapWith(staged)` aggregate commit;
- `ParseAccessDecl`: zero `permissions.PushLast(permission)` calls, exactly one
  checked `permissions.SetLength(permissionIndex + 1)` and exactly one typed
  `ActOnAccessSpecifierAction` publication;
- Runtime source outside Standalone: zero `asCTypedSemanticIRBuilder`,
  `TypedHIRSidecar` or `as_typed_semantic_ir` matches.
- `asCBuilder::Reset()` clears the generation-local access binding only under
  the same `#ifndef AS_NO_COMPILER` condition that declares the member. This
  statically repairs a review-found no-compiler configuration defect; a
  dedicated no-compiler/Standalone build remains deferred and is not claimed.
- The historical mixin-class expansion functions still contain source/name
  access lookup, but are not reachable in the current grammar:
  `ParseMixin()` accepts a free function only, `RegisterMixinClass()` has no
  callers, and current syntax tests reject `mixin class`. Free mixin functions
  are a different supported construct and do not traverse that path.

## Task impact

This gate advances the implementation evidence for Tasks `0.2`, `4.2`, `4.4`,
`4.5`, `4.6`, `10.3`, `10.6`, `13.2` and `13.6`. It does not by itself close
their umbrella requirements. In particular, other declaration families,
remaining body/expression/statement adapters, complete module transaction
coverage and final default cutover remain separate work.

## Recorded non-claims and remaining boundaries

- Product default remains LEGACY until the complete authority/cutover gate.
- The native AngelScript AST, Parser, Builder and Compiler remain intentionally
  available for explicit LEGACY/reference/syntax/differential/rollback use.
- HIR remains physically absent and is not reintroduced.
- Public AST V1 is unchanged.
- Current Sidecar schema remains V8; CTA-S69 adds no AST kind, trait, edge,
  public-view field or persisted schema data.
- Standalone was not modified, built, tested or claimed in CTA-S69.
- This is a per-class access-metadata transaction plus pre-member edge
  authentication, not proof that every Runtime declaration category commits in
  one module-wide transaction.
- A Stage 2 error suppresses active-generation swap, and the failed candidate
  is ultimately reset/discarded, but the UE orchestrator still invokes broader
  layout/global-allocation/Stage 3 work on that doomed candidate. Tightening
  this module-lifecycle behavior remains Task 13.6 rather than CTA-S69.
- Per-member authentication is not a single transaction over the access DTO
  aggregate and every member in the class. A later member failure can leave
  earlier candidate-local shells until the failed module is discarded.
- Constructors/destructors, dormant shared-class paths, dormant mixin-class
  expansion and interface-specific access behavior are not claimed as newly
  supported access surfaces by this gate. The current Parser supports free
  mixin functions but not `mixin class`; `RegisterMixinClass()` has no callers.
  Reachability must be established before that historical path becomes
  implementation scope.
- The dormant virtual-property route still contains source/name access lookup;
  current production parsing rejects that route before it reaches registration,
  so virtual-property access is explicitly not claimed by this gate.
- Checked Parser growth proves `asCArray` append failure. It does not prove that
  every later `asCString` payload copy has the same immediate Parser-error
  contract. Current empty-name/Sema/Seal rejection remains fail-closed, while a
  uniform string-allocation contract is separately scoped.
- Runtime DTO pointers and numeric TypeIds remain current-generation values.
  They must never become durable cache, sidecar, Hot Reload or cross-generation
  identity.
- The generation-local binding table is intentionally transient. A future
  persistent relation must use stable producer identity, never copied Runtime
  pointers.
- CTA-S69's new tests are Prepared Builder Stage 2 and Parser producer gates.
  Their location in `ProductionCodeGenTests.cpp` does not by itself prove a
  detached CodeGen artifact, VM execution, publisher selection, Hot Reload or
  Cache restore for this access slice.
