# LANG-FN-OVERLOAD

Author reference for `FFnOverloadGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Discriminator: `TYPE` | `ARITY` | `CONST` | `DIRECTION` | `NAMESPACE` | `DEFAULT` | `CONVERSION`
2. Outcome: `EXACT` | `PROMOTION` | `AMBIGUOUS` | `MISSING`

Product ID prefix: `LANG-FN-OVERLOAD`. Complete set: 7×4 = 28 cells. Normal-return aggregate = 14. Compile reject = 14 (`AMBIGUOUS` and `MISSING`). Runtime fault = 0.

Example: `LANG-FN-OVERLOAD-TYPE-EXACT` → `int EntryLangFnOverloadTypeExact()`.

## Source branches

Each cell emits a `Probe` overload set plus an `int` entry. Aggregate and dump uniquify probe and owner names from the entry stem. Isolated `Entry` / `ProbeEntry` modules keep the short `Probe` / `FOwner` names.

- `TYPE` / `CONVERSION`: exact int+double pair (`CONVERSION` calls `Probe(int(7))`); promotion is double-only; ambiguous is float+double; missing takes `FValue` and calls `Probe(true)`.
- `ARITY` / `DEFAULT`: exact one- and two-int probes called as `Probe(3, 4)`; promotion is two doubles; ambiguous is defaulted extra; missing calls `Probe()` (`DEFAULT`) or `Probe(1, 2, 3)` (`ARITY`).
- `CONST`: methods on a unique `FOwner`; exact has mutable and const `Probe`; promotion is const-only from a mutable `Invoke`; missing calls mutable `Probe` from const `Invoke`.
- `DIRECTION`: `int& in`, `double& in`, float+double in-refs, or `int& out` against a const argument.
- `NAMESPACE`: exact/promotion/ambiguous live in `namespace A` with a decoy in `B`; missing calls `Missing::Probe(7)`.

`BuildOverloadSource` is positive-only and returns empty for reject cells. `BuildRejectSource` and `ListRejectCaseIds` own the 14 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent marker: discriminator base TYPE 100, ARITY 200, CONST 300, DIRECTION 400, NAMESPACE 500, DEFAULT 600, CONVERSION 700, plus 1 for `EXACT` and 2 for `PROMOTION`.

`GetExpected` uses this marker for the 14 normal IDs and returns 0 for reject and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue` + `Standalone`. Reject rows are `CompileReject` with no declaration and `SourceOnly` execution. No host, lifecycle, or limited-observation notes apply.
