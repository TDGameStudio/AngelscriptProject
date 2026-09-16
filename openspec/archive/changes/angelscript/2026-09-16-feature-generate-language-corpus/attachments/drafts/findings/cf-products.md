# ControlFlow product contracts

English scoped extraction from the accepted product cards; the full-scope clarification applies to every row. Original source identity: angelscript/test-code-language-corpus, generators/classes/cf. Source hashes preserve provenance, not evidence of successful execution. Read the Change design for common source, failure and verification contracts. Code identifiers and expressions below retain original spelling. The cited repository Legacy C++ is dormant implementation evidence and is available without any ignored draft dependency.

Declared products: 11. Declared cells: 2483.

## LANG-CF-FOR-CLAUSES

- Class: `AngelscriptTest::Generate::FForLoopGenerator`; task: 1.1.
- Cells: **24**; categories: normal=24, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildForSource(const FForLoopParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-FOR-CLAUSES-PRESENT-OMITTED-PRESENT-ONE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeForClauseTests.cpp`.
- Card SHA256: `2130cf52e0ca981dbfdcbd796dd292ae01c087925e291dd01c1b76894b6fa3c0`; inspected source SHA256: `d5eb550c6b531e0970a2a7eda51c7b52237e0211ebfd77f8a4b1afc82cd92292`.
- Axis tables and tokens in documented order: `*Cases`; `PresenceCases` / `present` / `omitted`; `PresenceCases` / `present` / `omitted`; `PresenceCases` / `present` / `omitted`; `CountCases` / `zero` / `one` / `many`.
- Construction/oracle expressions retained from the card: `GetExpected`; `Init*1000 + Body*100 + Cond*10 + Inc`; `if (Index >= Limit - 1) break`; `++Index`; `PRESENT-OMITTED-PRESENT-ONE`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CF-BRANCH-CONDITION-DEPTH

- Class: `AngelscriptTest::Generate::FBranchConditionGenerator`; task: 1.2.
- Cells: **45**; categories: normal=45, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildBranchSource(const FBranchConditionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-BRANCH-CONDITION-DEPTH-IF-VARIABLE-FIRST-LF`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeBranchConditionDepthTests.cpp`.
- Card SHA256: `4ee997a5aa71dc93b3d691f7f606ebf76dba34491199dbcd66ac29f9709f6f7c`; inspected source SHA256: `25c23ea256d0cecd81aedfbcb27dd4f87438a7995e517b8839d152debad91fee`.
- Axis tables and tokens in documented order: `*Cases`; `BranchCases` / `if` / `if_else` / `else_if_chain`; `ConditionCases` / `variable` / `comparison` / `logical` / `negated` / `side_effect`; `SelectionCases` / `first` / `second` / `none`; `LineEndingCases` / `lf` / `crlf`.
- Construction/oracle expressions retained from the card: `GetExpectedMarker`; `GetExpectedCalls`; `crlf`; `lf`; `side_effect`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CF-CONDITION

- Class: `AngelscriptTest::Generate::FConditionGenerator`; task: 1.3.
- Cells: **56**; categories: normal=48, reject=8, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildConditionSource(const FConditionParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-CONDITION-IF-BOOL_LITERAL`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeConditionTests.cpp`.
- Card SHA256: `a11f9c20346626b44aa9423c7d7bbbad08056890e0098b33f578d22f1744e0d1`; inspected source SHA256: `ce87b3a9b39e9ab5e321ffeb9eebfa3003799f9cf362a55258a417d454962f08`.
- Axis tables and tokens in documented order: `*Cases`; `StatementCases` / `if` / `while` / `do_while` / `for`; `ConditionCases` / `bool_literal` / `variable` / `comparison` / `logical` / `side_effect_call` / `overloaded_conversion` / `invalid_type`.
- Construction/oracle expressions retained from the card: `ExpectedResult`; `Trace*10 + EvaluationCount`; `do_while`; `side_effect_call`; `invalid_type`; `overloaded_conversion`; `opImplConv`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CF-LIVE-LOCAL-CLEANUP

- Class: `AngelscriptTest::Generate::FLiveLocalCleanupGenerator`; task: 1.4.
- Cells: **120**; categories: normal=96, reject=0, divide_by_zero=24, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildLiveLocalSource(const FLiveLocalCleanupParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-LIVE-LOCAL-CLEANUP-LOOP-NORMAL-ONE-ONE-LF`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeControlFlowLifetimeDepthTests.cpp`.
- Card SHA256: `1289b9a9f39bea30f78aec89017015c53ff0ccec08d5e7b859c5f8a26d8c1898`; inspected source SHA256: `8c01419ac980eb78db756dfad6afcfe0adcccea0be01fe9d65d8ed8df6f1dd28`.
- Axis tables and tokens in documented order: `*Cases`; `ScopeCases` / `loop` / `branch_loop` / `nested_loop` / `switch_loop`; `ExitCases` / `normal` / `break` / `continue` / `return` / `exception`; `DepthCases` / `one` / `two` / `three`; `LocalCountCases` / `one` / `two`; `LineEndingCases` / `lf` / `crlf`.
- Construction/oracle expressions retained from the card: `GetExpected`; `Trace`; `crlf`; `exception`; `Divide by zero`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CF-LOOP-COND-TRANSFER-DEPTH

- Class: `AngelscriptTest::Generate::FLoopCondTransferGenerator`; task: 1.5.
- Cells: **180**; categories: normal=180, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildLoopCondSource(const FLoopCondTransferParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-LOOP-COND-TRANSFER-DEPTH-WHILE-VARIABLE-ZERO-NONE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeLoopConditionTransferDepthTests.cpp`.
- Card SHA256: `6c090999feaf403b7b9f07477170e2580d654944c214c8d20a36e9cbb320413d`; inspected source SHA256: `948aecad504c551852cd71980b83cf4defa8570bd2b393084304911d9f1463fe`.
- Axis tables and tokens in documented order: `*Cases`; `LoopCases` / `while` / `do_while` / `for`; `ConditionCases` / `variable` / `comparison` / `logical` / `negated` / `side_effect`; `CountCases` / `zero` / `one` / `two`; `TransferCases` / `none` / `break` / `continue` / `return`.
- Construction/oracle expressions retained from the card: `GetExpectedResult`; `BodyCalls*100 + ConditionCalls`; `return`; `1000`; `ConditionCalls`; `side_effect`; `GetConditionCalls`; `CheckCondition`; `Entry_*`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CF-LOOP-DEPTH

- Class: `AngelscriptTest::Generate::FLoopDepthGenerator`; task: 1.6.
- Cells: **48**; categories: normal=48, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildLoopSource(const FLoopDepthParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-LOOP-DEPTH-WHILE-ZERO-NONE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeLoopDepthTests.cpp`.
- Card SHA256: `ee4a2c78928a0e3d7754af1a4008cbf8c24c388a8b5fc094f2be6795dbb7cb94`; inspected source SHA256: `e9c07a4b8a2e22cbccccd22ae4c3a46bdc88ef088a7e46d08dd0953919f1c616`.
- Axis tables and tokens in documented order: `*Cases`; `LoopCases` / `while` / `do_while` / `for`; `CountCases` / `zero` / `one` / `two` / `many`; `TransferCases` / `none` / `break` / `continue` / `return`.
- Construction/oracle expressions retained from the card: `GetExpected`; `Body*100 + Cond*10 + Inc`; `zero`; `one`; `two`; `many`; `for`; `break`; `CountCondition`; `CountIncrement`; `InitializeIndex`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CF-NESTED-TARGETS

- Class: `AngelscriptTest::Generate::FNestedTargetGenerator`; task: 1.7.
- Cells: **18**; categories: normal=18, reject=0, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildNestedSource(const FNestedTargetParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-NESTED-TARGETS-NESTED_LOOP-BREAK-INNER`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeNestedTargetTests.cpp`.
- Card SHA256: `aaf962593c0fc3d1c2e66aefdc45e331009cf4df8825fda9dd2fa4587a344cf4`; inspected source SHA256: `af691567a95ccc838a1356794e9a19ae74087fcb3435bab3107fcdf0b542fd4a`.
- Axis tables and tokens in documented order: `*Cases`; `NestingCases` / `nested_loop` / `branch_loop` / `three_level`; `TransferCases` / `break` / `continue` / `return`; `TargetCases` / `inner` / `outer`.
- Construction/oracle expressions retained from the card: `SimulateExpectedTrace`; `Trace`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CF-STATEMENT-COUNT-TRANSFER

- Class: `AngelscriptTest::Generate::FStatementTransferGenerator`; task: 1.8.
- Cells: **1536**; categories: normal=1344, reject=0, divide_by_zero=192, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildStatementTransferSource(const FStatementTransferParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-STATEMENT-COUNT-TRANSFER-IF-ZERO-NONE-NONE`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeStatementTransferTests.cpp`.
- Card SHA256: `6d31878a63b96eb0f8e6b6f36d0422588aa308a2bcf1b139eaf492eb4e04dbf0`; inspected source SHA256: `969113f74923a9118a98b7458d171aaf57296dfaf243b36f768eb1302f76fe0d`.
- Axis tables and tokens in documented order: `*Cases`; `StatementCases` / `if` / `if_else` / `else_if` / `while` / `do_while` / `for` / `switch` / `nested_block`; `CountCases` / `zero` / `one` / `two` / `many`; `TransferCases` / `none` / `break_loop` / `break_switch` / `continue` / `early_return` / `nested_return` / `fallthrough` / `exception`; `NestingCases` / `none` / `same_kind` / `mixed_loop` / `loop_switch` / `branch_loop` / `three_level`.
- Construction/oracle expressions retained from the card: `ExpectedResult`; `Trace`; `exception`; `Divide by zero`; `throw`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CF-SWITCH

- Class: `AngelscriptTest::Generate::FSwitchGenerator`; task: 1.9.
- Cells: **432**; categories: normal=209, reject=146, divide_by_zero=77, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildSwitchSource(const FSwitchParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-SWITCH-INT8-FIRST-BREAK`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeSwitchTests.cpp`.
- Card SHA256: `909b35fdc7130cb03605f8b43d0508a7f769e4262564efafa5e5c495fe82dee7`; inspected source SHA256: `d0e2d2cc0e0e4b2ed133c98c1e3f4509c491d1d8eff2ca547e0199fb7921e54a`.
- Axis tables and tokens in documented order: `*Cases`; `SelectorCases` / `int8` / `int16` / `int` / `int64` / `uint8` / `uint16` / `uint` / `uint64` / `enum` / `typedef` / `boundary` / `unsupported`; `CaseCases` / `first` / `middle` / `last` / `default` / `no_match` / `fallthrough` / `grouped` / `duplicate` / `non_constant`; `ExitCases` / `break` / `fallthrough` / `return` / `exception`.
- Construction/oracle expressions retained from the card: `unsupported`; `duplicate`; `non_constant`; `default`; `no_match`; `fallthrough`; `exception`; `Divide by zero`; `ExpectedResult`; `typedef SelectorAlias`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CF-SWITCH-PLACEMENT

- Class: `AngelscriptTest::Generate::FSwitchPlacementGenerator`; task: 1.10.
- Cells: **16**; categories: normal=0, reject=16, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildSwitchPlacementSource(const FSwitchPlacementParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-SWITCH-PLACEMENT`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeSwitchPlacementTests.cpp`.
- Card SHA256: `8b2d8b20dc79db5b1d6896f6e0eafaaaf655f8d8e0717f88a04029e44c8ef7c7`; inspected source SHA256: `71a0258688c5790f1d771955ec27c894900e42a5749b107ef142b426126dc926`.
- Axis tables and tokens in documented order: .
- Construction/oracle expressions retained from the card: `case_outside`; `default_outside`; `duplicate_default`; `case_after_default`; `BuildAllSource`; `OutCaseCount`; `BuildRejectSource`; `ListRejectCaseIds`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.

## LANG-CF-TRANSFER-VALIDITY

- Class: `AngelscriptTest::Generate::FTransferValidityGenerator`; task: 1.11.
- Cells: **8**; categories: normal=3, reject=5, divide_by_zero=0, integer_overflow=0, power_overflow=0, null_pointer=0, stack_overflow=0, host_fault=0.
- Consumer APIs: `TArray<FGeneratedCaseInfo> ListCases() const` and `FString BuildCaseSource(FStringView CaseId) const`; readable full-product dump: `FString BuildDumpSource() const`; metadata and replay follow the current Change design.
- Typed single-case API: `FString BuildValiditySource(const FTransferValidityParams& Params) const`.
- Example ID (membership only, not necessarily a normal return): `LANG-CF-TRANSFER-VALIDITY-FUNCTION-BREAK`.
- Legacy source: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeTransferValidityTests.cpp`.
- Card SHA256: `3dc6a0326d2db9cd2ced4d9504ce274df4ef34ba42a4ae77220534378d4f653c`; inspected source SHA256: `cddf5c22b192aff1f84dba717f37ee8f24b83a0a4b223137156a01ad8c71bed2`.
- Axis tables and tokens in documented order: `*Cases`; `PlacementCases` / `function` / `branch` / `switch` / `loop`; `TransferCases` / `break` / `continue`.
- Construction/oracle expressions retained from the card: `BuildAllSource`; `SWITCH-BREAK`; `LOOP-BREAK`; `LOOP-CONTINUE`; `FUNCTION-*`; `BRANCH-*`; `SWITCH-CONTINUE`; `BuildRejectSource`; `ListRejectCaseIds`.
- Observation: use the product-specific normal-return oracle; reject and runtime-fault cells have no normal-return comparison.
- Runtime export: one GeneratesAndExportsAllCases test writes BuildDumpSource() as GeneratedCases/<ClassWithoutF>.as beside the actual log; all product cases appear in one formatted inspection file. Implementation remains Framework/Generate; tests remain FrameworkTests/Generate.
- Acceptance: enumerate the complete declared category partition; independent expected IDs and observations; deterministic aggregate order; typed single-case source; representative reviewed gold; invalid-input behavior. Apply all common design invariants.
