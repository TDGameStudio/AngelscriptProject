## Why

`FAngelscriptBytecode::GetInstrDebugString()` retained its synthetic operand
separator when an instruction rendered no operands. StaticJIT generation then
emitted trailing horizontal whitespace in AOT debug comments, making generated
artifacts unstable under source-format checks even though execution was
unchanged.

## What Changes

- Own production hunk P019 and no other production hunk.
- Normalize the final instruction debug string after opcode/operand rendering.
- Preserve the existing generated-output regression owner and literal
  trailing-whitespace check.
- Keep source, regression, and rollback evidence together while fresh linked
  build/AOT verification remains pending.

## Capabilities

### New Capabilities

- `as-static-jit-debug-text-format`: Defines deterministic whitespace behavior
  for StaticJIT instruction debug text and generated AOT comments.

### Modified Capabilities

None.

## Impact

- Production: P019 only,
  `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptBytecodes.cpp`,
  `FAngelscriptBytecode::GetInstrDebugString()`, current line 6743.
- Regression:
  `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITAotTests.cpp`,
  `FAngelscriptStaticJITAotTests::GeneratedOutputVerify`.
- Generated evidence: `ASStaticJITAotFixture.as.jit.hpp` and the documented AOT
  generation/build/automation sequence.
- No VM execution, opcode layout, serialization, public API, or consumer-facing
  diagnostics contract changes.
