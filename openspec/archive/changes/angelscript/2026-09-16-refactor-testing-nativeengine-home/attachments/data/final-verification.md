# Final matrix and Review resolution

Captured 2026-09-15T14:07:08.380084+08:00 for task 4.1.

## Proving run

Shared `ue.test` `Angelscript.UnitTest.NativeEngine` Fast TimeoutMs 600000 after editor rebuild `68a8c1cab9974acf838f3963ff3048f4` (`-NoUBTMakefiles`).

| Field | Value |
|---|---|
| Harness runId | `3716f78c9f164d84975160af22aea8da` |
| UE RunId | `b99a111c19a2478a9f15027ae270f89f` |
| Report | `Saved/Harness/Unreal/Runs/b99a111c19a2478a9f15027ae270f89f/AutomationReport/index.json` |
| Outcome | Passed, complete |
| Counts | 1239 Total, 1239 Success, 0 Fail, 0 NotRun, 0 InProcess |

Phase-1 freeze was 1206 NativeEngine identities. The +33 are Parser (5) plus 3.x matrix methods on SourceExecution and Sema. Relocated identities remain; no retired flat `NativeEngine.<Class>` names.

## Task-to-case map on that binary

Parser prefix `b8426d6bd67648718fccd1dc28383897` (5/5) and the shared NativeEngine run both include:

- `NativeEngine.Parser.ParserContracts.ValidDeclarationCollectsFunctionG`
- `NativeEngine.Parser.ParserPrecedence.AddRootHasMultiplyOnTheRight`
- `NativeEngine.Parser.ParserPrecedence.ParenthesizedAddHasMultiplyRoot`
- `NativeEngine.Parser.ParserRecovery.IncompleteEofIsDistinctFromMidSourceBadToken`
- `NativeEngine.Parser.ParserRecovery.MalformedFKeepsFollowingG`

3.2–3.6 new identities on the shared run include:

- Numeric/effects: `VMSourceNumeric.RuntimeIntSevenAndThreeArithmetic`, `RuntimeFloatSevenPointFiveAndTwo`, `RuntimeIntDivideByZeroIsException`, `RuntimeMinInt32DivNegOneOverflows`, `RuntimeSignedAddWrapsAtInt32`, `RuntimeDoubleDivideByZeroIsException`
- Compounds/shifts: `VMSourceExpressions.RuntimeCompoundAssignChainFromTwelve`, `RuntimeInRangeShiftsKeepFixedWidthBits`; Sema `BodiesLanguageForms.CompoundAssignsAnalyzeWithoutPublication`, `InRangeShiftsAnalyzeWithoutPublication`, `IntPlusBoolRejectsWithoutBody`, `ConstAndNonLvalueAssignmentReject`, `FloatBitwiseRejects`
- Control: `VMSourceControlFlow.RuntimeN4LoopsSumZeroToThree`, `RuntimeCommaKeepsLeftToRightLastValue`, `RuntimeEarlyReturnSkipsLaterMark`; Sema `BodiesControlFlow.BreakOutsideLoopOrSwitchRejects`, `ContinueOutsideLoopRejects`, `DuplicateCaseRejects`
- Calls: `VMSourceCalls.RuntimePickDefaultSecondIsThirtyTwo`, `RuntimeQualifiedNamespaceCallIsSeven`, `ReturnTypeOnlyOverloadsPublishNoImage`
- Objects/storage: `VMSourceObjects.NestedOwnedObjectsConstructOuterThenInner`, `ReferenceWriteBackChangesCallerStorage`, `InheritedOverrideDispatchReturnsFour`, `MutableModuleGlobalRejectsPublication`
- Conversions: `VMSourceNumeric.RuntimeIntWidensToDoubleSeven`; Sema `BodiesLanguageForms.UnrelatedObjectCastRejects`

Existing-proven overlap (not deleted): `SourceCombineNamedAndDefaultIsThirtyFour`, `SourceOverloadsReturnDistinctMarkers`, `SourceLazyAndOrTernarySkipSideEffects`, `SourceValueFieldWriteThenRead`, `SourceReverseDestroyOnReturn`, `FloatCompareAssignAndNonIntCast`, `UnsupportedBodyPublishesNoPartialImage`, Syntax/Lambda retired forms, `GlobalDefinitions` mutable reject, `IntegralConstants.LogicalAndArithmeticRightShiftKeepMaintainedASMeanings`.

## Owning-phase dispositions recorded during 3.x

- Comma expressions are not a `ParseExpression` binary operator. CF.COMMA executes as for-increment comma lists plus multi-declarators (`IncrementList` → 73, `MultiDecl` → 31).
- Compound-assign spellings analyze in Sema; bytecode emission does not lower `AddAssign` and friends. Visible values 15/13/52/26/1 use expanded `A = A + n` updates.
- Source `<<`/`>>`/`>>>` analyze in Sema and emit `UnsupportedLowering`. In-range bit patterns remain `IntegralConstants` plus VM `BSLL`/`BSRL` opcodes.
- Inherited `B.F(3)` / `B.F()` execute (4 and 0). `A@` virtual `CALLINTF` stays on existing VM dispatch tests; source handle-to-base was not required to publish an image.

These are product contracts already present in the frontend/emitter, not weakened oracles.

## Adjacent tenants

Reran on the same final editor binary as NativeEngine `b99a111c19a2478a9f15027ae270f89f` (`68a8c1cab9974acf838f3963ff3048f4`):

| Prefix | RunId | Result |
|---|---|---|
| `Angelscript.UnitTest.Framework` | `326eb1630f35454793f00093eb52fed8` | 45 Success |
| `Angelscript.UnitTest.Baseline` | `08e46230316447039cc70fd84fb6dbe2` | 3 passed (2 Success + 1 SuccessWithWarnings; LogMetaSound tag noise on `LegacySuiteExcludedByDefault`) |
| `Angelscript.UnitTest.Bindings` | `02a35de7a01943c5a969ce2756da33b1` | 2 Success |

`Test-Phase1MigrationConservation.ps1` exit 0 (NativeEngine 1206 mapped + later 3.x additions; Framework 45; Baseline 3; RuntimeBindings 312; Bindings 2). Whole `Angelscript.UnitTest` and RuntimeBindings success remain blocked by the pre-existing `Array.AppendRemoveAndIterationYieldTwoThenFive` bind-materialization crash.

## Review

Open user Review `attachments/reviews/review-20260915-122143-nativeengine-home-design-inline.md` is re-reviewed against snapshot `Saved/Harness/Reviews/review-20260915-140708-nativeengine-home-rereview`. F01–F03 resolution conditions hold. Coordinator closes the Review `APPROVE`.

## Intentionally omitted

- Full `Angelscript.UnitTest` — pre-existing RuntimeBindings crash; not a gate after replan-20260915-133321.
- RuntimeBindings execution success — conservation-only.
- `workflow-evaluation.md` / `RequireTerminal` — archive gate only; 4.1 does not archive.
- Knowledge promotion — K1–K3 remain `candidate`.
- Production frontend/VM repairs, foreach productization, TestCode rewrite, unified-framework, archive/commit/push.

## Naming assumed

`ParserContracts`, `ParserRecovery`, `ParserPrecedence`, `BuilderStages`, `CompoundAssignsAnalyzeWithoutPublication`, `InRangeShiftsAnalyzeWithoutPublication`, and the `Runtime*` SourceExecution methods follow adjacent CQTest class/method convention.
