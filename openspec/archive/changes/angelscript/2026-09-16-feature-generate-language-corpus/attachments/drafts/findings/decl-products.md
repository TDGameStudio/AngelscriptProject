# Declarations product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/decl. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 3. Declared cells: 414.

## LANG-DECL-COLLISION

- Class: `AngelscriptTest::Generate::FDeclCollisionGenerator`; task: 10.1.
- Cells: **96**; categories: normal=48, reject=48, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildCollisionSource(const FDeclCollisionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-DECL-COLLISION-LEFT_THEN_RIGHT-SAME-FUNCTION_OVERLOAD`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Declarations/AngelscriptNativeDeclarationCollisionTests.cpp`.
- Card SHA256: `86fb65d80239b32f80f1636fe2a86f5f02c520dd6282b0fe8e1fae322766f381`; inspected source SHA256: `be4b7ded72da1f2c335df70d391e6d361571051bef7c860d85235cf42fcde740`.
- Axis tables and tokens in documented order: `*Cases`; `InsertionOrderCases` / `left_then_right` / `right_then_left`; `NamespaceRelationCases` / `same` / `different` / `nested`; `PairCases` / `function_overload` / `function_duplicate` / `function_type` / `function_enum` / `type_duplicate` / `type_enum` / `enum_duplicate` / `method_overload` / `method_duplicate` / `method_field` / `method_property` / `field_duplicate` / `field_property` / `property_get_set` / `property_duplicate_get` / `property_duplicate_set`.
- Construction/oracle expressions retained from the card: `VerifyRunResult(..., "int RunCollisionPublication()", 71)`; `GetExpected`; `71`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-DECL-FAILURE-RECOVERY

- Class: `AngelscriptTest::Generate::FDeclFailureRecoveryGenerator`; task: 10.2.
- Cells: **18**; categories: normal=0, reject=18, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildInvalidSource(const FDeclFailureRecoveryParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-DECL-FAILURE-RECOVERY-UNBALANCED_CLASS-ENTRY_BODY-LF`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Declarations/AngelscriptNativeDeclarationFailureRecoveryTests.cpp`.
- Card SHA256: `beca630eb2fe25d4253704db4be498c7da07e5b2bcc23d76ba4ced048c8e1254`; inspected source SHA256: `93680f177aca1725693502124a532ce9ffe35877fc8f331ed66db8d71141cb73`.
- Axis tables and tokens in documented order: `*Cases`; `FormCases` / `unbalanced_class` / `bad_parameter_list` / `unclosed_function_body` / `missing_type_name` / `unexpected_handle` / `unknown_base`; `PlacementCases` / `entry_body` / `after_valid_function` / `inside_namespace`; `LineEndingCases` / `lf`; `LineEndingCases` / `crlf`.
- Construction/oracle expressions retained from the card: `BuildInvalidSource`; `BuildResult < 0`; `int Entry()`; `GetExpected`; `BuildRecoverySource`; `23`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-DECL-FAMILY-SCOPE-ORDER

- Class: `AngelscriptTest::Generate::FDeclFamilyScopeOrderGenerator`; task: 10.3.
- Cells: **300**; categories: normal=300, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildDeclarationSource(const FDeclFamilyScopeOrderParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-DECL-FAMILY-SCOPE-ORDER-FUNCTION-GLOBAL-BEFORE_USE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Declarations/AngelscriptNativeDeclarationPublicationTests.cpp`.
- Card SHA256: `6e6706c26d3114067db4362be2ae095918e9cf239794d79f671c566f04e79e4a`; inspected source SHA256: `39799fb7ef3cb706bb9504ec3fa8ac98c693e68b9762043544f0b93c2c1f8732`.
- Axis tables and tokens in documented order: `*Cases`; `FamilyCases` / `function` / `method` / `class` / `struct` / `field` / `constructor` / `destructor` / `namespace` / `enum` / `typedef`; `FamilyCases` / `funcdef` / `import` / `virtual_property` / `indexed_property` / `mixin_global`; `ScopeCases` / `global` / `namespace` / `nested_namespace` / `member` / `multiple_sections`; `ScopeCases` / `imported_module`; `OrderingCases` / `before_use` / `forward_use` / `same_section` / `later_section` / `reversed_sections` / `rebuild`.
- Construction/oracle expressions retained from the card: `GetFamilyValue`; `GetScopeValue`; `GetOrderingValue`; `FDeclarationPublicationTests`; `Entry`; `FamilyWitness() + ScopeWitness() + OrderingWitness()`; `GetExpected`; `(100 + FamilyIndex) + (200 + ScopeIndex) + (300 + OrderingIndex)`; `FUNCTION-GLOBAL-BEFORE_USE`; `100+200+300`; `600`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
