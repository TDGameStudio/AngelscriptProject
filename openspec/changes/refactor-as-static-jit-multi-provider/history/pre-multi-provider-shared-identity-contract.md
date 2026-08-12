# Shared Artifact Identity Consumption Contract

## Readiness

Cache change `refactor-as-incremental-function-cache` task group 1 now provides
the pure Runtime value boundary required by this change:

- `FAngelscriptHash256`;
- stable module, type, function, global, and property keys;
- `FAngelscriptFunctionSourceDigest` and `FAngelscriptFunctionInputDigest`;
- separate execution/debug `FAngelscriptFunctionContentHash` values;
- compatibility, context, and artifact profile keys;
- `FAngelscriptFunctionArtifactIdentity`;
- schema-versioned domain-separated canonical encoding;
- fail-closed logical virtual paths;
- frozen full-width golden vectors.

The shared entity-kind contract includes stable type kinds `Typedef=6` and
`Funcdef=7` in addition to the existing Class/Struct/Interface/Enum/Delegate
values. They are TypeKey coordinates; delegate/funcdef signatures use a
separate `DelegateSignature=37` FunctionKey owned by the type. Existing enum
values and identity vectors are not renumbered or rewritten. These two enum
values are a Task 2B-1 implementation obligation in the Cache change; this
record does not claim the executable provider boundary has implemented them
until the shared identity tests are green.

Cache Task 2B-2 additionally owns one shared profile-specific absence value for
the debug coordinate. The public identity operation MUST use
`FAngelscriptArtifactCanonicalWriter("function-debug-absent")` and write exactly
the complete 32-byte ArtifactProfileKey. Cache will add full Editor/Shipping
goldens that distinguish this result from zero and from
`H("function-debug", empty payload)`. StaticJIT task 1.1 MUST consume that API
and those vectors whenever an entry/profile represents absent debug; it MUST
NOT add a provider-private sentinel or second hash algorithm. This is a pending
Cache Task 2B-2 and StaticJIT Task 1.1 obligation, not an implementation-complete
claim.

The complete authoritative vector definitions, fixture inputs, schema bytes,
and expected hashes are recorded in
`../refactor-as-incremental-function-cache/identity-golden-vectors.md` and in
the executable `Angelscript.TestModule.Cache.Identity` tests. StaticJIT task
1.1 must re-run or directly share those fixture constants before provider ABI
implementation begins; it must not copy a partial/truncated interpretation.

## Provider Boundary

StaticJIT may include and embed the public identity value types and may use
their canonical builders in generation/provider tests. It must match provider
entries using the complete stable function key, selected complete content
hash, complete artifact profile, complete entry ABI hash, and complete Native
environment fingerprint.

When the selected debug coordinate represents absence, StaticJIT uses the
shared `function-debug-absent` builder for that full profile. A zero hash, zero
RecordId, empty-debug payload hash, or provider-defined absence constant cannot
satisfy a full FunctionContentHash match.

StaticJIT must not include, inspect, or depend on:

- Cache V2 record or pack types;
- RecordId, PackId, manifest, Current/Previous/Pending, or generation APIs;
- Saved cache directory layout;
- source discovery, SourceIndex authority, or package-staging policy;
- Cache runtime reload, publication, compaction, or recovery policy.

The Cache change's frozen `manifest-pack-wire-v1.md` and
`store-publication-v1.md` do not expand this boundary. In particular, semantic
RecordId, payload RawChecksum, physical PackId/GenerationId, pack/manifest/
pointer schema versions, Zlib compressor identity, filesystem namespace,
pointer checksum, store commit state and store errors are not provider-entry,
provider-generation, function-content, artifact-profile, EntryAbiHash, or
Native-environment inputs. StaticJIT's `ProviderGeneration` is the identity of
its own validated provider manifest and MUST NOT copy or alias a Cache V2
GenerationId.

A Cache repack, pointer rotation, fallback, or compaction may change physical
Cache GenerationIds while leaving every shared function/content/profile/
environment coordinate unchanged; it therefore MUST NOT refresh, invalidate,
or reorder Native routes. Conversely, provider arrival/removal or Live Coding
generation changes routing only and MUST NOT rewrite or invalidate Cache V2
records. The only synchronization points between these changes remain the
public identity builders/types and their full-width golden vectors.

Numeric AngelScript FunctionId remains a current-engine route coordinate only.
Display GUID remains diagnostic only. No provider ABI field may substitute
either value for a complete 256-bit identity.

## Schema Change Rule

If the shared identity schema changes, both changes must deliberately update:

1. the Runtime identity schema version;
2. every affected authoritative golden vector;
3. Cache identity tests;
4. StaticJIT provider ABI/generator tests;
5. provider layout/version compatibility policy.

Silently accepting new bytes under the old schema or updating only one
change's expected constants is forbidden. This coordination requirement does
not create a dependency on Cache V2 storage or lifecycle.
