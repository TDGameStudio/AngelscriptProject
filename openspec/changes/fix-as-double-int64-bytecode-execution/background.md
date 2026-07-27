# Background

## Current-fork defect

The bytecode metadata declares `dTOi64` and `dTOu64` with
`asBCTYPE_wW_rW_ARG`. Lowercase `wW` distinguishes this existing two-word
numeric format from uppercase `W_rW_ARG`, which is used by GETOBJ/reference
instructions.

Before repair, both interpreter cases:

- used operand 0 for destination and source;
- advanced one word rather than two.

The primary diagnostic printed
`dTOi64 0x000e0095 0x0000000c` and confirmed an instruction size of two. The
next dispatch interpreted the source-offset word as an opcode, eventually
causing invalid memory access. P091 and P092 now read `SWORDARG1(l_bc)` and
advance `l_bc += 2`.

## Existing interpreter owners and StaticJIT gap

| Role | File / owner | Exact evidence |
| --- | --- | --- |
| Primary reproducer | `Language/Constructors/AngelscriptNativeConstructorParameterTests.cpp`, `FConstructorParameterTests::ParameterTypesByArityAndSelection` | `LANG-CTOR-PARAM-SELECT` retains the float64 explicit-conversion cells and printed two-word bytecode. |
| Signed/unsigned breadth | `Language/Conversions/AngelscriptNativeNumericConversionTests.cpp`, `FNumericConversionTests::SourceTargetFormAndValue` | `LANG-CONV-NUMERIC` covers source/target/form/value combinations. |
| Rejected parity owner | `StaticJIT/AngelscriptStaticJITPrimitiveConversionTests.cpp`, `FAngelscriptStaticJITPrimitiveConversionTests::BitCastAndNumericParity` | Calls `ConvertPrimitiveValue<double, int>(-1)` and `ConvertPrimitiveValue<double, asDWORD>(0xFFFFFFFFu)`, proving 32-bit integer-to-double helper behavior. It neither converts double to `int64`/`uint64` nor executes generated StaticJIT code. |
| Generated parity owner | `StaticJIT/AngelscriptStaticJITAotTests.cpp`, `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter` | Prints the complete shared fixture, requires interpreter `asBC_dTOi64`/`asBC_dTOu64` bytecode with no JIT pointers, then requires all three loaded-AOT entries, one generated-entry hit per function, exact signed/unsigned values, interpreter parity, and module/context cleanup. The canonical regenerate/build/AOT workflow passes `11/11`; `verification.md` retains the exact artifacts. |

Historical red evidence is
`Saved/Tests/as-native-sdk-constructor-parameter-bytecode-isolation-fix15b/20260723_224516_460_b31de318/`.
The repair build is
`Saved/Build/as-native-sdk-float64-int64-bytecode-fix16/20260723_224913_762_81aa18d5/UBT.log`.
The later parameter contract report is
`Saved/Tests/as-native-sdk-constructor-parameter-semantics-fix16f-rerun/20260723_231304_386_bf59758c/Report/index.json`.
Fresh focused evidence is
`Saved/Tests/fix-as-double-int64-bytecode-execution-parameters/20260727_203151_605_0fd20e0c/Report/index.json`
(`1/1`) and
`Saved/Tests/fix-as-double-int64-bytecode-execution-conversions/20260727_203229_950_2e0e4480/Report/index.json`
(`4/4`). The generated parity report is
`Saved/Tests/fix-as-double-int64-bytecode-execution_04_tests/20260727_202944_840_d76cfee4/Report/index.json`
(`11/11`).

## Hunk ownership

| Hunk | Current anchor | Exact responsibility |
| --- | --- | --- |
| P091 | `as_context.cpp:3451-3452` | Decode signed conversion source from operand 1 and advance two words. |
| P092 | `as_context.cpp:3461-3462` | Decode unsigned conversion source from operand 1 and advance two words. |

No `as_restore.cpp` hunk belongs to this change.
