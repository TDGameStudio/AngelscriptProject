# LANG-OP-NUMERIC-BINARY

Author reference for `FOpNumericBinaryGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Left type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64`
2. Operator: `ADD` | `SUBTRACT` | `MULTIPLY` | `DIVIDE` | `MODULO` | `LESS` | `LESS_EQUAL` | `GREATER` | `GREATER_EQUAL` | `EQUAL` | `NOT_EQUAL`
3. Right type: same tokens as left type
4. Value: `ZERO` | `ONE` | `NEGATIVE` | `NEAR_MIN` | `NEAR_MAX`

Product ID prefix: `LANG-OP-NUMERIC-BINARY`. Complete set: 10×11×10×5 = 5500 cells, enumerated by integer Index (left, operator, right, value). All 5500 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-NUMERIC-BINARY-INT-ADD-INT-ZERO` → `int EntryLangOpNumericBinaryIntAddIntZero()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated module:

- `ObserveNumericType` overloads for `int`/`uint`/`int64`/`uint64`/`float32`/`float64`/`bool` return 101–107.

Each entry hardcodes typed left and right operands and evaluates `ObserveNumericType(Left <op> Right)`:

- Left uses the catalog partition: 0, 1, -3, min+1 / unsigned 1 or max-2, max-1; floats use 0.0, 1.0, -3.0, ±max/2.
- Right for add/subtract is 1; multiply/divide is 2 except near partitions use 1; modulo is 2; comparisons reuse the left partition on the right type.
- Operator text is `+` `-` `*` `/` `%` `<` `<=` `>` `>=` `==` `!=`.

Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected` is the promoted TypeMarker only: comparison → 107; otherwise float64 → 106, float32 → 105, wide signed → 103, wide unsigned → 104, signed32 → 101, unsigned32 → 102.

int32 TypeMarker is not full-width arithmetic proof. `bLimitedObservation` is true. Unknown IDs return 0 from `GetExpected`; that fallback is not membership proof. There is no real expected-zero normal cell.

All rows are `ReturnValue` + `Standalone`.
