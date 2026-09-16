# Variables product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/var. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 8. Declared cells: 1925.

## LANG-VAR-ASSIGN-TARGET

- Class: `AngelscriptTest::Generate::FVarAssignTargetGenerator`; task: 6.1.
- Cells: **595**; categories: normal=212, reject=383, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildAssignmentSource(const FVarAssignTargetParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-VAR-ASSIGN-TARGET-SIMPLE-MUTABLE_LOCAL-INT8`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Variables/AngelscriptNativeVariableAssignmentTests.cpp`.
- Card SHA256: `af993d62285d35f838aa6eaa55d7d19535add453d203bc12c4450da3343fb492`; inspected source SHA256: `4f7a30178ba0dbabb37e7931b4770b4c5862a52290f0e1709e5ded24b85415f6`.
- Axis tables and tokens in documented order: `*Cases`; `AssignmentCases` / `simple` / `copy_source` / `self_assignment` / `compound` / `reference_rebind`; `TargetCases` / `mutable_local` / `const_local` / `mutable_field` / `const_field` / `reference_alias` / `temporary` / `expression_result`; `TypeCases` / `NativeTypeCases` / `null` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef` / `script_value` / `native_value` / `script_reference` / `native_reference`.
- Construction/oracle expressions retained from the card: `ExpectedResult`; `GetExpected`; `TargetAfter*100+SourceAfter`; `37*100+37`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `ShouldCompile`; `mutable_local`; `mutable_field`; `reference_alias`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT

- Class: `AngelscriptTest::Generate::FVarCountedReferenceAssignmentGenerator`; task: 6.2.
- Cells: **7**; categories: normal=6, reject=0, divide_by_zero=1, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildReferenceAssignmentSource(const FVarCountedReferenceAssignmentParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT-FACTORY_LOCAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Variables/AngelscriptNativeCountedReferenceAssignmentTests.cpp`.
- Card SHA256: `37762bf716addf1a645936fe96e5c3130f19811aee4eafda499258468f0a644f`; inspected source SHA256: `7385e6bc77530fe11acb761bb0bec53f63123361007f73861cc49d9c4a02b986`.
- Axis tables and tokens in documented order: `EReferenceAssignmentScenario`; `ScenarioCases` / `factory_local` / `overwrite` / `null_assignment` / `parameter_return` / `exception_frame` / `save_load` / `parameter_return_save_load`.
- Construction/oracle expressions retained from the card: `FReferenceAssignmentCase::ExpectedReturnValue`; `GetExpected`; `factory_local`; `save_load`; `overwrite`; `null_assignment`; `parameter_return`; `parameter_return_save_load`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `exception_frame`; `Divide by zero`; `1 / Zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-VAR-FAILURE-BOUNDARY

- Class: `AngelscriptTest::Generate::FVarFailureBoundaryGenerator`; task: 6.3.
- Cells: **28**; categories: normal=12, reject=12, divide_by_zero=4, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildBoundarySource(const FVarFailureBoundaryParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-VAR-FAILURE-BOUNDARY-FRESH_MODULE-LONG_IDENTIFIER`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Variables/AngelscriptNativeVariableFailureBoundaryTests.cpp`.
- Card SHA256: `10d45eb02dbce041ae6e0cf523907fc10fee0bb4974963c1db656f129b920b88`; inspected source SHA256: `24a4fd4d80e069c1502a50890ceb88bf32e14f1aa31590bf7937e168c057b169`.
- Axis tables and tokens in documented order: `*Cases`; `RecoveryCases` / `fresh_module` / `same_module_or_context`; `ScenarioCases` / `use_before_declaration` / `use_after_scope` / `duplicate_same_scope` / `incompatible_initializer` / `mutable_global` / `reference_global` / `uninitialized_read` / `initializer_exception` / `failed_initializer_atomicity` / `long_identifier` / `many_locals_supported` / `many_locals_boundary` / `stack_frame_pressure` / `module_discard`.
- Construction/oracle expressions retained from the card: `FScenarioCase::ExpectedReturn`; `EScenarioOutcome`; `GetExpected`; `long_identifier`; `module_discard`; `many_locals_supported`; `stack_frame_pressure`; `many_locals_boundary`; `uninitialized_read`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `initializer_exception`; `41 / Zero`; `failed_initializer_atomicity`; `ArmNextNativeCaseValueCopyFault`; `1 / Zero`; `Divide by zero`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-VAR-INIT-STORAGE

- Class: `AngelscriptTest::Generate::FVarInitStorageGenerator`; task: 6.4.
- Cells: **735**; categories: normal=713, reject=22, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildVariableSource(const FVarInitStorageParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-VAR-INIT-STORAGE-DEFAULT-LOCAL-INT8`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Variables/AngelscriptNativeVariableInitializationTests.cpp`.
- Card SHA256: `89ea884afdeeafdba251b530a6997fa1f2b4dfc2899b8c3fd632ef79e564996c`; inspected source SHA256: `e8ac93241bb50fd943111ac7ced34c6eb9dc4e0689799195207cdf75b3857515`.
- Axis tables and tokens in documented order: `*Cases`; `InitializerCases` / `default` / `literal` / `expression` / `copy` / `constructor` / `function_return` / `conditional`; `StorageCases` / `local` / `const_local` / `auto` / `loop_initializer` / `branch_local` / `const_global` / `field_linkage`; `TypeCases` / `IsCoreValueTypeCase` / `NativeTypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef` / `script_value` / `native_value`.
- Construction/oracle expressions retained from the card: `ExpectedValue`; `GetExpected`; `default`; `expression`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `ShouldCompile`; `auto`; `const_global`; `native_value`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-VAR-LIFETIME

- Class: `AngelscriptTest::Generate::FVarLifetimeGenerator`; task: 6.5.
- Cells: **100**; categories: normal=80, reject=0, divide_by_zero=20, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildVariableLifetimeSource(const FVarLifetimeParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-VAR-LIFETIME-BLOCK_END-ONE-LOCAL_VALUE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Variables/AngelscriptNativeVariableLifetimeTests.cpp`.
- Card SHA256: `eff03cfb563fab819d06dad8778bcc7bcab1356a23cf7908c87776c6d3970088`; inspected source SHA256: `9bf97e3dc757424076f61b3a84d1e5f1a4b5ce0151192a8c4f9034d069c10cf1`.
- Axis tables and tokens in documented order: `*Cases`; `ExitCases` / `block_end` / `return` / `break` / `continue` / `exception`; `NestingCases` / `one` / `sequential` / `nested_scopes` / `loop` / `nested_call`; `OwnerCases` / `local_value` / `nested_value` / `field` / `reference`.
- Construction/oracle expressions retained from the card: `FExitCase::ReturnValue`; `GetExpected`; `block_end`; `return`; `break`; `continue`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `exception`; `Divide by zero`; `throw`; `1 / Zero`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-VAR-LOOP-DECL-LIFETIME

- Class: `AngelscriptTest::Generate::FVarLoopDeclLifetimeGenerator`; task: 6.6.
- Cells: **200**; categories: normal=168, reject=0, divide_by_zero=32, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildVariableLoopSource(const FVarLoopDeclLifetimeParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-VAR-LOOP-DECL-LIFETIME-NORMAL-ZERO-FOR_INITIALIZER-SCRIPT_VALUE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Variables/AngelscriptNativeVariableLoopLifetimeTests.cpp`.
- Card SHA256: `2ae5a838056bad89194cfbf7db952ebcd676fcb218371ccc75a874beefe646c9`; inspected source SHA256: `1fe9cae63217fe5355090f01b3f70159a30a3b7088c62ce55406a22fdfe807e8`.
- Axis tables and tokens in documented order: `*Cases`; `ExitCases` / `normal` / `break` / `continue` / `return` / `exception`; `IterationCases` / `zero` / `one` / `three` / `eight`; `PlacementCases` / `for_initializer` / `for_body` / `while_body` / `do_body` / `nested_body`; `TypeCases` / `script_value` / `native_value`.
- Construction/oracle expressions retained from the card: `ExpectedBodyCount`; `ShouldRaiseException`; `ReturnBase`; `GetExpected`; `Exit.ReturnBase + ExpectedBodyCount`; `do_body`; `max(1, Count)`; `Count`; `break`; `return`; `exception`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `zero`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-VAR-REFERENCE-INIT

- Class: `AngelscriptTest::Generate::FVarReferenceInitGenerator`; task: 6.7.
- Cells: **150**; categories: normal=128, reject=20, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=2, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildReferenceInitializationSource(const FVarReferenceInitParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-VAR-REFERENCE-INIT-EXPLICIT_TYPE-CONSTRUCTED_LOCAL-SCRIPT_REFERENCE-IDENTITY`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Variables/AngelscriptNativeVariableReferenceInitializationTests.cpp`.
- Card SHA256: `dbbfef06da76bb55c73555455fddde79aa2ae5aea9f1b6386f78bee31a7302e3`; inspected source SHA256: `5340cfb49009ae88b163b5096819de679c5e895c305c615bc605a35015abede2`.
- Axis tables and tokens in documented order: `*Cases`; `DeclarationCases` / `explicit_type` / `auto` / `const_view`; `SourceCases` / `constructed_local` / `parameter` / `function_return` / `field` / `null`; `TypeCases` / `script_reference` / `native_reference`; `UseCases` / `identity` / `mutation` / `argument` / `return` / `null_compare`.
- Construction/oracle expressions retained from the card: `ShouldCompile`; `ShouldRaiseNullException`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `null`; `explicit_type`; `mutation`; `auto`; `const_view`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-VAR-SHADOW

- Class: `AngelscriptTest::Generate::FVarShadowGenerator`; task: 6.8.
- Cells: **110**; categories: normal=89, reject=21, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildScopeSource(const FVarShadowParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-VAR-SHADOW-NONE-FUNCTION_AFTER_DECLARATION`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Variables/AngelscriptNativeLanguageVariableScopeTests.cpp`.
- Card SHA256: `19d0eaceae3577d898e8089f8d1454f6736705dde18fed9c3a302b11ce1a79c5`; inspected source SHA256: `a0cb9f7892e0aa5ed891587f1f44cea72df2215a94efe7eb01da116b11858592`.
- Axis tables and tokens in documented order: `*Cases`; `RelationCases` / `none` / `inner_outer` / `parameter_global` / `parameter_member` / `sibling`; `ScopeUsePathCases` / `function_before_declaration` / `function_after_declaration` / `function_sibling_call` / `nested_block_before` / `nested_block_inside` / `nested_block_after` / `if_branch_before` / `if_branch_inside` / `if_branch_after` / `switch_case_before` / `switch_case_inside` / `switch_case_after` / `for_initializer` / `for_body` / `for_after` / `while_before` / `while_body` / `while_after` / `nested_call_caller_before` / `nested_call_callee` / `nested_call_caller_after` / `after_owner`; `foreach_before` / `foreach_body` / `foreach_after`.
- Construction/oracle expressions retained from the card: `ExpectedValue`; `ShouldCompile`; `GetExpected`; `after_owner`; `inner_outer`; `sibling`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
