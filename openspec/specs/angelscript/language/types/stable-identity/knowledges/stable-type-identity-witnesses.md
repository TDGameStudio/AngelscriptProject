# Stable Type Identity Witnesses

## Reusable Insight

Compiler identity must be split by question. “Which nominal declaration is this?”, “which qualified/generic use is this?”, “is its semantic schema reusable?”, “is its target ABI compatible?”, “where is its requirement inside this artifact?”, and “which runtime object represents it now?” require different typed values and lifetimes.

## Evidence

| Question | Correct value | Evidence |
|---|---|---|
| Same nominal type? | Versioned `TypeDeclKey` descriptor and exact witness | [Stable TypeDeclKey research](../../../../../../../Temp/TypeDeclKey%E7%A8%B3%E5%AE%9A%E7%B1%BB%E5%9E%8B%E8%BA%AB%E4%BB%BD%E4%B8%8E%E7%BC%93%E5%AD%98%E8%A7%A3%E8%80%A6%E7%A0%94%E7%A9%B6.md); current hash descriptors in `Core/Artifacts/AngelscriptArtifactIdentity.h` |
| Same structural use? | `TypeUseKey` with ordered child uses and legal qualifiers | [Canonical AST type audit 09](../../../../../../../Temp/canonical-ast-cache-jit-audit/09-CanonicalAST%E7%B1%BB%E5%9E%8B%E5%88%86%E7%B1%BB%E4%BA%8C%E6%AC%A1%E5%AE%A1%E8%AE%A1.md), lines 167-285; current missing structure in `as_ast_type.h:12-45` |
| Same semantic shape? | Separate schema digest/witness | [Stable TypeDeclKey research](../../../../../../../Temp/TypeDeclKey%E7%A8%B3%E5%AE%9A%E7%B1%BB%E5%9E%8B%E8%BA%AB%E4%BB%BD%E4%B8%8E%E7%BC%93%E5%AD%98%E8%A7%A3%E8%80%A6%E7%A0%94%E7%A9%B6.md), identity/schema/ABI decision table |
| Same target representation? | Profile-scoped complete ABI key | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.h` |
| Compact artifact reference? | Artifact-local requirement slot | Existing relocation repetition analyzed in [Stable TypeDeclKey research](../../../../../../../Temp/TypeDeclKey%E7%A8%B3%E5%AE%9A%E7%B1%BB%E5%9E%8B%E8%BA%AB%E4%BB%BD%E4%B8%8E%E7%BC%93%E5%AD%98%E8%A7%A3%E8%80%A6%E7%A0%94%E7%A9%B6.md) |
| Efficient current execution? | Generation-local `typeId`, pointer, offsets, callable bindings | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.h`; [Temp reconstruction transcript 2](../../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/2.md), lines 1065-1112 |
| How does Clang persist context-local identity? | Serialize IDs then relocate through ASTReader | `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Serialization/ASTBitCodes.h`; `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Serialization/ASTWriter.cpp`; `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Serialization/ASTReader.cpp` |

A digest is useful for indexing but cannot prove equality. Persist the schema/domain plus complete canonical witness, bucket by BLAKE3-256, and compare witnesses on a digest hit. This also catches forced collisions and producer-version drift.

## Boundaries

- Nominal identity excludes member bodies, layout, ABI, source location, display metadata, and current runtime state.
- Type-use identity includes ordered generic arguments and legal semantic qualifiers; parameter direction and ownership events belong to their owning edges.
- Weak alias spelling is retained for diagnostics but resolves to the canonical target; a strong distinct declaration has its own nominal key.
- A declaration without stable module/provider/owner identity is non-cacheable until an explicit policy exists.
- UE core types may implement storage, but their memory layout, pointer values, name indices, and unordered enumeration do not define bytes.

## Rejected Boundaries

- No persisted runtime `typeId`, `TypeInfo*`, function ID, pointer, or generation-local offset.
- No identity from short name, absolute path, source line, declaration traversal ordinal, or registration order.
- No reverse parsing of a stable/display string to recover type structure.
- No hash-only equality or ABI bypass.
- No adoption of Clang `QualType` pointer identity or serialized numeric `TypeID` as a cross-artifact semantic key.
- No steady-state VM hash lookup; any later candidate installation resolves scoped requirements before execution, outside this identity capability.

## Application

Use this split whenever adding a type-bearing AST edge, artifact record, cache entry, reload comparison, runtime relocation, or diagnostic. Name the layer explicitly. If a consumer needs two layers, store two typed values rather than broadening one key until it silently answers incompatible questions.

## Sources

- [Stable TypeDeclKey research](../../../../../../../Temp/TypeDeclKey%E7%A8%B3%E5%AE%9A%E7%B1%BB%E5%9E%8B%E8%BA%AB%E4%BB%BD%E4%B8%8E%E7%BC%93%E5%AD%98%E8%A7%A3%E8%80%A6%E7%A0%94%E7%A9%B6.md)
- [Temp reconstruction transcript 2](../../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/2.md), lines 698-700,1065-1112
- [Canonical AST architecture audit 01](../../../../../../../Temp/canonical-ast-cache-jit-audit/01-CanonicalAST%E6%9E%B6%E6%9E%84%E4%B8%8E%E9%97%AE%E9%A2%98.md), lines 296-325,401-458
- [Canonical AST type audit 09](../../../../../../../Temp/canonical-ast-cache-jit-audit/09-CanonicalAST%E7%B1%BB%E5%9E%8B%E5%88%86%E7%B1%BB%E4%BA%8C%E6%AC%A1%E5%AE%A1%E8%AE%A1.md), lines 167-318,353-414
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_type.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/Type.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Serialization/ASTBitCodes.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Serialization/ASTWriter.cpp`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Serialization/ASTReader.cpp`
