# Cache V2 Task 2B-3 Manifest And Pack Wire V1

## Status and authority

This document is the normative byte-level and validation contract for Task
2B-3 generation manifests and in-memory aggregate packs. It closes the format,
identity, compression, reachability, budget, ordering, and error decisions that
must be fixed before byte-golden RED tests are written.

For the types defined here, this document overrides abbreviated manifest/pack
sketches in `implementation-plan.md`. It does not change:

- the canonical scalar, string, array, key, common-value, SourceIndex, or
  ModuleInterface rules in `record-wire-v1.md`;
- the remaining five record payloads, errors `44..64`, per-module graph rules,
  or opaque-codec seam in `record-wire-v1-remaining.md`; or
- the 56-byte Task 2A record envelope and semantic RecordId stream in
  `archive-format-vectors.md`.

Task 2B-3 is pointer-free, engine-free, and filesystem-free. Paths,
Current/Previous/PendingColdStart, temporary files, atomic publication, locking,
fallback, reader pinning, retention, and compaction are defined separately by
`store-publication-v1.md`.

There are no implementation-defined fields in this V1 wire. Unknown enum
values, flags, schemas, reserved bytes, noncanonical ordering, alternate
padding, and trailing bytes fail closed.

## Independent version axes and magic

The pack and manifest schemas are independent of the record-envelope schema,
semantic record payload schemas, and VM-private codec versions:

```text
PackSchemaVersion     = 1
ManifestSchemaVersion = 1
PackMagic             = 8 ASCII bytes "UEASCV2P"
ManifestMagic         = 8 ASCII bytes "UEASCV2M"
```

A later pack-layout change increments `PackSchemaVersion`. A later manifest
field/layout change increments `ManifestSchemaVersion`. Such changes do not
silently reinterpret V1 and do not renumber existing RecordKinds or semantic
payload versions. CompatibilityKey includes both schema versions and the
storage-codec ABI described below, while each file still validates its explicit
schema.

## Inherited scalar and comparator rules

All integers are unsigned fixed-width little-endian. Enums are `u8`; flags and
array counts are `u32`; byte sizes and offsets are `u64`; hashes and stable keys
are exactly 32 bytes in `FAngelscriptHash256` byte order. Files contain no
native padding, native enum, `FArchive << struct`, timestamp, pointer, FName
index, numeric FunctionId, object path, or process-local value.

RecordId has this exact 33-byte wire wherever it appears in a manifest or pack
index:

```text
RecordId:
  RecordKind:u8
  ContentHash:hash256
```

No padding follows RecordKind. RecordId canonical order compares the unsigned
RecordKind byte first and then all 32 hash bytes lexicographically. Stable
ModuleKey and PackId order compares all 32 bytes lexicographically. Every
set/map-like collection below must already be in its stated order when read;
the reader never repairs order.

## Identity and checksum streams

### Semantic RecordId remains unchanged

The complete semantic RecordId is `{RecordKind, ContentHash}`. ContentHash is
the already frozen BLAKE3-256 stream:

```text
ASCII bytes "UEAS-CACHE-RECORD"
NUL byte
u32 LE record semantic schema version 2
u8 RecordKind
u64 LE canonical payload byte length
canonical uncompressed semantic payload bytes
```

Compression, pack header/index fields, offsets, RawChecksum, PackId, manifest
locations, and GenerationId are excluded. Pack storage therefore cannot change
semantic RecordId.

### RawChecksum

`RawChecksum` is direct BLAKE3-256 over exactly the canonical uncompressed
semantic payload bytes, with no prefix, kind, size, envelope, or other field:

```text
RawChecksum = BLAKE3_256(CanonicalPayloadBytes)
```

It is a physical raw-payload integrity coordinate, not a replacement for the
domain-separated semantic RecordId. Two record kinds with identical payload
bytes have equal RawChecksum but distinct RecordIds.

### PackId

PackId is direct BLAKE3-256 over every byte of the complete final `.aspack`
file, from magic byte zero through the final stored blob byte:

```text
PackId = BLAKE3_256(CompleteFinalPackBytes)
```

There is no PackId field inside the pack. The magic and schema already enter
the hashed bytes. Excluding a header/index field or hashing only payload blobs
is forbidden. A change to codec output, index metadata, order, offset, or any
other physical byte produces another PackId.

### GenerationId

GenerationId is direct BLAKE3-256 over every byte of the complete final
`.asmanifest` file:

```text
GenerationId = BLAKE3_256(CompleteFinalManifestBytes)
```

There is no GenerationId field inside the manifest. Runtime DTOs may carry a
computed GenerationId, but it is derived metadata and is never serialized into
the file whose ID it defines. This removes all self-hash/zero-field ambiguity.
The outer expected ID and later filename/pointer ID must equal the recomputed
value.

Because a manifest includes PackIds and locations, a physical repack may
change GenerationId while all semantic RecordIds remain equal.

## Generation manifest V1

### Physical field stream

The manifest has a 16-byte fixed prefix followed by canonical values. The byte
stream is exactly:

```text
offset 0    8 bytes  ASCII "UEASCV2M"
offset 8    u32 LE   ManifestSchemaVersion, exactly 1
offset 12   u32 LE   ManifestFlags, exactly 0 in V1
offset 16   32 bytes CompatibilityKey
offset 48   32 bytes ContextKey
offset 80   32 bytes ArtifactProfileKey
offset 112  32 bytes SourceSnapshot
offset 144  33 bytes SourceIndexRecordId
offset 177  u32 LE   ModuleSnapshotCount

then ModuleSnapshotCount entries, each exactly 65 bytes:
  32 bytes ModuleKey
  33 bytes ModuleSnapshotRecordId

then:
  u32 LE RecordCount

then RecordCount entries, each exactly 122 bytes:
  33 bytes RecordId
  32 bytes PackId
  u64 LE PackOffset
  u64 LE StoredSize
  u64 LE RawSize
  u8     Codec
  32 bytes RawChecksum

then EOF exactly
```

There is no alignment, padding, footer, file checksum, embedded GenerationId,
writer-policy value, timestamp, writer token, or trailing data.

The minimum valid manifest is 307 bytes: fixed bytes through
ModuleSnapshotCount, zero ModuleSnapshots, one RecordCount, and one 122-byte
SourceIndex location entry.

### Manifest value rules

The following are local manifest invariants:

- CompatibilityKey, ContextKey, ArtifactProfileKey, SourceSnapshot, every
  stable key/hash, and every PackId are nonzero full 256-bit values.
- ArtifactProfileKey recomputes exactly from CompatibilityKey and ContextKey by
  the already frozen Task 1 identity builder.
- SourceIndexRecordId has kind SourceIndex.
- ModuleSnapshot links sort by full ModuleKey. Duplicate identical links are
  `DuplicateKey`; one ModuleKey mapped to another RecordId is `ConflictingKey`.
- Every ModuleSnapshotRecordId has kind ModuleSnapshot.
- A generation with no modules is valid: ModuleSnapshotCount may be zero.
- RecordCount is at least one because SourceIndex is always indexed.
- record-index entries sort by complete RecordId. Duplicate identical entries
  are `DuplicateKey`; the same RecordId with another location is
  `ConflictingKey`.
- the number of distinct nonzero PackIds in the complete record index is at
  most MaxGenerationPacks. The decoder counts them under the caller budget
  before requesting or opening any pack; excess is `BudgetExceeded` at
  ManifestDecode.
- SourceIndexRecordId occurs exactly once in the record index.
- every root ModuleSnapshotRecordId occurs exactly once in the record index.
- Codec is `None=0` or `Zlib=1`; no other storage codec is accepted.
- PackOffset is absolute from pack file byte zero, not relative to payload
  data, the selected record, or the manifest.
- every manifest location must equal the matching entry in that pack's
  validated internal index byte-for-byte: RecordId, PackId association,
  offset, StoredSize, RawSize, Codec, and RawChecksum.

Manifest local decoding does not compare current source or current environment
ABI. It only proves the stored value is internally canonical. Compatibility,
context, profile, and current source comparisons occur after physical and graph
integrity.

## Aggregate pack V1

### Stored raw unit

A pack stores canonical uncompressed **semantic payload bytes**, not a nested
record envelope with its 56-byte header plus payload. Its index supplies
RecordKind and declared RecordId.
After decompression, the reader validates RawChecksum and invokes the existing
`TryBuildRecordId(RecordKind, CanonicalPayload)` to recompute semantic identity.

Consequently:

- RawSize is exactly canonical semantic payload size;
- `None` stored bytes are exactly those payload bytes;
- the 64 MiB grouping target counts payload bytes, not envelope bytes; and
- Task 2A envelopes remain a valid independent one-record representation but
  are not concatenated or nested in `.aspack`.

### Fixed 32-byte header

```text
offset 0   8 bytes  ASCII "UEASCV2P"
offset 8   u32 LE   PackSchemaVersion, exactly 1
offset 12  u32 LE   HeaderSize, exactly 32
offset 16  u32 LE   IndexEntrySize, exactly 96
offset 20  u32 LE   IndexEntryCount, greater than zero
offset 24  u64 LE   DataOffset, exactly 32 + IndexEntryCount * 96
```

### Fixed 96-byte index entry

```text
entry+0   u8       RecordKind
entry+1   u8       Codec
entry+2   u16 LE   Reserved16, exactly zero
entry+4   u32 LE   Reserved32, exactly zero
entry+8   32 bytes RecordId.ContentHash
entry+40  u64 LE   PackOffset, absolute from pack byte zero
entry+48  u64 LE   StoredSize
entry+56  u64 LE   RawSize
entry+64  32 bytes RawChecksum
```

The complete RecordId represented by an entry is `{RecordKind at entry+0,
ContentHash at entry+8}`. PackId is not stored in each entry because it is the
identity of the complete containing file.

### Payload area and exact ranges

Stored blobs follow the index immediately and are concatenated in index order
without padding:

- the first PackOffset equals DataOffset;
- every later PackOffset equals the previous checked `PackOffset +
  StoredSize`;
- the final checked `PackOffset + StoredSize` equals the file byte length;
- gaps, backwards offsets, non-empty overlaps, and trailing bytes are invalid;
- a zero-size half-open range `[Offset,Offset)` is empty and does not overlap
  another empty or non-empty range. Consecutive empty None records may have the
  same offset but remain uniquely ordered by RecordId;
- every non-empty range is wholly within the file after checked arithmetic.

Index entries sort by complete RecordId. Duplicate RecordIds are invalid even
when their locations/bytes match. One pack may contain records not selected by
a particular manifest; this is valid historical content and does not weaken
the manifest's exact-reachability rule.

### Per-codec size rules

For `None`:

- StoredSize equals RawSize;
- the stored blob is the raw payload byte-for-byte; and
- zero StoredSize/RawSize is valid.

For `Zlib`:

- RawSize is greater than zero;
- StoredSize is greater than zero and strictly less than RawSize;
- the stored blob is exactly one complete canonical zlib-wrapped stream for
  exactly that record; and
- dictionary, concatenated streams, raw-deflate mode, gzip framing, trailing
  compressed input, and alternate bit windows are forbidden.

Per-codec size-relation failures are `OutOfBounds` at the first responsible
size field. A None `StoredSize != RawSize` failure owns the RawSize field. A
Zlib zero StoredSize failure owns StoredSize; zero RawSize or
`StoredSize >= RawSize` owns RawSize. `MaxStoredRecordBytes` owns StoredSize and
`MaxCanonicalRecordPayloadBytes` owns RawSize. These checks precede ranges,
PackId, location comparison, decompression, and allocation.

`None` remains a valid representation even when Auto policy would compress the
payload. This permits two valid physical packs with equal RecordIds and
different PackIds. Production Auto output is nevertheless deterministic.

## Deterministic Zlib V1

The production V1 encoder uses Unreal Core `FCompression` with these exact
parameters:

```text
FormatName      = NAME_Zlib
Flags           = COMPRESS_BiasMemory
CompressionData = DEFAULT_ZLIB_BIT_WINDOW = 15
dictionary      = none
one invocation  = one record payload
```

In current UE Core, `COMPRESS_BiasMemory` maps to zlib
`Z_BEST_COMPRESSION`. `CompressMemoryBound` and `CompressMemory` receive the
same format and bit-window parameter. The writer chooses Zlib only when the
successful compressed byte count is strictly smaller than RawSize; otherwise
it emits None. Empty payload always emits None.

CompatibilityKey canonical inputs must include all of:

```text
cache-pack-schema=1
cache-manifest-schema=1
cache-storage-codec=zlib-window15-best-compression-v1
cache-storage-compressor=<FCompression::GetCompressorDDCSuffix(NAME_Zlib)>
```

The exact key/value string encoding follows the existing CompatibilityKey
builder. A compressor suffix or storage-codec ABI change therefore selects a
different compatibility namespace instead of producing different bytes under
one declared compatibility.

The public `FCompression::UncompressMemory` bool result and exact RawSize are
not sufficient to reject trailing compressed input because that API does not
report consumed input. V1 therefore defines canonical Zlib read validation as:

1. decompress the full StoredSize blob into exactly RawSize output bytes with
   the fixed format/window;
2. require decompression success and exact output size;
3. recompress those raw bytes with the fixed V1 encoder; and
4. require the recompressed byte count and every byte to equal the original
   stored blob.

This proves that the blob is the one canonical representation for its selected
CompatibilityKey and rejects truncated, concatenated, alternative-level, or
trailing input. A future codec implementation may use a streaming decoder that
also reports exact consumed bytes, but V1 acceptance must remain byte-equivalent
to the recompression rule. A failed decoder or canonical recompression mismatch
is `DecompressionFailed`; a successful decoder producing any byte count other
than RawSize is `DecompressedSizeMismatch`.

The pure storage-codec seam reports produced bytes independently from the
caller-provided RawSize-sized output view:

```cpp
virtual bool TryCompressCanonicalZlib(
    TConstArrayView<uint8> RawBytes,
    TArray<uint8>& OutStoredBytes) = 0;

virtual bool TryDecompressCanonicalZlib(
    TConstArrayView<uint8> StoredBytes,
    TArrayView<uint8> RawOutput,
    uint64& OutProducedBytes) = 0;
```

The reader pre-reserves the complete RawOutput buffer through the shared Budget
before invoking the codec. A false return is `DecompressionFailed`; a true
return with `OutProducedBytes != RawSize` is `DecompressedSizeMismatch` at the
selected blob's PackOffset, before checksum, semantic RecordId, canonical
recompression, or decoded-record publication. Reporting more than the supplied
view capacity is a size mismatch, never permission to write beyond that view.

Production policy is per record and named `Auto`. Tests may inject
`ForceNoneForTest`; they may inject `ForceZlibForTest` only for a payload whose
fixed V1 compressed output is strictly smaller than raw. A whole-pack Codec
parameter is not a V1 production API.

## Deterministic pack construction policy

This policy is part of V1 writer determinism, not semantic compatibility:

```text
TargetRawBytesPerPack = 64 * 1024 * 1024
```

An injected smaller target is allowed only for tests; it does not enter pack
bytes. For one prepared generation/store state, the writer:

1. validates each prepared `{RecordId, CanonicalPayload}` by recomputing
   RecordId and RawChecksum;
2. sorts by complete RecordId;
3. collapses exact duplicate RecordId+payload inputs; the same RecordId with
   different payload/checksum is `ConflictingKey`;
4. removes records already assigned to a selected reusable valid pack location
   by the store rebase contract;
5. applies per-record Auto compression independently;
6. greedily appends remaining sorted records to the current pack;
7. before appending a record to a non-empty pack, closes that pack if the
   resulting raw sum would be greater than TargetRawBytesPerPack, the resulting
   entry count would exceed MaxPackIndexEntries, or the resulting final
   physical file size would exceed MaxPackBytes;
8. places a record larger than the configured target alone, provided it is
   within the hard record/pack limits; and
9. never emits an empty pack.

“Oversized” means larger than the configured grouping target, not larger than
the hard record limit. Default Task 2A's 64 MiB record limit equals the default
target, while tests can prove the single-large-record rule with a smaller
injected target.

Worker scheduling never selects order or grouping. Forced serial, forward,
reverse, and seeded-random completion of the same prepared/reuse inputs must
emit byte-identical pack indexes, pack bytes, PackIds, manifest bytes, and
GenerationId.

The production preparation/aggregation boundary carries both a stable
PreparationOrdinal and observed CompletionOrdinal. Both are exact permutations
of `0..N-1`; array storage order is not schedule authority. ForcedSerial mode
requires `CompletionOrdinal == PreparationOrdinal`; BoundedParallel accepts any
complete permutation. The aggregator validates and then discards both ordinals
before canonical RecordId sorting/grouping. Tests inject forward, reverse, and
seeded-random completion permutations through this same pure production seam;
they do not substitute input insertion order for completion order and require no
real worker threads.

## Exact generation reachability

### Allowed RecordId edges

The only V1 RecordId edges are inherited unchanged:

| Owner | Allowed outgoing RecordId links |
|---|---|
| SourceIndex | none |
| ModuleInterface | none |
| TypeSchema | none |
| ModuleState | none |
| FunctionBody | optional one DebugSidecar |
| DebugSidecar | none |
| ModuleSnapshot | one ModuleInterface, keyed TypeSchemas, one ModuleState, keyed FunctionBodies |
| manifest | exactly one SourceIndex plus keyed ModuleSnapshot roots |

Stable semantic dependencies are not RecordId reachability edges.

### Required algorithm

After local manifest and pack validation, one caller-owned read budget is used
to decode the manifest-selected records. The validator then:

1. initializes traversal with SourceIndexRecordId and every keyed
   ModuleSnapshotRecordId;
2. resolves each selected RecordId exactly once through the manifest index;
3. requires every link target to exist and have the expected RecordKind;
4. follows only the allowed edges above, including every FunctionBody-owned
   DebugSidecar;
5. compares the complete visited RecordId set with the manifest record-index
   RecordId set; a missing target is `MissingRecord`, while any unvisited
   indexed record is `UnexpectedRecord`;
6. validates SourceIndex's embedded SourceSnapshot equals the manifest
   SourceSnapshot;
7. validates every root ModuleSnapshot's embedded ModuleKey equals its root
   ModuleKey; and
8. invokes the frozen Task 2B-2 per-module graph validator exactly once for
   every keyed ModuleSnapshot root, including roots with no functions or
   TypeSchemas.

The manifest record index is therefore exactly the transitive reachable set.
A referenced pack's internal index may contain extra historical entries, but
those entries are not added to the generation traversal and are not a manifest
error.

On guarded-test success, the caller-owned visited output is the canonical
RecordId-sorted visited set and equals the manifest record-index RecordId
sequence element-for-element. Every failure clears a prepopulated visited
output.

## Read limits and one cumulative budget

### Default V1 limits

All limits are injectable downward in tests. The default policy is:

```text
MaxCanonicalRecordPayloadBytes =  64 MiB
MaxStoredRecordBytes           =  64 MiB
MaxManifestBytes               =  64 MiB
MaxPackBytes                   = 128 MiB
MaxPackIndexEntries            = 262,144
MaxGenerationRecords           = 262,144
MaxModuleSnapshots             = 262,144
MaxGenerationPacks             =   4,096
MaxStringBytes                 =   1 MiB
MaxArrayElements               =   1 Mi elements
MaxNestingDepth                =  64
MaxReferencesAndRelocations    =   1 Mi elements
MaxTotalStoredBytes            = 512 MiB
MaxTotalDecompressedBytes      = 512 MiB
MaxTotalDecodedBytes           = 512 MiB
MaxResidentDecodedBytes        = 512 MiB
```

MiB is exactly `1024 * 1024` bytes. A count limit never replaces the checked
`count * minimum wire bytes <= remaining bytes` proof. Manifest and pack
physical limits are checked before whole-file allocation or reserve.
MaxGenerationPacks counts distinct PackIds, not record-index entries. The
writer refuses a generation whose final manifest would exceed it; the reader
builds the distinct-ID set as caller-owned temporary decoded state under the
same TotalDecoded and combined-live accounting described below, and returns
BudgetExceeded before any pack source lookup, file open, or handle allocation.

### Counter semantics

One `FAngelscriptCacheReadBudget` is created for a candidate generation read
session and passed through manifest decode, pack/index validation, every
selected record read, semantic decode, opaque-codec summary, reachability, and
per-module graph validation. No child or retry resets it.

StoredBytes, DecompressedBytes, DecodedBytes and ReferencesAndRelocations are
unsigned checked monotonic totals in V1. Retained and temporary decoded bytes
separately describe current live ownership, while one peak observes their
combined live value:

- StoredBytes consumes StoredSize before reading/copying each selected blob.
- DecompressedBytes consumes RawSize before producing raw bytes for both None
  and Zlib. Counting None prevents codec choice from bypassing raw-output
  limits.
- DecodedBytes consumes every retained or temporary decoded allocation charge,
  including the raw payload buffer, manifest/index scratch, decoded semantic
  candidates and graph scratch. It is monotonic: releasing temporary memory
  does not refund TotalDecoded.
- ResidentDecodedBytes is current retained decoded ownership. A successful
  candidate promotes its aggregate temporary ownership to retained exactly
  once; a failed candidate never promotes.
- TemporaryResidentDecodedBytes is current temporary decoded ownership. The
  raw payload buffer, bounded distinct-PackId set, candidate DTO allocations
  and graph scratch reserve here before allocation and release on every exit.
  Release decrements current temporary live bytes but never refunds
  DecodedBytes.
- The selected record's complete RawSize buffer is one temporary reservation
  acquired before None copy or Zlib decode. It remains live through exact-size,
  RawChecksum and semantic RecordId validation and through the sole decoded
  factory's candidate/promotion decision, then releases on both success and
  failure. Factory candidate bytes therefore overlap this raw reservation in
  the combined-live peak; a codec or factory cannot hide behind separate
  resident limits.
- MaxResidentDecodedBytes limits the checked sum
  `ResidentDecodedBytes + TemporaryResidentDecodedBytes`, not either component
  independently. Every acquire preflights TotalDecoded and this combined-live
  value atomically. `PeakLiveResidentDecodedBytes` is the maximum successfully
  acquired combined-live value observed during the session and never exceeds
  MaxResidentDecodedBytes.
- ReferencesAndRelocations consumes record-index/graph entries and opaque-codec
  reference, relocation, debug-source, and owned-byte summaries as already
  frozen by Task 2B-2.

Each counter is charged or reserved before the corresponding
allocation/decompression. Failure does not refund monotonic totals; it does
release every live temporary reservation. Repeated public read calls therefore
charge monotonic totals again without leaking current temporary live bytes.
This prevents repeated corrupt reads from bypassing the session limit. Every
failure clears the current output and publishes no partial record, manifest,
pack, or validated graph.

## Validation stages

The diagnostic stage is not serialized. Preserve values `0..6` and append:

```text
EAngelscriptCacheValidationStage
  None=0
  EnvelopeDecode=1
  PayloadDecode=2
  LocalSemantic=3
  OpaqueCodec=4
  ModuleGraph=5
  CurrentResolver=6
  PackDecode=7
  ManifestDecode=8
  ManifestGraph=9
```

Pack header/index/range/codec/PackId failures use PackDecode. Manifest header,
field, ordering, count, and GenerationId failures use ManifestDecode. Exact
generation reachability and root/link ownership use ManifestGraph. Existing
record/module/current stages are unchanged.

ByteOffset is the first failing absolute byte offset in the containing pack or
manifest when a physical field/range is at fault. A generation graph error uses
the manifest offset of the responsible root or record-index entry. If no single
physical field owns a derived set mismatch, ByteOffset is the RecordCount
field offset. RecordKind is set when the failure is attributable to one record;
otherwise it is Invalid/zero.

The guarded reachability projection receives the SourceIndex root's manifest
byte offset explicitly, in addition to each keyed ModuleSnapshot/root-index
offset. It records caller-owned visited IDs and per-root graph calls from the
same production traversal. It does not infer offsets, run a second traversal,
decode payloads, or publish records.

## Validation errors and exact classification

Errors `0..64` retain their frozen values and classifications. Append only:

```text
UnsupportedStorageCodec=65
DecompressionFailed=66
DecompressedSizeMismatch=67
PackIdMismatch=68
GenerationIdMismatch=69
OverlappingRange=70
PackIndexMismatch=71
```

Use existing errors rather than aliases:

- raw payload checksum mismatch is `ChecksumMismatch`;
- semantic RecordId mismatch is `RecordIdMismatch`;
- invalid/truncated ranges are `Overflow` or `OutOfBounds`;
- impossible counts are `ImpossibleCount`;
- duplicate/conflicting locations are `DuplicateKey`/`ConflictingKey`;
- wrong linked kind is `WrongRecordKind`;
- missing/extra reachable records are `MissingRecord`/`UnexpectedRecord`;
- noncanonical order is `NonCanonicalOrder`; and
- every limit failure is `BudgetExceeded`.

The exhaustive classification table becomes:

| Class | Errors |
|---|---|
| Success | None |
| Malformed | BadMagic, UnsupportedSchema, UnsupportedPayloadSchema, UnknownRecordKind, UnknownEnumValue, UnknownFlags, InvalidBoolean, InvalidOptionalTag, NonZeroReserved, InvalidUtf8, EmbeddedNul, InvalidLogicalPath, TrailingData, InvalidArrayView, AliasedInputOutput |
| ArithmeticOrBudget | Overflow, BudgetExceeded, OutOfBounds, ImpossibleCount, NestingDepthExceeded, OverlappingRange |
| CodecOrIntegrity | ChecksumMismatch, RecordIdMismatch, UnsupportedCodecVersion, OpaquePayloadMalformed, OpaquePayloadHashMismatch, UnsupportedStorageCodec, DecompressionFailed, DecompressedSizeMismatch, PackIdMismatch, GenerationIdMismatch, PackIndexMismatch |
| CanonicalSemantic | NonCanonicalOrder, DuplicateKey, ConflictingKey, CaseCollision, ZeroStableKey, MissingExpectedAbi, ForbiddenExpectedAbi, InvalidPresence, InvalidQualifierCombination, OrdinalGap, DuplicateOrdinal, DerivedHashMismatch |
| GraphOrOwnership | MissingOwner, CrossModuleOwner, MissingGraphTarget, WrongReferenceKind, RelocationDependencyMismatch, WrongRecordKind, MissingRecord, MissingCoverage, UnexpectedRecord, UndeclaredEntity, DuplicateDebugOwner, DebugLinkMismatch, EnumAuthorityMismatch, InitializerOwnershipMismatch, GlobalCoverageMismatch, ProfileGraphMismatch, SourceGraphMismatch, GraphAbiMismatch, InvocationKindMismatch, DebugSourceMismatch |
| Ineligible | CompatibilityMismatch, ContextMismatch, ProfileMismatch, SourceSnapshotMismatch, CurrentAbiMismatch, CurrentContentMismatch, CurrentSymbolMissing |

`Classify(Error)` remains the only class authority. Result construction derives
Class; callers never choose one.

## Fixed validation precedence

### Pack precedence

For a complete pack and expected PackId:

1. validate input view state and MaxPackBytes;
2. prove fixed header bytes, then magic/schema/header size/entry size;
3. validate count, checked `count * 96`, exact DataOffset, enum/reserved bytes,
   per-entry size limits, ranges, EOF, canonical order, duplicates, and overlap;
4. recompute/compare complete PackId;
5. when selecting a record, require the manifest location to equal the pack
   index entry exactly;
6. charge StoredBytes and read the stored blob;
7. charge DecompressedBytes, then reserve RawSize against TotalDecoded and
   combined retained-plus-temporary live bytes before decoding None or
   canonical Zlib into a temporary raw buffer;
8. validate exact raw size, RawChecksum, and semantic RecordId; and
9. pass the validated raw payload and declared semantic RecordId to the sole
   common `TryDecode` factory under the same Limits/Budget, then publish only
   its immutable decoded-record handle after every local check succeeds.

A malformed header/range is not hidden by a later PackIdMismatch.
PackId-association mismatch has ByteOffset zero because PackId is not stored in
the pack; each other location mismatch is `PackIndexMismatch` at the differing
internal pack-index field (PackOffset, StoredSize, RawSize, Codec, or
RawChecksum).

### Manifest/generation precedence

For complete manifest bytes and an outer expected GenerationId:

1. validate input view state and MaxManifestBytes;
2. prove fixed fields, magic/schema/flags, counts, minimum bytes, nonzero values,
   Profile recomputation, RecordKinds, canonical order, duplicates/conflicts,
   exact EOF, and the bounded distinct PackId set before pack access;
3. recompute/compare GenerationId;
4. validate every distinct referenced pack and every manifest-to-pack location;
5. decode selected records under the same budget;
6. validate exact generation reachability and per-module immutable graphs; and
7. only then compare requested compatibility/context/profile/source/current
   ABI/content/symbol eligibility.

Internal corruption never falls through to a normal ineligible miss.

## Required pure interfaces

Names may follow established project naming, but the boundary must express all
required inputs and outputs. At minimum it is equivalent to:

```cpp
enum class EAngelscriptCachePackCompressionPolicy : uint8
{
    Auto = 1,
    ForceNoneForTest = 2,
    ForceZlibForTest = 3,
};

struct FAngelscriptPreparedRecord
{
    FAngelscriptCacheRecordId RecordId;
    TArray<uint8> CanonicalPayload;
};

enum class EAngelscriptCachePreparationExecutionMode : uint8
{
    ForcedSerial = 1,
    BoundedParallel = 2,
};

struct FAngelscriptPreparedRecordCompletion
{
    uint32 PreparationOrdinal;
    uint32 CompletionOrdinal;
    FAngelscriptPreparedRecord Record;
};

struct FAngelscriptEncodedPack
{
    FAngelscriptHash256 PackId;
    TArray<uint8> Bytes;
    TArray<FAngelscriptCachePackIndexEntry> Index;
};

TValueOrError<TArray<FAngelscriptEncodedPack>, FAngelscriptCacheValidationResult>
BuildAngelscriptCachePacks(
    TConstArrayView<FAngelscriptPreparedRecord> NewRecords,
    const FAngelscriptCachePackPolicy& Policy,
    IAngelscriptCacheStorageCodec& Codec);

TValueOrError<TArray<FAngelscriptEncodedPack>, FAngelscriptCacheValidationResult>
AggregateAngelscriptCachePreparedRecordCompletions(
    TConstArrayView<FAngelscriptPreparedRecordCompletion> Completions,
    EAngelscriptCachePreparationExecutionMode ExecutionMode,
    const FAngelscriptCachePackPolicy& Policy,
    IAngelscriptCacheStorageCodec& Codec);

TValueOrError<FAngelscriptDecodedCacheRecordHandle, FAngelscriptCacheValidationResult>
ReadAngelscriptCacheRecordFromPack(
    TConstArrayView<uint8> CompletePackBytes,
    const FAngelscriptHash256& ExpectedPackId,
    const FAngelscriptCacheRecordIndexEntry& ManifestEntry,
    const FAngelscriptCacheReadLimits& Limits,
    FAngelscriptCacheReadBudget& Budget,
    IAngelscriptCacheStorageCodec& Codec);

TValueOrError<FAngelscriptEncodedGenerationManifest, FAngelscriptCacheValidationResult>
EncodeAngelscriptCacheGenerationManifest(
    const FAngelscriptCacheGenerationManifestValue& Value);

TValueOrError<FAngelscriptValidatedGeneration, FAngelscriptCacheValidationResult>
ValidateAngelscriptCacheGeneration(
    TConstArrayView<uint8> CompleteManifestBytes,
    const FAngelscriptHash256& ExpectedGenerationId,
    IAngelscriptCachePackSource& Packs,
    FAngelscriptCacheReadBudget& Budget);
```

The encoded manifest result carries computed GenerationId separately. The
pack-read API receives complete pack bytes plus expected PackId; a location-only
API cannot validate complete physical identity and is not sufficient.

Every public writer/validator/read entry clears its caller-owned output at entry,
before input-view, header, or local validation. This includes previously
successful decoded-record handles and validated generations, not only empty or
default outputs. A header failure therefore leaves the already accumulated
Budget unchanged and performs no pack-source lookup/open while still clearing
the prior output. Later failures retain the frozen monotonic Budget charges but
release all temporary live reservations and publish no partial replacement.

## Required byte-golden and malformed evidence

Before Task 2B-3 GREEN, pure tests freeze at least:

- one minimum zero-module manifest and full GenerationId golden;
- one multi-module/multi-pack manifest with complete keyed roots, record index,
  bytes, and GenerationId golden;
- one empty-payload None pack and full PackId golden;
- one mixed None/Zlib multi-record pack with exact 32-byte header, 96-byte
  entries, stored blobs, and PackId golden;
- equal semantic records represented by valid None versus Auto-Zlib packs:
  equal RecordIds, unequal PackIds, and unequal GenerationIds when selected;
- forward/reverse/map/serial/random worker inputs producing identical complete
  bytes and IDs;
- pack extra historical content accepted while manifest extra content is
  rejected;
- every header/schema/reserved/count/order/duplicate/conflict/range/gap/
  overlap/EOF/codec/short-output/excess-output/trailing-zlib/checksum/RecordId/
  PackId/GenerationId/location mismatch;
- every missing/wrong-kind/unreachable root, child, and DebugSidecar case; and
- injected failures for every local and cumulative budget before allocation,
  including MaxGenerationPacks+1 distinct IDs with zero pack-source lookups or
  handle opens.

These tests do not open a filesystem or construct an AngelScript engine.

## Closed V1 decisions

V1 has no remaining choice between payload versus envelope storage, absolute
versus relative offsets, embedded versus outer PackId/GenerationId, whole-pack
versus per-record codec, Zlib level/window, raw-checksum input, pack-extra
semantics, empty-range semantics, budget accounting, or error classification.
Changing any of those choices requires an explicit format/compatibility change
and regenerated golden vectors; it is not an implementation detail.
