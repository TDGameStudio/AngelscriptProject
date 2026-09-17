# LANG-VAR-ASSIGN-TARGET

Author reference for `FVarAssignTargetGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Assignment: `SIMPLE` | `COPY_SOURCE` | `SELF_ASSIGNMENT` | `COMPOUND` | `REFERENCE_REBIND`
2. Target: `MUTABLE_LOCAL` | `CONST_LOCAL` | `MUTABLE_FIELD` | `CONST_FIELD` | `REFERENCE_ALIAS` | `TEMPORARY` | `EXPRESSION_RESULT`
3. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF` | `SCRIPT_VALUE` | `NATIVE_VALUE` | `SCRIPT_REFERENCE` | `NATIVE_REFERENCE`

Product ID prefix: `LANG-VAR-ASSIGN-TARGET`. Complete set: 595 cells. Normal-return = 212. Compile reject = 383. Runtime fault = 0.

Example: `LANG-VAR-ASSIGN-TARGET-SIMPLE-MUTABLE_LOCAL-INT8` → `int EntryLangVarAssignTargetSimpleMutableLocalInt8()`.

## Source branches

Shared helpers, emitted once per aggregate: `ENativeAssignmentEnum`, `NativeCaseAlias`, script/native value and reference types, `ObserveAssignmentValue` overloads, unique `FAssignmentHolder{Type}`, and unique `ApplyAssignmentAlias{Kind}{Type}`.

Host lifecycle callbacks are script constructors that store `Value` only.

## Observation

Independent oracle:

- discarded temporary/expression value-object assignment → 0
- `self_assignment` → initial (bool/enum 0, else 11)
- `compound` → initial + source (11+29 or 0+1)
- `copy_source` → `TargetAfter * 100 + SourceAfter`
- `reference_rebind` → `37 * 100 + 37` (bool/enum 0)
- `simple` → source (bool/enum 1, else 29)

`ShouldCompile`: writable targets `mutable_local` / `mutable_field` / `reference_alias`; compound only integer/float/typedef; rebind only references. The current fork also accepts const-local reference assignment (except compound) and discarded value-object assignment to temporary/expression_result.

`GetExpected` uses this table for the 212 non-reject IDs and returns 0 for reject IDs and unknown IDs. Discarded value-object cells and self-assignment bool/enum cells are real expected-zero rows; that populated optional is not the unknown-ID fallback.

`BuildAssignmentSource` accepts every compiling cell. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source. Positive builders refuse reject-category inputs.
