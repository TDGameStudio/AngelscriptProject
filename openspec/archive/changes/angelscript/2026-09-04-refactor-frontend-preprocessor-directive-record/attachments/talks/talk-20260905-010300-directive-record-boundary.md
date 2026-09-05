# Conditional Directive Record Boundary

## Context

The user twice constrained AngelScript preprocessing to simple `#if` behavior without macro expansion, then asked for AST-side comparison of regions affected by conditionals. The decision must preserve that intent while replacing the current destructive blanking behavior with a queryable frontend product.

## Evidence

- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 2119-2121 and `:2386-2388` record the explicit “no macro expansion; simple #if” direction.
- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 2777-2779 records the requirement to compare AST regions affected by `#if`.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:3510-3935` combines chunking and conditional routing; `:5323-5343` shows the current condition grammar is a flag with optional leading `!`.
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PPCallbacks.h` exposes condition events and `SourceRangeSkipped`.
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PreprocessingRecord.h` stores only macro definitions, top-level macro expansions, inclusion directives, and skipped ranges.
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Lex/PreprocessingRecord.cpp:384-444` drops nested macro-expansion entities and records skipped ranges, proving the record is not a lossless preprocessing tree.
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PPConditionalDirectiveRecord.h` supplies different-region and directive-intersection queries.
- `D:/LLVM/llvm-project-22.1.8.src/clang-tools-extra/clangd/support/DirectiveTree.h` explicitly models the full raw directive tree separately from typed AST.

## Options

1. Copy Clang's C preprocessor, macro definitions, expansion stack, and optional detailed record.
2. Keep destructive blanking and append a flat conditional range bag.
3. Build a complete AngelScript directive tree, route one active token stream, and expose a separate range-indexed record.

## Settled Decision

Choose option 3. The language stage supports the existing narrow flag grammar and conditional directive family, preserves every branch, and emits only selected non-directive tokens to Parser. Range queries connect later AST nodes to preprocessing facts without node-wide PP identifiers.

```text
raw tokens -> complete DirectiveTree -> select one configuration -> active tokens
                    |
                    `-> range-indexed PreprocessingRecord -> AST/tool queries
```

The same-module ThirdParty implementation may use `FString`, `FName`, `TArray`, `TMap`, and `TSharedPtr`. This permission does not make container internals or pointer identity durable source identity.

## Consequences and Flip Condition

Inactive text remains available for tooling but is not type-checked in the active AST. If a future accepted language requirement needs richer boolean expressions or multi-configuration analysis, it must extend the explicit condition grammar or produce separate snapshots; it does not justify silently importing C macro semantics.

## Rejected Boundaries

- Reject `#define`, token pasting, stringification, recursive/function-like macro expansion, and Clang `TokenLexer` parity.
- Reject the claim that `PreprocessingRecord` is a full event log or complete condition tree.
- Reject parsing mutually exclusive branches into one canonical typed AST.
- Reject a loose sidecar bag with no parentage, branch ordering, or configuration identity.
- Reject a second regex annotation scanner, implicit import generation, and direct `FAngelscriptClassDesc` production in this stage.
- Reject cross-generation use of raw file IDs, record IDs, pointers, or `FName` indices.

## Sources

- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 2119-2121,2283-2285,2386-2388,2777-2824,2841-2878
- [Language preprocessing provenance audit 07](../../../../../../Temp/canonical-ast-cache-jit-audit/07-%E8%AF%AD%E8%A8%80%E5%86%85%E9%A2%84%E5%A4%84%E7%90%86%E4%B8%8E%E5%AE%8F%E6%9D%A5%E6%BA%90%E6%A8%A1%E5%9E%8B.md)
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h:117-163`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:3510-3935,5323-5343`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PPCallbacks.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PreprocessingRecord.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Lex/PreprocessingRecord.cpp`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PPConditionalDirectiveRecord.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Lex/PPConditionalDirectiveRecord.cpp`
- `D:/LLVM/llvm-project-22.1.8.src/clang-tools-extra/clangd/support/DirectiveTree.h`
