## Why

The interpreter handled `asBC_dTOi64` and `asBC_dTOu64` as one-word
instructions even though this fork defines them with the two-word
`asBCTYPE_wW_rW_ARG` layout. It read the destination offset as the source,
advanced onto the operand word, and could execute later operand bits as an
opcode, producing wrong values or an access violation.

## What Changes

- Own production hunks P091 and P092 and no `as_restore.cpp` hunk.
- Decode the double source from operand 1 and advance the instruction pointer
  by two words for signed and unsigned 64-bit conversions.
- Preserve constructor-parameter and direct numeric-conversion regressions,
  which are interpreter owners.
- Add
  `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter` as
  the exact generated-code StaticJIT double-to-int64/uint64 parity owner.
- Require fresh linked build, focused conversion/constructor execution, real
  generated StaticJIT parity, and aggregate SDK evidence.

## Capabilities

### New Capabilities

- `as-double-int64-bytecode-execution`: Defines interpreter decoding and
  execution for double-to-signed/unsigned-64-bit conversion bytecodes.

### Modified Capabilities

None.

## Impact

- Production: P091-P092 only in
  `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp`,
  `asCContext::ExecuteNext()`, current lines 3451-3462.
- Primary regression:
  `FConstructorParameterTests::ParameterTypesByArityAndSelection`,
  `LANG-CTOR-PARAM-SELECT`.
- Breadth regression:
  `FNumericConversionTests::SourceTargetFormAndValue`,
  `LANG-CONV-NUMERIC`.
- StaticJIT parity:
  `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter`
  executes representative signed and unsigned conversions first without JIT,
  then through loaded generated entries, and owns opcode, entry-counter,
  exact-result, parity, and cleanup assertions.
- Rejected parity owner:
  `FAngelscriptStaticJITPrimitiveConversionTests::BitCastAndNumericParity`
  directly exercises the opposite `int`/`asDWORD`-to-`double` helper direction
  and does not execute generated code.
- No bytecode metadata, writer/reader, compiler emission, or stream-format
  change.
