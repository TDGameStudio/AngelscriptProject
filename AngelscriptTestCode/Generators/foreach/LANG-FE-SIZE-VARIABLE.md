# LANG-FE-SIZE-VARIABLE

Author reference for `FForeachSizeVariableGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Size: `EMPTY` (N=0) | `ONE` (N=1) | `TWO` (N=2) | `MANY` (N=4)
2. Element: `PRIMITIVE` | `VALUE_OBJECT` | `REFERENCE_OBJECT` | `CONST_ELEMENT`
3. Variable: `VALUE` | `AUTO` | `MUTABLE_REFERENCE` | `CONST_REFERENCE` | `INCOMPATIBLE`
4. Transfer: `COMPLETE` | `BREAK_FIRST` | `BREAK_MIDDLE` | `BREAK_LAST` | `CONTINUE_FIRST` | `CONTINUE_MIDDLE` | `RETURN` | `EXCEPTION`

Product ID prefix: `LANG-FE-SIZE-VARIABLE`. Complete set: 4×4×5×8 = 640 cells. Enumeration nests Size (outer), then Element, Variable, Transfer (inner).

Normal-return aggregate = 319. Compile reject = 288 (`INCOMPATIBLE`, every `REFERENCE_OBJECT`, and `CONST_ELEMENT`+`MUTABLE_REFERENCE`). Runtime fault (`divide_by_zero`) = 33 (non-reject nonempty `EXCEPTION`). OutCaseCount = 352 (faults stay in the aggregate). Empty `EXCEPTION` remains a normal-return 0 because the loop body never runs.

Example: `LANG-FE-SIZE-VARIABLE-EMPTY-PRIMITIVE-VALUE-COMPLETE` → `int EntryLangFeSizeVariableEmptyPrimitiveValueComplete()`.

## Source branches

Each case owns `FForeachIterationRange_<Entry>`. `VALUE_OBJECT` also owns `FForeachValueElement_<Entry>`; `INCOMPATIBLE` owns `FForeachIncompatibleElement_<Entry>`. Function-suffixed types keep the aggregate collision-free.

`opForValue` follows the element: `int&` (primitive), stored value-object, `FNativeCaseReference@` (reference object), or `const int&` (const element). The foreach variable is `auto`, a typed value/reference, `FNativeCaseReference@`, or the incompatible struct.

The entry sets `Range.Native.Count = N`, then:

- `MUTABLE_REFERENCE` increments `Value` or `Value.Value`
- `Contribution = ElementBias + 1`
- transfer: `break` at first/middle/last, `continue` at first/middle, `return Trace + Contribution`, or `Trace += 1 / Zero`
- otherwise `Trace += Contribution`

`BuildForeachIterationSource` is positive-only. `BuildRejectSource` and `ListRejectCaseIds` own the 288 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`C = 2` for `MUTABLE_REFERENCE`, otherwise 1. `N = CountFor(Size)`.

- `N == 0`: `0`
- `RETURN`: `C`
- `BREAK_FIRST`: `0`
- `BREAK_MIDDLE`: `C`
- `BREAK_LAST` or `CONTINUE_FIRST`: `(N-1)*C`
- `CONTINUE_MIDDLE`: `(N==1 ? 1 : N-1)*C`
- `COMPLETE`: `N*C`

`GetExpected` uses this formula for the 319 normal IDs, including the real expected zeros of empty and `BREAK_FIRST` rows (`ExpectedReturn` stays set). Reject IDs, nonempty-exception fault IDs, and unknown IDs return 0; that zero fallback is not membership proof.

Normal rows are `ReturnValue` + `RequiresHostSetup`. Fault rows are `RuntimeException` with exact text `Divide by zero` and no integer expectation. Reject rows are `CompileReject` + `SourceOnly` with no declaration. Host notes name `FNativeCaseRange` and `FNativeCaseReference`.
