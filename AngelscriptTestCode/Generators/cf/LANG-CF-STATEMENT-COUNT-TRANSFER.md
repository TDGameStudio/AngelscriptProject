# LANG-CF-STATEMENT-COUNT-TRANSFER

Author reference for `FStatementTransferGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated between axes. Multiword tokens keep internal underscores.

1. Statement: `IF` | `IF_ELSE` | `ELSE_IF` | `WHILE` | `DO_WHILE` | `FOR` | `SWITCH` | `NESTED_BLOCK`
2. Count: `ZERO` (Limit=0) | `ONE` (Limit=1) | `TWO` (Limit=2) | `MANY` (Limit=4)
3. Transfer: `NONE` | `BREAK_LOOP` | `BREAK_SWITCH` | `CONTINUE` | `EARLY_RETURN` | `NESTED_RETURN` | `FALLTHROUGH` | `EXCEPTION`
4. Nesting: `NONE` | `SAME_KIND` | `MIXED_LOOP` | `LOOP_SWITCH` | `BRANCH_LOOP` | `THREE_LEVEL`

Product ID prefix: `LANG-CF-STATEMENT-COUNT-TRANSFER`. Complete set: 8×4×8×6 = 1536 cells. Enumeration nests Statement (outer), then Count, Transfer, Nesting (inner), matching the legacy loop order.

Normal-return aggregate = 1344. Reject = 0. Runtime fault (`divide_by_zero`) = 192.

Example: `LANG-CF-STATEMENT-COUNT-TRANSFER-IF-ZERO-NONE-NONE` → `int EntryLangCfStatementCountTransferIfZeroNoneNone()`.

### Legacy token normalization

The dormant `AngelscriptNativeStatementTransferTests` builds IDs through `MakeNativeCaseId`, which upper-cases and then rewrites every `_` to `-`, collapsing multiword tokens (`IF-ELSE`, `DO-WHILE`, `BREAK-LOOP`, `SAME-KIND`). This corpus normalizes that documented defect by retaining internal underscores in the axis tokens, consistent with the sibling ControlFlow products; no cell is added or removed.

## Source branches

Every entry is self-contained; there are no shared helper declarations. Each entry declares local `Trace`, `Limit`, loop `Index`, plus per-branch locals (`Once`, `SameKind`, `MixedLoop`, `BranchLoop`, `ThreeLevel`, `ExceptionDivisor`), so cases never share mutable state.

```
int <Entry>()
{
	int Trace = 0;
	int Limit = <CountLimit>;
	for (int Index = 0; Index < Limit; ++Index)
	{
		Trace += <NestingWeight>;   // nesting prologue
		<nested statement wrapper around the statement body>
		<transfer tail>
	}
	return Trace;
}
```

Statement body adds `Trace += <StatementWeight>` (`IF`=1, `IF_ELSE`=2, `ELSE_IF`=3, `WHILE`=4, `DO_WHILE`=5, `FOR`=6, `SWITCH`=7, `NESTED_BLOCK`=8). `ELSE_IF` also emits dead `Trace += 1000;` / `Trace += 2000;` branches (`Index` is always `>= 0`). `WHILE`/`DO_WHILE`/`FOR` run their body exactly once via a local `Once` guard; `SWITCH` selects on `Index & 1` with both arms weighted equally.

Nesting wraps the statement body and adds `Trace += <NestingWeight>` first (`NONE`=0, `SAME_KIND`=10, `MIXED_LOOP`=20, `LOOP_SWITCH`=30, `BRANCH_LOOP`=40, `THREE_LEVEL`=50). `LOOP_SWITCH` and `THREE_LEVEL` scope the case body in an extra block because the fork rejects a declaration directly under a `case` label.

Transfer tail: `NONE` `Trace += 1;`; `BREAK_LOOP` `Trace += 10; break;`; `BREAK_SWITCH` a `switch(0)` adding 10 then `Trace += 1;`; `CONTINUE` `Trace += 10; continue;`; `EARLY_RETURN` `return Trace + 20;`; `NESTED_RETURN` `if (Trace >= 0) { return Trace + 30; }`; `FALLTHROUGH` `switch(0)` case-0 adds 10 falling through to case-1 adds 1; `EXCEPTION` a runtime divide-by-zero (`int ExceptionDivisor = 0; Trace += 1 / ExceptionDivisor;`). The fork does not accept a string literal in `throw()`, so the divide-by-zero fault replaces it.

`BuildStatementTransferSource` is positive over every valid axis combination (there are no reject inputs); empty `FunctionName` emits `Entry`. An out-of-domain enum cast or an invalid identifier such as `bad-name` emits no source. `BuildCaseSource` returns empty for unknown or foreign-product IDs.

## Observation

For non-exception cells with `Limit = CountLimit` and `PerIteration = StatementWeight + NestingWeight`:

- `Limit == 0` (`ZERO` count): `0` — the loop body never runs.
- `BREAK_LOOP`: `PerIteration + 10` (exits on first iteration).
- `EARLY_RETURN`: `PerIteration + 20`.
- `NESTED_RETURN`: `PerIteration + 30`.
- `BREAK_SWITCH` or `FALLTHROUGH`: `Limit * (PerIteration + 11)`.
- `CONTINUE`: `Limit * (PerIteration + 10)`.
- `NONE`: `Limit * (PerIteration + 1)`.

Non-exception rows are `ReturnValue` + `Standalone` with `ExpectedReturn` set (including the real expected `0` of every `ZERO`-count row).

### Fault-cell selection (192 divide_by_zero)

The category is assigned by the source construction, not by runtime execution of a specific count: every cell whose Transfer axis is `EXCEPTION` contains the divide-by-zero fault path. That is `8 (Statement) × 4 (Count) × 6 (Nesting) = 192` cells, independent of Count. These rows are `RuntimeException` + `Standalone`, carry `ExpectedException = "Divide by zero"`, and have no `ExpectedReturn`. (In the dormant runtime, a `ZERO`-count exception cell would finish without faulting because its loop body never executes; the declared corpus partition still classifies it as a divide-by-zero source cell.)

`GetExpected` returns the observation formula for the 1344 non-exception IDs and returns `0` for exception (fault) IDs and unknown IDs; that zero fallback is not membership proof. No host, lifecycle, or limited-observation notes apply.
