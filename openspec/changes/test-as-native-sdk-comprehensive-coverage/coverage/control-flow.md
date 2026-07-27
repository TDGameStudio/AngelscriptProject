# Conditional, Loop, Switch, and Jump Statements

## Dimensions

| Axis | Values |
| --- | --- |
| Statement | `if`, `if/else`, else-if chain, `while`, `do while`, classic `for`, `switch`, nested block, `break`, `continue`, `return`, fork `fallthrough` |
| Iteration/branch count | zero, one, two, representative many, configured/infinite-loop boundary |
| Nesting | none, same-kind nested, mixed loop, loop+switch, branch+loop, three-level target selection |
| Condition type | bool literal, variable, comparison, logical expression, side-effecting call, overloaded/current legal conversion, invalid type |
| Transfer | none, break nearest loop, break switch, continue nearest loop, early return, nested return, fallthrough, exception |
| Initialization/lifetime | init before condition, body local, increment expression, switch local/case, destructor on transfer |
| Switch selector | signed/unsigned integer widths, enum, legal alias, boundary value, unsupported type |
| Case shape | match first/middle/last, default, no match, fallthrough, grouped cases, duplicate, non-constant, missing break/fallthrough behavior |

## Required products

- `Loop form(while/do/for) × iteration count(0/1/many) × transfer(none/break/continue/return)` with exact body/condition/increment counters.
- `Nesting shape × transfer × intended target level` proves nearest-owner behavior and outer continuation.
- `Scope shape × nesting depth × local count × exit path` proves every initialized local is destroyed exactly once on normal, break, continue, return, and exception exits.
- `Condition source × short-circuit/side effect × branch result` for if and loops.
- `Switch selector type × case position/default/no-match × fallthrough mode` for every supported selector category.
- `Exit path × live local count/type` proves destructor order for break, continue, return, and exception.
- `For clause presence(init/condition/increment omitted or present)` covers every legal omission combination and invalid forms.
- `Unreachable/invalid statement × owning context` covers break/continue outside loop, case/default outside switch, duplicate default/case, invalid return, and malformed delimiters.

## Bytecode correlation

Representative cells inspect forward/backward targets, switch branches, loop back edges, break/continue targets, and line markers, then execute the same functions. Optimization must preserve the observable result and valid targets.

## Planned ownership

- `Language/ControlFlow/AngelscriptNativeConditionalTests.cpp`
- `Language/ControlFlow/AngelscriptNativeWhileLoopTests.cpp`
- `Language/ControlFlow/AngelscriptNativeDoWhileLoopTests.cpp`
- `Language/ControlFlow/AngelscriptNativeForLoopTests.cpp`
- `Language/ControlFlow/AngelscriptNativeSwitchTests.cpp`
- `Language/ControlFlow/AngelscriptNativeNestedJumpTests.cpp`
- `Language/ControlFlow/AngelscriptNativeControlFlowLifetimeTests.cpp`
- `Language/ControlFlow/AngelscriptNativeControlFlowFailureTests.cpp`
- `Language/ControlFlow/AngelscriptNativeLoopDepthTests.cpp`
- `Language/ControlFlow/AngelscriptNativeForClauseTests.cpp`
- `Language/ControlFlow/AngelscriptNativeNestedTargetTests.cpp`
- `Language/ControlFlow/AngelscriptNativeControlFlowLifetimeDepthTests.cpp`
- `Language/ControlFlow/AngelscriptNativeTransferValidityTests.cpp`
- `Language/ControlFlow/AngelscriptNativeSwitchPlacementTests.cpp`
- `Language/ControlFlow/AngelscriptNativeLoopConditionTransferDepthTests.cpp`
- `Language/ControlFlow/AngelscriptNativeBranchConditionDepthTests.cpp`
- `Compiler` owns correlated bytecode internals.
