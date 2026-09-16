# Properties product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/prop. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 9. Declared cells: 3018.

## LANG-PROP-ACCESSOR

- Class: `AngelscriptTest::Generate::FPropAccessorGenerator`; task: 8.1.
- Cells: **72**; categories: normal=36, reject=28, divide_by_zero=8, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildRegisteredPropertySource(const FPropAccessorParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-PROP-ACCESSOR-GETTER_READ_MUTABLE-SINGLE_LINE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Properties/AngelscriptNativeRegisteredPropertyTests.cpp`.
- Card SHA256: `f190814f53436c497631883f3bc18a0018f9502c376e7125800d0b3283be3cea`; inspected source SHA256: `2441fa72de429b91b8d5c91900b677980017bb1cc79cb06163a5261d3754ab59`.
- Axis tables and tokens in documented order: `*Cases`; `ScenarioCases` / `getter_read_mutable` / `getter_read_const` / `getter_nonconst_read_mutable` / `getter_nonconst_read_const_rejected` / `getter_write_missing` / `getter_compound_missing_set` / `setter_write_mutable` / `setter_write_const_rejected` / `setter_read_missing` / `setter_compound_missing_get` / `both_read_mutable` / `both_write_mutable` / `both_compound_mutable` / `both_compound_const_rejected` / `recursive_getter` / `recursive_setter` / `throwing_getter` / `throwing_setter`; `SourceShapeCases` / `single_line` / `multiline` / `parenthesized` / `helper_call`.
- Construction/oracle expressions retained from the card: `FScenarioCase.bShouldCompile`; `ExpectedValue`; `bShouldThrow`; `FRegisteredPropertyTests`; `Receiver.Value`; `property`; `RegisterObjectMethod`; `GetExpected = Scenario.ExpectedValue`; `31`; `73`; `both_compound_mutable`; `36`; `getter_nonconst_read_const_rejected`; `getter_write_missing`; `getter_compound_missing_set`; `setter_write_const_rejected`; `setter_read_missing`; `setter_compound_missing_get`; `both_compound_const_rejected`; `throwing_getter`; `throwing_setter`; `SetException`; `1 / Zero`; `Divide by zero`; `throw`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-PROP-COPY-INDEPENDENCE

- Class: `AngelscriptTest::Generate::FPropCopyIndependenceGenerator`; task: 8.2.
- Cells: **459**; categories: normal=459, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildPropertyCopySource(const FPropCopyIndependenceParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-PROP-COPY-INDEPENDENCE-SOURCE_AFTER_TRANSFER-COPY_CONSTRUCT-INT8-EXACT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Properties/AngelscriptNativePropertyCopyTests.cpp`.
- Card SHA256: `7e1ccc61b46b1f516315a4ab504e0f70645e576414f62c6d637229c4785149c8`; inspected source SHA256: `90cf638bf7f812ff5f06786b01aee4beb8f889adfc1cecd4b88e5c504c7ff4b8`.
- Axis tables and tokens in documented order: `*Cases`; `MutationCases` / `source_after_transfer` / `target_after_transfer` / `nested_member`; `TransferCases` / `copy_construct` / `assign` / `self_assign`; `TypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef` / `script_value` / `native_value` / `script_reference` / `native_reference`; `ViewCases` / `exact` / `base` / `derived`.
- Construction/oracle expressions retained from the card: `ExpectedSourceValue`; `ExpectedTargetValue`; `ExpectedSameIdentity`; `FPropertyCopyTests`; `1`; `0`; `11`; `22`; `1-Before`; `37`; `GetExpected = ExpectedSourceValue * 1000 + ExpectedTargetValue`; `self_assign`; `source_after_transfer`; `script_reference`; `native_reference`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-PROP-FAILURE

- Class: `AngelscriptTest::Generate::FPropFailureGenerator`; task: 8.3.
- Cells: **56**; categories: normal=0, reject=36, divide_by_zero=16, integer_overflow=0, power_overflow=0, null_pointer=4, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildPropertyFailureSource(const FPropFailureParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-PROP-FAILURE-NULL_RECEIVER-DIRECT-FRESH_MODULE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Properties/AngelscriptNativePropertyFailureTests.cpp`.
- Card SHA256: `28dcea1acc674e74828668072233a5f930af8523f44f73cf9ba372e4772d6d04`; inspected source SHA256: `fc4c4dc0912bb790bec91638ce8291ea02554b032d29e0e1c2169e3802ce65d7`.
- Axis tables and tokens in documented order: `*Cases`; `FailureCases` / `removed_property_decorator` / `removed_virtual_property` / `missing_getter` / `missing_setter` / `registered_mismatched_types` / `registered_duplicate_getter` / `registered_duplicate_setter` / `recursive_getter` / `recursive_setter` / `throwing_getter` / `throwing_setter` / `null_receiver` / `inaccessible_field` / `compound_value_receiver`; `ProbeCases` / `direct` / `alternate_path`; `RecoveryCases` / `fresh_module` / `same_module_or_context`.
- Construction/oracle expressions retained from the card: `FFailureCase.Phase`; `ExpectedText`; `FPropertyFailureTests`; `GetExpected`; `removed_property_decorator`; `The 'property' decorator has been removed`; `removed_virtual_property`; `Virtual property syntax has been removed`; `missing_getter`; `missing_setter`; `registered_mismatched_types`; `inaccessible_field`; `compound_value_receiver`; `registered_duplicate_getter`; `registered_duplicate_setter`; `asALREADY_REGISTERED`; `throwing_*`; `recursive_*`; `SetException`; `1 / Zero`; `Divide by zero`; `null_receiver`; `Null pointer access`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
- Classification clarification: the original card header grouped runtime faults; the breakdown here follows its explicit observation section.

## LANG-PROP-FORK-SEMANTICS

- Class: `AngelscriptTest::Generate::FPropForkSemanticsGenerator`; task: 8.4.
- Cells: **13**; categories: normal=1, reject=12, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildDirectMethodSource(const FPropForkSemanticsParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-PROP-FORK-SEMANTICS-DIRECT_METHOD-READ_WRITE_INDEXED`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Properties/AngelscriptNativePropertyForkSemanticsTests.cpp`.
- Card SHA256: `0f38361c7b78cda94cb7fb04e6826247d29560fb0935e188a410124d9366c633`; inspected source SHA256: `3d41dd5c0b8a1319685fe2d25fc06b3e2154df063b2168c1c59c54244a2dfedd`.
- Axis tables and tokens in documented order: `script-decorator` / `getter` / `setter` / `indexed_getter` / `indexed_setter` / `BuildDecoratorSource`; `native-registration` / `RegisterObjectMethod`; `automatic-access` / `read` / `write` / `indexed_read` / `indexed_write` / `BuildAutomaticAccessSource`; `direct-method` / `read-write-indexed` / `BuildDirectMethodSource`.
- Construction/oracle expressions retained from the card: `DecoratorRegistrationAndAutomaticAccessAreRejected`; `FPropertyForkSemanticsTests`; `int get_Value() property`; `GetExpected = 88`; `GetValue() + GetIndexedValue(2)`; `The 'property' decorator has been removed`; `RegisterObjectMethod(..., "... property")`; `asINVALID_DECLARATION`; `'Value' is not a member`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-PROP-INDEXED

- Class: `AngelscriptTest::Generate::FPropIndexedGenerator`; task: 8.5.
- Cells: **468**; categories: normal=129, reject=339, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildIndexedPropertySource(const FPropIndexedParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-PROP-INDEXED-SAME_TYPE-INT8-READ-MUTABLE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Properties/AngelscriptNativeIndexedPropertyTests.cpp`.
- Card SHA256: `606ebc33758027eaec49da264e10f314c50823268ad5e6fab7a4ccc9150e9fae`; inspected source SHA256: `e126afdc2fc341eeb90509c4c866b86b32bf1766a78521f298db0b061e1a17a4`.
- Axis tables and tokens in documented order: `*Cases`; `CandidateSetCases` / `same_type` / `adjacent_numeric` / `cross_family` / `competing_primary_first` / `competing_secondary_first` / `unrelated`; `IndexTypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef`; `OperationCases` / `read` / `write` / `compound`; `ReceiverCases` / `mutable` / `const`.
- Construction/oracle expressions retained from the card: `ShouldCompileAndExecute`; `FIndexedPropertyTests`; `Receiver.Value[Index]`; `get_Value`; `set_Value`; `property`; `Selected.Marker * 100 + IndexType.ExpectedArgumentValue`; `Selected.Marker * 10000 + IndexType.ExpectedArgumentValue * 100 + 73`; `same_type=101`; `adjacent_numeric=201`; `cross_family=301`; `competing_primary_first`; `competing_secondary_first`; `compound`; `read`; `bMatchesSource==false`; `unrelated`; `bool`; `enum`; `write`; `const`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-PROP-INIT-ORDER

- Class: `AngelscriptTest::Generate::FPropInitOrderGenerator`; task: 8.6.
- Cells: **1500**; categories: normal=1500, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildPropertyInitializationSource(const FPropInitOrderParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-PROP-INIT-ORDER-BASE_ENTRY-BASE_FIRST-DEFAULT_VALUE-INT8`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Properties/AngelscriptNativePropertyInitializationTests.cpp`.
- Card SHA256: `1d4ef77c41deda949f28c3ed73f9091c7eeacab596e3533dc35cfd20b1ccb07b`; inspected source SHA256: `aa98473285ff74967ee4b7c78141c43488128908253b56dfdd7cf5ff4c2b91c6`.
- Axis tables and tokens in documented order: `*Cases`; `ObservationCases` / `base_entry` / `base_exit` / `derived_entry` / `derived_exit`; `PositionCases` / `base_first` / `base_middle` / `base_last` / `derived_first` / `derived_last`; `SourceCases` / `default_value` / `declaration_initializer` / `owner_literal_assignment` / `owner_source_assignment` / `derived_reassignment`; `TypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef` / `script_value` / `native_value`.
- Construction/oracle expressions retained from the card: `ExpectedFinalValue`; `ExpectedCheckpointValue`; `FPropertyInitializationTests`; `GetExpected = ExpectedFinalValue(Source)`; `default_value`; `derived_reassignment`; `0`; `1`; `base_entry`; `base_exit`; `-777`; `declaration_initializer`; `derived_entry`; `derived_exit`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-PROP-REBUILD

- Class: `AngelscriptTest::Generate::FPropRebuildGenerator`; task: 8.7.
- Cells: **90**; categories: normal=90, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildScenarioSource(const FPropRebuildParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-PROP-REBUILD-METADATA-REBUILD-STORED_SAME_SOURCE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Properties/AngelscriptNativePropertyRebuildTests.cpp`.
- Card SHA256: `3607b539efd4f62620cf639502b2b7ca31187ba541b50bca8a5c760eaabb94e9`; inspected source SHA256: `21d5c0d2f9f1b6e1fa717f955a5955186e2c444dd33f885cb3f6d3cdf620931b`.
- Axis tables and tokens in documented order: `*Cases`; `ObservationCases` / `metadata` / `runtime` / `old_handle_cleanup`; `PathCases` / `rebuild` / `save_load`; `ScenarioCases` / `stored_same_source` / `stored_value` / `stored_field_type` / `stored_field_order` / `stored_inheritance` / `registered_same_source` / `registered_read_value` / `registered_getter_presence` / `registered_setter_presence` / `registered_constness` / `registered_indexed_same_source` / `registered_indexed_value` / `registered_indexed_constness` / `registered_indexed_index_type` / `registered_indexed_overload_set`.
- Construction/oracle expressions retained from the card: `ExpectedRuntimeValue`; `ExpectedTraceMarker`; `FPropertyRebuildTests`; `GetExpected = ExpectedRuntimeValue(Scenario, /*bSecondVersion=*/true)`; `registered_setter_presence`; `73`; `stored_value`; `stored_field_type`; `stored_field_order`; `stored_inheritance`; `registered_read_value`; `registered_indexed_value`; `29`; `+1`; `11`; `registered_getter_presence`; `metadata`; `old_handle_cleanup`; `runtime`; `INDEX_NONE`; `300`; `200`; `100`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-PROP-VALUE-OP

- Class: `AngelscriptTest::Generate::FPropValueOpGenerator`; task: 8.8.
- Cells: **300**; categories: normal=243, reject=57, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildStoredPropertySource(const FPropValueOpParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-PROP-VALUE-OP-DEFAULT_READ-MUTABLE-INT8`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Properties/AngelscriptNativeStoredPropertyTests.cpp`.
- Card SHA256: `4cfd3492bedb222a31521eb6504d417c6cae587f566b50b63c488b547cc7f5d2`; inspected source SHA256: `cf78819db6992bc2c3a797dce45ec525090558e0fa08a01e7bffc3063bb5fb9d`.
- Axis tables and tokens in documented order: `*Cases`; `OperationCases` / `default_read` / `write` / `compound_write` / `copy` / `reference_mutation`; `ReceiverCases` / `mutable` / `const` / `base_view` / `derived_view`; `TypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef` / `script_value` / `native_value`.
- Construction/oracle expressions retained from the card: `ShouldCompile`; `ExpectedResult`; `FStoredPropertyTests`; `GetExpected = ExpectedCoreResult * 100 + Receiver.Marker`; `default_read`; `0`; `copy`; `1`; `37`; `29`; `mutable`; `const`; `11`; `base_view`; `derived_view`; `22`; `compound_write`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-PROP-VISIBILITY

- Class: `AngelscriptTest::Generate::FPropVisibilityGenerator`; task: 8.9.
- Cells: **60**; categories: normal=42, reject=18, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildPropertyVisibilitySource(const FPropVisibilityParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-PROP-VISIBILITY-OWNER_METHOD-READ-DEFAULT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Properties/AngelscriptNativePropertyVisibilityTests.cpp`.
- Card SHA256: `4d70aa8f6210e9aa5da997be748907ba964f39f052f3694112235833f17d8705`; inspected source SHA256: `578c81633231beba58e3ed94ad9c96b58b6046294d7bd2ab4b6cf8c75e3b1566`.
- Axis tables and tokens in documented order: `*Cases`; `AccessPathCases` / `owner_method` / `owner_constructor` / `owner_destructor` / `accessor_body` / `direct_derived` / `deep_derived` / `unrelated_type` / `global_same_module` / `base_view_from_derived` / `derived_view_from_global`; `OperationCases` / `read` / `write`; `VisibilityCases` / `default` / `private` / `protected`.
- Construction/oracle expressions retained from the card: `ShouldCompile`; `FOperationCase.ExpectedValue`; `FPropertyVisibilityTests`; `GetExpected = Operation.ExpectedValue`; `41`; `67`; `owner_*`; `accessor_body`; `direct_derived`; `deep_derived`; `base_view_from_derived`; `!private`; `default`; `private`; `derived_view_from_global`; `protected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
