# Complete 122-product implementation inventory

This is the full delivery list, not a backlog outside the Change. Each product maps to one task and one English theme contract. Counts are the accepted source-generation targets from the original cards; passing runtime behavior is not implied. ForLoop already exists and remains included once.

## Physical ownership and inspectable artifacts

All generator .h/.cpp files: `Plugins/Angelscript/Source/AngelscriptTest/Framework/Generate/`. Tests: `Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/Generate/`, one `GeneratesAndExportsAllCases` method per product, ForLoop in `ForLoopGeneratorTests.cpp`. Rules: `AngelscriptTestCode/Generators/<theme>/`. Each generator exports one complete formatted dump beside the actual Unreal.log as `GeneratedCases/<ClassWithoutF>.as`. Inline case comments map stable IDs to declarations and expected observations; there are no per-case files or JSON sidecars.

## Theme totals

| Theme | Products | Declared cells | Normal | Reject | Runtime fault |
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

## Every product and owning task

The class column is relative to `AngelscriptTest::Generate`. Runtime faults include the explicitly documented host-fault approximations. Product links open their detailed contracts.

| Task | Product | Class | Cells | Normal | Reject | Fault | Baseline |
|---|---|---|---:|---:|---:|---:|---|
| 1.1 | [LANG-CF-FOR-CLAUSES](../drafts/findings/cf-products.md#lang-cf-for-clauses) | `FForLoopGenerator` | 24 | 24 | 0 | 0 | Existing ForLoop |
| 1.2 | [LANG-CF-BRANCH-CONDITION-DEPTH](../drafts/findings/cf-products.md#lang-cf-branch-condition-depth) | `FBranchConditionGenerator` | 45 | 45 | 0 | 0 | Implementation required |
| 1.3 | [LANG-CF-CONDITION](../drafts/findings/cf-products.md#lang-cf-condition) | `FConditionGenerator` | 56 | 48 | 8 | 0 | Implementation required |
| 1.4 | [LANG-CF-LIVE-LOCAL-CLEANUP](../drafts/findings/cf-products.md#lang-cf-live-local-cleanup) | `FLiveLocalCleanupGenerator` | 120 | 96 | 0 | 24 | Implementation required |
| 1.5 | [LANG-CF-LOOP-COND-TRANSFER-DEPTH](../drafts/findings/cf-products.md#lang-cf-loop-cond-transfer-depth) | `FLoopCondTransferGenerator` | 180 | 180 | 0 | 0 | Implementation required |
| 1.6 | [LANG-CF-LOOP-DEPTH](../drafts/findings/cf-products.md#lang-cf-loop-depth) | `FLoopDepthGenerator` | 48 | 48 | 0 | 0 | Implementation required |
| 1.7 | [LANG-CF-NESTED-TARGETS](../drafts/findings/cf-products.md#lang-cf-nested-targets) | `FNestedTargetGenerator` | 18 | 18 | 0 | 0 | Implementation required |
| 1.8 | [LANG-CF-STATEMENT-COUNT-TRANSFER](../drafts/findings/cf-products.md#lang-cf-statement-count-transfer) | `FStatementTransferGenerator` | 1536 | 1344 | 0 | 192 | Implementation required |
| 1.9 | [LANG-CF-SWITCH](../drafts/findings/cf-products.md#lang-cf-switch) | `FSwitchGenerator` | 432 | 209 | 146 | 77 | Implementation required |
| 1.10 | [LANG-CF-SWITCH-PLACEMENT](../drafts/findings/cf-products.md#lang-cf-switch-placement) | `FSwitchPlacementGenerator` | 16 | 0 | 16 | 0 | Implementation required |
| 1.11 | [LANG-CF-TRANSFER-VALIDITY](../drafts/findings/cf-products.md#lang-cf-transfer-validity) | `FTransferValidityGenerator` | 8 | 3 | 5 | 0 | Implementation required |
| 2.1 | [LANG-OP-ASSIGNMENT](../drafts/findings/op-products.md#lang-op-assignment) | `FOpAssignmentGenerator` | 444 | 444 | 0 | 0 | Implementation required |
| 2.2 | [LANG-OP-ASSIGNMENT-TARGET-REJECTION](../drafts/findings/op-products.md#lang-op-assignment-target-rejection) | `FOpAssignmentTargetRejectionGenerator` | 222 | 0 | 222 | 0 | Implementation required |
| 2.3 | [LANG-OP-ASSIGNMENT-TYPE-REJECTION](../drafts/findings/op-products.md#lang-op-assignment-type-rejection) | `FOpAssignmentTypeRejectionGenerator` | 128 | 0 | 128 | 0 | Implementation required |
| 2.4 | [LANG-OP-COMPARISON-ENUM-ALIAS](../drafts/findings/op-products.md#lang-op-comparison-enum-alias) | `FOpComparisonEnumAliasGenerator` | 144 | 144 | 0 | 0 | Implementation required |
| 2.5 | [LANG-OP-COMPARISON-FLOAT](../drafts/findings/op-products.md#lang-op-comparison-float) | `FOpComparisonFloatGenerator` | 192 | 192 | 0 | 0 | Implementation required |
| 2.6 | [LANG-OP-COMPARISON-OVERLOAD](../drafts/findings/op-products.md#lang-op-comparison-overload) | `FOpComparisonOverloadGenerator` | 96 | 96 | 0 | 0 | Implementation required |
| 2.7 | [LANG-OP-COMPARISON-REFERENCE](../drafts/findings/op-products.md#lang-op-comparison-reference) | `FOpComparisonReferenceGenerator` | 96 | 32 | 64 | 0 | Implementation required |
| 2.8 | [LANG-OP-FAILURE](../drafts/findings/op-products.md#lang-op-failure) | `FOpFailureGenerator` | 102 | 6 | 42 | 54 | Implementation required |
| 2.9 | [LANG-OP-INCREMENT](../drafts/findings/op-products.md#lang-op-increment) | `FOpIncrementGenerator` | 480 | 480 | 0 | 0 | Implementation required |
| 2.10 | [LANG-OP-INCREMENT-TARGET-REJECTION](../drafts/findings/op-products.md#lang-op-increment-target-rejection) | `FOpIncrementTargetRejectionGenerator` | 80 | 0 | 80 | 0 | Implementation required |
| 2.11 | [LANG-OP-INCREMENT-TYPE-REJECTION](../drafts/findings/op-products.md#lang-op-increment-type-rejection) | `FOpIncrementTypeRejectionGenerator` | 16 | 0 | 16 | 0 | Implementation required |
| 2.12 | [LANG-OP-INTEGRAL-BITWISE](../drafts/findings/op-products.md#lang-op-integral-bitwise) | `FOpIntegralBitwiseGenerator` | 1680 | 1680 | 0 | 0 | Implementation required |
| 2.13 | [LANG-OP-LOGICAL](../drafts/findings/op-products.md#lang-op-logical) | `FOpLogicalGenerator` | 192 | 192 | 0 | 0 | Implementation required |
| 2.14 | [LANG-OP-LOGICAL-NOT](../drafts/findings/op-products.md#lang-op-logical-not) | `FOpLogicalNotGenerator` | 10 | 10 | 0 | 0 | Implementation required |
| 2.15 | [LANG-OP-NUMERIC-BINARY](../drafts/findings/op-products.md#lang-op-numeric-binary) | `FOpNumericBinaryGenerator` | 5500 | 5500 | 0 | 0 | Implementation required |
| 2.16 | [LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER](../drafts/findings/op-products.md#lang-op-overload-assignment-consumer) | `FOpOverloadAssignmentConsumerGenerator` | 24 | 12 | 12 | 0 | Implementation required |
| 2.17 | [LANG-OP-OVERLOAD-BOOLEAN-CONSUMER](../drafts/findings/op-products.md#lang-op-overload-boolean-consumer) | `FOpOverloadBooleanConsumerGenerator` | 20 | 10 | 10 | 0 | Implementation required |
| 2.18 | [LANG-OP-OVERLOAD-DUPLICATE-DECLARATION](../drafts/findings/op-products.md#lang-op-overload-duplicate-declaration) | `FOpOverloadDuplicateDeclarationGenerator` | 7 | 0 | 7 | 0 | Implementation required |
| 2.19 | [LANG-OP-OVERLOAD-INTEGER-CONSUMER](../drafts/findings/op-products.md#lang-op-overload-integer-consumer) | `FOpOverloadIntegerConsumerGenerator` | 120 | 66 | 54 | 0 | Implementation required |
| 2.20 | [LANG-OP-POWER-FRACTIONAL-EXPONENT](../drafts/findings/op-products.md#lang-op-power-fractional-exponent) | `FOpPowerFractionalExponentGenerator` | 80 | 80 | 0 | 0 | Implementation required |
| 2.21 | [LANG-OP-POWER-NEGATIVE-EXPONENT](../drafts/findings/op-products.md#lang-op-power-negative-exponent) | `FOpPowerNegativeExponentGenerator` | 240 | 144 | 96 | 0 | Implementation required |
| 2.22 | [LANG-OP-POWER-UNIVERSAL](../drafts/findings/op-products.md#lang-op-power-universal) | `FOpPowerUniversalGenerator` | 1600 | 848 | 680 | 72 | Implementation required |
| 2.23 | [LANG-OP-RESULT-CONTEXT](../drafts/findings/op-products.md#lang-op-result-context) | `FOpResultContextGenerator` | 240 | 180 | 60 | 0 | Implementation required |
| 2.24 | [LANG-OP-UNARY](../drafts/findings/op-products.md#lang-op-unary) | `FOpUnaryGenerator` | 700 | 700 | 0 | 0 | Implementation required |
| 2.25 | [LANG-OP-UNARY-REJECTION](../drafts/findings/op-products.md#lang-op-unary-rejection) | `FOpUnaryRejectionGenerator` | 40 | 0 | 40 | 0 | Implementation required |
| 3.1 | [LANG-EXPR-ASSOCIATIVITY](../drafts/findings/expr-products.md#lang-expr-associativity) | `FExprAssociativityGenerator` | 72 | 60 | 12 | 0 | Implementation required |
| 3.2 | [LANG-EXPR-CHAIN](../drafts/findings/expr-products.md#lang-expr-chain) | `FExprChainGenerator` | 800 | 160 | 320 | 320 | Implementation required |
| 3.3 | [LANG-EXPR-EVAL-ORDER](../drafts/findings/expr-products.md#lang-expr-eval-order) | `FExprEvalOrderGenerator` | 540 | 135 | 0 | 405 | Implementation required |
| 3.4 | [LANG-EXPR-FAILURE](../drafts/findings/expr-products.md#lang-expr-failure) | `FExprFailureGenerator` | 192 | 0 | 112 | 80 | Implementation required |
| 3.5 | [LANG-EXPR-LAZY-EVALUATION](../drafts/findings/expr-products.md#lang-expr-lazy-evaluation) | `FExprLazyEvaluationGenerator` | 72 | 60 | 0 | 12 | Implementation required |
| 3.6 | [LANG-EXPR-PRECEDENCE](../drafts/findings/expr-products.md#lang-expr-precedence) | `FExprPrecedenceGenerator` | 432 | 231 | 201 | 0 | Implementation required |
| 3.7 | [LANG-EXPR-PRIMARY-CONTEXT](../drafts/findings/expr-products.md#lang-expr-primary-context) | `FExprPrimaryContextGenerator` | 220 | 174 | 46 | 0 | Implementation required |
| 3.8 | [LANG-EXPR-RESOLUTION](../drafts/findings/expr-products.md#lang-expr-resolution) | `FExprResolutionGenerator` | 224 | 112 | 112 | 0 | Implementation required |
| 3.9 | [LANG-EXPR-SOURCE-BOUNDARY](../drafts/findings/expr-products.md#lang-expr-source-boundary) | `FExprSourceBoundaryGenerator` | 210 | 210 | 0 | 0 | Implementation required |
| 3.10 | [LANG-EXPR-VALUE-MUTATION](../drafts/findings/expr-products.md#lang-expr-value-mutation) | `FExprValueMutationGenerator` | 140 | 60 | 80 | 0 | Implementation required |
| 4.1 | [LANG-CONV-ABI](../drafts/findings/conv-products.md#lang-conv-abi) | `FConvAbiGenerator` | 12 | 12 | 0 | 0 | Implementation required |
| 4.2 | [LANG-CONV-BOOL-CONTEXT](../drafts/findings/conv-products.md#lang-conv-bool-context) | `FConvBoolContextGenerator` | 234 | 18 | 216 | 0 | Implementation required |
| 4.3 | [LANG-CONV-ENUM-ALIAS](../drafts/findings/conv-products.md#lang-conv-enum-alias) | `FConvEnumAliasGenerator` | 1260 | 1130 | 130 | 0 | Implementation required |
| 4.4 | [LANG-CONV-FAILURE](../drafts/findings/conv-products.md#lang-conv-failure) | `FConvFailureGenerator` | 24 | 4 | 14 | 6 | Implementation required |
| 4.5 | [LANG-CONV-FLOAT-FINITE-SPECIAL](../drafts/findings/conv-products.md#lang-conv-float-finite-special) | `FConvFloatFiniteSpecialGenerator` | 240 | 240 | 0 | 0 | Implementation required |
| 4.6 | [LANG-CONV-FLOAT64-TO-FLOAT32-RANGE](../drafts/findings/conv-products.md#lang-conv-float64-to-float32-range) | `FConvFloat64ToFloat32RangeGenerator` | 8 | 8 | 0 | 0 | Implementation required |
| 4.7 | [LANG-CONV-NONFINITE-PRECONVERSION](../drafts/findings/conv-products.md#lang-conv-nonfinite-preconversion) | `FConvNonfinitePreconversionGenerator` | 240 | 0 | 0 | 240 | Implementation required |
| 4.8 | [LANG-CONV-NUMERIC](../drafts/findings/conv-products.md#lang-conv-numeric) | `FConvNumericGenerator` | 4200 | 4200 | 0 | 0 | Implementation required |
| 4.9 | [LANG-CONV-OBJECT-CAST](../drafts/findings/conv-products.md#lang-conv-object-cast) | `FConvObjectCastGenerator` | 180 | 108 | 72 | 0 | Implementation required |
| 4.10 | [LANG-CONV-OVERLOAD](../drafts/findings/conv-products.md#lang-conv-overload) | `FConvOverloadGenerator` | 144 | 72 | 72 | 0 | Implementation required |
| 4.11 | [LANG-CONV-VALUE-OBJECT](../drafts/findings/conv-products.md#lang-conv-value-object) | `FConvValueObjectGenerator` | 720 | 200 | 520 | 0 | Implementation required |
| 5.1 | [LANG-FN-ARG-SOURCE](../drafts/findings/fn-products.md#lang-fn-arg-source) | `FFnArgSourceGenerator` | 44 | 22 | 17 | 5 | Implementation required |
| 5.2 | [LANG-FN-ARITY-TARGET](../drafts/findings/fn-products.md#lang-fn-arity-target) | `FFnArityTargetGenerator` | 21 | 21 | 0 | 0 | Implementation required |
| 5.3 | [LANG-FN-ARITY-TYPE-STRESS](../drafts/findings/fn-products.md#lang-fn-arity-type-stress) | `FFnArityTypeStressGenerator` | 96 | 96 | 0 | 0 | Implementation required |
| 5.4 | [LANG-FN-DEFAULTS](../drafts/findings/fn-products.md#lang-fn-defaults) | `FFnDefaultsGenerator` | 72 | 57 | 15 | 0 | Implementation required |
| 5.5 | [LANG-FN-DIRECTION-DEFAULT](../drafts/findings/fn-products.md#lang-fn-direction-default) | `FFnDirectionDefaultGenerator` | 528 | 309 | 219 | 0 | Implementation required |
| 5.6 | [LANG-FN-INDIRECT-IMPORTED](../drafts/findings/fn-products.md#lang-fn-indirect-imported) | `FFnIndirectImportedGenerator` | 6 | 0 | 6 | 0 | Implementation required |
| 5.7 | [LANG-FN-INDIRECT-MIXIN](../drafts/findings/fn-products.md#lang-fn-indirect-mixin) | `FFnIndirectMixinGenerator` | 6 | 4 | 2 | 0 | Implementation required |
| 5.8 | [LANG-FN-INDIRECT-REGISTERED-FUNCDEF](../drafts/findings/fn-products.md#lang-fn-indirect-registered-funcdef) | `FFnIndirectRegisteredFuncdefGenerator` | 6 | 0 | 6 | 0 | Implementation required |
| 5.9 | [LANG-FN-INDIRECT-SCRIPT-FUNCDEF](../drafts/findings/fn-products.md#lang-fn-indirect-script-funcdef) | `FFnIndirectScriptFuncdefGenerator` | 6 | 0 | 6 | 0 | Implementation required |
| 5.10 | [LANG-FN-MIXIN-DIRECT-DISPATCH](../drafts/findings/fn-products.md#lang-fn-mixin-direct-dispatch) | `FFnMixinDirectDispatchGenerator` | 2 | 2 | 0 | 0 | Implementation required |
| 5.11 | [LANG-FN-MIXIN-FREE-CALL-REJECTION](../drafts/findings/fn-products.md#lang-fn-mixin-free-call-rejection) | `FFnMixinFreeCallRejectionGenerator` | 2 | 0 | 2 | 0 | Implementation required |
| 5.12 | [LANG-FN-OVERLOAD](../drafts/findings/fn-products.md#lang-fn-overload) | `FFnOverloadGenerator` | 28 | 14 | 14 | 0 | Implementation required |
| 5.13 | [LANG-FN-PARAM-DIRECTION](../drafts/findings/fn-products.md#lang-fn-param-direction) | `FFnParamDirectionGenerator` | 60 | 60 | 0 | 0 | Implementation required |
| 5.14 | [LANG-FN-PARAM-POSITION](../drafts/findings/fn-products.md#lang-fn-param-position) | `FFnParamPositionGenerator` | 180 | 180 | 0 | 0 | Implementation required |
| 5.15 | [LANG-FN-RECURSION](../drafts/findings/fn-products.md#lang-fn-recursion) | `FFnRecursionGenerator` | 24 | 6 | 12 | 6 | Implementation required |
| 5.16 | [LANG-FN-RETURN](../drafts/findings/fn-products.md#lang-fn-return) | `FFnReturnGenerator` | 136 | 86 | 33 | 17 | Implementation required |
| 5.17 | [LANG-FN-SIGNATURE-SHAPE](../drafts/findings/fn-products.md#lang-fn-signature-shape) | `FFnSignatureShapeGenerator` | 192 | 192 | 0 | 0 | Implementation required |
| 5.18 | [LANG-FN-TYPED-DEFAULTS](../drafts/findings/fn-products.md#lang-fn-typed-defaults) | `FFnTypedDefaultsGenerator` | 168 | 168 | 0 | 0 | Implementation required |
| 5.19 | [LANG-FN-VALUE-LIFECYCLE](../drafts/findings/fn-products.md#lang-fn-value-lifecycle) | `FFnValueLifecycleGenerator` | 24 | 6 | 0 | 18 | Implementation required |
| 6.1 | [LANG-VAR-ASSIGN-TARGET](../drafts/findings/var-products.md#lang-var-assign-target) | `FVarAssignTargetGenerator` | 595 | 212 | 383 | 0 | Implementation required |
| 6.2 | [LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT](../drafts/findings/var-products.md#lang-var-counted-reference-assignment) | `FVarCountedReferenceAssignmentGenerator` | 7 | 6 | 0 | 1 | Implementation required |
| 6.3 | [LANG-VAR-FAILURE-BOUNDARY](../drafts/findings/var-products.md#lang-var-failure-boundary) | `FVarFailureBoundaryGenerator` | 28 | 12 | 12 | 4 | Implementation required |
| 6.4 | [LANG-VAR-INIT-STORAGE](../drafts/findings/var-products.md#lang-var-init-storage) | `FVarInitStorageGenerator` | 735 | 713 | 22 | 0 | Implementation required |
| 6.5 | [LANG-VAR-LIFETIME](../drafts/findings/var-products.md#lang-var-lifetime) | `FVarLifetimeGenerator` | 100 | 80 | 0 | 20 | Implementation required |
| 6.6 | [LANG-VAR-LOOP-DECL-LIFETIME](../drafts/findings/var-products.md#lang-var-loop-decl-lifetime) | `FVarLoopDeclLifetimeGenerator` | 200 | 168 | 0 | 32 | Implementation required |
| 6.7 | [LANG-VAR-REFERENCE-INIT](../drafts/findings/var-products.md#lang-var-reference-init) | `FVarReferenceInitGenerator` | 150 | 128 | 20 | 2 | Implementation required |
| 6.8 | [LANG-VAR-SHADOW](../drafts/findings/var-products.md#lang-var-shadow) | `FVarShadowGenerator` | 110 | 89 | 21 | 0 | Implementation required |
| 7.1 | [LANG-REF-DIRECTION](../drafts/findings/ref-products.md#lang-ref-direction) | `FRefDirectionGenerator` | 96 | 96 | 0 | 0 | Implementation required |
| 7.2 | [LANG-REF-DIRECTION-FORK-GLOBAL](../drafts/findings/ref-products.md#lang-ref-direction-fork-global) | `FRefDirectionForkGlobalGenerator` | 1 | 0 | 1 | 0 | Implementation required |
| 7.3 | [LANG-REF-FAILURE](../drafts/findings/ref-products.md#lang-ref-failure) | `FRefFailureGenerator` | 20 | 0 | 18 | 2 | Implementation required |
| 7.4 | [LANG-REF-FORK-DERIVED-INREF](../drafts/findings/ref-products.md#lang-ref-fork-derived-inref) | `FRefForkDerivedInrefGenerator` | 1 | 0 | 1 | 0 | Implementation required |
| 7.5 | [LANG-REF-LIFETIME](../drafts/findings/ref-products.md#lang-ref-lifetime) | `FRefLifetimeGenerator` | 200 | 150 | 50 | 0 | Implementation required |
| 7.6 | [LANG-REF-RESOLUTION](../drafts/findings/ref-products.md#lang-ref-resolution) | `FRefResolutionGenerator` | 160 | 111 | 49 | 0 | Implementation required |
| 7.7 | [LANG-REF-SOURCE-OP](../drafts/findings/ref-products.md#lang-ref-source-op) | `FRefSourceOpGenerator` | 288 | 193 | 88 | 7 | Implementation required |
| 8.1 | [LANG-PROP-ACCESSOR](../drafts/findings/prop-products.md#lang-prop-accessor) | `FPropAccessorGenerator` | 72 | 36 | 28 | 8 | Implementation required |
| 8.2 | [LANG-PROP-COPY-INDEPENDENCE](../drafts/findings/prop-products.md#lang-prop-copy-independence) | `FPropCopyIndependenceGenerator` | 459 | 459 | 0 | 0 | Implementation required |
| 8.3 | [LANG-PROP-FAILURE](../drafts/findings/prop-products.md#lang-prop-failure) | `FPropFailureGenerator` | 56 | 0 | 36 | 20 | Implementation required |
| 8.4 | [LANG-PROP-FORK-SEMANTICS](../drafts/findings/prop-products.md#lang-prop-fork-semantics) | `FPropForkSemanticsGenerator` | 13 | 1 | 12 | 0 | Implementation required |
| 8.5 | [LANG-PROP-INDEXED](../drafts/findings/prop-products.md#lang-prop-indexed) | `FPropIndexedGenerator` | 468 | 129 | 339 | 0 | Implementation required |
| 8.6 | [LANG-PROP-INIT-ORDER](../drafts/findings/prop-products.md#lang-prop-init-order) | `FPropInitOrderGenerator` | 1500 | 1500 | 0 | 0 | Implementation required |
| 8.7 | [LANG-PROP-REBUILD](../drafts/findings/prop-products.md#lang-prop-rebuild) | `FPropRebuildGenerator` | 90 | 90 | 0 | 0 | Implementation required |
| 8.8 | [LANG-PROP-VALUE-OP](../drafts/findings/prop-products.md#lang-prop-value-op) | `FPropValueOpGenerator` | 300 | 243 | 57 | 0 | Implementation required |
| 8.9 | [LANG-PROP-VISIBILITY](../drafts/findings/prop-products.md#lang-prop-visibility) | `FPropVisibilityGenerator` | 60 | 42 | 18 | 0 | Implementation required |
| 9.1 | [LANG-INH-ACCESS](../drafts/findings/inh-products.md#lang-inh-access) | `FInhAccessGenerator` | 60 | 37 | 23 | 0 | Implementation required |
| 9.2 | [LANG-INH-CAST](../drafts/findings/inh-products.md#lang-inh-cast) | `FInhCastGenerator` | 60 | 60 | 0 | 0 | Implementation required |
| 9.3 | [LANG-INH-CLASS-RULE](../drafts/findings/inh-products.md#lang-inh-class-rule) | `FInhClassRuleGenerator` | 64 | 24 | 40 | 0 | Implementation required |
| 9.4 | [LANG-INH-DISPATCH](../drafts/findings/inh-products.md#lang-inh-dispatch) | `FInhDispatchGenerator` | 360 | 360 | 0 | 0 | Implementation required |
| 9.5 | [LANG-INH-OVERRIDE-SIGNATURE](../drafts/findings/inh-products.md#lang-inh-override-signature) | `FInhOverrideSignatureGenerator` | 54 | 36 | 18 | 0 | Implementation required |
| 10.1 | [LANG-DECL-COLLISION](../drafts/findings/decl-products.md#lang-decl-collision) | `FDeclCollisionGenerator` | 96 | 48 | 48 | 0 | Implementation required |
| 10.2 | [LANG-DECL-FAILURE-RECOVERY](../drafts/findings/decl-products.md#lang-decl-failure-recovery) | `FDeclFailureRecoveryGenerator` | 18 | 0 | 18 | 0 | Implementation required |
| 10.3 | [LANG-DECL-FAMILY-SCOPE-ORDER](../drafts/findings/decl-products.md#lang-decl-family-scope-order) | `FDeclFamilyScopeOrderGenerator` | 300 | 300 | 0 | 0 | Implementation required |
| 11.1 | [LANG-CTOR-BOUNDARY](../drafts/findings/ctor-products.md#lang-ctor-boundary) | `FCtorBoundaryGenerator` | 68 | 20 | 40 | 8 | Implementation required |
| 11.2 | [LANG-CTOR-KIND-CALL](../drafts/findings/ctor-products.md#lang-ctor-kind-call) | `FCtorKindCallGenerator` | 288 | 257 | 31 | 0 | Implementation required |
| 11.3 | [LANG-CTOR-ORDER-FAILURE](../drafts/findings/ctor-products.md#lang-ctor-order-failure) | `FCtorOrderFailureGenerator` | 128 | 16 | 0 | 112 | Implementation required |
| 11.4 | [LANG-CTOR-PARAM-SELECT](../drafts/findings/ctor-products.md#lang-ctor-param-select) | `FCtorParamSelectGenerator` | 300 | 152 | 148 | 0 | Implementation required |
| 11.5 | [LANG-CTOR-SPECIAL-POLICY](../drafts/findings/ctor-products.md#lang-ctor-special-policy) | `FCtorSpecialPolicyGenerator` | 64 | 44 | 20 | 0 | Implementation required |
| 11.6 | [LANG-CTOR-TRANSFER](../drafts/findings/ctor-products.md#lang-ctor-transfer) | `FCtorTransferGenerator` | 448 | 448 | 0 | 0 | Implementation required |
| 11.7 | [LANG-CTOR-VISIBILITY](../drafts/findings/ctor-products.md#lang-ctor-visibility) | `FCtorVisibilityGenerator` | 72 | 21 | 51 | 0 | Implementation required |
| 12.1 | [LANG-DTOR-DECLARATION](../drafts/findings/dtor-products.md#lang-dtor-declaration) | `FDtorDeclarationGenerator` | 52 | 40 | 4 | 8 | Implementation required |
| 12.2 | [LANG-DTOR-OWNER-EXIT](../drafts/findings/dtor-products.md#lang-dtor-owner-exit) | `FDtorOwnerExitGenerator` | 666 | 522 | 0 | 144 | Implementation required |
| 12.3 | [LANG-DTOR-PARTIAL](../drafts/findings/dtor-products.md#lang-dtor-partial) | `FDtorPartialGenerator` | 168 | 126 | 0 | 42 | Implementation required |
| 13.1 | [LANG-FE-PROTOCOL](../drafts/findings/foreach-products.md#lang-fe-protocol) | `FForeachProtocolGenerator` | 250 | 45 | 190 | 15 | Implementation required |
| 13.2 | [LANG-FE-SIZE-VARIABLE](../drafts/findings/foreach-products.md#lang-fe-size-variable) | `FForeachSizeVariableGenerator` | 640 | 319 | 288 | 33 | Implementation required |
| 13.3 | [LANG-FE-STRUCTURAL-MUTATION](../drafts/findings/foreach-products.md#lang-fe-structural-mutation) | `FForeachStructuralMutationGenerator` | 36 | 36 | 0 | 0 | Implementation required |
| 13.4 | [LANG-FE-TRANSFER-LIFETIME](../drafts/findings/foreach-products.md#lang-fe-transfer-lifetime) | `FForeachTransferLifetimeGenerator` | 84 | 72 | 0 | 12 | Implementation required |
