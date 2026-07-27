## Context

Unlike stock configurations that can infer or use a generic fallback, this fork
expects a valid `asFunctionCaller`/automatic caller for supported non-generic
native calls. Object-last conventions add an object-position dimension, while
the VM and persistence layer must use the same operand and stack contract.

## Goals / Non-Goals

**Goals:**

- Execute supported object-last/native calls with correct object, argument,
  return, exception, and cleanup behavior.
- Reject missing/invalid caller payloads with the fork's stable diagnostic.
- Preserve calls across compatible bytecode save/load.

**Non-Goals:**

- Restore an upstream calling-convention backend that this fork intentionally
  disables.
- Change UE binding or RPC routing.
- Accept unsupported ABI/signature combinations.

## Decisions

1. Keep caller validation at registration/preparation boundaries and do not
   silently substitute a generic route.
2. Define one pointer-sized in-memory native function operand contract shared by
   compiler, context, and restore.
3. Test object placement with multiple scalar/value shapes and both free/object
   calls so a passing integer smoke test cannot hide ABI errors.
4. Assert cleanup after normal return, native exception, script exception, and
   context reuse.
5. Keep missing-caller rejection as an enabled current-fork negative test.

## Risks / Trade-offs

- **[Stack corruption]** Compiler/context disagreement can corrupt adjacent
  arguments. → Use sentinel arguments and exact result/order assertions.
- **[Unsupported ABI expansion]** Broad registration may imply more signatures
  than the caller supports. → enumerate supported signatures and keep
  unsupported forms negative.
- **[Persistence overlap]** Native-call pointer translation overlaps reference
  bytecode persistence. → this change owns call semantics; the linked
  persistence change owns generic stream identity mechanics.

## Migration Plan

1. Reconcile callfunc/compiler/context/restore hunks by call opcode.
2. Add failing sentinel, exception, cleanup, and save/load regressions.
3. Apply one coherent caller/stack repair.
4. Build once; run Embedding, Runtime, Module, and full SDK prefixes.
5. Roll back the entire object-last call hunk set on ABI or cleanup regression.

## Open Questions

- Finalize the supported signature table for object-last automatic callers.
