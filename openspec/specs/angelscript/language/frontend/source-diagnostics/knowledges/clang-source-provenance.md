# Clang source provenance boundary

## Guidance

Reuse Clang's layering, not its raw source-location encoding:

- Tokens and AST nodes retain compact snapshot-local source ranges.
- One shared source manager resolves immutable bytes, lazy display coordinates, and overlapping origin records.
- Directly spelled, transformed, directive-produced, and synthetic ranges form a snapshot-owned origin graph; ordinary AST nodes do not own preprocessing-record IDs or provenance pointers.
- Display line/column data is derived and may be affected by presentation policy, so it is never durable source identity.
- Cross-compilation storage uses a logical source key, content revision, and byte range, then explicitly relocates into a later snapshot.

Clang's `SourceLocation` and `FileID` are manager-local values that may be reused, and Clang serialization relocates source positions rather than persisting raw runtime values. AngelScript therefore keeps explicit `(snapshot, FileID, UTF-8 byte offset)` ownership instead of copying Clang's packed encoding.

## Application boundary

Apply this guidance when Lexer, Preprocessor, AST, Sema, diagnostics, or tooling adds a source-bearing product. Do not collapse spelling, transformation, directive, and display locations into one vague “original location”; do not add per-node snapshot smart pointers; and do not treat absolute paths, `FName` indices, line numbers, or snapshot-local IDs as stable keys.

## Provenance

Promoted from `openspec/archive/changes/angelscript/2026-09-05-refactor-frontend-source-diagnostics-model/attachments/knowledges/clang-source-provenance.md`, based on local LLVM/Clang 22.1.8 `SourceLocation`, `SourceManager`, `PreprocessingRecord`, serialization, and libclang range-query sources. The originating Change's focused 11-scenario CQTest proof establishes the corresponding AngelScript implementation boundary.
