# B2 Slice 1 direct-interface golden recomputation

Date: 2026-08-09
Scope: IC-147 / IC-149 normal-producer direct-interface order authority
Status: literals independently recomputed; candidate fix and exact-SHA review are
tracked separately and do not make B2 behavior RED or GREEN.

## Why this attachment exists

The first Slice-1 candidate used normal serialization of one Interface DTO as the
expected bytes for normal serialization of that same DTO. Independent review
correctly rejected that self-confirming comparison. Fix-1 replaced it with two
valid DTOs whose direct-interface target order was reversed and asserted that the
complete payloads differed. Exact-SHA rereview rejected that assertion too:
`TypeLayoutHash` covers each relation's `SemanticOrdinal` and target, so the two
inputs already carried different stored hashes before write. The full payloads
could remain unequal even if a write-only bug sorted the emitted interface rows.

The accepted repair strategy separates the two producer stages:

1. A valid high-key-at-ordinal-zero DTO must serialize successfully. Because
   producer validation recomputes `TypeLayoutHash` after canonicalization, this
   catches target sorting before validation: the stored high-first hash would
   become stale.
2. The exact normal-producer payload is committed through the common TypeSchema
   `RecordId` domain and compared with an independently derived literal. This
   catches target sorting introduced only while writing the final relation array.

No decoder, raw scanner, raw patcher, physical semantic writer, producer trace or
test-side TypeSchema serializer is needed.

## Frozen fixture

```text
PayloadSchemaVersion = 1
ModuleKey             = 0x50 repeated 32 bytes
TypeKey               = 0x53 repeated 32 bytes
TypeKind              = Interface (3)
Namespace             = Gameplay
CanonicalName         = Minimal
Declaration           = type Minimal
TypeSemanticFlags     = Abstract | ReferenceType = 0x00000081
Layout                = { SemanticSize=0, SemanticAlignment=8,
                          BasePropertyBoundary=0 }
Reflection            = None (1), flags 0, optional strings absent, zero members
All local member arrays and LayoutInputs = empty

Direct relations:
  ordinal 0 -> ScriptType key 0xf2*32, ExpectedAbi 0xf3*32
  ordinal 1 -> ScriptType key 0xe2*32, ExpectedAbi 0xe3*32

Dependencies, independently canonicalized by the frozen comparator:
  Inheritance / ScriptType / 0xe2*32 / 0xe3*32 / absent content
  Inheritance / ScriptType / 0xf2*32 / 0xf3*32 / absent content
```

The lower-key `0xe2` target deliberately appears at semantic ordinal 1. A
target-key sort therefore changes the physical relation bytes.

## Three independent recomputation paths

### Root recomputation

The root agent compiled a temporary generic hex-input BLAKE3 utility against the
UE 5.8 bundled BLAKE3 1.3.1 static library. The utility knows nothing about Cache
or TypeSchema. An inline Python byte packer independently emitted the frozen
little-endian artifact and record streams and passed only their hexadecimal bytes
to that utility.

Checks:

- `BLAKE3("abc")` matched published vector
  `6437b3ac38465133ffb63b75273a8db548c558465d79db03fd359c6cd5bd9d85`.
- Applying the reconstructed common record header to the repository's existing
  980-byte Delegate TypeSchema payload golden reproduced its frozen RecordId
  `24c26c072a4e5feba7eec27b1a6dab7a9c0815bbd87198af585f5dec5d1c0260`.
- Temporary source SHA-256:
  `E152E59897FE9FA528B085C606C73B9D19DF4782815EEB22D68644F11FEA6BFB`.
- Temporary executable SHA-256:
  `2F6B47C295B58098B956D2E9AE3FFF480BDF7768C39CE56ABF532675591D2D25`.

### Independent pure-Python recomputation

A fresh read-only agent reconstructed the same streams with a persisted-code-free,
single-chunk pure-Python BLAKE3 implementation. It first asserted the published
empty and `abc` vectors. It did not call normal/physical serialization,
`ComputeTypeLayoutHash`, `TryBuildRecordId`, a decoder, scanner or project hash
helper. Working report SHA-256:
`2DE295AF46D0AC94FBC3FF691A13D61611A3C4D6804DA56554081DF7CE299DF3`.

### Independent oracle/design recomputation

A second fresh read-only agent independently packed the full payload and record
domain, checked published BLAKE3 vectors and the frozen FunctionBody RecordId
vector, and concluded that one hard-coded high-first TypeSchema RecordId golden is
the smallest permitted writer-order oracle. Working report SHA-256:
`8D40D6FEFD066603BCB0696D0E50054DA16005230922D548DBA155EBD70EE2EE`.

All three paths returned the same literals.

## Exact accepted literals

| Fixture | TypeLayoutHash | TypeSchema RecordId.ContentHash | Payload bytes |
|---|---|---|---:|
| ordinal 0=`f2/f3`, ordinal 1=`e2/e3` | `dd58ac98186a58c34b2decc1d15c7842f5c4e61e512515d205caba9c63e04dfd` | `1048a8e8b3e5833e6e600776e93f319fde7281879e8a4ae0bde5ec39effc080d` | 479 |
| ordinal 0=`e2/e3`, ordinal 1=`f2/f3` | `e3a8cd581c4775e7bc0e65e6741629cc4f17ff7cc8701c76909dcdac8c0e1ae0` | `1fe6aff92ffad8e1271c624f6c3ad4aa88141e726b68665958ac4a7b2df90c02` | 479 |

The common RecordId semantic header for either 479-byte TypeSchema payload is:

```text
554541532d43414348452d5245434f5244000200000003df01000000000000
```

It is `UEAS-CACHE-RECORD`, a NUL byte, little-endian archive schema 2,
TypeSchema kind 3 and little-endian `u64(479)`, followed by the payload before
BLAKE3-256 finalization.

### High-first payload consumed by the test

```text
0100000050505050505050505050505050505050505050505050505050505050505050505353535353535353535353535353535353535353535353535353535353535353030800000047616d65706c6179070000004d696e696d616c0c00000074797065204d696e696d616c81000000000000000200000004010000000002f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f304010100000002e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e30000000000000000000000000800000000000000dd58ac98186a58c34b2decc1d15c7842f5c4e61e512515d205caba9c63e04dfd000000000000000000000000000000000100000000000000000000020000000402e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3000402f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f300
```

The test intentionally stores only the 32-byte TypeLayoutHash and RecordId
ContentHash literals plus the byte count, not a duplicate 479-byte serializer.

## Governance and evidence level

These literals are V1 wire/identity authority. An approved payload-schema,
RecordId-domain, field-order or fixture-coordinate change requires a new authority
decision and fresh independent recomputation; a failing test must not be repaired
by casually regenerating the string from the current producer.

This attachment supplies independent literal authority only. IC-145 still prevents
the focused normal-producer methods from truthfully executing until the private
decoder bridge and real Manifest declaration make the complete modules link. A
SingleFile compile or exact-SHA review may advance the B2 authority frontier but
does not close B2 or authorize B3 Runtime changes.
