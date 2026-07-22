## Context

The native AngelScript SDK suite is the lowest executable regression layer for the vendored fork. It must distinguish raw SDK behavior from the UE wrapper, bindings, generated types, editor services, and debugger integration. The current directory does not preserve that boundary: raw `asIScriptEngine` tests, direct internal-class tests, `FAngelscriptEngine` tests, Debugger tests, generator tests, historical upstream ports, support headers, and duplicate smoke cases all live together.

The full planning evidence, source counts, corrected preliminary assumptions, helper property profile, user-approved decisions, active-work coordination, and exact verification commands are preserved in `background.md`. The concise inventories and mappings under `audits/` are normative implementation inputs rather than substitutes for that background.

The fork reports AngelScript version 2.33 and contains extensive `[UE++]` changes. It selectively includes some 2.38 surfaces, but deliberately differs on automatic reference semantics, const-only script globals, script interfaces, mixin classes, module storage, memory ownership, and restore layout. A native regression suite must therefore assert the fork as it exists rather than silently adapting assertions to vanilla 2.38. At the same time, useful 2.38 targets need a visible place in the executable test catalog.

The implementation is a dual-repository change: OpenSpec/configuration/documentation live in the parent repository; plugin source lives in the `Plugins/Angelscript` submodule. Both worktrees already contain unrelated user edits. `ThirdParty/angelscript/source/as_builder.cpp` is clean at the reviewed plugin baseline; the enum-description fix is committed in `b903571`, so this change preserves that behavior and owns only its regression coverage.

`Documents/UnitTest/UnitTest.md` is authoritative for test registration, fixture formatting, matcher assertions, lifecycle, cleanup, and helper boundaries. Every new/refactored test registration body is gated with `WITH_ANGELSCRIPT_UNITTESTS`; raw SDK inline source uses `ASTEST_AS_ANSI(R"AS(...)AS")` and visually indented, dedented fixtures.

## Goals / Non-Goals

**Goals:**

- Make the directory and automation-ID hierarchy communicate ownership and behavior.
- Provide deterministic, scoped raw-engine/module/context helpers with exact lookup and one execution path.
- Preserve the current fork's active semantics and make selected future 2.38 expectations compiled and discoverable.
- Give every vendored implementation unit, concrete internal class, and public SDK interface an auditable P0/P1 disposition.
- Cover every SDK domain to the existing `Coverage/` suite's behavioral depth standard, and cover the core language's syntax and runtime semantics—including properties and constructors—through a separate behavior inventory rather than treating internal implementation coverage as a substitute.
- Convert disabled or fake Atomic, Thread, and StringUtil tests into real compiled white-box coverage.
- Move UE wrapper/generator/debugger tests out of the raw SDK layer without reducing their coverage.
- Remove duplicate helpers, byte streams, ambiguous lookup, duplicate smoke coverage, stale IDs, compile-only claims, and oversized mixed-topic files.
- Complete each large implementation phase before its build, avoid per-file compilation, and defer automation tests until the final integration build passes.

**Non-Goals:**

- Wholesale upgrade of the fork to AngelScript 2.38 or replacement of APV2/UE-specific architecture.
- Enabling 2.38 semantics whose implementation is not already compatible with the fork.
- Changing the AngelScript script-facing API, object model, bytecode format, or UE plugin public behavior.
- Creating legacy automation-ID aliases or preserving historical file names solely for compatibility.
- Adding a non-unity build runner where the repository does not currently expose one.
- Reimplementing the enum-description fix already owned by `fix-automation-suite-reliability`.
- Testing AngelScript add-on libraries (`scriptarray`, dictionary, weakref, datetime, math/complex, standard string, or other `sdk/add_on` packages). The core `asIStringFactory` embedding contract remains in scope.
- Archiving the OpenSpec, committing either repository, or publishing changes automatically.

## Decisions

### 1. Use one ownership hierarchy with nine executable test domains

The root remains `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK` so existing module include paths and the root automation entry point remain stable. “Domain” here is a logical test ownership segment inside the existing `AngelscriptTest` UE module; this change does not create nine new UE modules. Under it:

| Directory / ID segment | Responsibility |
| --- | --- |
| `Engine` | engine lifecycle, configuration, memory, threading, context pool, function-call ABI |
| `Frontend` | source text, tokenizer, parser, AST/script nodes, string utilities |
| `Compiler` | builder, compiler, expression state, bytecode emission, diagnostics |
| `Runtime` | context execution, generic calls, GC, script object runtime behavior |
| `Module` | module APIs, sections, imports, namespaces, save/load/restore |
| `TypeSystem` | data types, type info, object/enum/typedef/funcdef types, config groups, globals, scopes |
| `Language` | fork language semantics exercised through public SDK APIs |
| `Embedding` | native registration, calling conventions, host callbacks, public interface contracts |
| `Conformance` | explicit fork decisions, compatible upstream behavior, and disabled future 2.38 expectations |
| `Support` | non-registering shared test infrastructure only |

Alternative: retain a flat directory and only rename IDs. Rejected because physical ownership, include boundaries, and file-size hotspots would remain opaque.

### 2. Preserve two compatibility includes but split implementation into five support headers

The root `AngelscriptNativeTestSupport.h` is removed rather than retained as a compatibility umbrella: root-level test sources are being eliminated, so a root include would preserve the old structure without a consumer. Its common implementation first moves to `Support/AngelscriptNativeCoreTestSupport.h`, then topic-specific helpers are extracted. `AngelscriptTestAdapter.h` remains the CQTest compatibility adapter until its callers move to the execution/module support paths. The support layout includes:

- `Support/AngelscriptNativeEngineTestSupport.h`
- `Support/AngelscriptNativeModuleTestSupport.h`
- `Support/AngelscriptNativeExecutionTestSupport.h`
- `Support/AngelscriptNativeCompilerTestSupport.h`
- `Support/AngelscriptNativeBuilderTestSupport.h`

The old `AngelscriptSDKTestUtilities.h`, `AngelscriptSDKTestExecutionHelpers.h`, and `AngelscriptBuilderTestSupport.h` are removed after every include site migrates. Common code lives once in `Support/AngelscriptNativeCoreTestSupport.h` or a topic-specific support header; file-local helpers remain in the test class or receive file-unique names where unity compilation requires it.

Alternative: delete the two old public includes. Rejected because `angelscript-test-helper-api` explicitly documents them as the stable extension surface.

### 3. Make ownership and engine configuration explicit

The support layer provides:

- `ENativeEngineProfile { BareSdk, ForkCompatibility }`.
- `FNativeTestEngine`, owning one `asIScriptEngine*`, its message collector, and shutdown.
- `FScopedNativeModule`, owning module creation/discard and section build state.
- `FScopedNativeContext`, owning acquire/prepare/unprepare/release for one context.
- `FNativeFunctionInvoker`, the only generic argument/execute/return conversion path.
- `FMemoryBinaryStream`, the only in-memory `asIBinaryStream` implementation.

`BareSdk` changes no engine properties beyond message capture. `ForkCompatibility` applies the properties required by the UE fork and records them at construction. Tests choose a profile at the call site. Reset destroys case-owned modules/contexts and clears messages; it is not a message-only reset.

Class-level shared raw engines are not used because registration mutates engine-global state and makes test order observable. Each `TEST_METHOD` owns its raw engine unless a narrowly documented read-only fixture can prove isolation.

Alternative: retain `CreateNativeEngine`/`CreateBareSdkEngine` free functions and class-level engine reuse. Rejected because profile intent and state cleanup remain implicit.

### 4. Declaration lookup is exact; name lookup is a separate API

`FindFunctionByDecl` delegates only to `asIScriptModule::GetFunctionByDecl`. The compatibility spelling `GetNativeFunctionByDecl` may remain as a deprecated exact alias during source migration, but it must not fall back to a function name or to “the only function.” Tests specifically exercising name lookup use `FindFunctionByName` and assert ambiguity behavior.

Alternative: preserve fallback for convenience. Rejected because it allows a test to execute the wrong overload while appearing to validate an exact declaration.

### 5. One execution path handles context lifecycle and return ABI

All execution helpers use `FScopedNativeContext` and `FNativeFunctionInvoker`. Argument setters and return readers are selected from AngelScript type IDs. In particular, `float` reads `GetReturnFloat()` and `double` reads `GetReturnDouble()`; the engine's precision property never changes the native ABI accessor for an explicitly declared return type. Exceptions, suspend, abort, and normal finish are returned as explicit outcomes rather than collapsed to a boolean.

Alternative: retain templates spread across `AngelscriptNativeTestSupport.h` and `AngelscriptSDKTestExecutionHelpers.h`. Rejected because duplicated prepare/execute/release paths already disagree about float returns and failure reporting.

### 6. Current fork semantics are active; future 2.38 semantics are compiled-disabled

Every semantic scenario is classified:

- `Fork`: active and authoritative for current behavior.
- `Compatible`: active behavior shared with the pinned 2.38 reference.
- `Future238`: source uses `TEST_CLASS_WITH_FLAGS_AND_TAGS`, includes `EAutomationTestFlags::Disabled`, and supplies the CQTest class tag `TEXT("#as-v238-backport")`.
- `NotApplicable`: documented only when the upstream behavior conflicts structurally with the UE fork.

Future script-semantic tests are never hidden with `#if 0`, `&& 0`, or unregistered helper functions. Each expressible future subject has a topic-named test file/class; the disabled test body expresses the desired assertion so enabling it later is a deliberate flag change plus implementation work. Higher-version C++ APIs that do not exist in the current headers are recorded as `Future238 API Deferred` with missing symbols and an enable condition; they are not referenced through uncompilable dead code or fake production declarations.

Alternative: comment the tests out. Rejected because commented code is not compiled, discoverable, or protected from rot.

### 7. Internal white-box access uses narrow DLL exports

The test module is a separate UE DLL. Direct coverage of internal implementations therefore requires symbol visibility. Add `ANGELSCRIPTRUNTIME_API` plus a `[UE++]` comment to these 14 existing internal class declarations without changing layout or behavior:

`asCAtomic`, `asCByteInstruction`, `asCConfigGroup`, `asCExprValue`, `asCExprContext`, `asCOutputBuffer`, `asCStringPointer`, `asCThreadLocalData`, `asCThreadManager`, `asCLockableSharedBool`, `asCVariableScope`, `asCEnumType`, `asCTypedefType`, and `asCFuncdefType`.

Export the existing free functions `asCompareStrings`, `asStringScanDouble`, `asStringScanFloat`, `asStringScanUInt64`, `asStringEncodeUTF8`, `asStringDecodeUTF8`, and `asStringEncodeUTF16` from `as_string_util.h` with the same marker. The remaining 22 concrete classes are already accessible/exported. No wrapper API is introduced.

Alternative: test-only wrappers in `AngelscriptRuntime`. Rejected because wrappers duplicate the surface, can mask ABI/signature defects, and add more production code than export annotations.

### 8. Coverage claims are audit-backed

The checked-in audit records are normative implementation inputs:

- `audits/implementation-units.md`: all 41 `as_*.cpp` units. Of the 14 callfunc-related units, the 12 inactive architecture backends are `Platform N/A`, while shared `as_callfunc.cpp` and the active Win64 MSVC backend map to execution/calling-convention coverage.
- `audits/internal-classes.md`: all 36 concrete classes with out-of-line logic, mapped to direct test files/method themes.
- `audits/interfaces.md`: 12 public SDK interfaces, mapped to behavioral/contract coverage.
- `audits/public-api.md`: exported global functions and each interface's method families, including callbacks, cleanup hooks, error paths, and the fork-specific concrete `asIScriptObject` surface.
- `audits/language-semantics.md`: core syntax, properties, constructors/destructors, object behavior, expressions, statements, and module-language features, separated from external add-ons.
- `audits/test-depth.md`: the completion standard and current gaps for all nine SDK domains, benchmarked against the existing deep `Coverage/` tests without using raw counts as quotas.
- `audits/global-state.md`: safe execution, RAII restoration, non-mutating contract, and Fork N/A dispositions for process/thread-global SDK state.
- `audits/workspace-baseline.md`: current parent/submodule coordination facts and the required fresh-baseline gate.
- `audits/test-methods.csv`: all 433 current methods, each with source line/SHA-256 identity, one disposition, and exact final owner; prohibited legacy generic suffixes are sanitized in the record and never carried into final names.
- `audits/test-scenarios.md`: minimum behavioral depth and exact new scenario owners for all nine domains and fourteen language themes.
- `audits/upstream-compatibility.md`: relevant 2.33–2.38 language/host API classifications and enable conditions.

A static audit script regenerates source and test inventory, verifies every required coverage key, checks IDs/gates/disabled policy, and fails on removed helper names, `ASSDK`, `NativeReference`, forbidden disabled blocks, duplicate byte streams, ambiguous lookup fallback, or SDK test files outside the approved domain directories.

Process-global setters are not invoked merely to increase a coverage count. `asSetAllocScriptObjectFunction` and `asSetResolveObjectPtrFunction` are already populated by the production runtime and expose no getter/restore surface; `asSetGlobalMemoryFunctions`/`asResetGlobalMemoryFunctions` are declared but intentionally have no fork definitions under the structural FMemory backend. Their explicit inventory disposition is source/integration ownership, while active memory behavior uses the FMemory gateways. The threading manager is observed without unpreparing the editor's production manager.

Alternative: infer completeness from raw test count. Rejected because test count does not prove source, class, interface, or semantic coverage.

### 9. Mis-layered tests move to owning themes

The following coverage moves without semantic loss:

| Current SDK file | Destination prefix |
| --- | --- |
| `AngelscriptCompilerTests.cpp` | `Angelscript.TestModule.Compiler.ModulePipeline` |
| `AngelscriptContextPoolTests.cpp` | `Angelscript.TestModule.Engine.ContextPool` |
| `AngelscriptDebuggerValueTests.cpp` | `Angelscript.TestModule.Debugger.Value` |
| `AngelscriptDebugReificationTests.cpp` | `Angelscript.TestModule.Debugger.Reification` |
| `AngelscriptFunctionCallerErasureTests.cpp` | `Angelscript.TestModule.Engine.FunctionCallers` |
| `AngelscriptStructCppOpsTests.cpp` and fixture types | `Angelscript.TestModule.Generator.ASStruct.CppOps` |
| `AngelscriptTypeRegistryTests.cpp` | `Angelscript.TestModule.Engine.TypeRegistry` |
| `AngelscriptTypeUsageTests.cpp` | `Angelscript.TestModule.Engine.TypeUsage` |

`AngelscriptDataTypeTests.cpp`, `AngelscriptGCInternalTests.cpp`, and `AngelscriptRestoreTests.cpp` stay in the SDK only after removal of full-wrapper dependencies and conversion to raw engine/internal APIs.

### 10. Full ID replacement is intentional

Every native test class registers under:

`Angelscript.TestModule.AngelScriptSDK.<Domain>.<Class>`

and every method completes the ID. File/class names use `SDK` or descriptive native names, never `ASSDK`. Historical flat IDs, `.NativeReference.*`, `.Smoke` duplicates, and source-class aliases are not retained. `audits/test-id-migration.md` records old-to-new prefix mappings for operators and CI migration.

The root `AngelScriptSDK` prefix remains stable, and `NativeCore` continues to include it. `Config/DefaultEngine.ini` removes the stale `.AngelScriptSDK.Smoke` and `.ASSDK.Smoke` entries and relies on the root group.

### 11. Source split follows behavior, not arbitrary line limits

`AngelscriptBuilderTests.cpp`, `AngelscriptScriptModuleTests.cpp`, `AngelscriptBytecodeTests.cpp`, and `AngelscriptNativeReferenceScriptClassTests.cpp` are redistributed into the exact subject owners in `audits/file-map.md` and `audits/test-methods.csv`. Splitting is cohesion-first: line count is not a quota, and a source above 500 lines is valid when it has one cohesive owner and a recorded rationale. Duplicate smoke cases collapse to `Engine.Smoke`. Atomic, Thread, and StringUtil files are replaced with direct real-implementation tests. Historical reference-port scenarios are assigned to their actual Language, Module, Runtime, Frontend, or Conformance owners.

### 12. Build only at large phase checkpoints

This change intentionally avoids test-by-test or file-by-file compilation. The implementation sequence is:

1. Write and strictly validate the complete OpenSpec.
2. Complete the entire structure phase: exports, support layer, legacy-helper migration/deletion, all cross-layer moves, nine-domain layout, ID replacement, gates, and mechanical fixture cleanup.
3. Run structure-mode static checks, then one structure build. Batch same-class compile fixes before any rebuild.
4. Complete the entire coverage phase: P0/P1 audit records, nine-domain depth evidence, core language behavior, strict conformance/future-2.38 tests, complete audit, config, and documentation.
5. Run complete static checks and strict OpenSpec validation, then one final integration build. Batch same-class fixes before any rebuild.
6. After the final build passes, run the nine native domain prefixes.
7. Run the eight moved-test prefixes.
8. Run the full SDK prefix, `NativeCore`, then `All`.
9. Use systematic debugging for each observed test failure, rerunning the narrowest affected command before resuming the sequence.

The nominal plan uses two full builds plus only necessary repair rebuilds. Automation tests do not begin after the structure build; they wait for the final integration build.

A separate `WITH_ANGELSCRIPT_UNITTESTS=0` build is not part of the nominal sequence because the established gate change already verified that compile mode, this change does not modify Build.cs or CQTest fallback macros, and the complete static audit verifies every registration body gate. If implementation changes gate plumbing, it MUST first add that build back to `tasks.md` and `verification.md`.

### 13. Freeze the native test-support contracts

The support types are test-internal C++ interfaces, but their ownership and call shapes are fixed so implementation does not create competing helpers:

```cpp
enum class ENativeEngineProfile : uint8
{
	BareSdk,
	ForkCompatibility,
};

struct FNativeMessageEntry
{
	asEMsgType Type;
	FString Section;
	int32 Row;
	int32 Column;
	FString Message;
};

class FNativeMessageCollector
{
public:
	static void MessageCallback(const asSMessageInfo* MessageInfo, void* UserData);
	const TArray<FNativeMessageEntry>& GetEntries() const;
	void Reset();
	bool Contains(asEMsgType Type, const TCHAR* Text) const;
};

class FNativeTestEngine
{
public:
	explicit FNativeTestEngine(FAutomationTestBase& Test, ENativeEngineProfile Profile);
	~FNativeTestEngine();
	asIScriptEngine* Get() const;
	FNativeMessageCollector& GetMessages();
	void ResetCaseState();
};

class FScopedNativeModule
{
public:
	FScopedNativeModule(FNativeTestEngine& Engine, const char* ModuleName);
	~FScopedNativeModule();
	int AddSection(const char* SectionName, const std::string& Source, int32 LineOffset = 0);
	int Build();
	asIScriptModule* Get() const;
	asIScriptFunction* FindFunctionByDecl(const char* Declaration) const;
	TArray<asIScriptFunction*> FindFunctionsByName(const char* Name) const;
};

enum class ENativeExecutionOutcome : uint8
{
	Finished,
	Suspended,
	Aborted,
	Exception,
	PrepareFailed,
	ExecuteFailed,
};

struct FNativeExecutionResult
{
	ENativeExecutionOutcome Outcome;
	int32 RawResult;
	int32 ReturnTypeId;
	FString ExceptionMessage;
	FString ExceptionFunction;
	int32 ExceptionLine;
};

class FScopedNativeContext
{
public:
	explicit FScopedNativeContext(asIScriptEngine& Engine);
	~FScopedNativeContext();
	int Prepare(asIScriptFunction& Function);
	asIScriptContext* Get() const;
};

class FNativeFunctionInvoker
{
public:
	explicit FNativeFunctionInvoker(FScopedNativeContext& Context);
	int SetArgument(uint32 Index, int32 TypeId, const void* Value);
	FNativeExecutionResult Execute();
	template<typename T> T ReadReturn(int32 DeclaredTypeId) const;
};

class FMemoryBinaryStream final : public asIBinaryStream
{
public:
	void Write(const void* Pointer, asUINT Size) override;
	void Read(void* Pointer, asUINT Size) override;
	void ResetReadPosition();
	void Truncate(int32 NewSize);
	bool HasReadError() const;
	const TArray<uint8>& GetBytes() const;
};
```

Contract details:

- `FNativeTestEngine` owns exactly one engine and one collector. Its destructor discards test-owned modules, releases/unprepares test-owned contexts, resets messages, and then shuts down the engine.
- `BareSdk` changes no optional property. `ForkCompatibility` applies exactly the 16 properties recorded in `background.md` and fails with the property name if any setting is rejected.
- `FindFunctionByDecl` calls only `asIScriptModule::GetFunctionByDecl`. The compatibility alias `GetNativeFunctionByDecl`, if temporarily retained, is a deprecated exact forwarding function.
- `FindFunctionsByName` returns every match. It never selects the first/only function implicitly; a caller expecting one match asserts `Num() == 1`.
- `FNativeFunctionInvoker` is the only generic argument/execute/return path. It uses declared type IDs, reads `float` with `GetReturnFloat()` and `double` with `GetReturnDouble()`, and preserves non-finished outcomes.
- `FMemoryBinaryStream` is the only in-memory binary stream in the SDK suite and deliberately exposes truncation for negative save/load cases.
- `AngelscriptTestAdapter.h` delegates to these owners. `SDKExecuteString` uses an exact documented entry declaration and has no function-name or sole-function fallback.

### 14. Make CQTest and inline-source rules auditable

All active final SDK classes use `TEST_CLASS_WITH_FLAGS`; only Future238 classes use `TEST_CLASS_WITH_FLAGS_AND_TAGS`. Each registering `.cpp` keeps includes outside and registrations inside `#if WITH_ANGELSCRIPT_UNITTESTS`. No legacy Automation/Spec registration is introduced.

`Documents/UnitTest/UnitTest.md` normally requires class-level `FAngelscriptEngine` lifecycle for wrapper CQTests. Native SDK tests are the explicit layer-specific exception: each `TEST_METHOD` owns a raw `asIScriptEngine` because registration mutates engine-global state. Moved wrapper tests continue using class-level `FAngelscriptEngine`; raw and wrapper lifecycle helpers are not mixed.

Each scenario-specific `TEST_METHOD` keeps compile/execute/assert intent visible. One-class helpers are private, hooks/methods return to `public:`, helpers receiving `FAutomationTestBase&` get `*TestRunner`, and refactored main flows use matcher assertions. Raw source is local `ASTEST_AS_ANSI(R"AS(...)AS")` with visual indentation, dedent, Allman braces, spacing, and scenario-specific names. A line/column-sensitive case uses the preserve-lines helper and records why normalization is unsafe.

## Risks / Trade-offs

- **Large rename obscures behavior regressions** → Preserve an explicit ID migration table, mechanical source inventory, and post-write static audit before compiling.
- **New exports widen the DLL symbol surface** → Export only existing declarations needed for white-box tests; mark every export `[UE++]`; do not change object layout or add script registration.
- **Per-test engine creation increases runtime** → Prefer correctness and isolation; optimize only after measuring the completed suite and without reintroducing mutable shared state.
- **Disabled 2.38 tests can accumulate indefinitely** → Require one `#as-v238-backport` tag and a concrete assertion body; catalog them separately from active pass counts.
- **Moving tests can silently reduce discovery** → Record every old/new mapping and run exact destination prefixes before the broad suite.
- **Unity build can hide/self-create collisions** → Static audit all file-local symbols and common helpers; keep shared definitions in support headers and uniquely name divergent local helpers.
- **Existing dirty files can be overwritten** → Capture a fresh baseline, inspect diffs before each overlapping patch, and never replace unrelated hunks. Treat the `as_builder.cpp` production fix as committed baseline behavior.
- **Historical docs contain stale counts/rules** → Update Chinese-facing guidance first, then English/catalog/config, and make counts generated by the audit rather than hand-waved.
- **Full-suite failures may be unrelated** → Record baseline ownership and only modify failures causally connected to this change; report unrelated failures separately.

## Migration Plan

1. Create and strictly validate proposal, design, delta specs, task checklist, current-state audit, complete subject/depth records, ID migration, file map, and verification template.
2. Add the narrow ThirdParty export annotations and string utility exports, preserving all existing `[UE++]` edits.
3. Create the five support headers, make the two stable includes thin, migrate all SDK includes/calls, then remove obsolete helpers and duplicate stream implementations.
4. Move the eight mis-layered areas to their owning directories and update their IDs/gates without reducing assertions.
5. Create the nine SDK directories, distribute/rename tests, split hotspots, replace Atomic/Thread/StringUtil, and remove obsolete sources.
6. Add direct class/interface/source-unit coverage, deep evidence for every SDK domain, and disabled 2.38 expectations until all audit records close.
7. Run the audit in structure mode and perform the single structure build; batch any compile fixes.
8. Finish complete coverage/config/documentation, run the complete audit, and perform the final integration build.
9. Execute automation verification in the approved order and record exact commands, timestamps, counts, and logs in `verification.md`.
10. Leave the change active and unarchived. Do not commit or update the parent gitlink unless the user later asks.

Rollback is file-based: restore the previous SDK directory and automation IDs, remove only the new export annotations, and restore config/document entries. No persistent user data or serialized runtime format changes.

## Open Questions

No design-blocking questions remain. The approved choices are: current-fork semantics first, compiled-disabled/tagged 2.38 targets, direct DLL exports, full ID replacement, source deletion/addition permitted, current checkout rather than a new worktree, low-frequency structure/final phase builds, and automation only after the final integration build.
