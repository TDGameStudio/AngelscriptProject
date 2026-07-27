## Why

Reference-oriented bytecode in the 2.33-based fork can carry object-type or
native-function operands whose ownership and serialized representation are not
handled consistently. The comprehensive native SDK tests exposed lifetime and
save/load paths where stale or under-referenced operands can survive compilation
or be restored incorrectly.

## What Changes

- Make reference-copy and related object-type bytecodes participate in function
  reference acquisition and release.
- Keep object-type/function operands valid through local optimization, module
  reference updates, execution, bytecode save, and bytecode restore.
- Serialize native-call pointers as stable function identities and restore them
  only after validation.
- Serialize and restore the current-fork two-operand
  `GETOBJ(offset, variableOffset)` contract through an explicit
  `asBCTYPE_W_rW_ARG` reader/writer path that adjusts only the reference offset.
- Export `FAngelscriptPrecompiledFunction::Process` narrowly so the existing
  AngelscriptTest regression invokes the production precompiled reader across
  the Runtime/Test DLL boundary.
- Add focused raw SDK regressions for retained-function lifetime, module
  discard, save/load, exact execution, and teardown.

## Capabilities

### New Capabilities

- `as-reference-bytecode-persistence`: Defines ownership and persistence
  requirements for reference/object/native-function operands in script
  bytecode.

### Modified Capabilities

None.

## Impact

- Vendored runtime: `as_bytecode.cpp`, reference-related compiler/context
  opcodes, `as_module.cpp`, `as_scriptfunction.cpp`, and bytecode translation in
  `as_restore.cpp`.
- Supporting StaticJIT integration: P022 in `StaticJIT/PrecompiledData.h` and
  P138/P142/P149/P150/P151 in `as_restore.cpp`; these six hunks are part of the
  same reference-persistence rollback boundary.
- Tests: AngelScriptSDK Reference, Compiler bytecode, Runtime, and Module
  save/load owners, plus
  `FAngelscriptPrecompiledDataArchiveTests::ReferenceCopyTypeOperandsRemapAcrossPrecompiledLoad`.
- Serialized bytecode compatibility requires explicit validation and a recorded
  stream-version decision; public embedding APIs are not intentionally changed.
- The `Process` export changes symbol visibility only; signature, layout,
  behavior, and archive format remain unchanged.
- Related coverage record:
  `test-as-native-sdk-comprehensive-coverage/runtime-change-map.md`.
