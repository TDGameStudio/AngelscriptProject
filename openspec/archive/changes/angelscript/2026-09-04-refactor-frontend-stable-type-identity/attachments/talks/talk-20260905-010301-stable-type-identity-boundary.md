# Stable Type Identity Boundary

## Context

The project needs stable type references for AST, caching, reload, artifacts, and later runtime publication. Existing answers and code sometimes use “type ID,” string stable keys, hash keys, ABI records, and runtime pointers as if they were interchangeable. They are not.

## Evidence

- [Temp reconstruction transcript 2](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/2.md), lines 698-700 records the user's type-ID design question, and `:1065-1067` asks whether bytecode stores a type ID or pointer.
- [Temp reconstruction transcript 2](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/2.md), lines 1074-1112 correctly observes that current bytecode uses both forms, but its claim that numeric `typeId` is a stable cross-boundary interface is rejected: the value belongs to one engine generation.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_decl.h:49-91` and `as_ast_type.h:26-45` use string `stableKey` fields on wide records.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h` defines BLAKE3-backed stable hashes and string-based descriptors.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.h` explicitly keeps stable requirements separate from generation-local pointers and numeric type IDs, but still carries a string stable key inside `asSTypeABIKey`.
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/Type.h` uses pointer-oriented in-memory `QualType`; that is efficient within one AST context, not a persistent semantic key.
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Serialization/ASTBitCodes.h:70-99` defines serialized `DeclID`/`TypeID` values for serialized AST context, and ASTReader/ASTWriter relocate them rather than treating live pointers or IDs as universal identity.

## Options

1. Persist numeric runtime `typeId` or a type pointer and recreate matching registration order.
2. Promote the current stable-key string or BLAKE3 digest to sole semantic authority.
3. Define typed canonical declaration/use descriptors, retain exact witnesses, separate schema/ABI, and project into artifact-local and generation-local values.

## Settled Decision

Choose option 3. `TypeDeclKey` identifies a nominal declaration; `TypeUseKey` captures canonical target, ordered type arguments, and legal use qualifiers. Semantic schema and target ABI remain separate proofs. This Change defines artifact-local slots and generation-local runtime-ID wrappers as scoped domains; a later Builder/Engine Change owns requirement resolution and publication.

```text
TypeDeclKey + TypeUseKey
          ├─> TypeSchemaDigest
          ├─> target TypeABIKey
          └─> artifact requirement slot
                    `-> later current-generation binding/typeId/pointers
```

The implementation may use UE strings, containers, maps, names, and smart pointers inside the module. Canonical encoding is still defined in terms of explicit tags, canonical UTF-8, prescribed ordering, and exact witness bytes.

## Consequences and Flip Condition

Hashes are no longer sufficient persisted witnesses, and some anonymous/generated declarations become explicitly non-cacheable until a stable owner/generator contract exists. A future wire-format Change may serialize these records after it defines versioning and budgets, and a later Builder/Engine Change may resolve them transactionally; neither future need moves runtime IDs into the stable domain.

## Rejected Boundaries

- Reject numeric runtime `typeId`, pointer, function ID, registration order, or artifact slot as a stable semantic key.
- Reject short-name or string-normalization lookup as equality authority.
- Reject hash-only equality without the complete canonical witness.
- Reject layout, member bodies, tooltips, absolute paths, source lines, and traversal ordinals in nominal declaration identity.
- Reject `FName` comparison indices, `FString` memory, or `TMap` iteration order in canonical bytes.
- Reject Clang's in-memory pointer-based `QualType` and serialized module-local `TypeID` as models for a universal AngelScript key.
- Reject defining best-effort runtime binding or publication inside this identity-only Change.
- Reject bundling Cache V2, sidecar, bytecode V5, or VM extraction into this Change.

## Sources

- [Temp reconstruction transcript 2](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/2.md), lines 698-700,1065-1112
- [Stable TypeDeclKey research](../../../../../../Temp/TypeDeclKey%E7%A8%B3%E5%AE%9A%E7%B1%BB%E5%9E%8B%E8%BA%AB%E4%BB%BD%E4%B8%8E%E7%BC%93%E5%AD%98%E8%A7%A3%E8%80%A6%E7%A0%94%E7%A9%B6.md)
- [Canonical AST type audit 09](../../../../../../Temp/canonical-ast-cache-jit-audit/09-CanonicalAST%E7%B1%BB%E5%9E%8B%E5%88%86%E7%B1%BB%E4%BA%8C%E6%AC%A1%E5%AE%A1%E8%AE%A1.md)
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_decl.h:49-91`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_type.h:12-45`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/Type.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Serialization/ASTBitCodes.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Serialization/ASTWriter.cpp`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Serialization/ASTReader.cpp`
