# LANG-FN-TYPED-DEFAULTS

Author reference for `FFnTypedDefaultsGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Arity: `ONE` | `TWO` | `THREE` | `FOUR`
2. Type: `HOMOGENEOUS_INT` | `HOMOGENEOUS_BOOL` | `ALTERNATING_INT_BOOL` | `ALTERNATING_BOOL_INT`
3. Target: `GLOBAL` | `NAMESPACE_GLOBAL` | `INSTANCE_METHOD`
4. OmittedCount: integer knob `OMIT0` … `OMITn` where `n` equals arity

Product ID prefix: `LANG-FN-TYPED-DEFAULTS`. Complete set: 4 type patterns × 3 targets × (2+3+4+5) omitted counts = 168 cells. Normal-return aggregate = 168. Compile reject = 0. Runtime fault = 0.

Example: `LANG-FN-TYPED-DEFAULTS-ONE-HOMOGENEOUS_INT-GLOBAL-OMIT0` → `int EntryLangFnTypedDefaultsOneHomogeneousIntGlobalOmit0()`.

## Source branches

Each cell emits a unique `Probe` whose every parameter has a default, plus an `int` entry that omits the trailing `OmittedCount` arguments. Aggregate and dump uniquify probe, namespace, and owner names from the entry stem. Isolated `Entry` / `ProbeEntry` modules keep the short `Probe` / `NDefaults` / `FOwner` names.

Integer defaults are `100`, `10 + 2`, `0x10`, `-7`. Bool defaults are `true`, `false`, `1 < 2`, `2 == 3`. Explicit arguments are `1..4` or `false`/`true`/`false`/`true`. The probe returns the sum of int parameters and `(P ? 1 : 0)` for bool parameters.

`BuildSource` is positive-only. `OmittedCount` outside `0..arity` is invalid. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent marker: for slot `i`, use the default value when `i >= arity - omitted`, otherwise the explicit value (`100/12/16/-7` or bool `1/0/1/0`; explicit ints `i+1`, explicit bools alternate `0/1`).

`GetExpected` uses that marker for the 168 IDs and returns `0` for unknown IDs. Some normal cells honestly observe `0` (for example a single omitted-false bool); those keep a populated `ExpectedReturn` optional and are not confused with an unknown ID.

Normal rows are `ReturnValue` + `Standalone`. No host, lifecycle, or limited-observation notes apply.
