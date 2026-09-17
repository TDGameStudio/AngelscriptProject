# LANG-PROP-INDEXED

Author reference for `FPropIndexedGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Candidate set: `SAME_TYPE` | `ADJACENT_NUMERIC` | `CROSS_FAMILY` | `COMPETING_PRIMARY_FIRST` | `COMPETING_SECONDARY_FIRST` | `UNRELATED`
2. Index type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF`
3. Operation: `READ` | `WRITE` | `COMPOUND`
4. Receiver: `MUTABLE` | `CONST`

Product ID prefix: `LANG-PROP-INDEXED`. Complete set: 6×13×3×2 = 468 cells. Normal-return aggregate = 129. Compile reject = 339. Runtime fault = 0.

Reject cells:

- every `COMPOUND` operation
- every `READ` on a competing candidate set
- every cell whose first candidate does not match (`UNRELATED`; `ADJACENT_NUMERIC`/`CROSS_FAMILY`/`COMPETING_SECONDARY_FIRST` with `BOOL` or `ENUM`)
- every `WRITE` on a `CONST` receiver

Example: `LANG-PROP-INDEXED-SAME_TYPE-INT8-READ-MUTABLE` → `int EntryLangPropIndexedSameTypeInt8ReadMutable()`.

## Source branches

Shared helper, emitted once per aggregate or isolated reject module: `enum ERegisteredIndex { Three = 3 }`.

Each entry records `const int CandidateMarker = 101|201|301|401|402|0`, constructs `CreateIndexedProperty()`, and binds a typed `Index` (`3`, `3.0f`, `3.0`, `true`, or `ERegisteredIndex::Three`). Operations use `Receiver.Value[Index]`, `= 73`, or `+= 5`.

`BuildIndexedPropertySource` is positive-only and returns empty for reject cells. `BuildRejectSource` and `ListRejectCaseIds` own the 339 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent oracle for normal-return cells:

- read: `Marker * 100 + Argument`
- write: `Marker * 10000 + Argument * 100 + 73`

`Argument` is `1` for `BOOL` and `3` otherwise. Markers: same_type 101, adjacent 201, cross 301, competing primary 401, competing secondary 402.

`GetExpected` uses this formula for the 129 normal IDs and returns 0 for reject and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue` + `RequiresHostSetup`. Host notes name `CreateIndexedProperty` and `ObserveIndexedProperty`.
