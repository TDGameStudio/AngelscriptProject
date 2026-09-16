# Destructors product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/dtor. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 3. Declared cells: 886.

## LANG-DTOR-DECLARATION

- Class: `AngelscriptTest::Generate::FDtorDeclarationGenerator`; task: 12.1.
- Cells: **52**; categories: normal=40, reject=4, divide_by_zero=8, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildDestructorDeclarationSource(const FDtorDeclarationParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-DTOR-DECLARATION-IMPLICIT_SCRIPT_VALUE-COMPILE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Destructors/AngelscriptNativeDestructorDeclarationTests.cpp`.
- Card SHA256: `16436cdc19382b42fff25ffcb851d20b55df2e628d46e5df03ef701138950c27`; inspected source SHA256: `8ee45fa3ea75ad91eaf4dd7da95afc910d1133b8872b0fb5642e8a4808d32cab`.
- Axis tables and tokens in documented order: `*Cases`; `ScenarioCases` / `implicit_script_value` / `declared_script_value` / `implicit_script_reference` / `declared_script_reference` / `native_value` / `native_reference` / `empty_destructor` / `field_destructor` / `base_derived_destructor` / `private_destructor` / `throwing_destructor` / `throwing_derived_members_base` / `malformed_destructor`; `ObservationCases` / `compile` / `metadata` / `runtime` / `cleanup`.
- Construction/oracle expressions retained from the card: `FScenarioCase.ExpectedValue`; `throwing_*`; `FinishedIgnoringDestructorException`; `GetExpected`; `implicit_script_value=41`; `private_destructor=50`; `Divide by zero`; `throw`; `malformed_destructor`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-DTOR-OWNER-EXIT

- Class: `AngelscriptTest::Generate::FDtorOwnerExitGenerator`; task: 12.2.
- Cells: **666**; categories: normal=522, reject=0, divide_by_zero=144, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildDestructorExitSource(const FDtorOwnerExitParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-DTOR-OWNER-EXIT-LOCAL_BLOCK_END-ONE-EVENT_ORDER`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Destructors/AngelscriptNativeDestructorExitTests.cpp`.
- Card SHA256: `dc3e9a6d51d70581e8445b0d5d2b30120c2d5dc1511163bd86c6b8c1c05f1cca`; inspected source SHA256: `d267b0cf229a7541837688f6d542c0ec310b2eebcf223f62c3bc9f86f44aff89`.
- Axis tables and tokens in documented order: `*Cases`; `ScenarioCases` / `local_block_end` / `local_return` / `local_early_return` / `local_break` / `local_continue` / `local_switch_exit` / `local_exception` / `local_abort` / `local_unprepare` / `nested_local_block_end` / `nested_local_return` / `nested_local_exception` / `field_block_end` / `field_return` / `field_exception` / `field_abort` / `base_derived_block_end` / `base_derived_return` / `base_derived_exception` / `base_derived_abort` / `temporary_statement_end` / `temporary_early_return` / `temporary_exception` / `returned_value_consume` / `returned_value_discard` / `returned_value_exception` / `argument_copy_return` / `argument_copy_exception` / `argument_copy_abort` / `reference_scope_end` / `reference_alias_scope_end` / `reference_return` / `reference_exception` / `reference_abort` / `reference_unprepare` / `module_discard_global` / `engine_shutdown_global`; `NestingCases` / `one` / `sequential` / `nested_scopes` / `nested_calls` / `loop` / `recursion`; `ObservationCases` / `event_order` / `ownership_once` / `terminal_state_recovery`.
- Construction/oracle expressions retained from the card: `ExpectedExecutionState`; `FScenarioCase.RouteId`; `void RunDestructorExit()`; `int Entry_*`; `GetExpected`; `RouteId`; `local_block_end=1`; `engine_shutdown_global`; `*_exception`; `ReachDestructorExitTerminal`; `SetException`; `1 / Zero`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-DTOR-PARTIAL

- Class: `AngelscriptTest::Generate::FDtorPartialGenerator`; task: 12.3.
- Cells: **168**; categories: normal=126, reject=0, divide_by_zero=42, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildDestructorPartialSource(const FDtorPartialParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-DTOR-PARTIAL-INDEPENDENT-BEFORE_ROOT-NORMAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Destructors/AngelscriptNativeDestructorPartialConstructionTests.cpp`.
- Card SHA256: `417a3a19919206172c90028a76a7a020dd3a154d1a732f3dd8ff4a4492294ef6`; inspected source SHA256: `b257c03266a965d4a6e21234ce2fabae66b3889a06f78ee234f6a600a7e26743`.
- Axis tables and tokens in documented order: `*Cases`; `TopologyCases` / `independent` / `nested_member` / `base_derived` / `copy_transfer` / `assignment_transfer` / `self_assignment` / `reference_alias`; `BoundaryCases` / `before_root` / `root_started` / `first_owned` / `middle_owned` / `all_owned` / `complete`; `ExitCases` / `normal` / `exception` / `abort` / `unprepare`.
- Construction/oracle expressions retained from the card: `FBoundaryCase.ExpectedNormalResult`; `VerifyExitState`; `GetExpected`; `ExpectedNormalResult`; `before_root=0`; `root_started=1`; `first_owned=101`; `middle_owned=303`; `all_owned=606`; `complete=606`; `Boundary==complete`; `copy_transfer`; `assignment_transfer`; `reference_alias`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
