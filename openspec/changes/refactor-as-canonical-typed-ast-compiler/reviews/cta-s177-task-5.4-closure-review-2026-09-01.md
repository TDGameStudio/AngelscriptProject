# CTA-S177 / Task 5.4 closure review — 2026-09-01

## Review result

**APPROVE. Task 5.4 is complete on plugin commit `01c4158`.** The final
subagent reviews report no blocker and no major finding after the discovered
scalar-reference alias bug and two test-precision gaps were corrected. Formal
progress becomes **109/136 = 80.1%**, with **27** task rows open. The practical
engineering estimate is **about 83% (±4%)**; product-default readiness remains
lower because CANONICAL is still opt-in and the cutover/final matrices are open.

## Code review outcome

The CodeGen-focused reviewer originally found one major correctness issue in
the index compound-assignment rewrite. An RHS such as `int&` was wrapped in an
`OpaqueValue` before scalar decay, so the first Sequence phase captured its
address. If receiver evaluation changed that storage, the later arithmetic saw
the new value even though the observable call trace still looked RHS-first.

The valid oracle is:

```angelscript
MutateAndReturn()[0] += GetSharedRhs();
```

`GetSharedRhs()` returns a reference to `10`; `MutateAndReturn()` changes that
same storage to `20`; the indexed sink starts at `1`. The authentic RED produced
`21`. Both index-compound paths now decay a primitive/enum scalar reference to
an rvalue before creating the RHS Opaque. The GREEN result is `11` with exact
trace `8,9,2`, proving the value was read and frozen before the receiver and
that RHS/receiver/index each execute once.

The final re-review verified:

- overloaded `opIndex` and raw Index fallback use the same decay-before-Opaque
  rule;
- the explicit five-phase Sequence is RHS value, receiver, index/reference,
  updated value, write;
- reference Opaque capture remains address-based only where the type is still a
  non-handle reference;
- the test runs the same oracle through independent LEGACY and CANONICAL
  Engines;
- no remaining evaluation-order, Opaque dominance, reference lifetime or
  write-through blocker/major was found.

## Test review outcome

The test-focused reviewer originally found two coverage weaknesses:

1. Three rejected LEGACY property-unary forms shared one failing module, so an
   early failure could mask accidental acceptance of another form.
2. Bool/reference Conditional tests checked selected payload but did not trace
   each reference arm, so eager evaluation of both addresses could escape
   detection.

The final fixtures now:

- build temporary prefix, temporary postfix and local postfix in three
  independently created modules;
- require each module's own negative `BuildResult`, expected diagnostic,
  missing `Entry()` and empty runtime trace;
- reset collected diagnostics before each build;
- give the two Conditional reference arms distinct markers `8` and `9` and
  require exact trace `8` or `9`, plus the expected bool/reference payload.

The test re-review returned APPROVE with no blocker/major. Its final diagnostic
accumulation minor was corrected before the last Build and Semantics run.

## Verification reviewed

| Gate | Result |
|---|---:|
| final production/review Build | PASS |
| Semantics | **15/15 PASS** |
| SemaAuthority | **538/538 PASS** |
| ProductionCodeGen | **230/230 PASS** |
| Frontend CanonicalAST | **189/189 PASS** |
| Build after final test-isolation minor | PASS |
| Semantics after final test-isolation minor | **15/15 PASS** |

The complete report paths and RED/GREEN lineage are in
`attachments/canonical-sequencing-single-evaluation-closure-gate-2026-09-01.md`.
Cache V2/V12 was not run and is not represented as evidence: the user-approved
scope defers that prototype's refactor/testing, and Task 5.4 does not depend on
it.

## Acceptance boundary

The closure is for valid currently supported source forms. It deliberately
does not claim LEGACY parity for property-accessor unary forms that LEGACY
rejects, nor for assignment-as-expression that the current parser rejects.
Those negative boundaries have independent tests and are not disguised as
green execution evidence.

Task 5.4 closure does not close:

- 5.5/5.6 structured statement/control targets and phase closure;
- 5.7/5.8 complete lifetime umbrellas;
- 5.9 advanced language/generated lifecycle coverage;
- 13.2 full Sema authority;
- 7.x/9.x backend and install consumers;
- 10.x product-default cutover/LEGACY isolation;
- 12.x/13.12 final focused and All regression.

## Final recommendation

Keep 5.4 checked and move the active semantic critical path to Task 5.5. Reopen
5.4 only for a concrete valid-source sequencing or single-evaluation
counterexample, not because a separately owned control/lifetime/backend/cutover
umbrella remains unfinished.
