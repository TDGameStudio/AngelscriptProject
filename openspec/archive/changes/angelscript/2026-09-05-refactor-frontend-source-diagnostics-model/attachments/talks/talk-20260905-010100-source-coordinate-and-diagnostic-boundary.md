# Source coordinate and diagnostic boundary

## Context

The new frontend needs Clang-like source backquery and diagnostics, but “copy SourceLocation” is not a complete design. Clang locations are compact tokens meaningful only inside one SourceManager epoch, and ordinary AST nodes do not own preprocessing-record IDs.

## Evidence

- `clang/include/clang/Basic/SourceLocation.h` defines a 32-bit opaque raw encoding with a macro bit and manager-local offset.
- `clang/include/clang/Basic/SourceManager.h` and `clang/lib/Basic/SourceManager.cpp` resolve that offset through file or expansion entries; clearing ID tables can reuse numeric identities.
- `clang/include/clang/AST/Stmt.h` explicitly notes that SourceLocation has no independent meaning without its SourceManager.
- `clang/tools/libclang/CIndex.cpp` performs preprocessing backquery by asking `PreprocessingRecord` for entities overlapping an AST range.
- Current AngelScript `as_source_location.h` already expresses FileID and offset directly, while Parser diagnostics still travel through Builder and the live Engine.

## Options

1. Copy Clang's packed raw location and negative FileID representation.
2. Store filenames, lines, columns, and provenance pointers on every token and AST node.
3. Preserve explicit UTF-8 byte coordinates, add immutable snapshot ownership, and put rich provenance and display indexes behind a shared manager.

## Settled Decision

Use option 3. It captures the architectural value of Clang without importing an opaque encoding optimized for C/C++ modules and PCH. A stable anchor is a separate cross-compilation object; a snapshot-local location is never advertised as durable identity.

Diagnostics use the same snapshot and ranges but remain structured until a consumer renders them. This permits focused tests and later UE adapters without making `asCScriptEngine` part of lexical or semantic state.

## Consequences and Flip Condition

AST and token storage stay compact, while tooling can recover origins through shared indexes. The snapshot retains bytes for the lifetime of its AST/result. Reconsider packing only after measured memory evidence shows location representation is a material bottleneck and a packed design can retain explicit owner validation and serialization relocation.

## Visual

```text
AST / Token SourceRange
          |
          v
  immutable SourceSnapshot
    |        |         |
   bytes   line map   origin graph
             ^          |
             `-- lazy --'

Diagnostic record -> same ranges -> later renderer/consumer
```

## Sources

- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/SourceLocation.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/SourceManager.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Basic/SourceManager.cpp`
- `D:/LLVM/llvm-project-22.1.8.src/clang/tools/libclang/CIndex.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_source_location.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp`
