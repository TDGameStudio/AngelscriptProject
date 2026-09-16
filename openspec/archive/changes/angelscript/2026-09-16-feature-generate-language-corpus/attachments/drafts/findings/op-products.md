# Operators product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/op. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 25. Declared cells: 12453.

## LANG-OP-ASSIGNMENT

- Class: `AngelscriptTest::Generate::FOpAssignmentGenerator`; task: 2.1.
- Cells: **444**; categories: normal=444, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildLegalSource(const FOpAssignmentParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-ASSIGNMENT-LOCAL-ASSIGN_INT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeAssignmentOperatorTests.cpp`.
- Card SHA256: `093d3c9b3cfa2b7d0543c6bc00d7cac871e219eecfe760c4b8457c15f46e9ace`; inspected source SHA256: `0ca8181cb876e5786122196c8c3c0da7a3d35e683719b703880f614d9dbbcf6d`.
- Axis tables and tokens in documented order: `*Cases`; `CategoryCases` / `local` / `field` / `property` / `alias`; `OperationCases` / `assign` / `add_assign` / `subtract_assign` / `multiply_assign` / `divide_assign` / `modulo_assign` / `power_assign` / `and_assign` / `or_assign` / `xor_assign` / `shift_left_assign` / `shift_right_logical_assign` / `shift_right_arithmetic_assign`; `SupportsOperation` / `assign` / `+−*/%` / `**=`.
- Construction/oracle expressions retained from the card: `SupportsOperation`; `ExpectedBits`; `=`; `%`; `**=`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-ASSIGNMENT-TARGET-REJECTION

- Class: `AngelscriptTest::Generate::FOpAssignmentTargetRejectionGenerator`; task: 2.2.
- Cells: **222**; categories: normal=0, reject=222, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildTargetRejectionSource(const FOpAssignmentTargetRejectionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-ASSIGNMENT-TARGET-REJECTION-CONST_INVALID-ASSIGN_INT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeAssignmentTargetRejectionTests.cpp`.
- Card SHA256: `f21e9957fafd46a29ae875199883fec55d36f69928c5af6ef6c04e103c1379bb`; inspected source SHA256: `3c4c6b76ec3cd692a268b083c681da0142f98ed02ef9afea0fd28032e6a4cb38`.
- Axis tables and tokens in documented order: `*Cases`; `RejectedTargetCases` / `const_invalid` / `temporary_invalid`; `OperationType` / `SupportsOperation==true` / `assign_int`.
- Construction/oracle expressions retained from the card: `VerifyRejectedSource`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-ASSIGNMENT-TYPE-REJECTION

- Class: `AngelscriptTest::Generate::FOpAssignmentTypeRejectionGenerator`; task: 2.3.
- Cells: **128**; categories: normal=0, reject=128, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildTypeRejectionSource(const FOpAssignmentTypeRejectionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-ASSIGNMENT-TYPE-REJECTION-LOCAL-ADD_ASSIGN_BOOL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeAssignmentTypeRejectionTests.cpp`.
- Card SHA256: `1fa2e62d48b0e8bd2e1f8e4403f368d614aaff684eaebdd68a260e87f1658ad7`; inspected source SHA256: `4502a7d1b0d7b6f360b9e5cfe3d658d6c2d5660c0191b166c0d4a541b8759cd2`.
- Axis tables and tokens in documented order: `*Cases`; `CategoryCases` / `local` / `field` / `property` / `alias`; `+−*/%` / `**=`.
- Construction/oracle expressions retained from the card: `SupportsOperation`; `VerifyRejectedSource`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-COMPARISON-ENUM-ALIAS

- Class: `AngelscriptTest::Generate::FOpComparisonEnumAliasGenerator`; task: 2.4.
- Cells: **144**; categories: normal=144, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildIntegralComparisonSource(const FOpComparisonEnumAliasParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-COMPARISON-ENUM-ALIAS-ENUM-LESS-EQUAL_ZERO-LEFT_RIGHT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeEnumAliasComparisonOperatorTests.cpp`.
- Card SHA256: `28f5559f75ad31c0d2b0be425e751a761d9ff5246438e50a59b56f4b594da0ac`; inspected source SHA256: `b483f875b0fd089be884d4dbba728bd6d01d12e23a21c6140a1907f15dc72de6`.
- Axis tables and tokens in documented order: `*Cases`; `IntegralFamilyCases` / `enum` / `alias`; `OperatorCases` / `less` / `less_equal` / `greater` / `greater_equal` / `equal` / `not_equal`; `IntegralPairCases` / `equal_zero` / `equal_named` / `below_adjacent` / `above_adjacent` / `minimum_boundary` / `maximum_boundary`; `OrderCases` / `left_right` / `right_left`.
- Construction/oracle expressions retained from the card: `IntegralValues`; `ExpectedComparison`; `(0,0)`; `(1,1)`; `(1,0)`; `(127,1)`; `right_left`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-COMPARISON-FLOAT

- Class: `AngelscriptTest::Generate::FOpComparisonFloatGenerator`; task: 2.5.
- Cells: **192**; categories: normal=192, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildFloatComparisonSource(const FOpComparisonFloatParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-COMPARISON-FLOAT-FLOAT32-LESS-NEGATIVE_ZERO-LEFT_RIGHT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeComparisonOperatorTests.cpp`.
- Card SHA256: `8db18bac4666dc1cca61a1bbf062fb6ec907b52203c288ba1608a8be2fbf9fe3`; inspected source SHA256: `e4addb13647bad40f4ffc7099fe23b12135b6778a8133f75980bc75f5a15bd2a`.
- Axis tables and tokens in documented order: `*Cases`; `FloatTypeCases` / `float32` / `float64`; `OperatorCases` / `less` / `less_equal` / `greater` / `greater_equal` / `equal` / `not_equal`; `FloatValueCases` / `negative_zero` / `positive_zero` / `nan` / `positive_infinity` / `negative_infinity` / `minimum` / `maximum` / `equal_pair`; `OrderCases` / `left_right` / `right_left`.
- Construction/oracle expressions retained from the card: `FloatValues`; `ExpectedComparison`; `right_left`; `>`; `>=`; `!=`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-COMPARISON-OVERLOAD

- Class: `AngelscriptTest::Generate::FOpComparisonOverloadGenerator`; task: 2.6.
- Cells: **96**; categories: normal=96, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildOverloadedComparisonSource(const FOpComparisonOverloadParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-COMPARISON-OVERLOAD-LESS-LESS-LEFT_RIGHT-MUTABLE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeOverloadedComparisonOperatorTests.cpp`.
- Card SHA256: `275368a745c162c07e678d43ece548642b56f038510137253d2a6d3edcdeff36`; inspected source SHA256: `1efe96e03cc030003b24b27675a49da9665575509b87f7645bc9533f370f53ab`.
- Axis tables and tokens in documented order: `*Cases`; `OperatorCases` / `less` / `less_equal` / `greater` / `greater_equal` / `equal` / `not_equal`; `OverloadRelationCases` / `less` / `equal` / `greater` / `unequal`; `OrderCases` / `left_right` / `right_left`; `ReceiverCases` / `mutable` / `const`.
- Construction/oracle expressions retained from the card: `ExecuteOverloadedComparisonCase`; `ExpectedComparison`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-COMPARISON-REFERENCE

- Class: `AngelscriptTest::Generate::FOpComparisonReferenceGenerator`; task: 2.7.
- Cells: **96**; categories: normal=32, reject=64, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildReferenceComparisonSource(const FOpComparisonReferenceParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-COMPARISON-REFERENCE-EQUAL-SAME_NON_NULL-LEFT_RIGHT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeReferenceComparisonOperatorTests.cpp`.
- Card SHA256: `8edf092783e243e8e02171c9e19a6532958841ea88e376bec06492523c0c6b38`; inspected source SHA256: `381a8078887db756a02a747727688e0f4d9dee8f8a0d768be8dd7e1340123c30`.
- Axis tables and tokens in documented order: `*Cases`; `OperatorCases` / `less` / `less_equal` / `greater` / `greater_equal` / `equal` / `not_equal`; `ReferenceRelationCases` / `same_non_null` / `different_non_null` / `left_null` / `right_null` / `both_null` / `derived_base_same` / `sibling_different` / `const_same`; `OrderCases` / `left_right` / `right_left`.
- Construction/oracle expressions retained from the card: `IsReferenceOrdering`; `ExecuteReferenceCase`; `<`; `<=`; `>`; `>=`; `==`; `!=`; `ExpectedResult = (Op==Equal) ? Relation.bEqual : !Relation.bEqual`; `bEqual`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-FAILURE

- Class: `AngelscriptTest::Generate::FOpFailureGenerator`; task: 2.8.
- Cells: **102**; categories: normal=6, reject=42, divide_by_zero=12, integer_overflow=12, power_overflow=6, null_pointer=6, stack_overflow=0, host_fault=18.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildFailureSource(const FOpFailureParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-FAILURE-INVALID_SHIFT_COUNT-DIAGNOSTIC_OR_EXCEPTION-FRESH_MODULE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeOperatorFailureTests.cpp`.
- Card SHA256: `3df4fcf04188ee8b03432e4beb880c7653c9d16ace4a4f073f15ca82e4564752`; inspected source SHA256: `549625d7ab366397e3855965c6ed9e302cd13fd57dcffd7ad1ed41ade505b7fe`.
- Axis tables and tokens in documented order: `*Cases`; `FailureCases` / `unsupported_operand` / `divide_zero` / `modulo_zero` / `invalid_shift_count` / `signed_overflow` / `signed_remainder_overflow` / `power_overflow` / `invalid_lvalue` / `const_mutation` / `missing_overload` / `ambiguous_overload` / `invalid_signature` / `duplicate_operator` / `null_receiver` / `left_operand_exception` / `right_operand_exception` / `assignment_exception`; `ObservationCases` / `diagnostic_or_exception` / `cleanup` / `recovery_result`; `RecoveryCases` / `fresh_module` / `same_module_or_context`.
- Construction/oracle expressions retained from the card: `FFailureCase.Outcome`; `ExpectedException`; `ValidateRuntimeOutcome`; `unsupported_operand`; `invalid_lvalue`; `const_mutation`; `missing_overload`; `ambiguous_overload`; `invalid_signature`; `duplicate_operator`; `divide_zero`; `modulo_zero`; `Divide by zero`; `invalid_shift_count`; `MaskedShiftExecution`; `GetExpected`; `uint`; `Overflow in integer division`; `Overflow in exponent operation`; `Null pointer access`; `BuildAllSource`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-INCREMENT

- Class: `AngelscriptTest::Generate::FOpIncrementGenerator`; task: 2.9.
- Cells: **480**; categories: normal=480, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildLegalSource(const FOpIncrementParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-INCREMENT-LOCAL-BEFORE-PRE_INCREMENT-INT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeIncrementOperatorTests.cpp`.
- Card SHA256: `797eec87c2ad88fc3b9283f79be62ff1773b0141cfbc8cb0dfd15d2f6f432db8`; inspected source SHA256: `f54f707947723874d83a9bfc163598f1f87443d1d9c327f7c709e18b51bd36f2`.
- Axis tables and tokens in documented order: `*Cases`; `CategoryCases` / `local` / `field` / `property` / `alias`; `ObservationCases` / `before` / `expression_result` / `after`; `OperatorCases` / `pre_increment` / `post_increment` / `pre_decrement` / `post_decrement`; `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64`.
- Construction/oracle expressions retained from the card: `InitialBits`; `FinalBits`; `ExpectedObservationBits`; `++`; `--`; `before`; `expression_result`; `after`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-INCREMENT-TARGET-REJECTION

- Class: `AngelscriptTest::Generate::FOpIncrementTargetRejectionGenerator`; task: 2.10.
- Cells: **80**; categories: normal=0, reject=80, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildTargetRejectionSource(const FOpIncrementTargetRejectionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-INCREMENT-TARGET-REJECTION-CONST_INVALID-PRE_INCREMENT-INT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeIncrementTargetRejectionTests.cpp`.
- Card SHA256: `c89f718a6cabc8b467d33092226d684609f5d2667ab125ebb415768188e349a6`; inspected source SHA256: `d387f1994d9c3fdbf2999c2763b73ee010b5d33803fa5aeae05336406d197f63`.
- Axis tables and tokens in documented order: `*Cases`; `RejectedTargetCases` / `const_invalid` / `temporary_invalid`; `OperatorCases` / `pre_increment` / `post_increment` / `pre_decrement` / `post_decrement`; `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64`.
- Construction/oracle expressions retained from the card: `VerifyRejectedSource`; `++/--`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-INCREMENT-TYPE-REJECTION

- Class: `AngelscriptTest::Generate::FOpIncrementTypeRejectionGenerator`; task: 2.11.
- Cells: **16**; categories: normal=0, reject=16, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildBoolRejectionSource(const FOpIncrementTypeRejectionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-INCREMENT-TYPE-REJECTION-LOCAL-PRE_INCREMENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeIncrementTypeRejectionTests.cpp`.
- Card SHA256: `3a63175d33e09989a07c68706e1bac19d9dbf698d4cb7dc00e26443438627c04`; inspected source SHA256: `692dd29b7589ccfb8b7406df710ddcc151c0251db9a47b8109fbb8b6521f0b90`.
- Axis tables and tokens in documented order: `*Cases`; `CategoryCases` / `local` / `field` / `property` / `alias`; `OperatorCases` / `pre_increment` / `post_increment` / `pre_decrement` / `post_decrement`.
- Construction/oracle expressions retained from the card: `BuildBoolRejectionSource`; `VerifyRejectedSource`; `bool`; `++/--`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-INTEGRAL-BITWISE

- Class: `AngelscriptTest::Generate::FOpIntegralBitwiseGenerator`; task: 2.12.
- Cells: **1680**; categories: normal=1680, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildBitwiseSource(const FOpIntegralBitwiseParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-INTEGRAL-BITWISE-MUTABLE_LVALUE-BIT_AND-ZERO-INT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeBitwiseOperatorTests.cpp`.
- Card SHA256: `cf9dd137988a15aa8706949f83d90d18f3787368297997d7b6d2990e0fcd262f`; inspected source SHA256: `0a47f12ccec270b557503a141765f68dca3461cb122f166dbbd38315df57df76`.
- Axis tables and tokens in documented order: `*Cases`; `CategoryCases` / `mutable_lvalue` / `const_lvalue` / `temporary` / `field` / `alias`; `OperatorCases` / `bit_and` / `bit_or` / `bit_xor` / `shift_left` / `shift_right_logical` / `shift_right_arithmetic`; `RightCases` / `zero` / `one` / `source_width_minus_one` / `source_width` / `source_width_plus_one` / `large` / `negative`; `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64`.
- Construction/oracle expressions retained from the card: `SourceBits`; `PromotedBits`; `RightValue`; `ExpectedBits`; `0xA5`; `0xA55A`; `0xA55AA55A`; `0xA55AA55AA55AA55A`; `Right & (Width-1)`; `>>>`; `ArithmeticShiftRight`; `GetExpected`; `ResultMarker`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-LOGICAL

- Class: `AngelscriptTest::Generate::FOpLogicalGenerator`; task: 2.13.
- Cells: **192**; categories: normal=192, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildLogicalSource(const FOpLogicalParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-LOGICAL-ASSIGNMENT-AND-BOOL_LITERAL-FALSE_FALSE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeLogicalOperatorTests.cpp`.
- Card SHA256: `d5c34cd1c51472bae7531919653fcc90116fbaba2dd471485351093c7d27f20c`; inspected source SHA256: `e0d3633837cea11f144a72cf1f3018c305282bd6e8d85c97fc23d4d0e89ff60f`.
- Axis tables and tokens in documented order: `*Cases`; `ContextCases` / `assignment` / `return` / `condition` / `argument`; `OperatorCases` / `and` / `or` / `xor`; `SourceCases` / `bool_literal` / `bool_lvalue` / `comparison` / `conversion_operator`; `TruthCases` / `false_false` / `false_true` / `true_false` / `true_true`.
- Construction/oracle expressions retained from the card: `ExpectedResult`; `ExpectedMarkers`; `and`; `L&&R`; `or`; `L\|\|R`; `xor`; `^^`; `L!=R`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-LOGICAL-NOT

- Class: `AngelscriptTest::Generate::FOpLogicalNotGenerator`; task: 2.14.
- Cells: **10**; categories: normal=10, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildLogicalNotSource(const FOpLogicalNotParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-LOGICAL-NOT-MUTABLE_LVALUE-FALSE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeLogicalNotOperatorTests.cpp`.
- Card SHA256: `5aa98df5459663cc285ad50f60d4d0bcb6283de4b0366b41322fc502f5ae19bc`; inspected source SHA256: `28f3906916e84ee5f86083a051f8f1231f4ef23d0fefa543bf3184bb1a8ecb7c`.
- Axis tables and tokens in documented order: `*Cases`; `CategoryCases` / `mutable_lvalue` / `const_lvalue` / `temporary` / `field` / `alias`; `ValueCases` / `false` / `true`.
- Construction/oracle expressions retained from the card: `ExecuteFunction`; `CategoriesByValue`; `ValueCase.Value ? 0 : 1`; `GetExpected`; `GetExpected = Value ? 0 : 1`; `!Input`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `ObserveLogicalNotType(bool)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-NUMERIC-BINARY

- Class: `AngelscriptTest::Generate::FOpNumericBinaryGenerator`; task: 2.15.
- Cells: **5500**; categories: normal=5500, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildNumericBinarySource(const FOpNumericBinaryParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-NUMERIC-BINARY-INT-ADD-INT-ZERO`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeNumericBinaryOperatorTests.cpp`.
- Card SHA256: `a151413a4f5ccaba606059909afd349897bb0d58f58eddd4c1b6b5b778a62a67`; inspected source SHA256: `15ea4104aeaa5a9232093733e4d7c7e38addd4d06712852080271b1fd4d0b125`.
- Axis tables and tokens in documented order: `*Cases`; `NativeTypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64`; `OperatorCases` / `add` / `subtract` / `multiply` / `divide` / `modulo` / `less` / `less_equal` / `greater` / `greater_equal` / `equal` / `not_equal`; `ValueCases` / `zero` / `one` / `negative` / `near_min` / `near_max`.
- Construction/oracle expressions retained from the card: `PromotedKind`; `ExpectedResult`; `MakePartitionArgument`; `MakeRightArgument`; `float64`; `float32`; `max-2`; `min+1`; `max-1`; `*`; `/`; `%`; `GetExpected`; `ExpectedResult.Bits`; `TypeMarker`; `int32`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER

- Class: `AngelscriptTest::Generate::FOpOverloadAssignmentConsumerGenerator`; task: 2.16.
- Cells: **24**; categories: normal=12, reject=12, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildScenarioSource(const FOpOverloadAssignmentConsumerParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER-ASSIGNMENT_INT_PARAMETER-ASSIGNMENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeOverloadedAssignmentConsumerTests.cpp`.
- Card SHA256: `c5b51f80ff79d81be671f76db3e20469f6f51eb6d639604ddd2e136dc54e3b58`; inspected source SHA256: `b33848daa0c5e9b2d060b7155f127a38a27e339983debe821428bed3c201169c`.
- Axis tables and tokens in documented order: `*Cases`; `assignment_int_parameter` / `assignment_value_parameter`; `assignment_ambiguous_int8` / `assignment_missing_add_assign`; `ConsumerContexts` / `assignment` / `return` / `condition` / `overload_argument` / `chain` / `switch_index`.
- Construction/oracle expressions retained from the card: `Marker`; `.Value`; `ReturnValueMarker`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-OVERLOAD-BOOLEAN-CONSUMER

- Class: `AngelscriptTest::Generate::FOpOverloadBooleanConsumerGenerator`; task: 2.17.
- Cells: **20**; categories: normal=10, reject=10, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildScenarioSource(const FOpOverloadBooleanConsumerParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-OVERLOAD-BOOLEAN-CONSUMER-COMPARISON_INT_PARAMETER-ASSIGNMENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeOverloadedBooleanConsumerTests.cpp`.
- Card SHA256: `c3fc4a07cfcc25a8663fba7fb8e3a33e5b504cb33ba8fe5424670007dc17ebc8`; inspected source SHA256: `14135378ab0d53dcc8621e66fdfab15bf5426d1d0e5a71d1721e72e8df96254a`.
- Axis tables and tokens in documented order: `*Cases`; `comparison_int_parameter` / `comparison_value_parameter`; `comparison_ambiguous_int8` / `comparison_missing_less`; `assignment` / `return` / `condition` / `overload_argument` / `chain`.
- Construction/oracle expressions retained from the card: `Marker`; `ExecuteSuccessfulScenario`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-OVERLOAD-DUPLICATE-DECLARATION

- Class: `AngelscriptTest::Generate::FOpOverloadDuplicateDeclarationGenerator`; task: 2.18.
- Cells: **7**; categories: normal=0, reject=7, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildDuplicateSource(const FOpOverloadDuplicateDeclarationParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-OVERLOAD-DUPLICATE-DECLARATION-DUPLICATE-UNARY`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeOverloadedDuplicateDeclarationTests.cpp`.
- Card SHA256: `6ea313db61ef56fef3985186e246413e8bad455ebcb71bd11dc8ef2a35e43ca7`; inspected source SHA256: `7973e39294f346b9108be102236060bfb2ebc329abf642acae01337945382f88`.
- Axis tables and tokens in documented order: `*Cases`; `duplicate`; `GetFamilyName` / `unary` / `binary` / `comparison` / `index` / `call` / `conversion` / `assignment`.
- Construction/oracle expressions retained from the card: `RunDuplicateDeclaration`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-OVERLOAD-INTEGER-CONSUMER

- Class: `AngelscriptTest::Generate::FOpOverloadIntegerConsumerGenerator`; task: 2.19.
- Cells: **120**; categories: normal=66, reject=54, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildScenarioSource(const FOpOverloadIntegerConsumerParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-OVERLOAD-INTEGER-CONSUMER-UNARY_MEMBER-ASSIGNMENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeOverloadedOperatorTests.cpp`.
- Card SHA256: `41e1462120c30342eb1e35c8dfb79451fcb6a59c65760b59e4ffd654fda9646e`; inspected source SHA256: `46da58841375045a5c05d6fdfc31536a9e618fb53cf22cf32c23ca17988381f0`.
- Axis tables and tokens in documented order: `*Cases`; `unary_member` / `unary_const_member` / `binary_int_member` / `binary_int_const_member` / `binary_int64_promotion` / `binary_value_parameter` / `index_int_parameter` / `index_int64_promotion` / `call_int_member` / `call_int64_promotion` / `conversion_int_target`; `binary_ambiguous_int8` / `index_ambiguous_int8` / `call_ambiguous_int8` / `conversion_ambiguous_target`; `unary_missing_complement` / `binary_missing_subtract` / `index_missing_second_argument` / `call_missing_second_argument` / `conversion_missing_target`; `ConsumerContexts` / `assignment` / `return` / `condition` / `overload_argument` / `chain` / `switch_index`.
- Construction/oracle expressions retained from the card: `FScenarioDefinition.Marker`; `ExecuteSuccessfulScenario`; `GetExpected = Marker`; `GetExpected=0`; `[AS-FORK-LIMITATION]`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-POWER-FRACTIONAL-EXPONENT

- Class: `AngelscriptTest::Generate::FOpPowerFractionalExponentGenerator`; task: 2.20.
- Cells: **80**; categories: normal=80, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildPowerSource(const FOpPowerFractionalExponentParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-POWER-FRACTIONAL-EXPONENT-INT-FLOAT32-CONSTANT-FRACTIONAL_EXPONENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativePowerOperatorTests.cpp`.
- Card SHA256: `94d572135f14cd0e5355875c0e28828fabdb80e50a8a8ac84379f4c1a6f715a0`; inspected source SHA256: `720c8ea120d6f4cc7414a7e84f3b368ca15145f39e70d4a4b2efcf218386ef24`.
- Axis tables and tokens in documented order: `*Cases`; `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64`; `float32` / `float64`; `SourceShapeCases` / `constant` / `mutable_lvalue` / `const_lvalue` / `function_return`.
- Construction/oracle expressions retained from the card: `ExpectedResultBits`; `FractionalExponent`; `ExpectedBuildFailure`; `GetExpected`; `int32`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-POWER-NEGATIVE-EXPONENT

- Class: `AngelscriptTest::Generate::FOpPowerNegativeExponentGenerator`; task: 2.21.
- Cells: **240**; categories: normal=144, reject=96, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildPowerSource(const FOpPowerNegativeExponentParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-POWER-NEGATIVE-EXPONENT-INT-INT-CONSTANT-NEGATIVE_EXPONENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativePowerOperatorTests.cpp`.
- Card SHA256: `a828b8542ec4480aa8ab1c995dfba7b631387ba9d270451243d118593a3bef15`; inspected source SHA256: `720c8ea120d6f4cc7414a7e84f3b368ca15145f39e70d4a4b2efcf218386ef24`.
- Axis tables and tokens in documented order: `*Cases`; `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64`; `int8` / `int16` / `int` / `int64` / `float32` / `float64`; `SourceShapeCases` / `constant` / `mutable_lvalue` / `const_lvalue` / `function_return`.
- Construction/oracle expressions retained from the card: `ExpectedBuildFailure`; `ExpectedResultBits`; `NegativeExponent`; `Overflow in exponent operation`; `Cannot pow on integer values`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-POWER-UNIVERSAL

- Class: `AngelscriptTest::Generate::FOpPowerUniversalGenerator`; task: 2.22.
- Cells: **1600**; categories: normal=848, reject=680, divide_by_zero=0, integer_overflow=0, power_overflow=72, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildPowerSource(const FOpPowerUniversalParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-POWER-UNIVERSAL-INT-INT-CONSTANT-ZERO_EXPONENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativePowerOperatorTests.cpp`.
- Card SHA256: `d472563f3f840ecc0f2bc54e977158f942bd8382bc53cc1a21c45320eee46e53`; inspected source SHA256: `720c8ea120d6f4cc7414a7e84f3b368ca15145f39e70d4a4b2efcf218386ef24`.
- Axis tables and tokens in documented order: `*Cases`; `NativeTypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64`; `SourceShapeCases` / `constant` / `mutable_lvalue` / `const_lvalue` / `function_return`; `EScenario` / `zero_exponent` / `one_exponent` / `near_limit` / `overflow`.
- Construction/oracle expressions retained from the card: `ResultKind`; `ExpectedBuildFailure`; `ExpectedResultBits`; `ExpectedRuntimeOverflow`; `overflow`; `const_lvalue`; `Overflow in exponent operation`; `Cannot pow on integer values`; `BuildAllSource`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-RESULT-CONTEXT

- Class: `AngelscriptTest::Generate::FOpResultContextGenerator`; task: 2.23.
- Cells: **240**; categories: normal=180, reject=60, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildSource(const FOpResultContextParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-RESULT-CONTEXT-UNARY-ASSIGNMENT-EXACT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeOperatorContextTests.cpp`.
- Card SHA256: `b3b09cb09dc965c0f7e1915ec88f59f496b3a01e6c579d463a616083f0a1bd27`; inspected source SHA256: `f0a951cd3c2095fb159a590117ef3d2c039c2851ad41ac9e9d437be786a5cb08`.
- Axis tables and tokens in documented order: `*Cases`; `FamilyCases` / `unary` / `arithmetic` / `power` / `bitwise` / `shift` / `comparison` / `logical` / `assignment` / `increment` / `overloaded`; `ContextCases` / `assignment` / `return` / `condition` / `overload_argument` / `chain` / `switch_or_index`; `OutcomeCases` / `exact` / `converted` / `ambiguous` / `rejected`.
- Construction/oracle expressions retained from the card: `ExpectedResult`; `ExecuteExactFunction(..., 1)`; `VerifyExact`; `VerifyConverted`; `return`; `GetExpected`; `exact`; `converted`; `rejected`; `ambiguous`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-UNARY

- Class: `AngelscriptTest::Generate::FOpUnaryGenerator`; task: 2.24.
- Cells: **700**; categories: normal=700, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildUnarySource(const FOpUnaryParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-UNARY-MUTABLE_LVALUE-POSITIVE_INT-ZERO`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeUnaryOperatorTests.cpp`.
- Card SHA256: `de745904be797a7274c80185aed76ce47e1f28d440b200ba5b2b6a2568316cc8`; inspected source SHA256: `e4be86bc3692df89dec8638799ca6718e91433afc852fb3508909ee26f6b2ef1`.
- Axis tables and tokens in documented order: `*Cases`; `CategoryCases` / `mutable_lvalue` / `const_lvalue` / `temporary` / `field` / `alias`; `OperationTypeCases` / `positive_int8` / `positive_float64` / `negative_int8` / `negative_float64` / `bit_not_int8` / `bit_not_uint64`; `ValueCases` / `zero` / `one` / `negative` / `near_min` / `near_max`.
- Construction/oracle expressions retained from the card: `ResultTypeCase`; `MakeArgument`; `ExpectedBits`; `+`; `-`; `~`; `max-2`; `min+1`; `max-1`; `GetExpected`; `TypeMarker`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: the card explicitly includes limited/approximate observations; int32 must not be represented as full-width arithmetic proof.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-OP-UNARY-REJECTION

- Class: `AngelscriptTest::Generate::FOpUnaryRejectionGenerator`; task: 2.25.
- Cells: **40**; categories: normal=0, reject=40, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildUnaryFailureSource(const FOpUnaryRejectionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-OP-UNARY-REJECTION-MUTABLE_LVALUE-POSITIVE_BOOL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Operators/AngelscriptNativeUnaryOperatorFailureTests.cpp`.
- Card SHA256: `82dfec8b08a67a5f82ecbd7b079feb4ad774c68f5563c282a6872275501111c2`; inspected source SHA256: `066f78a42c311373a6e4f844b6c6f4d46a21fc35794277a0fb792fa4b7ffae6a`.
- Axis tables and tokens in documented order: `*Cases`; `CategoryCases` / `mutable_lvalue` / `const_lvalue` / `temporary` / `field` / `alias`; `FailureCases` / `positive_bool` / `negative_bool` / `bit_not_bool` / `logical_not_signed` / `logical_not_unsigned` / `logical_not_float` / `bit_not_float32` / `bit_not_float64`.
- Construction/oracle expressions retained from the card: `BuildUnaryFailureSource`; `CompileAndReport`; `UNARY_CAUSE`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
