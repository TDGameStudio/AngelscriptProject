# Functions product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/fn. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 19. Declared cells: 1601.

## LANG-FN-ARG-SOURCE

- Class: `AngelscriptTest::Generate::FFnArgSourceGenerator`; task: 5.1.
- Cells: **44**; categories: normal=22, reject=17, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=5, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildArgumentSource(const FFnArgSourceParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-ARG-SOURCE-VALUE-LITERAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionArgumentSourceTests.cpp`.
- Card SHA256: `ee5717b434aaa27f03b05e294e0f8de5e6e72ebbfc0040bcb885cd2e682b90f9`; inspected source SHA256: `23e5d4b3b2be8431a71d79df88ddb64df3e774632481b4eea18d9baba34db610`.
- Axis tables and tokens in documented order: `*Cases`; `DirectionCases` / `value` / `in` / `out` / `inout` / `NativeDirectionCases`; `SourceCases` / `literal` / `local_lvalue` / `const_local` / `global_const` / `field` / `function_return` / `arithmetic_expression` / `conditional_expression` / `null` / `base_view` / `derived_view`.
- Construction/oracle expressions retained from the card: `ShouldCompile`; `derived_view`; `value`; `out`; `inout`; `literal`; `const_local`; `global_const`; `function_return`; `arithmetic_expression`; `conditional_expression`; `null`; `base_view`; `Null pointer access`; `SetException`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
- Classification clarification: the original card header grouped runtime faults; the breakdown here follows its explicit observation section.

## LANG-FN-ARITY-TARGET

- Class: `AngelscriptTest::Generate::FFnArityTargetGenerator`; task: 5.2.
- Cells: **21**; categories: normal=21, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildAritySource(const FFnArityTargetParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-ARITY-TARGET-ZERO-GLOBAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionArityTests.cpp`.
- Card SHA256: `de0b7141a5c172220054d412adb53e1766f9cb25c978178d648ff8c665c225a4`; inspected source SHA256: `84856c79eb1574da639a9f161522843999719b93b01361d347b8b70bbf10e784`.
- Axis tables and tokens in documented order: `*Cases`; `ArityCases` / `zero` / `one` / `two` / `three` / `eight` / `current_boundary` / `boundary_plus_one`; `TargetCases` / `global` / `namespace_global` / `instance_method`.
- Construction/oracle expressions retained from the card: `Count==0 ? 42 : Count*(Count+1)/2`; `GetExpected`; `boundary_plus_one`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-ARITY-TYPE-STRESS

- Class: `AngelscriptTest::Generate::FFnArityTypeStressGenerator`; task: 5.3.
- Cells: **96**; categories: normal=96, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildSource(const FFnArityTypeStressParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-ARITY-TYPE-STRESS-ZERO-HOMOGENEOUS_INT-GLOBAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionArityTypeStressTests.cpp`.
- Card SHA256: `cacf44a714edf9856e04933c7dc7784853bf038525b9f7d9feb753d14bf1bc93`; inspected source SHA256: `2fd72f8a6cb3626ef9a4b2ea681130dc25cfa6ca12fec0da8c5da880115378ac`.
- Axis tables and tokens in documented order: `*Cases`; `ArityCases` / `zero` / `one` / `two` / `four` / `eight` / `sixteen` / `thirty_two` / `sixty_four`; `TypePatternCases` / `homogeneous_int` / `homogeneous_bool` / `alternating_int_bool` / `alternating_bool_int`; `TargetCases` / `global` / `namespace_global` / `instance_method`.
- Construction/oracle expressions retained from the card: `ExpectedResult(Arity, Pattern)`; `Count==0`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-DEFAULTS

- Class: `AngelscriptTest::Generate::FFnDefaultsGenerator`; task: 5.4.
- Cells: **72**; categories: normal=57, reject=15, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildDefaultArgumentSource(const FFnDefaultsParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-DEFAULTS-NONE-FINAL_ONE-GLOBAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionDefaultArgumentTests.cpp`.
- Card SHA256: `c0dd998c99f45b7763af6861c65ad047bbec13252dd9e0971e053c1d9201e2f2`; inspected source SHA256: `f1cc5796b7e83972b1e20ebed344cbd993462ba3fa1c0d1d2b012cd508bc5d8b`.
- Axis tables and tokens in documented order: `*Cases`; `OmissionCases` / `none` / `one` / `many`; `PatternCases` / `final_one` / `final_many` / `all_optional` / `explicit_override` / `mixed_omitted_provided` / `non_trailing_invalid` / `type_invalid` / `earlier_parameter_reference_invalid`; `TargetCases` / `global` / `namespace_global` / `instance_method`.
- Construction/oracle expressions retained from the card: `ShouldCompile`; `ExpectedResult`; `A*100 + B*10 + C`; `GetExpected`; `none/one/many`; `mixed_omitted_provided`; `non_trailing_invalid`; `final_one`; `many`; `earlier_parameter_reference_invalid`; `type_invalid`; `earlier_*`; `none`; `one`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-DIRECTION-DEFAULT

- Class: `AngelscriptTest::Generate::FFnDirectionDefaultGenerator`; task: 5.5.
- Cells: **528**; categories: normal=309, reject=219, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildSource(const FFnDirectionDefaultParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-DIRECTION-DEFAULT-INT8-VALUE-NONE_EXPLICIT-GLOBAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionDirectionDefaultTests.cpp`.
- Card SHA256: `01102c5aa3f9eccbd582776350649e551e783875df4c215b882eeeecd075fd89`; inspected source SHA256: `8a6b6431e726be94aed92eecf8546ef47e6afc454152eee9f85e68bcbc77fd26`.
- Axis tables and tokens in documented order: `*Cases`; `TypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `NativeTypeCases` / `IsPrimitiveType`; `DirectionCases` / `value` / `in` / `out` / `inout`; `DefaultStateCases` / `none_explicit` / `none_omitted` / `present_explicit` / `present_omitted`; `TargetCases` / `global` / `namespace_global` / `instance_method`.
- Construction/oracle expressions retained from the card: `ShouldCompile`; `GetExpected`; `bool Entry`; `none_omitted`; `present_omitted`; `out`; `inout`; `in`; `{int,float32,float64,bool}`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-INDIRECT-IMPORTED

- Class: `AngelscriptTest::Generate::FFnIndirectImportedGenerator`; task: 5.6.
- Cells: **6**; categories: normal=0, reject=6, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildImportProviderSource(const FFnIndirectImportedParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-INDIRECT-IMPORTED-DECLARATION_METADATA`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp`.
- Card SHA256: `66eb8e9c1a4542242b9adc38ab5f7af1165a40079dd158133f6b8fb077d5d0b0`; inspected source SHA256: `6a1984306b8a2a37bf900408dc6712e0fe5d8dc42b98c260214d72b4d1a0280e`.
- Axis tables and tokens in documented order: `*Cases`; `ScenarioCases` / `declaration_metadata` / `compatible_direct` / `compatible_nested` / `null_or_unbound` / `incompatible_signature` / `rebuild_or_rebind`.
- Construction/oracle expressions retained from the card: `import`; `BuildAllSource`; `OutCaseCount=0`; `BuildRejectSource`; `ListRejectCaseIds`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-INDIRECT-MIXIN

- Class: `AngelscriptTest::Generate::FFnIndirectMixinGenerator`; task: 5.7.
- Cells: **6**; categories: normal=4, reject=2, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildMixinSource(const FFnIndirectMixinParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-INDIRECT-MIXIN-DECLARATION_METADATA`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp`.
- Card SHA256: `d5d5861f91e3e3d7b1a39b520514b1b8bcd8ba790910295a27ea89c8ec1f0fa2`; inspected source SHA256: `6a1984306b8a2a37bf900408dc6712e0fe5d8dc42b98c260214d72b4d1a0280e`.
- Axis tables and tokens in documented order: `*Cases`; `ScenarioCases` / `declaration_metadata` / `compatible_direct` / `compatible_nested` / `null_or_unbound` / `incompatible_signature` / `rebuild_or_rebind`.
- Construction/oracle expressions retained from the card: `RunMixinCase`; `bShouldCompile = !null_or_unbound && !incompatible_signature`; `declaration_metadata`; `compatible_direct`; `compatible_nested`; `rebuild_or_rebind`; `GetExpected`; `40+2+0`; `null_or_unbound`; `MissingMixin`; `incompatible_signature`; `int`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-INDIRECT-REGISTERED-FUNCDEF

- Class: `AngelscriptTest::Generate::FFnIndirectRegisteredFuncdefGenerator`; task: 5.8.
- Cells: **6**; categories: normal=0, reject=6, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildRegisteredTargetSource(const FFnIndirectRegisteredFuncdefParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-INDIRECT-REGISTERED-FUNCDEF-DECLARATION_METADATA`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp`.
- Card SHA256: `267f97388e830fddeae5e285f06ec6625816c71537dc5812cd1ea445e7f7ba16`; inspected source SHA256: `6a1984306b8a2a37bf900408dc6712e0fe5d8dc42b98c260214d72b4d1a0280e`.
- Axis tables and tokens in documented order: `*Cases`; `ScenarioCases` / `declaration_metadata` / `compatible_direct` / `compatible_nested` / `null_or_unbound` / `incompatible_signature` / `rebuild_or_rebind`.
- Construction/oracle expressions retained from the card: `funcdef`; `RegisterFuncdef`; `BuildAllSource`; `OutCaseCount=0`; `BuildRejectSource`; `ListRejectCaseIds`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-INDIRECT-SCRIPT-FUNCDEF

- Class: `AngelscriptTest::Generate::FFnIndirectScriptFuncdefGenerator`; task: 5.9.
- Cells: **6**; categories: normal=0, reject=6, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildScriptFuncdefSource(const FFnIndirectScriptFuncdefParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-INDIRECT-SCRIPT-FUNCDEF-DECLARATION_METADATA`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp`.
- Card SHA256: `fc511cb1609bdfe40c8fe9afa01990e9b1b800048ffe19461348cd76f9bdde77`; inspected source SHA256: `6a1984306b8a2a37bf900408dc6712e0fe5d8dc42b98c260214d72b4d1a0280e`.
- Axis tables and tokens in documented order: `*Cases`; `ScenarioCases` / `declaration_metadata` / `compatible_direct` / `compatible_nested` / `null_or_unbound` / `incompatible_signature` / `rebuild_or_rebind`.
- Construction/oracle expressions retained from the card: `RunScriptFuncdefCase`; `BuildAllSource`; `OutCaseCount=0`; `BuildRejectSource`; `ListRejectCaseIds`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-MIXIN-DIRECT-DISPATCH

- Class: `AngelscriptTest::Generate::FFnMixinDirectDispatchGenerator`; task: 5.10.
- Cells: **2**; categories: normal=2, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildFnMixinDirectDispatchSource(const FFnMixinDirectDispatchParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-MIXIN-DIRECT-DISPATCH-GLOBAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/AngelscriptNativeFunctionsTests.cpp`.
- Card SHA256: `eed93e31ddab6ea816a104eab84e00128ddbe43b5fd33080f0635ee7cf1e2dab`; inspected source SHA256: `57fed4341cc30dbcc5cb3384624a460e72e28b8a451c4983948490dd3b2bc21b`.
- Axis tables and tokens in documented order: `FMixinCase`; `NamespaceCases` / `global` / `nested`.
- Construction/oracle expressions retained from the card: `FunctionsMixinNamespace`; `bMemberInvocation==true`; `Value.AddToCounter(3)`; `bool Entry`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-MIXIN-FREE-CALL-REJECTION

- Class: `AngelscriptTest::Generate::FFnMixinFreeCallRejectionGenerator`; task: 5.11.
- Cells: **2**; categories: normal=0, reject=2, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildFnMixinFreeCallRejectionSource(const FFnMixinFreeCallRejectionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-MIXIN-FREE-CALL-REJECTION-GLOBAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/AngelscriptNativeFunctionsTests.cpp`.
- Card SHA256: `c03e36e8a56a4481ad805d26a8572d3047d8aa6c0d945fce049896166d556ba6`; inspected source SHA256: `57fed4341cc30dbcc5cb3384624a460e72e28b8a451c4983948490dd3b2bc21b`.
- Axis tables and tokens in documented order: `FMixinCase`; `NamespaceCases` / `global` / `nested`.
- Construction/oracle expressions retained from the card: `bMemberInvocation==false`; `AddToCounter(Value, 3)`; `BuildAllSource`; `OutCaseCount=0`; `BuildRejectSource`; `ListRejectCaseIds`; `GetExpected`; `No matching signatures`; `AddToCounter`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-OVERLOAD

- Class: `AngelscriptTest::Generate::FFnOverloadGenerator`; task: 5.12.
- Cells: **28**; categories: normal=14, reject=14, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildOverloadSource(const FFnOverloadParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-OVERLOAD-TYPE-EXACT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionOverloadResolutionTests.cpp`.
- Card SHA256: `82a88cd7b28937b6bdaa8134563495bfde568df4643b2fd5120e18bee15fccab`; inspected source SHA256: `9302ea77b849881623787f2343c0661adfea2147987ebeb80c7766641153080c`.
- Axis tables and tokens in documented order: `*Cases`; `DiscriminatorCases` / `type` / `arity` / `const` / `direction` / `namespace` / `default` / `conversion`; `OutcomeCases` / `exact` / `promotion` / `ambiguous` / `missing`.
- Construction/oracle expressions retained from the card: `ExpectedMarker`; `Outcome.bShouldCompile`; `type`; `arity`; `const`; `direction`; `namespace`; `default`; `conversion`; `GetExpected`; `exact`; `ambiguous`; `missing`; `bShouldCompile=false`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-PARAM-DIRECTION

- Class: `AngelscriptTest::Generate::FFnParamDirectionGenerator`; task: 5.13.
- Cells: **60**; categories: normal=60, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildParameterDirectionSource(const FFnParamDirectionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-PARAM-DIRECTION-VALUE-INT8`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionParameterDirectionTests.cpp`.
- Card SHA256: `818feacda7004b2cc747017f0ea37eb6543fe3aed6ae28192834632ea7a222e5`; inspected source SHA256: `f2633da83b0b0a3fc828d1b4b75641e2f5238f54743842a55149a80860f9188b`.
- Axis tables and tokens in documented order: `*Cases`; `DirectionCases` / `value` / `in` / `out` / `inout`; `TypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef` / `script_value` / `native_value`.
- Construction/oracle expressions retained from the card: `bool Run_*`; `OneLiteral`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-PARAM-POSITION

- Class: `AngelscriptTest::Generate::FFnParamPositionGenerator`; task: 5.14.
- Cells: **180**; categories: normal=180, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildParameterPositionSource(const FFnParamPositionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-PARAM-POSITION-VALUE-FIRST-INT8`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionParameterPositionTests.cpp`.
- Card SHA256: `91e1079ebaeaa8a1b6f530902337df8371ea586704bb656142d7dbeef1260523`; inspected source SHA256: `c8c8bd359274d9fcb51ae1ad726d86a92a2375c97798130452764384339d0eca`.
- Axis tables and tokens in documented order: `*Cases`; `DirectionCases` / `value` / `in` / `out` / `inout` / `NativeDirectionCases`; `PositionCases` / `first` / `middle` / `last`; `TypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef` / `script_value` / `native_value` / `IsCoreValueTypeCase` / `null`.
- Construction/oracle expressions retained from the card: `bool Run_*`; `101/202/303`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-RECURSION

- Class: `AngelscriptTest::Generate::FFnRecursionGenerator`; task: 5.15.
- Cells: **24**; categories: normal=6, reject=12, divide_by_zero=6, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildRecursionSource(const FFnRecursionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-RECURSION-ZERO-RETURN-PRIMITIVE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionRecursionTests.cpp`.
- Card SHA256: `66a5c6f5cc478d2219a5aa5b3f64bc5db29bd6072eae019ea795afb7cab5ac8e`; inspected source SHA256: `a68560448d2eca2a1e0c92ddaa6b8430edbf571eb974beeb12ebd55d6bc977b7`.
- Axis tables and tokens in documented order: `*Cases`; `DepthCases` / `zero` / `one` / `eight` / `configured_limit`; `OutcomeCases` / `return` / `exception`; `TypeCases` / `primitive` / `value_object` / `reference_object`.
- Construction/oracle expressions retained from the card: `ExecutionDepth`; `GetExpected`; `configured_limit`; `OrdinaryDepth`; `eight`; `zero`; `one`; `return`; `exception`; `return 1 / Zero`; `Divide by zero`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
- Classification clarification: the original card header grouped runtime faults; the breakdown here follows its explicit observation section.

## LANG-FN-RETURN

- Class: `AngelscriptTest::Generate::FFnReturnGenerator`; task: 5.16.
- Cells: **136**; categories: normal=86, reject=33, divide_by_zero=17, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildReturnSource(const FFnReturnParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-RETURN-DIRECT-VOID`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionReturnTests.cpp`.
- Card SHA256: `026598f4d7d9325a51257a359aeeb0942b389066c1b00a4eecb51e5bb3890055`; inspected source SHA256: `949e52c7c8194c928cc3582f9e1cf1f97de0b1cfcea9d15108e034769aa2485b`.
- Axis tables and tokens in documented order: `*Cases`; `PathCases` / `direct` / `if_else` / `switch` / `early` / `recursive_base` / `exception` / `missing_invalid` / `incompatible_invalid`; `TypeCases` / `void` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef` / `script_value` / `script_reference` / `null_reference`.
- Construction/oracle expressions retained from the card: `ShouldCompile`; `TypeCases.ExpectedInteger`; `ExpectedFloatingPoint`; `GetExpected`; `incompatible_invalid`; `missing_invalid`; `void`; `exception`; `1 / Zero`; `Divide by zero`; `ExpectedInteger`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
- Classification clarification: the original card header grouped runtime faults; the breakdown here follows its explicit observation section.

## LANG-FN-SIGNATURE-SHAPE

- Class: `AngelscriptTest::Generate::FFnSignatureShapeGenerator`; task: 5.17.
- Cells: **192**; categories: normal=192, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildSource(const FFnSignatureShapeParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-SIGNATURE-SHAPE-GLOBAL-ALL_VALUE-HOMOGENEOUS_INT-ONE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionSignatureShapeTests.cpp`.
- Card SHA256: `1713d6547aea96ddaa7320db13edb7ada3623405e03dfd15f7a0b22cef07beef`; inspected source SHA256: `3c06225257cd424e7de0dc011b560fbdf27b8c4e62305947978468bdb1293615`.
- Axis tables and tokens in documented order: `*Cases`; `TargetCases` / `global` / `namespace_global` / `instance_method`; `DirectionPatternCases` / `all_value` / `all_in` / `all_out` / `alternating_inout_out`; `TypePatternCases` / `homogeneous_int` / `homogeneous_float` / `alternating_int_float` / `alternating_float_int`; `ArityCases` / `one` / `two` / `three` / `four`.
- Construction/oracle expressions retained from the card: `GetExpectedResult(Arity, DirectionPattern)`; `GetExpectedCallerValue`; `i`; `100+i`; `i+8`; `i+3`; `GetExpected`; `+1`; `int(P)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-TYPED-DEFAULTS

- Class: `AngelscriptTest::Generate::FFnTypedDefaultsGenerator`; task: 5.18.
- Cells: **168**; categories: normal=168, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildSource(const FFnTypedDefaultsParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-TYPED-DEFAULTS-ONE-HOMOGENEOUS_INT-GLOBAL-OMIT0`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionTypedDefaultArgumentTests.cpp`.
- Card SHA256: `12948449fabfc9af1b55555314720ea4e2406b63ebfc8dff484005b719c17012`; inspected source SHA256: `228efefc61f355840bb855e0855d5d9b8bf5fe8e7196980bf84a85cc573248be`.
- Axis tables and tokens in documented order: `*Cases`; `ArityCases` / `one` / `two` / `three` / `four`; `TypePatternCases` / `homogeneous_int` / `homogeneous_bool` / `alternating_int_bool` / `alternating_bool_int`; `TargetCases` / `global` / `namespace_global` / `instance_method`; `OmittedCount` / `omit0` / `omitN`.
- Construction/oracle expressions retained from the card: `ExpectedResult(Arity, Pattern, OmittedCount)`; `100, 12, 16, -7`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-FN-VALUE-LIFECYCLE

- Class: `AngelscriptTest::Generate::FFnValueLifecycleGenerator`; task: 5.19.
- Cells: **24**; categories: normal=6, reject=0, divide_by_zero=18, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildSource(const FFnValueLifecycleParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-FN-VALUE-LIFECYCLE-NONE-ZERO-VALUE_ARGUMENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Functions/AngelscriptNativeFunctionValueLifecycleTests.cpp`.
- Card SHA256: `d823947b340daf987994e9dac54a3aa04c28912218542902454eb9d18defd2d3`; inspected source SHA256: `24eeb615212927e90a49e00b5007460cf570846aa700117c5ba7c1a0d1d264c7`.
- Axis tables and tokens in documented order: `*Cases`; `FailureCases` / `none` / `argument_evaluation` / `body` / `return_construction`; `InitializedCases` / `zero` / `one` / `many`; `TransferCases` / `value_argument` / `value_return`.
- Construction/oracle expressions retained from the card: `GetExpected`; `none`; `argument_evaluation`; `body`; `1 / Zero`; `/ 0`; `return_construction`; `ArmNextNativeCaseValueCopyFault()`; `Context->SetException("Native case value copy construction fault")`; `throw`; `Divide by zero`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
- Classification clarification: the original card header grouped runtime faults; the breakdown here follows its explicit observation section.
