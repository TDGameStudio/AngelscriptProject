# SourceManager diagnostic AST-first gate — 2026-08-23

## Scope and result

This card closes OpenSpec task **2.2** only: the maintained fork's source
coordinate authority for Parser, Builder, and legacy Compiler *diagnostics*.
It does not claim Cache V2 DTO compatibility, candidate publication, or a
default canonical-pipeline cutover.

`as_source_manager.cpp` is already part of
`Plugins/Angelscript/Standalone/CMakeLists.txt`. The missing verified path was
a legacy Builder semantic error: its user-visible section/row/column was
calculated directly from `asCScriptCode`, so the diagnostic did not create a
source-session record. That made tooling unable to relate a real semantic
error to the same source identity model used by canonical AST diagnostics.

## Gate card: parser, Builder, and Compiler diagnostics share a source session

- **OpenSpec task(s):** `2.2`, with the AST-first routing requirements in
  `0.2`.
- **Source fixtures:**
  - malformed parser source: `void F(\n{\n}\n`, line offset `12`;
  - Builder semantic source: `enum OverflowEnum { TooLarge = 128 }`, line
    offset `7` (expanded over four lines);
  - Compiler semantic source: `GhostType Value;` in `Entry`, line offset `6`.
- **Canonical/source fact:** each source-facing diagnostic is associated with
  exactly one `asCSourceManager` authored record containing the logical key,
  the original line offset, and a token location whose mapped row/column is
  identical to the legacy diagnostic. Source identity remains byte-sensitive:
  a same logical key with changed bytes or offset is rejected rather than
  silently reusing stale coordinates.
- **AST/source test:**
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeSourceManagerTests.cpp`
  - `ParserDiagnosticsPublishSourceSessionCoordinates`;
  - `BuilderSemanticDiagnosticsPublishSourceSessionCoordinates`;
  - `CompilerSemanticDiagnosticsPublishSourceSessionCoordinates`.
  This is a source-coordinate gate rather than a node-shape gate: the
  observable contract is the parser/sema/compiler diagnostic's range/session,
  so a sealed internal AST is not required to prove it. The same suite retains
  the canonical Parser → Sema source-identity conflict test.
- **AST-red:** after adding the Builder enum-overflow test but before repairing
  its diagnostic coordinate entry, the source manager group reported
  **7 total, 6 passed, 1 failed**. The only failure was
  `BuilderSemanticDiagnosticsPublishSourceSessionCoordinates` at the assertion
  that the Builder semantic error must publish a source-session section:
  [RunMetadata.json](../../../../Saved/Tests/cta-source-manager-builder-diagnostic-runtime-red/20260823_172103_486_59f59cae/RunMetadata.json).
- **Repair:** `as_builder.cpp` now routes the remaining source-facing Builder
  warning/information/error sites through `GetDiagnosticRowColumn()`, including
  unused top-level nodes, compilation pre-messages, enum dependency errors,
  and signed-byte enum overflow. Parser already used that bridge; compiler
  `Error`, `Warning`, `Information`, and overload-candidate messages already
  use it. The bridge's legacy conversion fallback preserves diagnostics when a
  source section cannot safely enter the session.
- **AST-green / focused regression:** the source manager group reported
  **8/8 PASS**, including Parser, Builder, and Compiler fixtures:
  [RunMetadata.json](../../../../Saved/Tests/cta-source-manager-parser-builder-compiler-green/20260823_172349_744_e97564b9/RunMetadata.json).
- **Build evidence:**
  [RunMetadata.json](../../../../Saved/Build/cta-source-manager-compiler-diagnostic-build/20260823_172332_689_a25a37d7/RunMetadata.json)
  reports a successful editor build after the final test addition.
- **Legacy compatibility regressions:**
  - Script-node source range group: **6/6 PASS** — [RunMetadata.json](../../../../Saved/Tests/cta-source-manager-legacy-source-range-green/20260823_172500_503_1139b1c5/RunMetadata.json).
  - Parser recovery/cartesian group: **9/9 PASS** — [RunMetadata.json](../../../../Saved/Tests/cta-source-manager-legacy-parser-recovery-green/20260823_172537_124_e1b3ac42/RunMetadata.json).
- **CodeGen/provenance:** N/A. This card changes no AST node lowering or
  executable publication; it establishes source-coordinate diagnostic
  authority before those downstream stages.
- **Lifecycle:** the AST sidecar already writes every source record's logical
  key, origin, line offset, and bytes. Cache V2 restore/startup semantics are
  deliberately deferred to tasks `6.3`, `6.4`, `6.6`, and `13.9`.
- **Remaining boundary:** old `ConvertPosToRowCol` uses that remain are not
  diagnostic entry points: bytecode/debug line emission, typed-semantic
  observer spans, declaration and dependency metadata, generated-default
  source setup, and the bridge's compatibility fallback. Migrating those
  storage/debug representations needs its own ABI and Cache V2 gate; this
  task does not relabel them as completed.

## Static audit boundary

The final source audit distinguished direct legacy coordinate conversion from
diagnostic emission:

```text
Parser diagnostics        -> GetDiagnosticRowColumn -> SourceManager -> Write*
Builder source diagnostics-> GetDiagnosticRowColumn -> SourceManager -> Write*
Compiler diagnostics      -> GetDiagnosticRowColumn -> SourceManager -> Write*

remaining ConvertPosToRowCol
  -> bytecode line/debug records
  -> typed-semantic observer spans
  -> script declared-at / dependency metadata
  -> generated default-source offset
  -> safe legacy fallback when a source session cannot be recorded
```

This distinction is important: the completion claim is verifiable diagnostic
authority, not a claim that all legacy debug and serialized metadata have been
redesigned.
