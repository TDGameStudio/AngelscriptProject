# References product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/ref. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 7. Declared cells: 766.

## LANG-REF-DIRECTION

- Class: `AngelscriptTest::Generate::FRefDirectionGenerator`; task: 7.1.
- Cells: **96**; categories: normal=96, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildReferenceDirectionSource(const FRefDirectionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-REF-DIRECTION-VALUE-NON_NULL-SAME_TWO_NAMES`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/References/AngelscriptNativeReferenceDirectionTests.cpp`.
- Card SHA256: `3b16cc33ec356a3f086914e2d2ce206664e0262658c5ce3e9e7a5a229b387746`; inspected source SHA256: `c2cda6c296db62f56d5548b18903c0c2036bd4b0eb00d11eb756a1c1a161b8f3`.
- Axis tables and tokens in documented order: `*Cases`; `DirectionCases` / `NativeDirectionCases` / `value` / `in` / `out` / `inout`; `NullCases` / `non_null` / `null_input` / `null_output` / `null_return`; `RelationCases` / `same_two_names` / `distinct` / `self_assignment` / `base_derived_views` / `out_replacement` / `inout_mutation`.
- Construction/oracle expressions retained from the card: `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `LANG-REF-DIRECTION-FORK-GLOBAL`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-REF-DIRECTION-FORK-GLOBAL

- Class: `AngelscriptTest::Generate::FRefDirectionForkGlobalGenerator`; task: 7.2.
- Cells: **1**; categories: normal=0, reject=1, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildRefDirectionForkGlobalSource(const FRefDirectionForkGlobalParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-REF-DIRECTION-FORK-GLOBAL-MUTABLE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/References/AngelscriptNativeReferenceDirectionMutableGlobalRejectionTests.cpp`.
- Card SHA256: `69adad1fc83fa5324a9f71b48c3e6f6619aa7510652ddd2a69a3c5d174d049ad`; inspected source SHA256: `90bf4098b3287d81945de7f63538d66b6b174f42a9eaa7c7afb1823f1841ec87`.
- Axis tables and tokens in documented order: `StateCases` / `mutable`.
- Construction/oracle expressions retained from the card: `CurrentForkRejectsMutableScriptGlobals`; `GetExpected`; `int GReferenceDirectionForkRestriction = 0;`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `must be const`; `Mutable global variables are not supported`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-REF-FAILURE

- Class: `AngelscriptTest::Generate::FRefFailureGenerator`; task: 7.3.
- Cells: **20**; categories: normal=0, reject=18, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=2, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildReferenceFailureSource(const FRefFailureParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-REF-FAILURE-NULL_MEMBER_ACCESS-FRESH_MODULE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/References/AngelscriptNativeReferenceFailureTests.cpp`.
- Card SHA256: `43a2959e5ded4ffba024b90352c0da00b353eda1c68d8d0d7cae0d7be5cbe98b`; inspected source SHA256: `f26a3c036b385befa43df20d423adab42d3d9689800b68ff6d9ed9029f41ef17`.
- Axis tables and tokens in documented order: `*Cases`; `FailureCases` / `explicit_handle` / `const_removal` / `temporary_out` / `expired_local_return` / `unrelated_assignment` / `unrelated_cast` / `null_member_access` / `stale_module_object` / `ambiguous_overload` / `incompatible_inout`; `RecoveryCases` / `fresh_module` / `same_module_or_context`.
- Construction/oracle expressions retained from the card: `IsRuntimeFailure`; `GetExpected`; `null_member_access`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `Null pointer`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-REF-FORK-DERIVED-INREF

- Class: `AngelscriptTest::Generate::FRefForkDerivedInrefGenerator`; task: 7.4.
- Cells: **1**; categories: normal=0, reject=1, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildRefForkDerivedInrefSource(const FRefForkDerivedInrefParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-REF-FORK-DERIVED-TO-BASE-INREF`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/References/AngelscriptNativeReferenceDerivedInputRejectionTests.cpp`.
- Card SHA256: `972bc0fa22be3694a31b564c189eea39c651fd678a83fd8357211c56d0e839b1`; inspected source SHA256: `696adfe0104d285e4dd946c34a47a90e3d612b55603e190cf64a6027daffb18c`.
- Axis tables and tokens in documented order: `SourceCases` / `derived`; `TargetCases` / `base_inref`.
- Construction/oracle expressions retained from the card: `CurrentForkRejectsDerivedToBaseInputReferenceConversion`; `GetExpected`; `RequireRootInput(Source, Source)`; `Source`; `FRefDerived`; `const FRefRoot&in`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `No matching signatures`; `expected const FRefRoot&`; `BuildReferenceIdentityRecoverySource`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-REF-LIFETIME

- Class: `AngelscriptTest::Generate::FRefLifetimeGenerator`; task: 7.5.
- Cells: **200**; categories: normal=150, reject=50, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildReferenceLifetimeSource(const FRefLifetimeParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-REF-LIFETIME-IDENTITY-OWNER_LIVE-NONE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/References/AngelscriptNativeReferenceLifetimeTests.cpp`.
- Card SHA256: `d98dfbaf8330d94c6d0e4880c904eec67419b36700fe69c8b69e4c02a77f57e2`; inspected source SHA256: `3c1233a54c77833d7ec4f0891741b1ff5acda5714dc800d5b0bf8794aa52ba57`.
- Axis tables and tokens in documented order: `*Cases`; `ObservationCases` / `identity` / `refcount` / `weak_flag` / `destruction` / `gc_stats`; `OwnerCases` / `owner_live` / `scope_exit` / `returned_alias` / `module_retained` / `module_discarded` / `context_retained` / `context_released` / `gc_cycle`; `ReferenceCases` / `none` / `one_alias` / `multiple_aliases` / `cycle` / `weak_flag`.
- Construction/oracle expressions retained from the card: `RunOrdinaryWorkflow`; `RunRejectedGlobalOwnerWorkflow`; `GetExpected`; `Primary == nullptr ? 0 : Primary.GetIdentity()`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `module_retained`; `module_discarded`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-REF-RESOLUTION

- Class: `AngelscriptTest::Generate::FRefResolutionGenerator`; task: 7.6.
- Cells: **160**; categories: normal=111, reject=49, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildReferenceResolutionSource(const FRefResolutionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-REF-RESOLUTION-MUTABLE_EXACT-DIRECT-MUTABLE_LVALUE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/References/AngelscriptNativeReferenceResolutionTests.cpp`.
- Card SHA256: `692384269fbeb63604f50241bea658986faa9dbc07cb2dec69205f7a03c5bff5`; inspected source SHA256: `fe3548c797b0e891c23e85ff31a13caea9f2017ecf306aadf5a630818ac7583e`.
- Axis tables and tokens in documented order: `*Cases`; `CandidateCases` / `mutable_exact` / `const_pair` / `value_vs_in` / `base_vs_derived` / `return_covariance` / `null_pair` / `numeric_conversion` / `competing_conversions` / `missing_candidate` / `incompatible_candidate`; `SiteCases` / `direct` / `helper`; `SourceCases` / `mutable_lvalue` / `const_lvalue` / `temporary` / `field` / `parameter` / `base_view` / `derived_view` / `null`.
- Construction/oracle expressions retained from the card: `ExpectedMarker`; `GetExpected`; `mutable_exact`; `const_pair`; `value_vs_in`; `base_vs_derived`; `return_covariance`; `null_pair`; `numeric_conversion`; `competing_conversions`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `IsCompileFailure`; `const_lvalue`; `null`; `direct`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-REF-SOURCE-OP

- Class: `AngelscriptTest::Generate::FRefSourceOpGenerator`; task: 7.7.
- Cells: **288**; categories: normal=193, reject=88, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=7, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildReferenceIdentitySource(const FRefSourceOpParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-REF-SOURCE-OP-INITIALIZE-MUTABLE-NEW_LOCAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/References/AngelscriptNativeReferenceIdentityTests.cpp`.
- Card SHA256: `0620b37a7025e43d1f30029d4f05b7ba3acdd2f32f3cd0c786ffe24574004762`; inspected source SHA256: `59cbbe9fe5ba877aa934211fd00ad6a0e0731e21362cc49f2bdd3f89e4d80978`.
- Axis tables and tokens in documented order: `*Cases`; `OperationCases` / `initialize` / `assign` / `pass` / `return` / `identity` / `null_compare` / `cast` / `member_access` / `alias_mutation`; `QualifierCases` / `mutable` / `const_object` / `const_input` / `const_removal_invalid`; `SourceCases` / `new_local` / `field` / `parameter` / `return` / `base_view` / `derived_view` / `native_object` / `null`.
- Construction/oracle expressions retained from the card: `IsCompileFailure`; `IsRuntimeNullFailure`; `GetExpected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`; `Divide by zero`; `throw`; `null`; `member_access`; `cast`; `alias_mutation`; `Null pointer`; `const_removal_invalid`; `mutable`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
