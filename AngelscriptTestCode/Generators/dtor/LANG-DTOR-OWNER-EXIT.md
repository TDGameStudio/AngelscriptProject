# LANG-DTOR-OWNER-EXIT

Author reference for `FDtorOwnerExitGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Scenario: `LOCAL_BLOCK_END` | `LOCAL_RETURN` | `LOCAL_EARLY_RETURN` | `LOCAL_BREAK` | `LOCAL_CONTINUE` | `LOCAL_SWITCH_EXIT` | `LOCAL_EXCEPTION` | `LOCAL_ABORT` | `LOCAL_UNPREPARE` | `NESTED_LOCAL_BLOCK_END` | `NESTED_LOCAL_RETURN` | `NESTED_LOCAL_EXCEPTION` | `FIELD_BLOCK_END` | `FIELD_RETURN` | `FIELD_EXCEPTION` | `FIELD_ABORT` | `BASE_DERIVED_BLOCK_END` | `BASE_DERIVED_RETURN` | `BASE_DERIVED_EXCEPTION` | `BASE_DERIVED_ABORT` | `TEMPORARY_STATEMENT_END` | `TEMPORARY_EARLY_RETURN` | `TEMPORARY_EXCEPTION` | `RETURNED_VALUE_CONSUME` | `RETURNED_VALUE_DISCARD` | `RETURNED_VALUE_EXCEPTION` | `ARGUMENT_COPY_RETURN` | `ARGUMENT_COPY_EXCEPTION` | `ARGUMENT_COPY_ABORT` | `REFERENCE_SCOPE_END` | `REFERENCE_ALIAS_SCOPE_END` | `REFERENCE_RETURN` | `REFERENCE_EXCEPTION` | `REFERENCE_ABORT` | `REFERENCE_UNPREPARE` | `MODULE_DISCARD_GLOBAL` | `ENGINE_SHUTDOWN_GLOBAL`
2. Nesting: `ONE` | `SEQUENTIAL` | `NESTED_SCOPES` | `NESTED_CALLS` | `LOOP` | `RECURSION`
3. Observation: `EVENT_ORDER` | `OWNERSHIP_ONCE` | `TERMINAL_STATE_RECOVERY`

Product ID prefix: `LANG-DTOR-OWNER-EXIT`. Complete set: 37×6×3 = 666 cells. Enumeration nests Scenario (outer), then Nesting, Observation (inner).

Normal-return aggregate = 522. Compile reject = 0. Runtime fault (`divide_by_zero`) = 144 (the eight `*_EXCEPTION` scenarios × 6 nestings × 3 observations). OutCaseCount = 666.

Example: `LANG-DTOR-OWNER-EXIT-LOCAL_BLOCK_END-ONE-EVENT_ORDER` → `int EntryLangDtorOwnerExitLocalBlockEndOneEventOrder()`.

## Source branches

Shared helpers are emitted once per aggregate or isolated module: `FExitValue`, `FExitReference`, `FExitFieldOwner`, `FExitBaseOwner`, `FExitDerivedOwner`, `ObserveExitValue`, `MakeExitValue`, `ConsumeExitTemporaryAndTerminate`, `ConsumeExitValueByValue`, `BuildExitGlobalCall1..3`, `BuildExitGlobalNestedCall`, `BuildExitGlobalLoop`, and `RunDestructorExitRecovery`.

`RouteId` is `scenario_index + 1` (`LOCAL_BLOCK_END` = 1 … `ENGINE_SHUTDOWN_GLOBAL` = 37). `TokenBase` is `(nesting_index + 1) * 100`. Non-`ONE` nestings construct three units.

Owner construction follows the scenario family (`FExitValue`, nested outer/inner values, field/derived owners, temporaries, returned values, argument copies, references/aliases). Terminal routes call `ReachDestructorExitTerminal(RouteId)` and, for return-like scenarios, return `RouteId`. Control-transfer scenarios wrap the owner in `while`/`for`/`switch`. Fault scenarios emit `return 1 / Zero` (or `1 / Zero` on the argument-copy / temporary-exception path).

Nesting shapes:

- `ONE`: one terminal owner, then the entry tail.
- `SEQUENTIAL`: three sequential blocks; the last is terminal.
- `NESTED_SCOPES`: three nested blocks; the innermost is terminal.
- `NESTED_CALLS`: `EntryCallN` chain ending at `Entry()`.
- `LOOP`: `for (ShapeIndex = 1; ShapeIndex <= Count)` with a passive then terminal arm.
- `RECURSION`: `EntryRecursive(Depth)` with a depth-1 terminal.

`MODULE_DISCARD_GLOBAL` and `ENGINE_SHUTDOWN_GLOBAL` emit function-prefixed globals (`FExitReference` / field / loop / call helpers) plus `RecordDestructorExitGlobalReady(RouteId)`; the entry only checks that ready flag.

Observation does not change source text. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected` is `RouteId` for the 522 non-exception IDs. Fault IDs and unknown IDs return 0; that zero fallback is not membership proof.

Normal rows are `ReturnValue` + `RequiresHostSetup`. Fault rows are `RuntimeException` with exact text `Divide by zero` and no integer expectation. Host notes name native lifecycle helpers and `ReachDestructorExitTerminal`.
