# LANG-REF-DIRECTION

Author reference for `FRefDirectionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Direction: `VALUE` | `IN` | `OUT` | `INOUT`
2. Null: `NON_NULL` | `NULL_INPUT` | `NULL_OUTPUT` | `NULL_RETURN`
3. Relation: `SAME_TWO_NAMES` | `DISTINCT` | `SELF_ASSIGNMENT` | `BASE_DERIVED_VIEWS` | `OUT_REPLACEMENT` | `INOUT_MUTATION`

Product ID prefix: `LANG-REF-DIRECTION`. Complete set: 4×4×6 = 96 cells. Normal-return aggregate = 96. Compile reject = 0. Runtime fault = 0.

Example: `LANG-REF-DIRECTION-VALUE-NON_NULL-SAME_TWO_NAMES` → `int EntryLangRefDirectionValueNonNullSameTwoNames()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated module:

- `ReferenceIdentity` / `ReferenceValue` observe a handle
- `ReturnNullReference` returns `nullptr`

Each cell emits a unique `Apply<EntryName>(FRefRoot [& in|& out|& inout] Target)` plus the named entry:

- `IN` copies `Target` into `Working` before mutation
- `NULL_OUTPUT` assigns `nullptr`; `NULL_RETURN` assigns `ReturnNullReference()`
- `OUT` without replacement/mutation initializes `Target` from `MakeRefRoot` or `MakeRefDerivedAsRoot`
- Relations write 61/62/63, self-assign, replace with 71, or mutate/create 72

Entries construct `Source`/`Target` (including `NULL_INPUT` and `DISTINCT` 32) and call `CaptureDirectionSnapshot` around `Apply*`. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected` is 1 for every declared cell. That return is a source sentinel; host snapshots remain the real direction proof, so rows are `ReturnValue` + `RequiresHostSetup` with limited observation. Unknown IDs return 0 from `GetExpected`; that fallback is not membership proof. There is no real expected-zero normal cell.
