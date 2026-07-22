# Source File Migration Map

Every current file in `AngelscriptTest/AngelScriptSDK` has an explicit destination or deletion rationale. This file map and `test-methods.csv` are normative: implementation MUST use the exact final paths, classes, methods, and prefixes recorded here and in the ledger. A discovered ownership error requires an OpenSpec update before moving the affected method; implementation does not invent a destination while editing code.

Final paths are relative to `Plugins/Angelscript/Source/AngelscriptTest/`. Files beginning with `AngelScriptSDK/` remain in the native layer; all other paths are deliberate moves to another test layer.

## Support headers

| Current file | Action | Final owner |
| --- | --- | --- |
| `AngelscriptNativeTestSupport.h` | Move and remove root compatibility entry | `Support/AngelscriptNativeCoreTestSupport.h`; later topic headers consume or extract the relevant helpers |
| `AngelscriptTestAdapter.h` | Keep and update only for new support types/gates | root stable compatibility adapter |
| `AngelscriptBuilderTestSupport.h` | Split then delete | `Support/AngelscriptNativeBuilderTestSupport.h`, `Support/AngelscriptNativeCompilerTestSupport.h`, and `Support/AngelscriptNativeModuleTestSupport.h` |
| `AngelscriptSDKTestExecutionHelpers.h` | Split then delete | `Support/AngelscriptNativeExecutionTestSupport.h` |
| `AngelscriptSDKTestUtilities.h` | Migrate call sites then delete | umbrella functionality absorbed by root stable include |
| `AngelscriptStructCppOpsTestTypes.h` | Move out of SDK | `Generator/ASStruct/AngelscriptStructCppOpsTestTypes.h` |

New support files:

- `Support/AngelscriptNativeEngineTestSupport.h`
- `Support/AngelscriptNativeModuleTestSupport.h`
- `Support/AngelscriptNativeExecutionTestSupport.h`
- `Support/AngelscriptNativeCompilerTestSupport.h`
- `Support/AngelscriptNativeBuilderTestSupport.h`

## Engine

| Current file | Action | Final file / responsibility |
| --- | --- | --- |
| `AngelscriptAtomicTests.cpp` | Move, enable, clean formatting | `Engine/AngelscriptNativeAtomicTests.cpp` |
| `AngelscriptEngineTests.cpp` | Move/expand | `Engine/AngelscriptNativeEngineLifecycleTests.cpp` |
| `AngelscriptMemoryTests.cpp` | Move/expand | `Engine/AngelscriptNativeMemoryTests.cpp` |
| `AngelscriptThreadTests.cpp` | Move, enable, expand manager/interface lifecycle | `Engine/AngelscriptNativeThreadingTests.cpp` |
| `AngelscriptNativeSmokeTest.cpp` | Merge | canonical `Engine/AngelscriptNativeEngineSmokeTests.cpp` |
| `AngelscriptSmokeTest.cpp` | Merge then delete duplicate | canonical Engine smoke above |
| `AngelscriptContextPoolTests.cpp` | Move out of SDK | `Core/AngelscriptContextPoolTests.cpp`, ID `Engine.ContextPool` |

New Engine coverage also owns `asCLockableSharedBool`, `asCThreadLocalData`, `asCThreadManager`, allocator hooks, engine profiles, and interface lifecycle.

## Frontend

| Current file | Action | Final file / responsibility |
| --- | --- | --- |
| `AngelscriptTokenizerTests.cpp` | Move/rename ID | `Frontend/AngelscriptNativeTokenizerCoreTests.cpp` |
| `AngelscriptNativeTokenizerLiteralsTests.cpp` | Move | `Frontend/AngelscriptNativeTokenizerLiteralsTests.cpp` |
| `AngelscriptNativeTokenizerOperatorsTests.cpp` | Move | `Frontend/AngelscriptNativeTokenizerOperatorsTests.cpp` |
| `AngelscriptNativeTokenizerWhitespaceTests.cpp` | Move | `Frontend/AngelscriptNativeTokenizerWhitespaceTests.cpp` |
| `AngelscriptNativeReferenceTokenizerTests.cpp` | Move by tokenizer boundary/error subject | `Frontend/AngelscriptNativeTokenizerBoundaryTests.cpp` |
| `AngelscriptParserTests.cpp` | Move/rename ID | `Frontend/AngelscriptNativeParserCoreTests.cpp` |
| `AngelscriptNativeParserDeclarationsTests.cpp` | Move | `Frontend/AngelscriptNativeParserDeclarationsTests.cpp` |
| `AngelscriptNativeParserExpressionsTests.cpp` | Move | `Frontend/AngelscriptNativeParserExpressionsTests.cpp` |
| `AngelscriptNativeParserErrorsTests.cpp` | Move | `Frontend/AngelscriptNativeParserErrorsTests.cpp` |
| `AngelscriptScriptNodeTests.cpp` | Move/rename ID | `Frontend/AngelscriptNativeScriptNodeCoreTests.cpp` |
| `AngelscriptNativeScriptNodeShapeTests.cpp` | Move | `Frontend/AngelscriptNativeScriptNodeShapeTests.cpp` |
| `AngelscriptNativeScriptNodeSourceRangeTests.cpp` | Move | `Frontend/AngelscriptNativeScriptNodeSourceRangeTests.cpp` |
| `AngelscriptNativeScriptNodeCopyTests.cpp` | Move | `Frontend/AngelscriptNativeScriptNodeCopyTests.cpp` |
| `AngelscriptStringUtilTests.cpp` | Replace fake compiled-out tests | `Frontend/AngelscriptNativeStringUtilityTests.cpp`, calls real exports |
| none | Add | `Frontend/AngelscriptNativeScriptCodeTests.cpp`, `AngelscriptNativeStringTests.cpp` |

## Compiler

| Current file | Action | Final file / responsibility |
| --- | --- | --- |
| `AngelscriptBuilderAppInterfaceTests.cpp` | Move/ID | `Compiler/AngelscriptNativeBuilderApplicationTests.cpp` |
| `AngelscriptBuilderBytecodeTests.cpp` | Move/ID | `Compiler/AngelscriptNativeBuilderBytecodeTests.cpp` |
| `AngelscriptBuilderDeclarationTests.cpp` | Move/ID | `Compiler/AngelscriptNativeBuilderDeclarationTests.cpp` |
| `AngelscriptBuilderDependencyTests.cpp` | Move/ID | `Compiler/AngelscriptNativeBuilderDependencyTests.cpp` |
| `AngelscriptBuilderDiagnosticsTests.cpp` | Split/ID | `Compiler/AngelscriptNativeBuilderDiagnosticTests.cpp`; includes enum cleanup regression |
| `AngelscriptBuilderEditorOnlyTests.cpp` | Move/ID | `Compiler/AngelscriptNativeBuilderEditorOnlyTests.cpp` |
| `AngelscriptBuilderGlobalVariableTests.cpp` | Move/ID | `Compiler/AngelscriptNativeBuilderGlobalTests.cpp` |
| `AngelscriptBuilderLayoutTests.cpp` | Move/ID | `Compiler/AngelscriptNativeBuilderLayoutTests.cpp` |
| `AngelscriptBuilderLifecycleTests.cpp` | Move/ID | `Compiler/AngelscriptNativeBuilderLifecycleTests.cpp` |
| `AngelscriptBuilderTests.cpp` | Split then delete monolith | `Compiler/AngelscriptNativeBuilderFunctionTests.cpp`, `Compiler/AngelscriptNativeBuilderParsingTests.cpp`, `Compiler/AngelscriptNativeBuilderTypeTests.cpp`, `Compiler/AngelscriptNativeBuilderLayoutTests.cpp`, `Compiler/AngelscriptNativeBuilderLifecycleTests.cpp`, `Compiler/AngelscriptNativeBuilderDependencyTests.cpp`, `Compiler/AngelscriptNativeBuilderNamespaceTests.cpp`, and `Compiler/AngelscriptNativeBuilderPropertyTests.cpp` according to the method ledger |
| `AngelscriptBytecodeTests.cpp` | Split then delete monolith | `Compiler/AngelscriptNativeByteInstructionTests.cpp` and `Compiler/AngelscriptNativeBytecodeGenerationTests.cpp` |
| `AngelscriptNativeBytecodeJumpsTests.cpp` | Move | `Compiler/AngelscriptNativeBytecodeJumpTests.cpp` |
| `AngelscriptNativeBytecodeOpcodesTests.cpp` | Move | `Compiler/AngelscriptNativeBytecodeOpcodeTests.cpp` |
| `AngelscriptNativeBytecodeOptimizeTests.cpp` | Move | `Compiler/AngelscriptNativeBytecodeOptimizationTests.cpp` |
| `AngelscriptNativeCompileTests.cpp` | Move/expand | `Compiler/AngelscriptNativeCompilerCoreTests.cpp` |
| `AngelscriptSDKCompilerTests.cpp` | Merge by behavior, delete source | `Compiler/AngelscriptNativeCompilerCoreTests.cpp` and `Compiler/AngelscriptNativeCompilerDiagnosticTests.cpp` |
| `AngelscriptOutputBufferTests.cpp` | Move/expand | `Compiler/AngelscriptNativeOutputBufferTests.cpp` |
| `AngelscriptCompilerTests.cpp` | Move out of SDK | `Compiler/AngelscriptCompilerModulePipelineTests.cpp`, ID `Compiler.ModulePipeline` |

New Compiler files directly cover `asCByteInstruction`, `asCExprContext`, and `asCExprValue`.

## Runtime

| Current file | Action | Final file / responsibility |
| --- | --- | --- |
| `AngelscriptNativeExecutionTests.cpp` | Move/merge | `Runtime/AngelscriptNativeContextInvocationTests.cpp` |
| `AngelscriptNativeExecutionAdvancedTests.cpp` | Move/merge | `Runtime/AngelscriptNativeContextReturnValueTests.cpp` |
| `AngelscriptRuntimeTests.cpp` | Split/repair false suspend | `Runtime/AngelscriptNativeContextControlTests.cpp` and `Runtime/AngelscriptNativeContextExceptionTests.cpp` |
| `AngelscriptNativeReferenceContextTests.cpp` | Move by exception-recovery behavior | `Runtime/AngelscriptNativeContextRecoveryTests.cpp` |
| `AngelscriptGCInternalTests.cpp` | Rewrite raw and move | `Runtime/AngelscriptNativeGarbageCollectorTests.cpp` |
| none | Add | `Runtime/AngelscriptNativeGenericCallTests.cpp`; `Runtime/AngelscriptNativeScriptObjectTests.cpp` is also the exact destination for the existing object-runtime methods |

## Module

| Current file | Action | Final file / responsibility |
| --- | --- | --- |
| `AngelscriptScriptModuleTests.cpp` | Split then delete monolith | `Module/AngelscriptNativeModuleLifecycleTests.cpp`, `Module/AngelscriptNativeModuleSectionTests.cpp`, `Module/AngelscriptNativeModuleFunctionTests.cpp`, `Module/AngelscriptNativeModuleStateTableTests.cpp`, and `Module/AngelscriptNativeModuleBuildFailureTests.cpp` |
| `AngelscriptScriptModuleImportTests.cpp` | Move/ID | `Module/AngelscriptNativeModuleImportTests.cpp` |
| `AngelscriptScriptModuleNamespaceTests.cpp` | Move/ID | `Module/AngelscriptNativeModuleNamespaceTests.cpp` |
| `AngelscriptScriptModuleSectionDiagnosticsTests.cpp` | Move/ID | `Module/AngelscriptNativeModuleSectionTests.cpp` |
| `AngelscriptRestoreTests.cpp` | Rewrite raw and move | `Module/AngelscriptNativeRestorePrimitiveTests.cpp` |
| `AngelscriptNativeReferenceSaveLoadTests.cpp` | Move/merge | `Module/AngelscriptNativeModuleSaveLoadTests.cpp` |

## TypeSystem

| Current file | Action | Final file / responsibility |
| --- | --- | --- |
| `AngelscriptConfigGroupTests.cpp` | Move/expand direct class coverage | `TypeSystem/AngelscriptNativeConfigGroupTests.cpp` |
| `AngelscriptDataTypeTests.cpp` | Rewrite raw and move | `TypeSystem/AngelscriptNativeDataTypeTests.cpp` |
| `AngelscriptDefaultTraitTests.cpp` | Move/expand | `TypeSystem/AngelscriptNativeDefaultTraitTests.cpp` |
| `AngelscriptGlobalPropertyTests.cpp` | Move/expand | `TypeSystem/AngelscriptNativeGlobalPropertyTests.cpp` |
| `AngelscriptSDKTypeTests.cpp` | Split by real owner then delete | `TypeSystem/AngelscriptNativePrimitiveTypeTests.cpp`, `TypeSystem/AngelscriptNativeEnumTypeTests.cpp`, and `TypeSystem/AngelscriptNativeTypedefTypeTests.cpp` |
| `AngelscriptVariableScopeTests.cpp` | Move/enable direct class coverage | `TypeSystem/AngelscriptNativeVariableScopeTests.cpp` |
| `AngelscriptTypeRegistryTests.cpp` | Move out of SDK | `Core/AngelscriptTypeRegistryTests.cpp`, ID `Engine.TypeRegistry` |
| `AngelscriptTypeUsageTests.cpp` | Move out of SDK | `Core/AngelscriptTypeUsageTests.cpp`, ID `Engine.TypeUsage` |

New TypeSystem owners that close internal/public surfaces without inheriting a current monolith name:

- `TypeSystem/AngelscriptNativeTypeInfoTests.cpp`
- `TypeSystem/AngelscriptNativeObjectTypeTests.cpp`
- `TypeSystem/AngelscriptNativeFuncdefTypeTests.cpp`
- `TypeSystem/AngelscriptNativeScriptFunctionTests.cpp`

## Language

| Current file | Action | Final file / responsibility |
| --- | --- | --- |
| `AngelscriptConversionTests.cpp` | Move/expand runtime assertions | `Language/AngelscriptNativeConversionsTests.cpp` |
| `AngelscriptGlobalVarTests.cpp` | Split | `Module/AngelscriptNativeModuleGlobalTests.cpp`, `Language/AngelscriptNativeVariablesTests.cpp`, `Conformance/AngelscriptNativeGlobalSemanticsTests.cpp`, and `Runtime/AngelscriptNativeContextExceptionTests.cpp` |
| `AngelscriptObjectTests.cpp` | Split/expand execution | `Runtime/AngelscriptNativeScriptObjectTests.cpp`, `Language/AngelscriptNativeConstructorsTests.cpp`, and `Embedding/AngelscriptNativeObjectRegistrationTests.cpp` according to the method ledger |
| `AngelscriptOOPTests.cpp` | Split/expand execution | `Conformance/AngelscriptNativeInterfaceSemanticsTests.cpp` and `Language/AngelscriptNativeFunctionsTests.cpp` |
| `AngelscriptSDKFunctionTests.cpp` | Split | `Language/AngelscriptNativeFunctionsTests.cpp` and `Language/AngelscriptNativeReferencesTests.cpp` |
| `AngelscriptSDKOperatorTests.cpp` | Split | `Language/AngelscriptNativeExpressionsTests.cpp`, `AngelscriptNativeOperatorsTests.cpp`, and `AngelscriptNativeControlFlowTests.cpp` |
| `AngelscriptNativeReferenceScriptClassTests.cpp` | Split and delete permissive source | `Language/AngelscriptNativeConstructorsTests.cpp`, `Language/AngelscriptNativeInheritanceTests.cpp`, and `Conformance/AngelscriptNativeMemberInitialization238Tests.cpp` according to the method ledger |
| none | Add/complete named themes | `Language/AngelscriptNativeDeclarationsTests.cpp`, `Language/AngelscriptNativeFunctionsTests.cpp`, `Language/AngelscriptNativeVariablesTests.cpp`, `Language/AngelscriptNativePropertiesTests.cpp`, `Language/AngelscriptNativeConstructorsTests.cpp`, `Language/AngelscriptNativeDestructorsTests.cpp`, `Language/AngelscriptNativeInheritanceTests.cpp`, `Language/AngelscriptNativeReferencesTests.cpp`, `Language/AngelscriptNativeExpressionsTests.cpp`, `Language/AngelscriptNativeOperatorsTests.cpp`, `Language/AngelscriptNativeConversionsTests.cpp`, `Language/AngelscriptNativeControlFlowTests.cpp`, `Language/AngelscriptNativeForeachTests.cpp`, and `Language/AngelscriptNativeExceptionsTests.cpp` |

## Embedding

| Current file | Action | Final file / responsibility |
| --- | --- | --- |
| `AngelscriptCallFuncTests.cpp` | Move/expand active backend execution | `Embedding/AngelscriptNativeCallFunctionTests.cpp` |
| `AngelscriptCallingConvTests.cpp` | Move and replace compile-only Thiscall claim | `Embedding/AngelscriptNativeCallingConventionTests.cpp` |
| `AngelscriptExecuteTests.cpp` | Move/rename by host callback behavior | `Embedding/AngelscriptNativeGlobalCallbackTests.cpp` |
| `AngelscriptNativeRegistrationTests.cpp` | Split/expand | `Embedding/AngelscriptNativeGlobalRegistrationTests.cpp` and `Embedding/AngelscriptNativeObjectRegistrationTests.cpp` |
| none | Add | `Embedding/AngelscriptNativeInterfaceContractTests.cpp`, `Embedding/AngelscriptNativeStringFactoryTests.cpp`, `Embedding/AngelscriptNativeJITCompilerTests.cpp`, `Embedding/AngelscriptNativeThreadManagerContractTests.cpp`, and `Embedding/AngelscriptNativeGenericInterfaceTests.cpp` |

## Conformance

| Current file | Action | Final file / responsibility |
| --- | --- | --- |
| `AngelscriptNativeReferenceCompilerRejectTests.cpp` | Move by negative semantic diagnostic behavior | `Language/AngelscriptNativeSemanticRejectionTests.cpp` |
| `AngelscriptNativeReferenceParserErrorTests.cpp` | Move by parser diagnostic behavior | `Frontend/AngelscriptNativeParserDiagnosticTests.cpp` |
| portions of global/object/OOP/reference tests | Split | `AngelscriptNativeGlobalSemanticsTests.cpp`, `AngelscriptNativeReferenceSemanticsTests.cpp`, `AngelscriptNativeInterfaceSemanticsTests.cpp`, `AngelscriptNativeMixinSemanticsTests.cpp` |
| none | Add future targets | `Conformance/AngelscriptNativeUsingNamespace238Tests.cpp`, `Conformance/AngelscriptNativeMemberInitialization238Tests.cpp`, `Conformance/AngelscriptNativeDefaultSpecialMembers238Tests.cpp`, `Conformance/AngelscriptNativeBoolContext238Tests.cpp`, `Conformance/AngelscriptNativeLambda238Tests.cpp`, `Conformance/AngelscriptNativeVariadicFunction238Tests.cpp`, and `Conformance/AngelscriptNativeTemplateFunction238Tests.cpp`, each Disabled/tagged |

## Moves outside SDK

| Current file | Final location / ID |
| --- | --- |
| `AngelscriptDebuggerValueTests.cpp` | `Debugger/AngelscriptDebuggerValueTests.cpp` / `Debugger.Value` |
| `AngelscriptDebugReificationTests.cpp` | `Debugger/AngelscriptDebugReificationTests.cpp` / `Debugger.Reification` |
| `AngelscriptFunctionCallerErasureTests.cpp` | `Core/AngelscriptFunctionCallerErasureTests.cpp` / `Engine.FunctionCallers` |
| `AngelscriptStructCppOpsTests.cpp` | `Generator/ASStruct/AngelscriptStructCppOpsTests.cpp` / `Generator.ASStruct.CppOps` |
| `AngelscriptStructCppOpsTestTypes.cpp` | `Generator/ASStruct/AngelscriptStructCppOpsTestTypes.cpp` support, no registration |

## Deletion guard

A current file may be deleted only after:

1. all valid `TEST_METHOD` scenarios are mapped to a destination or explicitly marked duplicate/invalid;
2. the destination uses the new ID and registration gate;
3. old includes/symbol names have zero matches;
4. the static inventory reports no unmapped source.

## New source ownership guard

- Each final source owns one named subject. File size is evidence for review, not a split quota.
- A source larger than 500 lines is allowed when all methods belong to the same subject; record the cohesion rationale here before implementation completes.
- Do not split a cohesive subject merely to reduce line count.
- Every final registering source uses the class, method names, and automation prefix in `test-methods.csv` plus the new-method definitions in `test-scenarios.md`.
- Final class names are derived from the subject, e.g. `AngelScriptSDK/Engine/AngelscriptNativeAtomicTests.cpp` registers `FAtomicTests` at `Angelscript.TestModule.AngelScriptSDK.Engine.Atomic`.
| `AngelscriptSmokeTest.cpp` | Move and restrict adapter use to a statement snippet | `Engine/AngelscriptNativeEngineMessageCallbackTests.cpp` |
