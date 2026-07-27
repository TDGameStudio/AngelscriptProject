## 1. Ownership and Existing Source

- [x] 1.1 <!-- Non-TDD --> Record P091/P092 as the complete production hunk set and exclude every `as_restore.cpp` hunk.
- [x] 1.2 <!-- Non-TDD --> Confirm both current interpreter handlers read operand 1 and advance two words without changing bytecode metadata or compiler emission.
- [x] 1.3 <!-- Non-TDD --> Preserve `FConstructorParameterTests::ParameterTypesByArityAndSelection` and `FNumericConversionTests::SourceTargetFormAndValue` as primary/breadth interpreter owners; record `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter` as the exact generated-code parity owner and retain `FAngelscriptStaticJITPrimitiveConversionTests::BitCastAndNumericParity` as the opposite helper direction.

## 2. Rollback Boundary

- [x] 2.1 <!-- Non-TDD --> Record P091/P092 and their signed/unsigned decoder assertions as one indivisible rollback unit.
- [x] 2.2 <!-- Non-TDD --> Exclude conversion policy, compiler emission, bytecode metadata, and save/load reader/writer behavior.

## 3. Fresh Verification

- [x] 3.1 <!-- Non-TDD --> Run the exact coherent build command in `verification.md` and record metadata, exit codes, warnings, and errors.
- [x] 3.2 <!-- Non-TDD --> Run the constructor-parameter owner and require the printed two-word conversion cells to complete without operand-word misdispatch.
- [x] 3.3 <!-- Non-TDD --> Run the numeric-conversion owner and require exact signed/unsigned source/target results.
- [x] 3.4 <!-- TDD --> Implement `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter` with parameterized fixture functions, interpreter opcode/no-JIT proof, loaded-AOT three-entry and entry-counter proof, exact signed/unsigned parity, complete source output, and explicit cleanup. The requested centralized build/AOT run remains task 3.5.
- [x] 3.5 <!-- Non-TDD --> Run the newly implemented exact StaticJIT generated-execution owner and record its generated-code artifact and parity separately from interpreter decoder evidence.
- [x] 3.6 <!-- Non-TDD --> Run the complete SDK prefix and record terminal totals, cleanup, shutdown, and crash/timeout state.
- [x] 3.7 <!-- Non-TDD --> Run strict OpenSpec validation plus scoped parent/plugin whitespace checks and append fresh outputs to `verification.md`.
