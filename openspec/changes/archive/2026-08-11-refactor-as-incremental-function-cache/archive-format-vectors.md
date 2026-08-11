# Cache V2 Minimal Record Envelope Vectors

## Scope

These vectors freeze the completed Task 2A memory-only record-envelope
boundary. They do not define any complete SourceIndex, ModuleInterface,
TypeSchema, ModuleState, FunctionBody, DebugSidecar, ModuleSnapshot, manifest,
pack, or disk-store payload. Those semantic schemas are delivered by Task
2B-1 through 2B-3 under `record-schema.md`.

The executable implementation and fixtures are:

- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheTypes.h`;
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheArchive.h`;
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheArchive.cpp`;
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheArchiveEnvelopeTests.cpp`.

Changing the magic, schema, stable enum values, header fields, semantic hash
stream, or validation interpretation requires an explicit archive-schema
compatibility decision and regenerated vectors. Silently changing an expected
value under archive schema `2` is forbidden.

## Stable Wire Values

`EAngelscriptCacheCodec` reserves `None = 0` and `Zlib = 1`.

`EAngelscriptCacheRecordKind` uses these nonzero values:

| Record kind | Wire value |
|---|---:|
| SourceIndex | 1 |
| ModuleInterface | 2 |
| TypeSchema | 3 |
| ModuleState | 4 |
| FunctionBody | 5 |
| DebugSidecar | 6 |
| ModuleSnapshot | 7 |

Zero and unknown values are invalid. The public RecordId operation is the
typed, fail-closed `TryBuildRecordId`; the unchecked hasher has `.cpp` internal
linkage and is reachable only after input validation.

## Physical Envelope

Every minimal envelope is exactly one record and has this fixed header:

```text
offset 0   8 bytes  ASCII "UEASCV2R"
offset 8   u32 LE   archive schema version 2
offset 12  u8       nonzero record kind
offset 13  3 bytes  reserved zero
offset 16  u64 LE   canonical uncompressed payload byte length
offset 24  32 bytes complete semantic RecordId content hash
offset 56  N bytes  canonical uncompressed payload
```

Trailing bytes are invalid; a caller that wants multiple records must use the
later pack/index format rather than concatenating envelopes implicitly.

## Semantic RecordId Stream

The content hash is BLAKE3-256 over exactly:

```text
UTF-8 bytes "UEAS-CACHE-RECORD"
NUL byte
u32 LE semantic record schema version 2
u8 record kind
u64 LE canonical payload byte length
canonical uncompressed payload bytes
```

It excludes the physical magic, reserved bytes, declared checksum field,
compression, pack offset, pack index, and stored representation. The complete
semantic RecordId is `{RecordKind, FullContentHash}`; equality and ordering
use every one of the 256 hash bits. A derived display GUID is never
authoritative.

## Frozen Non-Empty Vector

For `FunctionBody = 5` and payload `10 00 ff 7e`, the semantic content hash is:

```text
0dd0eb1839134871fdb07ec1276b07b386114d1a8d5967b4ff44df131dde3501
```

The complete 60-byte envelope is:

```text
554541534356325202000000050000000400000000000000
0dd0eb1839134871fdb07ec1276b07b386114d1a8d5967b4ff44df131dde3501
1000ff7e
```

## Frozen Empty Vector

An empty canonical payload is valid. For `FunctionBody = 5`, its semantic
content hash is:

```text
7717b3b344c513d829e689476b5005824b5f5c5b92447bd970d1491b490b446d
```

The complete 56-byte envelope is:

```text
554541534356325202000000050000000000000000000000
7717b3b344c513d829e689476b5005824b5f5c5b92447bd970d1491b490b446d
```

Both fixtures deserialize and reserialize byte-identically.

## Fail-Closed Public Boundary

The public APIs reject malformed view state before hashing, reserving,
reading, or publishing:

- `Num() < 0`, positive-size null data, or an unrepresentable address end:
  `InvalidArrayView`;
- zero or unknown record kind: `UnknownRecordKind`;
- input view overlapping the current output allocation:
  `AliasedInputOutput`;
- header-plus-length arithmetic overflow: `Overflow`;
- configured payload or `TArray<int32>` representation limit:
  `BudgetExceeded`;
- truncation: `OutOfBounds`;
- extra bytes: `TrailingData`;
- changed payload or declared semantic hash: `ChecksumMismatch`.

Serialization checks payload/`OutBytes` overlap before output reset or hashing.
Deserialization checks input/`OutEnvelope.CanonicalPayload` overlap before
reset or header access. Address ranges are checked half-open `UPTRINT` ranges;
the implementation performs no relational comparison between unrelated C++
pointers. Empty views do not overlap because no bytes are read.

Every failure clears its output value. The reader then validates header,
magic, schema, kind, reserved bytes, arithmetic, budgets, exact bounds, and
checksum in that order before copying the payload or publishing the RecordId.

## Verification Snapshot

The final focused prefix is
`Angelscript.TestModule.Cache.Archive.Envelope`. The superseding evidence is:

- clean review-fix RED:
  `Saved/Build/as-cache-archive-envelope-review-fix-red2/20260808_042117_495_4bdc00de/`;
- empty-vector placeholder RED (`12/13` pass, the sole failure is the
  intentional empty golden):
  `Saved/Tests/as-cache-archive-envelope-review-fix-golden-red/20260808_042345_582_87702c85/`;
- build GREEN:
  `Saved/Build/as-cache-archive-envelope-green/20260808_042456_438_533302b4/`;
- focused GREEN (`13/13`, zero warnings/errors/not-run):
  `Saved/Tests/as-cache-archive-envelope-green/20260808_042513_872_2a2ebdf1/`.

The final independent re-review result is `Approve`, with `0` Critical, `0`
Important, and `0` Minor findings. Task 2A contains no AS engine construction,
filesystem I/O, pack/store behavior, StaticJIT path, or legacy-cache routing.
