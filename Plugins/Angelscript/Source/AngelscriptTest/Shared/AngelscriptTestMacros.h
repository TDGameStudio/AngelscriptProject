#pragma once

#include "AngelscriptTestUtilities.h"
#include "AngelscriptTestEnginePool.h"
#include "AngelscriptTestEngineHelper.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// ============================================================================
// Angelscript Test Macros
// ============================================================================
//
// Engine Creation:
//   ASTEST_CREATE_ENGINE()       — shared engine, reset to clean state
//   ASTEST_GET_ENGINE()          — shared engine, no reset (use in TEST_METHOD)
//   ASTEST_CREATE_ENGINE_FULL()  — fresh isolated full engine
//   ASTEST_CREATE_ENGINE_NATIVE()— raw asIScriptEngine* from SDK
//
// Engine Reset:
//   ASTEST_RESET_ENGINE(Engine)  — reset shared engine (use in AFTER_ALL)
//
// CQTest standard pattern:
//   BEFORE_ALL()  { ASTEST_CREATE_ENGINE(); }
//   TEST_METHOD() { FAngelscriptEngine& Engine = ASTEST_GET_ENGINE(); ... }
//   AFTER_ALL()   { FAngelscriptEngine& E = ASTEST_GET_ENGINE(); ASTEST_RESET_ENGINE(E); }
// ============================================================================

// ============================================================================
// Engine Creation Macros
// ============================================================================

// CREATE - Acquires the shared engine after resetting it to a clean state.
// Use for: first-time acquisition in BEFORE_ALL, or standalone tests needing
//          a guaranteed clean shared engine.
// Returns: FAngelscriptEngine&
#define ASTEST_CREATE_ENGINE() \
	AngelscriptTestSupport::AcquireCleanSharedCloneEngine()

// GET - Acquires the shared engine without resetting.
// Use for: TEST_METHOD bodies where the engine was already cleaned by
//          BEFORE_ALL / ASTEST_CREATE_ENGINE(). Pair with FCoverageModuleScope
//          for per-test module isolation.
// Returns: FAngelscriptEngine&
#define ASTEST_GET_ENGINE() \
	AngelscriptTestSupport::GetOrCreateSharedCloneEngine()

// FULL - Creates a fresh isolated Full engine each time.
// Use for: engine core self-tests, bind environment testing, hot-reload tests.
// Returns: FAngelscriptEngine&
#define ASTEST_CREATE_ENGINE_FULL() \
	(*[this]() -> TUniquePtr<FAngelscriptEngine>& { \
		static thread_local TUniquePtr<FAngelscriptEngine> _FullEngine; \
		_FullEngine = AngelscriptTestSupport::CreateIsolatedFullEngine(); \
		check(_FullEngine.IsValid()); \
		return _FullEngine; \
	}())

// NATIVE - Raw asIScriptEngine from the AngelScript SDK.
// Use for: testing AngelScript SDK APIs directly.
// Returns: asIScriptEngine*
#define ASTEST_CREATE_ENGINE_NATIVE() \
	asCreateScriptEngine(ANGELSCRIPT_VERSION)

// ============================================================================
// Engine Reset Macro
// ============================================================================

// RESET - Resets the shared engine to a clean state.
// Use for: AFTER_ALL / AFTER_EACH to leave the shared engine clean for
//          subsequent test classes.
#define ASTEST_RESET_ENGINE(Engine) \
	AngelscriptTestSupport::ResetSharedCloneEngine(Engine)

// ============================================================================
// Helper Macros: Compile + Execute shortcuts
// ============================================================================

// Compile module + get function + execute int, return false on any failure.
// Requires: *this is FAutomationTestBase, Engine is FAngelscriptEngine&
#define ASTEST_COMPILE_RUN_INT(Engine, ModuleName, Source, FuncDecl, OutResult) \
	do { \
		asIScriptModule* _Module = AngelscriptTestSupport::BuildModule( \
			*this, Engine, ModuleName, Source); \
		if (_Module == nullptr) { return false; } \
		asIScriptFunction* _Function = AngelscriptTestSupport::GetFunctionByDecl( \
			*this, *_Module, FuncDecl); \
		if (_Function == nullptr) { return false; } \
		if (!AngelscriptTestSupport::ExecuteIntFunction( \
			*this, Engine, *_Function, OutResult)) { return false; } \
	} while (false)

// Same as above but for int64 return type.
#define ASTEST_COMPILE_RUN_INT64(Engine, ModuleName, Source, FuncDecl, OutResult) \
	do { \
		asIScriptModule* _Module = AngelscriptTestSupport::BuildModule( \
			*this, Engine, ModuleName, Source); \
		if (_Module == nullptr) { return false; } \
		asIScriptFunction* _Function = AngelscriptTestSupport::GetFunctionByDecl( \
			*this, *_Module, FuncDecl); \
		if (_Function == nullptr) { return false; } \
		if (!AngelscriptTestSupport::ExecuteInt64Function( \
			*this, Engine, *_Function, OutResult)) { return false; } \
	} while (false)

// Compile only (no execution). Sets OutModulePtr, returns false on failure.
#define ASTEST_BUILD_MODULE(Engine, ModuleName, Source, OutModulePtr) \
	do { \
		OutModulePtr = AngelscriptTestSupport::BuildModule( \
			*this, Engine, ModuleName, Source); \
		if (OutModulePtr == nullptr) { return false; } \
	} while (false)
