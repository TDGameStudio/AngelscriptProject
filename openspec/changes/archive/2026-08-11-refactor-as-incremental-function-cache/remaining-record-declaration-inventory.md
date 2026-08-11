# Remaining Record Declaration Inventory

Date: 2026-08-08

Status: read-only implementation preflight. This attachment records declarations
that can be derived from existing wire/matrix authority and calls out shapes that
remain RED work. It does not authorize guessed captured-coordinate values and does
not claim a header, build, decoder or Automation GREEN.

## Authority order

1. `record-wire-v1-remaining.md` and `module-state-matrix-v1.md`;
2. `record-wire-v1.md` for common values/encoding;
3. `implementation-plan.md` only as a non-normative file-map sketch.

All five remaining payload schema constants are 1: TypeSchema, ModuleState,
FunctionBody, DebugSidecar and ModuleSnapshot.

## ModuleState enums

All are `uint8`:

```text
EAngelscriptCachedGlobalInitializationKind
  Invalid=0, Default=1, PureConstant=2, VmInitializer=3
EAngelscriptCachedGlobalCleanupPolicy
  Invalid=0, None=1, DestroyValue=2, ReleaseHandle=3
EAngelscriptCachedHardValueKind
  Invalid=0, GlobalConstant=1, EnumAuthority=2
EAngelscriptCachedInitializerKind
  Invalid=0, Global=1, Module=2
EAngelscriptCachedInitializationActionKind
  Invalid=0, DefaultConstructGlobal=1, ExecuteInitializer=2
EAngelscriptCachedCanonicalValueKind
  Invalid=0, Bool=1, SignedInteger=2, UnsignedInteger=3,
  Float32=4, Float64=5, EnumInt32=6
```

Support enums in the same authority but not persisted directly by these four record
DTOs:

```text
EAngelscriptCacheValueStorageKind:uint8
  Invalid=0, Trivial=1, OwningValue=2, ReferenceCounted=3
EAngelscriptCacheOpaquePayloadKind:uint8
  Invalid=0, FunctionExecution=1, InitializerExecution=2, Debug=3
```

## ModuleState wire-ordered DTOs

```cpp
struct FAngelscriptCachedGlobalSchema
{
    uint32 StorageOrdinal;
    FAngelscriptStableGlobalKey GlobalKey;
    FString CanonicalNamespace;
    FString CanonicalName;
    FAngelscriptCachedDataType Type;
    uint32 GlobalTraitFlags;
    EAngelscriptCachedGlobalInitializationKind InitializationKind;
    EAngelscriptCachedGlobalCleanupPolicy CleanupPolicy;
    FAngelscriptHash256 StorageLayoutFingerprint;
};

struct FAngelscriptCachedCanonicalValue
{
    EAngelscriptCachedCanonicalValueKind ValueKind;
    TArray<uint8> FixedWidthValueBytes;
};

struct FAngelscriptCachedHardValue
{
    EAngelscriptCachedHardValueKind HardValueKind;
    FAngelscriptCacheStableReference Owner;
    FAngelscriptCachedDataType Type;
    TOptional<FAngelscriptCachedCanonicalValue> CanonicalValue;
    FAngelscriptHash256 HardValueHash;
};

struct FAngelscriptCachedInitializerUnit
{
    EAngelscriptCachedInitializerKind InitializerKind;
    FAngelscriptStableFunctionKey InitializerKey;
    TOptional<FAngelscriptStableGlobalKey> OwnerGlobal;
    uint32 VmInitializerCodecVersion;
    FAngelscriptHash256 InitializerExecutionHash;
    TArray<uint8> CanonicalExecutionPayload;
};

struct FAngelscriptCachedInitializationAction
{
    uint32 ActionOrdinal;
    EAngelscriptCachedInitializationActionKind ActionKind;
    FAngelscriptCacheStableReference Target;
    TArray<FAngelscriptCacheSemanticDependency> Dependencies;
};

struct FAngelscriptCachedPostInitFunction
{
    uint32 PostInitOrdinal;
    FAngelscriptCacheStableReference Function;
};

struct FAngelscriptCachedModuleState
{
    uint32 PayloadSchemaVersion;
    FAngelscriptStableModuleKey ModuleKey;
    FAngelscriptArtifactProfileKey Profile;
    FAngelscriptHash256 StateInputHash;
    TArray<FAngelscriptCachedGlobalSchema> OrderedGlobals;
    TArray<FAngelscriptCachedHardValue> HardValues;
    TArray<FAngelscriptCachedInitializerUnit> Initializers;
    TArray<FAngelscriptCachedInitializationAction> OrderedInitializationActions;
    TArray<FAngelscriptCachedPostInitFunction> OrderedPostInitFunctions;
    TArray<FAngelscriptCacheSemanticDependency> Dependencies;
};
```

`GlobalTraitFlags` reuses the common raw `uint32`
`EAngelscriptCachedDeclarationTraitFlags` V1 mask (`KnownMask=0x1ff`) and must equal
the corresponding ModuleInterface global declaration flags. It does not introduce a
second enum.

## FunctionBody wire-ordered DTO

```text
EAngelscriptCachedFunctionInvocationKind:uint8
  Invalid=0
  GlobalFunction=1
  Method=2
  Constructor=3
  Destructor=4
  Factory=5
  GeneratedDefaultConstructor=6
  GeneratedDefaultDestructor=7
  InitDefaults=8
  PublicSingleFunction=9
  Lambda=10
```

```cpp
struct FAngelscriptCachedFunctionBody
{
    uint32 PayloadSchemaVersion;
    FAngelscriptStableModuleKey ModuleKey;
    FAngelscriptFunctionArtifactIdentity Identity;
    FAngelscriptHash256 ExpectedDeclarationAbi;
    FAngelscriptFunctionSourceDigest FunctionSourceDigest;
    FAngelscriptFunctionInputDigest FunctionInputDigest;
    EAngelscriptCachedFunctionInvocationKind InvocationKind;
    uint32 VmExecutionCodecVersion;
    TArray<uint8> CanonicalExecutionPayload;
    TArray<FAngelscriptCacheSemanticDependency> ActualDependencies;
    TOptional<FAngelscriptCacheRecordId> DebugSidecar;
};
```

The two digest member names above follow normative wire language and must be frozen
by task 2.4d before declaration GREEN; the implementation-plan sketch's shortened
`SourceDigest`/`InputDigest` names are not authority.

## DebugSidecar wire-ordered DTOs

```cpp
struct FAngelscriptCachedLogicalSectionKey
{
    FAngelscriptHash256 Hash;
};

struct FAngelscriptCachedDebugSourceReference
{
    FAngelscriptCachedSourceFileKey SourceFileKey;
    FAngelscriptCachedLogicalSectionKey LogicalSectionKey;
    FString CanonicalLogicalSection;
};

struct FAngelscriptCachedDebugSidecar
{
    uint32 PayloadSchemaVersion;
    FAngelscriptStableFunctionKey FunctionKey;
    FAngelscriptArtifactProfileKey Profile;
    FAngelscriptHash256 DebugHash;
    uint32 VmDebugCodecVersion;
    TArray<FAngelscriptCachedDebugSourceReference> Sources;
    TArray<uint8> CanonicalDebugPayload;
};
```

`FAngelscriptCachedLogicalSectionKey` is a distinct nonzero full-hash domain, not a
string alias or generic hash parameter.

## ModuleSnapshot wire-ordered DTOs

```cpp
struct FAngelscriptCachedModuleRecordLink
{
    FAngelscriptStableModuleKey ModuleKey;
    FAngelscriptCacheRecordId RecordId;
};

struct FAngelscriptCachedTypeSchemaLink
{
    FAngelscriptStableTypeKey TypeKey;
    FAngelscriptCacheRecordId RecordId;
};

struct FAngelscriptCachedFunctionBodyLink
{
    FAngelscriptStableFunctionKey FunctionKey;
    FAngelscriptCacheRecordId RecordId;
};

struct FAngelscriptCachedModuleSnapshot
{
    uint32 PayloadSchemaVersion;
    FAngelscriptStableModuleKey ModuleKey;
    FAngelscriptCachedModuleRecordLink ModuleInterface;
    TArray<FAngelscriptCachedTypeSchemaLink> TypeSchemas;
    FAngelscriptCachedModuleRecordLink ModuleState;
    TArray<FAngelscriptCachedFunctionBodyLink> FunctionBodies;
};
```

The plan-only `FAngelscriptCachedModuleSnapshotLink` belongs to manifest/root data,
not this record payload.

## Common reuse and byte encoding

Reuse, do not redeclare:

- `FAngelscriptCachedDataType`;
- `FAngelscriptCacheStableReference`;
- `FAngelscriptCacheSemanticDependency`;
- `FAngelscriptCachedSourceFileKey`;
- stable identity/digest/profile/RecordId wrappers.

Wire byte payloads use `u64 byte-count + raw bytes`; arrays use `u32 element-count`.
The C++ representation `TArray<uint8>` does not authorize the normal array encoder.

## Coordinate status

- SourceIndex is frozen append-only `uint16` `0..89` with exact P/S/T rules in
  `source-interface-captured-offsets-v1.md`.
- ModuleInterface is frozen append-only `uint16` `0..88` in the same authority;
  declaration DataType uses Secondary preorder and parameter DataType uses Tertiary
  preorder.
- TypeSchema is frozen append-only `uint16` through `0..40` in
  `record-wire-v1-remaining.md`/the corrected RED. The original `0..38` values
  remain unchanged; `ReflectionKind=39` and `ClassReflectionFlags=40` preserve
  exact Reflection/UFunction subfield diagnostics.
- ModuleState, FunctionBody, DebugSidecar and ModuleSnapshot now have normative
  append-only numeric/P/S/T and lookup authority in
  `remaining-record-captured-offsets-v1.md`: their published ranges are `0..88`,
  `0..27`, `0..11`, and `0..24` respectively. Task 2.4d / IC-095 remains RED until
  the attachment and declaration-first TU pass the independent exact-SHA review at
  `0C/0I`; authority existence is no longer the blocker.

All coordinate structs use a typed Field plus `uint32 PrimaryIndex`,
`SecondaryIndex`, `TertiaryIndex`, defaulting unused axes to `MAX_uint32`. The
remaining-record authority now explicitly freezes exact occurrence-scoped optional
presence/value applicability, independent DataType-root preorder bounds,
surplus/unapplicable lookup, wrong-kind/Last+1 rejection, and set-zero behavior.

## Existing migration map

In `AngelscriptCacheSemanticRecords.cpp`:

- replace shallow `FSourceIndexReadOffsets` around `1823..1835` and
  `FModuleInterfaceReadOffsets` around `1837..1847`;
- capture SourceIndex coordinates at the actual physical readers around
  `2847..3008`;
- capture ModuleInterface/common nested coordinates at the actual readers around
  `418..788`, `3387`, `3510` and `4013..4042`;
- migrate local semantic callers currently using only container offsets around
  `1849..2698` and `3646..3978`;
- absorb physical decode/offset storage from wrappers around `4801..4951` into the
  sole decoded-record candidate; and
- remove the transitional public SourceIndex owner/mutable ModuleInterface decoder
  only after all consumers migrate.

## Preconditions before header GREEN

1. Obtain independent exact-SHA `0C/0I` acceptance for the existing task 2.4d
   coordinate authority and its declaration-first RED TU; do not reopen the frozen
   enum/P/S/T values during header GREEN.
2. Preserve the exact nested member arity/order/name/type and unique-sentinel
   position-to-name contract, plus fail-closed defaults; do not infer public
   initializer behavior from enum value zero.
3. Preserve the normative FunctionBody digest member names and exact eleven-member
   arity, and preserve ModuleSnapshot's exact six-member record-only arity.
4. Preserve the four typed lookup overloads and the compile-time prohibition on a
   caller Boolean applicability overload.
5. Compile the complete final alternatives; no pimpl or placeholder coordinate blob.
6. Only then measure the final intrusive controller and implement the sole factory.
