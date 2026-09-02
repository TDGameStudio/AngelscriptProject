# Module Build → sealed AST → CodeGen → snapshot gate

**Scope:** Correct Task 3.4's stale implementation diagnosis while preserving
its remaining final-cutover obligation. This is an AST-first gate card: it
proves the semantic graph and publisher provenance before relying on execution
success.

## Contract under test

For a source `Build()` after explicitly selecting `asCOMPILER_PIPELINE_CANONICAL`:

```text
source sections
  -> Parser actions / asCSema
  -> sealed asCASTContext
  -> asCBytecodeCodeGen::Generate(candidate module)
  -> promote candidate on success
  -> retained public snapshot (if requested)
```

The succeeding build must have all of these independent facts:

1. `GetLastBytecodePublisher()` is
   `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`.
2. `GetLastLegacyCompilerInvocationCount()` is zero.
3. The retained snapshot exists, is current, and exposes a sealed Context.
4. The module debug dump's `canonicalAstDigest` equals the deterministic dump
   digest of that exact sealed Context.
5. `CompileFunction(..., asCOMP_ADD_TO_MODULE, ...)` does not leave an old
   snapshot current: its added executable declaration is absent from the
   complete sealed graph, so a fresh acquisition must fail until a full
   `Build()` replaces it.

The LEGACY-selected source path is intentionally **not** evidence for the
final requirement. It still executes `asCBuilder::BuildCompileCode()` and is
the residual Task 3.4 / Section 10 cutover work.

## AST-first tests

| Test | Sealed/public AST fact | Provenance/lifecycle fact |
| --- | --- | --- |
| `CanonicalBuildProvenanceExcludesLegacyCompiler` | canonical build uses a distinct backend route | publisher is canonical and legacy compiler count is zero |
| `CanonicalRetainedBuildDumpBindsPublisherToSealedSnapshot` | snapshot is current; Context is sealed; exact dump digest is bound | Bytecode dump records canonical publisher and that digest |
| `CompileFunctionAddToModuleRetiresIncompleteSnapshot` | old lease becomes non-current; fresh acquisition is null | single-function addition cannot falsely publish an incomplete snapshot |
| `SourceBuildPurposesSelectCanonicalAndExecute` | every currently enumerated module-`Build()` purpose selects the same canonical route | primary/reload/generation/commandlet/standalone-like builds publish CodeGen; direct `CompileFunction` remains explicitly legacy |

The concrete assertions are in
`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp`.

## Current implementation evidence

`as_module.cpp` performs the CANONICAL selected path in this order:

```text
BuildParallelParseScripts
  -> SealCanonicalAST
  -> TakeCanonicalAST
  -> asCBytecodeCodeGen::Generate(*pending, canonicalCandidate)
  -> InternalReset / PromoteCanonicalBuildCandidate
  -> AdoptPendingCanonicalAST / PublishCanonicalASTSnapshot
```

`asCBuilder::AttachCanonicalSemaIfNeeded()` makes a failed AST/Sema allocation
an error return from `BuildParallelParseScripts`; it is not ignored. Snapshot
publication seals before it allocates/replaces the public candidate. The
`asCOMP_ADD_TO_MODULE` path calls `ReleaseCanonicalASTSnapshot()` after a
successful addition, so a stale partial graph cannot remain current.

## Verification

Fresh build (already up-to-date but establishes the executed binary):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
  -Label "cta-canonical-build-provenance-build" -TimeoutMs 1800000 -NoXGE
```

Result: **PASS**.

- Build metadata: `Saved/Build/cta-canonical-build-provenance-build/20260823_173129_968_1e6ba7ba/RunMetadata.json`

Focused AST/provenance/lifecycle gate:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" `
  -Label "cta-canonical-build-provenance-green" -TimeoutMs 900000
```

Result: **7/7 PASS**, 0 failed, 0 skipped.

- Test metadata: `Saved/Tests/cta-canonical-build-provenance-green/20260823_173135_560_6d06dc17/RunMetadata.json`
- Report: `Saved/Tests/cta-canonical-build-provenance-green/20260823_173135_560_6d06dc17/Report/index.json`

## Remaining closure condition

Task 3.4 may only be checked after every supported production source-build
entry (rather than an explicitly CANONICAL-selected subset) has the sealed
canonical AST as its sole semantic/backend input, and the discard policy has
been demonstrated to release it after that production CodeGen use. This
requires the Section 10 legacy-authority removal gates; the 7/7 result above
does not erase that boundary.
