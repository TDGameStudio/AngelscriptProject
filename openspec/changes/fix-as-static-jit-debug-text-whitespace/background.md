# Background

## Current-fork defect

P019 is the single-line addition of `Out.TrimEndInline()` at current
`AngelscriptBytecodes.cpp:6743`, immediately before
`GetInstrDebugString()` returns. The opcode formatter creates a separating
space before it knows whether any operand text will be appended. No-operand
instructions therefore leaked that internal formatting detail into generated
AOT comments.

This is deterministic output hygiene, not a VM correctness defect. The source
line must not be grouped with reference-copy, script-object lifecycle, or
calling-convention changes in the same file.

## Existing regression owner

`FAngelscriptStaticJITAotTests::GeneratedOutputVerify` is published under
`Angelscript.TestModule.StaticJIT.AOT.GeneratedOutputVerify`. The comprehensive
verification record also preserves the completed `JIT-004` workflow:

- baseline build;
- commandlet generation;
- generated-code build;
- AOT automation 10/10;
- zero literal trailing-whitespace lines in
  `ASStaticJITAotFixture.as.jit.hpp`.

Those artifacts establish why the source exists. They do not replace a fresh
final run owned and recorded by this linked change.

## Hunk ownership

| Hunk | File / anchor | Exact responsibility |
| --- | --- | --- |
| P019 | `StaticJIT/AngelscriptBytecodes.cpp:6743`, `GetInstrDebugString()` | Remove terminal horizontal whitespace after complete opcode/operand rendering. |

No other production hunk is in this rollback boundary.
