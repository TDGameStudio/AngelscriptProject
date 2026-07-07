# AngelScriptSDK audit log

> Historical snapshot: this note reflects the 2026-06 audit state that existed while the helper and fixture refactor was being implemented. It is no longer the current inventory. For the current 2026-07-06 source counts, remaining gaps, and verification status, see `current-state-audit.md`.

## Why this note exists

This note records the follow-up review that happened after the CQTest fixture migration and the `Entry()`-pattern refactor. The immediate trigger was a user report that the documented goal and the actual test shape were drifting apart: the OpenSpec tasks still said that the `Entry()` pattern was not yet fully removed, while many newly added SDK cases were still using `Entry()`-style aggregate self-checks. The user also asked for the reasoning, the cause/effect chain, and the test inventory to be recorded in OpenSpec before any further code work continued.

This is therefore a decision log, not a design proposal from scratch. It captures what was observed, why the current boundary was chosen, and which parts are intentionally left as direct engine creation.

## Background

- The refactor started as a cleanup of `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`: remove duplicated helper code, collapse the `ASSDK` prefix to `SDK`, and modernize coverage.
- While reviewing that work, CQTest's class-level lifecycle hooks (`BEFORE_ALL()` / `AFTER_ALL()`) became the right place to store a raw engine fixture for ordinary test classes.
- A second thread emerged at the same time: behavioral SDK tests should stop using one aggregate `bool Entry()` that hides which behavior failed, and instead call specific named AS functions with typed arguments and typed returns.
- The test suite also contains a real mixture of test styles. Some files are ordinary behavioral tests, some are white-box parser/bytecode/reference tests, and some are lifecycle or configuration tests where per-method engine creation is the point of the test.

## What was audited

The directory was scanned at source level to answer three questions:

1. Which `AngelScriptSDK/*.cpp` files are ordinary CQTest behavioral tests and can share a class-level raw engine fixture?
2. Which files intentionally create a raw engine per method because the test is about engine lifecycle, stack limits, multi-engine save/load, or internal `asCScriptEngine` state?
3. Which test names or helper names still carry inconsistent acronym casing, especially `SDK` versus `Sdk`?

The audit counted:

- `64` `.cpp` files in the `AngelScriptSDK` directory;
- `63` of those are test files with `TEST_METHOD` definitions;
- `1` is a support file with no direct tests;
- `354` `TEST_METHOD` definitions at source level.

That source-level count is intentionally not the same as the runtime automation count. It is a file inventory used to reason about structure, not a claim about final execution totals.

## Why the CQTest fixture change matters

CQTest gives each `TEST_METHOD` a fresh test object, but `BEFORE_ALL()` / `AFTER_ALL()` are static and can hold shared class state through `inline static` members. That means a raw `asIScriptEngine*` can live once per test class while each method still gets its own per-test reset hook in `BEFORE_EACH()`.

That is the correct shape for the ordinary SDK behavior tests:

- the expensive raw engine is created once per class;
- `BEFORE_EACH()` clears adapter state, output buffers, and per-method scratch values;
- the test body stays focused on the behavior under test instead of setup churn.

The audit confirmed that this fixture shape is suitable for a large portion of the SDK suite, but not for everything.

## Why some direct engine creation remains intentional

The goal is not to eliminate every `asCreateScriptEngine` call. Some tests must keep direct creation because the test is specifically about the lifecycle or the isolated internal state of the engine.

The intentional direct-engine cases fall into these buckets:

- engine construction, property mutation, module enumeration, or garbage-collection behavior;
- stack limit or configuration mutation that must not bleed across methods;
- save/load tests that compare two engines or two different engine states;
- parser / bytecode / script-node / tokenizer white-box tests that operate below the `FAngelscriptEngine` wrapper;
- known fork boundaries that depend on isolated state and should not be normalized away.

One concrete example is the `TypedefBytecode` case in `AngelscriptSDKTypeTests.cpp`, which intentionally exercises save/load across two engines. Another is the runtime or reference tests that are validating a failure mode or a lifecycle transition, not a shared happy-path fixture.

## Naming guidance

The audit also exposed a naming-consistency point that should be preserved in future additions:

- keep helper and type names aligned with the existing `SDK` acronym style;
- avoid introducing new `Sdk`-cased helper names when the surrounding code already uses `FAngelscriptSDK*` and `SDKExecuteString`;
- do not churn legacy names that are already stable unless they are being touched for another reason.

This matters because the continuation work is not just about fixture shape. It is also about keeping the new shared helpers visually consistent with the rest of the directory so the next round of cleanup does not reintroduce avoidable style drift.

## Inventory appendix

### Behavioral and API-facing tests

- `AngelscriptAtomicTests.cpp` (4): `InitZero`, `SetGet`, `IncDec`, `ConcurrentIncDec`
- `AngelscriptBuilderTests.cpp` (5): `SingleModulePipeline`, `CompileErrors`, `RebuildModule`, `ImportBinding`, `MultiSectionBuild`
- `AngelscriptCallFuncTests.cpp` (9): `MultipleArgs`, `FloatPrecision`, `VoidSideEffect`, `NestedCall`, `ManyArgs`, `WideReturn`, `MixedIntDoubleArgs`, `BoolReturn`, `OutParams`
- `AngelscriptCallingConvTests.cpp` (3): `CDecl`, `Generic`, `Thiscall`
- `AngelscriptCompilerTests.cpp` (7): `BytecodeGeneration`, `BytecodeExecutionAndRetBoundary`, `VariableScopes`, `OutOfScopeUseRejected`, `FunctionCalls`, `TypeConversions`, `NegativeAndFloat64Matrix`
- `AngelscriptConfigGroupTests.cpp` (3): `BeginEnd`, `RemoveCleansTypes`, `NestedError`
- `AngelscriptContextPoolTests.cpp` (1): `ReuseAndResetPerEngine`
- `AngelscriptConversionTests.cpp` (5): `Numeric`, `ExplicitCast`, `ImplicitValueType`, `NumericBoundary`, `BoolConversion`
- `AngelscriptDataTypeTests.cpp` (5): `Primitives`, `Comparisons`, `HandleQualifierMatrix`, `ObjectHandles`, `SizeAndAlignment`
- `AngelscriptDebuggerValueTests.cpp` (3): `GetterPropertyTracking`, `FunctionEvaluationGuards`, `InheritedGetterTracksBasePropertyAddress`
- `AngelscriptDebugReificationTests.cpp` (1): `TypeMapAndFallback`
- `AngelscriptDefaultTraitTests.cpp` (1): `DefaultTraitModifiers`
- `AngelscriptEngineTests.cpp` (4): `Create`, `PropertyGetSet`, `ModuleEnumeration`, `GarbageCollectCycle`
- `AngelscriptExecuteTests.cpp` (5): `BasicCallback`, `OneArg`, `TwoArgs`, `FourArgs`, `FloatArgs`
- `AngelscriptFunctionCallerErasureTests.cpp` (1): `ConstRefQualifiedMethodCaller`
- `AngelscriptGCInternalTests.cpp` (7): `Statistics`, `EmptyCollect`, `InvalidLookup`, `ReportUndestroyedEmpty`, `ManualCycleCollection`, `CycleDetection`, `TwoNodeCycleCollection`
- `AngelscriptGlobalPropertyTests.cpp` (6): `ScriptReads`, `ScriptWrites`, `MultipleGlobals`, `ScalarReadModifyWrite`, `DoubleProperty`, `BoolProperty`
- `AngelscriptGlobalVarTests.cpp` (9): `Enumerate`, `ResetState`, `RemoveBeforeDiscard`, `InitializerExpression`, `ConstReadAccess`, `DeclarationString`, `DataLimit`, `CallLimit`, `ExceptionLocation`
- `AngelscriptMemoryTests.cpp` (5): `Construction`, `FreeUnused`, `ScriptNodeReuse`, `ByteInstructionReuse`, `PoolLeakTracking`
- `AngelscriptModuleTests.cpp` (6): `Create`, `Discard`, `Multi`, `MultiSection`, `EnumerateFunctions`, `RecompileAfterDiscard`
- `AngelscriptNativeCompileTests.cpp` (5): `SimpleFunction`, `MultipleFunctions`, `GlobalVariables`, `SyntaxError`, `ErrorMessage`
- `AngelscriptNativeExecutionAdvancedTests.cpp` (3): `FloatReturn`, `NegativeValue`, `MultipleReturnPaths`
- `AngelscriptNativeExecutionTests.cpp` (5): `VoidFunction`, `ReturnValue`, `OneArg`, `TwoArgs`, `ThreeArgs`
- `AngelscriptNativeRegistrationTests.cpp` (3): `GlobalFunction`, `GlobalProperty`, `SimpleValueType`
- `AngelscriptObjectTests.cpp` (3): `ValueType`, `ConstructorChain`, `NativeFloatWrapper`
- `AngelscriptOOPTests.cpp` (3): `InterfaceBridge`, `MixinNamespace`, `InheritedInterfaceMethod`
- `AngelscriptOutputBufferTests.cpp` (2): `ErrorCapture`, `WarningCapture`
- `AngelscriptParserTests.cpp` (5): `Declarations`, `ExpressionAst`, `ControlFlow`, `SyntaxErrors`, `ReuseAfterSyntaxError`
- `AngelscriptRestoreTests.cpp` (5): `RoundTrip`, `StripDebugInfoRoundTrip`, `EmptyStreamFails`, `TruncatedStreamFails`, `FailureLeavesModuleClean`
- `AngelscriptRuntimeTests.cpp` (6): `Context`, `Exception`, `Suspend`, `ExceptionDetails`, `ModuloByZero`, `ContextReuseAfterException`
- `AngelscriptSDKCompilerTests.cpp` (6): `Basic`, `Error`, `Config`, `MultipleErrors`, `TypeMismatch`, `RecompileAfterError`
- `AngelscriptSDKFunctionTests.cpp` (6): `OverloadDefault`, `RefArgument`, `ByRefMutation`, `ConstInRef`, `TypeBasedOverload`, `Recursion`
- `AngelscriptSDKOperatorTests.cpp` (11): `Arithmetic`, `Comparison`, `Logical`, `Bitwise`, `Assignment`, `Ternary`, `Pow`, `Call`, `Index`, `Precedence`, `ShortCircuit`
- `AngelscriptSDKTypeTests.cpp` (10): `Bool`, `Bits`, `Int8`, `Float`, `TypedefBytecode`, `Enum`, `Auto`, `IntegerWidths`, `IntegerOverflowWrap`, `EnumUnderlyingValues`
- `AngelscriptSmokeTest.cpp` (1): `Smoke`
- `AngelscriptStringUtilTests.cpp` (5): `ParseInt`, `ParseNegativeInt`, `ParseFloat`, `ParseZero`, `LargeValue` (currently disabled in source with `#if 0` and kept as a tracked prerequisite, not a runtime baseline)
- `AngelscriptStructCppOpsTests.cpp` (2): `NotBlueprintTypeByDefault`, `ValueClassUsesCppStructOps`
- `AngelscriptThreadTests.cpp` (3): `GetLocalDataNonNull`, `GetLocalDataStable`, `DifferentTLS`
- `AngelscriptTokenizerTests.cpp` (7): `BasicTokens`, `Keywords`, `CommentsAndStrings`, `ErrorRecovery`, `ErrorRecoveryAdvancesAndContinues`, `BasicLiteralAndPunctuationMatrix`, `UnterminatedBlockCommentAndEscapes`
- `AngelscriptTypeRegistryTests.cpp` (1): `AliasAndPropertyFinder`
- `AngelscriptTypeUsageTests.cpp` (5): `TypeUsageFromTypeIdScriptKinds`, `TypeUsageFromPropertyScriptMemberMatrix`, `DataTypeTypeUsageQualifiers`, `TypeUsageFromPropertyNativeQualifierMatrix`, `TypeUsageFromDataTypeQualifierAndContainerMatrix`
- `AngelscriptVariableScopeTests.cpp` (8): `Isolation`, `Shadowing`, `NestedBlocks`, `ForInitScope`, `ForInitLeakRejected`, `DeepShadowing`, `WhileAndIfBlockScope`, `IfBlockLeakRejected`

### Native parser / tokenizer / bytecode white-box tests

- `AngelscriptBytecodeTests.cpp` (4): `InstructionSequence`, `Append`, `JumpResolution`, `Output`
- `AngelscriptNativeBytecodeJumpsTests.cpp` (5): `ForwardJumpResolves`, `BackwardJumpResolves`, `MultipleLabelsResolveIndependently`, `JumpToUnresolvedLabelReturnsError`, `JumpAcrossAddedSequences`
- `AngelscriptNativeBytecodeOpcodesTests.cpp` (10): `Push_PshC4_PshV4_PshRPtr`, `Load_LoadObj_LoadThisR`, `Call_CALL_CALLSYS_CALLINTF`, `BranchOps_JZ_JNZ_JLowZ_JLowNZ`, `Misc_LINE_SUSPEND_JitEntry`, `RetVariants_RET_RetWithValue`, `MathOps_AddInt_SubInt_MulInt_Float`, `CompareOps_CMPi_CMPf`, `InstrSizeMatchesInfoTable`, `OpcodeCountsAcrossEachAsEBCType`
- `AngelscriptNativeBytecodeOptimizeTests.cpp` (8): `OptimizeReducesOrPreservesSize`, `OptimizeKeepsSemanticHeadAndTail`, `OutputBufferSizeMatchesGetSize`, `OutputBufferRoundTripStable`, `OutputAfterAppendIsContiguous`, `EmptyByteCodeGetSizeIsZero`, `LastInstrValueDwAfterMixedOps`, `GetLastInstrTypeAfterRet`
- `AngelscriptNativeParserDeclarationsTests.cpp` (18): `FunctionWithDefaultParam`, `FunctionWithInOutInoutRefs`, `ClassWithInheritance`, `ClassImplementsInterface`, `ClassFinalAbstract`, `MixinClassDeclaration`, `NamespaceDeclaration`, `NestedNamespace`, `EnumTypedAndUntyped`, `EnumScopedRequireEnumScope`, `TypedefDeclaration`, `FuncdefDeclaration`, `ImportFromDeclaration`, `PropertyAccessorGetSet`, `OperatorOverloadParse`, `GlobalConstDeclaration`, `ArrayTypeAndHandleType`, `TemplateInstantiationDeclaration`
- `AngelscriptNativeParserErrorsTests.cpp` (7): `MissingSemicolonRecovers`, `UnbalancedBracesError`, `UnclosedStringInDeclaration`, `BadOperatorSequenceError`, `BadParameterListError`, `ResetClearsErrorState`, `MultipleErrorsAccumulated`
- `AngelscriptNativeParserExpressionsTests.cpp` (10): `PrecedenceMulOverAdd`, `PrecedenceShiftOverAdd`, `RightAssocAssignment`, `TernaryNesting`, `CastExpression`, `MemberAccessChain`, `IndexExpression`, `FunctionCallWithNamedArg`, `AnonymousInitializerList`, `LambdaIfSupported_OrDocumentReject`
- `AngelscriptNativeScriptNodeCopyTests.cpp` (7): `CreateCopyPreservesNodeTypes`, `CreateCopyPreservesChildOrdering`, `CreateCopyPreservesSourceRange`, `CreateCopyDeepNestingNoStackBlow`, `SiblingTraversalVisitsAllNodes`, `EnumeratePerNodeTypeViaWalker`, `DisconnectAndReattachIfExposed`
- `AngelscriptNativeScriptNodeShapeTests.cpp` (13): `FunctionNodeChildrenLayout`, `ParameterListNodeShape`, `StatementBlockHoldsStatements`, `ReturnNodeHasOptionalExpression`, `BreakAndContinueAreLeafNodes`, `DoWhileShape`, `SwitchAndCaseShape`, `EnumNodeAndEnumValueChildren`, `InterfaceNodeShape`, `ImportNodeShape`, `FuncDefNodeShape`, `TypedefNodeShape`, `VirtualPropertyNodeShape`
- `AngelscriptNativeScriptNodeSourceRangeTests.cpp` (5): `LineColPropagatedToFunction`, `LineColPropagatedToClassMember`, `MultilineStatementSpansCorrectRange`, `CommentSkippedDoesNotShiftNextNodeLine`, `BomDoesNotPoisonFirstNodeColumn`
- `AngelscriptNativeTokenizerLiteralsTests.cpp` (20): `HexIntegerLiteral`, `HexUppercaseAndLowercase`, `OctalLiteralIfSupported_OrDocumentReject`, `BinaryLiteralIfSupported_OrDocumentReject`, `DecimalIntegerVarieties`, `Float64WithoutSuffix`, `Float32WithFSuffix`, `Float64WithDSuffix`, `FloatExponentPositive`, `FloatExponentNegative`, `FloatLeadingDot`, `FloatTrailingDot`, `StringEscape_NTRBackslashQuote`, `StringEscape_HexByte_xNN`, `StringEscape_Unicode_uNNNN`, `HeredocStringIfEnabled`, `CharLiteralBasic`, `CharLiteralEscape`, `EmptyStringLiteral`, `AdjacentStringConcatNotMerged`
- `AngelscriptNativeTokenizerOperatorsTests.cpp` (10): `ArithmeticOps_PlusMinusStarSlashPercent`, `BitwiseOps_AndOrXorNotShifts`, `ComparisonOps_EqNeLtLeGtGe`, `LogicalOps_AndOrNot`, `AssignmentOps_PlainAndCompound`, `IncrementDecrement`, `Ternary_Question_Colon`, `ScopeColonColonAndDot`, `HandleOpAt`, `LongestMatchPrefersShiftRAOverShiftR`
- `AngelscriptNativeTokenizerWhitespaceTests.cpp` (10): `LineCommentEmpty`, `BlockCommentNested_DocumentBehavior`, `UnterminatedBlockCommentReachesEOF`, `MixedCRLFWhitespace`, `BomAtStartOfSource`, `IdentifierLeadingUnderscore`, `IdentifierWithDigits`, `KeywordVsIdentifierBoundary`, `ZeroLengthInputReturnsEnd`, `PastEofGracefulHandling`
- `AngelscriptParserTests.cpp` (5): `Declarations`, `ExpressionAst`, `ControlFlow`, `SyntaxErrors`, `ReuseAfterSyntaxError`
- `AngelscriptScriptNodeTests.cpp` (3): `Types`, `Traversal`, `Copy`
- `AngelscriptTokenizerTests.cpp` (7): `BasicTokens`, `Keywords`, `CommentsAndStrings`, `ErrorRecovery`, `ErrorRecoveryAdvancesAndContinues`, `BasicLiteralAndPunctuationMatrix`, `UnterminatedBlockCommentAndEscapes`

### Reference, save/load, and lifecycle boundary tests

- `AngelscriptNativeReferenceCompilerRejectTests.cpp` (5): `InvalidConstObjectAssignmentReportsTypeMismatch`, `OutOfScopeLocalReferenceReportsIdentifier`, `UnknownFunctionCallReportsMissingSymbol`, `ReturnObjectFromIntFunctionIsRejected`, `LongIdentifierAssignmentReportsDiagnosticWithoutCrash`
- `AngelscriptNativeReferenceContextTests.cpp` (2): `ContextCanBeReusedAfterDeepStackException`, `ContextCanSwitchSignaturesAfterException`
- `AngelscriptNativeReferenceParserErrorTests.cpp` (5): `UnfinishedClassReportsMissingBrace`, `CapitalConstInParameterIsRejected`, `UnclosedNamespaceReportsEndOfFile`, `BadParameterListAccumulatesSyntaxError`, `MultipleMalformedDeclarationsReportMultipleErrors`
- `AngelscriptNativeReferenceSaveLoadTests.cpp` (4): `RoundTripPreservesFunctionDeclarations`, `StripDebugInfoReportsStrippedFlag`, `TruncatedStreamFailsThenCompleteStreamStillLoads`, `MultipleFunctionsRemainResolvableAfterLoad`
- `AngelscriptNativeReferenceScriptClassTests.cpp` (8): `ConstructorMetadataAndIsolatedExecutionException`, `ConstructorArgumentsAreRejectedForValueStyleConstruction`, `InheritanceMetadataAndIsolatedExecutionException`, `PrivateConstructorBlocksDerivedSuperCall`, `ProtectedConstructorAllowsDerivedSuperCall`, `BaseWithoutDefaultConstructorGetsAutoGeneratedDefaultConstructor`, `MemberInitializationExpressionReportsMissingSymbol`, `DeletedDefaultConstructorIsRejectedOrDocumented`
- `AngelscriptNativeReferenceTokenizerTests.cpp` (4): `LongIdentifierBoundaryFromReference`, `LongIdentifierFollowedByAssignmentTokenizesInOrder`, `UnrecognizedTokenDoesNotPoisonFollowingIdentifier`, `UnterminatedStringReportsDedicatedToken`
- `AngelscriptRestoreTests.cpp` (5): `RoundTrip`, `StripDebugInfoRoundTrip`, `EmptyStreamFails`, `TruncatedStreamFails`, `FailureLeavesModuleClean`

### Support file

- `AngelscriptStructCppOpsTestTypes.cpp` (0): support-only file, no `TEST_METHOD` definitions

## Continuation rule

When the next refactor step continues, the default assumption should be:

1. ordinary CQTest behavior files use one class-level raw engine fixture;
2. method-level `BEFORE_EACH()` resets are for per-test state only;
3. direct engine creation stays only where the test intent requires it;
4. naming should remain `SDK`, not `Sdk`, for any new helper or type introduced into this area.

That is the real boundary the audit established.
