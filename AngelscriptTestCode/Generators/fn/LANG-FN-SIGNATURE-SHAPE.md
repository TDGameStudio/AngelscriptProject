# LANG-FN-SIGNATURE-SHAPE

Author reference for `FFnSignatureShapeGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Target: `GLOBAL` | `NAMESPACE_GLOBAL` | `INSTANCE_METHOD`
2. Direction: `ALL_VALUE` | `ALL_IN` | `ALL_OUT` | `ALTERNATING_INOUT_OUT`
3. Type: `HOMOGENEOUS_INT` | `HOMOGENEOUS_FLOAT` | `ALTERNATING_INT_FLOAT` | `ALTERNATING_FLOAT_INT`
4. Arity: `ONE` | `TWO` | `THREE` | `FOUR`

Product ID prefix: `LANG-FN-SIGNATURE-SHAPE`. Complete set: 3×4×4×4 = 192 cells. Normal-return aggregate = 192. Compile reject = 0. Runtime fault = 0.

Example: `LANG-FN-SIGNATURE-SHAPE-GLOBAL-ALL_VALUE-HOMOGENEOUS_INT-ONE` → `int EntryLangFnSignatureShapeGlobalAllValueHomogeneousIntOne()`.

## Source branches

Each cell emits a unique `Probe` plus an `int` entry. Aggregate and dump uniquify probe, namespace (`N` + stem), and owner (`FOwner` + stem) names from the entry stem. Isolated `Entry` / `ProbeEntry` modules keep the short `Probe` / `NShape` / `FOwner` names.

- `ALL_VALUE`: value parameters; the entry passes literals `i+3` (`i+3.5f` for float).
- `ALL_IN`: `& in` parameters; the entry binds locals at `i+3`.
- `ALL_OUT`: `& out` parameters; the probe writes `100+i` and the entry starts locals at `i+7`.
- `ALTERNATING_INOUT_OUT`: even slots `& inout` (read then `P+1`), odd slots `& out` (`100+i`).

Float parameters contribute `int(P)` to the probe sum. The entry returns `(Result * 1000) + (caller-slot checks ? 1 : 0)`.

`BuildSource` is positive-only. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent marker: for each slot, add `i+3` when the direction does not write, `i+8` when the slot is read-and-written, or `100+i` when it is write-only. The observed integer is `(sum * 1000) + 1`.

`GetExpected` uses that marker for the 192 IDs and returns `0` for unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue` + `Standalone`. No host, lifecycle, or limited-observation notes apply.
