# Conversions product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/conv. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 11. Declared cells: 7262.

## LANG-CONV-ABI

- Class: `AngelscriptTest::Generate::FConvAbiGenerator`; task: 4.1.
- Cells: **12**; categories: normal=12, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildAbiSource(const FConvAbiParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-ABI-FLOAT-FLOAT32-ARGUMENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeConversionAbiTests.cpp`.
- Card SHA256: `e63c6365d3fa9c8fc5937e60b70590ac6b3acaa37e9dfd5f404761cb5462fdc9`; inspected source SHA256: `7b5644c15e7239688ea7bfaf35d3d679e5ec6b6e6ee129cdf151e233a66a7c16`.
- Axis tables and tokens in documented order: `*Cases`; `ScriptDeclarationCases` / `float` / `double`; `NativeStorageCases` / `float32` / `float64`; `DirectionCases` / `argument` / `return` / `property`.
- Construction/oracle expressions retained from the card: `ExpectedBits`; `ExpectedScriptReturn`; `ObservedNativeBits`; `RecordFloat32`; `RecordFloat64`; `RegisterAbiSurface`; `float32`; `float64`; `argument`; `101`; `202`; `return`; `property`; `1`; `Result == T(3.25)`; `Output == Input`; `ExpectedBits(NativeStorage, Value)`; `memcpy`; `float`; `double`; `3.25`; `6.5`; `AbiValue`; `Float32PropertyValue`; `Float64PropertyValue`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CONV-BOOL-CONTEXT

- Class: `AngelscriptTest::Generate::FConvBoolContextGenerator`; task: 4.2.
- Cells: **234**; categories: normal=18, reject=216, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildBoolConversionSource(const FConvBoolContextParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-BOOL-CONTEXT-BOOL-IF-ZERO`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeBoolConversionTests.cpp`.
- Card SHA256: `3fdf49a8aea546017c2fa3fa784a9c61d0796fb9a17eea3d42eb33419d56765a`; inspected source SHA256: `92f32f5817f1f8358c6c2546a7d65796e0a3791cca1e7e86a0b184f53ff2639b`.
- Axis tables and tokens in documented order: `*Cases`; `SourceCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef`; `ContextCases` / `if` / `while` / `ternary_condition` / `logical_and` / `logical_or` / `logical_xor`; `ValueCases` / `zero` / `one` / `negative`.
- Construction/oracle expressions retained from the card: `FSourceCase::bAccepted`; `FValueCase::bBranchValue`; `GetExpected`; `Source=bool`; `bAccepted=true`; `Value.bBranchValue ? 1 : 0`; `zero`; `0`; `false`; `one`; `1`; `true`; `negative`; `if`; `while`; `ternary_condition`; `SourceValue ? 1 : 0`; `logical_and`; `SourceValue && true ? 1 : 0`; `logical_or`; `SourceValue || false ? 1 : 0`; `logical_xor`; `SourceValue ^^ false ? 1 : 0`; `bBranchValue`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `BuildRejectSource`; `BuildAllSource`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CONV-ENUM-ALIAS

- Class: `AngelscriptTest::Generate::FConvEnumAliasGenerator`; task: 4.3.
- Cells: **1260**; categories: normal=1130, reject=130, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildEnumAliasConversionSource(const FConvEnumAliasParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-ENUM-ALIAS-ENUM-ENUM-ASSIGNMENT-ZERO`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeEnumAliasConversionTests.cpp`.
- Card SHA256: `f3b95cf74ba0614b10f984448150ce3881ee7c935004ce63c95e81a54fd05d6a`; inspected source SHA256: `e694a6de1dc568a2a5613ea018fc459ad1d82ab0c31f4e73635931d1fe672210`.
- Axis tables and tokens in documented order: `*Cases`; `SourceCases` / `enum` / `alias_int8` / `alias_int` / `alias_int64` / `alias_uint` / `alias_uint64`; `TargetCases` / `enum` / `int8` / `int` / `int64` / `uint` / `uint64` / `float64`; `FormCases` / `assignment` / `initializer` / `argument` / `return` / `promotion` / `explicit_cast`; `ValueCases` / `zero` / `one` / `negative` / `near_min` / `near_max`.
- Construction/oracle expressions retained from the card: `BuildIndependentExpectedLiteral`; `SourceValueForCase`; `NormalizeSigned`; `NormalizeUnsigned`; `GetExpected`; `BuildResult`; `ShouldCompile`; `LANG-CONV-FAILURE`; `numeric_to_enum`; `alias_*`; `enum`; `explicit_cast`; `promotion`; `Source + EConversionEnum(0)`; `EConversionEnum(SourceValue)`; `1`; `ActualValue == ExpectedLiteral`; `alias_uint`; `uint32`; `alias_uint64`; `uint64`; `EConversionEnum::{Zero,One,Negative,NearMinimum,NearMaximum}`; `float64`; `Execute(Entry<PascalCaseId>)`; `BuildRejectSource`; `BuildAllSource`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CONV-FAILURE

- Class: `AngelscriptTest::Generate::FConvFailureGenerator`; task: 4.4.
- Cells: **24**; categories: normal=4, reject=14, divide_by_zero=4, integer_overflow=0, power_overflow=0, null_pointer=2, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildFailureSource(const FConvFailureParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-FAILURE-AMBIGUOUS_CONSTRUCTOR-FRESH_MODULE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeConversionFailureTests.cpp`.
- Card SHA256: `ef8497b0d05d004adc4847a0e8e68ac60fab1455fb90d52245ba03f07ee9a847`; inspected source SHA256: `d5b4658325cd9586778d32fa5466e7cb43d2f5dd444c86635b29104b2e365201`.
- Axis tables and tokens in documented order: `*Cases`; `FailureCases` / `implicit_narrowing` / `numeric_to_enum` / `unrelated_reference` / `bad_downcast` / `null_value_target` / `ambiguous_constructor` / `ambiguous_operator` / `explicit_only_implicit_use` / `conversion_exception` / `constructor_exception` / `abi_mismatch` / `conditional_no_common_type`; `RecoveryCases` / `fresh_module` / `same_module_or_context`.
- Construction/oracle expressions retained from the card: `FFailureCase::{bRuntimeFailure, ExpectedException}`; `GetExpected`; `RunConversionRecovery`; `ambiguous_constructor`; `ambiguous_operator`; `1`; `null_value_target`; `Null pointer access`; `conversion_exception`; `constructor_exception`; `Value / Zero`; `Divide by zero`; `// CONVERSION_CAUSE`; `Execute(Entry<PascalCaseId>)`; `BuildRejectSource`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
- Classification clarification: the original card header grouped runtime faults; the breakdown here follows its explicit observation section.

## LANG-CONV-FLOAT-FINITE-SPECIAL

- Class: `AngelscriptTest::Generate::FConvFloatFiniteSpecialGenerator`; task: 4.5.
- Cells: **240**; categories: normal=240, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildNumericBoundaryConversionSource(const FConvFloatFiniteSpecialParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-FLOAT-FINITE-SPECIAL-FLOAT32-INT8-ASSIGNMENT-POSITIVE_ZERO`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeNumericBoundaryConversionTests.cpp`.
- Card SHA256: `624f8501e401ac3bf65e4f32615427281cbfe158e3836f9e04fcaddd1e0af349`; inspected source SHA256: `19ccd8852685c5905c4ebdcc8d57eaa0ffd307b14490ec9f63ff49f98ee719e1`.
- Axis tables and tokens in documented order: `SourceCases` / `float32` / `float64`; `NativeTypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64`; `FormCases` / `assignment` / `argument` / `return` / `explicit_cast`; `FiniteSpecialValueCases` / `positive_zero` / `negative_zero` / `subnormal`.
- Construction/oracle expressions retained from the card: `ExpectedFiniteBits`; `ReadReturnBits`; `ExecuteAndVerifyFiniteCell`; `ASSERT`; `positive_zero`; `0`; `negative_zero`; `0x80000000`; `0x8000000000000000`; `subnormal`; `float::denorm_min`; `double(float::denorm_min)`; `double::denorm_min`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CONV-FLOAT64-TO-FLOAT32-RANGE

- Class: `AngelscriptTest::Generate::FConvFloat64ToFloat32RangeGenerator`; task: 4.6.
- Cells: **8**; categories: normal=8, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildNumericBoundaryConversionSource(const FConvFloat64ToFloat32RangeParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-FLOAT64-TO-FLOAT32-RANGE-ASSIGNMENT-ABOVE_TARGET_MAX`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeNumericBoundaryConversionTests.cpp`.
- Card SHA256: `299cd833af521c31f469442eed6b76df0ab5b54a8e08e466ab9cb8e9b0f68dac`; inspected source SHA256: `19ccd8852685c5905c4ebdcc8d57eaa0ffd307b14490ec9f63ff49f98ee719e1`.
- Axis tables and tokens in documented order: `*Cases`; `FormCases` / `assignment` / `argument` / `return` / `explicit_cast`; `FiniteRangeValueCases` / `above_target_max` / `below_target_min`.
- Construction/oracle expressions retained from the card: `ExpectedFiniteBits`; `ExecuteAndVerifyFiniteCell`; `bExpectNonFinite=false`; `above_target_max`; `0x7F800000`; `2139095040`; `below_target_min`; `0xFF800000`; `-8388608`; `GetExpected(CaseId)`; `Divide by zero`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CONV-NONFINITE-PRECONVERSION

- Class: `AngelscriptTest::Generate::FConvNonfinitePreconversionGenerator`; task: 4.7.
- Cells: **240**; categories: normal=0, reject=0, divide_by_zero=240, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildNumericBoundaryConversionSource(const FConvNonfinitePreconversionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-NONFINITE-PRECONVERSION-FLOAT32-INT8-ASSIGNMENT-POSITIVE_INFINITY`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeNumericBoundaryConversionTests.cpp`.
- Card SHA256: `b8570aed8755537518619af8d78c389efb2c205ae934a485b95611bbbf18a0f1`; inspected source SHA256: `19ccd8852685c5905c4ebdcc8d57eaa0ffd307b14490ec9f63ff49f98ee719e1`.
- Axis tables and tokens in documented order: `SourceCases` / `float32` / `float64`; `NativeTypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64`; `FormCases` / `assignment` / `argument` / `return` / `explicit_cast`; `NonFiniteValueCases` / `positive_infinity` / `negative_infinity` / `nan`.
- Construction/oracle expressions retained from the card: `ExecuteAndVerifyNonFiniteCell`; `IsNonFiniteValue`; `AppendSpecialSourceValue`; `ASSERT`; `Unit / Zero`; `-Unit / Zero`; `Zero / Zero`; `Divide by zero`; `throw`; `GetExpected(CaseId)`; `0`; `asEXECUTION_EXCEPTION`; `GetExceptionString() == "Divide by zero"`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
- Classification clarification: the original card header grouped runtime faults; the breakdown here follows its explicit observation section.

## LANG-CONV-NUMERIC

- Class: `AngelscriptTest::Generate::FConvNumericGenerator`; task: 4.8.
- Cells: **4200**; categories: normal=4200, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildNumericConversionSource(const FConvNumericParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-NUMERIC-INT8-INT8-ASSIGNMENT-ZERO`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeNumericConversionTests.cpp`.
- Card SHA256: `d494cf5c567a2925c143bb3b573ff2a1ff23739e4ee130e0e6a624a0aa96dfc1`; inspected source SHA256: `0468510c1e2aef43d5773a81fca16637086398d24bcb817ac7f25abd83a69218`.
- Axis tables and tokens in documented order: `NativeTypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64`; `FormCases` / `assignment` / `initializer` / `argument` / `return` / `promotion` / `explicit_cast`; `ValueCases` / `zero` / `one` / `negative` / `min` / `max` / `near_boundary` / `fractional`.
- Construction/oracle expressions retained from the card: `BuildIndependentExpectedLiteral`; `HasPortableExactValue`; `SignedValueForCase`; `UnsignedValueForCase`; `FloatingValueForCase`; `GetExpected`; `1`; `ActualValue == ExpectedLiteral`; `one`; `negative`; `min`; `max`; `near_boundary`; `ResolveNumericLiteral`; `static_cast`; `float`; `double`; `%.9gf`; `%.17g`; `zero`; `fractional`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `BuildResult<0`; `LANG-CONV-FAILURE`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CONV-OBJECT-CAST

- Class: `AngelscriptTest::Generate::FConvObjectCastGenerator`; task: 4.9.
- Cells: **180**; categories: normal=108, reject=72, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildObjectCastSource(const FConvObjectCastParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-OBJECT-CAST-BASE-BASE-BASE-ASSIGNMENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeObjectCastTests.cpp`.
- Card SHA256: `daf8bbb85f26c5e06f30746ab2a477dfe27974994b8a209f9968fd97cc4e247e`; inspected source SHA256: `4eeef72f3e72ff7ca7300f3a2d5a7b19a1be454b905d28f4d43d9f6e6cd43f4a`.
- Axis tables and tokens in documented order: `*Cases`; `RuntimeKindCases` / `base` / `derived` / `unrelated` / `null`; `ViewCases` / `base` / `derived` / `unrelated`; `FormCases` / `assignment` / `initializer` / `argument` / `return` / `explicit_cast`.
- Construction/oracle expressions retained from the card: `ExpectedRuntimeResult`; `ShouldCompile`; `IsImplicitlyConvertible`; `IsVisibleThroughView`; `base`; `derived`; `unrelated`; `opImplCast`; `explicit_cast`; `cast<Derived>`; `cast<Unrelated>`; `cast<T>`; `IsVisibleThroughView(Kind, Source) && IsVisibleThroughView(Kind, Target) ? (int(Kind)+1)*1000+1 : -1`; `null`; `(Kind+1)*1000+1`; `-1`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `BuildRejectSource`; `BuildAllSource`; `nullptr`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CONV-OVERLOAD

- Class: `AngelscriptTest::Generate::FConvOverloadGenerator`; task: 4.10.
- Cells: **144**; categories: normal=72, reject=72, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildResolutionSource(const FConvOverloadParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-OVERLOAD-OVERLOAD-IDENTITY-EXACT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeConversionResolutionTests.cpp`.
- Card SHA256: `2edacaa243c561e410b8f582f08a535818fb0f53c57db1d8c935c72934c8dfd2`; inspected source SHA256: `b3646a60aa60f7b25de0e96511423c760a305093a6eaf7b868f6e8fb31ecdfbc`.
- Axis tables and tokens in documented order: `*Cases`; `ContextCases` / `overload` / `operator` / `default_argument` / `property` / `index` / `conditional`; `ConversionCases` / `identity` / `promotion` / `narrowing` / `constructor` / `operator` / `reference_cast`; `OutcomeCases` / `exact` / `selected_conversion` / `ambiguous` / `rejected`.
- Construction/oracle expressions retained from the card: `ExpectedContextResult`; `ExpectedSelectedMarker`; `ExpectedSourceMarker`; `FOutcomeCase::bExpectedCompile`; `Outcome.bExpectedCompile`; `exact`; `selected_conversion`; `ambiguous`; `rejected`; `opImplConv`; `overload +100`; `operator +7`; `default_argument +5`; `index +1`; `property`; `conditional +0`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `BuildRejectSource`; `BuildAllSource`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CONV-VALUE-OBJECT

- Class: `AngelscriptTest::Generate::FConvValueObjectGenerator`; task: 4.11.
- Cells: **720**; categories: normal=200, reject=520, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildValueObjectConversionSource(const FConvValueObjectParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CONV-VALUE-OBJECT-IMPLICIT_CONSTRUCTOR-SAME_VALUE-ASSIGNMENT-DIRECT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Conversions/AngelscriptNativeValueObjectConversionTests.cpp`.
- Card SHA256: `f87f25963060fc224358bc9305dfc344c31a867e89b6b7fc291b82f71df44830`; inspected source SHA256: `0c339ea7adb8b5f5828e43e25b1a66834233e7c0ba820f75167f3ec8bda72f5b`.
- Axis tables and tokens in documented order: `*Cases`; `AvailabilityCases` / `implicit_constructor` / `explicit_constructor` / `implicit_operator` / `explicit_operator` / `constructor_and_operator` / `none`; `TargetCases` / `same_value` / `other_value` / `int` / `float64` / `bool`; `FormCases` / `assignment` / `initializer` / `argument` / `return` / `explicit_cast` / `direct_constructor`; `OutcomeCases` / `direct` / `selected` / `ambiguous` / `rejected`.
- Construction/oracle expressions retained from the card: `ExpectedSelectedMarker`; `ShouldCompile`; `ShouldCompilePositivePath`; `HasImplicitSelectedPath`; `HasExplicitSelectedPath`; `Outcome`; `ambiguous`; `rejected`; `explicit_cast`; `direct_constructor`; `same_value`; `other_value`; `implicit_constructor`; `implicit_operator`; `constructor_and_operator`; `none`; `int`; `float64`; `bool`; `opImplConv`; `explicit_operator`; `opConv`; `direct`; `selected`; `7`; `SourceValue(7).Value`; `107`; `207`; `307`; `0`; `1`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `BuildRejectSource`; `BuildAllSource`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
