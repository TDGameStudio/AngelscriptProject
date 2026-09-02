# HIR Editor Dump Retirement Gate — 2026-08-27

## Scope

CTA-HIR-03 removes the Editor-only `AngelscriptHIRDump` command and
Commandlet surface as one independently verifiable part of Task 10.5. It does
not remove AngelScript's native `asCScriptNode`, Parser, `asCBuilder`,
`asCCompiler`, or the explicitly selected LEGACY compiler path. The supported
read-only compiler diagnostic surface is the Canonical AST diagnostics service
(`as.AST` / `UAngelscriptASTDiagnosticsCommandlet`).

## TDD gate

The Standalone architecture test was changed first to require:

- the Canonical AST diagnostics source to remain present;
- `AngelscriptHIRDumpCommand.{h,cpp}` to be absent;
- `AngelscriptHIRDumpCommandlet.{h,cpp}` to be absent;
- the dedicated HIR dump Commandlet test file to be absent.

The RED run completed **20/21 PASS** and failed only
`AngelscriptStandalone.Architecture`, listing those five still-present files:

`Saved/StandaloneTests/cta-hir-editor-dump-red_01_Standalone/20260827_180135_137_f8f188a4/RunMetadata.json`

This was the expected removal failure. It was not accepted as regression
evidence.

## Production and test changes

The following surfaces are physically deleted:

- `Source/AngelscriptEditor/StaticJIT/AngelscriptHIRDumpCommand.h/.cpp`;
- `Source/AngelscriptEditor/StaticJIT/AngelscriptHIRDumpCommandlet.h/.cpp`;
- `Source/AngelscriptTest/StaticJIT/AngelscriptHIRDumpCommandletTests.cpp`;
- the HIR-dump-only generated-source-provenance integration test under
  `AngelScriptSDK/Compiler/TypedSemanticIR/SourceProvenance/`.

With the second consumer gone, `FAngelscriptProjectSourceGraphCompileRequest`
no longer carries a one-value request-kind discriminator. The
`DeveloperHIRDump` enum value, HIR-specific scratch owner, and conditional
generation-profile branch are removed. ProjectSourceGraph is now the single
StaticJIT artifact compile service and always freezes its explicit Bytecode or
VerifiedCanonicalAST generation profile.

Two valuable behaviors previously reached only through the HIR dump wrapper
were retained without the wrapper:

1. `ProjectSourceGraphSuccessAndCompileFailurePreserveCompletePrimaryContainmentSnapshot`
   directly compiles the contained source graph, proves the consumer sees a
   complete retained Canonical snapshot, proves a failed compile never runs the
   consumer, verifies scratch cleanup, and checks both operations leave the
   primary Engine containment snapshot unchanged.
2. `PrimaryRetainedAstLeaseRemainsCurrentBeforeMatchingGeneration` acquires a
   public V1 lease from the real primary module, proves it is current and has a
   generation key, releases it, and then proves matching-profile generation
   still succeeds.

The old output-file persistence and HIR text/JSON formatting assertions were
not migrated because their product surface was deliberately deleted. Existing
Canonical AST diagnostics tests own list/dump/query/verify/diff formatting and
lease coverage.

## GREEN evidence

Runtime/Editor and the aggregate test module build successfully after UHT
noticed the removed Commandlet class:

`Saved/Build/cta-hir-editor-dump-green-build/20260827_180803_109_beba3007/RunMetadata.json`

The two migrated behavioral gates are **2/2 PASS**:

`Saved/Tests/cta-hir-editor-dump-migrated-tests/20260827_181202_460_de61bd10/RunMetadata.json`

The existing ProjectSourceGraph group is independently **2/2 PASS**:

`Saved/Tests/cta-hir-editor-dump-green-tests/20260827_181118_108_fb6aed8b/RunMetadata.json`

That first combined prefix did not select the two migrated CQTest methods
because their discoverable paths contain the test-class segment; its 2/2
result is recorded only as the existing ProjectSourceGraph regression. The
complete discovered paths were used by the separate migrated-tests run.

Standalone then rebuilt the maintained fork and completed **21/21 PASS**,
including the new physical-absence architecture gate:

`Saved/StandaloneTests/cta-hir-editor-dump-green_01_Standalone/20260827_181256_238_069819ea/RunMetadata.json`

Final source scans report:

- all five architecture-gated HIR dump paths are absent;
- zero `AngelscriptHIRDump` or `DeveloperHIRDump` symbols under active
  `Source` inputs;
- zero `EAngelscriptProjectSourceGraphRequestKind` symbols.

The Standalone architecture test intentionally retains the deleted paths as
negative-test string literals; they are not live symbols or includes.

## Problems encountered

### CTA-HIR-DUMP-01 — the initial five-file inventory missed embedded users

After deleting the standalone command/test files, the source scan found three
additional users: one method in the generation-engine suite, one method in the
primary Canonical generation suite, and the generated-source-provenance HIR
integration test. The two general behaviors were migrated as described above;
the HIR-specific integration file was removed.

### CTA-HIR-DUMP-02 — the first combined removal patch failed atomically

The initial large `apply_patch` used stale/over-broad repeated context for the
two ProjectSourceGraph test assignments and failed verification. It made no
partial edits. The exact slices were reread and applied as smaller patches.

### CTA-HIR-DUMP-03 — a Windows wildcard scan was invalid

One read-only `rg` call passed `AngelscriptProjectSourceGraph.*` as a Windows
path component and produced `os error 123`. It supplied no accepted evidence.
The follow-up scan used explicit paths and later the final directory-root scan
returned the zero counts above.

### CTA-HIR-DUMP-04 — the first GREEN test selector did not select new methods

The first combined Automation selector omitted CQTest's test-class path
segment. It discovered and passed only the two pre-existing ProjectSourceGraph
tests. No completion claim was based on that selection. The exact discoverable
paths were rerun and both migrated tests passed.

### CTA-HIR-DUMP-05 — generated-origin E2E diagnostics are not yet Canonical

The removed HIR-only integration test proved that literal-asset and subsystem
generated-origin records reached the normalized HIR dump. Neutral
`asCScriptCode` provenance ownership and propagation remain tested by
CTA-HIR-02, but Canonical `asCSourceManager` currently retains only logical
source/origin/bytes/line mapping and its structured dump does not expose the
authored/generated provenance chain.

This is an open migration item, not an equivalence claim: before final HIR
model deletion, attach ScriptCode provenance to Canonical SourceManager source
records (or another Canonical snapshot-owned diagnostic record), add an E2E
literal-asset/subsystem-origin test, and keep the data diagnostic-only rather
than a Cache identity input.

## Non-claims

- TypedSemantic HIR is still present in compiler capture, function storage,
  TypedASTJIT compatibility paths, diagnostics, Standalone tests, and many UE
  tests. Task 10.5 remains open.
- Removing an Editor wrapper does not make CANONICAL the default or prove full
  Canonical Bytecode coverage.
- AngelScript's native syntax AST/compiler remains intentionally retained.
- The architecture progress percentage and literal task count do not change
  for this bounded prerequisite.
