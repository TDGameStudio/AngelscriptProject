# TypedSemantic HIR physical-retirement gate — 2026-08-27

## Scope decision

This gate makes the deletion boundary explicit:

- **Delete in this OpenSpec:** the maintained-fork function-owned
  `asCTypedSemanticFunction` / `asCTypedSemanticIRBuilder` system, its capture
  switch, storage/accessors, HIR-only dump/diagnostic surfaces, compatibility
  branches, build wiring, and HIR-only tests after their semantic oracles have
  migrated to Canonical AST.
- **Retain in this OpenSpec:** AngelScript's native `asCScriptNode` syntax
  tree, native Parser, `asCBuilder`, `asCCompiler`, and the explicitly selected
  LEGACY source-compiler path. They remain available for syntax coverage,
  compatibility, isolated differential comparison, reference, and rollback.
- **Complete independently:** CANONICAL Parser→typed Sema actions→sealed
  AST→Bytecode/TypedASTJIT. It may retain native syntax nodes for grammar and
  recovery, but it may not obtain semantic facts by replaying those nodes,
  consulting HIR, merging LEGACY facts, or silently falling back.

The target state contains two explicitly selected compiler pipelines and one
shared high-level semantic authority for CANONICAL; it does not contain three
semantic representations:

```text
LEGACY (retained)
  native Parser -> asCScriptNode -> asCBuilder/asCCompiler -> VM Bytecode

CANONICAL (default after final gate)
  Parser typed actions -> Sema -> sealed Canonical AST
      -> detached Bytecode CodeGen
      -> TypedASTJIT

TypedSemantic HIR
  physically absent
```

## 2026-08-27 source inventory

A case-insensitive source scan for `typedsemantic`, `typed_semantic`,
`LegacyTypedHIR`, `VerifiedTypedHIR`, and `HIRDump` currently finds the
following retirement surface. These are audit matches, not claims that every
line is a live HIR consumer:

| Area | Matching files | Matching lines | Disposition |
| --- | ---: | ---: | --- |
| `Source/AngelscriptRuntime` | 44 | 2309 | Delete HIR model/capture/consumers; rename or migrate still-valid neutral contracts |
| `Source/AngelscriptEditor` | 6 | 104 | Replace HIR dump/command surfaces with Canonical AST diagnostics or remove obsolete entry points |
| `Source/AngelscriptTest` | 93 | 2687 | Migrate required semantic oracles to Canonical AST; delete redundant HIR-only fixtures |
| `Standalone` | 5 | 229 | Remove HIR build/test wiring after Canonical equivalents cover the contract |

The two physical model files alone are approximately 149 KiB:

- `source/as_typed_semantic_ir.h` — 21,352 bytes;
- `source/as_typed_semantic_ir.cpp` — 127,591 bytes.

### Physical model, builder, and ownership

The final deletion must remove as one coordinated unit:

- `as_typed_semantic_ir.h/.cpp`;
- `asCCompiler::typedSemanticBuilder` and every
  `typedSemanticExpression`/argument-provenance sidecar field and capture hook;
- HIR transaction creation, verification, `TakeVerifiedFunction`, and
  `SetTypedSemanticFunction` publication in `as_compiler.cpp`;
- `asCScriptFunction::Set/Discard/GetTypedSemanticFunction`, its owned pointer,
  and HIR capture diagnostic;
- engine/config `captureTypedSemanticIR`, `SetTypedSemanticIRCapture`,
  `IsTypedSemanticIRCaptureEnabled`, and `bCaptureTypedSemanticIR`;
- obsolete forward declarations, includes, CMake/build wiring, restore cleanup,
  and capture-state snapshot diagnostics.

This work deletes only HIR instrumentation inside `asCCompiler`; it does not
delete the rest of `asCCompiler` or prevent explicit LEGACY compilation.

### TypedASTJIT consumers and compatibility branches

The production source still contains HIR overloads/helpers in Analyzer,
Emitter, Dependencies, Eligibility, CallClosure, and Backend. In addition,
`LegacyTypedHIRForTesting` / `bUseLegacyTypedHIRForTesting` let unit tests enter
an HIR-only path even though production generation has begun using Canonical
AST. Those paths must be replaced by Canonical fixtures before deletion. A
production path being default-disabled or test-gated is not physical
retirement.

No `Canonical AST -> HIR`, Bytecode-to-HIR, cache-to-HIR, or dump-to-HIR
adapter may be introduced to keep those overloads alive.

### Neutral source-provenance capability currently misowned by HIR

The audit found one important extraction prerequisite. `asCScriptCode`,
`asCModule::AddScriptSectionWithSourceProvenance`, and
`FAngelscriptEngine::CompileModule` currently use HIR-named structures such as:

- `asSTypedSemanticSourceAnchor`;
- `asETypedSemanticGeneratedSourceKind`;
- `asSTypedSemanticSourceProvenanceRange`;
- `asSTypedSemanticSourceSpan`.

Source provenance remains required after HIR deletion. These types must first
move to a neutral source-location/source-manager contract (with non-HIR names),
and Canonical SourceManager/Sema must preserve authored/generated coordinates.
Deleting provenance along with HIR would be a regression; keeping the
`as_typed_semantic_ir.h` include merely for provenance would leave HIR physical
retirement incomplete.

### Editor, diagnostics, provider, and test terminology

HIR-named Editor dump command/commandlet files and Runtime diagnostic/provider
capability strings must either become Canonical AST equivalents or be removed
when no public contract requires them. Historical test intent is retained, but
the executable tests must no longer instantiate `asCTypedSemanticFunction`,
enable HIR capture, or inject `LegacyTypedHIRForTesting`.

The current test surface includes:

- 57 matching files under the AngelScript SDK area in the first symbol-focused
  scan, especially `Compiler/TypedSemanticIR` plus language tests that inspect
  HIR sidecars;
- 23 matching StaticJIT files in that same scan, including eligibility,
  closure, dependency, conversion, literal, control-flow, generated-output,
  AOT, and Canonical-migration fixtures;
- one Cache test that manually installs a HIR object;
- Standalone HIR tests and CMake wiring.

Tests protecting evaluation order, mutation, conversions, call resolution,
argument origins, cleanup, control targets, dependencies, provenance,
exceptions, suspend, fallback, and deterministic diagnostics must be ported to
Canonical AST/Bytecode/TypedASTJIT oracles before their HIR versions disappear.
Tests that only prove the existence of HIR capture are deleted rather than
ported as a new compatibility API.

## Required retirement sequence

1. Add permanent negative API/source tests for the final forbidden HIR
   symbols, while keeping them RED until consumer migration is complete.
2. Port TypedASTJIT tests and remove all HIR overloads and
   `LegacyTypedHIRForTesting` branches; production visitors consume only the
   verified Canonical snapshot.
3. Extract source provenance into neutral SourceManager/ScriptCode types and
   port Canonical provenance tests.
4. Replace/remove Editor HIR dump, provider/diagnostic capability names, config
   fields, and generation snapshot capture-state records.
5. Remove compiler capture/builder instrumentation and script-function HIR
   ownership/accessors without changing the retained LEGACY Bytecode behavior.
6. Delete `as_typed_semantic_ir.h/.cpp`, Standalone/build wiring, and remaining
   HIR-only tests; migrate every still-valuable oracle first.
7. Run forbidden-symbol scans, Runtime/Editor build, focused Compiler,
   Canonical AST, ProductionCodeGen, TypedASTJIT, StaticJIT, Cache, Hot Reload,
   Standalone Debug/Release, and configured All gates.

The sequence is dependency-ordered, but physical retirement is complete only
when the final repository scan has no HIR type, builder, accessor, capture,
compatibility branch, or build input left. Historical Markdown may describe
the retired design as history; production source and active tests may not.

## Completion scans

At final retirement, active source/build/test inputs must have zero matches for
at least:

```text
asCTypedSemanticFunction
asCTypedSemanticIRBuilder
GetTypedSemanticFunction
SetTypedSemanticFunction
DiscardTypedSemanticFunction
SetTypedSemanticIRCapture
IsTypedSemanticIRCaptureEnabled
captureTypedSemanticIR
bCaptureTypedSemanticIR
LegacyTypedHIRForTesting
bUseLegacyTypedHIRForTesting
VerifiedTypedHIR
as_typed_semantic_ir.h
as_typed_semantic_ir.cpp
```

The same gate must positively prove that the retained native implementation
still contains and tests `asCScriptNode`, native Parser construction,
`asCBuilder`, `asCCompiler`, and explicit `LEGACY` selection.

## Audit issue

The first focused provenance scan passed wildcard path components directly to
`rg` on Windows and failed with `os error 123`. The corrected scan uses the
directory root plus `--glob 'as_source_*' --glob 'as_ast_*' --glob 'as_*.h'`
and confirmed that provenance is still implemented by `as_scriptcode.*` using
HIR-named types. No source conclusion relies on the failed command.

## Final completion evidence — 2026-08-27

The inventory above records the original deletion frontier. That frontier is
now complete:

- `as_typed_semantic_ir.h` and `as_typed_semantic_ir.cpp` are physically
  absent;
- production HIR capture/configuration, compiler-builder hooks,
  script-function ownership/accessors, Editor dump surfaces, diagnostics,
  TypedASTJIT compatibility branches, Standalone build wiring and HIR-only
  tests are absent;
- neutral source provenance is owned by `as_source_provenance.h` and copied
  into Canonical SourceManager/ASTBodySidecar contracts rather than keeping a
  HIR include alive;
- Cache record kind 8 is `ASTBodySidecar`; `TypedHIRSidecar` is absent;
- TypedASTJIT/AOT consumes only retained sealed Canonical AST snapshots.

Final active-source scan results:

```text
asCTypedSemanticFunction                 0 consumers
asCTypedSemanticIRBuilder                0 consumers
Get/Set/DiscardTypedSemanticFunction     0 consumers
Set/IsTypedSemanticIRCapture             0 consumers
captureTypedSemanticIR                   0 consumers
LegacyTypedHIRForTesting                 0 consumers
bUseLegacyTypedHIRForTesting             0 consumers
VerifiedTypedHIR                         0 consumers
TypedHIRSidecar                          0 matches
as_typed_semantic_ir.h/.cpp              absent
```

The only active-source occurrences of the retired filenames are two string
literals in `AngelscriptStandaloneArchitectureTests.cpp`; they are permanent
negative assertions that the physical files do **not** exist, not build inputs
or consumers. A scan excluding that negative-gate file has zero matches for
the complete forbidden set.

Positive retention scan finds 21 maintained-fork source files containing one
or more of `asCScriptNode`, Parser, `asCBuilder`, `asCCompiler`, or explicit
`asCOMPILER_PIPELINE_LEGACY`. In particular, `as_scriptnode.*`, `as_parser.*`,
`as_builder.*`, `as_compiler.*`, and the LEGACY selection remain intact.

Verification evidence:

- complete Standalone Debug build and CTest: **20/20 PASS**;
- UE Runtime/Editor/test build after HIR deletion and Parser lifetime repair:
  **PASS**, 186/186 actions at
  `Saved/Build/cta-parser-lifetime-green-build/20260827_211820_226_d38fc24c/RunMetadata.json`;
- direct Canonical TypedASTJIT/AOT migration, generation, verification and
  benchmark groups: **48/48 PASS** at
  `Saved/Tests/cta-hir-model-delete-focused-green/20260827_210012_579_83f030dc/RunMetadata.json`;
- exact repeated real source compilation/generation: **1/1 PASS** at
  `Saved/Tests/cta-parser-lifetime-green-repeat-generation/20260827_212202_430_097fe78e/RunMetadata.json`;
- explicit CANONICAL Cutover: **12/12 PASS** at
  `Saved/Tests/cta-parser-lifetime-green-cutover-final/20260827_212626_867_9428d09d/RunMetadata.json`.

Task 10.5 is therefore closed.

## Non-claims

- No native AST/Parser/Builder/Compiler removal is authorized or performed by
  this gate.
- This gate does not close Task 10.6: CANONICAL Sema still semantically replays
  native Parser nodes for unresolved expression/statement/body slices.
- It does not switch the product default, broaden fallback, disable tests,
  commit, archive, or create the later native-AST-removal OpenSpec.
