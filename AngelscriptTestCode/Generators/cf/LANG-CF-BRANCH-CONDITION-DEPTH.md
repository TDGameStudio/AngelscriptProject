# LANG-CF-BRANCH-CONDITION-DEPTH

Author reference for `FBranchConditionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Branch: `IF` | `IF_ELSE` | `ELSE_IF_CHAIN`
2. Condition: `VARIABLE` | `COMPARISON` | `LOGICAL` | `NEGATED` | `SIDE_EFFECT`
3. Selection: `FIRST` | `SECOND` | `NONE`
4. Line ending: `LF` | `CRLF`

Product ID prefix: `LANG-CF-BRANCH-CONDITION-DEPTH`. Complete set: 3×5×3×2 = 45 cells. All 45 are normal-return aggregate entries. Reject = 0. Runtime fault = 0.

Example: `LANG-CF-BRANCH-CONDITION-DEPTH-IF-VARIABLE-FIRST-LF` → `int EntryLangCfBranchConditionDepthIfVariableFirstLf()`.

## Source branches

Each entry declares `FirstCondition`, `SecondCondition`, and `BranchMarker`, then one of:

- `if`: only the first condition.
- `if_else`: first condition plus `else`.
- `else_if_chain`: first condition, `else if` second condition, then `else`.

Condition text:

- `variable`: the bool name.
- `comparison`: `Name == true`.
- `logical`: `Name && true`.
- `negated`: `!(Name == false)`.
- `side_effect`: `EvaluateBranchCondition(Name)`.

Selection sets `FirstCondition`/`SecondCondition` to true only for `FIRST`/`SECOND`. After LF construction, `CRLF` cells replace `\n` with `\r\n`. Typed `BuildBranchSource` with empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Packed int32: `Marker * 100 + Calls`.

Marker:

- `if`: 10 when first is selected, else 0.
- `if_else`: 10 when first is selected, else 20.
- `else_if_chain`: 10 / 20 / 30 for first / second / none.

Calls:

- 0 unless `side_effect`.
- `side_effect` + `else_if_chain` + not first: 2.
- other `side_effect`: 1.

`GetExpected` uses this formula for catalog IDs and returns 0 for unknown IDs. That zero fallback is not membership proof. `IF` plus a non-first selection is a real expected zero and keeps `ExpectedReturn` set.

Every listed case is `ReturnValue` + `RequiresHostSetup`. Execution notes: needs native `EvaluateBranchCondition` and `ReadBranchConditionCalls`. The return always calls `ReadBranchConditionCalls()`. No limited-observation flag.
