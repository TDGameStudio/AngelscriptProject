# LANG-FE-TRANSFER-LIFETIME

Author reference for `FForeachTransferLifetimeGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Transfer: `COMPLETE` | `BREAK_FIRST` | `BREAK_MIDDLE` | `CONTINUE_FIRST` | `CONTINUE_MIDDLE` | `RETURN` | `EXCEPTION`
2. Nesting: `SINGLE` | `NESTED_SAME` | `NESTED_DISTINCT` | `INSIDE_FOR`
3. Element: `PRIMITIVE_VALUE` | `VALUE_OBJECT_COPY` | `VALUE_OBJECT_CONST_REF`

Product ID prefix: `LANG-FE-TRANSFER-LIFETIME`. Complete set: 7×4×3 = 84 cells. Enumeration nests Transfer (outer), then Nesting, Element (inner).

Normal-return aggregate = 72. Compile reject = 0. Runtime fault (`divide_by_zero`) = 12 (`EXCEPTION` × every nesting × every element). OutCaseCount = 84.

Example: `LANG-FE-TRANSFER-LIFETIME-COMPLETE-SINGLE-PRIMITIVE_VALUE` → `int EntryLangFeTransferLifetimeCompleteSinglePrimitiveValue()`.

## Source branches

Each case owns `FForeachTransferRange_<Entry>` wrapping `FNativeCaseRange`. Value-object elements store `FNativeCaseValue`. The foreach variable is `int`, `FNativeCaseValue`, or `const FNativeCaseValue&`.

The primary range has `Count = 3`. `NESTED_DISTINCT` adds `OtherRange` with `Count = 2`.

Inner loop visits add `Trace += 1` plus a typed `Value - Value` (or `.Value`) no-op, then the transfer:

- `BREAK_FIRST` / `CONTINUE_FIRST`: on iteration 0
- `BREAK_MIDDLE` / `CONTINUE_MIDDLE`: on iteration 1
- `RETURN`: `return Trace;`
- `EXCEPTION`: `Trace += 1 / Zero`

Nesting:

- `SINGLE`: one foreach
- `NESTED_SAME` / `NESTED_DISTINCT`: outer foreach adds 100, then an inner foreach on `Range` or `OtherRange`
- `INSIDE_FOR`: `for (OuterIndex < 2)` adds 10 around the foreach

Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`InnerLimit` is 2 for `NESTED_DISTINCT`, otherwise 3. `InnerVisits = TransferVisitCount`: `RETURN` / `EXCEPTION` / `BREAK_FIRST` → `min(L, 1)`; `BREAK_MIDDLE` → `min(L, 2)`; otherwise `L`.

- `EXCEPTION`: catalog observation is the runtime fault, not an integer (`GetExpected` returns 0)
- `SINGLE`: `InnerVisits`
- `NESTED_SAME` / `NESTED_DISTINCT`: `Outer * 100 + Outer * InnerVisits` with `Outer = 1` on `RETURN`, else 3
- `INSIDE_FOR`: `Outer * 10 + Outer * InnerVisits` with `Outer = 1` on `RETURN`, else 2

`GetExpected` uses this formula for the 72 non-exception IDs. Fault IDs and unknown IDs return 0; that zero fallback is not membership proof.

Normal rows are `ReturnValue` + `RequiresHostSetup`. Fault rows are `RuntimeException` with exact text `Divide by zero` and no integer expectation. Host notes name `FNativeCaseRange` and `FNativeCaseValue`.
