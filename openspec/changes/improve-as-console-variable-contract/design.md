## Context

`FConsoleVariable` is currently a Runtime manual binding implemented by `Bind_Console.h/.cpp` and `Bind_Console_Functions.cpp`. AngelScript sees one value type, but C++ registers its storage and destructor as `FScriptConsoleVariable<int32>` while the four constructors placement-new `FScriptConsoleVariable<int32>`, `<bool>`, `<float>`, or `<FString>`. Every specialization currently has the same fields, so normal-path tests pass, but cross-specialization method dispatch and destruction depend on an implementation coincidence.

The constructor currently performs `FindConsoleVariable(Name)` and registers only when the name is missing. During initial compilation it captures `this` in `OnInitialCompileFinished`; before the callback runs, getters return zero/empty values and setters silently do nothing. Destruction removes only a pending delegate and never unregisters an already-created CVar. Consequently the actual lifetime is process/console-manager lifetime even though the binding documentation says handle lifetime.

Unreal's `IConsoleManager` registry is process-global, while AngelScript engines, modules, and hot-reload generations have narrower lifetimes. The design must therefore coordinate global console-object identity with engine/module ownership without adding an Editor dependency. The current CVar tests prove binding availability, four-type read/write, native reuse, and metadata preservation, but their fixture manually unregisters tracked names before its leak assertion; they do not establish runtime ownership behavior.

The design follows the current source and engine interfaces rather than legacy planning documents. Tests must follow `Documents/UnitTest/UnitTest.md`, `Documents/Guides/TestConventions.md`, `Documents/Guides/Test.md`, and `Documents/Rules/ASInlineFormattingRule.md`.

## Goals / Non-Goals

**Goals:**

- Remove the cross-template object-layout and destructor dependency while preserving source compatibility for existing AS scripts.
- Give `Define` and `Find` separate, testable semantics.
- Make AS-created versus native-borrowed ownership explicit across engine shutdown, module discard, successful hot reload, and failed compilation.
- Make initial-compile registration safe without a per-handle lambda that captures an object address.
- Provide deterministic states and diagnostics for missing names, pending declarations, duplicate definitions, type mismatches, and CVar/command collisions.
- Add a bounded set of persistent creation flags and setting-source/result APIs without exposing arbitrary UE flag bits.
- Keep the entire script-facing feature in `AngelscriptRuntime` and validate it through `AngelscriptTest`.

**Non-Goals:**

- No `AngelscriptEditor` binding, editor UI, CVar browser, or editor-only owner.
- No `TConsoleVariable<T>` AngelScript generic type or compiler syntax/metadata extension.
- No direct CVar changed delegate in the first version; callback lifetime and reentrancy need a separate design.
- No arbitrary raw `EConsoleVariableFlags` integer passthrough and no script ability to impersonate command-line or interactive-console priority.
- No redesign of `FConsoleCommand`; only prevent a command from destroying/replacing a CVar with the same name and keep current command-to-command replacement behavior.
- No attempt to roll back arbitrary side effects caused by a script that explicitly calls `Console::Find(...).Set*()` during global initialization. Transactionality applies to CVar definitions, ownership, and registration metadata.

## Decisions

### 1. Keep one non-template value handle

`FScriptConsoleVariable<VarType>` will be replaced with a single `FScriptConsoleVariable`. The AngelScript value object will contain a shared handle state rather than a raw `IConsoleVariable*`, engine pointer, and delegate handle. The state records the name, declared/observed type, declaration default for pending reads, and current resolution status. Copy construction and assignment copy the shared state explicitly, so no handle copy owns an independent registration callback or unregister responsibility.

Every getter and setter resolves the current console object through the registry/name before use. This avoids retaining a dangling borrowed pointer if native code unregisters or replaces a console object. A resolved replacement is accepted only when it is still an `IConsoleVariable` with a compatible type; otherwise the handle becomes invalid and reports the identity change.

Alternatives rejected:

- Keeping four template specializations preserves the current undefined cross-specialization assumptions and makes future state additions dangerous.
- Binding `TConsoleVariable<T>` would improve static typing but expands generic binding, migration, documentation, and ABI scope without solving ownership by itself.
- Making the value type non-copyable would be safe but unnecessarily awkward for a lightweight script handle; shared state provides deterministic copy behavior.

### 2. Add explicit `Console::Define` and `Console::Find`

The Runtime binding will expose overloads equivalent to:

```angelscript
namespace Console
{
	FConsoleVariable Define(const FString& Name, int DefaultValue,
		const FString& Help = "",
		EScriptConsoleVariableFlags Flags = EScriptConsoleVariableFlags::Default);
	FConsoleVariable Define(const FString& Name, bool DefaultValue,
		const FString& Help = "",
		EScriptConsoleVariableFlags Flags = EScriptConsoleVariableFlags::Default);
	FConsoleVariable Define(const FString& Name, float32 DefaultValue,
		const FString& Help = "",
		EScriptConsoleVariableFlags Flags = EScriptConsoleVariableFlags::Default);
	FConsoleVariable Define(const FString& Name, const FString& DefaultValue,
		const FString& Help = "",
		EScriptConsoleVariableFlags Flags = EScriptConsoleVariableFlags::Default);

	FConsoleVariable Find(const FString& Name);
}
```

The existing four `FConsoleVariable(Name, DefaultValue, Help)` constructors remain and route to the same registry operation as `Console::Define(..., DefaultFlags)`. Existing `Get*`/`Set*` signatures remain available. Constructors and returned handles remain `NoDiscard` where supported by the bind DSL.

`Define` creates or owns a declaration. `Find` never registers and never becomes an owner. A missing `Find` is an expected invalid handle and does not log an error until a value operation is attempted without an `IsValid()` guard.

### 3. Use a Runtime global registry with engine/module-generation owner tokens

`FAngelscriptConsoleVariableRegistry` will live under `AngelscriptRuntime/Binds/Console/`. One registry coordinates the process-global `IConsoleManager`; its records are keyed by canonical CVar name. Each record distinguishes:

- an AS-created console variable, for which the registry may unregister;
- a native-borrowed console variable, which the registry never unregisters;
- committed owner tokens identified by `FAngelscriptEngine*` plus `asIScriptModule*` generation identity;
- staged owner tokens associated with an active compile transaction;
- the declared type, default/help/flags for AS-created definitions;
- shared handle states that must be refreshed or invalidated.

The caller module/generation is captured from the current AngelScript context and function module. Calling `Define` from a function-local scope still creates module-generation ownership; destroying the local handle does not remove the CVar. `Find` creates no ownership. This preserves existing scripts that construct a CVar in a helper function while bounding the registration to the owning module/engine lifecycle.

When the last committed owner of an AS-created CVar disappears, the registry calls `UnregisterConsoleObject` with keep-state enabled so a compatible future definition can recover the console manager's retained value. When the last owner of a native-borrowed record disappears, only registry metadata is dropped. Registry/engine detach clears pending work and invalidates shared handles before their engine pointer can become stale.

### 4. Integrate registry transactions with compile and module lifecycle

The engine will gain narrow engine-owned internal lifecycle hooks for:

- compile begin/end with `ECompileType`, `ECompileResult`, and the participating module descriptors;
- active module-generation discard with module name and the old `asIScriptModule*` identity.

These hooks do not replace `FAngelscriptCompilationEvents`, `GetPreCompile`, or `GetPostCompile`; they provide the exact engine identity and generation lifecycle needed by an engine extension. The CVar registry extension attaches/detaches to each published engine through `FAngelscriptEngineExtensionRegistry` and owns its delegate handles.

During a compile run, `Define` records declarations in a transaction and does not mutate `IConsoleManager`. On successful hot reload, old-generation removals and new-generation definitions are reconciled in one game-thread commit: unchanged compatible names retain the same CVar and current value, new names register, and names with no remaining owner unregister. On failure, staged definitions and staged removals are discarded, leaving the last-good registry and UE console state unchanged.

Initial compilation may run off the game thread. Its successful transaction remains pending until `PostInitialize_GameThread()` broadcasts `OnInitialCompileFinished`; only then may the registry call `IConsoleManager`. Handles created by initial global initialization are valid-but-not-ready and read their declared default until commit. `TrySet*` returns `NotReady` during this window. No lambda captures a handle's address.

All `IConsoleManager` registration, unregistration, and metadata reconciliation SHALL run on the game thread. A non-initial compile completion observed off the game thread is queued to the game thread with a monotonically ordered transaction id; a newer transaction cannot be committed before an older one for the same engine.

### 5. Define duplicate, native reuse, and collision rules

- Exact duplicate AS definitions—same canonical name, type, help, and persistent flags—share the registration and add an owner. The first committed default initializes a new CVar; later compatible owners do not reset the live value.
- Conflicting AS definitions—different type, help, or persistent flags—fail the new declaration with a diagnostic containing the name, existing declaration attributes, incoming attributes, and owner module names. The committed definition remains unchanged.
- `Define` over an existing native CVar succeeds only when the native type is compatible. It returns a borrowed handle and preserves native value, help, flags, identity, and ownership; script defaults/metadata never overwrite native metadata.
- `Find` over any existing CVar returns a borrowed, immediately ready handle and permits the existing UE conversion getters/setters.
- A console command with the requested name makes `Define` invalid and produces a deterministic diagnostic. A new `FConsoleCommand` may replace another command as today, but it may not unregister a CVar—native or AS-created—with the same name.
- Empty or UE-invalid console-object names fail `Define` without leaving a staged owner or console object.

### 6. Expose explicit state, type, flags, and safe setting results

The script surface will add:

```angelscript
enum EScriptConsoleVariableType
{
	Invalid,
	Bool,
	Int,
	Float,
	String,
}

enum EScriptConsoleVariableFlags
{
	Default = 0,
	Cheat = 1,
	ReadOnly = 2,
	RenderThreadSafe = 4,
}

enum EScriptConsoleVariableSetBy
{
	GameSetting,
	Code,
}

enum EScriptConsoleVariableSource
{
	Unknown,
	Constructor,
	Scalability,
	GameSetting,
	ProjectSetting,
	SystemSettingsIni,
	DeviceProfile,
	GameOverride,
	ConsoleVariablesIni,
	CommandLine,
	Code,
	Console,
}

enum EScriptConsoleVariableSetResult
{
	Succeeded,
	InvalidHandle,
	NotReady,
	ReadOnly,
	PriorityRejected,
}
```

Only the four approved persistent flag bits are accepted, including combinations; unknown bits fail `Define`. Registry code maps them to UE flags and never exposes `ECVF_SetByMask` as creation flags. Native CVar flags are preserved and queried rather than rewritten.

New handle methods are:

```angelscript
bool IsValid() const;
bool IsReady() const;
FString GetName() const;
EScriptConsoleVariableType GetType() const;
EScriptConsoleVariableSource GetLastSetBy() const;

EScriptConsoleVariableSetResult TrySetBool(bool Value,
	EScriptConsoleVariableSetBy SetBy = EScriptConsoleVariableSetBy::Code) const;
EScriptConsoleVariableSetResult TrySetInt(int Value,
	EScriptConsoleVariableSetBy SetBy = EScriptConsoleVariableSetBy::Code) const;
EScriptConsoleVariableSetResult TrySetFloat(float32 Value,
	EScriptConsoleVariableSetBy SetBy = EScriptConsoleVariableSetBy::Code) const;
EScriptConsoleVariableSetResult TrySetString(const FString& Value,
	EScriptConsoleVariableSetBy SetBy = EScriptConsoleVariableSetBy::Code) const;
```

Legacy `Set*` methods call the corresponding `TrySet*` with `Code`; failure remains non-throwing for source compatibility but emits a rate-limited diagnostic instead of disappearing silently. Pending `Define` getters return their declaration default converted through the requested getter. Missing/invalid `Find` getters retain type-neutral fallbacks for compatibility but emit a rate-limited invalid-handle diagnostic. `EScriptConsoleVariableSetBy` is the bounded input enum, whereas the separate read-only `EScriptConsoleVariableSource` covers every UE source currently represented by `ECVF_SetByMask`; scripts can observe but cannot request constructor, ini, device-profile, command-line, or interactive-console authority.

### 7. Keep change callbacks out of the first contract

The registry will not bind `IConsoleVariable::SetOnChangedCallback` to AngelScript in this change. UE CVar callbacks can run during initialization, can re-enter other CVar writes, and would retain script function/module references across reload. Polling `Get*()` and the bounded setting result APIs cover the immediate need. A later OpenSpec may design a game-thread sink with generation-safe subscription ownership.

### 8. Separate binding smoke from runtime semantics in tests

`Bindings.Console` retains a small contract smoke for constructors, `Console::Define`, `Console::Find`, state queries, and representative read/write dispatch. The ownership, conflict, transaction, priority, and reload matrix moves to a new Runtime Integration theme under `AngelscriptTest/ConsoleVariable/` with prefix `Angelscript.TestModule.ConsoleVariable.*`.

Every new registration `.cpp` is guarded by `#if WITH_ANGELSCRIPT_UNITTESTS`, uses `TEST_CLASS_WITH_FLAGS`, class-level engine creation/reset, matcher assertions, `ASTEST_AS(...)`, and case-owned module/console-object cleanup. Tests must observe registry behavior before any emergency cleanup; cleanup exists only to restore the process-global console manager after a failed assertion. Existing `Coverage.CVar` stays as the broad access/value matrix and is rerun for regression coverage.

## Risks / Trade-offs

- **[Registry and UE both have global identity]** → Resolve by name on every operation, distinguish AS-created/native-borrowed records, and invalidate a record if an external replacement changes kind or type.
- **[Hot reload momentarily discards an old generation]** → Stage discard and new declarations inside one compile transaction; unregister only at successful commit.
- **[Failed compile can leave staging memory]** → Always receive compile-end result, roll back the transaction on every non-success result, and clear remaining transactions on engine detach.
- **[Initial compile is off-thread]** → Never call `IConsoleManager` from the compiling thread; commit on `OnInitialCompileFinished` on the game thread.
- **[Multiple engines in tests share one `IConsoleManager`]** → Include engine identity in owner tokens, attach/detach through the engine extension registry, and use unique test prefixes.
- **[Legacy local constructors become module-owned]** → This matches current observable persistence while introducing a real cleanup boundary at module/engine lifetime.
- **[Keep-state may restore an old value after redefinition]** → Restore only when the new definition is type-compatible; incompatible redefinitions fail and do not consume retained state.
- **[Rate-limited diagnostics hide repeated context]** → Include name, operation, state, caller module, and first failure reason; suppress only identical repeats within one generation.
- **[New engine lifecycle hooks broaden Core surface]** → Keep payloads narrow and engine-owned, cover success/failure ordering in Compiler tests, and do not expose mutable compiler/module internals.

## Migration Plan

1. Add failing contract tests for single-handle type/copy behavior and the new API declarations while existing constructors remain the compatibility baseline.
2. Introduce the non-template handle and shared state without changing external CVar lifetime; make the existing tests pass.
3. Add compile/module lifecycle hooks and registry transaction tests, then route definitions through the registry.
4. Add `Console::Define`/`Find`, state/type queries, collisions, flags, and `TrySet*` APIs under focused tests.
5. Move deep runtime cases to `AngelscriptTest/ConsoleVariable/`, keep `Bindings.Console` as smoke, rerun `Coverage.CVar`, and add a real script example.
6. Update the binding API table and test catalog only after the tested surface is final.

Rollback is source-compatible: the legacy AS constructors and `Get*`/`Set*` declarations remain throughout. If registry rollout must be reverted, the new namespace APIs can temporarily route to the non-template direct implementation while the old constructor surface continues to compile. Do not restore the template-specialization storage/destructor model.

## Open Questions

None for the first implementation. The public enum members, module-generation ownership, game-thread commit rule, native-borrowed behavior, legacy compatibility, and callback exclusion are fixed by this design; expanding flag sources or adding callbacks requires a follow-up OpenSpec.
