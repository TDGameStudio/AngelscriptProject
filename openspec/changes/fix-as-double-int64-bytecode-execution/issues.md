# Issue Record

| ID | State | Finding | Required closure |
| --- | --- | --- | --- |
| AS-CONVERT-001 | Closed | `dTOi64`/`dTOu64` used operand 0 as their source and advanced one word despite two-word `asBCTYPE_wW_rW_ARG` metadata. P091/P092 align interpreter dispatch with the current fork. Fresh Parameters `1/1`, Numeric `4/4`, canonical generated AOT `11/11`, complete SDK `674/674`, strict/planning/whitespace gates, and the standalone coherent `-NoXGE` build all pass; `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter` owns the exact generated path, while `BitCastAndNumericParity` remains the opposite 32-bit-integer-to-double helper direction. | Complete. Preserve P091/P092 as one rollback unit and do not expand the SDK result into NativeCore, whole-project full-suite, Disabled-test, obj-last, or counted-reference claims. |

The historical crash, isolated red bytecode, repair build, and later green
parameter owner remain supporting evidence. Fresh focused interpreter and
generated-AOT, complete-SDK, static-gate, and standalone-build evidence is
retained in `verification.md`. No issue remains open in this linked change.
