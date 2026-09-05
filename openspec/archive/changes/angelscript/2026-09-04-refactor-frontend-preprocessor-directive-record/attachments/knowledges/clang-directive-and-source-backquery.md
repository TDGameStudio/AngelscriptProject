# Clang Directive and Source Backquery Lessons

## Reusable Insight

A typed AST and a preprocessing history answer different questions. AST nodes should keep ordinary source ranges; a snapshot-owned directive/record product should answer conditional-region and skipped-range questions by range. A full raw directive tree is required when inactive branch structure matters, because Clang's ordinary detailed preprocessing record is intentionally incomplete.

## Evidence

| Observation | Local source evidence | AngelScript application |
|---|---|---|
| Ordinary AST nodes carry source locations/ranges, not preprocessing entity IDs | `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/DeclBase.h`; `clang/include/clang/AST/Stmt.h`; `clang/tools/libclang/CIndex.cpp:247-264,460-494` | Query records by AST range instead of adding a PP ID to every node. |
| `PreprocessingRecord` has a narrow entity set | `clang/include/clang/Lex/PreprocessingRecord.h:56-202`; `clang/lib/Lex/PreprocessingRecord.cpp:384-467` | Do not treat it as a complete directive/event model; maintain an explicit AngelScript tree. |
| Skipped blocks are lexed for conditional balance, not parsed into normal AST | `clang/lib/Lex/PPDirectives.cpp:515-901` | Preserve inactive raw tokens/ranges while keeping them out of the active typed AST. |
| Region comparison is a separate query abstraction | `clang/include/clang/Lex/PPConditionalDirectiveRecord.h`; `clang/lib/Lex/PPConditionalDirectiveRecord.cpp` | Offer different-region and directive-intersection APIs over the snapshot index. |
| clangd explicitly models the full tree | `clang-tools-extra/clangd/support/DirectiveTree.h:40-100` | Store Code, Directive, and Conditional chunks with branches, terminator, and taken state. |
| Source coordinates require their owning manager/snapshot | `clang/include/clang/Basic/SourceLocation.h`; `clang/include/clang/Basic/SourceManager.h` | Validate snapshot ownership and never persist raw local encodings. |

The project-specific user constraint is preserved in [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 2119-2121,2386-2388,2777-2779: simple conditional preprocessing, no macro expansion, and later AST-region comparison.

## Boundaries

- This insight does not recommend Clang's 31-bit virtual source-location packing, negative loaded `FileID` convention, or serialized location encoding.
- It does not claim `getTopMacroCallerLoc()` reaches an ultimate file callsite; AngelScript has no macro-expansion chain in this Change.
- It does not call skipped ranges “inactive AST.”
- It does not imply that `RetainExcludedConditionalBlocks` creates a canonical multi-configuration AST.
- It does not authorize C macro expansion, include/import processing, UE reflection policy, or live runtime mutation.
- It does not permit a range or local record ID to outlive or cross its source snapshot.

## Rejected Boundaries

- No raw pointer from AST to preprocessing records.
- No per-node copy of the condition tree.
- No flat range bag as the sole conditional representation.
- No durable `FName` index, raw `SourceLocation`, `FileID`, or snapshot-local integer.
- No reconstruction of inactive typed declarations from skipped text.

## Application

Use this model whenever a later consumer needs to explain why an AST range exists, determine whether two declarations came from different conditional regions, display inactive source, or compare snapshots built under different configurations. Create one preprocessing result per frozen configuration and aggregate results outside the canonical typed AST when multi-configuration tooling is needed.

## Sources

- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 2119-2121,2386-2388,2777-2824
- [Language preprocessing provenance audit 07](../../../../../../Temp/canonical-ast-cache-jit-audit/07-%E8%AF%AD%E8%A8%80%E5%86%85%E9%A2%84%E5%A4%84%E7%90%86%E4%B8%8E%E5%AE%8F%E6%9D%A5%E6%BA%90%E6%A8%A1%E5%9E%8B.md)
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/SourceLocation.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/SourceManager.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PPCallbacks.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PreprocessingRecord.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Lex/PreprocessingRecord.cpp`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Lex/PPDirectives.cpp`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PPConditionalDirectiveRecord.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang-tools-extra/clangd/support/DirectiveTree.h`
