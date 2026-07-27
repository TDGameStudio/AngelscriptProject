## Context

This fork stores some bytecode operands as pointers during execution while the
serialized stream must use stable indices. Reference-copy instructions also
embed type operands that must contribute to the owning function's references.
The repair spans emission, optimization, module reference updates, function
ownership, execution, and persistence, so file-level ownership is insufficient.

## Goals / Non-Goals

**Goals:**

- Keep every embedded type/function operand alive for the executable function's
  lifetime.
- Translate pointer operands to validated stream identities and back without
  truncation or stale-address reuse.
- Preserve current-fork runtime results before and after save/load.
- Reject malformed or incompatible bytecode deterministically.

**Non-Goals:**

- Redesign the VM instruction set.
- Provide compatibility with arbitrary upstream or future bytecode streams.
- Test AngelScript add-ons or UE integration.

## Decisions

1. Treat ownership by opcode operand meaning, not by the historical opcode
   shortlist. Reference-copy opcodes with object-type pointers join
   `AddReferences`/`ReleaseReferences`.
2. Keep runtime native-call operands pointer-sized; serialize stable function
   indices and restore only after resolving them through the destination
   engine/module.
3. Give each adjusted stack-position operand format an explicit reader/writer
   path. Do not rely on a similar instruction's layout.
   For `asBCTYPE_W_rW_ARG`, serialize both words but adjust only operand 1: the
   first value operand is not a stack position. This is the current-fork
   `GETOBJ(offset, variableOffset)` contract used by GETOBJ/GETOBJREF/GETREF;
   it is not the lowercase-leading `asBCTYPE_wW_rW_ARG` numeric conversion
   layout.
4. Export `FAngelscriptPrecompiledFunction::Process` at its existing declaration
   rather than duplicating archive-reader logic in the test module. The export
   is the minimum module boundary needed by the exact production-reader
   regression and does not create a new public consumer contract.
5. Require both retained-function and released-predecessor workflows. One proves
   ownership; the other proves cleanup and absence of stale references.
6. Correlate internal bytecode assertions with public build/execute/save/load
   results.

## Risks / Trade-offs

- **[Stream incompatibility]** A representation change can misread old data. →
  The fork now writes magic `0xE3` and version `2` before the payload, rejects
  every unframed or non-version-2 stream before `ReadInner()`, resets the
  destination on failure, and retains legacy/empty/truncated/retry tests.
- **[Reference leak]** Adding ownership without symmetric release leaks types. →
  Audit opcode symmetry and assert teardown baselines.
- **[Pointer truncation]** Treating a pointer operand as a 32-bit ID corrupts
  64-bit builds. → Use pointer-sized accessors in memory and indices only in the
  stream.
- **[Overlapping context hunks]** Calling-convention cleanup also touches
  `as_context.cpp`. → Assign each hunk by opcode contract in the shared runtime
  change map.
- **[Operand corruption]** Adjusting both `W_rW_ARG` words would treat the value
  operand as a stack offset. → Reader/writer branches adjust only operand 1 and
  the focused regression checks source/target type remap plus execution.
- **[Unnecessary export growth]** Test access could widen more StaticJIT
  internals. → Export only the existing `Process` member required by the named
  regression.

## Migration Plan

1. Reconcile all relevant changed hunks and opcode formats.
2. Add focused failing ownership/save-load tests.
3. Apply symmetric runtime/stream changes.
4. Build once after the coherent batch, then run Reference, Compiler, Runtime,
   Module, and full SDK prefixes.
5. Roll back the complete reference-persistence hunk set together if stream or
   teardown regression appears. P022/P138/P142/P149/P150/P151 and
   `ReferenceCopyTypeOperandsRemapAcrossPrecompiledLoad` are inseparable: do not
   keep the export without its production-reader regression or keep only one
   side of the GETOBJ reader/writer contract.

## Compatibility decision

- Version 2 is the only accepted current-fork bytecode stream. Version 1 is
  intentionally rejected because some script-object type operands could be
  process-local addresses and cannot be safely reinterpreted as stable
  destination indices.
- This is a deliberate fork-format break, not compatibility with arbitrary
  upstream or older fork streams. A producer and consumer must both use the
  current version-2 reader/writer pair.
- Rollback is indivisible: remove the two-byte framing, version-2 type-operand
  translation, and all dependent reader/writer changes together. Keeping a
  version-2 header without its complete pointer/index translation, or accepting
  version 1 through the new reader, is invalid.
- Native-call pointer operands remain covered by
  `fix-as-object-last-native-calling-convention`; reference/type operands and
  `asBCTYPE_W_rW_ARG` stack adjustment remain owned here.
