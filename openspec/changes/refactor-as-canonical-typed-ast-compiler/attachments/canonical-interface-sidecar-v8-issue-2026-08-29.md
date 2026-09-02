# Canonical interface method relation Sidecar V8 issue — 2026-08-29

## Status

- Scope: Approach A, Task 2 — authenticate, traverse, dump, hash, and persist the exact method relations sealed by Canonical Sema.
- Producer baseline: plugin commit `cbd49ce` (`[CanonicalAST] Refactor: seal exact interface method relations`).
- Implementation: plugin commit `adedb56` (`[CanonicalAST] Refactor: verify and preserve interface method relations`).
- Schema introduced and verified by this issue: Canonical AST Sidecar V8.
- Result: Task 2 is implemented and verified. V8 append-only transport, three-phase verification, deterministic inspection, diff/digest material, and exact round-trip preservation are green.
- Remaining boundary: Runtime projection and atomic publication are still Approach A Tasks 3–5; this issue does not make CANONICAL the default.
- Standalone remains explicitly deferred and is outside this issue.

## Observed defect

Canonical Sema now seals record-owned `asSASTMethodRelation` entries whose pointer-free fields identify:

1. the implementation `MethodDecl`;
2. the overridden or interface-requirement `MethodDecl`;
3. the semantic relation kind (`BASE_OVERRIDE` or `INTERFACE_IMPLEMENTATION`).

The V7 Sidecar declaration DTO serialized declaration dependencies and bases, but had no method-relation payload. Encoding a valid sealed snapshot therefore succeeded while silently omitting an irreducible Sema fact. Decoding the same payload produced a structurally valid snapshot whose record had zero method relations. This was unsafe because downstream CodeGen could otherwise fall back to name/signature reconstruction after detachment, reintroducing a second semantic decision point.

Before `adedb56`, the same fact was absent from generic AST traversal and deterministic dump. The verifier therefore could not authenticate owner, ancestry, signature, uniqueness, or interface completeness, and tooling could not observe the missing relation.

## RED evidence

### Build authoring gate

- Command: `Tools\RunBuild.ps1 -Label cta-interface-task2-red-build-2 -TimeoutMs 1800000`
- Result: succeeded.
- Evidence: `Saved/Build/cta-interface-task2-red-build-2/20260829_193804_388_14aeffc7/`

This confirms the failing results below are behavior failures rather than test compilation failures.

### Verifier, traversal, and dump

- Command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label cta-interface-verifier-red -TimeoutMs 600000`
- Result: `49/51 PASS`, `2 FAIL`, `0 SKIP`.
- Evidence: `Saved/Tests/cta-interface-verifier-red/20260829_193823_203_954da37e/`.
- Expected failing tests:
  - `TraversalNamesMethodRelationImplementationAndRequirementEdges`
  - `VerifierRejectsForeignWrongOwnerWrongSignatureAndDuplicateMethodRelations`

The verifier test reports that the current verifier incorrectly accepts all four forged cases:

- a `VarDecl` owning a method relation;
- an unrelated interface requirement outside the owner interface closure;
- implementation and requirement methods with different exact Canonical signatures;
- two competing implementations for one requirement.

The traversal test additionally proves that the implementation/requirement references and `method-relations=` dump section are absent.

### Sidecar loss

- Command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.InterfaceDispatch" -Label cta-interface-sidecar-red -TimeoutMs 600000`
- Result: `5/6 PASS`, `1 FAIL`, `0 SKIP`.
- Evidence: `Saved/Tests/cta-interface-sidecar-red/20260829_193857_895_34bdaf36/`.
- Expected failing test: `SidecarRoundTripPreservesExactMethodRelations`.
- Stable failure assertion: `Sidecar must not erase an irreducible Sema relationship`.

The other five Sema authority tests remain green, so the defect is isolated to observation/authentication/persistence and not to Task 1 relation production.

### Follow-on verifier REDs

The initial RED matrix exposed the missing relation layer. Focused forged-graph follow-ups then prevented a superficially green implementation from admitting invalid endpoint types or ancestry:

- `Saved/Tests/cta-interface-verifier-contract-red/20260829_195543_506_f85a51fe/`: `50/51 PASS`, with interface executable body/cycle/direct-duplicate cases still admitted before the contract extension.
- `Saved/Tests/cta-interface-verifier-qualtype-red/20260829_195647_257_3e1069b8/`: exact `0/1`, proving two dangling-but-equal `QualType` values could otherwise pass signature equality.
- `Saved/Tests/cta-interface-class-ancestry-red/20260829_200323_630_a36c5284/`: exact `0/1`, proving class cycles were misclassified as interface incompleteness and that multiple direct class bases plus an interface inheriting a class were still admitted.

These were expected REDs. They are retained as subcases of `VerifierRejectsForeignWrongOwnerWrongSignatureAndDuplicateMethodRelations` and now require exact stable detail tokens rather than accepting an arbitrary `method-relation-*` prefix.

## GREEN and repeat evidence

### Build

- Command: `Tools\RunBuild.ps1 -Label cta-interface-class-ancestry-green-build -TimeoutMs 600000`
- Result: succeeded, exit code `0`.
- Evidence: `Saved/Build/cta-interface-class-ancestry-green-build/20260829_200615_393_e8a9e719/`.

### Complete verifier/traversal/dump prefix

- Command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label cta-interface-class-ancestry-green -TimeoutMs 600000`
- Result: `51/51 PASS`, `0 FAIL`, `0 SKIP`.
- Evidence: `Saved/Tests/cta-interface-class-ancestry-green/20260829_200628_881_3a935468/`.

The green matrix authenticates local `QualType` validity before signature equality; declaration owner/kind; class single-inheritance and cycle rules; interface base kind, cycle, and duplicate authored direct bases; relation endpoint owner/ancestry/kind/signature; one implementation per requirement; and complete interface coverage. A legal interface diamond with one shared transitive base remains accepted and is deduplicated by declaration identity.

### Exact Sema relation and Sidecar V8 repeat

- Command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.InterfaceDispatch" -Label cta-interface-task2-sidecar-repeat -TimeoutMs 600000`
- Result: `6/6 PASS`, `0 FAIL`, `0 SKIP`.
- Evidence: `Saved/Tests/cta-interface-task2-sidecar-repeat/20260829_200706_809_9ea65549/`.

The round-trip fixture contains both a base override and an interface implementation. It proves source encode determinism, exact decoded triples/order, byte-identical decoded re-encode, and exact tree/JSON/compatibility dump plus traversal edge names. It never reconstructs a target by textual name.

### Runtime Cache wrapper regression

- Command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.ASTBodySidecar" -Label cta-interface-task2-cache-repeat -TimeoutMs 600000`
- Result: `23/23 PASS`, `0 FAIL`, `0 SKIP`.
- Evidence: `Saved/Tests/cta-interface-task2-cache-repeat/20260829_200753_005_796369ff/`.

The maintained-fork schema constant and `FAngelscriptCacheASTBodySidecar::SchemaVersion` both read V8. Older schemas remain explicit safe misses; no V7-to-V8 semantic guessing was added.

## V8 schema requirement

Sidecar V8 shall append method relations to each declaration DTO without changing the meaning or order of existing V7 fields. Each relation is a pointer-free triple:

```text
relation-kind
implementation-decl-id
requirement-decl-id
```

The encoded IDs remain snapshot-local references inside one Sidecar payload. Decode must remap both endpoints to the restored snapshot after all declarations have been allocated; no raw AST pointer, runtime function pointer, numeric Runtime function ID, numeric TypeId, `vfTableIdx`, or interface offset may enter the payload.

Required decoder behavior:

- accept only schema V8 for the V8 reader;
- fail closed on an unsupported/older schema as the existing safe-miss contract requires;
- bounds-check relation counts and enum values before applying them;
- require both endpoint IDs to resolve to declarations in the decoded snapshot;
- apply relations only after every declaration exists and the declaration ID map is complete;
- preserve producer insertion order exactly;
- reject duplicate/forged relation payloads through context construction and final verification;
- abandon the candidate snapshot on any failure and never publish a partial relation set.

V7 payloads are not upgraded by guessing relations from names or signatures. Their safe outcome is an explicit cache/Sidecar miss followed by a fresh source compile.

## Verifier contract

Before sealing or publication, every method relation must satisfy all of the following:

- owner is a `Class` or `Interface` declaration from the same snapshot;
- relation kind is known;
- implementation and requirement endpoints are distinct `Method` declarations from the same snapshot;
- return and every parameter `QualType` is valid, snapshot-local, resolves to a type in the same context, and carries valid qualifiers before equality is considered;
- endpoint signatures match exactly by Canonical name, return `QualType`, const trait, and ordered parameter `QualType` sequence;
- a class has at most one direct class base and its class ancestry is acyclic;
- an interface never inherits a concrete class;
- interface ancestry rejects cycles and duplicate authored direct base edges, while a shared transitive base in a legal diamond is deduplicated by identity;
- an interface method is declaration-only: no executable body, initializer plan, or persisted backend state is accepted;
- `BASE_OVERRIDE` points from an owner method to a requirement in the owner's class ancestry;
- `INTERFACE_IMPLEMENTATION` points from a method owned by the owner or its class ancestry to a requirement owned by an interface in the owner's transitive interface closure;
- no exact triple is duplicated;
- one requirement has exactly one selected implementation for the owner;
- every method requirement in the owner's transitive interface closure has exactly one authenticated relation.

Diagnostics use stable `method-relation-*` details so tests and reports do not depend on rendered prose.

Verification is deliberately ordered in three passes: authenticate the generic declaration graph; authenticate record ancestry/shape and each authored relation; only then check concrete-class interface completeness. This prevents a forged endpoint or invalid ancestry from being masked by an earlier `method-relation-interface-incomplete` result.

## Traversal, dump, diff, and digest contract

The generic traversal shall expose two named reference edges for every relation in insertion order:

- `decl-method-relation-implementation[index]`
- `decl-method-relation-requirement[index]`

Both carry the relation index. Structured dump, compatibility dump, diff, structural hash/digest material, and any declaration fingerprint must include relation kind and both endpoints in the same deterministic order. Rendered dump text remains diagnostic output and must not become the transport or the source of semantic reconstruction.

## Non-claims and follow-up boundary

Closing Task 2 in this issue proves that exact Sema relations survive verification and Sidecar detachment. It does not yet prove that Runtime interface tables are derived from them, that all publication plans are transactional, or that CANONICAL is ready to replace LEGACY by default. Those remain Approach A Tasks 3–5.

The native AngelScript AST/Parser/Builder/Compiler remains available behind LEGACY selection for compatibility, reference, differential validation, and rollback. HIR remains deleted and must not be recreated as a relation transport.
