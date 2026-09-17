# LANG-OP-ASSIGNMENT

Author reference for `FOpAssignmentGenerator`. This file is not part of the ordinary `.as` projection.

Naming assumed: `EOpAssignmentCategory` — product stem plus Category axis.
Naming assumed: `EOpAssignmentOperation` — product stem plus Operation axis.
Naming assumed: `EOpAssignmentType` — product stem plus Type axis.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. The operation and type share one multiword token joined by `_`. Legacy `MakeNativeCaseId` underscore-to-hyphen smash is normalized away; cells are not removed.

1. Category: `LOCAL` | `FIELD` | `PROPERTY` | `ALIAS`
2. Operation+type: `{ASSIGN|ADD_ASSIGN|SUBTRACT_ASSIGN|MULTIPLY_ASSIGN|DIVIDE_ASSIGN|MODULO_ASSIGN|POWER_ASSIGN|AND_ASSIGN|OR_ASSIGN|XOR_ASSIGN|SHIFT_LEFT_ASSIGN|SHIFT_RIGHT_LOGICAL_ASSIGN|SHIFT_RIGHT_ARITHMETIC_ASSIGN}_{INT8|INT16|INT|INT64|UINT8|UINT16|UINT|UINT64|FLOAT32|FLOAT64|BOOL}`

Supported pairs only (`SupportsOperation`): `ASSIGN` on every primitive; `+ − * / %` on numeric; `**=` on float32/float64; bitwise/shifts on integral. 111 pairs × 4 categories = 444 cells. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-ASSIGNMENT-LOCAL-ASSIGN_INT` → `int EntryLangOpAssignmentLocalAssignInt()`.

## Source branches

Shared aggregate helpers, emitted once:

- `struct FAssignmentFieldOwner_<type>` for every primitive.
- `Apply<Op>Alias_<type>(Type& inout Value, Type Source)` for every supported pair.

Each entry hardcodes `Input`/`Source` as 4/2 (bool false/true, float 4.0/2.0) and writes the selected operator:

- local: `Value <op> Source` then `ObserveAssignment_<type>(Result, Value)`
- field: `Owner.Value <op> Source`
- property assign: `Result = Source`; compound: `Current = Owner.get_Value(); Current <op> Source`
- alias: `Result = Apply<Op>Alias_<type>(Value, Source)`

`float64` script spelling is `double` (legacy CanonicalType). Empty `FunctionName` emits `Entry`. `bad-name` and unsupported pairs emit no source.

## Observation

Independent int32 of `4 <op> 2` (bool assign → 1):

| op | value |
| --- | --- |
| `=` `-=` `/=` | 2 |
| `+=` `\|=` `^=` | 6 |
| `*=` | 8 |
| `%=` `&=` | 0 |
| `**=` `<<=` | 16 |
| `>>=` `>>>=` | 1 |

`INT64`, `UINT64`, `FLOAT32`, and `FLOAT64` set `bLimitedObservation`; the int32 is not full-width or bit-exact proof. Real zeros (`%=`, `&=`) keep `ExpectedReturn` set. Unknown `GetExpected` is 0 and is not membership.

All rows are `ReturnValue` + `RequiresHostSetup`. Host notes name `ObserveAssignment_*` and property fixtures.
