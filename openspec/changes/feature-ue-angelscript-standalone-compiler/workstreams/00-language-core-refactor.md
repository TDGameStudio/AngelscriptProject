# LanguageCore Refactor Workstream

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


## Purpose

Move pure language processing out of the UE-heavy `FAngelscriptPreprocessor` implementation without replacing its public API or changing current UE-AngelScript semantics. This workstream precedes broad standalone frontend implementation because both UE and standalone must consume the same parser, declaration IR, rewrite, and diagnostic behavior.

## Ownership boundary

Shared source lives under:

```text
Plugins/Angelscript/Source/AngelscriptRuntime/Language/
  Platform/
  Source/
  Lexing/
  Preprocessing/
  Declarations/
  Rewriting/
  Diagnostics/
  Frontend/
```

The shared layer owns:

- UTF-8 source values, logical paths, module identities, spans, and source maps;
- tokenization and comment/string-aware scanning;
- conditional directives, imports, chunk boundaries, annotations, and specifier syntax;
- value-only declarations and host-type queries through `ITypeOracle`;
- deterministic rewrite edits/plans and structured diagnostics;
- explicit `ChunksProcessed`, `CodePostProcessed`, and `Completed` checkpoints.

The UE facade/adapters retain:

- files, directory watching, asynchronous loading, and `IAngelscriptSourceProvider`;
- conversion from `UAngelscriptSettings` and current engine context;
- slow-task, delegate, log, event, and editor integration;
- live engine/reflection duplicate, base, interface, trait, and symbol queries;
- lowering into `FAngelscriptModuleDesc`, `FAngelscriptClassDesc`, and related UE descriptors;
- ClassGenerator, UObject/UClass/UFunction/FProperty materialization, hot reload, and runtime compilation.

The standalone host retains:

- CMake, CLI filesystem loading, bundle-backed `ITypeOracle`, artifact production;
- AngelScript engine/module/context creation, bytecode, execution, limits, and add-ons.

## Compatibility strategy

- UE Build.cs and CMake compile the same LanguageCore `.cpp` files.
- Core value records use standard C++ only.
- The only LanguageCore host definition is CMake-internal `ANGELSCRIPT_LANGUAGE_STANDALONE=1`.
- That definition is consumed only by the platform/export compatibility header and standalone build/test-host configuration.
- No `AS_STANDALONE`, `WITH_ANGELSCRIPT_STANDALONE`, fake `CoreMinimal.h`, copied preprocessor, or language-semantic conditional is allowed.

## Migration sequence

1. Characterize current module naming, path handling, directives, chunks, imports, declarations, rewrites, hooks, source locations, and diagnostics.
2. Add Platform, Source, Diagnostics, and Lexing value APIs with standalone unit tests and UE parity tests.
3. Move directive/chunk/import processing behind `FLanguageSession`.
4. Introduce declaration IR and `ITypeOracle`; lower it back into existing UE descriptors.
5. Move rewrite recipes and source maps; preserve facade hook checkpoints.
6. Switch every current facade path to LanguageCore and delete migrated duplicate logic.
7. Add architecture scans and differential corpus gates before promoting standalone UE analysis.

## Semantic exclusions

- Mutable globals are not enabled by this workstream.
- Raw `@` handle syntax is not introduced.
- AngelScript engine/module/context or bytecode ownership does not move into LanguageCore.
- ClassGenerator and reflection materialization do not move into LanguageCore.
