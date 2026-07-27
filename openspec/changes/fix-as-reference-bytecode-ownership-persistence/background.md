# Background Addendum: GETOBJ Persistence and StaticJIT Reader Access

## Correct operand-family classification

The current fork defines GETOBJ-style instructions with
`asBCTYPE_W_rW_ARG`. The first word is a value/destination operand and the
second is a reference/stack offset. The interpreter and StaticJIT consume
`GETOBJ(offset, variableOffset)`, and the compiler's valid transfer source
prints `VAR 6; GETOBJ 0,6; CALL`.

This format is distinct from lowercase-leading `asBCTYPE_wW_rW_ARG`, already
used by `dTOi64`/`dTOu64`. Therefore P138/P142/P150/P151 are GETOBJ/reference
persistence repairs, not numeric-conversion work. P149 corrects the adjacent
GETOBJ operand-format comment and documents the exact invariant.

## Supporting hunk inventory

| Hunk | File / current anchor | Responsibility |
| --- | --- | --- |
| P022 | `StaticJIT/PrecompiledData.h:179` | Export existing `FAngelscriptPrecompiledFunction::Process` so the Test DLL calls the production reader. |
| P138 | `as_restore.cpp:3049` | Read `asBCTYPE_W_rW_ARG`. |
| P142 | `as_restore.cpp:3668-3671` | Adjust only operand 1 while translating restored stack positions. |
| P149 | `as_restore.cpp:5778` | Document GETOBJ as the two-operand format. |
| P150 | `as_restore.cpp:5864-5867` | Apply writer-side adjustment to operand 1. |
| P151 | `as_restore.cpp:5970` | Serialize both format words. |

## Exact regression owner

`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptPrecompiledDataArchiveTests.cpp`
publishes
`FAngelscriptPrecompiledDataArchiveTests::ReferenceCopyTypeOperandsRemapAcrossPrecompiledLoad`
under the full path
`Angelscript.TestModule.StaticJIT.PrecompiledData.FAngelscriptPrecompiledDataArchiveTests.ReferenceCopyTypeOperandsRemapAcrossPrecompiledLoad`.

Its first direct-reader link failed with LNK2019 for `Process`; P022 enabled the
test to invoke the real reader. The intended red then proved reference-copy
type operands were not remapped; the subsequent focused report passed 1/1 and
the PrecompiledData parent passed 4/4. These are retained historical artifacts.
Fresh final linked verification remains pending.

## Rollback boundary

P022/P138/P142/P149/P150/P151, the exact production-reader regression, and any
fixture delta caused only by these contracts roll back together. Removing the
export alone breaks the test link; retaining only reader or writer handling
creates an asymmetric stream contract.

## Successful-GC discarded-module retirement

The retained reference-copy function owner produced a new behavioral red after
its bytecode and native object lifecycle assertions had passed. In raw mode the
registered fixture TypeInfo began at internal reference count `3`, rose to `11`
while the function was retained, and remained `11` after the module disappeared
from name lookup and the function's final external `Release()` returned zero.
The application object itself was fully balanced, so this was not a missing
native release.

Source comparison isolates the cause. The current fork's public
`asCScriptEngine::GarbageCollect()` returns directly after object GC, while the
pinned 2.38 implementation calls `DeleteDiscardedModules()` when the collection
returns zero. P166 selectively restores that branch. The regression now calls
the public full-cycle GC after final function release and requires the exact
TypeInfo baseline plus continued absent module lookup. A nonzero GC result
still performs no module retirement.

This integration hunk belongs to reference ownership because it is the final
release boundary for the retained function/type operands. It does not claim to
fix the separately recorded engine-shutdown ordering or Module user-data
cleanup defect.
