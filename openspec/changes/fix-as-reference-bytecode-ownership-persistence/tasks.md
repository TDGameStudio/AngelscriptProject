## 1. Hunk and Contract Reconciliation

- [x] 1.1 Map every affected opcode and production hunk across compiler, bytecode, context, module, function ownership, and restore code; the current 164-hunk reconciliation assigns P022/P138/P142/P149/P150/P151 here explicitly.
- [x] 1.2 Record the stream magic/version compatibility decision and rollback boundary: current fork writes magic `0xE3` plus version `2`, rejects unframed/version-1 streams before payload interpretation, and treats framing plus pointer/index translation as one rollback unit.
- [x] 1.3 Record the exact `GETOBJ(offset, variableOffset)` / `asBCTYPE_W_rW_ARG` contract, narrow `Process` export, and six-hunk supporting rollback boundary.

## 2. Focused Regression Coverage

- [x] 2.1 Add retained-function and module-discard ownership regressions for raw `REFCPY` and optimized `RefCpyV` type operands, final external-function release, successful-GC retirement, exact TypeInfo baseline restoration, and absent module lookup.
- [x] 2.2 Add save/load equivalence and malformed-stream rejection regressions for the changed type/reference and stack-position formats. `MOD-BYTECODE-STREAM-RESTORE` covers framed primitive/current-format success, version-1, empty, truncated, atomic cleanup, retry, deterministic `CopyScript` bytes, and the current shared-`$obj` restriction; the precompiled owner covers reference-copy type remapping.
- [x] 2.3 Assert exact declarations, source/restored runtime values, bytecode/type metadata, symmetric reference cleanup, empty failed destinations, retry cleanup, and independent-engine isolation across the retained-function, Module restore, and precompiled remap owners.
- [x] 2.4 Preserve the existing
  `FAngelscriptPrecompiledDataArchiveTests::ReferenceCopyTypeOperandsRemapAcrossPrecompiledLoad`
  owner, which calls production `Process`, checks serialized/source/destination
  type identity, and executes the restored result.

## 3. Runtime Repair

- [x] 3.1 Make `REFCPY`/`RefCpyV` TypeInfo acquisition and release symmetric in script-function ownership and preserve final baseline restoration.
- [x] 3.2 Correct pointer/index translation for all version-2 script-object type operands and adjust only operand 1 for current-fork `asBCTYPE_W_rW_ARG`.
- [x] 3.3 Reconcile module reference updates, typed `FREE`, `REFCPY`/`RefCpyV` optimizer rewrites, interpreter execution, StaticJIT emission, and stream translation with the same operand contract.
- [x] 3.4 Preserve the present P022/P138/P142/P149/P150/P151 source batch without
  introducing runtime or test edits in this record-only session.

## 4. Verification

- [x] 4.1 Run static opcode/ownership reconciliation before building.
- [x] 4.2 Build the coherent runtime/test batch once and batch compile repairs.
- [x] 4.3 Run focused Reference, Compiler, Runtime, Module, and full SDK prefixes; record crashes, duration, cleanup, and report paths.
- [x] 4.4 Run
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.PrecompiledData.FAngelscriptPrecompiledDataArchiveTests.ReferenceCopyTypeOperandsRemapAcrossPrecompiledLoad" -Label fix-as-reference-bytecode-precompiled-remap-final -TimeoutMs 600000`
  after the coherent build and append fresh report/exit/shutdown evidence to
  `verification.md`.
