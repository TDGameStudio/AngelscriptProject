# Background and Planning Record

This file preserves the reasoning and source evidence gathered before implementation. It is intentionally more detailed than `proposal.md`: the proposal states the change at decision level, while this record explains how the scope was derived and which assumptions must remain visible during application.

## User intent and approved decisions

The requested outcome is a regression suite for the native functionality of the AngelScript third-party library embedded in the Unreal Engine plugin. Its purpose is to protect later fork edits and selective feature upgrades, not to test gameplay bindings or unrelated UE integrations.

The following decisions were explicitly established before implementation:

1. Current fork semantics are the active source of truth.
2. Useful AngelScript 2.38 expectations may be implemented now, but must stay compiled and registered as Disabled until the fork is adapted.
3. An OpenSpec must be created first and must plan the complete change and impact surface before source implementation begins.
4. Files may be added and deleted.
5. Build frequency must stay low. Implementation is batched into large, coherent phases; a phase is completed before its build, and fixes are batched by failure class before rebuilding. Automation tests wait until the final integration build passes.
6. `Documents/UnitTest/UnitTest.md` is the authoritative test rule set.
7. The suite must cover core AngelScript syntax and behavior—including properties and constructors—not merely internal C++ classes.
8. External AngelScript `sdk/add_on` libraries are outside scope; only the core library and host interface contracts are tested.
9. Direct DLL export annotations are the approved way to make the selected internal concrete implementations testable from the separate `AngelscriptTest` DLL.
10. Native test IDs may be fully reorganized; no legacy alias registrations are required.
11. The current checkout is used. Repository guidance forbids creating/using a worktree unless the user explicitly asks for one.
12. This review pass happens before source implementation. At the time of this record, this change has edited only OpenSpec files.
13. The enum-description lifetime fix in `as_builder.cpp` is committed baseline behavior at plugin commit `b903571`; this change owns only its regression coverage unless a separate causal defect is proven.
14. Coverage depth is judged by named behavioral dimensions and scenarios, using the existing deep `Coverage/` suite as a rigor benchmark rather than imposing file, line, or method-count quotas.

## Repository and module context

The real deliverable is `Plugins/Angelscript`, a git submodule of the parent `AngelscriptProject` repository. The native SDK tests live in the `AngelscriptTest` UE module, while the vendored AngelScript implementation lives in `AngelscriptRuntime`. The separate UE module/DLL boundary is why non-inline internal implementations need export visibility for direct tests.

This is a dual-repository implementation:

- Parent repository: OpenSpec, `Config/DefaultEngine.ini`, `Tools/Shared/TestSuiteDefinitions.ps1` if necessary, and project-level test/fork documentation.
- Plugin submodule: ThirdParty header annotations, SDK support/tests, moved tests, and plugin test documentation.

The workspace was already dirty before this change. Unrelated modifications in the parent, plugin, and Wiki belong to the user and must be preserved. Scoped diffs, not broad reset/checkout operations, are required throughout.

## Version and upstream reference

The fork identifies itself in `AngelscriptRuntime/Core/angelscript.h` as:

- `ANGELSCRIPT_VERSION 23300`
- `ANGELSCRIPT_VERSION_STRING "2.33.0 WIP"`

The pinned local upstream reference is:

- path: `Reference/angelscript-v2.38.0`
- tag: `v2.38.0`
- commit: `0601da029d846a658bf23f2888e953a45a94450a`

The reference is an improvement source, not a wholesale replacement target. `Documents/Guides/AngelscriptForkStrategy.md` describes the structural divergence: automatic reference semantics, const-only script globals, no script `interface`, no `mixin class`, UE/FMemory allocation, APV2 module and type storage, hot-reload integration, and fork bytecode restore layout.

Already selected 2.38-compatible surfaces include foreach parsing/compiler support, module declaration lookup APIs, imported-function traits, parts of restore, wider type flags, and memory cleanup. This OpenSpec does not claim the fork is otherwise 2.38-compatible.

## Native SDK suite inventory before the change

Source inspection on 2026-07-22 produced:

| Metric | Value |
| --- | ---: |
| Flat `.cpp` files in `AngelScriptSDK` | 76 |
| Root headers in `AngelScriptSDK` | 6 |
| CQTest classes | 76 |
| Source `TEST_METHOD` definitions | 433 |
| Methods hidden by `WITH_ANGELSCRIPT_UNITTESTS && 0` | 12 |
| Source methods outside the three known constant-false blocks | 421 |
| Vendored `as_*.cpp` units | 41 |
| Concrete internal classes with out-of-line logic in the approved inventory | 36 |
| Public SDK interfaces | 12 |
| Test `.cpp` files above 500 lines | 7 |
| SDK classes using `EAutomationTestFlags::Disabled` | 0 |

The historical `301/301 PASS` documentation predates the current 433 source definitions. It remains useful as the last recorded run snapshot but must not be presented as the post-refactor definition count or verification result.

Seven current files exceed 500 lines. These values describe the baseline only; they are not target limits or split criteria:

| File | Lines at audit |
| --- | ---: |
| `AngelscriptScriptModuleTests.cpp` | 1269 |
| `AngelscriptBuilderTests.cpp` | 1224 |
| `AngelscriptBuilderBytecodeTests.cpp` | 589 |
| `AngelscriptTypeUsageTests.cpp` | 574 |
| `AngelscriptNativeReferenceScriptClassTests.cpp` | 569 |
| `AngelscriptBytecodeTests.cpp` | 560 |
| `AngelscriptBuilderDiagnosticsTests.cpp` | 558 |

The complete per-file migration is in `audits/file-map.md`; the 433-method migration ledger is in `audits/test-methods.csv`; required new depth scenarios are in `audits/test-scenarios.md`; the complete old-prefix migration is in `audits/test-id-migration.md`.

## Corrections made while planning

The source audit corrected several preliminary planning assumptions. These corrections are recorded so implementation does not regress to the earlier assumptions:

- The concrete class inventory is 36, not the preliminary 35. The approved new-export list remains exactly 14, so 22 classes already have usable visibility.
- The 41 implementation units include 14 callfunc-related sources: shared `as_callfunc.cpp`, 13 architecture/compiler backends, with Win64 MSVC active and 12 backends inactive for the current target. A preliminary note that called these “15 architecture sources” was incorrect.
- A search only for literal `#if 0` reports zero, but three files use `#if WITH_ANGELSCRIPT_UNITTESTS && 0`; together they hide 12 methods. The audit must detect constant-false expressions, not just literal `#if 0`.
- There are six root headers, because the generated-struct CppOps fixture header is also present and must move out of the SDK.

## Helper-layer evidence

The current support surface is too broad and internally inconsistent:

- `AngelscriptNativeTestSupport.h`: 1038 lines; owns diagnostics, two engine factories, module building, `FNativeTestEngine`, module scopes, ambiguous lookup, parser/tokenizer/bytecode helpers, fixtures, and compile snippets.
- `AngelscriptBuilderTestSupport.h`: 631 lines; adds builder-oriented helpers while overlapping module/compiler responsibilities.
- `AngelscriptSDKTestExecutionHelpers.h`: 466 lines; owns `FSdkFunctionInvoker` and additional standalone execute helpers with separate context lifecycle paths.
- `AngelscriptSDKTestUtilities.h`: small umbrella/alias layer whose remaining call sites can use the stable native support include.
- `AngelscriptTestAdapter.h`: stable compatibility adapter, but currently contains its own `FSDKBytecodeStream` and execution path.

`CreateNativeEngine` currently applies this implicit fork-compatibility property profile:

- `asEP_ALLOW_UNSAFE_REFERENCES = 1`
- `asEP_USE_CHARACTER_LITERALS = 1`
- `asEP_ALLOW_MULTILINE_STRINGS = 1`
- `asEP_SCRIPT_SCANNER = 1`
- `asEP_OPTIMIZE_BYTECODE = 1`
- `asEP_AUTO_GARBAGE_COLLECT = 0`
- `asEP_ALTER_SYNTAX_NAMED_ARGS = 1`
- `asEP_DISALLOW_VALUE_ASSIGN_FOR_REF_TYPE = 1`
- `asEP_ALLOW_IMPLICIT_HANDLE_TYPES = 1`
- `asEP_REQUIRE_ENUM_SCOPE = 1`
- `asEP_ALWAYS_IMPL_DEFAULT_CONSTRUCT = 1`
- `asEP_ALWAYS_IMPL_DEFAULT_COPY = 1`
- `asEP_ALWAYS_IMPL_DEFAULT_COPY_CONSTRUCT = 1`
- `asEP_MEMBER_INIT_MODE = 0`
- `asEP_TYPECHECK_SWITCH_ENUMS = 1`
- `asEP_ALLOW_DOUBLE_TYPE = 1`

`CreateBareSdkEngine` applies none of those properties. This semantic difference is real but hidden in factory names/call sites; the design makes it an explicit `ENativeEngineProfile` selection.

Other proven helper defects:

- The default message collector is global fallback state.
- `FNativeTestEngine::Reset` clears failure/messages/output but does not reset the engine or registrations, so a class-shared fixture can leak engine-global state between methods.
- `GetNativeFunctionByDecl` first uses exact lookup, then extracts a name, then accepts `GetFunctionByName`, then accepts the module's sole function, then scans by name. A test can therefore execute the wrong overload.
- `FSdkFunctionInvoker::CallAndReturn<float>` selects `GetReturnDouble()` when `asEP_FLOAT_IS_FLOAT64` is enabled, even though the declared function return type must determine the ABI accessor.
- `AngelscriptTestAdapter.h` and other helpers define duplicate memory byte streams and context execution flows.
- `SDKExecuteString` uses an internal `_assdk_exec_` module name and an ambiguous sole-function path; the refactor removes historical ASSDK terminology and makes function selection exact.

## Disabled and misleading coverage evidence

- `AngelscriptAtomicTests.cpp` has four useful direct tests, all compiled out solely because `asCAtomic` is not exported.
- `AngelscriptThreadTests.cpp` has three useful direct TLS tests, all compiled out because `asCThreadManager`/`asCThreadLocalData` are not exported.
- `AngelscriptStringUtilTests.cpp` has five compiled-out tests that register local `std::strtol`/`std::strtod` lambdas. They do not exercise `as_string_util.cpp` and must be replaced, not enabled.
- `AngelscriptRuntimeTests.cpp` includes a suspend-named case that does not prove a suspend/resume lifecycle.
- CallingConv Thiscall and several Object/OOP/automatic-reference/implicit-value scenarios are compile-only even when raw runtime execution is feasible.
- ScriptClass reference tests use permissive “or documented” outcomes and sometimes accept a null-pointer exception. Current fork behavior must be one active assertion; desired 2.38 behavior must be a separate Disabled test.

## Raw SDK boundary evidence

Eight areas are currently in the SDK directory despite depending on plugin/UE layers:

1. `AngelscriptCompilerTests.cpp`: seven tests use `FAngelscriptEngine::CompileModule`/trace behavior.
2. `AngelscriptContextPoolTests.cpp`: plugin context-pool behavior.
3. `AngelscriptDebuggerValueTests.cpp`: debugger value logic.
4. `AngelscriptDebugReificationTests.cpp`: debugger reification.
5. `AngelscriptFunctionCallerErasureTests.cpp`: plugin function-caller wrapper.
6. `AngelscriptStructCppOpsTests.cpp` and fixture types: generated UE struct CppOps.
7. `AngelscriptTypeRegistryTests.cpp`: plugin type registry.
8. `AngelscriptTypeUsageTests.cpp`: plugin/UE type-usage integration.

Their exact destination prefixes are preserved in `audits/file-map.md` and `audits/test-id-migration.md`. `AngelscriptDataTypeTests.cpp`, `AngelscriptGCInternalTests.cpp`, and `AngelscriptRestoreTests.cpp` remain in the SDK only after conversion to raw engine/internal APIs.

## Production visibility decision

Four approaches were considered for internal white-box access:

1. direct `ANGELSCRIPTRUNTIME_API` exports;
2. test-only Runtime wrappers;
3. moving tests into the Runtime module;
4. relying only on public black-box behavior.

Direct export annotations were selected because the implementation types already exist, the test module is intentionally separate, wrappers could mask ABI/signature defects, moving tests would violate the three-module ownership model, and black-box behavior alone cannot satisfy the approved concrete-class coverage. Exports change link visibility only.

The exact 14 new-export types are:

`asCAtomic`, `asCByteInstruction`, `asCConfigGroup`, `asCEnumType`, `asCExprContext`, `asCExprValue`, `asCFuncdefType`, `asCLockableSharedBool`, `asCOutputBuffer`, `asCStringPointer`, `asCThreadLocalData`, `asCThreadManager`, `asCTypedefType`, and `asCVariableScope`.

The exact seven exported free functions are:

`asCompareStrings`, `asStringScanDouble`, `asStringScanFloat`, `asStringScanUInt64`, `asStringEncodeUTF8`, `asStringDecodeUTF8`, and `asStringEncodeUTF16`.

The 22 already-visible classes and all direct coverage dispositions are listed in `audits/internal-classes.md`.

## Public interface inventory

The 12 core interfaces in `AngelscriptRuntime/Core/angelscript.h` are:

`asIScriptEngine`, `asIScriptModule`, `asIScriptContext`, `asIScriptGeneric`, `asIScriptObject`, `asITypeInfo`, `asIScriptFunction`, `asIBinaryStream`, `asIJITCompiler`, `asIThreadManager`, `asILockableSharedBool`, and `asIStringFactory`.

The core suite may implement minimal host test doubles for JIT, string factory, or thread-manager contracts, but it must not import an external add-on to satisfy them. Behavioral expectations are in `audits/interfaces.md` and `audits/public-api.md`.

## Core language scope

Internal-source coverage is not treated as a substitute for language coverage. The required language surface includes:

- tokens and declarations;
- functions, overloads, parameters/default arguments, recursion, returns;
- local/const variables, scope, and const-only global policy;
- class fields/properties and virtual properties;
- default/parameterized/copy construction, assignment, and destruction;
- inheritance, base construction/calls, override/virtual dispatch, abstract/final restrictions;
- expressions, arithmetic/bit/logical/comparison/ternary operators, overloads, conversions, member access;
- if/else, while/do/for/foreach, switch, break/continue/return;
- exceptions, suspend, abort, and call stacks;
- namespaces, sections, imports, enums, typedefs, funcdefs, mixin global functions;
- automatic references, identity, null behavior, and explicit rejection of `@` handles;
- strict rejection of mutable globals, script interfaces, and mixin classes in the current fork.

The external add-on exclusion includes scriptarray, dictionary, standard-string registration, weakref, datetime, math/complex, serializer, context manager, debugger, grid, filesystem, sockets, and other `sdk/add_on` packages. The detailed classification is in `audits/language-semantics.md`.

## 2.38 compatibility recording policy

Each conformance case belongs to one category:

- `Fork`: enabled, authoritative current behavior.
- `Compatible`: enabled behavior shared with 2.38.
- `Future238`: compiled/registered with `TEST_CLASS_WITH_FLAGS_AND_TAGS`, `EAutomationTestFlags::Disabled`, and the CQTest tag `TEXT("#as-v238-backport")`.
- `NotApplicable`: documented structural conflict with the fork.

The initial selected Future238 cases are using-namespace behavior, member initialization modes, default-copy semantics, and bool-context conversion. They are not enabled by this change. Each has its own topic-named test class so the Disabled flag/tag applies precisely. `#if 0`, `&& 0`, or dead unregistered helpers are forbidden as future-coverage mechanisms.

## Naming decision and coverage depth

New SDK C++ file names state only the tested subject, for example `AngelscriptNativeConstructorsTests.cpp` or `AngelscriptNativeContextReturnsTests.cpp`. They do not use generic process-oriented suffixes. OpenSpec inventory files likewise use subject names such as `language-semantics.md` and `public-api.md`.

This naming choice does not weaken coverage. Completeness remains a hard gate across implementation units, internal classes, interfaces, public API families, and every applicable depth dimension for the 14 language themes. The audit checks named owners/evidence rather than inferring sufficiency from file names or raw test counts.

## Automation and configuration evidence

Current suite tooling already uses the stable root:

- `Tools/Shared/TestSuiteDefinitions.ps1`: `NativeCore` points to `Angelscript.TestModule.AngelScriptSDK`.
- `All` also contains the same root once.

Current `Config/DefaultEngine.ini` has:

- an `AngelscriptNative` group matching `Angelscript.TestModule.AngelScriptSDK.`;
- an `AngelscriptFast` entry matching the same root;
- stale Smoke filters for `Angelscript.TestModule.AngelScriptSDK.Smoke` and `Angelscript.TestModule.AngelScriptSDK.ASSDK.Smoke`.

The root remains stable. The two stale Smoke filters are removed, and no nine-prefix duplication is added to `NativeCore`.

## Test-rule constraints from UnitTest.md

Relevant mandatory rules captured before implementation:

- use `WITH_ANGELSCRIPT_UNITTESTS` as the single registration gate;
- keep includes/helper implementations outside the body gate unless they themselves register tests;
- keep CQTest hooks public after private helpers;
- keep test intent in `TEST_METHOD`, use class-private narrow helpers, and avoid forwarding the whole scenario to a file-level helper;
- prefer matcher assertions in refactored CQTest main flows;
- raw SDK source must use `ASTEST_AS_ANSI(R"AS(...)AS")`;
- source and closing delimiter are visually indented and dedented by the wrapper, not placed at column zero;
- use Allman braces, meaningful source variable names, and no `"\\n"` concatenation;
- each case cleans its own modules, handles, contexts, and transient state;
- actual pass/fail numbers and log evidence are required before claiming success.

An older archived SDK coverage specification still says inline source begins at column zero. That is stale and conflicts with `UnitTest.md`/`ASInlineFormattingRule.md`; this change explicitly replaces that requirement.

## Coordination with active work

The enum-description lifetime fix in `ThirdParty/angelscript/source/as_builder.cpp` is already committed in plugin baseline `b903571`: enum value descriptions are deleted after compilation and removed from `globVariableList` so diagnostics do not traverse dangling pointers. This SDK refactor retains the focused post-build regression without reapplying or taking ownership of that production fix.

Other dirty files include test documentation, configuration, suite definitions, and unrelated plugin runtime/editor/test work. Any overlap requires reading the current hunk and applying the smallest compatible patch.

## Implementation sequencing decision

Normal per-test red/green compilation is deliberately replaced by large phase checkpoints to reduce Unreal build count:

1. complete and strictly validate OpenSpec;
2. **Structure phase:** finish all ThirdParty exports, five support owners, legacy-helper migration/deletion, eight out-of-layer moves, nine-domain directory reorganization, complete ID replacement, gates, and fixture-mechanical cleanup;
3. run the structure-mode static audit, then one structure build;
4. if that build fails, diagnose the causal failure classes, batch all same-class fixes, and rebuild only after the batch is ready;
5. **Coverage phase:** finish all 41/36/12/nine-domain/core-language/future-2.38 tests, complete audit enforcement, configuration, subject/depth records, and documentation;
6. run the complete static audit and strict OpenSpec validation, then one final integration build;
7. batch and repair any final build failures before rebuilding;
8. only after the final build passes, run nine SDK domains;
9. run eight moved prefixes;
10. run full SDK, NativeCore, then All;
11. diagnose test failures systematically and rerun the narrowest affected scope before resuming.

The nominal plan therefore has two full builds—one after the large structural phase and one after the complete coverage/integration phase—plus only evidence-driven repair rebuilds. There is no build per file, per moved test, or per individual test case.

A third build with `WITH_ANGELSCRIPT_UNITTESTS=0` is intentionally omitted. The existing unit-test-gate change already verified both compile modes, this change does not alter Build.cs or the CQTest fallback macros, the enabled build compiles the larger code surface, and the complete static audit verifies body gates. Any implementation change to gate plumbing invalidates this assumption and requires adding the disabled-gate build back to `tasks.md` before proceeding.

No supported non-unity runner was identified in the repository. The plan therefore uses static self-containment/symbol checks plus the repository's normal unity build; it does not invent a new build mode.

## Verification commands fixed during planning

Build:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-native-sdk-regression-build -TimeoutMs 1800000 -NoXGE
```

Each SDK domain uses:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.<Domain>" -Label "as-native-sdk-<domain>" -TimeoutMs 600000
```

Domains: `Engine`, `Frontend`, `Compiler`, `Runtime`, `Module`, `TypeSystem`, `Language`, `Embedding`, `Conformance`.

Moved prefixes:

- `Angelscript.TestModule.Compiler.ModulePipeline`
- `Angelscript.TestModule.Engine.ContextPool`
- `Angelscript.TestModule.Engine.FunctionCallers`
- `Angelscript.TestModule.Engine.TypeRegistry`
- `Angelscript.TestModule.Engine.TypeUsage`
- `Angelscript.TestModule.Debugger.Value`
- `Angelscript.TestModule.Debugger.Reification`
- `Angelscript.TestModule.Generator.ASStruct.CppOps`

Broad verification:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label as-native-sdk-regression-full -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite NativeCore -LabelPrefix as-native-sdk-regression -TimeoutMs 900000 -ContinueOnFail
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite All -LabelPrefix as-native-sdk-regression -TimeoutMs 900000 -ContinueOnFail
```

Every result must record start/end, exit code, discovered/pass/fail/disabled/not-found counts, and log path in `verification.md`.

## Planning artifact index

- `proposal.md`: decision-level motivation, changes, capabilities, and impact.
- `design.md`: architecture, alternatives, risks, migration, and execution ordering.
- `impact-map.md`: repositories, production/test/tool/docs/ABI/downstream impact.
- `audits/current-state.md`: concise inventory and defects.
- `audits/file-map.md`: disposition for all 76 current `.cpp` and six headers.
- `audits/implementation-units.md`: all 41 vendored implementation units and their coverage owners.
- `audits/internal-classes.md`: all 36 direct concrete class owners and the 14-export set.
- `audits/interfaces.md`: all 12 public core interfaces.
- `audits/public-api.md`: exported globals and method families for the 12 core interfaces.
- `audits/language-semantics.md`: core syntax/runtime behavior and add-on exclusion.
- `audits/test-depth.md`: the existing `Coverage/` benchmark and the depth completion rules/current gaps for all nine SDK domains.
- `audits/global-state.md`: safe ownership/restoration and non-mutating dispositions for process/thread-global APIs.
- `audits/workspace-baseline.md`: reviewed parent/submodule state, committed builder baseline, overlap ownership, and the fresh-baseline gate.
- `audits/test-methods.csv`: generated 433-row current-method disposition and exact final owner ledger.
- `audits/tools/GenerateTestMethodsLedger.ps1`: reproducible baseline ledger generator and 433-row source-key guard.
- `audits/test-scenarios.md`: exact minimum behavioral scenarios and depth dimensions for all domains/language themes.
- `audits/upstream-compatibility.md`: complete relevant 2.33–2.38 language and host API classification.
- `audits/test-id-migration.md`: old-to-new ID families and moved prefixes.
- `review.md`: final planning findings, resolutions, and ready-to-implement content gate.
- `tasks.md`: executable checklist and build/test gate.
- `verification.md`: evidence template.

## Remaining implementation-time unknowns

No product decision is open. Exact final method counts and pass counts cannot be known until implementation/discovery and must be generated rather than predicted. If an internal direct test exposes a symbol that cannot be exported without an ABI/layout side effect, implementation must stop, update this design with evidence, and obtain user direction instead of silently replacing direct coverage with a weaker claim.
