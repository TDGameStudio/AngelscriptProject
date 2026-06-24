# File-Level Using Namespace Audit

This audit records the first-pass source files for `fix-angelscript-test-unity-symbol-scope`.

Scan command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File openspec\changes\fix-angelscript-test-unity-symbol-scope\scan-file-level-using.ps1
```

Verification command after migration:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File openspec\changes\fix-angelscript-test-unity-symbol-scope\scan-file-level-using.ps1 -FailOnRequired
```

## Summary Before Migration

- Required SDK support imports: 89 imports across 59 files.
- Required file/theme private imports: 38 imports across 38 files.
- First-pass total: 127 imports across 97 files.
- Deferred broad utility imports: 61 imports across 52 files.

## First-Pass Scope

The first pass removes file-level `using namespace` for:

- `AngelscriptBuilderTestSupport`
- `AngelscriptNativeTestSupport`
- `AngelscriptSDKTestSupport`
- `AngelscriptSDKTestUtilities`
- names ending in `_Private`
- names ending in `TestHelpers`
- `CompilerPipeline*Test`
- `PreprocessorTestHelpers`
- `SubsystemGetterMetadataTest`
- `CurveTestHelpers`
- `WorldCollisionTraceTestHelpers`

The migration target is CQTest method/hook-local `using namespace` or explicit qualification. Do not move a using directive to C++ class scope; C++ does not allow namespace using-directives there.

## First-Pass Files

### AngelScriptSDK Support Imports

- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderAppInterfaceTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderBytecodeTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderDeclarationTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderDependencyTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderDiagnosticsTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderEditorOnlyTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderGlobalVariableTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderLayoutTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderLifecycleTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptBytecodeTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptCallFuncTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptCallingConvTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptConfigGroupTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptConversionTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptDefaultTraitTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptEngineTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptExecuteTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptGlobalPropertyTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptGlobalVarTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeBytecodeJumpsTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeBytecodeOpcodesTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeBytecodeOptimizeTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeCompileTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeExecutionAdvancedTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeExecutionTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeParserDeclarationsTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeParserErrorsTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeParserExpressionsTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeReferenceCompilerRejectTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeReferenceParserErrorTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeReferenceSaveLoadTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeReferenceTokenizerTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeRegistrationTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeScriptNodeCopyTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeScriptNodeShapeTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeScriptNodeSourceRangeTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeSmokeTest.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTokenizerLiteralsTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTokenizerOperatorsTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTokenizerWhitespaceTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptObjectTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptOOPTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptOutputBufferTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptParserTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptRestoreTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptRuntimeTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptScriptModuleImportTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptScriptModuleNamespaceTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptScriptModuleSectionDiagnosticsTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptScriptModuleTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptSDKCompilerTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptSDKFunctionTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptSDKOperatorTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptSDKTypeTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptSmokeTest.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptStringUtilTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptTokenizerTests.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/AngelscriptVariableScopeTests.cpp`

### File/Theme Private Imports

- `Source/AngelscriptTest/Bindings/AngelscriptCurveFunctionLibraryTests.cpp`
- `Source/AngelscriptTest/Bindings/AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineBlueprintEventWrapperTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineClassHierarchyTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineControlFlowTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineDelegateRuntimeTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineDelegateTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineFormatStringTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineFunctionDefaultTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineFunctionFlagTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineGlobalUFunctionTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineImportReloadTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineImportTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineMetadataSpecifierTests.cpp`
- `Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelinePropertyDefaultTests.cpp`
- `Source/AngelscriptTest/Core/AngelscriptEngineParityTests.cpp`
- `Source/AngelscriptTest/Core/AngelscriptFunctionLibrarySignatureTests.cpp`
- `Source/AngelscriptTest/Dump/AngelscriptDumpCommand.cpp`
- `Source/AngelscriptTest/Functional/Actor/AngelscriptActorInteractionTests.cpp`
- `Source/AngelscriptTest/Functional/Actor/AngelscriptActorPropertyInterfaceTests.cpp`
- `Source/AngelscriptTest/Functional/Interface/AngelscriptInterfaceNativeTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorAsyncTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorBasicTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorClassTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorCompilationEventsTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorContextTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorDirectiveTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorFunctionMacroTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorImportTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorLiteralTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorMacroShapeTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorNamespaceTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorPathTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorPropertyTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorStructTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorSummaryTests.cpp`
- `Source/AngelscriptTest/Preprocessor/AngelscriptVirtualScriptPathPreprocessorTests.cpp`
- `Source/AngelscriptTest/Shared/AngelscriptConstructionContextProbe.cpp`

## Deferred Scope

These broad shared utility imports are not part of the first pass unless they trigger a concrete unity conflict:

- `AngelscriptFunctionalTestUtils`
- `AngelscriptActorTestUtils`
- `AngelscriptBlueprintTestUtils`
