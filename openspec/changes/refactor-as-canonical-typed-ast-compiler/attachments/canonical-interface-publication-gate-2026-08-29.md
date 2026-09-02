# Canonical interface publication gate — 2026-08-29

## Status

- Approach A Tasks 1–4 are implemented and verified.
- The sealed semantic fact is an ordered, record-owned
  `asSASTMethodRelation` edge. Runtime dispatch is a generation-local
  projection of those exact edges; it is not a second semantic lookup.
- Detached Canonical CodeGen publishes candidate interface shells and dispatch
  tables atomically. Prepared Canonical CodeGen authenticates the Builder-owned
  Stage 1/2 graph read-only and publishes only detached bodies/globals after
  the graph is known to agree with the sealed relation plan.
- The final Runtime/Editor build and every required semantic, transport,
  CodeGen, StaticJIT, Hot Reload, Compiler, Frontend and Module gate are green.
- This closes the interface-publication slice. It does **not** close the full
  `refactor-as-canonical-typed-ast-compiler` change or its broad 9.1, 9.5,
  13.2 and 13.6 umbrella sentences.
- Standalone remains explicitly deferred and was neither edited nor run.

## End-to-end architecture now proved

```text
Parser typed actions
    -> Canonical Sema selects exact override/interface targets
    -> record-owned methodRelations (snapshot-local DeclIds only)
    -> final verifier authenticates owner/ancestry/signature/completeness
    -> Sidecar V8 remaps and preserves the exact relation triples
    -> CodeGen binds each DeclId to one current-generation Runtime shell
    -> mechanical dispatch plan (methods/interfaces/offsets/vtable/vfTableIdx)
    -> detached Commit/Abandon, or read-only Prepared Stage 2 authentication
    -> canonical body/global publication and generation promotion
```

The durable side of the boundary contains stable keys, Canonical types and
snapshot-local declaration edges. The Runtime side may contain `TypeId`,
`FunctionId`, `asCTypeInfo*`, `asCScriptFunction*`, `vfTableIdx` and interface
offsets only inside the candidate/current generation. None of those Runtime
values is serialized or used as cross-generation identity.

## Issue ledger and RED/GREEN evidence

### CTA-IF-01 — irreducible method relations were absent from Sidecar V7

- RED: verifier `49/51`, interface Sema/Sidecar `5/6`; V7 decoded a valid
  snapshot with zero method relations.
- Root cause: V7 declaration DTOs had no relation triple and traversal/dump/
  verifier had no generic edge for the fact.
- Fix: append pointer-free `(kind, implementation DeclId, requirement DeclId)`
  triples as Sidecar V8, remap after declaration allocation, verify in three
  phases, and include them in traversal/dump/diff/digest.
- GREEN: verifier `51/51`, interface Sema/Sidecar `6/6`, Cache ASTBodySidecar
  `23/23`.
- Detailed evidence:
  `attachments/canonical-interface-sidecar-v8-issue-2026-08-29.md`.

### CTA-IF-02 — detached CodeGen had no interface declaration/runtime shape

- RED: `0/1`; `Canonical CodeGen failed code=-7 ... unsupported declaration
  kind Interface`.
- Root cause: detached registration admitted classes only and all created
  methods were script-body functions.
- Fix: register zero-sized interface shells, create bodyless
  `asFUNC_INTERFACE` functions, bind their exact declaration IDs, and exclude
  them from body emission.
- GREEN: declaration-shell gate `1/1`, followed by the exact dispatch and
  compatibility matrix `9/9`.
- Detailed evidence:
  `attachments/canonical-interface-runtime-publication-issue-2026-08-29.md`.

### CTA-IF-03 — Runtime projection still needed exact layout and transaction ownership

- REDs found three independent facts: missing class interface closure,
  breadth-first rather than legacy depth-first closure order, and pointer-based
  rather than complete-signature inherited requirement de-duplication.
- Root cause: the old Runtime finalizer chose methods again by name/signature,
  while the new detached path initially lacked an exact, complete dispatch
  plan and legacy-observable layout rules.
- Fix: derive base overrides and interface implementations only from sealed
  relation DeclIds; prepare the complete object graph before publication;
  preserve legacy DFS closure/order and inherited-requirement de-duplication;
  install the graph only during artifact Commit; abandon the candidate at the
  injected post-plan/pre-commit seam.
- GREEN: focused interface gate `9/9`, ProductionCodeGen `132/132` at the Task
  3 closure point, and transaction regression `20/20`.
- Plugin commits: `cbd49ce`, `adedb56`, `0fb646b`, `e474dc4`.

### CTA-IF-04 — Prepared Stage 2 graph was accepted without sealed-plan authentication

- RED method:
  `PreparedInterfaceShellsAreAuthenticatedBySealedRelations`.
- The test swaps the existing class interface order after Stage 2, requires
  `GeneratePreparedModule()` to reject it before body/provenance publication,
  restores the original graph, then requires the same Builder to retry and
  execute the interface call as `42`.
- Root cause: Prepared CodeGen inherited Builder-owned method/interface/vtable
  arrays but did not compare the whole graph with a mechanically derived plan.
- Fix: capture the exact record stable key on `sClassDeclaration` while
  Parser/Sema identity is still available, bind one current Stage 2 type and
  method shell per sealed declaration, prepare the same relation-derived plan
  with generated-only methods excluded, and compare methods, interface order,
  offsets, vtable entries and every `vfTableIdx` read-only.
- Boundary: Prepared CodeGen never installs or repairs this graph. A mismatch
  fails before globals, generated functions, relocations or detached bodies.

### CTA-IF-05 — native PreClass base was confused with script inheritance

- RED method:
  `PreparedNativeShadowBaseIsAuthenticatedAsPreClassRelation`.
- Root cause: a registered native base projected into the Canonical snapshot
  is a `canonical-native-type-view`; Stage 2 represents that relation through
  `shadowType`, not `derivedFrom`.
- Fix: preserve the projected native origin, compare one native edge with
  `shadowType`, and compare an authored script class base with `derivedFrom`.
- GREEN: the prepared fixture retains `shadowType`, has no script base, emits
  Canonical bytecode with zero legacy invocations, and executes `42`.

### CTA-IF-06 — failure could pollute source coordinates before graph rejection

- RED build: PASS at
  `Saved/Build/cta-prepared-source-metadata-red-build/20260829_213915_209_633fcfde/`.
- RED test: `0/1` at
  `Saved/Tests/cta-prepared-source-metadata-red/20260829_213943_030_d538addf/`.
- Root cause: Stage 2 shell binding called `FillFunctionSourceMetadata()`
  before dispatch authentication, so a later graph failure left coordinates
  on an otherwise unpublished function body.
- Fix: source metadata is written only after the Stage 2 body has been swapped
  for a detached `ScriptFunctionData` candidate. Rollback discards metadata
  with that candidate and restores the original empty shell.
- GREEN build: PASS at
  `Saved/Build/cta-prepared-source-metadata-green-build/20260829_214025_275_58c5e21a/`.
- GREEN test: `1/1` at
  `Saved/Tests/cta-prepared-source-metadata-green/20260829_214039_420_1efd867d/`.

### CTA-IF-07 — pure-constant flags escaped the prepared global transaction

- RED build: PASS at
  `Saved/Build/cta-prepared-pure-constant-red-build/20260829_214234_015_6dfca47b/`.
- RED test: `0/1` at
  `Saved/Tests/cta-prepared-pure-constant-red/20260829_214249_108_a6ad256f/`.
- Root cause: `property->isPureConstant` and the Builder description flag were
  set before the whole prepared module committed, but their original values
  were not in the rollback journal.
- Fix: journal and restore both flags on every failure; publish both flags and
  constant storage only in `CommitPreparedGlobals()`.
- GREEN build: PASS at
  `Saved/Build/cta-prepared-pure-constant-green-build/20260829_214331_625_365d0cee/`.
- GREEN test: `1/1` at
  `Saved/Tests/cta-prepared-pure-constant-green/20260829_214344_107_3ffb3c2c/`.

### CTA-IF-08 — Hot Reload kept two same-name Runtime generations alive

- First full Hot Reload result: `11/12`; original failure at
  `Saved/Tests/cta-interface-prepared-hotreload-canonical-green/20260829_214905_201_a6ddf9d3/`:
  `record 'UCanonicalASTPublisherReloadActor' has no exact Stage2 Runtime type`.
- Root cause: an old type stayed alive behind its snapshot lease while the new
  Builder type already existed. General stable-key lookup correctly saw two
  candidates, but Prepared authentication incorrectly used that general lookup
  to select the current producer's shell.
- First fix: capture `sClassDeclaration::canonicalASTStableDeclKey` from the
  exact Parser/Sema producer and use it to select the current Builder type.
- Follow-on RED: object binding passed, then generated destructor signature
  lowering failed with `error=-10` at
  `Saved/Tests/cta-prepared-hotreload-identity-focused-green/20260829_215316_812_0e226e0e/`.
- Follow-on root cause: later type resolution still enumerated both published
  generations.
- Final fix: construct `preparedRuntimeTypes` from the current module's
  classes, enums, typedefs and funcdefs and install it as the bridge transient
  view. Candidate types shadow published generations for this transaction;
  stable-key ambiguity inside the candidate set still fails closed.
- Focused GREEN: `1/1` at
  `Saved/Tests/cta-prepared-hotreload-transient-types-focused-green/20260829_215435_241_b2537bea/`.
- Full Hot Reload GREEN: `12/12` at
  `Saved/Tests/cta-interface-prepared-hotreload-canonical-final-green/20260829_215514_165_726c9f11/`.

This is the concrete answer to the dynamic TypeId concern for this slice:
durable identity is the Canonical stable type/declaration key plus the owning
snapshot/generation; the current generation resolves that identity into a
transient Runtime pointer/TypeId view. Numeric TypeId is never treated as
stable identity and an old generation cannot contaminate current candidate
selection.

## Final verification matrix

All paths below are post-Hot-Reload-fix results. ProductionCodeGen is a subset
of Compiler CanonicalAST, so counts are intentionally not summed as distinct
test definitions.

| Gate | Result | Evidence |
|---|---:|---|
| Runtime/Editor build | PASS | `Saved/Build/cta-prepared-hotreload-transient-types-green-build/20260829_215423_285_6daf2ef4/` |
| ProductionCodeGen | 135/135 | `Saved/Tests/cta-interface-prepared-production-post-hotreload-green/20260829_215608_598_5a625799/` |
| StaticJIT PrimaryCanonicalASTGenerate | 12/12 | `Saved/Tests/cta-interface-prepared-staticjit-post-hotreload-green/20260829_215645_823_cc740cc0/` |
| Compiler CanonicalAST | 614/614 | `Saved/Tests/cta-interface-prepared-compiler-post-hotreload-green/20260829_215802_606_d5dc5a3a/` |
| Frontend CanonicalAST | 175/175 | `Saved/Tests/cta-interface-prepared-frontend-post-hotreload-green/20260829_215844_941_700b4ed4/` |
| Module CanonicalAST Snapshot | 10/10 | `Saved/Tests/cta-interface-prepared-module-post-hotreload-green/20260829_215919_476_7d6b0785/` |
| Sema interface relations | 6/6 | `Saved/Tests/cta-interface-final-sema-post-hotreload-green/20260829_220010_190_63897577/` |
| Production interface dispatch | 9/9 | `Saved/Tests/cta-interface-final-production-post-hotreload-green/20260829_220041_857_e57f61cc/` |
| Cache ASTBodySidecar V8 | 23/23 | `Saved/Tests/cta-interface-final-sidecar-v8-post-hotreload-green/20260829_220113_331_d6d67c0b/` |
| Hot Reload Canonical snapshot | 12/12 | `Saved/Tests/cta-interface-prepared-hotreload-canonical-final-green/20260829_215514_165_726c9f11/` |

The StaticJIT run emitted only the known external `generate_204` connectivity
warnings; no test failed, skipped or timed out.

## Source and invariant audit

- `IsSignatureExceptNameAndReturnTypeEqual` and `DoesMethodExist` are absent
  from `as_bytecode_codegen.cpp` after the final scan.
- Complete-signature equality remains only in the dedicated inherited
  interface-method inventory merge that preserves the legacy observable
  de-duplication shape. It does not select a class implementation or relation
  target; sealed `methodRelations` have already selected those endpoints.
- Every authored `BASE_OVERRIDE` and `INTERFACE_IMPLEMENTATION` target is found
  through exact declaration bindings.
- Prepared graph authentication compares existing Stage 2 arrays but never
  swaps, appends, repairs or commits them.
- Native `asCScriptNode` is not read by the dispatch planner or verifier.
- Failure before publication leaves body bytecode, source metadata, pure-
  constant flags/storage, publisher, digest and last-good generation intact.

## Scope and non-claims

- Product default remains LEGACY.
- Native AngelScript Parser/Builder/Compiler and `asCScriptNode` remain for
  LEGACY, reference, syntax/recovery, differential validation and rollback.
- HIR remains physically absent.
- Public AST V1 is unchanged.
- No production `dual` backend or silent CANONICAL-to-LEGACY fallback exists.
- Standalone is deferred and untouched.
- Dumps remain diagnostic observers. AOT/StaticJIT consumers can consume the
  sealed AST/snapshot directly; a dump is not an intermediate compiler format.
- Dynamic Runtime TypeId is not redesigned product-wide here. This slice proves
  the stable-key + generation-local projection model for Prepared Canonical
  type/function/interface publication and Hot Reload.
- Stored capturing closures, exception tables, the complete language/lifetime
  matrix, remaining semantic adapters and default cutover still own the broad
  unchecked OpenSpec tasks.

## Publication commits

- Final prepared-path plugin implementation:
  `e474dc4 [CanonicalAST] Refactor: authenticate prepared interface dispatch`.
- Parent gitlink/OpenSpec record: committed immediately after the plugin in the
  required dual-repository order.
