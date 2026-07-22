# Required Test Scenarios

## Purpose and completion rule

This record defines the minimum behavioral depth of the final suite. `test-methods.csv` prevents loss of the 433 current methods; this file prevents a mechanically complete but semantically shallow rewrite.

A subject is complete only when:

1. every migrated method assigned to the subject is implemented or replaced with recorded evidence;
2. every required scenario below has the exact owner and final `TEST_METHOD` name shown here;
3. all applicable dimensions are asserted: public contract, internal state, valid input, invalid input, runtime result, lifecycle/cleanup, interaction, isolation/reuse, and fork/upstream classification;
4. a non-applicable dimension has a concrete reason in the final audit rather than a bare `N/A`;
5. a compile assertion is followed by execution or internal-state evidence whenever the behavior has an executable or observable result;
6. no scenario accepts contradictory outcomes or multiple unrelated diagnostic categories.

The names below are minimum required methods, not a numerical quota. Existing methods in the migration ledger remain additional required coverage unless explicitly merged, replaced, or deleted with evidence.

## Engine domain

| Final owner | Required `TEST_METHOD` | Behavioral evidence and dimensions |
| --- | --- | --- |
| `Engine/AngelscriptNativeEngineLifecycleTests.cpp` | `BareProfileLeavesOptionalPropertiesAtSdkDefaults` | Create a raw engine with `BareSdk`, query every property the helper could alter, and prove the profile did not silently apply fork settings. Contract, configuration, isolation. |
| `Engine/AngelscriptNativeEngineMessageCallbackTests.cpp` | `EngineMessageCallbackCapturesInfoAndStatementExecutionSucceeds` | Install a test-local message callback, emit an information message, and execute a statement snippet through the adapter. Callback/adapter contract. |
| same | `ForkProfileAppliesEveryRecordedProperty` | Verify the 16-property fork profile one property at a time and report the mismatching property. Contract, fork classification. |
| same | `EngineShutdownReleasesCaseOwnedModulesAndContexts` | Create module/context/user data, shut down through RAII, and prove release callbacks and owned-resource counters return to baseline. Lifecycle, cleanup. |
| same | `IndependentEnginesDoNotShareRegistrationsOrModules` | Register/build on one engine, query the second, and prove isolation in both directions. Interaction, isolation. |
| same | `MessageCallbackCapturesTypeSectionRowColumnAndText` | Trigger one warning/error and assert the complete message entry rather than only non-empty text. Callback, diagnostic fidelity. |
| `Engine/AngelscriptNativeAtomicTests.cpp` | `DefaultConstructionStartsAtZero` | Direct `asCAtomic` initial state. Internal state. |
| same | `SetAndGetPreserveValue` | Positive, zero, and boundary values round trip. Input boundary. |
| same | `IncrementAndDecrementReturnExpectedValues` | Return values and stored value before/after each operation. State transition. |
| same | `ConcurrentIncrementAndDecrementRemainBalanced` | Multiple joined workers mutate the same atomic and final value returns to baseline. Concurrency, cleanup, repeatability. |
| `Engine/AngelscriptNativeThreadingTests.cpp` | `PreparedThreadReturnsLocalData` | Prepare current thread, obtain local data, and release only test-owned state. Public/internal contract. |
| same | `RepeatedLookupReturnsStableLocalData` | Repeated same-thread lookup returns the same object and preserves per-thread fields. Identity, reuse. |
| same | `WorkerThreadsReceiveDistinctLocalData` | Workers get distinct TLS, join, and leave no test-owned thread data. Isolation, cleanup. |
| same | `ProductionThreadManagerRemainsInstalledAfterCase` | Observe manager identity before/after the test without unpreparing the production manager. Global-state safety. |
| `Engine/AngelscriptNativeMemoryTests.cpp` | `EngineAllocationsUseForkMemoryGateway` | Exercise engine allocation/free through the current FMemory-backed path and prove balanced accounting. Host integration, lifecycle. |
| same | `DiscardAndGarbageCollectionReleaseUnusedAllocations` | Build/discard/collect and compare owned allocation counters. Lifecycle interaction. |
| same | `UnavailableGlobalMemoryCallbacksRemainUninvoked` | Contract test proves the suite does not call header-only/non-restorable memory callback APIs. Fork classification, process safety. |
| `Engine/AngelscriptNativeEngineSmokeTests.cpp` | `RawEngineCompilesAndExecutesMinimalFunction` | One canonical create/build/exact-lookup/execute/return/shutdown path. Root smoke; no duplicate owner. |

## Frontend domain

| Final owner | Required `TEST_METHOD` | Behavioral evidence and dimensions |
| --- | --- | --- |
| `Frontend/AngelscriptNativeScriptCodeTests.cpp` | `RowAndColumnConversionHandlesStartMiddleAndEndOffsets` | Exact row/column conversion over multiline source, including CRLF/LF and EOF. Position boundary. |
| same | `LineSensitiveSourcePreservesOriginalOffsets` | Use the preserve-lines fixture helper with an explicit reason and verify diagnostics are not shifted by C++ indentation. Formatting interaction. |
| `Frontend/AngelscriptNativeTokenizerCoreTests.cpp` | `IdentifiersKeywordsAndPunctuationTokenizeInOrder` | Sequence, type, lexeme length, and next-token position. Public/internal input. |
| same | `LongIdentifierBoundaryDoesNotConsumeFollowingAssignment` | Boundary-length identifier followed by operator remains two correct tokens. Boundary/recovery. |
| `Frontend/AngelscriptNativeTokenizerLiteralsTests.cpp` | `IntegerRadicesAndFloatingSuffixesProduceExactTokenKinds` | Decimal, hex, octal, binary, float32, float64, exponent and suffix lengths. Valid classification. |
| same | `MalformedNumericSuffixStopsAtTheFirstInvalidCharacter` | Exact token length and subsequent recovery token. Invalid input/recovery. |
| `Frontend/AngelscriptNativeTokenizerOperatorsTests.cpp` | `LongestOperatorWinsWithoutConsumingAdjacentTokens` | All overlapping one/two/three-character operators plus neighboring identifiers. Boundary/interaction. |
| `Frontend/AngelscriptNativeTokenizerWhitespaceTests.cpp` | `CommentsWhitespaceAndNewlinesPreserveNextTokenPosition` | Line/block comments, CRLF/LF, escaped newline, unterminated block comment. Position/recovery. |
| `Frontend/AngelscriptNativeTokenizerErrorTests.cpp` | `UnrecognizedTokenDoesNotPoisonFollowingIdentifier` | Exact error token then valid identifier. Error recovery. |
| same | `UnterminatedStringReportsDedicatedTokenAndLength` | Exact error kind and consumed range. Negative diagnostic. |
| `Frontend/AngelscriptNativeTokenizerBoundaryTests.cpp` | `LongIdentifierAndMalformedTokenPreserveFollowingTokenization` | Long-identifier limits, following assignment token, unrecognized token recovery and unterminated-string kind/length. Boundary/recovery. |
| `Frontend/AngelscriptNativeParserDeclarationsTests.cpp` | `DeclarationsProduceExpectedNodeKindsAndHierarchy` | Namespace, class, function, property, enum, typedef, funcdef, shared/external forms. Grammar/shape. |
| same | `DuplicateOrMalformedDeclarationStopsAtTheOwningBoundary` | Exact parser diagnostic and subsequent declaration recovery. Negative/recovery. |
| `Frontend/AngelscriptNativeParserExpressionsTests.cpp` | `PrecedenceCallIndexCastAndTernaryProduceExpectedTreeShape` | Node hierarchy and source ranges for interacting expression forms. Grammar/interaction. |
| same | `AnonymousFunctionProducesCurrentParserShape` | Assert the current parser node shape only; do not claim executable lambda semantics. Fork classification. |
| `Frontend/AngelscriptNativeParserErrorsTests.cpp` | `MalformedInputsReportOneOwningSyntaxCategoryAndRecover` | Missing brace, parameter delimiter, namespace EOF and malformed expression each have precise expected category/position. Negative/recovery. |
| `Frontend/AngelscriptNativeParserDiagnosticTests.cpp` | `MalformedDeclarationsReportStableErrorCountsAndRecovery` | Incomplete class, invalid parameter qualifier, namespace EOF and multiple malformed declarations retain deterministic error counts and recovery behavior. Diagnostic/recovery. |
| `Frontend/AngelscriptNativeScriptNodeCoreTests.cpp` | `TraversalVisitsParentsChildrenAndSiblingsInSourceOrder` | Tree links and stable order. Internal behavior. |
| `Frontend/AngelscriptNativeScriptNodeCopyTests.cpp` | `DeepCopyOwnsIndependentChildrenAndSourceRanges` | Mutate/free original and prove copy remains valid. Ownership/lifecycle. |
| `Frontend/AngelscriptNativeScriptNodeSourceRangeTests.cpp` | `NestedNodesRemainWithinParentSourceRange` | Start/end containment and exact leaf range. Invariant. |
| `Frontend/AngelscriptNativeStringUtilityTests.cpp` | `ScanUnsignedIntegerConsumesExpectedDigits` | Direct exported integer scan, bases, consumed length, overflow boundary. Valid/boundary. |
| same | `ScanSignedDoubleConsumesLeadingSign` | Sign, exponent, consumed length and result. Valid/boundary. |
| same | `ScanFloatRejectsMalformedExponentAtExactOffset` | Invalid input and failure position. Negative. |
| same | `CompareStringsOrdersEqualAndDistinctValues` | Equal, prefix, lexicographic and empty inputs. Input classes. |
| same | `Utf8AndUtf16EncodingRoundTripsBoundaryValues` | ASCII, multibyte, surrogate boundary, invalid scalar behavior. Round trip/error. |
| `Frontend/AngelscriptNativeStringTests.cpp` | `StringCopyMoveAppendAndComparisonPreserveOwnership` | Direct internal string operations including empty/self assignment. Lifecycle/aliasing. |

## Compiler domain

| Final owner | Required `TEST_METHOD` | Behavioral evidence and dimensions |
| --- | --- | --- |
| `Compiler/AngelscriptNativeBuilderParsingTests.cpp` | `ParseStageCreatesOwnedTreesForEverySection` | Multiple sections, node ownership and cleanup after failure. Phase/lifecycle. |
| `Compiler/AngelscriptNativeBuilderTypeTests.cpp` | `TypeGenerationPublishesOnlyCompleteDeclarations` | Successful class/enum/typedef/funcdef publication and no leak after duplicate/invalid declaration. Phase/error atomicity. |
| `Compiler/AngelscriptNativeBuilderFunctionTests.cpp` | `FunctionGenerationPreservesDeclarationsOverloadsAndSections` | Exact declarations, overload identities, section ownership and executable bodies. Metadata/runtime. |
| `Compiler/AngelscriptNativeBuilderPropertyTests.cpp` | `PropertyInitializersAndAccessorsReachExecutableBytecode` | Field/virtual property resolution, initializer execution and invalid accessor diagnostic. Phase/runtime. |
| `Compiler/AngelscriptNativeBuilderNamespaceTests.cpp` | `NamespaceResolutionSeparatesTypesFunctionsAndGlobals` | Same short names in different namespaces resolve by exact declaration. Resolution/interaction. |
| `Compiler/AngelscriptNativeBuilderDependencyTests.cpp` | `CrossSectionDependenciesCompileInDependencyOrder` | Forward references and cross-section calls execute; missing dependency fails without partial state. Interaction/error. |
| `Compiler/AngelscriptNativeBuilderLifecycleTests.cpp` | `FailedStageCannotPublishExecutableCodeAndCanRebuild` | Fail, inspect empty publication, fix source, rebuild and execute. Recovery/reuse. |
| `Compiler/AngelscriptNativeBuilderDiagnosticTests.cpp` | `EveryDiagnosticRetainsOwningSectionRowColumnAndSeverity` | Parse/type/function/global initializer/warning-as-error cases with exact location/severity. Diagnostic fidelity. |
| same | `PostBuildEnumDescriptionsReleaseTemporaryState` | Regression for committed baseline `b903571`; successful build and cleanup leave no stale description ownership. Lifecycle/regression. |
| `Compiler/AngelscriptNativeByteInstructionTests.cpp` | `InstructionListInsertRemoveClearPreservesLinksAndTail` | Direct instruction sequence invariants across empty/one/many cases. Internal lifecycle. |
| same | `JumpResolutionTargetsExpectedInstructionAfterMutation` | Forward/backward jumps before/after insertion/removal. Interaction/invariant. |
| `Compiler/AngelscriptNativeBytecodeGenerationTests.cpp` | `BranchLoopCallAndArithmeticEmitDistinctExecutableShapes` | Inspect representative opcodes and execute each function. Internal/public correlation. |
| `Compiler/AngelscriptNativeBytecodeOptimizationTests.cpp` | `OptimizationPreservesResultControlFlowAndDebugMarkers` | Compare before/after observable result, branch targets and line markers. Transformation invariant. |
| `Compiler/AngelscriptNativeOutputBufferTests.cpp` | `OutputBufferSeparatesErrorsWarningsAndFormattedLocations` | Add/append/clear, severity counts, section and line offset. Internal/error. |
| `Compiler/AngelscriptNativeCompilerCoreTests.cpp` | `CompileBuildLookupAndExecuteUsesOneExactDeclarationPath` | Full compiler path and exact lookup. End-to-end. |
| `Compiler/AngelscriptNativeCompilerDiagnosticTests.cpp` | `CompilerRejectsSyntaxTypeAndResolutionErrorsPrecisely` | One expected diagnostic category and location per failure; recompilation succeeds after correction. Negative/recovery. |

## Runtime domain

| Final owner | Required `TEST_METHOD` | Behavioral evidence and dimensions |
| --- | --- | --- |
| `Runtime/AngelscriptNativeContextInvocationTests.cpp` | `ArgumentsObjectAndAuxiliaryDataReachPreparedFunction` | Zero through many arguments, object pointer and auxiliary pointer. Public ABI. |
| same | `ExactDeclarationPreventsWrongOverloadExecution` | Two overloads, exact declaration lookup, and deliberately ambiguous name lookup. Safety/negative. |
| `Runtime/AngelscriptNativeContextReturnValueTests.cpp` | `PrimitiveAndObjectReturnsUseTypeCorrectAccessors` | void, bool, integers, float32, float64, object/address; explicitly distinguish float/double ABI. Public ABI/boundary. |
| same | `MultipleReturnPathsPreserveDeclaredReturnType` | Branching return paths and negative values. Control-flow interaction. |
| `Runtime/AngelscriptNativeContextControlTests.cpp` | `SuspendAndResumePreserveContextState` | Real suspend result, state inspection, resume and final return. State transition. |
| same | `AbortStopsExecutionAndAllowsContextReuse` | Abort callback/loop, outcome, unprepare/prepare next function. Recovery/reuse. |
| `Runtime/AngelscriptNativeContextExceptionTests.cpp` | `ExceptionResultIncludesFunctionSectionLineAndMessage` | Divide/modulo/user exception with exact metadata. Error contract. |
| `Runtime/AngelscriptNativeContextRecoveryTests.cpp` | `ContextRecoversAfterDeepExceptionAndSignatureChange` | Reuse a context after a deep-stack exception and after switching function signatures; verify execution result and absence of stale state. Runtime recovery. |
| same | `DeepStackExceptionRetainsCallStackAndAllowsSignatureChange` | Nested calls, call-stack frames, then reuse context for a differently shaped function. Error/reuse. |
| `Runtime/AngelscriptNativeGenericCallTests.cpp` | `GenericInterfaceExposesTypedArgumentsObjectAndReturnStorage` | Real engine invokes deterministic generic callback and validates type IDs/addresses/object/auxiliary/return. Interface contract. |
| `Runtime/AngelscriptNativeScriptObjectTests.cpp` | `ConstructCopyAssignAndReleasePreservePropertiesAndRefCounts` | Construction, property address/value, copy, assignment, addref/release, weak flag. Lifecycle/ownership. |
| same | `FailedConstructionReleasesInitializedMembersInReverseOrder` | Partially constructed object throws and initialized members clean up once. Error/lifecycle. |
| `Runtime/AngelscriptNativeGarbageCollectorTests.cpp` | `CycleDetectionEnumerationAndReleaseUpdateStatistics` | One-node/two-node cycles, enumeration, detection, release and stats. Internal/public lifecycle. |
| same | `EmptyAndInvalidGcOperationsRemainStableAcrossRepeatedRuns` | Empty collect, invalid lookup, repeated collection. Boundary/reuse. |

## Module domain

| Final owner | Required `TEST_METHOD` | Behavioral evidence and dimensions |
| --- | --- | --- |
| `Module/AngelscriptNativeModuleLifecycleTests.cpp` | `CreateBuildRebuildDiscardAndRecreateUseDistinctState` | Complete lifecycle and identity changes. Public lifecycle. |
| same | `IndependentModulesKeepFunctionsTypesAndGlobalsIsolated` | Same declarations in two modules with distinct values. Isolation. |
| `Module/AngelscriptNativeModuleSectionTests.cpp` | `MultiSectionBuildPreservesOwningSectionsAndCrossReferences` | Sections, cross-calls, diagnostic ownership. Interaction. |
| same | `FailedSectionBuildPublishesNoPartialDeclarationsAndCanRecover` | Atomic failure, correction and rebuild. Error/recovery. |
| `Module/AngelscriptNativeModuleFunctionTests.cpp` | `ExactDeclarationLookupDistinguishesOverloadsAndReturnTypes` | Exact declaration returns expected identity; name lookup reports ambiguity. Lookup safety. |
| same | `FunctionArgumentsAndReturnsRoundTripAfterRebuild` | Execute before/after rebuild with changed implementation. Runtime/reuse. |
| `Module/AngelscriptNativeModuleGlobalTests.cpp` | `ConstGlobalsInitializeEnumerateResetAndDiscard` | Const-only fork semantics, address/value, reset and discard. Fork/lifecycle. |
| `Module/AngelscriptNativeModuleImportTests.cpp` | `ImportsBindExecuteUnbindAndRejectSignatureMismatch` | Two modules, bind/unbind, execution, mismatched declaration. Interaction/error. |
| `Module/AngelscriptNativeModuleNamespaceTests.cpp` | `NestedNamespacesResolveQualifiedAndUnqualifiedDeclarations` | Type/function/global lookup and collision behavior. Resolution. |
| `Module/AngelscriptNativeModuleStateTableTests.cpp` | `TopLevelTablesReflectSuccessfulBuildAndClearOnRebuild` | Internal table contents correlate with public lookup; rebuild clears old entries. Internal/public invariant. |
| `Module/AngelscriptNativeModuleSaveLoadTests.cpp` | `BytecodeRoundTripPreservesDeclarationsMetadataAndExecution` | One stream, functions/types/globals, optional debug strip, load and execute. Serialization/runtime. |
| same | `TruncatedAndCorruptStreamsFailWithoutPoisoningNextLoad` | Short/corrupt inputs fail, module remains recoverable, complete stream then loads. Error/recovery. |
| `Module/AngelscriptNativeRestorePrimitiveTests.cpp` | `RestoreRoundTripsPrimitiveStateAndReferenceIdentity` | Primitive/register/reference restore covered only where current API exposes it. Current contract. |

## TypeSystem domain

| Final owner | Required `TEST_METHOD` | Behavioral evidence and dimensions |
| --- | --- | --- |
| `TypeSystem/AngelscriptNativeDataTypeTests.cpp` | `PrimitiveObjectHandleReferenceAndConstFlagsRoundTrip` | Creation, equality variants, declaration rendering, size/alignment. Internal/public correlation. |
| same | `InvalidAndNullTypesRemainDistinctFromTypedHandles` | Null/unknown/boundary type IDs and comparison behavior. Negative/boundary. |
| `TypeSystem/AngelscriptNativeConfigGroupTests.cpp` | `BeginEndRemovalAndNestedErrorsPreserveOwnership` | Group lifecycle, owned types/functions/properties, removal and invalid nesting. Lifecycle/error. |
| `TypeSystem/AngelscriptNativeGlobalPropertyTests.cpp` | `RegisteredScalarPropertiesReadWriteAndRetainAddresses` | integer/float/bool, multiple globals, read-modify-write, pointer identity. Public runtime. |
| `TypeSystem/AngelscriptNativeVariableScopeTests.cpp` | `NestedLoopAndBranchScopesResolveAndDiscardVariables` | Shadowing, for initializer, while/if blocks, leak rejection. Resolution/lifecycle. |
| `TypeSystem/AngelscriptNativeTypeInfoTests.cpp` | `TypeIdentityNamespaceFlagsBaseAndSubtypeMetadataMatchRuntime` | Public `asITypeInfo` families and script execution correlation. Contract/runtime. |
| `TypeSystem/AngelscriptNativeObjectTypeTests.cpp` | `PropertiesMethodsBehaviorsAndInheritanceRemainQueryable` | Enumeration, declaration, offsets, methods, behaviors, base relation and user data. Contract. |
| `TypeSystem/AngelscriptNativeEnumTypeTests.cpp` | `EnumNamesValuesUnderlyingTypeAndBytecodeRoundTrip` | Negative/explicit values, lookup and saved module. Metadata/serialization. |
| `TypeSystem/AngelscriptNativeTypedefTypeTests.cpp` | `TypedefIdentityDeclarationAndBytecodeRoundTripRemainStable` | Alias metadata versus underlying type and load. Metadata/serialization. |
| `TypeSystem/AngelscriptNativeFuncdefTypeTests.cpp` | `FuncdefSignaturesDelegatesAndReferenceCountsRemainStable` | Parameters, return, namespace/module, delegate target, addref/release. Contract/lifecycle. |
| `TypeSystem/AngelscriptNativeScriptFunctionTests.cpp` | `FunctionMetadataCoversParametersTraitsImportsDelegatesAndUserData` | Every applicable public method family and cleanup callback. Public API depth. |
| `TypeSystem/AngelscriptNativeDefaultTraitTests.cpp` | `DefaultTraitsMatchConstructionCopyAndDestructionBehavior` | Trait flags correlate with executable lifecycle, not flags alone. Metadata/runtime. |

## Embedding domain

| Final owner | Required `TEST_METHOD` | Behavioral evidence and dimensions |
| --- | --- | --- |
| `Embedding/AngelscriptNativeGlobalRegistrationTests.cpp` | `RegisteredFunctionsAndPropertiesResolveByExactDeclarationAndExecute` | Successful registration, duplicate/malformed rejection, execution and address identity. Public host contract. |
| `Embedding/AngelscriptNativeGlobalCallbackTests.cpp` | `GlobalCallbacksMarshalPrimitiveAndFloatingPointArguments` | Register host callbacks, invoke them from script statements and prepared contexts, and verify callback execution, cleanup, mixed-width argument and floating-point marshalling. Host/runtime boundary. |
| `Embedding/AngelscriptNativeObjectRegistrationTests.cpp` | `ObjectTypesPropertiesMethodsBehaviorsAndFactoriesExecute` | Value/reference types, constructor/factory, method/property, addref/release, invalid flags/signatures. Host/runtime/lifecycle. |
| `Embedding/AngelscriptNativeCallingConventionTests.cpp` | `ActiveCdeclGenericAndThiscallPathsMarshalRepresentativeSignatures` | Execute active supported paths with primitive/object/multiple arguments and return values; unsupported combinations get exact registration errors. ABI/error. |
| `Embedding/AngelscriptNativeCallFunctionTests.cpp` | `ActiveWin64BackendHandlesWideReturnsOutParametersAndNestedCalls` | Execute active backend for wide return, many args, bool, out parameter, nested call and float precision. Platform classification/runtime. |
| `Embedding/AngelscriptNativeInterfaceContractTests.cpp` | `EngineModuleContextTypeAndFunctionInterfacesHonorUserDataCleanup` | Set/get user data for each applicable interface, replace values, release owner, and assert cleanup callback exactly once. Contract/lifecycle. |
| `Embedding/AngelscriptNativeGenericInterfaceTests.cpp` | `GenericCallbackReceivesDeclaredTypesAddressesAndReturnStorage` | Real engine invokes host callback; no compile-only test double claim. Contract/runtime. |
| `Embedding/AngelscriptNativeStringFactoryTests.cpp` | `StringFactoryDeduplicatesConstantsAndBalancesAcquireRelease` | Duplicate identity, raw data length/copy, release count, invalid request. Contract/lifecycle. |
| `Embedding/AngelscriptNativeJITCompilerTests.cpp` | `JitCompileAssignClearAndReleaseCallbacksFollowFunctionLifetime` | Real engine calls deterministic JIT double and clears/release exactly once. Contract/lifecycle. |
| `Embedding/AngelscriptNativeThreadManagerContractTests.cpp` | `ThreadManagerInstallationLookupAndWorkerPreparationRemainBalanced` | Test-owned manager only where safely installable; otherwise observe production manager and exercise worker preparation without global teardown. Global safety. |

## Conformance domain

| Final owner | Required `TEST_METHOD` | Behavioral evidence and dimensions |
| --- | --- | --- |
| `Conformance/AngelscriptNativeGlobalSemanticsTests.cpp` | `ConstGlobalInitializesAndMutableGlobalReportsForkDiagnostic` | One active success and one exact fork rejection. Fork classification. |
| `Conformance/AngelscriptNativeReferenceSemanticsTests.cpp` | `AutomaticReferencesNullAndIdentityFollowForkRules` | Assignment, parameter, return, null and identity execute. Fork runtime. |
| same | `ExplicitHandleSyntaxReportsForkDiagnostic` | Exact current rejection; no alternative success path. Fork negative. |
| `Conformance/AngelscriptNativeInterfaceSemanticsTests.cpp` | `ScriptInterfaceDeclarationReportsForkDiagnostic` | Exact current rejection and no leaked type/module state. Fork negative/cleanup. |
| `Conformance/AngelscriptNativeMixinSemanticsTests.cpp` | `MixinGlobalFunctionExecutesAndMixinClassReportsForkDiagnostic` | Supported and unsupported forms are separate assertions. Fork classification. |
| `Conformance/AngelscriptNativeUsingNamespace238Tests.cpp` | `UsingDirectiveResolvesTypeAndFunction` | Disabled/tagged future target; compiles and executes desired namespace resolution when enabled. Future238. |
| `Conformance/AngelscriptNativeMemberInitialization238Tests.cpp` | `ConstructorMemberInitializerEvaluatesInDeclarationOrder` | Disabled/tagged future target with observable member values. Future238. |
| `Conformance/AngelscriptNativeDefaultSpecialMembers238Tests.cpp` | `GeneratedDefaultAndCopyMembersPreserveValues` | Disabled/tagged future target. Future238. |
| same | `DeletedDefaultOrCopyMemberRejectsTheMatchingUse` | Disabled/tagged future negative target with one diagnostic category. Future238. |
| `Conformance/AngelscriptNativeBoolContext238Tests.cpp` | `BoolContextSelectsBranchAndLoopConditions` | Disabled/tagged future execution. Future238. |
| `Conformance/AngelscriptNativeLambda238Tests.cpp` | `AnonymousFunctionCompilesInvokesAndReturnsValue` | Disabled/tagged executable semantic target; distinct from active parser-shape coverage. Future238. |
| `Conformance/AngelscriptNativeVariadicFunction238Tests.cpp` | `VariadicFunctionAcceptsZeroAndMultipleTrailingArguments` | Disabled/tagged future execution. Future238. |
| `Conformance/AngelscriptNativeTemplateFunction238Tests.cpp` | `TemplateFunctionInstantiatesForTwoPrimitiveTypes` | Disabled/tagged future resolution/execution. Future238. |

## Language domain

The Language domain is organized into the fourteen core themes below. All language owners are under `AngelScriptSDK/Language/` unless stated otherwise. Fixtures use only core language plus minimal locally registered host types; they do not include or register an add-on package.

`Language/AngelscriptNativeSemanticRejectionTests.cpp` retains the negative semantic contract: incompatible object assignment, out-of-scope reference, unresolved call, incompatible return, and long identifier assignment must report stable owning diagnostics without crashing.

### Declarations

Required methods:

- `PrimitiveEnumTypedefFuncdefClassAndFunctionDeclarationsPublishMetadata`
- `ForwardDeclarationsResolveAcrossOrderedSections`
- `NamespacesSharedAndExternalDeclarationsResolveExactOwners`
- `DuplicateDeclarationsRejectWithoutPartialPublication`
- `MalformedDeclarationReportsOwningTokenAndRecoversNextDeclaration`
- `DeclarationMetadataSurvivesModuleSaveLoad`

Depth: grammar forms, symbol publication, namespace/module interaction, duplicate and malformed input, source location, cleanup after failure, serialization.

### Functions

Required methods:

- `FunctionsExecuteParametersAndReturnValues`
- `OverloadsResolveByExactArgumentTypes`
- `DefaultArgumentsApplyAtImplicitAndExplicitCallSites`
- `RecursionPreservesFramesAndReturnsExpectedValue`
- `FuncdefAndDelegateInvocationPreserveSignature`
- `MixinGlobalFunctionResolvesInOwningNamespace`
- `UnknownAndAmbiguousCallsReportOneResolutionDiagnostic`
- `FunctionMetadataMatchesExecutableDeclaration`

Depth: declaration, overload resolution, default arguments, recursion, indirect call, namespace/mixin interaction, metadata/runtime agreement, negative resolution.

### Variables

Required methods:

- `LocalVariablesInitializeAssignAndReadAcrossPrimitiveTypes`
- `ShadowedVariablesResolveToNearestScope`
- `LoopAndBranchLocalsExpireAtBlockExit`
- `ConstGlobalInitializesOnceAndRemainsReadable`
- `MutableGlobalDeclarationReportsForkDiagnostic`
- `FailedInitializerPublishesNoGlobalAndCanRebuild`
- `VariableLifetimeInvokesConstructionAndDestructionOnce`

Depth: local/global, inference/`auto`, initialization, assignment, shadowing, scope exit, fork restriction, failure atomicity, lifecycle.

### Properties

Required methods:

- `ClassFieldsInitializeReadWriteAndRetainIndependentInstanceState`
- `InheritedFieldsPreserveBaseAndDerivedLayoutBehavior`
- `VirtualPropertyGetterAndSetterExecuteObservableSideEffects`
- `IndexedPropertySelectsGetterAndSetterByArgumentType`
- `ConstPropertyAccessRejectsMutation`
- `MissingAmbiguousAndMismatchedAccessorsReportExactDiagnostics`
- `PropertyValuesSurviveCopyAssignmentAndModuleExecution`

Depth: storage, initialization, inheritance, virtual/indexed access, constness, overload resolution, side effects, copy interaction, negative diagnostics.

### Constructors

Required methods:

- `DefaultConstructorInitializesFieldsBeforeFirstUse`
- `ParameterizedConstructorSelectsExactOverload`
- `CopyConstructorAndAssignmentPreserveIndependentValues`
- `ExplicitConstructorAllowsDirectAndRejectsImplicitConversion`
- `BaseConstructorRunsBeforeDerivedConstructor`
- `PrivateAndProtectedConstructorsEnforceAccessRules`
- `MissingOrDeletedConstructorReportsExactDiagnostic`
- `ThrowingConstructorCleansAlreadyInitializedMembers`

Depth: default/parameter/copy, overload, explicitness, inheritance order, access, deleted/missing behavior, partial construction cleanup.

### Destructors

Required methods:

- `BlockExitRunsDestructorExactlyOnce`
- `FunctionReturnRunsLocalsInReverseConstructionOrder`
- `ExceptionUnwindRunsInitializedDestructorsOnly`
- `DerivedDestructorRunsBeforeBaseDestructor`
- `TemporaryAndAssignedValuesDoNotDoubleDestroy`
- `ModuleDiscardReleasesRemainingScriptObjects`

Depth: normal exit, early return, exception, inheritance order, temporary/copy interaction, module teardown, exact counts.

### Inheritance

Required methods:

- `DerivedConstructionInitializesBaseThenDerivedState`
- `VirtualDispatchInvokesMostDerivedOverride`
- `ExplicitBaseCallBypassesOverride`
- `AbstractClassRejectsInstantiationUntilImplemented`
- `FinalClassAndFinalMethodRejectFurtherOverride`
- `InheritedPropertiesAndMethodsRemainQueryableAndExecutable`
- `InvalidBaseOrCycleReportsExactDiagnosticWithoutPublishedType`

Depth: construction, override, dispatch, base call, abstract/final, metadata/runtime, invalid graph cleanup.

### References

Required methods:

- `InOutAndInOutReferencesPropagateExpectedMutations`
- `ConstInputReferenceRejectsMutation`
- `ReturnedReferencePreservesAliasingWhileOwnerLives`
- `AutomaticObjectReferenceSupportsNullAndIdentityChecks`
- `ReferenceOverloadResolutionUsesConstAndDirectionQualifiers`
- `OutOfScopeOrTemporaryReferenceReportsExactDiagnostic`
- `ExplicitHandleSyntaxReportsForkDiagnostic`

Depth: directions, constness, aliasing, owner lifetime, null/identity, overload resolution, invalid lifetime, fork syntax.

### Expressions

Required methods:

- `ArithmeticComparisonLogicalAndBitExpressionsReturnExpectedValues`
- `PrecedenceAndParenthesesSelectExpectedEvaluationTree`
- `TernaryEvaluatesOnlySelectedBranch`
- `CallMemberIndexAndCastExpressionsCompose`
- `ShortCircuitSkipsUnreachedSideEffects`
- `InvalidLvalueAndTypeCombinationReportExactDiagnostics`
- `ExpressionBytecodeAndRuntimeResultAgree`

Depth: operator families, precedence, lazy evaluation, composed expression forms, side effects, invalid operands/lvalues, compiler/runtime correlation.

### Operators

Required methods:

- `BuiltinUnaryBinaryAndCompoundOperatorsReturnExpectedValues`
- `PrefixAndPostfixOperatorsExposeDifferentResults`
- `OverloadedOperatorDispatchesToDeclaredMethod`
- `OperatorOverloadResolutionSelectsExactTypes`
- `AmbiguousOrMissingOperatorReportsExactDiagnostic`
- `OperatorEvaluationOrderPreservesSideEffects`
- `OperatorResultParticipatesInConversionAndControlFlow`

Depth: built-ins, mutation, overload dispatch/resolution, ambiguity, evaluation order, conversion/control interaction.

### Conversions

Required methods:

- `IntegerWidthSignAndBoundaryConversionsMatchForkRules`
- `Float32AndFloat64ConversionsTruncateAndReturnThroughCorrectAbi`
- `BoolConversionsFollowCurrentExplicitAndContextRules`
- `ExplicitCastSelectsTargetTypeAndRuntimeValue`
- `ObjectConversionAndConstructorConversionResolveWithoutAmbiguity`
- `NarrowingOverflowOrInvalidConversionReportsExactBehavior`
- `ConversionParticipatesInOverloadAndOperatorResolution`

Depth: primitive widths, sign, float ABI, bool rules, explicit/object conversion, boundary/error, overload/operator interaction.

### ControlFlow

Required methods:

- `IfElseSelectsExpectedBranch`
- `WhileDoWhileAndForProduceExpectedIterations`
- `SwitchSelectsCaseDefaultAndFallthroughBehavior`
- `NestedBreakAndContinueTargetOwningLoop`
- `ReturnExitsNestedControlFlowWithExpectedValue`
- `ShortCircuitConditionsSkipUnreachedEffects`
- `InvalidBreakContinueOrReturnReportsExactDiagnostic`
- `CompiledBranchesContainValidForwardAndBackwardTargets`

Depth: all statement families, nested targeting, return, lazy conditions, invalid placement, bytecode/runtime agreement.

### Foreach

Required methods:

- `ForeachVisitsValuesInSourceOrder`
- `ForeachReferenceVariableMutatesUnderlyingValues`
- `ForeachBreakAndContinueSelectExpectedElements`
- `ForeachOverEmptyInputExecutesNoBody`
- `ForeachIteratorLifetimeEndsOnNormalReturnAndException`
- `ForeachInteractsWithNestedLoopAndFunctionReturn`
- `InvalidIterableOrVariableShapeReportsExactDiagnostic`

Depth: order, value/reference variables, mutation, empty boundary, break/continue, lifecycle, exception/return interaction, invalid protocol. Use a minimal core iterator protocol fixture, not an add-on container.

### Exceptions

Required methods:

- `ThrowAndCatchSelectMatchingHandler`
- `NestedTryCatchPropagatesToNearestMatchingHandler`
- `RethrowPreservesExceptionMessageAndOrigin`
- `ExceptionUnwindRunsDestructorsInReverseOrder`
- `UnhandledExceptionReturnsContextMetadataAndCallStack`
- `ContextCanBeReusedAfterCaughtAndUncaughtExceptions`
- `ExceptionInteractsWithForeachReturnAndNestedCalls`
- `MalformedTryCatchReportsExactDiagnostic`

Depth: throw/catch/rethrow, propagation, metadata, cleanup, context reuse, interactions, syntax failure.

## Cross-theme interaction gate

The following interactions cannot be waived by completing each theme independently:

| Interaction | Required proof |
| --- | --- |
| constructor + property + inheritance | Base and derived property initializers and constructors run in recorded order and virtual/property access observes final values. |
| constructor/destructor + exception | Partial construction and stack unwind destroy exactly the initialized objects in reverse order. |
| reference + overload + conversion | Const/direction qualifiers and conversions select one exact overload; ambiguous case reports one diagnostic. |
| operator + expression + control flow | Overloaded result participates in comparison/branching and short-circuit prevents side effects. |
| namespace + shared/external + module import | Identity and resolution remain correct across modules, bind/unbind, and rebuild. |
| type metadata + bytecode save/load + execution | Loaded declarations retain metadata and execute the same observable result. |
| context exception + suspend/abort + reuse | Each non-finished outcome is distinct and the context becomes reusable only after correct cleanup. |
| GC + script-object references + module discard | Cycles are collected and remaining objects release once when their module/engine owner ends. |

## Scenario quality audit

The complete-phase audit SHALL reject:

- a listed method with no final source owner;
- a method whose only assertion is compile success when runtime/state evidence is required above;
- a method that loops unrelated subjects and reports only an aggregate count;
- a method name containing a conditional-support, generic compatibility, process-phase, or table-oriented placeholder;
- a diagnostic check that accepts mutually exclusive categories;
- an ignored helper result;
- a future test that is not compiled Disabled and tagged;
- an add-on include, registration, or data type used to satisfy core-language coverage;
- a topic whose applicable dimension has neither a named method nor a specific non-applicability rationale.
