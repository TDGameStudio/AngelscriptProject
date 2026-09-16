# Inheritance product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/inh. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 5. Declared cells: 598.

## LANG-INH-ACCESS

- Class: `AngelscriptTest::Generate::FInhAccessGenerator`; task: 9.1.
- Cells: **60**; categories: normal=37, reject=23, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildInheritanceAccessSource(const FInhAccessParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-INH-ACCESS-DEFAULT-FIELD-OWNER`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Inheritance/AngelscriptNativeInheritanceAccessTests.cpp`.
- Card SHA256: `81adec680b416caa4bb206f6b16fabf24ffea3c151e2eb4c3d4cfafda5b2868f`; inspected source SHA256: `2b9652b6e945956f16469586a0283f5d8421bd49df8e7077d8b867e58610b744`.
- Axis tables and tokens in documented order: `*Cases`; `AccessCases` / `default` / `protected` / `private`; `MemberCases` / `field` / `method` / `getter_setter_method` / `constructor`; `SiteCases` / `owner` / `direct_derived` / `deep_derived` / `unrelated` / `global`.
- Construction/oracle expressions retained from the card: `ShouldCompile`; `FInheritanceAccessTests`; `Null pointer access`; `GetExpected`; `field`; `41`; `method`; `42`; `getter_setter_method`; `43`; `constructor`; `direct_derived`; `deep_derived`; `48`; `unrelated`; `46`; `47`; `!private`; `default`; `private`; `owner`; `protected`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-INH-CAST

- Class: `AngelscriptTest::Generate::FInhCastGenerator`; task: 9.2.
- Cells: **60**; categories: normal=60, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildInheritanceCastSource(const FInhCastParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-INH-CAST-MUTABLE-EXACT-ASSIGN`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Inheritance/AngelscriptNativeInheritanceCastTests.cpp`.
- Card SHA256: `fe4202d6d646fc3736a9546c57d18a1f4a3c67e5be1dd1bd975956ddf204aed6`; inspected source SHA256: `978a92ebece1c32edceae2f076806cf106ed4c0efb3f6666efad0e3b92e8582e`.
- Axis tables and tokens in documented order: `*Cases`; `ConstnessCases` / `mutable` / `const`; `RelationCases` / `exact` / `upcast` / `downcast_success` / `downcast_failure` / `sibling` / `null`; `UseCases` / `assign` / `argument` / `return` / `identity_compare` / `member_call`.
- Construction/oracle expressions retained from the card: `ExpectedRuntimeValue`; `IsSuccessfulRelation`; `FInheritanceCastTests`; `cast<T>(expr)`; `cast<T>`; `exact`; `upcast`; `downcast_success`; `GetKind()`; `2`; `GetExpected = ExpectedRuntimeValue(Relation, Use)`; `identity_compare`; `null`; `1`; `0`; `-1`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-INH-CLASS-RULE

- Class: `AngelscriptTest::Generate::FInhClassRuleGenerator`; task: 9.3.
- Cells: **64**; categories: normal=24, reject=40, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildInheritanceRuleSource(const FInhClassRuleParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-INH-CLASS-RULE-CONCRETE_INSTANTIATE-RUNTIME`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Inheritance/AngelscriptNativeInheritanceRuleTests.cpp`.
- Card SHA256: `c749e3116f23e97466bba47060b90c592e59ab0ff0471b1252b1c009cf2b88cf`; inspected source SHA256: `9963cc6f8f53b88fc168e0f5ad5dec9f3cdf2ddee99873c242aca1734036d6f6`.
- Axis tables and tokens in documented order: `*Cases`; `ScenarioCases` / `abstract_class_keyword_rejected` / `final_class_keyword_rejected` / `concrete_base_inherit` / `concrete_instantiate` / `final_method_override` / `final_method_inherit` / `invalid_base_name` / `invalid_base_kind` / `duplicate_base` / `inheritance_cycle_direct` / `inheritance_cycle_indirect` / `implicit_override_without_keyword` / `exact_override` / `override_without_base` / `return_type_mismatch` / `deep_override`; `ObservationCases` / `compile` / `diagnostic` / `metadata` / `runtime`.
- Construction/oracle expressions retained from the card: `FScenarioCase.Outcome`; `Append*Value()`; `FInheritanceRuleTests`; `Outcome == CompileAccepted`; `concrete_base_inherit`; `31`; `concrete_instantiate`; `41`; `final_method_inherit`; `61`; `implicit_override_without_keyword`; `122`; `exact_override`; `132`; `deep_override`; `163`; `compile`; `diagnostic`; `metadata`; `runtime`; `GetExpected`; `Object.Value()`; `abstract_class_keyword_rejected`; `final_class_keyword_rejected`; `final_method_override`; `invalid_base_name`; `invalid_base_kind`; `duplicate_base`; `inheritance_cycle_direct`; `inheritance_cycle_indirect`; `override_without_base`; `return_type_mismatch`; `abstract`; `final`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-INH-DISPATCH

- Class: `AngelscriptTest::Generate::FInhDispatchGenerator`; task: 9.4.
- Cells: **360**; categories: normal=360, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildInheritanceDispatchSource(const FInhDispatchParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-INH-DISPATCH-BASE-FIELD-DERIVED_OBJECT-DIRECT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Inheritance/AngelscriptNativeInheritanceDispatchTests.cpp`.
- Card SHA256: `357749226a9bbf188b5fc984643dafadad27b1f9a3b69875ac5cae8a4231ec06`; inspected source SHA256: `d6e842696ed2155f71d477c134a24ba133187a0a0d325eceff98501501071a2e`.
- Axis tables and tokens in documented order: `*Cases`; `DepthCases` / `base` / `two_levels` / `three_levels` / `deep`; `MemberCases` / `field` / `nonvirtual_method` / `virtual_method` / `override` / `getter_method` / `setter_method`; `ViewCases` / `derived_object` / `base_view` / `explicit_base` / `owner` / `derived_impl`; `InvocationCases` / `direct` / `virtual_route` / `explicit_base`.
- Construction/oracle expressions retained from the card: `AppendRootTarget`; `AppendDerivedTarget`; `ProbeExpression`; `FInheritanceDispatchTests`; `Null pointer access`; `Level = BaseEdges`; `setter`; `7`; `UsesExplicitBase`; `explicit_base`; `UsesBaseView`; `base_view`; `virtual_route`; `nonvirtual_method`; `final`; `100`; `701`; `107`; `701 + Level*10`; `100 + Level*100 + 7`; `100 + Level*100`; `BaseView.DispatchField`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-INH-OVERRIDE-SIGNATURE

- Class: `AngelscriptTest::Generate::FInhOverrideSignatureGenerator`; task: 9.5.
- Cells: **54**; categories: normal=36, reject=18, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildOverrideSignatureSource(const FInhOverrideSignatureParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-INH-OVERRIDE-SIGNATURE-PARAMETER_TYPE-EXACT-BASE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Inheritance/AngelscriptNativeOverrideSignatureTests.cpp`.
- Card SHA256: `c9d6ec6051357c77368e10289ad1d9bc63ad64b4c7f3bf1755d380fe9227a0e9`; inspected source SHA256: `5cafc292f396e1d42d176307e4d98c44d6e3cae3cbeac24c3c2747404d6ca99a`.
- Axis tables and tokens in documented order: `*Cases`; `DimensionCases` / `parameter_type` / `parameter_count` / `return_type` / `constness` / `visibility` / `name_hiding`; `VariantCases` / `exact` / `compatible_overload` / `incompatible`; `ViewCases` / `base` / `derived` / `explicit_base`.
- Construction/oracle expressions retained from the card: `MakeSignatureShape`; `bBuildAccepted`; `Probe*`; `FOverrideSignatureTests`; `101 + Value`; `202 + int(Value)`; `202.0f + float(Value)`; `202 + Left + Right`; `exact`; `compatible_overload`; `explicit_base`; `FSignatureBase::Resolve(BaseArg)`; `101 + BaseArg`; `102`; `base`; `203`; `derived`; `parameter_count`; `205`; `202+1+2`; `name_hiding`; `204`; `202+int(2.5f)`; `incompatible`; `bBuildAccepted=false`; `Execute(Entry<PascalCaseId>)`; `GetExpected(CaseId)`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
