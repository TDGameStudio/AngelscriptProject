# Constructors product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/ctor. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 7. Declared cells: 1368.

## LANG-CTOR-BOUNDARY

- Class: `AngelscriptTest::Generate::FCtorBoundaryGenerator`; task: 11.1.
- Cells: **68**; categories: normal=20, reject=40, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=8, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildConstructorBoundarySource(const FCtorBoundaryParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CTOR-BOUNDARY-DUPLICATE_DEFAULT_SIGNATURE-COMPILE_OR_EXECUTION_STATE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Constructors/AngelscriptNativeConstructorBoundaryTests.cpp`.
- Card SHA256: `489de90ee5eddb64d022cb8c7341d7fbcc2811ecdaa194c6c4f1bf64b6f79e19`; inspected source SHA256: `b1e69bfab2e54ee20f4a60a161ddc7e63a6c0fc0d6fc6b99db9ea22adf09a440`.
- Axis tables and tokens in documented order: `*Cases`; `ScenarioCases` / `duplicate_default_signature` / `duplicate_parameter_signature` / `mismatched_constructor_name` / `constructor_value_return` / `super_outside_constructor` / `super_after_statement` / `repeated_super` / `missing_base_argument` / `ambiguous_base_argument` / `inaccessible_base` / `recursive_value_field_direct` / `recursive_value_field_indirect` / `recursive_constructor_direct` / `recursive_constructor_indirect` / `mutable_reference_global` / `module_discard_const_value_global` / `engine_shutdown_const_value_global`; `ObservationCases` / `compile_or_execution_state` / `diagnostic_or_metadata` / `lifecycle_cleanup` / `recovery_or_teardown`.
- Construction/oracle expressions retained from the card: `RunConstructorBoundary`; `GetExpected`; `duplicate_default_signature`; `42`; `super_after_statement`; `7`; `module_discard_const_value_global`; `engine_shutdown_const_value_global`; `71`; `duplicate_parameter_signature`; `Stack overflow`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CTOR-KIND-CALL

- Class: `AngelscriptTest::Generate::FCtorKindCallGenerator`; task: 11.2.
- Cells: **288**; categories: normal=257, reject=31, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildConstructorSelectionSource(const FCtorKindCallParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CTOR-KIND-CALL-LOCAL-IMPLICIT_DEFAULT-SCRIPT_VALUE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Constructors/AngelscriptNativeConstructorSelectionTests.cpp`.
- Card SHA256: `ab4725f5590d2d31fb2be41b4b3fa80ab0fdf052d35c81ce528bbaf4926ff643`; inspected source SHA256: `58aa0478f98912bb4fdd538f613aa0c5d7272c3e4a1f86227f5864042788147e`.
- Axis tables and tokens in documented order: `*Cases`; `CallCases` / `local` / `temporary` / `field` / `return` / `argument` / `base_call` / `copy_declaration` / `assignment`; `KindCases` / `implicit_default` / `declared_default` / `parameterized` / `overloaded` / `copy` / `conversion`; `ObjectCases` / `script_value` / `script_reference` / `base` / `derived` / `native_value` / `native_reference`.
- Construction/oracle expressions retained from the card: `ExpectedReturnedValue`; `RunConstructorSelection`; `Base = (Kind==implicit_default) || (Kind==declared_default && Object==native_value) ? 0 : 7`; `GetExpected`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CTOR-ORDER-FAILURE

- Class: `AngelscriptTest::Generate::FCtorOrderFailureGenerator`; task: 11.3.
- Cells: **128**; categories: normal=16, reject=0, divide_by_zero=112, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildConstructorFailureSource(const FCtorOrderFailureParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CTOR-ORDER-FAILURE-NONE-FLAT_MEMBERS-VALUES`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Constructors/AngelscriptNativeConstructorFailureTests.cpp`.
- Card SHA256: `3c265a327bd665d80d8298d7c888def2d3f02ecfc6c3df6c0420e196c8d9fcd2`; inspected source SHA256: `876fc7b58c70b8828cb0270ed2e30d3967006588391043fbea5fde8dde8e2bef`.
- Axis tables and tokens in documented order: `*Cases`; `FailureCases` / `none` / `base` / `member_first` / `member_middle` / `member_last` / `derived_body` / `copy` / `conversion`; `DepthCases` / `flat_members` / `nested_members` / `deep_nested_members` / `base_and_derived_members`; `ObservationCases` / `values` / `event_order` / `cleanup` / `context_reuse`.
- Construction/oracle expressions retained from the card: `VerifyValues`; `Failure.Stage==0`; `150`; `asEXECUTION_EXCEPTION`; `GetExpected`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CTOR-PARAM-SELECT

- Class: `AngelscriptTest::Generate::FCtorParamSelectGenerator`; task: 11.4.
- Cells: **300**; categories: normal=152, reject=148, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildConstructorParameterSource(const FCtorParamSelectParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CTOR-PARAM-SELECT-ONE-EXACT-INT8`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Constructors/AngelscriptNativeConstructorParameterTests.cpp`.
- Card SHA256: `e13b0024cd7f7ec36eeaab0fd4b91e07de434150a3e8e1e5d3eee5d5863e9ecc`; inspected source SHA256: `c23e1a7f0bdec5e74fc1c2c1623f70a4cd7076bb0ae02fcfc21f231efd0a9a89`.
- Axis tables and tokens in documented order: `*Cases`; `ArityCases` / `one` / `two` / `five` / `sixteen`; `SelectionCases` / `exact` / `promotion` / `explicit_conversion` / `ambiguous` / `missing`; `TypeCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `float32` / `float64` / `bool` / `enum` / `typedef` / `script_value` / `native_value`.
- Construction/oracle expressions retained from the card: `ExpectedChecksum`; `RunConstructorParameter`; `GetExpected`; `i = 0 .. Arity.Count-1`; `bool`; `1`; `0`; `i+1`; `N(N+1)/2`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CTOR-SPECIAL-POLICY

- Class: `AngelscriptTest::Generate::FCtorSpecialPolicyGenerator`; task: 11.5.
- Cells: **64**; categories: normal=44, reject=20, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildConstructorPolicySource(const FCtorSpecialPolicyParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CTOR-SPECIAL-POLICY-COMPILE-IMPLICIT_STRUCT_DEFAULT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Constructors/AngelscriptNativeConstructorPolicyTests.cpp`.
- Card SHA256: `fea0178d1721d9f1a998d329c8512d95a7376da269f1366998bd6baa6f1d2918`; inspected source SHA256: `1ad60e13369a108c77e1e95d2b0a8e89630cbdc13eef13446486272103a67f0f`.
- Axis tables and tokens in documented order: `compile` / `metadata` / `runtime` / `lifecycle`; `FScenario.CatalogName` / `implicit_struct_default` / `declared_struct_default` / `parameter_preserves_generated_default` / `parameter_suppresses_default_option_off` / `implicit_struct_copy` / `declared_struct_copy` / `implicit_struct_assignment` / `declared_struct_assignment` / `user_destructor_copy` / `class_factory_default` / `class_parameter_factory` / `derived_generated_default` / `derived_explicit_super` / `missing_base_default_option_off` / `copy_after_user_constructor` / `assignment_self_stability`.
- Construction/oracle expressions retained from the card: `FScenario.ExpectedReturnValue`; `GetExpected`; `implicit_struct_default=0`; `declared_struct_default=12`; `parameter_preserves_generated_default=13`; `declared_struct_copy=32`; `implicit_struct_assignment=34`; `declared_struct_assignment=36`; `class_factory_default=20`; `class_parameter_factory=21`; `derived_generated_default=34`; `derived_explicit_super=26`; `assignment_self_stability=84`; `ExpectedDiagnostic`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CTOR-TRANSFER

- Class: `AngelscriptTest::Generate::FCtorTransferGenerator`; task: 11.6.
- Cells: **448**; categories: normal=448, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildConstructorTransferSource(const FCtorTransferParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CTOR-TRANSFER-SCRIPT_VALUE_LOCAL-COPY_DECLARATION_LOCAL-INITIAL_IDENTITY_VALUE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Constructors/AngelscriptNativeConstructorTransferTests.cpp`.
- Card SHA256: `e27ca0fd1c66fbab68b5345169520b72a9160dd96aba943d4c3e51db747cfdee`; inspected source SHA256: `8b6973143bdd8c359bf412b2ccf4d49ec2cc3e96c43cb45e6ddc44d7f8fafaa9`.
- Axis tables and tokens in documented order: `*Cases`; `SourceCases` / `script_value_local` / `script_value_temporary` / `script_value_return` / `native_value_local` / `native_value_temporary` / `native_value_return` / `script_reference_local` / `script_reference_temporary` / `script_reference_return` / `native_reference_local` / `native_reference_temporary` / `native_reference_return` / `derived_reference_exact` / `derived_reference_base_view`; `WorkflowCases` / `copy_declaration_local` / `field_constructor_transfer` / `assignment_local` / `field_assignment_after_default` / `argument_transfer` / `return_transfer` / `self_assignment` / `chained_assignment`; `ObservationCases` / `initial_identity_value` / `source_or_temporary_state` / `target_mutation_relation` / `lifecycle_cleanup`.
- Construction/oracle expressions retained from the card: `RunConstructorTransfer`; `ExpectedObservation`; `ExpectedRelation`; `GetExpected`; `1`; `throw`; `SetException`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CTOR-VISIBILITY

- Class: `AngelscriptTest::Generate::FCtorVisibilityGenerator`; task: 11.7.
- Cells: **72**; categories: normal=21, reject=51, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildConstructorVisibilitySource(const FCtorVisibilityParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CTOR-VISIBILITY-EXACT-OWNER-DEFAULT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Constructors/AngelscriptNativeConstructorVisibilityTests.cpp`.
- Card SHA256: `42eda5ad755fbb61248190464b621e72acd1307bea59c8297609eb37598ef0e4`; inspected source SHA256: `1c766c6d5df3e66b651713165a978912751508b9336b7752020bb8921f843c63`.
- Axis tables and tokens in documented order: `*Cases`; `SelectionCases` / `exact` / `promotion` / `explicit_cast` / `implicit_rejected` / `ambiguous` / `missing`; `SiteCases` / `owner` / `derived` / `unrelated` / `global`; `VisibilityCases` / `default` / `protected` / `private`.
- Construction/oracle expressions retained from the card: `RunConstructorVisibility`; `GetExpected`; `7`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
