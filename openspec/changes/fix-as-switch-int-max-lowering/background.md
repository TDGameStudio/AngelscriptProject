# Background

## Current-fork defect

`CompileSwitchStatement()` sorts labels, groups sufficiently close values, and
emits dense-table entries by walking from the first case to `maxRange`.
Historically these operations used signed `int` throughout:

- P066 widens the prior-case-plus-five gap comparison;
- P067 widens the maximum-range-plus-five comparison;
- P068 widens the dense-table induction variable;
- P069 compares the case value with that widened variable.

The failure was semantic rather than diagnostic. Source with a matching
`2147483643` selector/label compiled, but overflow in the grouping arithmetic
excluded the first case and produced an unconditional default path. A dense
loop ending at `2147483647` also risked increment wrap.

## Existing regression owner

`FSwitchTests::SelectorsByCaseAndExit` is published under
`Angelscript.TestModule.AngelScriptSDK.Language.ControlFlow.Switch` and owns
`LANG-CF-SWITCH`. Its generated high-end controls execute:

- `2147483642` (`INT_MAX - 5`);
- `2147483643` (`INT_MAX - 4`, the original trigger);
- dense labels `2147483645`, `2147483646`, and `2147483647`.

Historical evidence is preserved as `LANG-CF-005`/`LANG-CF-006`: the red report
is
`Saved/Tests/as-native-sdk-controlflow-repair5-rerun/20260724_132425_735_9aed04c4/Report/index.json`;
the repair report is
`Saved/Tests/as-native-sdk-controlflow-boundary-overflow-fix/20260724_140643_788_7d78de49/Report/index.json`
with ControlFlow 4/4.

## Hunk ownership

| Hunk | Current anchor | Exact responsibility |
| --- | --- | --- |
| P066 | `as_compiler.cpp:5143-5146` | Prevent overflow in the neighboring-case gap comparison. |
| P067 | `as_compiler.cpp:5167` | Prevent overflow in the maximum-range heuristic. |
| P068 | `as_compiler.cpp:5201-5203` | Prevent dense-table loop-counter wrap. |
| P069 | `as_compiler.cpp:5205` | Compare the current case against the widened loop value. |

All four hunks form one rollback boundary.
