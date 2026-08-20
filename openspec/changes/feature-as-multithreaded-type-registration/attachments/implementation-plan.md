# Native Engine Multithread Schemes — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Track progress with checkboxes in `../tasks.md` (OpenSpec parser), not by duplicating boxes here.

**Goal:** Restore stock-grade engine locks (A0), define concurrent independent type `Register*` inside an explicit window (A1), then intern template instances so host stage3 bytecode can ParallelFor (A2).

**Architecture:** One `engineRWLock` intern lock. Keep `TMap`/`asCArray`. Do not start with lock-free containers or `CallBinds` ParallelFor. Dual-repo: C++ in `Plugins/Angelscript` first.

**Tech Stack:** Maintained AngelScript fork, UE `FRWLock`/`FCriticalSection` + Standalone `UECompat` shims, native SDK CQTest, Standalone CTest, host `ParallelFor` + cvar.

**Spec:** `../design.md` plus `../specs/as-engine-thread-lock-floor/spec.md`, `../specs/as-multithreaded-type-registration/spec.md`, `../specs/as-compile-intern-parallel-bytecode/spec.md`.

## Global Constraints

- Dual-repo: C++ in `Plugins/Angelscript` first, then parent gitlink + this OpenSpec.
- Do not ParallelFor `CallBinds` or make `RegisterObjectMethod` concurrent.
- Do not replace `asCArray` / `TMap` with lock-free containers.
- Do not use Hazelight `myas` as an implementation template.
- Do not commit unless the user asks (this repo’s git rule overrides writing-plans “commit every task”).
- New tests: `Angelscript` prefix. Pure SDK / no UObject → `AngelscriptTest/AngelScriptSDK/` plus Standalone CTest.
- Verify only with `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, `Tools\RunTestSuite.ps1`.
- Native engine first: tests call `asIScriptEngine` / `asCScriptEngine`, not `FAngelscriptBinds`.
- Upstream 2.38/2.39 do not supply concurrent Register* or parallel Build; copy lock/`RequestBuild`/lazy-id DCL from `Reference/angelscript-v2.38.0/sdk/angelscript/source/`.

---

## File map

| Path | Scheme | Role |
|---|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_criticalsection.h` | A0 | Real `asCThreadCriticalSection` / `asCThreadReadWriteLock` wrapping `FCriticalSection` / `FRWLock` when `!AS_NO_THREADS` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_thread.cpp` | A0 | UE implementations of public `asPrepareMultithread` / `asThreadCleanup` / app `asAcquire*Lock` (header already declares them) |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h` | A0–A2 | Window flag; `InternRegisteredType`; `AllocateFunction` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp` | A0–A2 | Locked `RequestBuild`/`BuildCompleted`; lazy-id DCL (~5027); Register* intern; `GetTemplateInstanceType`; function alloc |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h` | A1 | `BeginConcurrentTypeRegistration` / `EndConcurrentTypeRegistration` at end of `asIScriptEngine` |
| `Plugins/Angelscript/Standalone/Compat/UECompat.h` | A0 | `FCriticalSection`, `FRWLock` (`std::mutex` / `std::shared_mutex`) |
| `Plugins/Angelscript/Standalone/CMakeLists.txt` | A0 | Remove `AS_NO_THREADS` from `AngelscriptMaintainedFork`; add CTest executable |
| `Plugins/Angelscript/Standalone/Tests/CMake/AssertTargetInterfaces.cmake` | A0 | Remove `AS_NO_THREADS` from the private-definition assert list (keep the assert: it must **not** leak as INTERFACE) |
| `Plugins/Angelscript/Standalone/Compat/Source/AngelscriptStandaloneThreadCompat.cpp` | A0 | App lock already exists behind `#ifndef AS_NO_THREADS`; keep after the define is dropped |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Engine/AngelscriptConcurrentTypeRegistrationTests.cpp` | A0/A1 | Native concurrent tests (`FRunnable`) |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Engine/AngelscriptCompileInternTests.cpp` | A2 | Template intern + AllocateFunction |
| `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneConcurrentTypeRegistrationTests.cpp` | A0/A1 | CTest `std::thread` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` | A2 | Cvar-gated ParallelFor of `BuildCompileCode`; serial `JITCompile` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.cpp` | A2 | Do not ParallelFor inside one builder until diagnostics are per-builder; `WriteMessage` lock if needed |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_map.h` | — | No rewrite |

`AngelscriptTest.Build.cs` already globbs `.cpp` under the module; no list edit for new test files.

---

## Scheme A0 — floor locks

### A0 interfaces

```cpp
// as_scriptengine.h — already declared
int  RequestBuild();
void BuildCompleted();
int  GetTypeIdFromDataType(const asCDataType &dt) const;

// as_criticalsection.h — restore types
class asCThreadCriticalSection {
public:
	void Enter();
	void Leave();
	bool TryEnter();
private:
	FCriticalSection Mutex;
};

class asCThreadReadWriteLock {
public:
	void AcquireExclusive();
	void ReleaseExclusive();
	void AcquireShared();
	void ReleaseShared();
private:
	FRWLock Lock;
};
```

Copy `RequestBuild` from `Reference/angelscript-v2.38.0/sdk/angelscript/source/as_scriptengine.cpp` ~3609, and **also** lock `BuildCompleted` when clearing `isBuilding`.

Copy lazy-id exclusive DCL from the same 2.38 file ~5094–5108, using this fork’s `mapTypeIdToTypeInfo.Add` (not stock `Insert`).

### A0 Standalone `FRWLock` shim (UECompat.h)

Match UE names so `as_criticalsection.h` compiles unchanged on both hosts. `CoreMinimal.h` on Standalone is `#include "UECompat.h"` and does **not** currently provide these types.

```cpp
#include <mutex>
#include <shared_mutex>

class FCriticalSection
{
public:
	void Lock() { Mutex.lock(); }
	void Unlock() { Mutex.unlock(); }
	bool TryLock() { return Mutex.try_lock(); }
private:
	std::mutex Mutex;
};

class FRWLock
{
public:
	void ReadLock() { Mutex.lock_shared(); }
	void ReadUnlock() { Mutex.unlock_shared(); }
	void WriteLock() { Mutex.lock(); }
	void WriteUnlock() { Mutex.unlock(); }
private:
	std::shared_mutex Mutex;
};
```

Do not include `Windows.h` SRWLOCK. Do not compile stock 2.38 pthread/Win32 lock class bodies.

### A0 native test sketch

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Engine/AngelscriptConcurrentTypeRegistrationTests.cpp`

Pattern: copy includes/`FRunnable` style from `AngelscriptNativeAtomicTests.cpp`. Prefix:

`Angelscript.TestModule.AngelScriptSDK.Engine.ConcurrentTypeRegistration`

```cpp
#include "CQTest.h"
#include "AngelscriptTestMacros.h"
#include "../Support/AngelscriptNativeCoreTestSupport.h"
#include "HAL/Runnable.h"
#include "HAL/RunnableThread.h"
#include <atomic>

#include "StartAngelscriptHeaders.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

#if WITH_ANGELSCRIPT_UNITTESTS

TEST_CLASS_WITH_FLAGS(FConcurrentTypeRegistrationTests,
	"Angelscript.TestModule.AngelScriptSDK.Engine.ConcurrentTypeRegistration",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(RequestBuildFromTwoThreads)
	{
		using namespace AngelscriptNativeTestSupport;
		asCScriptEngine* const Engine = CreateBareSdkEngine(this);
		ASSERT_THAT(IsTrue(Engine != nullptr));
		ON_SCOPE_EXIT { DestroyNativeEngine(Engine); };

		std::atomic<int32> SuccessCount{0};
		std::atomic<int32> InProgressCount{0};

		class FBuildWorker final : public FRunnable
		{
		public:
			FBuildWorker(asCScriptEngine* InEngine, std::atomic<int32>& InOk, std::atomic<int32>& InBusy)
				: Engine(InEngine), Ok(InOk), Busy(InBusy) {}
			uint32 Run() override
			{
				const int Result = Engine->RequestBuild();
				if (Result == 0) { Ok.fetch_add(1); }
				else if (Result == asBUILD_IN_PROGRESS) { Busy.fetch_add(1); }
				return 0;
			}
		private:
			asCScriptEngine* Engine;
			std::atomic<int32>& Ok;
			std::atomic<int32>& Busy;
		};

		FBuildWorker A(Engine, SuccessCount, InProgressCount);
		FBuildWorker B(Engine, SuccessCount, InProgressCount);
		FRunnableThread* ThreadA = FRunnableThread::Create(&A, TEXT("ASRequestBuildA"));
		FRunnableThread* ThreadB = FRunnableThread::Create(&B, TEXT("ASRequestBuildB"));
		ThreadA->WaitForCompletion();
		ThreadB->WaitForCompletion();
		delete ThreadA;
		delete ThreadB;

		ASSERT_THAT(AreEqual(1, SuccessCount.load()));
		ASSERT_THAT(AreEqual(1, InProgressCount.load()));
		Engine->BuildCompleted();
		ASSERT_THAT(AreEqual(0, Engine->RequestBuild()));
		Engine->BuildCompleted();
	}
};
#endif
```

Expected **before** A0: both threads may see `isBuilding == false` and both return `0` (FAIL). After A0: PASS.

### A0 Standalone CTest sketch

File: `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneConcurrentTypeRegistrationTests.cpp`

Wire in `CMakeLists.txt` next to Compat tests:

```cmake
add_executable(
	AngelscriptStandaloneConcurrentTypeRegistrationTests
	"${CMAKE_CURRENT_LIST_DIR}/Tests/AngelscriptStandaloneConcurrentTypeRegistrationTests.cpp"
)
target_compile_features(AngelscriptStandaloneConcurrentTypeRegistrationTests PRIVATE cxx_std_20)
target_include_directories(
	AngelscriptStandaloneConcurrentTypeRegistrationTests
	PRIVATE
		"${CMAKE_CURRENT_LIST_DIR}/Compat"
		"${ANGELSCRIPT_RUNTIME_ROOT}/Core"
		"${ANGELSCRIPT_FORK_ROOT}"
)
target_link_libraries(
	AngelscriptStandaloneConcurrentTypeRegistrationTests
	PRIVATE
		AngelscriptMaintainedFork
)
add_test(
	NAME AngelscriptStandalone.ConcurrentTypeRegistration
	COMMAND AngelscriptStandaloneConcurrentTypeRegistrationTests
)
set_tests_properties(
	AngelscriptStandalone.ConcurrentTypeRegistration
	PROPERTIES LABELS "standalone;compat;concurrency"
)
```

Use `asCreateScriptEngine()`, `std::thread`, `asCScriptEngine*` cast for `RequestBuild` (include `as_scriptengine.h`). Same assertions as the native test.

### A0 verification

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-mt-a0-build -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Engine.ConcurrentTypeRegistration" -Label as-mt-a0-reg -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label as-mt-a0-sdk -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -Label as-mt-a0-standalone
```

Expected after A0: `RequestBuildFromTwoThreads` PASS; SDK prefix still PASS; Standalone previous tests plus new CTest PASS. Concurrent `RegisterObjectType` tests (A1) still FAIL until A1.

Do **not** restore `asCContext::Suspend`/`Abort` in A0 unless a separate later slice needs Execute-from-timeout.

---

## Scheme A1 — type-registration window

### A1 public API (add at end of `asIScriptEngine`, before `protected: virtual ~asIScriptEngine()`)

In `Core/angelscript.h` and `as_scriptengine.h`:

```cpp
virtual int BeginConcurrentTypeRegistration() = 0;
virtual int EndConcurrentTypeRegistration() = 0;
```

Implementation:

```cpp
int asCScriptEngine::BeginConcurrentTypeRegistration()
{
	ACQUIREEXCLUSIVE(engineRWLock);
	if (isBuilding)
	{
		RELEASEEXCLUSIVE(engineRWLock);
		return asBUILD_IN_PROGRESS;
	}
	if (concurrentTypeRegistrationOpen)
	{
		RELEASEEXCLUSIVE(engineRWLock);
		return asINVALID_CONFIGURATION;
	}
	concurrentTypeRegistrationOpen = true;
	RELEASEEXCLUSIVE(engineRWLock);
	return asSUCCESS;
}

int asCScriptEngine::EndConcurrentTypeRegistration()
{
	ACQUIREEXCLUSIVE(engineRWLock);
	if (!concurrentTypeRegistrationOpen)
	{
		RELEASEEXCLUSIVE(engineRWLock);
		return asINVALID_CONFIGURATION;
	}
	concurrentTypeRegistrationOpen = false;
	RELEASEEXCLUSIVE(engineRWLock);
	return asSUCCESS;
}
```

Member on `asCScriptEngine`: `bool concurrentTypeRegistrationOpen = false;`

`RequestBuild` while the window is open: return `asINVALID_CONFIGURATION` (do not set `isBuilding`). `CreateContext` / method / funcdef / property / behaviour / global function / `RegisterEnumValue` while open: `ConfigError(asINVALID_CONFIGURATION, ...)`.

### A1 intern helper

```cpp
// as_scriptengine.h (internal)
int InternRegisteredType(asCTypeInfo* type, asSNameSpace* ns); // exclusive lock held by caller
int AssignTypeIdLocked(asCTypeInfo* type) const; // exclusive; typeIdSeqNbr++ and map Add
```

`AssignTypeIdLocked` is the body currently at `GetTypeIdFromDataType` ~5032–5040, minus the DCL. `GetTypeIdFromDataType` DCL calls it. Register paths call it after insert so application types are not left at `-1`.

`RegisterObjectType` (non-template) shape:

```cpp
int asCScriptEngine::RegisterObjectType(const char *name, int byteSize, asQWORD flags)
{
	// existing flag/name validation — no shared writes
	asSNameSpace* const ns = defaultNamespace; // snapshot before lock
	asCBuilder bld(this, 0);
	// ParseTemplateDecl / token checks that do not look up registered tables may happen here

	ACQUIREEXCLUSIVE(engineRWLock);
	if (GetRegisteredType(typeName, ns))
	{
		RELEASEEXCLUSIVE(engineRWLock);
		return asALREADY_REGISTERED;
	}
	// CheckNameConflict using ns; asNEW; fill type->nameSpace = ns;
	allRegisteredTypes.Add(type);
	allRegisteredTypesByName.Add(type);
	registeredObjTypes.PushLast(type);
	const int typeId = AssignTypeIdLocked(type);
	RELEASEEXCLUSIVE(engineRWLock);
	return typeId;
}
```

If `ParseDataType` / `CheckNameConflict` must read tables, keep them **inside** the exclusive section (A1: short critical section is secondary to correctness). Template and specialization branches: entire intern exclusive.

`SetDefaultNamespace`: take exclusive for the pointer swap (always, not only during the window).

`RegisterEnum` (~5993), `RegisterInterface`, `RegisterTypedef`: same uniqueness + insert + `AssignTypeIdLocked` under exclusive; push `registeredEnums` / interface obj types / `registeredTypeDefs` as today.

### A1 tests (same native file + Standalone CTest)

Add methods after the window API exists. First add the virtuals returning `asNOT_SUPPORTED` if you need a compiling failing test; then implement.

```cpp
TEST_METHOD(RegistersTwoTypesFromWorkerThreads)
{
	using namespace AngelscriptNativeTestSupport;
	asIScriptEngine* const Engine = CreateNativeEngine(&Messages);
	ON_SCOPE_EXIT { DestroyNativeEngine(Engine); };
	ASSERT_THAT(AreEqual(asSUCCESS, Engine->BeginConcurrentTypeRegistration()));

	std::atomic<int> IdA{-1};
	std::atomic<int> IdB{-1};
	// two FRunnable workers:
	//   IdA = Engine->RegisterObjectType("ConcurrentTypeA", 4, asOBJ_VALUE | asOBJ_POD | asOBJ_APP_PRIMITIVE);
	//   IdB = Engine->RegisterObjectType("ConcurrentTypeB", 4, asOBJ_VALUE | asOBJ_POD | asOBJ_APP_PRIMITIVE);
	// join
	ASSERT_THAT(IsTrue(IdA.load() >= 0 && IdB.load() >= 0 && IdA.load() != IdB.load()));
	ASSERT_THAT(IsTrue(Engine->GetTypeInfoByName("ConcurrentTypeA") != nullptr));
	ASSERT_THAT(IsTrue(Engine->GetTypeInfoByName("ConcurrentTypeB") != nullptr));
	ASSERT_THAT(AreEqual(asSUCCESS, Engine->EndConcurrentTypeRegistration()));
}

TEST_METHOD(DuplicateNameFromTwoThreads)
{
	// both RegisterObjectType("ConcurrentDup", 4, asOBJ_VALUE | asOBJ_POD | asOBJ_APP_PRIMITIVE)
	// exactly one >= 0, one == asALREADY_REGISTERED
	// GetTypeInfoByName("ConcurrentDup") non-null once
}

TEST_METHOD(MethodRegisterRejectedDuringWindow)
{
	Engine->BeginConcurrentTypeRegistration();
	const int Result = Engine->RegisterObjectMethod("ConcurrentTypeA", "void F()", asFUNCTION(Dummy), asCALL_CDECL);
	ASSERT_THAT(AreEqual(asINVALID_CONFIGURATION, Result));
}

TEST_METHOD(BeginRejectedWhileBuilding)
{
	asCScriptEngine* Engine = CreateBareSdkEngine(this);
	ASSERT_THAT(AreEqual(0, Engine->RequestBuild()));
	ASSERT_THAT(AreEqual(asBUILD_IN_PROGRESS, Engine->BeginConcurrentTypeRegistration()));
	Engine->BuildCompleted();
}
```

`CreateNativeEngine` needs a `FNativeMessageCollector Messages` like other native tests — copy the collector local from an existing Engine test that compiles a module if `RegistersTwoTypes` needs a callback; `CreateBareSdkEngine` is enough if `RegisterObjectType` does not emit messages.

POD flags: follow existing fork usage. Compat CTest already uses `RegisterObjectType("FCompatRawObject", 0, asOBJ_REF | asOBJ_NOCOUNT)`. Value types **must** have non-zero size (`as_scriptengine.cpp:1940`). Use size `4` + `asOBJ_VALUE | asOBJ_POD | asOBJ_APP_PRIMITIVE`.

### A1 verification

Same prefix as A0 plus Standalone `AngelscriptStandalone.ConcurrentTypeRegistration`. Expected: all A1 scenarios PASS. Full SDK prefix PASS. Do **not** enable CallBinds ParallelFor.

---

## Scheme A2 — template intern + ParallelFor bytecode

### A2 `AllocateFunction`

Grep `GetNextScriptFunctionId` and `AddScriptFunction` in `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/`. Every peek-then-add pair becomes:

```cpp
int asCScriptEngine::AllocateFunction(asCScriptFunction* func)
{
	// Precondition: caller holds exclusive engineRWLock
	if (func == nullptr) return asINVALID_ARG;
	if (freeScriptFunctionIds.GetLength())
	{
		func->id = freeScriptFunctionIds[freeScriptFunctionIds.GetLength() - 1];
		freeScriptFunctionIds.PopLast();
		asASSERT(scriptFunctions[func->id] == 0 || scriptFunctions[func->id] == func);
		scriptFunctions[func->id] = func;
		return func->id;
	}
	func->id = (int)scriptFunctions.GetLength();
	scriptFunctions.PushLast(func);
	return func->id;
}
```

Leave `GetNextScriptFunctionId` as a private wrapper that asserts the exclusive lock in non-shipping, or delete it once call sites are gone. Do **not** drop hole reuse in this change.

Serial GenerateFunctions can take exclusive around `AllocateFunction` only (short), or hold it for the whole add. Prefer short.

### A2 `GetTemplateInstanceType`

File: `as_scriptengine.cpp:3385`.

```text
ACQUIRESHARED(engineRWLock)
lookup templateInstanceBuckets
if hit: RELEASESHARED; return existing (unless isInvalidGeneratedType)
RELEASESHARED
ACQUIREEXCLUSIVE(engineRWLock)
lookup again
if hit: RELEASEEXCLUSIVE; return
// existing create path, but every AddScriptFunction → AllocateFunction
insert bucket
RELEASEEXCLUSIVE
return ot
```

Do not hold shared while creating (would block writers incorrectly if upgraded in place). Always drop shared then exclusive + double-check.

### A2 native test

File: `AngelscriptCompileInternTests.cpp`

Prefix: `Angelscript.TestModule.AngelScriptSDK.Engine.CompileIntern`

Register a template `array<T>` as `asOBJ_REF | asOBJ_TEMPLATE | asOBJ_NOCOUNT` with name `"array<class T>"` (this is what `ParseTemplateDecl` expects — copy a working RegisterObjectType template call from addon `scriptarray` if the dummy fails). Then two threads:

```cpp
asCArray<asCDataType> SubA; SubA.PushLast(asCDataType::CreatePrimitive(ttInt, false));
asCArray<asCDataType> SubB; SubB.PushLast(asCDataType::CreatePrimitive(ttFloat32, false));
asCObjectType* InstA = Engine->GetTemplateInstanceType(TemplateType, SubA, nullptr);
asCObjectType* InstB = Engine->GetTemplateInstanceType(TemplateType, SubB, nullptr);
```

Distinct subtypes → distinct pointers. Same subtype from two threads → same pointer.

If registering a dummy template is too coupled to subtype factory stubs, skip to a Standalone native-runtime compile of two modules that each use `array<int>` / `array<float>` **after** StdLib is registered (`AngelscriptStandaloneStdLib.cpp` already does this for runtime tests). Prefer a native SDK test that does not need UObject.

### A2 host ParallelFor

`AngelscriptEngine.cpp` ~6232 serial loop calls `CompileModule_Code_Stage3` which does `BuildCompileCode`, deletes builder, `JITCompile`.

Split:

```cpp
void FAngelscriptEngine::CompileModule_BytecodeOnly(...)
{
	ScriptModule->builder->BuildCompileCode();
}

void FAngelscriptEngine::CompileModule_JitAndDisposeBuilder(...)
{
	asDELETE(ScriptModule->builder, asCBuilder);
	ScriptModule->builder = nullptr;
	ScriptModule->JITCompile();
}
```

```cpp
static TAutoConsoleVariable<int32> CVarAsCompileParallelBytecode(
	TEXT("as.Compile.ParallelBytecode"),
	0,
	TEXT("If 1, ParallelFor BuildCompileCode across modules in stage3. Requires template intern lock."),
	ECVF_Default);
```

When cvar is 0: keep today’s serial `CompileModule_Code_Stage3` (behavior-preserving).

When cvar is 1: `ParallelFor(CompiledModules.Num(), ..., EParallelForFlags::Unbalanced)` of `CompileModule_BytecodeOnly`, then serial `CompileModule_JitAndDisposeBuilder`. Skip modules with `bCompileError` / `bLoadedPrecompiledCode` as today.

Diagnostics (hard prerequisite, same A2 slice):

- Host `bHadCompileErrors`: `std::atomic<bool>` or `FPlatformAtomics` store; Parse workers already race the plain `bool` today — fix for both Parse and bytecode.
- `asCScriptEngine::WriteMessage`: exclusive lock around callback invoke **or** a message mutex. `preMessage` must not be written from two bytecode workers; if `CompileFunctions` still uses `engine->preMessage.isSet = false`, take the same lock or stop using the singleton from workers.

Do **not** ParallelFor `CompileFunctions` inside one builder in this change.

### A2 verification

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Engine.CompileIntern" -Label as-mt-a2-intern -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label as-mt-a2-sdk -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -Label as-mt-a2-standalone
```

Host ParallelFor: leave cvar at 0 for the default verification gate. Enabling it is a separate measured run (ForceClean / cache miss) watching `script compilation stage3` vs parse timers. Do not flip the default to 1 in this change.

---

## Out of this change (do not implement)

| Approach | Trigger to schedule later |
|---|---|
| **B** two-pass intern all templates then read-only bytecode | Insights: intern exclusive > ~15% of stage3 wall with cvar on |
| **C** sharded maps / lock-free `asCArray` | Same, after B is rejected |
| `ParallelFor(CallBinds)` | After A1 is green; separate host change |
| Restore `Suspend`/`Abort` | Execute-from-timeout / debug; not A1 |
| Overlapping full `Build()` | Never the first compile-parallel shape |

---

## Spec coverage

| Spec requirement | Plan section |
|---|---|
| Real RW/critical macros; Standalone threads on | A0 |
| Linearizable `RequestBuild` | A0 |
| Lazy type-id DCL | A0 |
| Public thread C APIs link | A0 `as_thread.cpp` + Standalone ThreadCompat |
| Registration window begin/end | A1 |
| Unique published type ids | A1 `AssignTypeIdLocked` |
| Duplicate name linearizable | A1 exclusive uniqueness |
| Namespace snapshot | A1 `ns` snapshot + locked `SetDefaultNamespace` |
| Native + Standalone concurrent register tests | A1 |
| Template intern linearizable | A2 `GetTemplateInstanceType` |
| `AllocateFunction` | A2 |
| Opt-in ParallelFor bytecode | A2 host cvar |
| Diagnostics without races | A2 diagnostics |
