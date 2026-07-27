## Context

This fork's `asBC_dTOi64` and `asBC_dTOu64` metadata uses
`asBCTYPE_wW_rW_ARG`: destination and source stack offsets occupy two encoded
words. The compiler and StaticJIT already consume both operands. Before P091
and P092, the interpreter used `asBC_SWORDARG0` as both destination and source
and incremented `l_bc` by one.

The isolated red trace printed
`dTOi64 0x000e0095 0x0000000c`. After the handler consumed only the first word,
dispatch resumed on `0x0000000c`, eventually reaching an unrelated instruction
and invalid memory access. This is an interpreter decoder defect, not imported
call behavior and not stream persistence.

## Goals / Non-Goals

**Goals:**

- Read the double source from operand 1 for signed and unsigned conversions.
- Advance past both encoded words.
- Preserve exact result, execution status, bytecode shape, recovery, and
  cleanup evidence.
- Keep signed/unsigned handlers and their regressions in one rollback boundary.
- Add real generated-code StaticJIT execution for representative signed and
  unsigned double-to-64-bit conversions and compare it with interpreter
  results before parity closes.

**Non-Goals:**

- Change conversion rounding/truncation policy.
- Change compiler emission or bytecode metadata.
- Modify `as_restore.cpp` reader/writer logic.
- Claim that a StaticJIT parity pass alone proves interpreter dispatch.

## Decisions

1. Align the two interpreter handlers with current-fork metadata, compiler
   emission, and StaticJIT operand use. Importing an upstream one-operand
   handler was rejected because this fork deliberately retains the two-operand
   form.
2. Own only P091/P092. `asBCTYPE_wW_rW_ARG` was already serialized and
   translated; the nearby missing `asBCTYPE_W_rW_ARG` cases belong to
   GETOBJ/reference persistence.
3. Keep the constructor-parameter owner as the primary reproducer because it
   preserved the exact crash-producing bytecode. Use the numeric-conversion
   owner for signed/unsigned source/target breadth.
4. Do not treat
   `FAngelscriptStaticJITPrimitiveConversionTests::BitCastAndNumericParity` as
   a double-to-64-bit parity owner. Its template calls convert signed/unsigned
   32-bit integers to `double` directly and the test does not execute generated
   StaticJIT code.
5. Use
   `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter` as
   the exact secondary parity owner. It runs isolated interpreter and loaded
   AOT engines sequentially with exact inputs `-4294967296.75` and
   `4294967296.75`, requires the interpreter opcodes and absence of all JIT
   entries, then requires all three generated entry forms, entry counter `1`,
   exact results `-4294967296` and `4294967296`, cross-mode equality, and
   explicit context/module cleanup.
6. Extend the existing `ASStaticJITAotFixture` and cache semantic registry
   instead of creating another AOT package. Regenerate the matched header/cache
   pair only through the canonical AOT workflow; never hand-edit generated
   output.
7. Keep `LANG-CONV-NUMERIC` and its generated-source registry row as the
   interpreter breadth product. The new owner is outside `AngelScriptSDK` and
   its source comes from the deterministic AOT fixture, so it is registered in
   `TestCatalog.md` under the established AOT prefix rather than being falsely
   assigned to the Native SDK-only coverage-product registry.

## Risks / Trade-offs

- **[Half repair]** Fixing only signed or unsigned dispatch leaves identical
  layout risk in the other handler. → Keep P091/P092 indivisible.
- **[Instruction-pointer drift]** Correct source selection with the old
  increment still dispatches the operand word. → Assert both source offset and
  two-word advancement through execution/recovery.
- **[Incorrect persistence expansion]** Grouping `W_rW_ARG` restore hunks here
  would conflate distinct formats. → Explicitly exclude `as_restore.cpp`.

## Migration Plan

1. Preserve P091/P092 and the named interpreter regressions.
2. Run one coherent build.
3. Run exact constructor-parameter and numeric-conversion owners.
4. Preserve the implemented generated-code StaticJIT double-to-int64/uint64
   parity owner and regenerate its matched AOT artifacts.
5. Run that exact parity owner and the complete SDK prefix.
6. Record terminal reports, source/bytecode/generated-code visibility, exit
   codes, recovery,
   cleanup, shutdown, and crash/timeout state.

Rollback P091/P092 and their signed/unsigned decoder assertions together. No
serialized-stream rollback is part of this change.

## Open Questions

No design question remains. The exact StaticJIT generated-execution owner is
implemented; fresh focused interpreter execution and the canonical
regenerate/generated-build/AOT workflow pass, the complete SDK prefix passes
`674/674`, final strict/planning/whitespace gates pass, and the standalone
coherent `-NoXGE` build succeeds with terminal `0/0` exit metadata. The linked
change is complete.
