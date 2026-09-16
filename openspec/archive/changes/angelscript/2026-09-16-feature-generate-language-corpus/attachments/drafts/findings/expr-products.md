# Expressions product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/expr. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 10. Declared cells: 2902.

## LANG-EXPR-ASSOCIATIVITY

- Class: `AngelscriptTest::Generate::FExprAssociativityGenerator`; task: 3.1.
- Cells: **72**; categories: normal=60, reject=12, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildPrecedenceSource(const FExprAssociativityParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-EXPR-ASSOCIATIVITY-UNPARENTHESIZED-MULTIPLICATIVE-REPEATED_OPERATOR`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Expressions/AngelscriptNativeExpressionPrecedenceTests.cpp`.
- Card SHA256: `b54d4ee07fd3e49341f266f6e2bb7a31c39075852d4555ba88315413b90d93d3`; inspected source SHA256: `c905beff4e0f1e88fc658be951ea68b6260e1440d8d564f8a5e933cbcec67692`.
- Axis tables and tokens in documented order: `*Cases`; `GroupingCases` / `unparenthesized` / `left_parenthesized` / `right_parenthesized`; `LevelCases` / `multiplicative` / `additive` / `shift` / `relational` / `equality` / `bitwise_and` / `bitwise_xor` / `bitwise_or` / `logical_and` / `logical_or` / `conditional` / `assignment`; `SequenceCases` / `repeated_operator` / `mixed_same_level`.
- Construction/oracle expressions retained from the card: `VerifyCell`; `BuildAssociativityExpressions`; `BuildPrecedenceSource`; `GetExpected`; `SelectedUsesLeftControl`; `ObservePrecedence`; `!bRightAssociative`; `conditional`; `assignment`; `logical_and`; `logical_or`; `repeated_operator`; `A && B && C`; `A || B || C`; `A = B = C`; `A += B = C`; `IsForkExpressionBoundary`; `BuildRejectSource`; `mixed_same_level`; `Q`; `&&`; `||`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-EXPR-CHAIN

- Class: `AngelscriptTest::Generate::FExprChainGenerator`; task: 3.2.
- Cells: **800**; categories: normal=160, reject=320, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=320, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildExpressionChainSource(const FExprChainParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-EXPR-CHAIN-INITIALIZER-TWO-CALL_MEMBER-VALID`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Expressions/AngelscriptNativeExpressionChainTests.cpp`.
- Card SHA256: `cebbdca7702ea793378986074b06bbb12910fc078bb0215a97093eb868c79b14`; inspected source SHA256: `337fbf5c51087417c7f7b2242c6ba5cce5c73c6100173a2c2342582845a62948`.
- Axis tables and tokens in documented order: `*Cases`; `ContextCases` / `initializer` / `argument` / `return` / `condition` / `assignment`; `DepthCases` / `two` / `three` / `eight` / `deep_boundary`; `ShapeCases` / `call_member` / `member_call` / `index_member` / `member_index` / `cast_member` / `call_index_cast` / `member_call_index` / `cast_call_member_index`; `StateCases` / `valid` / `null_receiver` / `invalid_intermediate` / `exception_intermediate` / `missing_terminal`.
- Construction/oracle expressions retained from the card: `ExpectedValue`; `IsCompileFailure`; `FailureStage`; `valid`; `GetExpected`; `Context==condition ? 1 : ExpectedValue`; `Call=1`; `Member=3`; `Index=5`; `Cast=7`; `two/three/eight/deep_boundary`; `invalid_intermediate`; `missing_terminal`; `BuildRejectSource`; `null_receiver`; `Null pointer access`; `exception_intermediate`; `FailureStage=(Depth+1)/2`; `1 / Zero`; `Divide by zero`; `SetException`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-EXPR-EVAL-ORDER

- Class: `AngelscriptTest::Generate::FExprEvalOrderGenerator`; task: 3.3.
- Cells: **540**; categories: normal=135, reject=0, divide_by_zero=405, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildEagerEvaluationSource(const FExprEvalOrderParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-EXPR-EVAL-ORDER-BINARY-TWO-COMPLETE-SINGLE_LINE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Expressions/AngelscriptNativeEagerExpressionOrderTests.cpp`.
- Card SHA256: `20e8eb3a953fb8b2ca6da5b5754b86b6eb420cfb194d1755869bd93d8d4adfb1`; inspected source SHA256: `47eee97ca43519a1846aacf26644f03dadf3e75c7d8a713e26bf33bc67295165`.
- Axis tables and tokens in documented order: `*Cases`; `EagerCompositionCases` / `binary` / `assignment` / `compound_assignment` / `call_arguments` / `constructor_arguments` / `index_arguments` / `call_chain` / `member_index_chain` / `nested_cast`; `EagerOperandCountCases` / `two` / `three` / `eight`; `EagerOutcomeCases` / `complete` / `exception_first` / `exception_middle` / `exception_last`; `EagerSourceShapeCases` / `single_line` / `whitespace` / `comments` / `multiline` / `nested_parentheses`.
- Construction/oracle expressions retained from the card: `ExpectedEagerResult`; `ExpectedEagerMarkers`; `ExpectsEagerException`; `complete`; `GetExpected`; `n(n+1)/2`; `compound_assignment`; `+10`; `n`; `exception_first`; `exception_middle`; `exception_last`; `RecordEagerStage(..., true)`; `CompleteEagerBoundary`; `1 / Zero`; `Divide by zero`; `SetException`; `throw`; `Count==2 && exception_middle`; `call_arguments`; `constructor_arguments`; `index_arguments`; `call_chain`; `member_index_chain`; `1000`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-EXPR-FAILURE

- Class: `AngelscriptTest::Generate::FExprFailureGenerator`; task: 3.4.
- Cells: **192**; categories: normal=0, reject=112, divide_by_zero=80, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildExpressionFailureSource(const FExprFailureParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-EXPR-FAILURE-INITIALIZER-DIVIDE_ZERO-FRESH_MODULE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Expressions/AngelscriptNativeExpressionFailureTests.cpp`.
- Card SHA256: `7ed015a8564feb92be119737d5ad354904b7a6981836615abc282a8283ec08c8`; inspected source SHA256: `149a24278f22c215d907e75c8d0243afcf42c32ecdf5cee61301828c0f763f8a`.
- Axis tables and tokens in documented order: `*Cases`; `ContextCases` / `initializer` / `assignment` / `argument` / `return` / `condition` / `loop_clause` / `switch_selector` / `index`; `FailureCases` / `invalid_lvalue` / `missing_delimiter` / `malformed_ternary` / `missing_symbol` / `ambiguous_symbol` / `inaccessible_member` / `missing_member` / `divide_zero` / `index_out_of_range` / `null_access` / `exception_left` / `exception_right`; `RecoveryCases` / `fresh_module` / `rebuild_or_context_reuse`.
- Construction/oracle expressions retained from the card: `IsCompileFailure`; `ExpectedExceptionText`; `ExpectedTrace`; `GetExpected`; `invalid_lvalue`; `missing_delimiter`; `malformed_ternary`; `missing_symbol`; `ambiguous_symbol`; `inaccessible_member`; `missing_member`; `BuildRejectSource`; `BuildAllSource`; `divide_zero`; `Divide by zero`; `exception_left`; `exception_right`; `ThrowFailureStage`; `SetException`; `1 / Zero`; `throw`; `index_out_of_range`; `Expression index out of range`; `null_access`; `Null pointer access`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-EXPR-LAZY-EVALUATION

- Class: `AngelscriptTest::Generate::FExprLazyEvaluationGenerator`; task: 3.5.
- Cells: **72**; categories: normal=60, reject=0, divide_by_zero=12, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildLazyEvaluationSource(const FExprLazyEvaluationParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-EXPR-LAZY-EVALUATION-LOGICAL_AND-VALUE-FALSE-SINGLE_LINE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Expressions/AngelscriptNativeLazyExpressionEvaluationTests.cpp`.
- Card SHA256: `d9140e1c4206666af7f0f0361dba518383361a2d5b4466771172d7d78ba8c243`; inspected source SHA256: `277e98854e10102e8662532f1c415a2c7c51c54faa2559dc886222673037baed`.
- Axis tables and tokens in documented order: `*Cases`; `FormCases` / `logical_and` / `logical_or` / `conditional`; `OperandOutcomeCases` / `value` / `side_effect` / `exception`; `SelectorCases` / `false` / `true`; `SourceShapeCases` / `single_line` / `comments` / `multiline` / `parenthesized`.
- Construction/oracle expressions retained from the card: `ExpectedResult`; `ExpectedMarkers`; `IsGuardedOperandSelected`; `GetExpected`; `logical_and`; `Selector?1:0`; `logical_or`; `conditional`; `Selector?41:23`; `exception`; `RaiseGuarded*`; `1 / Zero`; `Divide by zero`; `throw`; `side_effect`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-EXPR-PRECEDENCE

- Class: `AngelscriptTest::Generate::FExprPrecedenceGenerator`; task: 3.6.
- Cells: **432**; categories: normal=231, reject=201, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildPrecedenceSource(const FExprPrecedenceParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-EXPR-PRECEDENCE-UNPARENTHESIZED-MULTIPLICATIVE-ADDITIVE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Expressions/AngelscriptNativeExpressionPrecedenceTests.cpp`.
- Card SHA256: `6fd37b26154d235d95f36779cad20f116217d9a0c5969fa859af265975ea4678`; inspected source SHA256: `c905beff4e0f1e88fc658be951ea68b6260e1440d8d564f8a5e933cbcec67692`.
- Axis tables and tokens in documented order: `*Cases`; `GroupingCases` / `unparenthesized` / `left_parenthesized` / `right_parenthesized`; `LevelCases` / `multiplicative` / `additive` / `shift` / `relational` / `equality` / `bitwise_and` / `bitwise_xor` / `bitwise_or` / `logical_and` / `logical_or` / `conditional` / `assignment`.
- Construction/oracle expressions retained from the card: `VerifyCell`; `SelectedUsesLeftControl`; `IsForkExpressionBoundary`; `GetExpected`; `ObservePrecedence`; `MarkPrecedence`; ` = `; ` += `; `Q`; `&&`; `||`; `?`; ` < `; ` >= `; ` == `; ` != `; `BuildRejectSource`; `Forms.bUnparenthesizedUsesLeft`; `Left.Rank<=Right.Rank`; `BuildPrecedenceExpressions`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-EXPR-PRIMARY-CONTEXT

- Class: `AngelscriptTest::Generate::FExprPrimaryContextGenerator`; task: 3.7.
- Cells: **220**; categories: normal=174, reject=46, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildPrimaryExpressionSource(const FExprPrimaryContextParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-EXPR-PRIMARY-CONTEXT-INITIALIZER-INT_LITERAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Expressions/AngelscriptNativePrimaryExpressionTests.cpp`.
- Card SHA256: `d9e3cb6d04f3586adf49917e9decfedfcc2495dbac4367541e42262444b7b651`; inspected source SHA256: `57955d0dbaead38f310fb4b1c58d6bac17ca598bab6a6885579f23d4e677a2c9`.
- Axis tables and tokens in documented order: `*Cases`; `ContextCases` / `initializer` / `assignment_rhs` / `assignment_lhs` / `argument` / `return` / `condition` / `loop_clause` / `switch_selector` / `index` / `property_accessor`; `PrimaryCases` / `int_literal` / `bool_literal` / `enum_literal` / `null_literal` / `local_identifier` / `const_identifier` / `reference_identifier` / `scoped_constant` / `scoped_enum` / `parenthesized_scalar` / `parenthesized_lvalue` / `global_function_call` / `method_call` / `value_constructor` / `reference_constructor` / `member_field` / `virtual_property` / `indexed_property` / `explicit_numeric_cast` / `object_cast` / `base_cast` / `derived_cast`.
- Construction/oracle expressions retained from the card: `IsLegal`; `GetExpected`; `ObservePrimary`; `assignment_lhs`; `bAssignable`; `switch_selector`; `bIntegralContext`; `index`; `property_accessor`; `BuildRejectSource`; `null_literal`; `object_cast`; `nullptr`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-EXPR-RESOLUTION

- Class: `AngelscriptTest::Generate::FExprResolutionGenerator`; task: 3.8.
- Cells: **224**; categories: normal=112, reject=112, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildExpressionResolutionSource(const FExprResolutionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-EXPR-RESOLUTION-INITIALIZER-IDENTIFIER-EXACT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Expressions/AngelscriptNativeExpressionResolutionTests.cpp`.
- Card SHA256: `a57189dc8580549a558cf576fd5d883e453eddf2a67a14f09e4f14ec13532095`; inspected source SHA256: `fa022fc0ef11d3b7afaa43aec22efedf83db0ebba24f9a87c98755f64bb30941`.
- Axis tables and tokens in documented order: `*Cases`; `ContextCases` / `initializer` / `assignment` / `argument` / `return` / `condition` / `index` / `member_receiver`; `ShapeCases` / `identifier` / `call` / `member` / `scoped_name`; `StateCases` / `exact` / `namespace_qualified` / `overload` / `conversion` / `missing` / `ambiguous` / `inaccessible` / `wrong_type`.
- Construction/oracle expressions retained from the card: `ExpectedMarker`; `IsSuccessfulState`; `exact`; `namespace_qualified`; `overload`; `conversion`; `GetExpected`; `Base + ShapeOrdinal`; `identifier=1`; `call=2`; `member=3`; `scoped_name=4`; `exact=100`; `namespace_qualified=200`; `overload=300`; `conversion=400`; `missing`; `ambiguous`; `inaccessible`; `wrong_type`; `BuildRejectSource`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-EXPR-SOURCE-BOUNDARY

- Class: `AngelscriptTest::Generate::FExprSourceBoundaryGenerator`; task: 3.9.
- Cells: **210**; categories: normal=210, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildExpressionBoundarySource(const FExprSourceBoundaryParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-EXPR-SOURCE-BOUNDARY-FIRST-INITIALIZER-PARENTHESES_ONE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Expressions/AngelscriptNativeExpressionBoundaryTests.cpp`.
- Card SHA256: `89bf5fc5b5a09a28b9e3afadc10798f5593fc60f7e4ff01bb63d144c76db287b`; inspected source SHA256: `195a828add8e3419b774b8646eaa26bdeeb5f9112712ca2bef66a1067810aaff`.
- Axis tables and tokens in documented order: `*Cases`; `BuildCases` / `first` / `same_rebuild` / `changed_rebuild`; `ContextCases` / `initializer` / `argument` / `return` / `condition` / `index`; `ScenarioCases` / `parentheses_one` / `parentheses_eight` / `parentheses_sixty_four` / `chain_one` / `chain_eight` / `chain_thirty_two` / `arguments_zero` / `arguments_one` / `arguments_many` / `numeric_minimum` / `numeric_maximum` / `whitespace` / `comments` / `multiline`.
- Construction/oracle expressions retained from the card: `ExpectedBoundaryResult`; `GetExpected`; `int64`; `int32`; `Seed`; `changed_rebuild ? 58 : 41`; `MIN_int32`; `+17`; `MAX_int32`; `-17`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-EXPR-VALUE-MUTATION

- Class: `AngelscriptTest::Generate::FExprValueMutationGenerator`; task: 3.10.
- Cells: **140**; categories: normal=60, reject=80, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildExpressionValueCategorySource(const FExprValueMutationParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-EXPR-VALUE-MUTATION-MUTABLE_LVALUE-ASSIGN-LOCAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Expressions/AngelscriptNativeExpressionValueCategoryTests.cpp`.
- Card SHA256: `65e46d8946792523b2e9df661afeeeea269f914b3dc7786523e89f94c9037699`; inspected source SHA256: `9aea179d9216141224f12d280b8ec9062f9ac7f0a692234985b3e3b09cd34b2e`.
- Axis tables and tokens in documented order: `*Cases`; `CategoryCases` / `mutable_lvalue` / `const_lvalue` / `temporary` / `reference_alias` / `field` / `property` / `invalid_non_lvalue`; `MutationCases` / `assign` / `compound_assign` / `prefix_increment` / `postfix_increment` / `out_argument`; `PlacementCases` / `local` / `global` / `member` / `indexed`.
- Construction/oracle expressions retained from the card: `Category.bWritable`; `Mutation.ExpectedResult`; `ExpectedAfter`; `mutable_lvalue`; `reference_alias`; `field`; `GetExpected`; `ExpectedResult*10000 + ExpectedAfter*100 + ExpectedAfter`; `assign`; `compound_assign`; `prefix_increment`; `postfix_increment`; `out_argument`; `const_lvalue`; `temporary`; `property`; `invalid_non_lvalue`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
