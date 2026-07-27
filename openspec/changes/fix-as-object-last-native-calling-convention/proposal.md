## Why

This fork requires explicit native caller payloads, and object-last/system-call
paths must agree on where the object and arguments live across registration,
compiler emission, VM dispatch, cleanup, and bytecode persistence. Inconsistent
handling causes incorrect calls, stack corruption, or save/load failures.

## What Changes

- Normalize detection and preparation of generic/system interfaces carrying the
  fork's native caller.
- Emit and execute object-last/native call bytecodes with one pointer-sized
  function/caller and stack layout contract.
- Clean arguments and return objects consistently after success and failure.
- Persist native-call function identities without serializing process pointers.
- Add positive and negative calling-convention regressions, including the fork's
  required-caller diagnostic.

## Capabilities

### New Capabilities

- `as-object-last-native-call`: Defines registration, execution, cleanup, and
  persistence behavior for object-last and related native system calls.

### Modified Capabilities

None.

## Impact

- Vendored runtime: `as_callfunc.cpp/.h`, relevant compiler call emission,
  `as_context.cpp` dispatch/cleanup, and native-call restore translation.
- Tests: Embedding calling conventions/object registration, Runtime invocation,
  and Module save/load.
- The fork's missing-caller rejection remains intentional and enabled.
- Related coverage record:
  `test-as-native-sdk-comprehensive-coverage/runtime-change-map.md`.
