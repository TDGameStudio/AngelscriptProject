# Task 7 StaticJIT diagnostics field audit

## Scope

This audit maps the task-7 diagnostic contract to the current pointer-free
generation output, generated Provider ABI/catalog, live Engine route snapshot,
and the separate developer HIR dump. It exists to prevent a second diagnostic
store or JSON fields whose production source has already been discarded.

## Existing authoritative sources

### Developer HIR dump

`AngelscriptHIRDump` already owns a deliberately restricted result model:

- request kind is only `DeveloperHIRDump`;
- target profile, complete graph identity, artifact profile, filters, capture
  counts, verifier state and normalized output paths are present;
- BackendId, Provider entries, fallback, runtime routes and execution counters
  are absent by construction.

This already satisfies the separation half of task 7.2. StaticJIT artifact
diagnostics must not extend or reuse this result as a generated-Provider claim.

### Backend-neutral generation output

`FAngelscriptStaticJITGeneratorOutput` already owns pointer-free task facts:

- requested backend, capture profile and ordered fallback chain;
- complete compiled-source-graph counts and verified-HIR presence;
- task error;
- per-function stable key, actual backend, emitted/unsupported/failed
  disposition, deterministic detail, emitted entry plan, and ordered backend
  attempts.

The TypedAST backend also computes richer structured facts before returning:
root/helper eligibility, exact fallback enum and source span, raw traits,
normalized invocation/receiver, required/available capabilities, recursion
components, and per-call disposition/linkage validation. Most of these are
currently collapsed into `Detail` or discarded when the backend result crosses
the generator boundary.

### Generated Provider and live route snapshot

The Provider catalog currently retains stable identity, entry kinds,
capability/profile hashes, references, native call-site metadata and entry
pointers. `FStaticJITDiagnostics` schema 4 combines that catalog with current
Engine route adoption, stable reference resolution and execution counters.

It does not retain:

- requested or actual backend;
- capture/HIR/root/helper/trait/receiver facts;
- structured TypedAST fallback reason/span;
- backend attempts for a Bytecode fallback;
- functions that produced no Static entry;
- structured exception/cleanup or call-closure diagnostics.

Consequently the live dump cannot recover these facts from current routes, and
must not infer them from declaration text, generated symbol spelling, or
free-form detail strings.

## Required ownership seam

Task 7 needs one pointer-free function diagnostic record produced while the
generation Engine and HIR still exist. The record must cross the backend-neutral
generator boundary without parsing prose. After packaging, the same record must
be available in two forms:

1. generation result diagnostics, including failures that prevent Provider
   publication;
2. immutable generated Provider diagnostic metadata for every packaged
   function row, copied into the Runtime registry catalog for live dumps.

BackendId remains diagnostic metadata. It is not added to stable function,
content, profile, Entry ABI, artifact-set, or route identity. Display strings
remain metadata and never participate in dispatch.

Adding a generated Provider diagnostic table changes the Provider view layout,
so task 7.3 must confirm and bump the Provider ABI exactly once. It should not
create a TypedAST-only provider namespace: Bytecode and TypedAST rows share the
same backend-neutral record and stable identity.

## Incremental TDD slices

Completed on 2026-08-16:

1. Add generation-diagnostic serialization tests beneath
   `StaticJIT/AOT/Diagnostics/` for request kind, requested backend, capture
   state, actual backend, entry disposition, ordered attempts and stable order.
2. Preserve structured TypedAST function diagnostics across backend attempt and
   generator aggregation; cover the exhaustive fallback enum without parsing
   `Detail`.
3. Add source provenance, root/helper/trait/receiver, capability,
   exception/cleanup diagnostic fields from the existing closure plan.
4. Add per-call lowering/linkage/source rows from the closure plan and enrich
   them with the actual emitted C++ call-site metadata. The record keeps all
   dispositions, exact generated/direct/Runtime-core/registered spellings,
   stable key/ABI/slot identity, typed linkage and callee-rejection details,
   mandatory processed source and explicit optional authored/generated source.

5. Attach the backend-neutral diagnostic catalog to generated Provider output,
   validate/copy it at registration, and expose it through the live snapshot.
6. Combine Provider diagnostic rows with current route/reference/counter state
   in `as.StaticJIT.DumpDiagnostics`; retain HIR dump separation and Shipping
   exclusion.

Steps 5-6 completed on 2026-08-16. The live snapshot schema is revision 9 and
stores the Registry-owned immutable catalog beneath each Provider as
`generationDiagnostics`. Serialization nests function, ordered backend
attempt, semantic closure and call rows while the sibling Provider
entry/reference/route/counter records retain current adoption state. Function
queries remove unrelated diagnostic function rows without reordering the
catalog's immutable dependent ranges. The real `AngelscriptTestJIT` Provider
and console command output are covered by a bounded no-new-Engine test.

7. Add Editor-side authority/containment failure records to the generation
   result path. These pre-publication failures are not fabricated as loaded
   Provider state.

Step 7 completed on 2026-08-16. The Editor refresh path records an actual
`AuthoritativeEngineStale` result before preparation/generation, while the
injected containment-monitor seam proves a typed
`GenerationContainmentFailure` result cannot call the generator, backend,
Provider registration, or route publication. The pre-publication record
advanced the live diagnostics schema to revision 9; it remains a generation
result and is never represented as a loaded Provider catalog row.

## Stable source identity and backend-neutral execution identity

The real TestJIT provider fixed-point check found one diagnostics-only source
of non-determinism: captured spans used the isolated test Engine's absolute
`Saved/Automation/AngelscriptTestJITGeneration/<GUID>/Script` directory. The
Provider manifest and owned inventory were stable, but those process-local
paths changed the rendered Provider C++ through structured source fields and
the eligibility detail string.

Generation diagnostics now map spans through the frozen graph's authoritative
module descriptor/code-section view and persist `/Angelscript/Game/*.as`
virtual paths for the test fixtures. The free-form detail uses the same stable
source prefix. The finalized generated Provider contains no drive-letter or
random test-root path. This is a normalization fix within the existing
Provider ABI-7 diagnostic catalog and `FStaticJITDiagnostics` schema revision
9. The source normalization itself did not change either layout or vocabulary;
the later pre-publication failure record is what advanced the diagnostics
schema from 8 to 9, while Provider ABI 7 remained unchanged.
bumped.

Task 7.4 also reuses the real two-run generation-verification session to prove
BytecodeJIT and TypedASTJIT agree on FunctionKey, execution/content hash, debug
hash, ArtifactProfile and EntryAbi hash. BackendId remains diagnostic metadata
and does not create a second identity namespace. Final evidence is
`Saved/Tests/typed-aot-provider-identity-green-03/20260816_174750_272_ac8d5a1c/`
(`1/1 PASS`).

## Test-file boundary

- `AOT/Diagnostics/AngelscriptStaticJITAotGenerationDiagnosticsTests.cpp`
  owns steps 1-3 and pre-publication failure records.
- `AOT/Diagnostics/AngelscriptStaticJITAotCallDiagnosticsTests.cpp` owns the
  pointer-free per-call lowering/linkage/source record and deterministic JSON
  mapping. It does not start an Engine; real feed coverage stays in the shared
  generation-verification session.
- `AOT/Diagnostics/AngelscriptStaticJITAotInstalledDiagnosticsTests.cpp`
  owns generated Provider/catalog/route joins.
- `AOT/Diagnostics/AngelscriptStaticJITAotCommandDiagnosticsTests.cpp`
  owns deterministic JSON, filtering and console-command output.
- a small diagnostics fixture bridge/support unit may share the already-created
  AOT Engine session; scenario bodies remain in the files above.

## Final task-7.1/7.2 verification

The final bounded diagnostics plus real Editor refresh run passed all 26
methods:

- `Saved/Tests/typed-aot-task7-diagnostics-refresh-audit/
  20260816_180019_246_0b5971a6/` — `26/26 PASS` for
  `Angelscript.TestModule.StaticJIT.AOT.Diagnostics` plus
  `Angelscript.TestModule.StaticJIT.RefreshService`.

Formal Shipping exclusion was then verified through the product path, not only
the in-memory emitter test:

- `Saved/Commandlet/typed-aot-task7-gameshipping-generate-04/
  20260816_180344_909_9f542042/` — official
  `AngelscriptJIT -Mode=Generate -Profile=GameShipping` completed with exit
  code zero and produced the worktree-owned GameShipping Provider plus eight
  independent module `.jit.cpp` files;
- a recursive text scan of `Source/AngelscriptJIT/Generated/GameShipping`
  found none of `AngelscriptJITProviderDiagnostics`,
  `GProviderDiagnostics`, `generationDiagnostics`, `DiagnosticDigest`,
  `EligibilitySource`, `ProcessedSource`, `FallbackReason`, or
  `TypedDiagnostic`;
- `Saved/Build/typed-aot-task7-gameshipping-build/
  20260816_180500_724_6d8639ac/` — actual
  `AngelscriptProject Win64 Shipping` build compiled `Provider.generated.cpp`
  and all eight GameShipping `.jit.cpp` units, linked
  `AngelscriptProject-Win64-Shipping.exe`, and finished `104` actions with
  `Result: Succeeded` and process exit code zero.

The first correct-profile publication attempt found a foreign-owner
GameShipping directory left by the main checkout. It was moved recoverably,
not deleted, to
`Saved/AngelscriptJITTransient/task7-gameshipping-foreign-owner-20260816_180337`
before the worktree-owned profile was generated. This preserves worktree
isolation and explains the expected owner-mismatch refusal without weakening
the publication guard.

Tasks 7.1 and 7.2 are complete. `AngelscriptHIRDump` remains a separate
developer-only schema with no Provider/backend/fallback/execution claims, and
no testing-only Engine API or pointer-based persistent identity was introduced.
