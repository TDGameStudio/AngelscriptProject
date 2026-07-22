param(
	[string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..\..')).Path
)

$ErrorActionPreference = 'Stop'

$SdkRoot = Join-Path $RepositoryRoot 'Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK'
$OutputPath = Join-Path $PSScriptRoot '..\test-methods.csv'
$LegacyTableWord = 'M' + 'atrix'

$DefaultDestination = @{
	'AngelscriptAtomicTests.cpp' = 'AngelScriptSDK/Engine/AngelscriptNativeAtomicTests.cpp'
	'AngelscriptBuilderAppInterfaceTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderApplicationTests.cpp'
	'AngelscriptBuilderBytecodeTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderBytecodeTests.cpp'
	'AngelscriptBuilderDeclarationTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderDeclarationTests.cpp'
	'AngelscriptBuilderDependencyTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderDependencyTests.cpp'
	'AngelscriptBuilderDiagnosticsTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderDiagnosticTests.cpp'
	'AngelscriptBuilderEditorOnlyTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderEditorOnlyTests.cpp'
	'AngelscriptBuilderGlobalVariableTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderGlobalTests.cpp'
	'AngelscriptBuilderLayoutTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderLayoutTests.cpp'
	'AngelscriptBuilderLifecycleTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderLifecycleTests.cpp'
	'AngelscriptBuilderTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderFunctionTests.cpp'
	'AngelscriptBytecodeTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeByteInstructionTests.cpp'
	'AngelscriptCallFuncTests.cpp' = 'AngelScriptSDK/Embedding/AngelscriptNativeCallFunctionTests.cpp'
	'AngelscriptCallingConvTests.cpp' = 'AngelScriptSDK/Embedding/AngelscriptNativeCallingConventionTests.cpp'
	'AngelscriptCompilerTests.cpp' = 'Compiler/AngelscriptCompilerModulePipelineTests.cpp'
	'AngelscriptConfigGroupTests.cpp' = 'AngelScriptSDK/TypeSystem/AngelscriptNativeConfigGroupTests.cpp'
	'AngelscriptContextPoolTests.cpp' = 'Core/AngelscriptContextPoolTests.cpp'
	'AngelscriptConversionTests.cpp' = 'AngelScriptSDK/Language/AngelscriptNativeConversionsTests.cpp'
	'AngelscriptDataTypeTests.cpp' = 'AngelScriptSDK/TypeSystem/AngelscriptNativeDataTypeTests.cpp'
	'AngelscriptDebuggerValueTests.cpp' = 'Debugger/AngelscriptDebuggerValueTests.cpp'
	'AngelscriptDebugReificationTests.cpp' = 'Debugger/AngelscriptDebugReificationTests.cpp'
	'AngelscriptDefaultTraitTests.cpp' = 'AngelScriptSDK/TypeSystem/AngelscriptNativeDefaultTraitTests.cpp'
	'AngelscriptEngineTests.cpp' = 'AngelScriptSDK/Engine/AngelscriptNativeEngineLifecycleTests.cpp'
	'AngelscriptExecuteTests.cpp' = 'AngelScriptSDK/Runtime/AngelscriptNativeContextInvocationTests.cpp'
	'AngelscriptFunctionCallerErasureTests.cpp' = 'Core/AngelscriptFunctionCallerErasureTests.cpp'
	'AngelscriptGCInternalTests.cpp' = 'AngelScriptSDK/Runtime/AngelscriptNativeGarbageCollectorTests.cpp'
	'AngelscriptGlobalPropertyTests.cpp' = 'AngelScriptSDK/TypeSystem/AngelscriptNativeGlobalPropertyTests.cpp'
	'AngelscriptGlobalVarTests.cpp' = 'AngelScriptSDK/Language/AngelscriptNativeVariablesTests.cpp'
	'AngelscriptMemoryTests.cpp' = 'AngelScriptSDK/Engine/AngelscriptNativeMemoryTests.cpp'
	'AngelscriptNativeBytecodeJumpsTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBytecodeJumpTests.cpp'
	'AngelscriptNativeBytecodeOpcodesTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBytecodeOpcodeTests.cpp'
	'AngelscriptNativeBytecodeOptimizeTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeBytecodeOptimizationTests.cpp'
	'AngelscriptNativeCompileTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeCompilerCoreTests.cpp'
	'AngelscriptNativeExecutionAdvancedTests.cpp' = 'AngelScriptSDK/Runtime/AngelscriptNativeContextReturnValueTests.cpp'
	'AngelscriptNativeExecutionTests.cpp' = 'AngelScriptSDK/Runtime/AngelscriptNativeContextInvocationTests.cpp'
	'AngelscriptNativeParserDeclarationsTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeParserDeclarationsTests.cpp'
	'AngelscriptNativeParserErrorsTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeParserErrorsTests.cpp'
	'AngelscriptNativeParserExpressionsTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeParserExpressionsTests.cpp'
	'AngelscriptNativeReferenceCompilerRejectTests.cpp' = 'AngelScriptSDK/Conformance/AngelscriptNativeReferenceSemanticsTests.cpp'
	'AngelscriptNativeReferenceContextTests.cpp' = 'AngelScriptSDK/Runtime/AngelscriptNativeContextExceptionTests.cpp'
	'AngelscriptNativeReferenceParserErrorTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeParserErrorsTests.cpp'
	'AngelscriptNativeReferenceSaveLoadTests.cpp' = 'AngelScriptSDK/Module/AngelscriptNativeModuleSaveLoadTests.cpp'
	'AngelscriptNativeReferenceScriptClassTests.cpp' = 'AngelScriptSDK/Language/AngelscriptNativeConstructorsTests.cpp'
	'AngelscriptNativeReferenceTokenizerTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeTokenizerCoreTests.cpp'
	'AngelscriptNativeRegistrationTests.cpp' = 'AngelScriptSDK/Embedding/AngelscriptNativeRegistrationTests.cpp'
	'AngelscriptNativeScriptNodeCopyTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeScriptNodeCopyTests.cpp'
	'AngelscriptNativeScriptNodeShapeTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeScriptNodeShapeTests.cpp'
	'AngelscriptNativeScriptNodeSourceRangeTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeScriptNodeSourceRangeTests.cpp'
	'AngelscriptNativeSmokeTest.cpp' = 'AngelScriptSDK/Engine/AngelscriptNativeEngineSmokeTests.cpp'
	'AngelscriptNativeTokenizerLiteralsTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeTokenizerLiteralsTests.cpp'
	'AngelscriptNativeTokenizerOperatorsTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeTokenizerOperatorsTests.cpp'
	'AngelscriptNativeTokenizerWhitespaceTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeTokenizerWhitespaceTests.cpp'
	'AngelscriptObjectTests.cpp' = 'AngelScriptSDK/Runtime/AngelscriptNativeScriptObjectTests.cpp'
	'AngelscriptOOPTests.cpp' = 'AngelScriptSDK/Conformance/AngelscriptNativeInterfaceSemanticsTests.cpp'
	'AngelscriptOutputBufferTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeOutputBufferTests.cpp'
	'AngelscriptParserTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeParserCoreTests.cpp'
	'AngelscriptRestoreTests.cpp' = 'AngelScriptSDK/Module/AngelscriptNativeRestorePrimitiveTests.cpp'
	'AngelscriptRuntimeTests.cpp' = 'AngelScriptSDK/Runtime/AngelscriptNativeContextControlTests.cpp'
	'AngelscriptScriptModuleImportTests.cpp' = 'AngelScriptSDK/Module/AngelscriptNativeModuleImportTests.cpp'
	'AngelscriptScriptModuleNamespaceTests.cpp' = 'AngelScriptSDK/Module/AngelscriptNativeModuleNamespaceTests.cpp'
	'AngelscriptScriptModuleSectionDiagnosticsTests.cpp' = 'AngelScriptSDK/Module/AngelscriptNativeModuleSectionTests.cpp'
	'AngelscriptScriptModuleTests.cpp' = 'AngelScriptSDK/Module/AngelscriptNativeModuleLifecycleTests.cpp'
	'AngelscriptScriptNodeTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeScriptNodeCoreTests.cpp'
	'AngelscriptSDKCompilerTests.cpp' = 'AngelScriptSDK/Compiler/AngelscriptNativeCompilerCoreTests.cpp'
	'AngelscriptSDKFunctionTests.cpp' = 'AngelScriptSDK/Language/AngelscriptNativeFunctionsTests.cpp'
	'AngelscriptSDKOperatorTests.cpp' = 'AngelScriptSDK/Language/AngelscriptNativeOperatorsTests.cpp'
	'AngelscriptSDKTypeTests.cpp' = 'AngelScriptSDK/TypeSystem/AngelscriptNativePrimitiveTypeTests.cpp'
	'AngelscriptSmokeTest.cpp' = 'AngelScriptSDK/Engine/AngelscriptNativeEngineSmokeTests.cpp'
	'AngelscriptStringUtilTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeStringUtilityTests.cpp'
	'AngelscriptStructCppOpsTests.cpp' = 'Generator/ASStruct/AngelscriptStructCppOpsTests.cpp'
	'AngelscriptThreadTests.cpp' = 'AngelScriptSDK/Engine/AngelscriptNativeThreadingTests.cpp'
	'AngelscriptTokenizerTests.cpp' = 'AngelScriptSDK/Frontend/AngelscriptNativeTokenizerCoreTests.cpp'
	'AngelscriptTypeRegistryTests.cpp' = 'Core/AngelscriptTypeRegistryTests.cpp'
	'AngelscriptTypeUsageTests.cpp' = 'Core/AngelscriptTypeUsageTests.cpp'
	'AngelscriptVariableScopeTests.cpp' = 'AngelScriptSDK/TypeSystem/AngelscriptNativeVariableScopeTests.cpp'
}

$MethodDestination = @{
	'AngelscriptBuilderTests.cpp|ParseScriptsCreatesParserNodes' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderParsingTests.cpp'
	'AngelscriptBuilderTests.cpp|GenerateTypesRegistersDeclarations' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderTypeTests.cpp'
	'AngelscriptBuilderTests.cpp|LayoutAndCompileProduceExecutableBytecode' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderLayoutTests.cpp'
	'AngelscriptBuilderTests.cpp|StageFailureStopsBeforeExecutableCode' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderLifecycleTests.cpp'
	'AngelscriptBuilderTests.cpp|CrossSectionDependenciesCompileAndKeepSections' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderDependencyTests.cpp'
	'AngelscriptBuilderTests.cpp|NamespaceResolutionSeparatesTypesFunctionsAndGlobals' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderNamespaceTests.cpp'
	'AngelscriptBuilderTests.cpp|ClassInheritanceResolvesBaseTypesAndInheritedCalls' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderTypeTests.cpp'
	'AngelscriptBuilderTests.cpp|ScriptInterfaceDeclarationFailsWithoutLeakingState' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderTypeTests.cpp'
	'AngelscriptBuilderTests.cpp|DuplicateDeclarationsFailWithoutLeakingModuleState' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderTypeTests.cpp'
	'AngelscriptBuilderTests.cpp|PropertyInitializersAndMethodOverloadsCompile' = 'AngelScriptSDK/Compiler/AngelscriptNativeBuilderPropertyTests.cpp'
	'AngelscriptBytecodeTests.cpp|CompiledFunctionExposesExecutableBytecode' = 'AngelScriptSDK/Compiler/AngelscriptNativeBytecodeGenerationTests.cpp'
	'AngelscriptBytecodeTests.cpp|CompiledControlFlowProducesBranchOpcode' = 'AngelScriptSDK/Compiler/AngelscriptNativeBytecodeGenerationTests.cpp'
	'AngelscriptBytecodeTests.cpp|CompiledLoopProducesBackwardJump' = 'AngelScriptSDK/Compiler/AngelscriptNativeBytecodeGenerationTests.cpp'
	'AngelscriptBytecodeTests.cpp|CompiledArithmeticBytecodeDiffersFromConstantReturn' = 'AngelScriptSDK/Compiler/AngelscriptNativeBytecodeGenerationTests.cpp'
	'AngelscriptGlobalVarTests.cpp|Enumerate' = 'AngelScriptSDK/Module/AngelscriptNativeModuleGlobalTests.cpp'
	'AngelscriptGlobalVarTests.cpp|ResetState' = 'AngelScriptSDK/Module/AngelscriptNativeModuleGlobalTests.cpp'
	'AngelscriptGlobalVarTests.cpp|RemoveBeforeDiscard' = 'AngelScriptSDK/Module/AngelscriptNativeModuleGlobalTests.cpp'
	'AngelscriptGlobalVarTests.cpp|DataLimit' = 'AngelScriptSDK/Conformance/AngelscriptNativeGlobalSemanticsTests.cpp'
	'AngelscriptGlobalVarTests.cpp|CallLimit' = 'AngelScriptSDK/Conformance/AngelscriptNativeGlobalSemanticsTests.cpp'
	'AngelscriptGlobalVarTests.cpp|ExceptionLocation' = 'AngelScriptSDK/Runtime/AngelscriptNativeContextExceptionTests.cpp'
	'AngelscriptNativeCompileTests.cpp|SyntaxError' = 'AngelScriptSDK/Compiler/AngelscriptNativeCompilerDiagnosticTests.cpp'
	'AngelscriptNativeCompileTests.cpp|ErrorMessage' = 'AngelScriptSDK/Compiler/AngelscriptNativeCompilerDiagnosticTests.cpp'
	'AngelscriptNativeParserExpressionsTests.cpp|LambdaIfSupported_OrDocumentReject' = 'AngelScriptSDK/Frontend/AngelscriptNativeParserExpressionsTests.cpp'
	'AngelscriptNativeReferenceCompilerRejectTests.cpp|InvalidConstObjectAssignmentReportsTypeMismatch' = 'AngelScriptSDK/Language/AngelscriptNativeConversionsTests.cpp'
	'AngelscriptNativeReferenceCompilerRejectTests.cpp|OutOfScopeLocalReferenceReportsIdentifier' = 'AngelScriptSDK/Language/AngelscriptNativeReferencesTests.cpp'
	'AngelscriptNativeReferenceCompilerRejectTests.cpp|UnknownFunctionCallReportsMissingSymbol' = 'AngelScriptSDK/Language/AngelscriptNativeFunctionsTests.cpp'
	'AngelscriptNativeReferenceCompilerRejectTests.cpp|ReturnObjectFromIntFunctionIsRejected' = 'AngelScriptSDK/Language/AngelscriptNativeConversionsTests.cpp'
	'AngelscriptNativeReferenceCompilerRejectTests.cpp|LongIdentifierAssignmentReportsDiagnosticWithoutCrash' = 'AngelScriptSDK/Language/AngelscriptNativeDeclarationsTests.cpp'
	'AngelscriptNativeReferenceScriptClassTests.cpp|InheritanceMetadataAndIsolatedExecutionException' = 'AngelScriptSDK/Language/AngelscriptNativeInheritanceTests.cpp'
	'AngelscriptNativeReferenceScriptClassTests.cpp|MemberInitializationExpressionReportsMissingSymbol' = 'AngelScriptSDK/Conformance/AngelscriptNativeMemberInitialization238Tests.cpp'
	'AngelscriptNativeReferenceTokenizerTests.cpp|UnrecognizedTokenDoesNotPoisonFollowingIdentifier' = 'AngelScriptSDK/Frontend/AngelscriptNativeTokenizerErrorTests.cpp'
	'AngelscriptNativeReferenceTokenizerTests.cpp|UnterminatedStringReportsDedicatedToken' = 'AngelScriptSDK/Frontend/AngelscriptNativeTokenizerErrorTests.cpp'
	'AngelscriptNativeRegistrationTests.cpp|GlobalProperty' = 'AngelScriptSDK/Embedding/AngelscriptNativeGlobalRegistrationTests.cpp'
	'AngelscriptNativeRegistrationTests.cpp|GlobalFunction' = 'AngelScriptSDK/Embedding/AngelscriptNativeGlobalRegistrationTests.cpp'
	'AngelscriptNativeRegistrationTests.cpp|SimpleValueType' = 'AngelScriptSDK/Embedding/AngelscriptNativeObjectRegistrationTests.cpp'
	'AngelscriptObjectTests.cpp|ConstructorChain' = 'AngelScriptSDK/Language/AngelscriptNativeConstructorsTests.cpp'
	'AngelscriptObjectTests.cpp|NativeFloatWrapper' = 'AngelScriptSDK/Embedding/AngelscriptNativeObjectRegistrationTests.cpp'
	'AngelscriptOOPTests.cpp|MixinNamespace' = 'AngelScriptSDK/Language/AngelscriptNativeFunctionsTests.cpp'
	'AngelscriptScriptModuleTests.cpp|SingleModulePipeline' = 'AngelScriptSDK/Module/AngelscriptNativeModuleSectionTests.cpp'
	'AngelscriptScriptModuleTests.cpp|MultiSectionBuild' = 'AngelScriptSDK/Module/AngelscriptNativeModuleSectionTests.cpp'
	'AngelscriptScriptModuleTests.cpp|CrossSectionSymbolResolution' = 'AngelScriptSDK/Module/AngelscriptNativeModuleSectionTests.cpp'
	'AngelscriptScriptModuleTests.cpp|EnumerateFunctions' = 'AngelScriptSDK/Module/AngelscriptNativeModuleFunctionTests.cpp'
	'AngelscriptScriptModuleTests.cpp|FunctionArgumentReturnRoundTripExecutesModuleFunctions' = 'AngelScriptSDK/Module/AngelscriptNativeModuleFunctionTests.cpp'
	'AngelscriptScriptModuleTests.cpp|RichModuleStoresTopLevelTablesAndExecutesEntry' = 'AngelScriptSDK/Module/AngelscriptNativeModuleStateTableTests.cpp'
	'AngelscriptScriptModuleTests.cpp|RebuildClearsPreviousTopLevelTables' = 'AngelScriptSDK/Module/AngelscriptNativeModuleStateTableTests.cpp'
	'AngelscriptScriptModuleTests.cpp|FailedBuildDoesNotPublishPartialModuleTablesAndCanRecover' = 'AngelScriptSDK/Module/AngelscriptNativeModuleBuildFailureTests.cpp'
	'AngelscriptSDKCompilerTests.cpp|Error' = 'AngelScriptSDK/Compiler/AngelscriptNativeCompilerDiagnosticTests.cpp'
	'AngelscriptSDKCompilerTests.cpp|MultipleErrors' = 'AngelScriptSDK/Compiler/AngelscriptNativeCompilerDiagnosticTests.cpp'
	'AngelscriptSDKCompilerTests.cpp|TypeMismatch' = 'AngelScriptSDK/Compiler/AngelscriptNativeCompilerDiagnosticTests.cpp'
	'AngelscriptSDKFunctionTests.cpp|RefArgument' = 'AngelScriptSDK/Language/AngelscriptNativeReferencesTests.cpp'
	'AngelscriptSDKFunctionTests.cpp|ByRefMutation' = 'AngelScriptSDK/Language/AngelscriptNativeReferencesTests.cpp'
	'AngelscriptSDKFunctionTests.cpp|ConstInRef' = 'AngelScriptSDK/Language/AngelscriptNativeReferencesTests.cpp'
	'AngelscriptSDKOperatorTests.cpp|Arithmetic' = 'AngelScriptSDK/Language/AngelscriptNativeExpressionsTests.cpp'
	'AngelscriptSDKOperatorTests.cpp|Comparison' = 'AngelScriptSDK/Language/AngelscriptNativeExpressionsTests.cpp'
	'AngelscriptSDKOperatorTests.cpp|Logical' = 'AngelScriptSDK/Language/AngelscriptNativeExpressionsTests.cpp'
	'AngelscriptSDKOperatorTests.cpp|Ternary' = 'AngelScriptSDK/Language/AngelscriptNativeExpressionsTests.cpp'
	'AngelscriptSDKOperatorTests.cpp|Call' = 'AngelScriptSDK/Language/AngelscriptNativeExpressionsTests.cpp'
	'AngelscriptSDKOperatorTests.cpp|Index' = 'AngelScriptSDK/Language/AngelscriptNativeExpressionsTests.cpp'
	'AngelscriptSDKOperatorTests.cpp|Precedence' = 'AngelScriptSDK/Language/AngelscriptNativeExpressionsTests.cpp'
	'AngelscriptSDKOperatorTests.cpp|ShortCircuit' = 'AngelScriptSDK/Language/AngelscriptNativeControlFlowTests.cpp'
	'AngelscriptSDKTypeTests.cpp|TypedefBytecode' = 'AngelScriptSDK/TypeSystem/AngelscriptNativeTypedefTypeTests.cpp'
	'AngelscriptSDKTypeTests.cpp|Enum' = 'AngelScriptSDK/TypeSystem/AngelscriptNativeEnumTypeTests.cpp'
	'AngelscriptSDKTypeTests.cpp|EnumUnderlyingValues' = 'AngelScriptSDK/TypeSystem/AngelscriptNativeEnumTypeTests.cpp'
}

$MethodRename = @{
	'AngelscriptAtomicTests.cpp|InitZero' = 'DefaultConstructionStartsAtZero'
	'AngelscriptAtomicTests.cpp|SetGet' = 'SetAndGetPreserveValue'
	'AngelscriptAtomicTests.cpp|IncDec' = 'IncrementAndDecrementReturnExpectedValues'
	'AngelscriptAtomicTests.cpp|ConcurrentIncDec' = 'ConcurrentIncrementAndDecrementRemainBalanced'
	'AngelscriptEngineTests.cpp|Create' = 'CreatesAndShutsDownRawEngine'
	'AngelscriptNativeParserExpressionsTests.cpp|LambdaIfSupported_OrDocumentReject' = 'AnonymousFunctionProducesCurrentParserShape'
	'AngelscriptNativeReferenceScriptClassTests.cpp|DeletedDefaultConstructorIsRejectedOrDocumented' = 'DeletedDefaultConstructorIsRejected'
	'AngelscriptNativeTokenizerLiteralsTests.cpp|OctalLiteralIfSupported_OrDocumentReject' = 'OctalLiteralTokenizesAsBitsConstant'
	'AngelscriptNativeTokenizerLiteralsTests.cpp|BinaryLiteralIfSupported_OrDocumentReject' = 'BinaryLiteralTokenizesAsBitsConstant'
	'AngelscriptNativeSmokeTest.cpp|Smoke' = 'RawEngineCompilesAndExecutesMinimalFunction'
	'AngelscriptSmokeTest.cpp|Smoke' = 'RawEngineCompilesAndExecutesMinimalFunction'
	'AngelscriptRuntimeTests.cpp|Suspend' = 'SuspendAndResumePreserveContextState'
	'AngelscriptRuntimeTests.cpp|Exception' = 'UnhandledExceptionReturnsExceptionOutcome'
	'AngelscriptThreadTests.cpp|GetLocalDataNonNull' = 'PreparedThreadReturnsLocalData'
	'AngelscriptThreadTests.cpp|GetLocalDataStable' = 'RepeatedLookupReturnsStableLocalData'
	'AngelscriptThreadTests.cpp|DifferentTLS' = 'WorkerThreadsReceiveDistinctLocalData'
	'AngelscriptStringUtilTests.cpp|ParseInt' = 'ScanUnsignedIntegerConsumesExpectedDigits'
	'AngelscriptStringUtilTests.cpp|ParseNegativeInt' = 'ScanSignedDoubleConsumesLeadingSign'
	'AngelscriptStringUtilTests.cpp|ParseFloat' = 'ScanFloatConsumesFractionalLiteral'
	'AngelscriptStringUtilTests.cpp|ParseZero' = 'CompareStringsOrdersEqualAndDistinctValues'
	'AngelscriptStringUtilTests.cpp|LargeValue' = 'Utf8AndUtf16EncodingRoundTripsBoundaryValues'
}

$MethodDestination["AngelscriptScriptModuleTests.cpp|FunctionReturnType$($LegacyTableWord)ExecutesModuleFunctions"] = 'AngelScriptSDK/Module/AngelscriptNativeModuleFunctionTests.cpp'
$MethodRename["AngelscriptCompilerTests.cpp|NegativeAndFloat64$LegacyTableWord"] = 'NegativeAndFloat64ConversionsProduceExecutableBytecode'
$MethodRename["AngelscriptDataTypeTests.cpp|HandleQualifier$LegacyTableWord"] = 'HandleQualifiersPreserveConstAndReferenceFlags'
$MethodRename["AngelscriptScriptModuleTests.cpp|FunctionReturnType$($LegacyTableWord)ExecutesModuleFunctions"] = 'ModuleFunctionsPreserveDeclaredReturnTypes'
$MethodRename["AngelscriptTokenizerTests.cpp|BasicLiteralAndPunctuation$LegacyTableWord"] = 'LiteralAndPunctuationTokensHaveExpectedKinds'
$MethodRename["AngelscriptTypeUsageTests.cpp|TypeUsageFromPropertyScriptMember$LegacyTableWord"] = 'ScriptMembersResolvePrimitiveContainerEnumAndObjectTypes'
$MethodRename["AngelscriptTypeUsageTests.cpp|TypeUsageFromPropertyNativeQualifier$LegacyTableWord"] = 'NativePropertiesPreserveInputOutputAndConstQualifiers'
$MethodRename["AngelscriptTypeUsageTests.cpp|TypeUsageFromDataTypeQualifierAndContainer$LegacyTableWord"] = 'DataTypesResolveQualifiersHandlesAndContainers'

function Get-FinalDomain([string]$FinalFile)
{
	if ($FinalFile -match '^AngelScriptSDK/([^/]+)/') { return $Matches[1] }
	if ($FinalFile -match '^Core/') { return 'Engine' }
	if ($FinalFile -match '^Compiler/') { return 'Compiler' }
	if ($FinalFile -match '^Debugger/') { return 'Debugger' }
	if ($FinalFile -match '^Generator/') { return 'Generator' }
	throw "No domain rule for $FinalFile"
}

function Get-FinalSubject([string]$FinalFile)
{
	$Stem = [IO.Path]::GetFileNameWithoutExtension($FinalFile)
	$Stem = $Stem -replace '^Angelscript', ''
	$Stem = $Stem -replace '^Native', ''
	$Stem = $Stem -replace 'Tests?$', ''
	return $Stem
}

function Get-FinalPrefix([string]$FinalFile)
{
	$Subject = Get-FinalSubject $FinalFile
	if ($FinalFile -match '^AngelScriptSDK/([^/]+)/') { return "Angelscript.TestModule.AngelScriptSDK.$($Matches[1]).$Subject" }
	if ($FinalFile -eq 'Compiler/AngelscriptCompilerModulePipelineTests.cpp') { return 'Angelscript.TestModule.Compiler.ModulePipeline' }
	if ($FinalFile -eq 'Core/AngelscriptContextPoolTests.cpp') { return 'Angelscript.TestModule.Engine.ContextPool' }
	if ($FinalFile -eq 'Core/AngelscriptFunctionCallerErasureTests.cpp') { return 'Angelscript.TestModule.Engine.FunctionCallers' }
	if ($FinalFile -eq 'Core/AngelscriptTypeRegistryTests.cpp') { return 'Angelscript.TestModule.Engine.TypeRegistry' }
	if ($FinalFile -eq 'Core/AngelscriptTypeUsageTests.cpp') { return 'Angelscript.TestModule.Engine.TypeUsage' }
	if ($FinalFile -eq 'Debugger/AngelscriptDebuggerValueTests.cpp') { return 'Angelscript.TestModule.Debugger.Value' }
	if ($FinalFile -eq 'Debugger/AngelscriptDebugReificationTests.cpp') { return 'Angelscript.TestModule.Debugger.Reification' }
	if ($FinalFile -eq 'Generator/ASStruct/AngelscriptStructCppOpsTests.cpp') { return 'Angelscript.TestModule.Generator.ASStruct.CppOps' }
	throw "No prefix rule for $FinalFile"
}

$Rows = [Collections.Generic.List[object]]::new()

foreach ($File in Get-ChildItem $SdkRoot -File -Filter '*.cpp' | Sort-Object Name)
{
	$Content = Get-Content -Raw $File.FullName
	$Methods = [regex]::Matches($Content, 'TEST_METHOD\(([^)]+)\)')
	if ($Methods.Count -eq 0) { continue }

	$ClassMatch = [regex]::Match($Content, 'TEST_CLASS_WITH_FLAGS(?:_AND_TAGS)?\s*\(\s*([^,\r\n]+)\s*,\s*"([^"]+)"', [Text.RegularExpressions.RegexOptions]::Singleline)
	if (-not $ClassMatch.Success) { throw "Unable to parse CQTest class and prefix in $($File.Name)" }

	$CurrentClass = $ClassMatch.Groups[1].Value.Trim()
	$CurrentPrefix = $ClassMatch.Groups[2].Value.Trim()

	foreach ($MethodMatch in $Methods)
	{
		$CurrentMethod = $MethodMatch.Groups[1].Value.Trim()
		$RecordedCurrentMethod = $CurrentMethod -replace [regex]::Escape($LegacyTableWord), '<legacy-generic-suffix>'
		$CurrentLine = ([regex]::Matches($Content.Substring(0, $MethodMatch.Index), "`n")).Count + 1
		$Sha256 = [Security.Cryptography.SHA256]::Create()
		try
		{
			$HashBytes = $Sha256.ComputeHash([Text.Encoding]::UTF8.GetBytes("$($File.Name)|$CurrentMethod"))
			$CurrentMethodSha256 = ([BitConverter]::ToString($HashBytes) -replace '-', '').ToLowerInvariant()
		}
		finally
		{
			$Sha256.Dispose()
		}
		$Key = "$($File.Name)|$CurrentMethod"
		$FinalFile = if ($MethodDestination.ContainsKey($Key)) { $MethodDestination[$Key] } else { $DefaultDestination[$File.Name] }
		if ([string]::IsNullOrWhiteSpace($FinalFile)) { throw "No final file for $Key" }

		$FinalSubject = Get-FinalSubject $FinalFile
		$FinalMethod = if ($MethodRename.ContainsKey($Key)) { $MethodRename[$Key] } elseif ($CurrentMethod.Length -lt 16) { "$FinalSubject$CurrentMethod" } else { $CurrentMethod }
		$Disposition = 'Move'
		$Rationale = 'Preserve the current behavior under its exact subject owner and retain or strengthen its assertions.'

		if ($File.Name -in @('AngelscriptAtomicTests.cpp', 'AngelscriptThreadTests.cpp', 'AngelscriptStringUtilTests.cpp'))
		{
			$Disposition = 'Replace'
			$Rationale = 'Replace the known constant-false or fake implementation with compiled direct coverage of the real fork implementation.'
		}
		elseif ($File.Name -eq 'AngelscriptSmokeTest.cpp')
		{
			$Disposition = 'DeleteDuplicate'
			$Rationale = 'Collapse the duplicate smoke scenario into the one canonical raw-engine smoke method.'
		}
		elseif ($File.Name -match '^AngelscriptNativeReference')
		{
			$Disposition = 'Merge'
			$Rationale = 'Merge the historical reference-port scenario into the current subject owner without retaining a reference-branded suite.'
		}

		$Classification = if ($FinalFile -match '/Conformance/' -or $File.Name -in @('AngelscriptCompilerTests.cpp','AngelscriptContextPoolTests.cpp','AngelscriptDebuggerValueTests.cpp','AngelscriptDebugReificationTests.cpp','AngelscriptFunctionCallerErasureTests.cpp','AngelscriptStructCppOpsTests.cpp','AngelscriptTypeRegistryTests.cpp','AngelscriptTypeUsageTests.cpp')) { 'Fork' } else { 'Compatible' }
		if ($CurrentMethod -match 'Float64|Mutable|Interface|Mixin|Reference') { $Classification = 'Fork' }

		$Rows.Add([pscustomobject][ordered]@{
			CurrentFile = $File.Name
			CurrentClass = $CurrentClass
			CurrentMethod = $RecordedCurrentMethod
			CurrentLine = $CurrentLine
			CurrentMethodSha256 = $CurrentMethodSha256
			CurrentPrefix = $CurrentPrefix
			Disposition = $Disposition
			FinalDomain = Get-FinalDomain $FinalFile
			FinalFile = $FinalFile
			FinalClass = "F$FinalSubject`Tests"
			FinalMethod = $FinalMethod
			Classification = $Classification
			Rationale = $Rationale
		})
	}
}

if ($Rows.Count -ne 433) { throw "Expected 433 TEST_METHOD rows, found $($Rows.Count)" }

$DuplicateSources = $Rows | Group-Object CurrentFile, CurrentClass, CurrentMethod | Where-Object Count -ne 1
if ($DuplicateSources) { throw "Current method source keys are not unique" }

$Rows | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding utf8
Write-Output "Generated $($Rows.Count) rows at $OutputPath"
