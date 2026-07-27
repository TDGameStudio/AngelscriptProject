# Full native SDK prefix execution record — 2026-07-24

## Invocation and terminal state

```powershell
Tools/RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK" `
  -Label as-native-sdk-full-prefix-object-cast-regression `
  -TimeoutMs 1800000
```

- Run directory: `Saved/Tests/as-native-sdk-full-prefix-object-cast-regression/20260724_071958_594_466a0f04/`.
- Runner terminal exit: `3` (the wrapper returns failure); duration approximately
  161 seconds.
- `Summary.json` has `ReportJsonPath: null` and no totals because execution
  terminated before Automation could export `Report/index.json`.
- `Report/` contains only the early `index.html` shell, not a result JSON.
- The active Conversions parent was already independently verified at **17/17
  PASS** in the preceding focused run. This full-prefix failure does not
  invalidate that narrower result, but it prevents a complete SDK regression
  claim.

## Terminal crash — open `FULL-002`

The editor process terminates while
`FPropertyRebuildTests::RunWorkflow()` loads serialized bytecode. This is a
native access violation, not an Automation assertion result:

```text
Unhandled Exception: EXCEPTION_ACCESS_VIOLATION writing address 0x0000000000000014
asCAtomic::atomicInc()                         as_atomic.cpp:71
asCReader::ReadTypeDeclaration()               as_restore.cpp:1882
asCReader::ReadInner()                         as_restore.cpp:519
asCReader::Read()                              as_restore.cpp:358
asCModule::LoadByteCode()                      as_module.cpp:1764
FPropertyRebuildTests::RunWorkflow()           AngelscriptNativePropertyRebuildTests.cpp:1002
FPropertyRebuildTests::ScenariosByPathAndObservation()
```

`Automation.log` states that a crash snapshot was written to
`Saved/Angelscript/CrashSnapshots/95244_20260724_072105_830/AngelscriptCrashSnapshot.json`.
After process exit, that directory exists but is empty. The missing JSON is
recorded as `FULL-003`; no contents are inferred from the log message.

## Normal owner failures observed before the crash — open `FULL-001`

The log records 62 distinct owner failures before the terminal PropertyRebuild
crash. This list is an execution inventory, not a root-cause grouping: the
first diagnostic is retained for each owner, but every owner remains active
and unclassified until it has an isolated reproduction and source/API/runtime
evidence.

### Control flow, declarations, destructors, and exceptions

| Owner | First retained diagnostic / stable product |
| --- | --- |
| `Language.ControlFlow.Conditions.FConditionTests.StatementsByConditionAndTruth` | `LANG-CF-CONDITION-IF-INVALID-TYPE-FALSE`: invalid condition diagnostic should name the rejected type. |
| `Language.ControlFlow.StatementTransfers.FStatementTransferTests.StatementsByCountTransferAndNesting` | `LANG-CF-STATEMENT-COUNT-TRANSFER-IF-ZERO-NONE-THREE-LEVEL`: statement transfer cell should compile. |
| `Language.ControlFlow.Switch.FSwitchTests.SelectorsByCaseAndExit` | `LANG-CF-SWITCH-INT8-FIRST-BREAK`: switch cell should compile. |
| `Language.Declarations.Collisions.FDeclarationCollisionTests.PairsByNamespaceRelationAndInsertionOrder` | `LANG-DECL-COLLISION-LEFT-THEN-RIGHT-SAME-METHOD-FIELD`: legal overload, accessor pair, or separated names should compile. |
| `Language.Declarations.Publication.FDeclarationPublicationTests.DeclarationFamiliesByScopeAndOrder` | `LANG-DECL-FAMILY-SCOPE-ORDER-FUNCTION-MEMBER-BEFORE-USE`: declaration entry should execute every supported selected declaration. |
| `Language.Destructors.Declaration.FDestructorDeclarationTests.ScenariosByObservation` | `LANG-DTOR-DECLARATION-RUNTIME-FIELD-DESTRUCTOR`: declared destructor markers should preserve exact derived/owner/field order. |
| `Language.Destructors.OwnerExit.FDestructorExitTests.ScenariosByNestingAndObservation` | `LANG-DTOR-OWNER-EXIT-LOCAL-ABORT-ONE-TERMINAL-STATE-RECOVERY`: owner-exit execution state should match its selected route. |
| `Language.Destructors.PartialConstruction.FDestructorPartialConstructionTests.TopologiesByBoundaryAndExit` | `LANG-DTOR-PARTIAL-INDEPENDENT-BEFORE-ROOT-ABORT`: partial destructor execution state should match the selected termination route. |
| `Language.Exceptions.Origins.FExceptionOriginTests.OriginsByDepthAndCallback` | `LANG-EX-ORIGIN-DEPTH-NULL-ACCESS-TOP-ABSENT`: exception origin cell should compile. |
| `Language.Exceptions.Recovery.FExceptionRecoveryTests.LiveStatesByFollowUpAndNesting` | `LANG-EX-CLEANUP-REUSE-NONE-UNPREPARE-NONE`: exception recovery cell should compile. |

### Expressions and foreach

| Owner | First retained diagnostic / stable product |
| --- | --- |
| `Language.Expressions.Boundary.FExpressionBoundaryTests.ScenariosByContextAndBuild` | `LANG-EXPR-SOURCE-BOUNDARY-FIRST-INITIALIZER-PARENTHESES-ONE`: boundary owner should retain executable line metadata. |
| `Language.Expressions.Chain.FExpressionChainTests.ShapesByDepthStateAndContext` | Native chain-surface registration failed before product execution. |
| `Language.Expressions.Evaluation.FExpressionEvaluationTests.CompositionsByCountOutcomeAndSourceShape` | `LANG-EXPR-EVAL-ORDER-ASSIGNMENT-TWO-COMPLETE-SINGLE-LINE`: expected successful compilation. |
| `Language.Expressions.Failure.FExpressionFailureTests.FailuresByContextAndRecovery` | Core fixture registration failed before product execution. |
| `Language.Expressions.Precedence.FExpressionPrecedenceTests.LevelsByLevelAndGrouping` | `LANG-EXPR-PRECEDENCE-UNPARENTHESIZED-MULTIPLICATIVE-LOGICAL-AND`: expected successful compilation. |
| `Language.Expressions.Precedence.FExpressionPrecedenceTests.LevelsBySequenceAndGrouping` | `LANG-EXPR-ASSOCIATIVITY-UNPARENTHESIZED-LOGICAL-AND-REPEATED-OPERATOR`: expected successful compilation. |
| `Language.Expressions.Primary.FPrimaryExpressionTests.PrimaryVariantsByContext` | `LANG-EXPR-PRIMARY-CONTEXT-INITIALIZER-INT-LITERAL`: reference/accessor fixture registration failed. |
| `Language.Expressions.Resolution.FExpressionResolutionTests.StatesByContextAndShape` | Core fixture registration failed before product execution. |
| `Language.Expressions.ValueCategory.FExpressionValueCategoryTests.CategoriesByMutationAndPlacement` | `LANG-EXPR-VALUE-MUTATION-MUTABLE-LVALUE-ASSIGN-LOCAL`: mutation fixture registration failed. |
| `Language.Foreach.Iteration.FForeachIterationTests.SizesByElementVariableAndTransfer` | `LANG-FE-SIZE-VARIABLE-EMPTY-PRIMITIVE-VALUE-COMPLETE`: foreach iteration cell should compile. |
| `Language.Foreach.Protocol.FForeachProtocolTests.ProtocolsByResolutionAndNesting` | `LANG-FE-PROTOCOL-COMPLETE-EXACT-SINGLE`: resolved foreach protocol should compile. |

### Functions and inheritance

| Owner | First retained diagnostic / stable product |
| --- | --- |
| `Language.Functions.ArgumentSources.FFunctionArgumentSourceTests.ArgumentSourcesByDirection` | `LANG-FN-ARG-SOURCE-VALUE-LITERAL`: parameter direction metadata should be exact. |
| `Language.Functions.DefaultArguments.FFunctionDefaultArgumentTests.DefaultPatternsByOmissionAndTarget` | `LANG-FN-DEFAULTS-NONE-TYPE-INVALID-GLOBAL`: invalid default declaration or omission should fail. |
| `Language.Functions.IndirectCalls.FFunctionIndirectCallTests.MechanismsByScenario` | `LANG-FN-INDIRECT-REGISTERED-FUNCDEF-NULL-OR-UNBOUND`: raw context should reject a null indirect target safely. |
| `Language.Functions.OverloadResolution.FFunctionOverloadResolutionTests.DiscriminatorsByOutcome` | `LANG-FN-OVERLOAD-TYPE-PROMOTION`: expected published overload metadata is missing. |
| `Language.Functions.ParameterDirections.FFunctionParameterDirectionTests.ParameterTypesByDirection` | Module compilation fails; direct source diagnostic names reserved keyword `int` at line 10, column 9. |
| `Language.Functions.ParameterPositions.FFunctionParameterPositionTests.ParameterTypesByPositionAndDirection` | Module compilation fails; direct source diagnostic names reserved keyword `int` at line 10, column 9. |
| `Language.Functions.Recursion.FFunctionRecursionTests.DepthsByTypeAndOutcome` | `LANG-FN-RECURSION-ZERO-RETURN-PRIMITIVE`: recursive cell should compile. |
| `Language.Functions.Returns.FFunctionReturnTests.ReturnTypesByControlPath` | `LANG-FN-RETURN-DIRECT-VOID`: legal return path should compile. |
| `Language.Functions.ValueLifecycle.FFunctionValueLifecycleTests.FailuresByInitializedCountAndTransfer` | `LANG-FN-VALUE-LIFECYCLE-ARGUMENT-EVALUATION-MANY-VALUE-ARGUMENT`: sentinels should unwind in reverse construction order. |
| `Language.Inheritance.Access.FInheritanceAccessTests.AccessByMemberAndSite` | `LANG-INH-ACCESS-DEFAULT-GETTER-SETTER-METHOD-OWNER`: access setter should publish its exact declaration. |
| `Language.Inheritance.Cast.FInheritanceCastTests.RelationsByConstnessAndUse` | `LANG-INH-CAST-MUTABLE-EXACT-ASSIGN`: native type family registration failed. |
| `Language.Inheritance.Dispatch.FInheritanceDispatchTests.DepthsByMemberViewAndDispatch` | `LANG-INH-DISPATCH-BASE-DIRECT-FIELD-DERIVED-OBJECT`: dispatch view should publish its exact witness. |
| `Language.Inheritance.OverrideSignature.FOverrideSignatureTests.DimensionsByVariantAndView` | `LANG-INH-OVERRIDE-SIGNATURE-PARAMETER-TYPE-EXACT-DERIVED`: source should publish the exact base method. |
| `Language.Inheritance.Rules.FInheritanceRuleTests.ScenariosByObservation` | `LANG-INH-CLASS-RULE-DIAGNOSTIC-ABSTRACT-CLASS-KEYWORD-REJECTED`: rejected inheritance rule should own its exact located diagnostic. |
| `Language.Interactions.SemanticChains.FSemanticInteractionTests.ChainsByPathAndLifecycle` | `X-SEMANTIC-CHAIN-FN-CONV-NORMAL-INITIAL`: positive semantic chain should compile. |

### Operators

| Owner | First retained diagnostic / stable product |
| --- | --- |
| `Language.Operators.Assignment.FAssignmentOperatorTests.TypeRejections` | Writable-fixture registration failed before rejection execution. |
| `Language.Operators.Assignment.FAssignmentOperatorTests.TypesByOperatorAndCategory` | Raw SDK property/observer registration failed before product execution. |
| `Language.Operators.Assignment.FAssignmentOperatorTests.WritableTargetRejections` | No-execution fixture registration failed before rejection execution. |
| `Language.Operators.Bitwise.FBitwiseOperatorTests.TypesByOperatorCountAndCategory` | `LANG-OP-INTEGRAL-BITWISE-MUTABLE-LVALUE-BIT-AND-ZERO-INT8`: bitwise source parameter should pass by value. |
| `Language.Operators.Comparison.FComparisonOperatorTests.EnumAndAliasByOperatorPairAndOrder` | Enum/alias trace-function registration failed. |
| `Language.Operators.Comparison.FComparisonOperatorTests.FloatingTypesByOperatorValueAndOrder` | Floating trace-function registration failed. |
| `Language.Operators.Comparison.FComparisonOperatorTests.OverloadsByOperatorRelationOrderAndReceiver` | `LANG-OP-COMPARISON-OVERLOAD-LESS-LESS-LEFT-RIGHT-MUTABLE`: exact const/mutable overload should resolve. |
| `Language.Operators.Comparison.FComparisonOperatorTests.ReferencesByOperatorRelationAndOrder` | Raw reference-fixture registration failed. |
| `Language.Operators.Context.FOperatorContextTests.FamiliesByContextAndOutcome` | `LANG-OP-RESULT-CONTEXT-UNARY-ASSIGNMENT-AMBIGUOUS`: rejected context should fail compilation. |
| `Language.Operators.Failure.FOperatorFailureTests.FailuresByRecoveryAndObservation` | `LANG-OP-FAILURE-UNSUPPORTED-OPERAND-DIAGNOSTIC-OR-EXCEPTION-FRESH-MODULE`: expected negative build instead returned `0` with no messages. |
| `Language.Operators.Increment.FIncrementOperatorTests.BoolTypeRejections` | Writable-shape registration failed before bool rejection execution. |
| `Language.Operators.Increment.FIncrementOperatorTests.TypesByOperatorCategoryAndObservation` | Property/rejection fixture registration failed. |
| `Language.Operators.Increment.FIncrementOperatorTests.WritableTargetRejections` | No-execution fixture registration failed. |
| `Language.Operators.Logical.FLogicalOperatorTests.SourcesByOperatorTruthAndContext` | `LANG-OP-LOGICAL-ASSIGNMENT-AND-CONVERSION-OPERATOR-FALSE-FALSE`: expected successful build. |
| `Language.Operators.NumericBinary.FNumericBinaryOperatorTests.OperandTypesByOperatorAndValue` | `LANG-OP-NUMERIC-BINARY-INT8-ADD-INT8-ZERO`: left parameter should be passed by value. |
| `Language.Operators.Overload.FOverloadedOperatorTests.AssignmentResultsByScenarioAndConsumer` | `LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER-ASSIGNMENT-INT-PARAMETER-ASSIGNMENT`: declared overload should compile. |
| `Language.Operators.Overload.FOverloadedOperatorTests.BooleanResultsByScenarioAndConsumer` | `LANG-OP-OVERLOAD-BOOLEAN-CONSUMER-COMPARISON-INT-PARAMETER-ASSIGNMENT`: selected overload metadata should match `bool opEquals(int) const`. |
| `Language.Operators.Overload.FOverloadedOperatorTests.IntegerResultsByScenarioAndConsumer` | `LANG-OP-OVERLOAD-INTEGER-CONSUMER-BINARY-INT-MEMBER-ASSIGNMENT`: selected overload metadata should match `int opAdd(int)`. |
| `Language.Operators.Power.FPowerOperatorTests.FractionalExponentTypesBySourceShape` | `LANG-OP-POWER-FRACTIONAL-EXPONENT-CONST-LVALUE-CONST-LVALUE-CONST-LVALUE`: runtime floating power should emit its fork bytecode route. |
| `Language.Operators.Power.FPowerOperatorTests.NegativeExponentTypesBySourceShape` | `LANG-OP-POWER-NEGATIVE-EXPONENT-CONST-LVALUE-CONST-LVALUE-CONST-LVALUE`: expected negative build instead returned `0` with no messages. |
| `Language.Operators.Power.FPowerOperatorTests.UniversalTypesBySourceShapeAndValue` | `LANG-OP-POWER-UNIVERSAL-CONST-LVALUE-CONST-LVALUE-CONST-LVALUE-ZERO-EXPONENT`: expected negative build instead returned `0` with no messages. |
| `Language.Operators.Unary.FUnaryOperatorTests.OperationsByCategoryAndValue` | `LANG-OP-UNARY-MUTABLE-LVALUE-POSITIVE-FLOAT64-ZERO`: unary evaluator should resolve by exact declaration. |

### Properties before terminal PropertyRebuild crash

| Owner | First retained diagnostic / stable product |
| --- | --- |
| `Language.Properties.Copy.FPropertyCopyTests.TypesByTransferMutationAndView` | `LANG-PROP-COPY-INDEPENDENCE-SOURCE-AFTER-TRANSFER-COPY-CONSTRUCT-INT8-EXACT`: property-copy cell should compile. |
| `Language.Properties.Failure.FPropertyFailureTests.FailuresByRecoveryAndProbe` | `LANG-PROP-FAILURE-REMOVED-PROPERTY-DECORATOR-DIRECT-FRESH-MODULE`: fixture should reach its expected registration state. |
| `Language.Properties.IndexedProperty.FIndexedPropertyTests.IndexTypesByCandidateSetOperationAndReceiver` | `LANG-PROP-INDEXED-SAME-TYPE-INT8-READ-MUTABLE`: fixture should publish every requested native declaration. Subsequent `LANG-002` evidence classifies this as a positive automatic-access expectation incompatible with committed current-fork semantics; it requires explicit current-fork rejection and Disabled selected-2.38 successor evidence rather than a Runtime repair. |
| `Language.Properties.Initialization.FPropertyInitializationTests.TypesBySourcePositionAndObservation` | `LANG-PROP-INIT-ORDER-ALL-CHECKPOINTS-BASE-FIRST-DEFAULT-VALUE-TYPEDEF`: property-initialization cell should compile. |

## Required follow-up order

1. Isolate and repair `FULL-002` first, preserving a minimal
   PropertyRebuild save/load source and bytecode artifact. A full-prefix run
   cannot produce a trustworthy final summary while this native crash remains.
2. Preserve/repair crash-snapshot output (`FULL-003`) so the path logged on a
   fatal error contains the promised JSON after process exit.
3. Partition the 62 normal owner failures by exact shared registration,
   declaration-format, current-fork semantic, assertion, or runtime root
   cause. Do not bulk-change expected outcomes from this one inventory.
4. For each partition, run the narrow owner first, then its theme, then the
   complete native SDK prefix. Record any new evidence in `issues.md` before
   closing the corresponding partition.

## PropertyRebuild follow-up record

The dedicated owner reproduction at `Saved/Tests/as-native-sdk-property-rebuild-loadbytecode-repro/20260724_072809_238_ee98ef18/` confirmed the original first-crash stack. Inspection established that the fork carries zero IDs for several deliberate no-count script-object default behaviors, while `ReadTypeDeclaration()` tried to add a function reference through every copied behavior slot. The narrowly scoped zero-ID guard builds successfully in `Saved/Build/as-native-sdk-property-rebuild-default-behaviour-restore/20260724_073122_384_41a30ef7/`.

That guard is not a complete resolution: the immediate owner rerun at `Saved/Tests/as-native-sdk-property-rebuild-default-behaviour-restore/20260724_073137_392_60889dbf/` advances past the prior failure and then crashes after its first script-class save/load workflow during a later `FString` allocation. The changed stack is recorded as `RESTORE-002` in `issues.md`. The claimed crash-snapshot directory for this rerun, `Saved/Angelscript/CrashSnapshots/14184_20260724_073204_944/`, is also empty. Ordinary Module SaveLoad controls remain 4/4 PASS, so no generic SaveLoad conclusion is warranted.

The first minimal script-class lifecycle probe is also red: it compiles, writes both complete generated sources, and then terminates with the same invalid-address heap failure before a result JSON is exported. Its `68428_20260724_074524_033` crash-snapshot directory is empty as well. This is `RESTORE-003`; the next probe iteration separates predecessor-retained and predecessor-released paths into independently runnable methods with persistent lifecycle stage records, rather than inferring the corrupting transition from the final allocator stack.

Separated runs now distinguish two active faults. Without a retained predecessor entry, the complete lifecycle reaches engine destruction and a forced allocation normally, but source execution returns `16` whereas restored execution returns `10` (`RESTORE-004`). With the predecessor retained across destination load, lifecycle logging reaches predecessor release and destination discard, then stops before the next `engine_destroy_begin` record; the short diagnostic observation window leaves an orphan editor process with no report, which was explicitly stopped after its PID/path/start time were verified (`RESTORE-005`). This shows that the property restoration error and retained-predecessor corruption must be diagnosed as separate causes; neither is waived or treated as a current-fork contract.

## Later authoritative rerun after Destructor and Constructor repairs (2026-07-24)

The Destructors runtime repair and Constructor Failure expectation rebaseline were
completed before the next aggregate launch. The full SDK prefix then exported a
normal report at
`Saved/Tests/as-native-sdk-full-after-destructor-and-constructor-order-fixes/20260724_144205_598_77c9f99e/Report/index.json`:
**478 succeeded, 57 failed, 0 not-run, 0 in-process**, with 15.89 seconds of
automation and no crash. The recovered owners are Constructor Failure and all
three Destructors methods; they are no longer in the failing list.

The remaining 57 failing owners are distributed as follows: Exceptions 2,
Expressions 9, Foreach 2, Functions 8, Inheritance 5, Interactions 1,
Operators 13, Properties 4, References 5, and Variables 8. This run supersedes
the 474/535 switch-repair baseline for progress reporting but does not erase
the earlier crash investigation or the 2.38 follow-up work. Each remaining
owner still needs a focused source/diagnostic/runtime/cleanup result before the
next full-prefix claim.
