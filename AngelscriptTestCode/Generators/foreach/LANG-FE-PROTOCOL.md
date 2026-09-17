# LANG-FE-PROTOCOL

Author reference for `FForeachProtocolGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Protocol: `COMPLETE` | `OVERLOADED` | `MISSING_BEGIN` | `MISSING_NEXT` | `MISSING_VALUE` | `MISSING_END` | `WRONG_PARAMETER` | `WRONG_RETURN` | `INACCESSIBLE` | `THROWING`
2. Resolution: `EXACT` | `CONVERSION` | `CONST_OVERLOAD` | `AMBIGUOUS` | `MISSING`
3. Nesting: `SINGLE` | `SAME_ITERABLE` | `DISTINCT_ITERABLE` | `INSIDE_FOR` | `CONTAINS_FOR`

Product ID prefix: `LANG-FE-PROTOCOL`. Complete set: 10×5×5 = 250 cells. Enumeration nests Protocol (outer), then Resolution, Nesting (inner).

Normal-return aggregate = 45. Compile reject = 190 (incomplete protocol or unresolved value). Runtime fault (`divide_by_zero`) = 15 (`THROWING` × resolved non-`AMBIGUOUS` × every nesting). OutCaseCount = 60 (faults stay in the aggregate).

Example: `LANG-FE-PROTOCOL-COMPLETE-EXACT-SINGLE` → `int EntryLangFeProtocolCompleteExactSingle()`.

## Source branches

Each case owns a function-suffixed range type (`FForeachProtocolRange_<Entry>` or `FBrokenProtocol_<Entry>`) so case-dependent protocol types never collide.

Complete protocols (`COMPLETE`, `OVERLOADED`, `THROWING`) emit `opForBegin` / `opForEnd` / `opForNext` plus resolution-specific `opForValue`:

- `EXACT`: `int opForValue` returns 1
- `CONVERSION`: `int8 opForValue` returns `int8(2)`; the foreach variable is `int64`
- `CONST_OVERLOAD`: returns 3 and adds `opForValue(int8)`
- `AMBIGUOUS`: `opForValue(int64)` / `opForValue(uint64)` returning 20 / 21
- `MISSING`: `opForValue(const int, const int)` (unresolved)
- `THROWING` (non-ambiguous): `opForValue` returns `1 / Zero`
- `OVERLOADED`: extra `opForBegin(const int)` and `opForValue(int8)`

Broken protocols omit or warp one callback (`MISSING_*`, `WRONG_PARAMETER` uses `int64&`, `WRONG_RETURN` uses `void opForBegin`, `INACCESSIBLE` marks members `private:`).

Nesting wraps a two-element range:

- `SINGLE`: one `foreach`
- `SAME_ITERABLE` / `DISTINCT_ITERABLE`: outer + inner foreach (`OtherRange` when distinct)
- `INSIDE_FOR`: `for (OuterIndex < 2)` around foreach
- `CONTAINS_FOR`: foreach body contains `for (Index < 2)`

Fault entries also inject `Trace += 1 / Zero` before the loop. `BuildForeachProtocolSource` is positive-only. `BuildRejectSource` and `ListRejectCaseIds` own the 190 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`C = ResolutionContribution`: `EXACT`=1, `CONVERSION`=2, `CONST_OVERLOAD`=3, `AMBIGUOUS`=20. Nesting: `SINGLE` → `2C`; `INSIDE_FOR` → `4C`; otherwise `6C`.

`GetExpected` uses this formula for the 45 normal IDs. Reject IDs, fault IDs, and unknown IDs return 0; that zero fallback is not membership proof.

Normal rows are `ReturnValue` + `RequiresHostSetup`. Fault rows are `RuntimeException` with exact text `Divide by zero` and no integer expectation. Reject rows are `CompileReject` + `SourceOnly` with no declaration. Host notes name `FNativeCaseRange`.
