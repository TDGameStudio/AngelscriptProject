# Canonical source-provenance retention gate — 2026-08-27

## Outcome

CTA-HIR-04 closes the generated-source provenance gap exposed when the Editor
HIR dump surface was deleted. Neutral authored/generated provenance is now
owned by the Canonical source session, survives optional `ASTBodySidecar`
restore, and remains available to snapshot-owned diagnostics without
re-running preprocessing or Sema.

This is a bounded prerequisite for TypedSemantic HIR deletion. It does **not**
complete Task 10.5: compiler HIR capture/storage/accessors, TypedASTJIT HIR
compatibility, HIR-era diagnostics/tests and Standalone HIR wiring still exist.
It also does not remove or weaken AngelScript's native `asCScriptNode`, Parser,
`asCBuilder`, `asCCompiler`, parser tests, or explicit LEGACY pipeline. Those
remain the syntax-coverage/reference/compatibility/rollback path required by
the revised scope.

## Authority and identity boundary

The implemented ownership chain is:

```text
preprocessor/generated source
  -> asCScriptCode::sourceProvenanceRanges
  -> Parser/Sema source session
  -> asCSourceManager-owned copied ranges
  -> sealed Canonical AST snapshot
  -> optional ASTBodySidecar V6
  -> restored asCSourceManager
  -> ResolveSourceSpan authored/generated diagnostic provenance
```

The processed source tuple remains authoritative. `ResolveSourceSpan` only
attaches authored/generated provenance when the requested span is contained by
one validated provenance range; it never relabels processed coordinates as
authored coordinates.

Provenance is **diagnostic metadata**, not semantic function identity:

- `AppendRangeIdentity` continues to hash the processed logical source,
  source class, line offset, source slice and semantic graph facts;
- authored/generated anchor changes do not alter
  `asSASTSidecarRecordId::contentHash`;
- V6 changes the complete sidecar payload/schema bytes because the DTO now
  carries more snapshot data, but it does not redefine function semantic
  identity or incremental dependency identity;
- public numeric TypeId, stable type keys, ABI keys and generation-local
  Runtime bindings are unchanged.

## Implementation

### Canonical SourceManager ownership

- `asCSourceManager::AddSection` and `RemapLogical` copy and validate neutral
  `asSSourceProvenanceRange` records.
- Exact logical remap equality includes provenance so the same snapshot-local
  FileID cannot silently retain stale authored/generated coordinates.
- `ResolveSourceSpan` returns processed coordinates plus the applicable
  authored/generated chain.
- const copy-out observation APIs expose provenance to the sidecar encoder
  without exposing mutable section storage.
- `asCASTContext`, `asCSema::PrepareParsedSource` and Builder diagnostic source
  sessions pass the neutral ranges through. Reuse of an existing source
  session verifies bytes, line mapping and provenance together.

### Pointer-free sidecar V6

`asAST_SIDECAR_SCHEMA_VERSION` and
`FAngelscriptCacheASTBodySidecar::SchemaVersion` move from V5 to V6 together.
Each source record now serializes:

- processed offset and length;
- optional authored section/offset/length/row/column;
- optional generated kind/name;
- optional generated-to-authored anchor.

Decode bounds the range count, validates presence flags and generated-kind
values, reconstructs neutral records, and delegates range/order/buffer bounds
to SourceManager admission. Malformed or truncated data resets the unsealed
candidate and fails closed. The previous V5 payload is an explicit safe miss;
there is no compatibility reinterpretation and no HIR reconstruction.

## TDD evidence

### SourceManager RED

The first SourceManager/provenance tests were added before the production API:

- `NeutralGeneratedProvenanceIsOwnedAndResolvedByCanonicalSourceManager`;
- `RemapRejectsChangedProvenanceForExistingLogicalSource`;
- `ParserSemaCopiesScriptCodeProvenanceIntoCanonicalSourceSession`.

The RED build failed only because the required SourceManager/ASTContext APIs
did not exist:

`Saved/Build/cta-canonical-provenance-red/20260827_182237_161_72d76310/RunMetadata.json`.

### Restore RED

`SidecarRoundTripPreservesNeutralSourceProvenance` encoded and decoded a sealed
Canonical context, then required the restored span to retain both authored and
generated origins. The test build passed:

`Saved/Build/cta-canonical-provenance-sidecar-red-build/20260827_183023_816_1f3af9e0/RunMetadata.json`.

The test failed exactly because V5 restored the processed source but not the
authored origin:

`Saved/Tests/cta-canonical-provenance-sidecar-red/20260827_183047_175_ff90f8d1/RunMetadata.json`.

### Permanent boundary tests

- `SidecarRoundTripPreservesNeutralSourceProvenance` proves V6 round-trip.
- `MalformedSourceProvenanceFailsClosed` corrupts a provenance presence flag
  and proves no partial source model is published.
- `SourceProvenanceIsDiagnosticOnlyForFunctionRecordIdentity` builds identical
  semantic graphs with different authored anchors and proves equal function
  record hashes.
- `UnsupportedSidecarVersionIsRejectedWithoutHirBytes` explicitly injects the
  previous V5 version and proves both full decode and input admission reject it
  as a safe miss.

## GREEN evidence

- Full Runtime/Editor build after the V6 implementation: PASS —
  `Saved/Build/cta-canonical-provenance-sidecar-green-build/20260827_183445_426_016c04f5/RunMetadata.json`.
- Final incremental build after identity/malformed boundaries: PASS —
  `Saved/Build/cta-canonical-provenance-sidecar-boundary-build-fix1/20260827_184058_675_a5853faa/RunMetadata.json`.
- Explicit V5 safe-miss test build: PASS —
  `Saved/Build/cta-canonical-provenance-sidecar-v5-miss-build/20260827_184654_972_81e83e39/RunMetadata.json`.
- Exact restore RED converted to **1/1 PASS** —
  `Saved/Tests/cta-canonical-provenance-sidecar-green-exact/20260827_183801_157_b69fa04d/RunMetadata.json`.
- Final Cache ASTBodySidecar group: **21/21 PASS** —
  `Saved/Tests/cta-canonical-provenance-sidecar-final-prefix/20260827_184718_480_2e435ca1/RunMetadata.json`.
- Canonical SourceManager: **12/12 PASS** —
  `Saved/Tests/cta-canonical-provenance-source-manager-final/20260827_184210_655_88c8a7c7/RunMetadata.json`.
- Neutral ScriptCode ownership: **3/3 PASS** —
  `Saved/Tests/cta-canonical-provenance-ownership-final/20260827_184247_841_72d64800/RunMetadata.json`.
- Real Preprocessor generated provenance: **2/2 PASS** —
  `Saved/Tests/cta-canonical-provenance-preprocessor-final/20260827_184325_583_0c168b0c/RunMetadata.json`.
- Standalone Debug maintained-fork build and CTest: **21/21 PASS** —
  `Saved/StandaloneTests/cta-canonical-provenance-sidecar-final_01_Standalone/20260827_184407_997_70538cb5/RunMetadata.json`.

Standalone still compiles and runs its existing TypedSemanticIR target. That is
honest evidence that HIR physical deletion is not complete, not a reason to
retain HIR permanently. The native CanonicalAST/Compat/Frontend tests also pass
and preserve the retained native Parser/compiler coverage.

## Problems encountered

### CTA-HIR-DUMP-05 — Canonical snapshot lost generated provenance after restore

Deleting the Editor HIR dump removed the only E2E assertion for generated
literal/subsystem authored-origin chains. Neutral ScriptCode propagation
existed, but Canonical SourceManager originally owned only logical/origin/bytes/
line mapping, and V5 sidecar restore therefore lost the diagnostic chain.

**Status:** resolved by SourceManager ownership plus V6 serialization. HIR was
not reintroduced.

### CTA-HIR-PROV-01 — first GREEN build hit the wrapper's short timeout

The first complete post-SourceManager build reached roughly 150 of 171 actions
without a compiler error, then hit the default 180-second wrapper timeout:

`Saved/Build/cta-canonical-provenance-green/20260827_182406_756_9fad88e3/RunMetadata.json`.

The supported runner was repeated with a 600-second timeout and passed:

`Saved/Build/cta-canonical-provenance-green-fix1/20260827_182714_871_5e882f56/RunMetadata.json`.

This is validation-infrastructure timing, not accepted product evidence or a
compiler failure.

### CTA-HIR-PROV-02 — boundary test used a nonexistent verifier enum

The first build after adding the identity/malformed boundary tests failed only
because the test helper returned nonexistent
`asAST_VERIFY_INVALID_SOURCE_RANGE`:

`Saved/Build/cta-canonical-provenance-sidecar-boundary-build/20260827_184035_613_034cf484/RunMetadata.json`.

The helper now returns an ordinary local failure code; the production V6 code
was unchanged by this repair. The immediate rebuild passed at the `fix1` path
listed above.

### CTA-HIR-PROV-03 — several read-only scans used invalid paths/globs

Several audit commands were rejected and supplied no evidence:

- an OpenSpec scan named nonexistent `review` and attachment paths instead of
  the real `reviews/` paths;
- an initial fork scan assumed `Source/angelscript/source` instead of the real
  `Source/AngelscriptRuntime/ThirdParty/angelscript/source`;
- a schema scan launched from the plugin submodule also named parent-only
  `Documents/` and `openspec/` paths;
- two Windows `rg` commands used wildcard path components such as
  `as_ast*`/`as_source*`, producing `os error 123`.

Each command was treated as invalid, and no source conclusion relied on its
output. Corrected directory-root or explicit-file scans were used for the
actual inventory. `AngelscriptCacheDiagnostics.h::CurrentSchemaVersion == 5`
was inspected as a different diagnostics schema and was not incorrectly
bumped with ASTBodySidecar.

## Non-claims and next gate

- Task 10.5 remains unchecked; HIR still exists and is still built/tested.
- The headline remains **72%** and the literal count remains **86/125 checked,
  39 open**.
- Compiler default remains LEGACY; Cache V2 remains default-disabled.
- No native AST/Parser/Builder/Compiler file is a deletion target in this
  change.
- This slice does not prove structured diagnostic presentation of every
  provenance field; it proves snapshot ownership, span resolution and optional
  sidecar restoration.
- Next HIR work must migrate remaining TypedASTJIT/test/diagnostic consumers,
  remove temporary HIR aliases and capture/storage/accessors, then delete
  `as_typed_semantic_ir.h/.cpp` and build wiring in one verified sequence.

