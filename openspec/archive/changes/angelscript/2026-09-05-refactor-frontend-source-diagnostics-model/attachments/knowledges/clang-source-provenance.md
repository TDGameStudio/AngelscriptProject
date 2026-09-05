# Clang source provenance and the AngelScript boundary

## Reusable Insight

Clang's reusable architecture is the separation of compact AST ranges, a shared source manager, an expansion/origin graph, and optional range-query records. Its raw numeric encodings are not stable identities and should not be copied as a semantic contract.

## Evidence

- `SourceLocation` is an opaque 32-bit token tied to one `SourceManager`; it contains no manager identity or generation.
- A `FileID` identifies a source-location entry, not a durable physical file. The same physical file can have multiple IDs and IDs can be reused after table reset.
- `SourceRange` is only a begin/end pair; `CharSourceRange` separately distinguishes token and character ranges.
- `FullSourceLoc` is a non-owning location-plus-manager view, and `PresumedLoc` is display information affected by line directives.
- Ordinary AST nodes do not contain `PPEntityID`. libclang queries optional `PreprocessingRecord` entities by source range.
- Clang serialization relocates positions through a separate 64-bit encoding instead of persisting raw SourceLocation values.

## Boundaries

- Clang's `PreprocessingRecord` is not a lossless preprocessing trace or a full conditional tree.
- Spelling, expansion, file, and presumed locations have distinct meanings and must not be collapsed into one “original location”.
- Clang's macro/include/PCH requirements do not justify equivalent AngelScript machinery.
- An immutable AngelScript snapshot may use UE containers, but `FString` is not the authoritative byte-indexed parse buffer and an `FName` index is not durable identity.

## Application

Keep AngelScript locations explicit and snapshot-local. Store immutable UTF-8 bytes plus range-indexed origin records under one compilation snapshot, derive presentation lazily, and serialize stable logical anchors that can be explicitly relocated. Let AST nodes keep ranges while the root result owns the snapshot.

## Sources

- Local LLVM/Clang 22.1.8 source at `D:/LLVM/llvm-project-22.1.8.src`
- `clang/include/clang/Basic/SourceLocation.h`
- `clang/include/clang/Basic/SourceManager.h`
- `clang/include/clang/Lex/PreprocessingRecord.h`
- `clang/include/clang/Serialization/SourceLocationEncoding.h`
- `clang/tools/libclang/CIndex.cpp`
