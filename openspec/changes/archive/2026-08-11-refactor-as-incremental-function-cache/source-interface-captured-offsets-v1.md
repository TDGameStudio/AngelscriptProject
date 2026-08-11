# Source Interface Captured Offsets V1

Status: normative for the Task 2B-2 common decoded-record migration.

This document freezes the non-wire diagnostic coordinate API for SourceIndex
and ModuleInterface. It does not alter, copy, or reinterpret the wire order in
`record-wire-v1.md`; none of these enums or indexes enter a payload, RecordId,
manifest, pack, hash, or CompatibilityKey.

## Common coordinate rules

Both field enums have underlying type `uint16` and are append-only. Published
values are never inserted, deleted, reused, reordered, or renumbered.

```cpp
struct FAngelscriptSourceIndexFieldCoordinate
{
	EAngelscriptSourceIndexCapturedField Field =
		EAngelscriptSourceIndexCapturedField::Invalid;
	uint32 PrimaryIndex = MAX_uint32;
	uint32 SecondaryIndex = MAX_uint32;
	uint32 TertiaryIndex = MAX_uint32;
};

struct FAngelscriptModuleInterfaceFieldCoordinate
{
	EAngelscriptModuleInterfaceCapturedField Field =
		EAngelscriptModuleInterfaceCapturedField::Invalid;
	uint32 PrimaryIndex = MAX_uint32;
	uint32 SecondaryIndex = MAX_uint32;
	uint32 TertiaryIndex = MAX_uint32;
};
```

Tables below use `U` for `MAX_uint32`. A Field accepts only its documented
indexes. A missing required index, a non-`U` unused index, an out-of-range
index, wrong token kind, `Invalid` Field, or field absent from the active DTO
returns unset. A captured offset whose value is zero returns a set optional
containing zero.

Top-level array/container Fields point to their wire count prefix. Row Fields
point to the first field of that row. Optional `*Presence` Fields point to the
tag; the value Field exists only for a present optional and points to the value
start. A string value starts at its length prefix, a hash/integer at its first
byte, CanonicalDataType at root `Kind`, and StableReference at ReferenceKind.

Enclosing values without their own tag/length may share an offset with their
first field. Examples include DiscoveryPolicy/PolicyVersion, Mount/MountKey,
Declaration/DeclarationKind, CanonicalDataTypeNode/Kind,
StableReference/ReferenceKind, SemanticDependency/DependencyKind,
MetadataEntry/CanonicalKey, Parameter/Ordinal, and DeclarationSlot/SlotKind.
They remain distinct logical coordinates, not duplicate wire authorities.

### Recursive CanonicalDataType ordinal

Every independent CanonicalDataType root owns a separate pre-order ordinal
space:

```text
Visit(node):
    assign current ordinal
    for child in OrderedSubTypes wire order:
        Visit(child)
```

The root is ordinal zero and nodes are continuous `0..NodeCount-1`, depth-first
and left-to-right. `OrderedSubTypes` points to the current node's child-array
count. No string path is persisted or accepted and lookup never scans the
payload. Declaration DeclaredType uses SecondaryIndex for node ordinal;
Parameter Type uses TertiaryIndex because Primary/Secondary already identify
declaration and parameter.

## SourceIndex fields

```cpp
enum class EAngelscriptSourceIndexCapturedField : uint16
{
	Invalid = 0,

	PayloadSchemaVersion = 1,
	SourceSnapshot = 2,
	DiscoveryPolicy = 3,
	DiscoveryPolicyVersion = 4,
	DiscoveryPolicyFilterFlags = 5,
	DiscoveryPolicyOptions = 6,
	DiscoveryPolicyOption = 7,
	DiscoveryPolicyOptionCanonicalKey = 8,
	DiscoveryPolicyOptionValueFingerprint = 9,

	Mounts = 10,
	Mount = 11,
	MountKey = 12,
	MountSourceKind = 13,
	MountLogicalMount = 14,
	MountProviderKey = 15,
	MountRootConfigurationFingerprint = 16,
	MountOptions = 17,
	MountOption = 18,
	MountOptionCanonicalKey = 19,
	MountOptionValueFingerprint = 20,

	Providers = 21,
	Provider = 22,
	ProviderKey = 23,
	ProviderKind = 24,
	ProviderCanonicalImplementationIdentity = 25,
	ProviderIdentityFingerprint = 26,
	ProviderVersionFingerprintPresence = 27,
	ProviderVersionFingerprint = 28,
	ProviderConfigurationFingerprintPresence = 29,
	ProviderConfigurationFingerprint = 30,
	ProviderContentFingerprintPresence = 31,
	ProviderContentFingerprint = 32,
	ProviderCapabilityFlags = 33,

	PreprocessHooks = 34,
	PreprocessHook = 35,
	HookKey = 36,
	HookPhase = 37,
	HookCanonicalImplementationIdentity = 38,
	HookAffectedScopeKind = 39,
	HookAffectedScopeStableKey = 40,
	HookIdentityFingerprint = 41,
	HookVersionFingerprintPresence = 42,
	HookVersionFingerprint = 43,
	HookConfigurationFingerprintPresence = 44,
	HookConfigurationFingerprint = 45,
	HookContentFingerprintPresence = 46,
	HookContentFingerprint = 47,
	HookCapabilityFlags = 48,

	Files = 49,
	File = 50,
	FileSourceFileKey = 51,
	FileSourceKind = 52,
	FileMountKey = 53,
	FileProviderKey = 54,
	FileRelativeLogicalPath = 55,
	FileRawContentHash = 56,
	FileGeneratedSourceKeyPresence = 57,
	FileGeneratedSourceKey = 58,
	FileGeneratedConfigurationFingerprintPresence = 59,
	FileGeneratedConfigurationFingerprint = 60,
	FileModuleKey = 61,

	PreprocessorInputs = 62,
	PreprocessorInput = 63,
	InputKey = 64,
	InputOwnerScopeKind = 65,
	InputOwnerScopeStableKey = 66,
	InputKind = 67,
	InputCanonicalName = 68,
	InputTargetKind = 69,
	InputTargetStableKeyPresence = 70,
	InputTargetStableKey = 71,
	InputEffectiveValueOrContentHash = 72,

	Edges = 73,
	Edge = 74,
	EdgeKey = 75,
	EdgeKind = 76,
	EdgeFromSourceFileKey = 77,
	EdgeToSourceOrGeneratedKey = 78,
	EdgeCanonicalIncludeOrGeneratorIdentity = 79,
	EdgeSemanticOrdinalPresence = 80,
	EdgeSemanticOrdinal = 81,

	IneligibleScopes = 82,
	IneligibleScope = 83,
	IneligibleScopeKind = 84,
	IneligibleScopeStableKey = 85,
	IneligibleScopeReason = 86,
	IneligibleScopeCanonicalDiagnosticIdentity = 87,
	IneligibleScopeObservedFingerprintPresence = 88,
	IneligibleScopeObservedFingerprint = 89,
};
```

### SourceIndex indexes

| Values | Primary | Secondary | Tertiary | Meaning |
|---|---:|---:|---:|---|
| `1..6` | `U` | `U` | `U` | Top-level scalar/struct/array; Options is the policy array count. |
| `7..9` | discovery-option ordinal | `U` | `U` | `DiscoveryPolicy.Options[Primary]`. |
| `10` | `U` | `U` | `U` | Mounts array count. |
| `11..17` | mount ordinal | `U` | `U` | Mount row/direct field; MountOptions is that row's array count. |
| `18..20` | mount ordinal | mount-option ordinal | `U` | `Mounts[Primary].Options[Secondary]`. |
| `21` | `U` | `U` | `U` | Providers array count. |
| `22..33` | provider ordinal | `U` | `U` | Provider row/direct field/optional tag/value. |
| `34` | `U` | `U` | `U` | PreprocessHooks array count. |
| `35..48` | hook ordinal | `U` | `U` | Hook row/direct field/optional tag/value. |
| `49` | `U` | `U` | `U` | Files array count. |
| `50..61` | file ordinal | `U` | `U` | File row/direct field/optional tag/value. |
| `62` | `U` | `U` | `U` | PreprocessorInputs array count. |
| `63..72` | input ordinal | `U` | `U` | Input row/direct field/optional tag/value. |
| `73` | `U` | `U` | `U` | Edges array count. |
| `74..81` | edge ordinal | `U` | `U` | Edge row/direct field/optional tag/value. |
| `82` | `U` | `U` | `U` | IneligibleScopes array count. |
| `83..89` | scope ordinal | `U` | `U` | Ineligible-scope row/direct field/optional tag/value. |

### SourceIndex diagnostic routing

| Failure | Coordinate |
|---|---|
| SourceSnapshot recomputation | `SourceSnapshot` |
| Discovery scalar | Exact Version or FilterFlags field |
| Discovery option order/duplicate/conflict | Offending Option row; malformed scalar uses exact key/value field |
| Mount derived key | `MountKey` |
| Mount provider target | `MountProviderKey` |
| Mount option order/duplicate/conflict | Offending MountOption row |
| Provider derived key | `ProviderKey` |
| Provider optional/capability presence | Exact presence or CapabilityFlags field |
| Hook derived key | `HookKey` |
| Hook affected scope | StableKey; invalid enum uses ScopeKind |
| Hook optional/capability presence | Exact presence or CapabilityFlags field |
| File derived key | `FileSourceFileKey` |
| File mount/provider graph target | `FileMountKey` or `FileProviderKey` |
| Generated-source presence pair | First offending presence field in wire order |
| File module association | `FileModuleKey` |
| Input derived key | `InputKey` |
| Input owner graph target | StableKey; invalid enum uses OwnerScopeKind |
| Input target presence/kind/key | First offending exact field |
| Edge derived key | `EdgeKey` |
| Edge source/target | FromSourceFileKey or ToSourceOrGeneratedKey |
| Edge ordinal presence/gap/duplicate | Exact Presence or Ordinal field |
| Ineligible-scope graph target | StableKey; invalid enum uses ScopeKind |
| Observed-fingerprint presence | Presence field |
| Row canonical order/duplicate/conflict | Enclosing row of the smallest second wire occurrence |
| Invalid optional physical tag | Exact Presence field |
| Malformed present optional value | Exact value field unless the failure is the presence matrix |

## ModuleInterface fields

```cpp
enum class EAngelscriptModuleInterfaceCapturedField : uint16
{
	Invalid = 0,

	PayloadSchemaVersion = 1,
	ModuleKey = 2,
	CanonicalModuleName = 3,
	InterfaceAbi = 4,
	CanonicalNamespaces = 5,
	CanonicalNamespace = 6,

	Declarations = 7,
	Declaration = 8,
	DeclarationKind = 9,
	DeclarationEntityKind = 10,
	DeclarationSchemaCoverage = 11,
	DeclarationBodyCoverage = 12,
	DeclarationStableKey = 13,
	DeclarationOwnerKind = 14,
	DeclarationOwnerKey = 15,
	DeclarationModuleKey = 16,
	DeclarationCanonicalNamespace = 17,
	DeclarationCanonicalName = 18,
	DeclarationCanonicalDeclaration = 19,
	DeclarationCanonicalIdentityTraits = 20,
	DeclarationCanonicalIdentityTrait = 21,
	DeclarationCanonicalTypeSpellingPresence = 22,
	DeclarationCanonicalTypeSpelling = 23,
	DeclarationDeclaredTypePresence = 24,

	DeclarationDeclaredTypeNode = 25,
	DeclarationDeclaredTypeKind = 26,
	DeclarationDeclaredTypePrimitive = 27,
	DeclarationDeclaredTypeReferencePresence = 28,
	DeclarationDeclaredTypeReference = 29,
	DeclarationDeclaredTypeReferenceKind = 30,
	DeclarationDeclaredTypeReferenceStableKey = 31,
	DeclarationDeclaredTypeReferenceExpectedAbi = 32,
	DeclarationDeclaredTypeQualifierFlags = 33,
	DeclarationDeclaredTypeOrderedSubTypes = 34,

	DeclarationOrderedParameters = 35,
	DeclarationParameter = 36,
	DeclarationParameterOrdinal = 37,
	DeclarationParameterCanonicalName = 38,

	DeclarationParameterTypeNode = 39,
	DeclarationParameterTypeKind = 40,
	DeclarationParameterTypePrimitive = 41,
	DeclarationParameterTypeReferencePresence = 42,
	DeclarationParameterTypeReference = 43,
	DeclarationParameterTypeReferenceKind = 44,
	DeclarationParameterTypeReferenceStableKey = 45,
	DeclarationParameterTypeReferenceExpectedAbi = 46,
	DeclarationParameterTypeQualifierFlags = 47,
	DeclarationParameterTypeOrderedSubTypes = 48,

	DeclarationParameterPassing = 49,
	DeclarationParameterDefaultExpressionPresence = 50,
	DeclarationParameterDefaultExpression = 51,
	DeclarationParameterTraitFlags = 52,

	DeclarationTraitFlags = 53,
	DeclarationReflectionFlags = 54,
	DeclarationMetadata = 55,
	DeclarationMetadataEntry = 56,
	DeclarationMetadataCanonicalKey = 57,
	DeclarationMetadataCanonicalValue = 58,
	DeclarationSlots = 59,
	DeclarationSlot = 60,
	DeclarationSlotKind = 61,
	DeclarationSlotOrdinal = 62,
	DeclarationSignatureHash = 63,
	DeclarationTraitsHash = 64,

	Imports = 65,
	Import = 66,
	ImportKey = 67,
	ImportCanonicalNamespace = 68,
	ImportCanonicalName = 69,
	ImportCanonicalSignature = 70,
	ImportTargetModuleKey = 71,
	ImportTargetDeclaration = 72,
	ImportTargetDeclarationReferenceKind = 73,
	ImportTargetDeclarationStableKey = 74,
	ImportTargetDeclarationExpectedAbi = 75,
	ImportSlots = 76,
	ImportSlot = 77,
	ImportSlotKind = 78,
	ImportSlotOrdinal = 79,

	Dependencies = 80,
	Dependency = 81,
	DependencyKind = 82,
	DependencyTarget = 83,
	DependencyTargetReferenceKind = 84,
	DependencyTargetStableKey = 85,
	DependencyTargetExpectedAbi = 86,
	DependencyExpectedContentOrValuePresence = 87,
	DependencyExpectedContentOrValue = 88,
};
```

### ModuleInterface indexes

| Values | Primary | Secondary | Tertiary | Meaning |
|---|---:|---:|---:|---|
| `1..5` | `U` | `U` | `U` | Top-level scalar/array; CanonicalNamespaces is array count. |
| `6` | namespace ordinal | `U` | `U` | Namespace string element. |
| `7` | `U` | `U` | `U` | Declarations array count. |
| `8..20` | declaration ordinal | `U` | `U` | Declaration row/direct field or nested-array count. |
| `21` | declaration ordinal | trait ordinal | `U` | Identity-trait string element. |
| `22..24` | declaration ordinal | `U` | `U` | Outer optional tag/value before recursive type nodes. |
| `25..34` | declaration ordinal | DeclaredType node pre-order ordinal | `U` | DeclaredType node/field; unset when absent. |
| `35` | declaration ordinal | `U` | `U` | OrderedParameters array count. |
| `36..38` | declaration ordinal | parameter array ordinal | `U` | Parameter row and fields before Type. |
| `39..48` | declaration ordinal | parameter array ordinal | Type node pre-order ordinal | Parameter Type node/field. |
| `49..52` | declaration ordinal | parameter array ordinal | `U` | Parameter passing/default/traits. |
| `53..55` | declaration ordinal | `U` | `U` | Declaration flags and Metadata array count. |
| `56..58` | declaration ordinal | metadata ordinal | `U` | Metadata row/key/value. |
| `59` | declaration ordinal | `U` | `U` | Declaration Slots array count. |
| `60..62` | declaration ordinal | slot array ordinal | `U` | Declaration slot row/kind/ordinal. |
| `63..64` | declaration ordinal | `U` | `U` | SignatureHash and TraitsHash. |
| `65` | `U` | `U` | `U` | Imports array count. |
| `66..76` | import ordinal | `U` | `U` | Import row/direct fields/reference/Slots count. |
| `77..79` | import ordinal | slot array ordinal | `U` | Import slot row/kind/ordinal. |
| `80` | `U` | `U` | `U` | Dependencies array count. |
| `81..88` | dependency ordinal | `U` | `U` | Dependency row/reference/optional tag/value. |

### Nested common-value details

For DeclaredType fields `25..34`, Primary identifies the declaration and
Secondary the node pre-order ordinal. Node and Kind share the Kind offset;
Reference and ReferenceKind share the ReferenceKind offset. ReferencePresence
is the node optional tag, StableKey/ExpectedAbi are their hash starts, and
OrderedSubTypes is the current node child-array count. Outer
DeclaredTypePresence consumes only Primary. Function return, Global value and
Property value types all use this one family; V1 has no second ReturnType wire
field.

For Parameter non-type fields, Primary is declaration ordinal and Secondary is
parameter array ordinal; stored `Parameter.Ordinal` is separately required to
equal that array position. Parameter Type fields `39..48` additionally use
Tertiary as the node pre-order ordinal. Parameter/ParameterOrdinal share the
ordinal start, TypeNode/TypeKind share Kind, Reference/ReferenceKind share the
kind byte, and DefaultExpressionPresence is distinct from its present string.

Metadata fields use `{declaration, metadata, U}`. MetadataEntry and CanonicalKey
share the key length prefix. Declaration slots use `{declaration, slot, U}`;
import slots use `{import, slot, U}`. Each enclosing slot shares its SlotKind
offset and ordinal diagnostics use the explicit ordinal field.

StableReference has four context-specific families: DeclaredType reference,
Parameter Type reference, Import target declaration, and Dependency target.
There is no generic reference path table. Wrong ReferenceKind reports its kind
field, missing/zero target reports StableKey unless kind caused the failure,
and missing/forbidden ABI reports ExpectedAbi. DataType reference presence
shape reports the presence tag.

SemanticDependency uses `{dependency, U, U}`. Dependency/DependencyKind share
the dependency-kind byte; DependencyTarget/TargetReferenceKind share the
reference-kind byte. Presence-matrix failures report the optional presence
tag; present-zero/malformed content reports the value field.

### ModuleInterface diagnostic routing

| Failure | Coordinate |
|---|---|
| InterfaceAbi recomputation | `InterfaceAbi` |
| Namespace order/duplicate/empty | Offending CanonicalNamespace |
| Declaration order/duplicate/conflict | Offending Declaration row |
| Declaration tagged union | Kind or EntityKind, whichever first fails |
| Schema/body coverage | Exact SchemaCoverage or BodyCoverage field |
| StableKey recomputation | DeclarationStableKey |
| Cross-module owner | DeclarationModuleKey, else module-owned OwnerKey mismatch |
| Forbidden owner kind | DeclarationOwnerKind |
| Missing/unresolved owner | DeclarationOwnerKey |
| Identity-trait order/duplicate | Offending trait string |
| CanonicalTypeSpelling presence/shape | Presence or present value field |
| DeclaredType presence matrix | DeclarationDeclaredTypePresence |
| DataType semantic failure | Exact node-specific DeclaredType/ParameterType field |
| Parameter ordinal gap/duplicate | DeclarationParameterOrdinal |
| Parameter passing/default/trait | Exact parameter field |
| Metadata order/duplicate/conflict | Offending entry; malformed scalar uses key/value |
| Declaration slot | Exact SlotKind or SlotOrdinal |
| Signature/Traits hash | Exact stored hash field |
| Import order/duplicate/conflict | Offending Import row |
| ImportKey recomputation | ImportKey |
| Import target module | ImportTargetModuleKey |
| Import target kind/key/ABI | Exact target-reference field |
| Import slot | Exact SlotKind or SlotOrdinal |
| Dependency order/duplicate/conflict | Offending Dependency row |
| Dependency graph/current target | Exact target-reference field |
| Dependency content presence | Presence field; malformed present value uses value field |
| Missing captured coordinate for validated row | Internal invariant failure; never scan/fallback zero |

## Exact-fast-path wrong-kind result

`QueryExactFastPathEligibility` clears the output first and checks token kind
before ModuleKey, SourceIndex access, closure allocation, scratch reservation,
or offset lookup. For any valid decoded token that is not SourceIndex:

```text
Error      = WrongRecordKind (48)
Class      = GraphOrOwnership
Stage      = ModuleGraph (5)
RecordKind = actual supplied token RecordId.Kind
ByteOffset = 0
Output     = { bExactFastPathEligible=false, MatchingScopes=[] }
Budget     = unchanged in every counter
```

The actual kind is reported because the supplied validated record is the
subject; reporting SourceIndex or Invalid would misidentify the bad input.
Offset zero is an explicit context offset before any applicable SourceIndex
coordinate, not a missing-coordinate fallback. WrongRecordKind wins even when
the requested ModuleKey is also zero or absent.

```cpp
OutEligibility.Reset();
if (SourceIndexRecord.GetRecordId().Kind !=
	EAngelscriptCacheRecordKind::SourceIndex)
{
	return FAngelscriptCacheValidationResult::AtStage(
		EAngelscriptCacheValidationError::WrongRecordKind,
		SourceIndexRecord.GetRecordId().Kind,
		EAngelscriptCacheValidationStage::ModuleGraph,
		0);
}
```

## RED and implementation acceptance

- freeze every enum numeric value and coordinate index rule with compile-time
  assertions before common-factory migration GREEN;
- cover correct offset including present zero and unset for wrong kind,
  invalid/unapplicable field, unused supplied index, missing required index and
  each out-of-range index;
- mutate every physical optional tag/value and nested common-value boundary;
- preserve smallest-second-wire-occurrence order/duplicate diagnostics;
- retain the full private parallel offset arrays inside the immutable token and
  charge their actual allocator capacity with the matching AR-SCR family;
- never use caller paths/tables, string keys, semantic-key lookup, byte scan, or
  offset-zero fallback; and
- independently test the exact wrong-kind result, empty output, unchanged
  Budget and no allocation/accessor/offset-query calls.
