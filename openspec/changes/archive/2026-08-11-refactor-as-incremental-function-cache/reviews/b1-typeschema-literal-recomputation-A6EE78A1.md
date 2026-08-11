# B1 TypeSchema IC-139 literal recomputation

Date: 2026-08-09 (Asia/Shanghai)

Candidate:
`Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp`

Exact candidate SHA-256 at review start and end:
`A6EE78A19AC83A6F93AB86AD2072BF7E0758C0B699436D46D396DCAEB19CE66A`.
The review was read-only and changed no candidate, Runtime or frozen-authority
file.

## Scope and independence

The reviewer rebuilt the canonical LayoutInputHash and EnumAuthorityHash streams
from `type-layout-authority-v1.md`, `type-schema-matrix-v1.md` and the hash-domain
rules in `record-wire-v1-remaining.md`. The computation did not call
`ComputeLayoutInputHash`, `ComputeEnumAuthorityHash`, Unreal `FBlake3` or another
project hash helper.

The independent writer emitted:

1. ASCII `UEAS-ARTIFACT` and one zero byte;
2. schema version `1` as little-endian `u32`;
3. domain as a little-endian `u32` UTF-8 byte length followed by UTF-8 bytes;
4. all integers in little-endian form;
5. hashes as their 32 raw bytes; and
6. optionals as a one-byte presence tag followed by the value when present.

An independently implemented BLAKE3 compression/chunk path was first checked
against these public vectors:

| Input | Expected and actual digest | Result |
|---|---|---|
| empty | `af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262` | PASS |
| `abc` | `6437b3ac38465133ffb63b75273a8db548c558465d79db03fd359c6cd5bd9d85` | PASS |

No production hash implementation was used as the oracle for the four Cache
vectors.

## Results

| Domain/vector | Canonical bytes | Frozen expected | Independent actual | Result |
|---|---:|---|---|---|
| Layout baseline, alignment `8` | 124 | `19903c25b6a2d207614125561a1285221a021062c8219ba41c85a84b89abd04c` | same | PASS |
| Layout mutation, alignment `16` | 124 | `c36d242e8b167abedfad69a23577d0651e9e0edab2118d95dcccd448b67a9ac7` | same | PASS |
| Enum baseline, `Ready=MAX_int32` | 194 | `bc379827084ce82a8635f56600fae4de208534bf92a6d229ab0fa3688fce58e1` | same | PASS |
| Enum mutation, `Ready=MIN_int32` | 194 | `ef456bfeaf07d858e493bd128c2f90534a225bf716854b62113ff14d3d5053ad` | same | PASS |

Candidate assertion locations at this exact SHA are lines 5811, 5818, 5834 and
5842 respectively.

## Byte-level checks

The 124-byte Layout baseline encoded, after the common prefix/domain:

```text
InputKind = CodeRoot = 2
Target.ReferenceKind = EnvironmentSymbol = 7
Target.StableKey = a4 repeated 32 times
Target.ExpectedAbi = a5 repeated 32 times
BoundaryContribution = present, value 0
AlignmentContribution = present, value 8
```

The alignment-16 mutation changed only canonical byte offset 120 from `08` to
`10`; all other 123 bytes were identical. Thus it is a one-logical-field mutation,
not an optional-tag, boundary, reference or domain mutation.

The 194-byte Enum baseline encoded three declaration-order entries:

```text
0, Idle,    -1,        DisplayName=Idle
1, Waiting, -1,        DisplayName=Waiting
2, Ready,   MAX_int32, empty metadata
```

Signed `int32` values preserved their two's-complement bit patterns:

```text
-1        = ff ff ff ff
MAX_int32 = ff ff ff 7f
MIN_int32 = 00 00 00 80
```

The enum mutation changed only bytes 186 through 189, which are the single
logical `Ready.Value` field; the other 190 bytes were identical.

## Domain separation and metadata

Keeping payload bytes fixed while swapping only the domain yielded:

```text
Layout payload + cache-enum-authority-v1
= e2f8d54ba6775006986e001c4b9cc09b2d9d23d2bb4fecb0a84998df7501d1f7

Enum payload + cache-type-layout-input-v1
= 699227c56636af61e1eab622b1cb54b9cfd81c90b42a289749086572b5c1b2a4
```

Neither equals its original-domain digest. Metadata count, key/value encoding and
placement immediately after each enumerator's ordinal/name/value also matched the
authority.

## Disposition

IC-139 literal-vector recomputation: **PASS** for this exact candidate SHA.

One non-blocking future strengthening opportunity remains: every non-empty metadata
array in these four fixtures contains exactly one entry. A separate vector with at
least two entries supplied in reverse canonical order would isolate metadata-sort
behavior. This does not invalidate the four literals and is not an IC-139 blocker.
