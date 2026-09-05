## Why

The current compiler has several related but non-equivalent notions of type identity: string `stableKey` fields on AST records, hash-only artifact keys, complete target ABI records, artifact relocations, and generation-local runtime `typeId`/pointer projections. Treating any one of these as all the others either loses structural type facts or lets process-local values leak across cache, reload, and publication boundaries.

The reconstructed frontend needs one typed and deterministic contract that identifies a declaration and a use of that declaration without confusing nominal identity, source spelling, semantic schema, target ABI, compact artifact references, or current-engine handles. The contract must support exact equality after hashing and fail closed when a consumer generation cannot prove a compatible binding.

## What Changes

- Add canonical, versioned `TypeDeclKey` and structural `TypeUseKey` descriptors under the isolated `source/frontend/` boundary.
- Encode stable scope, owner path, declaration kind, name, arity, qualifiers, and ordered type arguments with deterministic length-framed UTF-8 encoding and domain-separated BLAKE3-256 digests.
- Retain the complete canonical witness as the equality authority; use the digest only for indexing and fast rejection.
- Separate nominal identity from `TypeSchemaDigest`, target-specific `TypeABIKey`, artifact-local `TypeSlot`, and generation-local `RuntimeTypeId` values.
- Adapt the existing Unreal artifact identity and runtime binding boundaries to consume the new canonical identity instead of parsing string keys or persisting dynamic IDs.
- Permit Unreal core value/container types inside ThirdParty while keeping canonical encoding independent of `FName` indices, pointer values, allocator layout, or container iteration order.

## Capabilities

### New Capabilities

- `angelscript/language/types/stable-identity`: Deterministic declaration and type-use identity, exact witnesses, compatibility layers, artifact requirement slots, and generation-local runtime projection.

### Modified Capabilities

None.

## Impact

The identity core belongs in `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/`. Narrow adapters may update `Core/Artifacts/AngelscriptArtifactIdentity.{h,cpp}` and `ThirdParty/angelscript/source/as_runtime_type_binding.{h,cpp}`. Replacement tests belong under `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Identity/`.

Implementation consumes the isolated CQTest support from `angelscript/refactor-native-engine-test-foundation` and canonical logical-source vocabulary from `angelscript/refactor-frontend-source-diagnostics-model`. Its stable descriptors deliberately precede and are consumed by `angelscript/refactor-frontend-clang-typed-ast`; this Change cannot depend on the later AST implementation. These prerequisites are coordinator gates, not local Task DAG edges.

This Change does not resolve or publish values into a live Engine, redesign VM opcodes, publish a new sidecar/cache wire version, migrate every function/property/global identity, extract an engine-free VM, or add rename redirects. It establishes the stable type identity authority and the exact adapter boundary those later changes consume.
