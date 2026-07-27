# AngelScriptSDK fixture and large-file quality review

Date: 2026-07-27

This began as a static, per-file audit of 232 `AngelScriptSDK/**/*.cpp` files
against `Documents/UnitTest/UnitTest.md`. The historical findings and repair
order remain below. The living CSV has now been reconciled against every
current source path and tracks 263 physical source owners after completed
semantic splits and concurrent source additions. This record makes a static
source-shape claim only; it does not make a build or runtime-test claim.

The reconciliation removed the retired
`Support/AngelscriptNativePublicInterfaceContractTests.cpp` row and added five
current source owners:

- `Compiler/AngelscriptNativeCompilerInternalLifecycleTests.cpp`
- `Compiler/AngelscriptNativeCompilerTemplateCovarianceTests.cpp`
- `Runtime/AngelscriptNativeScriptFunctionReferenceTests.cpp`
- `TypeSystem/AngelscriptNativeObjectTypeReleaseTests.cpp`
- `TypeSystem/AngelscriptNativePrimitiveTypeIdRoundTripTests.cpp`

The parser semantic-owner split retains five parser products in
`Frontend/AngelscriptNativeParserCartesianDepthTests.cpp` and adds focused
ScriptNode, ScriptCode-position, and parser-source-recovery owners. All four
resulting files are below the review threshold, preserve the nine registered
class/method/Automation identities, and share only the three parser
lifecycle/link helpers in
`Support/AngelscriptNativeParserDepthTestSupport.h`.

The tokenizer semantic-owner split replaces the former mixed aggregate with
keyword/identifier, operator, numeric, text/comment/whitespace/EOF, and
published-definition owners. All five files are below the review threshold,
preserve the twelve registered methods, products, generated case/source
identities, and Automation leaf IDs, and share only the four raw-tokenizer
mechanics in `Support/AngelscriptNativeTokenizerTestSupport.h`.

The expression-evaluation semantic-owner split replaces the former mixed
aggregate with focused lazy reachability and eager order owners. Both files
are below the review threshold, preserve the two registered methods, products,
612 generated case/source identities, opposite execution oracles, and
case-owned engine/context/module cleanup. They share only the recorder and
four native callback registrations in
`Support/AngelscriptNativeExpressionEvaluationTestSupport.h`.

The reference-direction semantic-owner split retains all 96 positive
direction/null-state/alias-relation cells in the original owner and gives the
single current-fork mutable-global rejection its own diagnostic owner. Both
files are below the review threshold, preserve the two registered methods,
all 97 generated source reports, and independent case-owned engine/module
cleanup without adding a shared support surface.

The mergeable row set is `handoffs/fixture-and-large-file-quality-review.csv`; it contains exactly the requested columns: `File`, `LifecycleDisposition`, `LifecycleEvidence`, `LargeFileDisposition`, `Rationale`, and `RequiredAction`.

## Summary

### Raw engine/module/context lifecycle

| Disposition | Files |
| --- | ---: |
| `CompliantCaseOwned` | 231 |
| `CompliantCaseOwnedDirectEngine` | 9 |
| `CompliantClassOwnedImmutableRegistration` | 8 |
| `CompliantNoRawEngineFixture` | 22 |
| `CompliantPerCaseRecreationHooks` | 1 |

No current row has a lifecycle `ChangeRequired` disposition. The 12 missing
Destroy findings and the 100 unjustified shared fixtures were repaired in the
domain handoffs named by each CSV row. Current source verification checks the
actual file path, `TEST_METHOD` count, raw-engine Create/Destroy call sites,
class-owned engine declarations, and `BEFORE_ALL` / `BEFORE_EACH` /
`AFTER_ALL` shape.

Two former no-engine classifications changed from direct source evidence:
`Frontend/AngelscriptNativeParserDiagnosticTests.cpp` now creates a direct
case-owned raw engine inside its diagnostic helper, while
`Frontend/AngelscriptNativeTokenizerCoreTests.cpp` now owns a method-local
`FNativeTestEngine`. Reporting 19 no-engine files would therefore contradict
the current source.

`FNativeTestEngine::Reset()` still changes only the current test pointer,
failure flag, messages, and optional buffered output. It does not recreate the
engine, clear registrations, or discard modules. The eight retained
class-owned exceptions have an independently reviewed immutable registration
contract; the separate recreation-hook exception destroys and recreates its
engine before each case.

All reviewed raw `CreateContext()` paths have an explicit release path or a
scoped context owner. No current context-only lifecycle action was identified.

### Files over 1000 lines

| Disposition | Files |
| --- | ---: |
| `NotLarge` | 228 |
| `RetainCohesiveGeneratorOrOwner` | 43 |
| `SplitRequiredMixedResponsibilities` | 0 |

There are 43 files over 1000 lines, and all 43 remain cohesive generated owners. No current semantic split is required. Line count alone was never used as the failure criterion. The Builder Application finding is closed by four physical subject owners, each below the review threshold and carrying only its matching compatibility method(s). The four Operator findings are closed by fourteen physical subject owners; each contains one product method while retaining its exact product-specific generated flow and helper graph. The Builder Dependency finding is closed by separate module-dependency and cross-section-publication owners, both below the review threshold; their complete product and compatibility methods retain case-owned engine teardown, while only the six genuinely shared builder pipeline/logging helpers moved to `Support/`. The Compiler Cartesian Depth finding is closed by retaining the coupled builder rejection/recovery protocol and moving bytecode shape, raw mutation, and optimization into three focused files; all four files are below 1000 lines, and the only newly shared helper surface is the unity-safe opcode scanner. The Parser Cartesian Depth finding is closed by retaining the five parser declaration/expression owners and moving ScriptNode copy/traversal, value-owned ScriptCode positions, and source recovery into three focused files; only parser parse/release/sibling-link helpers are shared. The Tokenizer Deep finding is closed by five family owners below 1000 lines; only token observation and generated-comment mechanics are shared. The Expression Evaluation finding is closed by separate lazy reachability and eager order owners below 1000 lines; only recorder/native-callback instrumentation is shared. The Reference Direction finding is closed by retaining the 96 positive cells in the original owner and moving the one current-fork mutable-global rejection into its own owner; no support surface changed. The Reference Identity finding is closed by retaining the 288 positive source/operation/qualifier cells in the original owner and moving the one current-fork derived-input rejection into its own owner; the existing reference support surface remains unchanged. The Variable Lifetime finding is closed by separate ordinary exit/nesting and counted-reference assignment owners below 1000 lines; the three stateless class-private query helpers remain local to both unique classes and no shared support surface changed. The Module API Contract finding is closed by eight one-product owners below 1,000 lines; both source-print overloads remain class-private in every unique owner, and no shared support surface changed.

## Historical lifecycle findings and completed repairs

### Historical missing case-local engine destruction (12, repaired)

The initial audit identified these direct leak/early-return risks because
`FNativeTestEngine` has no destructor that calls `Destroy()`. The repairs are
recorded in `handoffs/missing-engine-destroy-repair.md`; current source has the
required guards or paired multi-engine cleanup, and the CSV rows now report
`CompliantCaseOwned`. The original findings are retained below as history.

- `Language/AngelscriptNativeConversionsTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=5, CreateCalls=5, explicit Engine.Destroy calls=0.
- `Language/AngelscriptNativeFunctionsTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=4, CreateCalls=4, explicit Engine.Destroy calls=1.
- `Language/AngelscriptNativeReferencesTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=3, CreateCalls=3, explicit Engine.Destroy calls=0.
- `Language/Expressions/AngelscriptNativeExpressionValueCategoryTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=1, CreateCalls=1, explicit Engine.Destroy calls=0.
- `Language/Expressions/AngelscriptNativePrimaryExpressionTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=1, CreateCalls=1, explicit Engine.Destroy calls=0.
- `Language/References/AngelscriptNativeReferenceDirectionTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=2, CreateCalls=2, explicit Engine.Destroy calls=0.
- `Language/References/AngelscriptNativeReferenceFailureTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=1, CreateCalls=1, explicit Engine.Destroy calls=0.
- `Language/References/AngelscriptNativeReferenceIdentityTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=2, CreateCalls=2, explicit Engine.Destroy calls=0.
- `Language/References/AngelscriptNativeReferenceLifetimeTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=3, CreateCalls=3, explicit Engine.Destroy calls=0.
- `Language/References/AngelscriptNativeReferenceResolutionTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=1, CreateCalls=1, explicit Engine.Destroy calls=0.
- `Module/AngelscriptNativeRestorePrimitiveTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=8, CreateCalls=8, explicit Engine.Destroy calls=2.
- `TypeSystem/AngelscriptNativeDataTypeTests.cpp` — Case-local FNativeTestEngine is created, but at least one TEST_METHOD has no Engine.Destroy scope guard; FNativeTestEngine has no destructor-owned shutdown. LocalEngines=2, CreateCalls=2, explicit Engine.Destroy calls=1.

### Historical unjustified class-owned raw engines

The initial repair scope contained 100 shared fixtures. This pre-split list
contains 98 file owners; subsequent subject splits changed the physical owner
set, and 97 stale `ChangeRequiredClassOwnedMutableOrUnjustified` rows remained
in the living CSV immediately before this reconciliation.

These files originally had a static/class-owned raw engine without a reviewed
immutable registration contract. The Compiler, Frontend, Language,
Runtime/Module, and Engine/TypeSystem/Embedding repair handoffs record their
conversion. Current source has no such mutable class-owned fixture or lifecycle
hook in these owners. The original affected-file list is retained below.

#### Compiler

- `Compiler/AngelscriptNativeBuilderApplicationTests.cpp`
- `Compiler/AngelscriptNativeBuilderBytecodeTests.cpp`
- `Compiler/AngelscriptNativeBuilderDeclarationTests.cpp`
- `Compiler/AngelscriptNativeBuilderDiagnosticTests.cpp`
- `Compiler/AngelscriptNativeBuilderEditorOnlyTests.cpp`
- `Compiler/AngelscriptNativeBuilderFunctionTests.cpp`
- `Compiler/AngelscriptNativeBuilderGlobalTests.cpp`
- `Compiler/AngelscriptNativeBuilderLayoutTests.cpp`
- `Compiler/AngelscriptNativeBuilderLifecycleTests.cpp`
- `Compiler/AngelscriptNativeBuilderNamespaceTests.cpp`
- `Compiler/AngelscriptNativeBuilderParsingTests.cpp`
- `Compiler/AngelscriptNativeBuilderPropertyTests.cpp`
- `Compiler/AngelscriptNativeBuilderTypeTests.cpp`
- `Compiler/AngelscriptNativeOutputBufferTests.cpp`

#### Embedding

- `Embedding/AngelscriptNativeJitCompilerTests.cpp`

#### Engine

- `Engine/AngelscriptNativeEngineMessageCallbackTests.cpp`
- `Engine/AngelscriptNativeEnginePropertyIsolationTests.cpp`
- `Engine/AngelscriptNativeEnginePropertyProfileTests.cpp`

#### Frontend

- `Frontend/AngelscriptNativeParserCartesianDepthTests.cpp`
- `Frontend/AngelscriptNativeParserCoreTests.cpp`
- `Frontend/AngelscriptNativeParserDeclarationsTests.cpp`
- `Frontend/AngelscriptNativeParserErrorsTests.cpp`
- `Frontend/AngelscriptNativeParserExpressionsTests.cpp`
- `Frontend/AngelscriptNativeParserInternalTests.cpp`
- `Frontend/AngelscriptNativeScriptNodeCopyTests.cpp`
- `Frontend/AngelscriptNativeScriptNodeCoreTests.cpp`
- `Frontend/AngelscriptNativeScriptNodeOwnershipDepthTests.cpp`
- `Frontend/AngelscriptNativeScriptNodeShapeTests.cpp`
- `Frontend/AngelscriptNativeScriptNodeSourceRangeTests.cpp`

#### Language

- `Language/ControlFlow/AngelscriptNativeBranchConditionDepthTests.cpp`
- `Language/ControlFlow/AngelscriptNativeConditionTests.cpp`
- `Language/ControlFlow/AngelscriptNativeControlFlowLifetimeDepthTests.cpp`
- `Language/ControlFlow/AngelscriptNativeForClauseTests.cpp`
- `Language/ControlFlow/AngelscriptNativeLoopConditionTransferDepthTests.cpp`
- `Language/ControlFlow/AngelscriptNativeLoopDepthTests.cpp`
- `Language/ControlFlow/AngelscriptNativeNestedTargetTests.cpp`
- `Language/ControlFlow/AngelscriptNativeStatementTransferTests.cpp`
- `Language/ControlFlow/AngelscriptNativeSwitchPlacementTests.cpp`
- `Language/ControlFlow/AngelscriptNativeSwitchTests.cpp`
- `Language/ControlFlow/AngelscriptNativeTransferValidityTests.cpp`
- `Language/Conversions/AngelscriptNativeBoolConversionTests.cpp`
- `Language/Conversions/AngelscriptNativeConversionFailureTests.cpp`
- `Language/Conversions/AngelscriptNativeConversionResolutionTests.cpp`
- `Language/Conversions/AngelscriptNativeEnumAliasConversionTests.cpp`
- `Language/Conversions/AngelscriptNativeNumericBoundaryConversionTests.cpp`
- `Language/Conversions/AngelscriptNativeNumericConversionTests.cpp`
- `Language/Conversions/AngelscriptNativeObjectCastTests.cpp`
- `Language/Conversions/AngelscriptNativeValueObjectConversionTests.cpp`
- `Language/Declarations/AngelscriptNativeDeclarationCollisionTests.cpp`
- `Language/Declarations/AngelscriptNativeDeclarationFailureRecoveryTests.cpp`
- `Language/Declarations/AngelscriptNativeDeclarationPublicationTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionHandlingRejectionTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionMetadataTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionOriginTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionRecoveryTests.cpp`
- `Language/Foreach/AngelscriptNativeForeachIterationTests.cpp`
- `Language/Foreach/AngelscriptNativeForeachProtocolTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionArgumentSourceTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionArityTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionArityTypeStressTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionDefaultArgumentTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionDirectionDefaultTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionOverloadResolutionTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionParameterDirectionTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionParameterPositionTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionRecursionTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionReturnTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionSignatureShapeTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionTypedDefaultArgumentTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionValueLifecycleTests.cpp`
- `Language/Operators/AngelscriptNativePowerOperatorTests.cpp`

#### Module

- `Module/AngelscriptNativeModuleCompileFunctionTests.cpp`
- `Module/AngelscriptNativeModuleImportUnbindAllTests.cpp`
- `Module/AngelscriptNativeModuleNestedImportVisibilityTests.cpp`
- `Module/AngelscriptNativeModulePreClassMetadataTests.cpp`
- `Module/AngelscriptNativeModuleRemoveFunctionTests.cpp`
- `Module/AngelscriptNativeModuleRenameReindexTests.cpp`
- `Module/AngelscriptNativeModuleTypedefInventoryTests.cpp`
- `Module/AngelscriptNativeModuleUserDataLifecycleTests.cpp`
- `Module/AngelscriptNativeModuleBuildFailureTests.cpp`
- `Module/AngelscriptNativeModuleFunctionTests.cpp`
- `Module/AngelscriptNativeModuleImportTests.cpp`
- `Module/AngelscriptNativeModuleLifecycleTests.cpp`
- `Module/AngelscriptNativeModuleNamespaceTests.cpp`
- `Module/AngelscriptNativeModuleSectionTests.cpp`
- `Module/AngelscriptNativeModuleStateTableTests.cpp`

#### Runtime

- `Runtime/AngelscriptNativeContextAccessorDepthTests.cpp`
- `Runtime/AngelscriptNativeScriptObjectLifecycleDepthTests.cpp`
- `Runtime/Debug/AngelscriptNativeCallbackLifecycleTests.cpp`
- `Runtime/Debug/AngelscriptNativeCallstackTests.cpp`
- `Runtime/Debug/AngelscriptNativeExceptionCaughtQueryTests.cpp`
- `Runtime/Debug/AngelscriptNativeFunctionDebugMetadataTests.cpp`
- `Runtime/Debug/AngelscriptNativeInstructionPhaseDepthTests.cpp`
- `Runtime/Debug/AngelscriptNativeLineCallbackSourceTests.cpp`
- `Runtime/Debug/AngelscriptNativeLocalVariableTests.cpp`
- `Runtime/Debug/AngelscriptNativeNestedContextDepthTests.cpp`
- `Runtime/Debug/AngelscriptNativeNestedContextTests.cpp`
- `Runtime/Debug/AngelscriptNativeStackPopCallbackDepthTests.cpp`
- `Runtime/Debug/AngelscriptNativeThisPointerTests.cpp`

#### TypeSystem

- `TypeSystem/AngelscriptNativeConfigGroupTests.cpp`
- `TypeSystem/AngelscriptNativeDataTypeQualifierCartesianTests.cpp`
- `TypeSystem/AngelscriptNativeDefaultTraitTests.cpp`
- `TypeSystem/AngelscriptNativeTypeInfoShadowSystemTypeTests.cpp`
- `TypeSystem/AngelscriptNativeVariableScopeTests.cpp`

## Class-owned exceptions accepted by the rule

These eight files register a stable type/function/property contract once in `BEFORE_ALL`, have complete public create/destroy hooks, and keep mutable observations/modules/contexts per method:

- `Embedding/AngelscriptNativeCallingConventionTests.cpp` — Public BEFORE_ALL creates the engine and installs a stable registration/type/property contract once; public AFTER_ALL destroys it and clears stored IDs/state. Tests=4, custom registration references=7.
- `Embedding/AngelscriptNativeGenericInterfaceDepthTests.cpp` — Public BEFORE_ALL creates the engine and installs a stable registration/type/property contract once; public AFTER_ALL destroys it and clears stored IDs/state. Tests=2, custom registration references=8.
- `Engine/AngelscriptNativeEngineGcCleanupServiceTests.cpp` — Public BEFORE_ALL creates the engine and installs a stable registration/type/property contract once; public AFTER_ALL destroys it and clears stored IDs/state. Tests=4, custom registration references=4.
- `Engine/AngelscriptNativeEngineInventoryDepthTests.cpp` — Public BEFORE_ALL creates the engine and installs a stable registration/type/property contract once; public AFTER_ALL destroys it and clears stored IDs/state. Tests=5, custom registration references=6.
- `Engine/AngelscriptNativeEngineObjectServiceTests.cpp` — Public BEFORE_ALL creates the engine and installs a stable registration/type/property contract once; public AFTER_ALL destroys it and clears stored IDs/state. Tests=2, custom registration references=9.
- `Language/Foreach/AngelscriptNativeForeachTransferLifetimeTests.cpp` — Public BEFORE_ALL creates the engine and registers the stable NativeCaseValue/NativeCaseRange contracts once; public AFTER_ALL destroys the engine and resets the registration lifecycle. Per-method modules, contexts, and observations are discarded/reset.
- `TypeSystem/AngelscriptNativeGlobalPropertyTests.cpp` — Public BEFORE_ALL creates the engine and installs a stable registration/type/property contract once; public AFTER_ALL destroys it and clears stored IDs/state. Tests=7, custom registration references=12.
- `TypeSystem/AngelscriptNativeTypeInfoFunctionMetadataDepthTests.cpp` — Public BEFORE_ALL creates the engine and installs a stable registration/type/property contract once; public AFTER_ALL destroys it and clears stored IDs/state. Tests=4, custom registration references=6.

`Embedding/AngelscriptNativeGlobalCallbackTests.cpp` is separately accepted because `BEFORE_EACH` destroys and recreates the engine, so its class member does not carry registrations or modules between methods.

## Large files requiring semantic split (0)

No current source owner requires a semantic split. All 14 original
mixed-responsibility owners have focused physical ownership.

## Large files intentionally retained (43)

These files exceed 1000 lines but retain one cohesive generated owner or a tightly coupled semantic family. Their size is predominantly explicit source/case/oracle construction, so no split is required merely to reduce line count:

The Operator subject owners now retained here are: assignment legal (1628 lines), assignment target rejection (1575), assignment type rejection (1580), floating comparison (2101), enum/alias comparison (2116), reference comparison (2163), overloaded comparison (2076), legal increment/decrement (1445), increment/decrement target rejection (1400), increment/decrement type rejection (1412), overloaded integer consumer (1132), overloaded boolean consumer (1133), overloaded assignment consumer (1133), and overloaded duplicate declaration (1128). Each has exactly one `TEST_METHOD` and one product ID.

- `Language/Constructors/AngelscriptNativeConstructorBoundaryTests.cpp` — 1763 lines, 1 TEST_METHOD(s), products=[LANG-CTOR-BOUNDARY]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Constructors/AngelscriptNativeConstructorFailureTests.cpp` — 1153 lines, 1 TEST_METHOD(s), products=[LANG-CTOR-ORDER-FAILURE]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Constructors/AngelscriptNativeConstructorParameterTests.cpp` — 1421 lines, 1 TEST_METHOD(s), products=[LANG-CTOR-PARAM-SELECT]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Constructors/AngelscriptNativeConstructorPolicyTests.cpp` — 1507 lines, 1 TEST_METHOD(s), products=[LANG-CTOR-SPECIAL-POLICY]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Constructors/AngelscriptNativeConstructorSelectionTests.cpp` — 2107 lines, 1 TEST_METHOD(s), products=[LANG-CTOR-KIND-CALL]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Constructors/AngelscriptNativeConstructorTransferTests.cpp` — 2070 lines, 1 TEST_METHOD(s), products=[LANG-CTOR-TRANSFER]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Destructors/AngelscriptNativeDestructorDeclarationTests.cpp` — 1106 lines, 1 TEST_METHOD(s), products=[LANG-DTOR-DECLARATION]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Destructors/AngelscriptNativeDestructorExitTests.cpp` — 2444 lines, 1 TEST_METHOD(s), products=[LANG-DTOR-OWNER-EXIT]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Destructors/AngelscriptNativeDestructorPartialConstructionTests.cpp` — 1380 lines, 1 TEST_METHOD(s), products=[LANG-DTOR-PARTIAL]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Expressions/AngelscriptNativeExpressionPrecedenceTests.cpp` — 1047 lines, 2 TEST_METHOD(s), products=[LANG-EXPR-PRECEDENCE;LANG-EXPR-ASSOCIATIVITY]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Expressions/AngelscriptNativeExpressionResolutionTests.cpp` — 1568 lines, 1 TEST_METHOD(s), products=[LANG-EXPR-RESOLUTION]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Expressions/AngelscriptNativeExpressionValueCategoryTests.cpp` — 1308 lines, 1 TEST_METHOD(s), products=[LANG-EXPR-VALUE-MUTATION]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Inheritance/AngelscriptNativeInheritanceAccessTests.cpp` — 1348 lines, 1 TEST_METHOD(s), products=[LANG-INH-ACCESS]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Inheritance/AngelscriptNativeInheritanceCastTests.cpp` — 1202 lines, 1 TEST_METHOD(s), products=[LANG-INH-CAST]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Inheritance/AngelscriptNativeInheritanceDispatchTests.cpp` — 1311 lines, 1 TEST_METHOD(s), products=[LANG-INH-DISPATCH]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Inheritance/AngelscriptNativeInheritanceRuleTests.cpp` — 1166 lines, 1 TEST_METHOD(s), products=[LANG-INH-CLASS-RULE]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Inheritance/AngelscriptNativeOverrideSignatureTests.cpp` — 1270 lines, 1 TEST_METHOD(s), products=[LANG-INH-OVERRIDE-SIGNATURE]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Operators/AngelscriptNativeNumericBinaryOperatorTests.cpp` — 1255 lines, 1 TEST_METHOD(s), products=[LANG-OP-NUMERIC-BINARY]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Operators/AngelscriptNativePowerOperatorTests.cpp` — 1114 lines, 3 TEST_METHOD(s), products=[LANG-OP-POWER-UNIVERSAL;LANG-OP-POWER-NEGATIVE-EXPONENT;LANG-OP-POWER-FRACTIONAL-EXPONENT]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Properties/AngelscriptNativeIndexedPropertyTests.cpp` — 1156 lines, 1 TEST_METHOD(s), products=[LANG-PROP-INDEXED]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Properties/AngelscriptNativePropertyCopyTests.cpp` — 1264 lines, 1 TEST_METHOD(s), products=[LANG-PROP-COPY-INDEPENDENCE]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Properties/AngelscriptNativePropertyFailureTests.cpp` — 1346 lines, 1 TEST_METHOD(s), products=[LANG-PROP-FAILURE]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Properties/AngelscriptNativePropertyInitializationTests.cpp` — 1035 lines, 1 TEST_METHOD(s), products=[LANG-PROP-INIT-ORDER]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Properties/AngelscriptNativePropertyRebuildTests.cpp` — 1634 lines, 1 TEST_METHOD(s), products=[LANG-PROP-REBUILD]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/References/AngelscriptNativeReferenceIdentityTests.cpp` — 1081 lines, 1 TEST_METHOD(s), products=[LANG-REF-SOURCE-OP]. The retained owner contains only the 288 source/operation/qualifier cases and their compile, diagnostic, runtime, metadata, recovery, and lifecycle protocol; the independent derived-input fork rejection now has its own physical owner.
- `Language/References/AngelscriptNativeReferenceLifetimeTests.cpp` — 1512 lines, 1 TEST_METHOD(s), products=[LANG-REF-LIFETIME]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/References/AngelscriptNativeReferenceResolutionTests.cpp` — 1612 lines, 1 TEST_METHOD(s), products=[LANG-REF-RESOLUTION]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Variables/AngelscriptNativeVariableAssignmentTests.cpp` — 1123 lines, 1 TEST_METHOD(s), products=[LANG-VAR-ASSIGN-TARGET]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.
- `Language/Variables/AngelscriptNativeVariableInitializationTests.cpp` — 1061 lines, 1 TEST_METHOD(s), products=[LANG-VAR-INIT-STORAGE]. The file remains one cohesive generated Cartesian owner or one tightly coupled semantic family; its size comes from explicit case/source/oracle construction rather than unrelated failure responsibilities.

## Historical prioritization and current disposition

The initial prioritization was:

1. Fix the 12 missing `Destroy()` guards first.
2. Convert the 100 unjustified shared engines in theme-sized batches.
3. Split the 14 mixed-responsibility large files, seven of which also needed
   lifecycle conversion.
4. Leave the 28 then-reviewed cohesive large generators intact unless a later
   failure-localization review found a second responsibility.

The first two lifecycle priorities are complete in current source. Lifecycle
and semantic-split work no longer overlap: the remaining current split candidate
has a compliant lifecycle disposition. Physical organization remains a
separate living task.

## Static counts

### Historical starting audit

- SDK `.cpp` files: 232
- CSV rows: 232
- unique file keys: 232
- source-file key differences: 0
- files over 1000 lines: 42
- files with required lifecycle action: 112
- files with required semantic split: 14
- files requiring both lifecycle work and split: 7

### Living current record

- SDK `.cpp` files: 271
- CSV rows: 271
- unique file keys: 271
- source-file key differences: 0
- `CompliantCaseOwned`: 231
- `CompliantCaseOwnedDirectEngine`: 9
- `CompliantClassOwnedImmutableRegistration`: 8
- `CompliantNoRawEngineFixture`: 22
- `CompliantPerCaseRecreationHooks`: 1
- current lifecycle `ChangeRequired`: 0
- `NotLarge`: 228
- `RetainCohesiveGeneratorOrOwner`: 43
- `SplitRequiredMixedResponsibilities`: 0
- files requiring both lifecycle work and split: 0
- build/test execution: not performed by instruction
