# Static Caller and Opcode Reconciliation

Status: source inspection complete; compile and execution evidence pending.

## Registration and preparation

- `as_callfunc.cpp::DetectCallingConvention` clears the complete system-function
  interface and stores the supplied caller.
- `CallSystemFunction` selects the bound automatic caller first, then generic,
  and otherwise emits the stable missing-caller exception.
- `PrepareSystemFunctionGeneric` records cleanup only for transferred owners.
  No-count implicit handles are now excluded; counted implicit handles retain
  cleanup. A normal no-count argument slot is discarded by VM stack retirement,
  while stale or malformed cleanup metadata is handled defensively without
  dispatching an absent release behavior.

## Compiler and bytecode

- `as_compiler.cpp::CompileFunctionCall` emits `asBC_CALLSYS` for system
  functions after calculating object, return-storage, and explicit argument
  stack size.
- `asCByteCode::Call` stores `CALLSYS` and `Thiscall1` as pointer-sized
  `asCScriptFunction*` operands; ordinary script/import/interface calls retain
  integer identities.
- `MoveArgsToStack` moves by-value object temporaries through `GETOBJ`.

## Interpreter and generated execution

- `as_context.cpp::CallFunctionCaller` reads the VM object slot first but appends
  it after every explicit argument for `ICC_CDECL_OBJLAST` and
  `ICC_CDECL_OBJLAST_RETURNINMEM`.
- `StaticJITHeader.cpp` mirrors the same rule.
- The AOT fixture now contains `ObjectLastNativeForAOT()`, whose generated entry
  constructs `FAotObjectLastProbe(39, 97)` and exposes the resulting value.

## Persistence

- Writer translation converts the pointer-sized `CALLSYS`/`Thiscall1` function
  operand to a stable used-function index.
- Reader translation resolves the serialized index against the destination
  engine and writes the validated destination `asCScriptFunction*`.
- The compatible save/load owner keeps source and destination engines alive
  concurrently, proves their registered function objects are distinct, and
  requires the restored call to observe the destination active engine.

## Static checks for the batch

- Every modified test registration remains within
  `WITH_ANGELSCRIPT_UNITTESTS`.
- Every new raw SDK script is wrapped by `ASTEST_AS_ANSI` or emitted by the
  existing generated-source helper.
- Every generated/raw SDK source is printed to Automation output.
- No build or UE test was run during this coherent source batch.
