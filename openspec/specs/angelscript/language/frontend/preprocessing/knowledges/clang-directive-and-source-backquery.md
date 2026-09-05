# Clang Directive and Source Backquery Lessons

## Reusable Insight

A typed AST and a preprocessing history answer different questions. AST nodes should keep ordinary source ranges; a snapshot-owned directive/record product should answer conditional-region and skipped-range questions by range. A full raw directive tree is required when inactive branch structure matters, because Clang's ordinary detailed preprocessing record is intentionally incomplete.

## Evidence

| Observation | Local source evidence | AngelScript application |
|---|---|---|
| Ordinary AST nodes carry source locations/ranges, not preprocessing entity IDs | `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/DeclBase.h`; `clang/include/clang/AST/Stmt.h`; `clang/tools/libclang/CIndex.cpp:247-264,460-494` | Query records by AST range instead of adding a preprocessing ID to every node. |
| `PreprocessingRecord` has a narrow entity set | `clang/include/clang/Lex/PreprocessingRecord.h:56-202`; `clang/lib/Lex/PreprocessingRecord.cpp:384-467` | Do not treat it as a complete directive/event model; maintain an explicit AngelScript tree. |
| Skipped blocks are lexed for conditional balance, not parsed into normal AST | `clang/lib/Lex/PPDirectives.cpp:515-901` | Preserve inactive raw tokens/ranges while keeping them out of the active typed AST. |
| Region comparison is a separate query abstraction | `clang/include/clang/Lex/PPConditionalDirectiveRecord.h`; `clang/lib/Lex/PPConditionalDirectiveRecord.cpp` | Offer different-region and directive-intersection APIs over the snapshot index. |
| clangd explicitly models the full tree | `clang-tools-extra/clangd/support/DirectiveTree.h:40-100` | Store code, directive, and conditional chunks with branches, terminator, and taken state. |
| Source coordinates require their owning manager/snapshot | `clang/include/clang/Basic/SourceLocation.h`; `clang/include/clang/Basic/SourceManager.h` | Validate snapshot ownership and never persist raw local encodings. |

Project reconstruction notes in `Temp/as大重构/1.md` require simple conditional preprocessing without macro expansion and later AST-region comparison. The implementation preserves those boundaries without making temporary material authoritative.

## Boundaries

- Do not copy Clang's 31-bit virtual source-location packing, negative loaded `FileID` convention, or serialized location encoding.
- Do not call skipped ranges “inactive AST.”
- Do not infer that retaining excluded blocks creates a canonical multi-configuration AST.
- Do not authorize C macro expansion, include/import processing, UE reflection policy, or live runtime mutation here.
- Do not permit a range or local record ID to outlive or cross its source snapshot.
- Do not keep a raw pointer from AST to preprocessing records, copy the condition tree into each node, or persist an `FName` index, pointer, `FileID`, or local integer as durable identity.

## Application

Use this model whenever a later consumer needs to explain why an AST range exists, determine whether two declarations came from different conditional regions, display inactive source, or compare snapshots built under different configurations. Create one preprocessing result per frozen configuration and aggregate results outside the canonical typed AST when multi-configuration tooling is needed.

## Sources

- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/SourceLocation.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/SourceManager.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PPCallbacks.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PreprocessingRecord.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Lex/PreprocessingRecord.cpp`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Lex/PPDirectives.cpp`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/PPConditionalDirectiveRecord.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang-tools-extra/clangd/support/DirectiveTree.h`
