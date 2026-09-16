# Foreach product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/foreach. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 4. Declared cells: 1010.

## LANG-FE-PROTOCOL

- Class: `AngelscriptTest::Generate::FForeachProtocolGenerator`; task: 13.1.
- Cells: **250**; categories: normal=45, reject=190, divide_by_zero=15, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildForeachProtocolSource(const FForeachProtocolParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FE-PROTOCOL-COMPLETE-EXACT-SINGLE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Foreach/AngelscriptNativeForeachProtocolTests.cpp`.
- Card SHA256: `4ceffdebd202c444723126b9f1b7e46352471ea69d44dada1989766dc1e022da`; inspected source SHA256: `8a2d8d16423d35cd546c07513591c7f8ed0d6bfa3645a5078c482dfe65c3f71d`.
- Axis tables and tokens in documented order: `*Cases`; `ProtocolCases` / `complete` / `overloaded` / `missing_begin` / `missing_next` / `missing_value` / `missing_end` / `wrong_parameter` / `wrong_return` / `inaccessible` / `throwing`; `ResolutionCases` / `exact` / `conversion` / `const_overload` / `ambiguous` / `missing`; `NestingCases` / `single` / `same_iterable` / `distinct_iterable` / `inside_for` / `contains_for`.
- Construction/oracle expressions retained from the card: `ExpectedResult`; `C = ResolutionContribution`; `exact=1`; `conversion=2`; `const_overload=3`; `ambiguous=20`; `single`; `2 * C`; `inside_for`; `4 * C`; `contains_for`; `same_iterable`; `distinct_iterable`; `6 * C`; `throwing`; `ambiguous`; `RaiseNativeCaseException`; `1 / Zero`; `Divide by zero`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FE-SIZE-VARIABLE

- Class: `AngelscriptTest::Generate::FForeachSizeVariableGenerator`; task: 13.2.
- Cells: **640**; categories: normal=319, reject=288, divide_by_zero=33, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildForeachIterationSource(const FForeachSizeVariableParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FE-SIZE-VARIABLE-EMPTY-PRIMITIVE-VALUE-COMPLETE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Foreach/AngelscriptNativeForeachIterationTests.cpp`.
- Card SHA256: `6dfc7e3a9e67d6c14e7846d3b8ba6353ed2e2a3e79e348ab3b40804c945d14b5`; inspected source SHA256: `928cf96c6c9d37516f7c1494aec598f23cdf79bd2b13e5ab2bb451654255b12e`.
- Axis tables and tokens in documented order: `*Cases`; `SizeCases` / `empty` / `one` / `two` / `many`; `ElementCases` / `primitive` / `value_object` / `reference_object` / `const_element`; `VariableCases` / `value` / `auto` / `mutable_reference` / `const_reference` / `incompatible`; `TransferCases` / `complete` / `break_first` / `break_middle` / `break_last` / `continue_first` / `continue_middle` / `return` / `exception`.
- Construction/oracle expressions retained from the card: `ExpectedResult`; `FForeachIterationExpectation.ReturnValue`; `C = (Variable==mutable_reference) ? 2 : 1`; `N = CountFor(Size)`; `empty`; `N==0`; `0`; `complete`; `N * C`; `return`; `C`; `break_first`; `break_middle`; `break_last`; `continue_first`; `(N-1) * C`; `continue_middle`; `(N==1 ? 1 : N-1) * C`; `RaiseNativeCaseException`; `1 / Zero`; `Divide by zero`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FE-STRUCTURAL-MUTATION

- Class: `AngelscriptTest::Generate::FForeachStructuralMutationGenerator`; task: 13.3.
- Cells: **36**; categories: normal=36, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildStructuralMutationSource(const FForeachStructuralMutationParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FE-STRUCTURAL-MUTATION-ONE-STABLE-PRIMITIVE_VALUE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Foreach/AngelscriptNativeForeachTransferLifetimeTests.cpp`.
- Card SHA256: `8b2137323698fe583d705427a224d42b42025155e58ee7bf2c15167bc99c8ea1`; inspected source SHA256: `48fd2a748b7131085e20f5d488c684fbc72d823b47161ed215188b52387c08a4`.
- Axis tables and tokens in documented order: `SizeCases` / `one` / `two` / `many`; `MutationCases` / `stable` / `shrink_first` / `shrink_middle` / `clear_after_first`; `ElementCases` / `primitive_value` / `value_object_copy` / `value_object_const_ref`.
- Construction/oracle expressions retained from the card: `ExpectedMutationVisits`; `Entry`; `Trace`; `Size`; `one=1`; `two=2`; `many=4`; `stable`; `shrink_first`; `clear_after_first`; `min(Size, 1)`; `shrink_middle`; `min(Size, 2)`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FE-TRANSFER-LIFETIME

- Class: `AngelscriptTest::Generate::FForeachTransferLifetimeGenerator`; task: 13.4.
- Cells: **84**; categories: normal=72, reject=0, divide_by_zero=12, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildTransferSource(const FForeachTransferLifetimeParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FE-TRANSFER-LIFETIME-COMPLETE-SINGLE-PRIMITIVE_VALUE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Foreach/AngelscriptNativeForeachTransferLifetimeTests.cpp`.
- Card SHA256: `370938c4b5406bc5e5075122390011a23dff5687d886e0b20b4dac619e0e7cce`; inspected source SHA256: `48fd2a748b7131085e20f5d488c684fbc72d823b47161ed215188b52387c08a4`.
- Axis tables and tokens in documented order: `TransferCases` / `complete` / `break_first` / `break_middle` / `continue_first` / `continue_middle` / `return` / `exception`; `NestingCases` / `single` / `nested_same` / `nested_distinct` / `inside_for`; `ElementCases` / `primitive_value` / `value_object_copy` / `value_object_const_ref`.
- Construction/oracle expressions retained from the card: `SimulateTransfer.ReturnValue`; `InnerLimit`; `nested_distinct=2`; `InnerVisits = TransferVisitCount`; `min(L,1)`; `min(L,2)`; `L`; `single`; `InnerVisits`; `nested_same`; `nested_distinct`; `Outer * 100 + Outer * InnerVisits`; `Outer=1`; `inside_for`; `Outer * 10 + Outer * InnerVisits`; `RaiseNativeCaseException`; `1 / Zero`; `Divide by zero`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
