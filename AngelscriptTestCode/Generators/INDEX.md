# Language generator index

Complete 122-product catalog. Counts are source-generation targets, not runtime proof. Rule files live beside this index; C++ classes are `AngelscriptTest::Generate::F<ClassWithoutF>`.

## Theme totals

| Theme | Products | Cells | Normal | Reject | Fault |
|---|---:|---:|---:|---:|---:|
| ControlFlow | 11 | 2483 | 2015 | 175 | 293 |
| Operators | 25 | 12453 | 10816 | 1511 | 126 |
| Expressions | 10 | 2902 | 1202 | 883 | 817 |
| Conversions | 11 | 7262 | 5992 | 1024 | 246 |
| Functions | 19 | 1601 | 1223 | 332 | 46 |
| Variables | 8 | 1925 | 1408 | 458 | 59 |
| References | 7 | 766 | 550 | 207 | 9 |
| Properties | 9 | 3018 | 2500 | 490 | 28 |
| Inheritance | 5 | 598 | 517 | 81 | 0 |
| Declarations | 3 | 414 | 348 | 66 | 0 |
| Constructors | 7 | 1368 | 958 | 290 | 120 |
| Destructors | 3 | 886 | 688 | 4 | 194 |
| Foreach | 4 | 1010 | 472 | 478 | 60 |
| **Total** | **122** | **36686** | **28689** | **5999** | **1998** |

## Products

| Product | Class | Cells | Normal | Reject | Fault | Rules |
|---|---|---:|---:|---:|---:|---|
| [LANG-CF-FOR-CLAUSES](cf/LANG-CF-FOR-CLAUSES.md) | `FForLoopGenerator` | 24 | 24 | 0 | 0 | `cf/` |
| [LANG-CF-BRANCH-CONDITION-DEPTH](cf/LANG-CF-BRANCH-CONDITION-DEPTH.md) | `FBranchConditionGenerator` | 45 | 45 | 0 | 0 | `cf/` |
| [LANG-CF-CONDITION](cf/LANG-CF-CONDITION.md) | `FConditionGenerator` | 56 | 48 | 8 | 0 | `cf/` |
| [LANG-CF-LIVE-LOCAL-CLEANUP](cf/LANG-CF-LIVE-LOCAL-CLEANUP.md) | `FLiveLocalCleanupGenerator` | 120 | 96 | 0 | 24 | `cf/` |
| [LANG-CF-LOOP-COND-TRANSFER-DEPTH](cf/LANG-CF-LOOP-COND-TRANSFER-DEPTH.md) | `FLoopCondTransferGenerator` | 180 | 180 | 0 | 0 | `cf/` |
| [LANG-CF-LOOP-DEPTH](cf/LANG-CF-LOOP-DEPTH.md) | `FLoopDepthGenerator` | 48 | 48 | 0 | 0 | `cf/` |
| [LANG-CF-NESTED-TARGETS](cf/LANG-CF-NESTED-TARGETS.md) | `FNestedTargetGenerator` | 18 | 18 | 0 | 0 | `cf/` |
| [LANG-CF-STATEMENT-COUNT-TRANSFER](cf/LANG-CF-STATEMENT-COUNT-TRANSFER.md) | `FStatementTransferGenerator` | 1536 | 1344 | 0 | 192 | `cf/` |
| [LANG-CF-SWITCH](cf/LANG-CF-SWITCH.md) | `FSwitchGenerator` | 432 | 209 | 146 | 77 | `cf/` |
| [LANG-CF-SWITCH-PLACEMENT](cf/LANG-CF-SWITCH-PLACEMENT.md) | `FSwitchPlacementGenerator` | 16 | 0 | 16 | 0 | `cf/` |
| [LANG-CF-TRANSFER-VALIDITY](cf/LANG-CF-TRANSFER-VALIDITY.md) | `FTransferValidityGenerator` | 8 | 3 | 5 | 0 | `cf/` |
| [LANG-OP-ASSIGNMENT](op/LANG-OP-ASSIGNMENT.md) | `FOpAssignmentGenerator` | 444 | 444 | 0 | 0 | `op/` |
| [LANG-OP-ASSIGNMENT-TARGET-REJECTION](op/LANG-OP-ASSIGNMENT-TARGET-REJECTION.md) | `FOpAssignmentTargetRejectionGenerator` | 222 | 0 | 222 | 0 | `op/` |
| [LANG-OP-ASSIGNMENT-TYPE-REJECTION](op/LANG-OP-ASSIGNMENT-TYPE-REJECTION.md) | `FOpAssignmentTypeRejectionGenerator` | 128 | 0 | 128 | 0 | `op/` |
| [LANG-OP-COMPARISON-ENUM-ALIAS](op/LANG-OP-COMPARISON-ENUM-ALIAS.md) | `FOpComparisonEnumAliasGenerator` | 144 | 144 | 0 | 0 | `op/` |
| [LANG-OP-COMPARISON-FLOAT](op/LANG-OP-COMPARISON-FLOAT.md) | `FOpComparisonFloatGenerator` | 192 | 192 | 0 | 0 | `op/` |
| [LANG-OP-COMPARISON-OVERLOAD](op/LANG-OP-COMPARISON-OVERLOAD.md) | `FOpComparisonOverloadGenerator` | 96 | 96 | 0 | 0 | `op/` |
| [LANG-OP-COMPARISON-REFERENCE](op/LANG-OP-COMPARISON-REFERENCE.md) | `FOpComparisonReferenceGenerator` | 96 | 32 | 64 | 0 | `op/` |
| [LANG-OP-FAILURE](op/LANG-OP-FAILURE.md) | `FOpFailureGenerator` | 102 | 6 | 42 | 54 | `op/` |
| [LANG-OP-INCREMENT](op/LANG-OP-INCREMENT.md) | `FOpIncrementGenerator` | 480 | 480 | 0 | 0 | `op/` |
| [LANG-OP-INCREMENT-TARGET-REJECTION](op/LANG-OP-INCREMENT-TARGET-REJECTION.md) | `FOpIncrementTargetRejectionGenerator` | 80 | 0 | 80 | 0 | `op/` |
| [LANG-OP-INCREMENT-TYPE-REJECTION](op/LANG-OP-INCREMENT-TYPE-REJECTION.md) | `FOpIncrementTypeRejectionGenerator` | 16 | 0 | 16 | 0 | `op/` |
| [LANG-OP-INTEGRAL-BITWISE](op/LANG-OP-INTEGRAL-BITWISE.md) | `FOpIntegralBitwiseGenerator` | 1680 | 1680 | 0 | 0 | `op/` |
| [LANG-OP-LOGICAL](op/LANG-OP-LOGICAL.md) | `FOpLogicalGenerator` | 192 | 192 | 0 | 0 | `op/` |
| [LANG-OP-LOGICAL-NOT](op/LANG-OP-LOGICAL-NOT.md) | `FOpLogicalNotGenerator` | 10 | 10 | 0 | 0 | `op/` |
| [LANG-OP-NUMERIC-BINARY](op/LANG-OP-NUMERIC-BINARY.md) | `FOpNumericBinaryGenerator` | 5500 | 5500 | 0 | 0 | `op/` |
| [LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER](op/LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER.md) | `FOpOverloadAssignmentConsumerGenerator` | 24 | 12 | 12 | 0 | `op/` |
| [LANG-OP-OVERLOAD-BOOLEAN-CONSUMER](op/LANG-OP-OVERLOAD-BOOLEAN-CONSUMER.md) | `FOpOverloadBooleanConsumerGenerator` | 20 | 10 | 10 | 0 | `op/` |
| [LANG-OP-OVERLOAD-DUPLICATE-DECLARATION](op/LANG-OP-OVERLOAD-DUPLICATE-DECLARATION.md) | `FOpOverloadDuplicateDeclarationGenerator` | 7 | 0 | 7 | 0 | `op/` |
| [LANG-OP-OVERLOAD-INTEGER-CONSUMER](op/LANG-OP-OVERLOAD-INTEGER-CONSUMER.md) | `FOpOverloadIntegerConsumerGenerator` | 120 | 66 | 54 | 0 | `op/` |
| [LANG-OP-POWER-FRACTIONAL-EXPONENT](op/LANG-OP-POWER-FRACTIONAL-EXPONENT.md) | `FOpPowerFractionalExponentGenerator` | 80 | 80 | 0 | 0 | `op/` |
| [LANG-OP-POWER-NEGATIVE-EXPONENT](op/LANG-OP-POWER-NEGATIVE-EXPONENT.md) | `FOpPowerNegativeExponentGenerator` | 240 | 144 | 96 | 0 | `op/` |
| [LANG-OP-POWER-UNIVERSAL](op/LANG-OP-POWER-UNIVERSAL.md) | `FOpPowerUniversalGenerator` | 1600 | 848 | 680 | 72 | `op/` |
| [LANG-OP-RESULT-CONTEXT](op/LANG-OP-RESULT-CONTEXT.md) | `FOpResultContextGenerator` | 240 | 180 | 60 | 0 | `op/` |
| [LANG-OP-UNARY](op/LANG-OP-UNARY.md) | `FOpUnaryGenerator` | 700 | 700 | 0 | 0 | `op/` |
| [LANG-OP-UNARY-REJECTION](op/LANG-OP-UNARY-REJECTION.md) | `FOpUnaryRejectionGenerator` | 40 | 0 | 40 | 0 | `op/` |
| [LANG-EXPR-ASSOCIATIVITY](expr/LANG-EXPR-ASSOCIATIVITY.md) | `FExprAssociativityGenerator` | 72 | 60 | 12 | 0 | `expr/` |
| [LANG-EXPR-CHAIN](expr/LANG-EXPR-CHAIN.md) | `FExprChainGenerator` | 800 | 160 | 320 | 320 | `expr/` |
| [LANG-EXPR-EVAL-ORDER](expr/LANG-EXPR-EVAL-ORDER.md) | `FExprEvalOrderGenerator` | 540 | 135 | 0 | 405 | `expr/` |
| [LANG-EXPR-FAILURE](expr/LANG-EXPR-FAILURE.md) | `FExprFailureGenerator` | 192 | 0 | 112 | 80 | `expr/` |
| [LANG-EXPR-LAZY-EVALUATION](expr/LANG-EXPR-LAZY-EVALUATION.md) | `FExprLazyEvaluationGenerator` | 72 | 60 | 0 | 12 | `expr/` |
| [LANG-EXPR-PRECEDENCE](expr/LANG-EXPR-PRECEDENCE.md) | `FExprPrecedenceGenerator` | 432 | 231 | 201 | 0 | `expr/` |
| [LANG-EXPR-PRIMARY-CONTEXT](expr/LANG-EXPR-PRIMARY-CONTEXT.md) | `FExprPrimaryContextGenerator` | 220 | 174 | 46 | 0 | `expr/` |
| [LANG-EXPR-RESOLUTION](expr/LANG-EXPR-RESOLUTION.md) | `FExprResolutionGenerator` | 224 | 112 | 112 | 0 | `expr/` |
| [LANG-EXPR-SOURCE-BOUNDARY](expr/LANG-EXPR-SOURCE-BOUNDARY.md) | `FExprSourceBoundaryGenerator` | 210 | 210 | 0 | 0 | `expr/` |
| [LANG-EXPR-VALUE-MUTATION](expr/LANG-EXPR-VALUE-MUTATION.md) | `FExprValueMutationGenerator` | 140 | 60 | 80 | 0 | `expr/` |
| [LANG-CONV-ABI](conv/LANG-CONV-ABI.md) | `FConvAbiGenerator` | 12 | 12 | 0 | 0 | `conv/` |
| [LANG-CONV-BOOL-CONTEXT](conv/LANG-CONV-BOOL-CONTEXT.md) | `FConvBoolContextGenerator` | 234 | 18 | 216 | 0 | `conv/` |
| [LANG-CONV-ENUM-ALIAS](conv/LANG-CONV-ENUM-ALIAS.md) | `FConvEnumAliasGenerator` | 1260 | 1130 | 130 | 0 | `conv/` |
| [LANG-CONV-FAILURE](conv/LANG-CONV-FAILURE.md) | `FConvFailureGenerator` | 24 | 4 | 14 | 6 | `conv/` |
| [LANG-CONV-FLOAT-FINITE-SPECIAL](conv/LANG-CONV-FLOAT-FINITE-SPECIAL.md) | `FConvFloatFiniteSpecialGenerator` | 240 | 240 | 0 | 0 | `conv/` |
| [LANG-CONV-FLOAT64-TO-FLOAT32-RANGE](conv/LANG-CONV-FLOAT64-TO-FLOAT32-RANGE.md) | `FConvFloat64ToFloat32RangeGenerator` | 8 | 8 | 0 | 0 | `conv/` |
| [LANG-CONV-NONFINITE-PRECONVERSION](conv/LANG-CONV-NONFINITE-PRECONVERSION.md) | `FConvNonfinitePreconversionGenerator` | 240 | 0 | 0 | 240 | `conv/` |
| [LANG-CONV-NUMERIC](conv/LANG-CONV-NUMERIC.md) | `FConvNumericGenerator` | 4200 | 4200 | 0 | 0 | `conv/` |
| [LANG-CONV-OBJECT-CAST](conv/LANG-CONV-OBJECT-CAST.md) | `FConvObjectCastGenerator` | 180 | 108 | 72 | 0 | `conv/` |
| [LANG-CONV-OVERLOAD](conv/LANG-CONV-OVERLOAD.md) | `FConvOverloadGenerator` | 144 | 72 | 72 | 0 | `conv/` |
| [LANG-CONV-VALUE-OBJECT](conv/LANG-CONV-VALUE-OBJECT.md) | `FConvValueObjectGenerator` | 720 | 200 | 520 | 0 | `conv/` |
| [LANG-FN-ARG-SOURCE](fn/LANG-FN-ARG-SOURCE.md) | `FFnArgSourceGenerator` | 44 | 22 | 17 | 5 | `fn/` |
| [LANG-FN-ARITY-TARGET](fn/LANG-FN-ARITY-TARGET.md) | `FFnArityTargetGenerator` | 21 | 21 | 0 | 0 | `fn/` |
| [LANG-FN-ARITY-TYPE-STRESS](fn/LANG-FN-ARITY-TYPE-STRESS.md) | `FFnArityTypeStressGenerator` | 96 | 96 | 0 | 0 | `fn/` |
| [LANG-FN-DEFAULTS](fn/LANG-FN-DEFAULTS.md) | `FFnDefaultsGenerator` | 72 | 57 | 15 | 0 | `fn/` |
| [LANG-FN-DIRECTION-DEFAULT](fn/LANG-FN-DIRECTION-DEFAULT.md) | `FFnDirectionDefaultGenerator` | 528 | 309 | 219 | 0 | `fn/` |
| [LANG-FN-INDIRECT-IMPORTED](fn/LANG-FN-INDIRECT-IMPORTED.md) | `FFnIndirectImportedGenerator` | 6 | 0 | 6 | 0 | `fn/` |
| [LANG-FN-INDIRECT-MIXIN](fn/LANG-FN-INDIRECT-MIXIN.md) | `FFnIndirectMixinGenerator` | 6 | 4 | 2 | 0 | `fn/` |
| [LANG-FN-INDIRECT-REGISTERED-FUNCDEF](fn/LANG-FN-INDIRECT-REGISTERED-FUNCDEF.md) | `FFnIndirectRegisteredFuncdefGenerator` | 6 | 0 | 6 | 0 | `fn/` |
| [LANG-FN-INDIRECT-SCRIPT-FUNCDEF](fn/LANG-FN-INDIRECT-SCRIPT-FUNCDEF.md) | `FFnIndirectScriptFuncdefGenerator` | 6 | 0 | 6 | 0 | `fn/` |
| [LANG-FN-MIXIN-DIRECT-DISPATCH](fn/LANG-FN-MIXIN-DIRECT-DISPATCH.md) | `FFnMixinDirectDispatchGenerator` | 2 | 2 | 0 | 0 | `fn/` |
| [LANG-FN-MIXIN-FREE-CALL-REJECTION](fn/LANG-FN-MIXIN-FREE-CALL-REJECTION.md) | `FFnMixinFreeCallRejectionGenerator` | 2 | 0 | 2 | 0 | `fn/` |
| [LANG-FN-OVERLOAD](fn/LANG-FN-OVERLOAD.md) | `FFnOverloadGenerator` | 28 | 14 | 14 | 0 | `fn/` |
| [LANG-FN-PARAM-DIRECTION](fn/LANG-FN-PARAM-DIRECTION.md) | `FFnParamDirectionGenerator` | 60 | 60 | 0 | 0 | `fn/` |
| [LANG-FN-PARAM-POSITION](fn/LANG-FN-PARAM-POSITION.md) | `FFnParamPositionGenerator` | 180 | 180 | 0 | 0 | `fn/` |
| [LANG-FN-RECURSION](fn/LANG-FN-RECURSION.md) | `FFnRecursionGenerator` | 24 | 6 | 12 | 6 | `fn/` |
| [LANG-FN-RETURN](fn/LANG-FN-RETURN.md) | `FFnReturnGenerator` | 136 | 86 | 33 | 17 | `fn/` |
| [LANG-FN-SIGNATURE-SHAPE](fn/LANG-FN-SIGNATURE-SHAPE.md) | `FFnSignatureShapeGenerator` | 192 | 192 | 0 | 0 | `fn/` |
| [LANG-FN-TYPED-DEFAULTS](fn/LANG-FN-TYPED-DEFAULTS.md) | `FFnTypedDefaultsGenerator` | 168 | 168 | 0 | 0 | `fn/` |
| [LANG-FN-VALUE-LIFECYCLE](fn/LANG-FN-VALUE-LIFECYCLE.md) | `FFnValueLifecycleGenerator` | 24 | 6 | 0 | 18 | `fn/` |
| [LANG-VAR-ASSIGN-TARGET](var/LANG-VAR-ASSIGN-TARGET.md) | `FVarAssignTargetGenerator` | 595 | 212 | 383 | 0 | `var/` |
| [LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT](var/LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT.md) | `FVarCountedReferenceAssignmentGenerator` | 7 | 6 | 0 | 1 | `var/` |
| [LANG-VAR-FAILURE-BOUNDARY](var/LANG-VAR-FAILURE-BOUNDARY.md) | `FVarFailureBoundaryGenerator` | 28 | 12 | 12 | 4 | `var/` |
| [LANG-VAR-INIT-STORAGE](var/LANG-VAR-INIT-STORAGE.md) | `FVarInitStorageGenerator` | 735 | 713 | 22 | 0 | `var/` |
| [LANG-VAR-LIFETIME](var/LANG-VAR-LIFETIME.md) | `FVarLifetimeGenerator` | 100 | 80 | 0 | 20 | `var/` |
| [LANG-VAR-LOOP-DECL-LIFETIME](var/LANG-VAR-LOOP-DECL-LIFETIME.md) | `FVarLoopDeclLifetimeGenerator` | 200 | 168 | 0 | 32 | `var/` |
| [LANG-VAR-REFERENCE-INIT](var/LANG-VAR-REFERENCE-INIT.md) | `FVarReferenceInitGenerator` | 150 | 128 | 20 | 2 | `var/` |
| [LANG-VAR-SHADOW](var/LANG-VAR-SHADOW.md) | `FVarShadowGenerator` | 110 | 89 | 21 | 0 | `var/` |
| [LANG-REF-DIRECTION](ref/LANG-REF-DIRECTION.md) | `FRefDirectionGenerator` | 96 | 96 | 0 | 0 | `ref/` |
| [LANG-REF-DIRECTION-FORK-GLOBAL](ref/LANG-REF-DIRECTION-FORK-GLOBAL.md) | `FRefDirectionForkGlobalGenerator` | 1 | 0 | 1 | 0 | `ref/` |
| [LANG-REF-FAILURE](ref/LANG-REF-FAILURE.md) | `FRefFailureGenerator` | 20 | 0 | 18 | 2 | `ref/` |
| [LANG-REF-FORK-DERIVED-INREF](ref/LANG-REF-FORK-DERIVED-INREF.md) | `FRefForkDerivedInrefGenerator` | 1 | 0 | 1 | 0 | `ref/` |
| [LANG-REF-LIFETIME](ref/LANG-REF-LIFETIME.md) | `FRefLifetimeGenerator` | 200 | 150 | 50 | 0 | `ref/` |
| [LANG-REF-RESOLUTION](ref/LANG-REF-RESOLUTION.md) | `FRefResolutionGenerator` | 160 | 111 | 49 | 0 | `ref/` |
| [LANG-REF-SOURCE-OP](ref/LANG-REF-SOURCE-OP.md) | `FRefSourceOpGenerator` | 288 | 193 | 88 | 7 | `ref/` |
| [LANG-PROP-ACCESSOR](prop/LANG-PROP-ACCESSOR.md) | `FPropAccessorGenerator` | 72 | 36 | 28 | 8 | `prop/` |
| [LANG-PROP-COPY-INDEPENDENCE](prop/LANG-PROP-COPY-INDEPENDENCE.md) | `FPropCopyIndependenceGenerator` | 459 | 459 | 0 | 0 | `prop/` |
| [LANG-PROP-FAILURE](prop/LANG-PROP-FAILURE.md) | `FPropFailureGenerator` | 56 | 0 | 36 | 20 | `prop/` |
| [LANG-PROP-FORK-SEMANTICS](prop/LANG-PROP-FORK-SEMANTICS.md) | `FPropForkSemanticsGenerator` | 13 | 1 | 12 | 0 | `prop/` |
| [LANG-PROP-INDEXED](prop/LANG-PROP-INDEXED.md) | `FPropIndexedGenerator` | 468 | 129 | 339 | 0 | `prop/` |
| [LANG-PROP-INIT-ORDER](prop/LANG-PROP-INIT-ORDER.md) | `FPropInitOrderGenerator` | 1500 | 1500 | 0 | 0 | `prop/` |
| [LANG-PROP-REBUILD](prop/LANG-PROP-REBUILD.md) | `FPropRebuildGenerator` | 90 | 90 | 0 | 0 | `prop/` |
| [LANG-PROP-VALUE-OP](prop/LANG-PROP-VALUE-OP.md) | `FPropValueOpGenerator` | 300 | 243 | 57 | 0 | `prop/` |
| [LANG-PROP-VISIBILITY](prop/LANG-PROP-VISIBILITY.md) | `FPropVisibilityGenerator` | 60 | 42 | 18 | 0 | `prop/` |
| [LANG-INH-ACCESS](inh/LANG-INH-ACCESS.md) | `FInhAccessGenerator` | 60 | 37 | 23 | 0 | `inh/` |
| [LANG-INH-CAST](inh/LANG-INH-CAST.md) | `FInhCastGenerator` | 60 | 60 | 0 | 0 | `inh/` |
| [LANG-INH-CLASS-RULE](inh/LANG-INH-CLASS-RULE.md) | `FInhClassRuleGenerator` | 64 | 24 | 40 | 0 | `inh/` |
| [LANG-INH-DISPATCH](inh/LANG-INH-DISPATCH.md) | `FInhDispatchGenerator` | 360 | 360 | 0 | 0 | `inh/` |
| [LANG-INH-OVERRIDE-SIGNATURE](inh/LANG-INH-OVERRIDE-SIGNATURE.md) | `FInhOverrideSignatureGenerator` | 54 | 36 | 18 | 0 | `inh/` |
| [LANG-DECL-COLLISION](decl/LANG-DECL-COLLISION.md) | `FDeclCollisionGenerator` | 96 | 48 | 48 | 0 | `decl/` |
| [LANG-DECL-FAILURE-RECOVERY](decl/LANG-DECL-FAILURE-RECOVERY.md) | `FDeclFailureRecoveryGenerator` | 18 | 0 | 18 | 0 | `decl/` |
| [LANG-DECL-FAMILY-SCOPE-ORDER](decl/LANG-DECL-FAMILY-SCOPE-ORDER.md) | `FDeclFamilyScopeOrderGenerator` | 300 | 300 | 0 | 0 | `decl/` |
| [LANG-CTOR-BOUNDARY](ctor/LANG-CTOR-BOUNDARY.md) | `FCtorBoundaryGenerator` | 68 | 20 | 40 | 8 | `ctor/` |
| [LANG-CTOR-KIND-CALL](ctor/LANG-CTOR-KIND-CALL.md) | `FCtorKindCallGenerator` | 288 | 257 | 31 | 0 | `ctor/` |
| [LANG-CTOR-ORDER-FAILURE](ctor/LANG-CTOR-ORDER-FAILURE.md) | `FCtorOrderFailureGenerator` | 128 | 16 | 0 | 112 | `ctor/` |
| [LANG-CTOR-PARAM-SELECT](ctor/LANG-CTOR-PARAM-SELECT.md) | `FCtorParamSelectGenerator` | 300 | 152 | 148 | 0 | `ctor/` |
| [LANG-CTOR-SPECIAL-POLICY](ctor/LANG-CTOR-SPECIAL-POLICY.md) | `FCtorSpecialPolicyGenerator` | 64 | 44 | 20 | 0 | `ctor/` |
| [LANG-CTOR-TRANSFER](ctor/LANG-CTOR-TRANSFER.md) | `FCtorTransferGenerator` | 448 | 448 | 0 | 0 | `ctor/` |
| [LANG-CTOR-VISIBILITY](ctor/LANG-CTOR-VISIBILITY.md) | `FCtorVisibilityGenerator` | 72 | 21 | 51 | 0 | `ctor/` |
| [LANG-DTOR-DECLARATION](dtor/LANG-DTOR-DECLARATION.md) | `FDtorDeclarationGenerator` | 52 | 40 | 4 | 8 | `dtor/` |
| [LANG-DTOR-OWNER-EXIT](dtor/LANG-DTOR-OWNER-EXIT.md) | `FDtorOwnerExitGenerator` | 666 | 522 | 0 | 144 | `dtor/` |
| [LANG-DTOR-PARTIAL](dtor/LANG-DTOR-PARTIAL.md) | `FDtorPartialGenerator` | 168 | 126 | 0 | 42 | `dtor/` |
| [LANG-FE-PROTOCOL](foreach/LANG-FE-PROTOCOL.md) | `FForeachProtocolGenerator` | 250 | 45 | 190 | 15 | `foreach/` |
| [LANG-FE-SIZE-VARIABLE](foreach/LANG-FE-SIZE-VARIABLE.md) | `FForeachSizeVariableGenerator` | 640 | 319 | 288 | 33 | `foreach/` |
| [LANG-FE-STRUCTURAL-MUTATION](foreach/LANG-FE-STRUCTURAL-MUTATION.md) | `FForeachStructuralMutationGenerator` | 36 | 36 | 0 | 0 | `foreach/` |
| [LANG-FE-TRANSFER-LIFETIME](foreach/LANG-FE-TRANSFER-LIFETIME.md) | `FForeachTransferLifetimeGenerator` | 84 | 72 | 0 | 12 | `foreach/` |

Acceptance identity: `Angelscript.UnitTest.Framework.Generate.LanguageGeneratorCorpus.VerifiesCompleteCorpus`.
Dump leaf per product: `GeneratedCases/<ClassWithoutF>.as`. ForLoop is included once with 24 cells.
