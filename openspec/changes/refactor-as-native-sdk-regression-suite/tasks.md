## 1. OpenSpec record and pre-implementation gate

- [x] 1.1 <!-- Non-TDD --> Create `refactor-as-native-sdk-regression-suite` with the OpenSpec CLI in the current checkout and record the parent/submodule dirty-state constraints.
- [x] 1.2 <!-- Non-TDD --> Write `proposal.md`, including current-fork semantics, compiled-disabled 2.38 targets, direct exports, full ID replacement, add-on exclusion, and all-code-before-build ordering.
- [x] 1.3 <!-- Non-TDD --> Write `design.md`, including the nine-domain architecture inside the existing UE module, helper ownership, lifecycle, exact lookup, export surface, moves, audit evidence, risks, rollback, and verification sequence.
- [x] 1.4 <!-- Non-TDD --> Write delta specifications for `as-native-sdk-test-coverage` and `angelscript-test-helper-api`, plus the new `as-native-sdk-regression-architecture` specification.
- [x] 1.5 <!-- Non-TDD --> Record `background.md`, `current-state.md`, `impact-map.md`, the full current-file migration map, automation-ID migration, 41 implementation units, 36 internal classes, 12 interfaces, core public API families, nine-domain test depth, and core language semantics/add-on boundary.
- [x] 1.6 <!-- Non-TDD --> Run `openspec validate refactor-as-native-sdk-regression-suite --strict --json` and correct every artifact/schema error before editing plugin source.
- [x] 1.7 <!-- Non-TDD --> Record the reviewed parent/submodule baseline, committed `b903571` builder ownership, overlap policy, final planning findings, and fresh-baseline gate in `audits/workspace-baseline.md` and `review.md`.
- [x] 1.8 <!-- Non-TDD --> Generate `audits/test-methods.csv` from the current source and prove it contains exactly 433 unique current method keys, 12 explicit replacements from the three constant-false files, and no unresolved final owner.
- [x] 1.9 <!-- Non-TDD --> Freeze all 82 current-file destinations and every planned final source path; remove adjustable, approximate, quota-driven, or phrase-only destinations from `audits/file-map.md`.
- [x] 1.10 <!-- Non-TDD --> Record exact minimum behavior scenarios for all nine domains, fourteen language themes, cross-theme interactions, and relevant 2.33–2.38 compatibility classifications in `audits/test-scenarios.md` and `audits/upstream-compatibility.md`.
- [x] 1.11 <!-- Non-TDD --> Mark every task TDD/Non-TDD, synchronize proposal/design/specs/impact/verification with the final records, run consistency checks plus strict OpenSpec validation, and keep source implementation/build/test tasks unchecked.

## 2. ThirdParty visibility and support infrastructure

- [x] 2.1 <!-- Non-TDD --> Add `[UE++]`-documented `ANGELSCRIPTRUNTIME_API` visibility to `asCAtomic` and the approved threading/weak-bool classes in `as_atomic.h`, `as_thread.h`, and `as_scriptobject.h` without changing layout.
- [x] 2.2 <!-- Non-TDD --> Add the approved export visibility to `asCByteInstruction`, `asCConfigGroup`, `asCExprValue`, `asCExprContext`, `asCOutputBuffer`, and `asCVariableScope` in their owning headers.
- [x] 2.3 <!-- Non-TDD --> Add the approved export visibility to `asCStringPointer`, `asCEnumType`, `asCTypedefType`, and `asCFuncdefType` without changing inheritance or layout.
- [x] 2.4 <!-- Non-TDD --> Export the seven real functions in `as_string_util.h` and keep signatures/implementations unchanged.
- [x] 2.5 <!-- TDD --> Provide case-owned `FNativeTestEngine`, message capture, deterministic properties, and shutdown/reset behavior in consolidated core support; no default global collector remains.
- [x] 2.6 <!-- TDD --> Provide `FScopedNativeModule`, exact declaration lookup, explicit name lookup, source-section build, and the single `FMemoryBinaryStream` in consolidated core support.
- [x] 2.7 <!-- TDD --> Provide execution support with `FScopedNativeContext`, `FSdkFunctionInvoker`, type-correct arguments/returns, and explicit execution results.
- [x] 2.8 <!-- TDD --> Provide tokenizer/parser/script-node/bytecode access and diagnostic helpers through consolidated core support and compiler-owned tests.
- [x] 2.9 <!-- TDD --> Create `Support/AngelscriptNativeBuilderTestSupport.h` by extracting valid builder helpers and removing module/execution duplication.
- [x] 2.10 <!-- TDD --> Remove root `AngelscriptNativeTestSupport.h`; migrate its implementation to `Support/AngelscriptNativeCoreTestSupport.h` and keep `AngelscriptTestAdapter.h` as the stable CQTest adapter until its final consumers migrate.
- [x] 2.11 <!-- TDD --> Migrate every SDK include/call site from `AngelscriptSDKTestUtilities.h`, `AngelscriptSDKTestExecutionHelpers.h`, and root `AngelscriptBuilderTestSupport.h`; delete those three files only after zero references remain.
- [x] 2.12 <!-- TDD --> Remove duplicate byte-stream/context-invocation implementations and make compatibility aliases exact, thin, and non-owning.
- [x] 2.13 <!-- TDD --> Add `scripts/AuditNativeSdkTests.ps1` with `-Phase Structure` and `-Phase Complete` modes so phase builds use static gates without requiring unfinished later coverage.

## 3. Move tests that do not belong to the raw SDK layer

- [x] 3.1 <!-- Non-TDD --> Move `AngelscriptCompilerTests.cpp` to the plugin Compiler test layer and register its seven wrapper/trace cases under `Angelscript.TestModule.Compiler.ModulePipeline`.
- [x] 3.2 <!-- Non-TDD --> Move `AngelscriptContextPoolTests.cpp` to Core/Engine ownership and register it under `Angelscript.TestModule.Engine.ContextPool`.
- [x] 3.3 <!-- Non-TDD --> Move `AngelscriptFunctionCallerErasureTests.cpp` into the existing Core function-caller coverage and register it under `Angelscript.TestModule.Engine.FunctionCallers`.
- [x] 3.4 <!-- Non-TDD --> Move `AngelscriptTypeRegistryTests.cpp` and the plugin-dependent portions of `AngelscriptTypeUsageTests.cpp` to Core with `Engine.TypeRegistry` and `Engine.TypeUsage` IDs.
- [x] 3.5 <!-- Non-TDD --> Move `AngelscriptDebuggerValueTests.cpp` and `AngelscriptDebugReificationTests.cpp` to Debugger with `Debugger.Value` and `Debugger.Reification` IDs.
- [x] 3.6 <!-- Non-TDD --> Move `AngelscriptStructCppOpsTests.cpp`, `.h`, and fixture `.cpp` to `Generator/ASStruct` with `Generator.ASStruct.CppOps` registration and non-registering fixture support.
- [x] 3.7 <!-- TDD --> Rewrite `AngelscriptDataTypeTests.cpp`, `AngelscriptGCInternalTests.cpp`, and `AngelscriptRestoreTests.cpp` to remove `FAngelscriptEngine`/full-wrapper dependencies so they remain valid raw SDK tests.
- [x] 3.8 <!-- Non-TDD --> Update moved files to `WITH_ANGELSCRIPT_UNITTESTS` body gates, current matcher/fixture rules, and explicit cleanup without reducing assertions.

## 4. Reorganize files and automation identities

- [x] 4.1 <!-- Non-TDD --> Create all nine domain directories; only support/non-registering headers remain at the SDK root.
- [x] 4.2 <!-- Non-TDD --> Move/rename Engine and Frontend sources according to `audits/file-map.md` and consolidate smoke ownership under Engine.
- [x] 4.3 <!-- Non-TDD --> Move/rename builder and bytecode sources into Compiler, splitting prior monoliths by subject ownership.
- [x] 4.4 <!-- Non-TDD --> Move execution/context/GC sources into Runtime and assert the current fork's `Suspend()` rejection rather than a false successful-suspend claim.
- [x] 4.5 <!-- Non-TDD --> Split and move ScriptModule/Restore/SaveLoad sources into Module and remove superseded source owners after ledger mapping.
- [x] 4.6 <!-- Non-TDD --> Split and move ConfigGroup/DataType/traits/global-property/type/scope sources into TypeSystem with direct concrete-class coverage.
- [x] 4.7 <!-- Non-TDD --> Split and move function/operator/conversion/object/OOP/global/reference-script-class scenarios into Language and Conformance by actual behavior.
- [x] 4.8 <!-- Non-TDD --> Move registration/callfunc/calling-convention scenarios into Embedding and execute active ABI paths; explicitly assert known double-backed call limitations.
- [x] 4.9 <!-- Non-TDD --> Replace SDK class/file/automation names with domain-scoped identities from `test-methods.csv`; remove retired flat/reference naming.
- [x] 4.10 <!-- Non-TDD --> Apply `WITH_ANGELSCRIPT_UNITTESTS` registration gates to every registering `.cpp`, preserve helper compilation, and remove every constant-false registration condition.
- [x] 4.11 <!-- Non-TDD --> Update every modified raw SDK script fixture to `ASTEST_AS_ANSI(R"AS(...)AS")`, visual indentation/dedent, Allman braces, scenario names, and no `"\\n"` concatenation except explicitly preserved line-sensitive source.
- [x] 4.12 <!-- Non-TDD --> Split sources at subject-ownership boundaries and record cohesive-size exceptions rather than using a size quota.
- [x] 4.13 <!-- Non-TDD --> Run structure/complete audit, strict OpenSpec validation, and scoped diff checks after the full structure phase.
- [x] 4.14 <!-- Non-TDD --> Follow the requested all-code-first workflow: do not spend a separate structure build; run the final integration build through `Tools\RunBuild.ps1` after the implementation batch and static structure audit are complete.
- [x] 4.15 <!-- Non-TDD --> Use systematic debugging for encountered build failures, batch root-cause fixes, then repeat applicable build and static validation.

## 5. Close Engine, Frontend, Compiler, Runtime, and Module coverage

- [x] 5.1 <!-- TDD --> Enable and expand direct atomic/thread/engine lifecycle/profile and allocator/memory-manager coverage.
- [x] 5.2 <!-- TDD --> Apply global-state containment: pair resources, leave non-restorable process hooks untouched, classify unavailable header-only callbacks as Fork N/A, and remove the default global message collector path.
- [x] 5.3 <!-- TDD --> Add direct script-code/string/string-pointer and exported string scan/compare/UTF coverage; delete lambda-only StringUtil coverage.
- [x] 5.4 <!-- TDD --> Preserve complete tokenizer/parser/script-node themes and cover required source/string/error cases.
- [x] 5.5 <!-- TDD --> Complete direct bytecode/output/expr/compiler and builder phase coverage.
- [x] 5.6 <!-- TDD --> Retain the builder enum-description post-build regression against committed plugin baseline `b903571` without taking ownership of the production fix.
- [x] 5.7 <!-- TDD --> Complete context prepare/argument/return/exception/callstack/suspend/abort coverage using one invoker and assert float versus double ABI accessors.
- [x] 5.8 <!-- TDD --> Add generic-call and script-object construction/property/copy/refcount/weak-reference coverage; where isolated execution reaches the UE allocator assertion, lock the compile/metadata boundary explicitly.
- [x] 5.9 <!-- TDD --> Complete raw garbage collector detection/enumeration/release/statistics behavior with case-isolated registrations.
- [x] 5.10 <!-- TDD --> Complete module lifecycle/sections/lookups/globals/types/import bind-unbind/namespaces/discard behavior.
- [x] 5.11 <!-- TDD --> Complete one-stream writer/reader/module save-load round trip plus truncated/corrupt stream failures and post-load execution.

## 6. Close TypeSystem, Language, Embedding, and Conformance coverage

- [x] 6.1 <!-- TDD --> Add direct ConfigGroup/DataType/GlobalProperty/VariableScope lifecycle, access and lookup coverage.
- [x] 6.2 <!-- TDD --> Add direct TypeInfo/ObjectType/EnumType/TypedefType/FuncdefType/ScriptFunction identity, metadata, relationship and trait coverage.
- [x] 6.3 <!-- TDD --> Complete Declarations, Functions and Variables with executing core behavior and precise negative diagnostics, without add-on libraries.
- [x] 6.4 <!-- TDD --> Complete Properties with class initialization/access/inheritance and virtual-property behavior plus invalid-accessor diagnostics.
- [x] 6.5 <!-- TDD --> Add default, parameterized and copy constructor/assignment tests plus construction-failure diagnostics.
- [x] 6.6 <!-- TDD --> Add destructor cleanup/order tests across block exit, return and exception paths.
- [x] 6.7 <!-- TDD --> Add inheritance/base-construction/override/virtual-dispatch/base-call/abstract-final restriction tests.
- [x] 6.8 <!-- TDD --> Complete Expressions, Operators and Conversions with executing core behavior and precise invalid/ambiguous diagnostics.
- [x] 6.9 <!-- TDD --> Complete ControlFlow, Foreach and Exceptions with executing branch/loop/switch/return/exception/abort behavior; current `Suspend()` rejection is asserted explicitly.
- [x] 6.10 <!-- TDD --> Complete References and Module/TypeSystem owners for namespaces/imports/enums/typedefs/funcdefs/mixin-global-functions and reference/null/identity behavior.
- [x] 6.11 <!-- TDD --> Add supported embedding contracts for registration, native interfaces, string factory, thread manager, generic calls and active Win64 calling conventions; unavailable JIT V2 symbols remain API-deferred.
- [x] 6.12 <!-- TDD --> Assert current fork rejection semantics exactly for mutable globals, explicit `@` handles, script interfaces and `mixin class`.
- [x] 6.13 <!-- TDD --> Add the seven script-semantic Future238 owners—UsingNamespace238, MemberInitialization238, DefaultSpecialMembers238, BoolContext238, Lambda238, VariadicFunction238, and TemplateFunction238—using `TEST_CLASS_WITH_FLAGS_AND_TAGS`, `EAutomationTestFlags::Disabled`, and `TEXT("#as-v238-backport")`; keep context serialization and JIT V2 API-deferred until their absent C++ symbols are backported.
- [x] 6.14 <!-- TDD --> Audit includes and registrations to prove there is no `sdk/add_on` dependency; keep only minimal local host fixtures for core interface contracts.
- [x] 6.15 <!-- TDD --> Implement every exact language method in `audits/test-scenarios.md`; close applicable dimensions or record a specific current-fork non-applicability rationale.
- [x] 6.16 <!-- TDD --> Implement each exact non-language domain scenario in `audits/test-scenarios.md` and apply the documented public/internal/input/error/lifecycle/interaction/isolation/classification gate.
- [x] 6.17 <!-- TDD --> Reconcile final sources with all 433 ledger rows and planned scenarios; final files/methods have no placeholder or unowned active item.

## 7. Static audit and repository integration files

- [x] 7.1 <!-- TDD --> Complete the `-Phase Complete` audit against the final ledger, domain, language, public API and test inventories.
- [x] 7.2 <!-- TDD --> Make the audit reject root registrations, old helpers, duplicate streams/invokers, retired names, ambiguous lookup, constant-false gates, missing body gates and unresolved ledger entries.
- [x] 7.3 <!-- TDD --> Make the audit reject add-on dependencies and malformed enabled/untagged future-2.38 tests.
- [x] 7.4 <!-- TDD --> Make the audit reject generic final names and unowned domain/language depth requirements.
- [x] 7.5 <!-- TDD --> Make the audit reject prohibited global hooks and default global message-collector paths.
- [x] 7.6 <!-- Non-TDD --> Update `Config/DefaultEngine.ini` narrowly: retain the stable SDK root group and remove stale `.Smoke`/`.ASSDK.Smoke` filters without disturbing unrelated user changes.
- [x] 7.7 <!-- Non-TDD --> Verify `Tools/Shared/TestSuiteDefinitions.ps1` keeps `NativeCore` on the SDK root; change it only if the current dirty content is actually stale.
- [x] 7.8 <!-- Non-TDD --> Generate final source/test/domain/active/disabled counts into an OpenSpec audit result file for documentation use.

## 8. Documentation and final integration gate

- [x] 8.1 <!-- Non-TDD --> Update `Documents/UnitTest/UnitTest.md` first with the raw-SDK per-method engine exception, profiles, exact lookup, domain IDs, add-on exclusion, compiled-disabled script semantics, and API-deferred policy while preserving pre-existing edits.
- [x] 8.2 <!-- Non-TDD --> Update Chinese fork guidance in `ASSDK_Fork_Differences.md` and `AngelscriptForkStrategy.md` with strict current behavior, language/core scope, and future-2.38 test workflow.
- [x] 8.3 <!-- Non-TDD --> Update `Documents/Guides/TestConventions.md` to remove historical ASSDK/column-0/flat-Smoke guidance and point to current inline rules and domain IDs.
- [x] 8.4 <!-- Non-TDD --> Update `Documents/Guides/Test.md` with the nine domain commands, eight moved prefixes, build-after-write gate, full SDK, NativeCore, and All sequence including explicit timeouts.
- [x] 8.5 <!-- Non-TDD --> Update `TestCatalog.md` and `TechnicalDebtInventory.md` from generated counts/results; do not present `301/301` as the post-refactor current result.
- [x] 8.6 <!-- Non-TDD --> Update root `AGENTS_ZH.md` first and then `AGENTS.md`, plus `AngelscriptTest/TESTING_GUIDE.md`; `Tools/Shared/README.md` does not exist, so its absence is recorded in verification rather than creating an unrelated file.
- [x] 8.7 <!-- Non-TDD --> Review parent and submodule diffs against the original dirty-state inventory; confirm no unrelated file/hunk was reset, overwritten, or staged.
- [x] 8.8 <!-- Non-TDD --> Run `AuditNativeSdkTests.ps1 -Phase Complete` and `openspec validate refactor-as-native-sdk-regression-suite --strict --json`; mark the complete coverage/integration phase ready before the final build.

## 9. Final integration build and focused verification

- [x] 9.1 <!-- Non-TDD --> Run the final integration build with `Tools\RunBuild.ps1 -Label as-native-sdk-regression-build -TimeoutMs 1800000 -NoXGE`; record exit code and log in `verification.md`.
- [x] 9.2 <!-- Non-TDD --> Apply systematic debugging to the encountered focused build/test failures, batch same-class causal fixes, and repeat the applicable build/static validation; the final integration build passed.
- [x] 9.3 <!-- Non-TDD --> Run `Engine`, `Frontend`, and `Compiler` SDK prefixes separately with `-TimeoutMs 600000`; record discovered/pass/fail/disabled counts.
- [x] 9.4 <!-- Non-TDD --> Run `Runtime`, `Module`, and `TypeSystem` SDK prefixes separately with `-TimeoutMs 600000`; record counts.
- [x] 9.5 <!-- Non-TDD --> Run `Language`, `Embedding`, and `Conformance` SDK prefixes separately with `-TimeoutMs 600000`; record counts including Disabled future-2.38 cases.
- [x] 9.6 <!-- Non-TDD --> Run exact moved prefixes `Compiler.ModulePipeline`, `Engine.ContextPool`, `Engine.FunctionCallers`, `Engine.TypeRegistry`, and `Engine.TypeUsage`; record counts.
- [x] 9.7 <!-- Non-TDD --> Run exact moved prefixes `Debugger.Value`, `Debugger.Reification`, and `Generator.ASStruct.CppOps`; record counts.
- [x] 9.8 <!-- Non-TDD --> Diagnose/fix each focused failure with the narrowest prefix and rerun the affected domain/move group before broad verification.

## 10. Broad verification and handoff

- [x] 10.1 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label as-native-sdk-regression-full -TimeoutMs 900000` and record all outcomes.
- [x] 10.2 <!-- Non-TDD --> Run `Tools\RunTestSuite.ps1 -Suite NativeCore -LabelPrefix as-native-sdk-regression -TimeoutMs 900000 -ContinueOnFail` and record every group outcome.
- [x] 10.3 <!-- Non-TDD --> Run `Tools\RunTestSuite.ps1 -Suite All -LabelPrefix as-native-sdk-regression -TimeoutMs 900000 -ContinueOnFail` and separate causal failures from unrelated pre-existing failures with evidence.
- [x] 10.4 <!-- Non-TDD --> Rerun static audit, strict OpenSpec validation, scoped git status/diff checks, and update audit records/catalog/verification with final evidence.
- [x] 10.5 <!-- Non-TDD --> Perform a final scoped parent/submodule self-review, address verified findings, and rerun affected validation; no external review request or source-control action is authorized in this workspace.
- [x] 10.6 <!-- Non-TDD --> Leave the OpenSpec active and unarchived; do not commit, stage, update the parent gitlink, or publish unless the user explicitly requests it.
