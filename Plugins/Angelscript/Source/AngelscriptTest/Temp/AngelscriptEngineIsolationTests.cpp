#include "AngelscriptEngine.h"
#include "AngelscriptGameInstanceSubsystem.h"
#include "AngelscriptBinds.h"
#include "AngelscriptBindDatabase.h"
#include "Binds/Helper_ToString.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/ScopeExit.h"
#include "Curves/CurveFloat.h"
#include "UObject/UObjectGlobals.h"

#include "AngelscriptInclude.h"

#if WITH_DEV_AUTOMATION_TESTS

struct FAngelscriptEngineIsolationTestAccess
{
	static bool DestroyGlobalEngine()
	{
		return FAngelscriptEngine::DestroyGlobal();
	}

	static int32 GetToStringCount(const FAngelscriptEngine& Engine)
	{
		return Engine.GetToStringEntryCountForTesting();
	}

	static int32 GetBindDatabaseClassCount(const FAngelscriptEngine& Engine)
	{
		return Engine.GetBindDatabaseForTesting().Classes.Num();
	}

	static int32 GetLocalPooledContextCount(asIScriptEngine* ScriptEngine)
	{
		return FAngelscriptEngine::GetLocalPooledContextCountForTesting(ScriptEngine);
	}

	static asIScriptContext* GetActiveContext()
	{
		// Uses the AS public SDK accessor so this test can link from outside the Runtime DLL.
		return asGetActiveContext();
	}
};

struct FIsolationContextStackGuard
{
	TArray<FAngelscriptEngine*> SavedStack;
	FIsolationContextStackGuard()
	{
		SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
	}
	~FIsolationContextStackGuard()
	{
		FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
	}
};

static void ResetIsolationRuntime()
{
	if (!UAngelscriptGameInstanceSubsystem::HasAnyTickOwner() && FAngelscriptEngine::IsInitialized())
	{
		FAngelscriptEngineIsolationTestAccess::DestroyGlobalEngine();
	}
}

static FString MakeIsolationName(const TCHAR* Prefix)
{
	return FString::Printf(TEXT("%s_%s"), Prefix, *FGuid::NewGuid().ToString(EGuidFormats::Digits));
}

// FAngelscriptPooledContextBase::operator->() returns asCContext* (incomplete here because
// <source/as_context.h> is intentionally not pulled into this test). asCContext inherits from
// asIScriptContext, and reinterpret_cast between pointer types is well-defined in C++ without
// requiring a complete type, so we use this helper to reach the public AS interface.
static FORCEINLINE asIScriptContext* ScriptContextOf(const FAngelscriptPooledContextBase& Pooled)
{
	return reinterpret_cast<asIScriptContext*>(Pooled.operator->());
}

static asIScriptFunction* CompileIsolationFunction(
	FAutomationTestBase& Test,
	FAngelscriptEngine& Engine,
	const FString& ModuleName,
	const ANSICHAR* Source,
	const ANSICHAR* Declaration)
{
	FAngelscriptEngineScope GlobalScope(Engine);

	asIScriptModule* Module = Engine.GetScriptEngine()->GetModule(TCHAR_TO_ANSI(*ModuleName), asGM_ALWAYS_CREATE);
	if (!Test.TestNotNull(*FString::Printf(TEXT("Isolation helper should create module '%s'"), *ModuleName), Module))
	{
		return nullptr;
	}

	asIScriptFunction* Function = nullptr;
	const int32 CompileResult = Module->CompileFunction(TCHAR_TO_ANSI(*ModuleName), Source, 0, 0, &Function);
	if (!Test.TestEqual(*FString::Printf(TEXT("Isolation helper should compile '%s'"), *ModuleName), CompileResult, asSUCCESS))
	{
		return nullptr;
	}

	Test.TestNotNull(*FString::Printf(TEXT("Isolation helper should resolve '%s'"), ANSI_TO_TCHAR(Declaration)), Function);
	return Function;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptContextStackScopedResolutionTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.ContextStack.ScopedResolution",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineScopeRestoresWorldContextTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.EngineScope.RestoresWorldContext",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFullEnginesKeepStateSeparateTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.SharedState.FullEnginesKeepStateSeparate",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCloneSharesSourceStateTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.SharedState.CloneSharesSourceState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMultipleFullEnginesCanCoexistTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.MultiFull.CanCoexist",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRequestContextUsesRequestedEngineTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.ContextPool.RequestContextUsesRequestedEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRequestContextReusedStartsUnpreparedTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.ContextPool.RequestContextReusedStartsUnprepared",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRequestContextAfterReturningUnpreparedScopedContextTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.ContextPool.RequestContextAfterReturningUnpreparedScopedContext",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFullEngineCreateClearsThreadLocalPoolTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.ContextPool.FullEngineCreateClearsThreadLocalPool",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptContextPoolResetSequenceKeepsRequestedContextReusableTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.ContextPool.Sequence.FullEngineCreateThenRequestContextAfterReturningUnpreparedScopedContext",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScopedPooledContextUsesScopedEngineTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.ContextPool.ScopedPooledContextUsesScopedEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptReusedPooledContextStartsUnpreparedTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.ContextPool.ReusedContextStartsUnprepared",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptContextStackScopedResolutionTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();
	FIsolationContextStackGuard StackGuard;

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> PrimaryEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> SecondaryEngine = FAngelscriptEngine::CreateCloneFrom(*PrimaryEngine, Config);

	if (!TestNotNull(TEXT("Context stack scoped resolution should create a primary engine"), PrimaryEngine.Get())
		|| !TestNotNull(TEXT("Context stack scoped resolution should create a secondary engine"), SecondaryEngine.Get()))
	{
		return false;
	}

	TestTrue(TEXT("Context stack should start empty after guard clears it"), FAngelscriptEngineContextStack::IsEmpty());

	{
		FAngelscriptEngineScope PrimaryScope(*PrimaryEngine);
		TestTrue(TEXT("Scoped resolution should return the primary engine while its scope is active"), &FAngelscriptEngine::Get() == PrimaryEngine.Get());
		TestTrue(TEXT("Context stack should expose the active primary engine"), FAngelscriptEngineContextStack::Peek() == PrimaryEngine.Get());

		{
			FAngelscriptEngineScope SecondaryScope(*SecondaryEngine);
			TestTrue(TEXT("Nested scoped resolution should prefer the nested engine"), &FAngelscriptEngine::Get() == SecondaryEngine.Get());
			TestTrue(TEXT("Context stack should update its top entry for nested scopes"), FAngelscriptEngineContextStack::Peek() == SecondaryEngine.Get());
		}

		TestTrue(TEXT("Nested scope teardown should restore the previous engine"), &FAngelscriptEngine::Get() == PrimaryEngine.Get());
		TestTrue(TEXT("Context stack should restore the previous engine after nested scope teardown"), FAngelscriptEngineContextStack::Peek() == PrimaryEngine.Get());
	}

	return TestTrue(TEXT("Context stack should be empty after all scopes leave"), FAngelscriptEngineContextStack::IsEmpty());
}

bool FAngelscriptEngineScopeRestoresWorldContextTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> PrimaryEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> SecondaryEngine = FAngelscriptEngine::CreateCloneFrom(*PrimaryEngine, Config);

	if (!TestNotNull(TEXT("Engine scope restore test should create a primary engine"), PrimaryEngine.Get())
		|| !TestNotNull(TEXT("Engine scope restore test should create a secondary engine"), SecondaryEngine.Get()))
	{
		return false;
	}

	UObject* OuterContext = NewObject<UCurveFloat>();
	UObject* InnerContext = NewObject<UCurveFloat>();
	if (!TestNotNull(TEXT("Engine scope restore test should create an outer context object"), OuterContext)
		|| !TestNotNull(TEXT("Engine scope restore test should create an inner context object"), InnerContext))
	{
		return false;
	}

	{
		FAngelscriptEngineScope OuterScope(*PrimaryEngine, OuterContext);
		TestTrue(TEXT("Outer scope should expose its world context through the active engine"), PrimaryEngine->GetCurrentWorldContextObject() == OuterContext);

		{
			FAngelscriptEngineScope InnerScope(*SecondaryEngine, InnerContext);
			TestTrue(TEXT("Inner scope should expose its world context through the nested engine"), SecondaryEngine->GetCurrentWorldContextObject() == InnerContext);
		}

		TestTrue(TEXT("Leaving the inner scope should restore the outer world context"), PrimaryEngine->GetCurrentWorldContextObject() == OuterContext);
	}

	return TestNull(TEXT("Leaving the outer scope should clear the world context"), PrimaryEngine->GetCurrentWorldContextObject());
}

bool FAngelscriptFullEnginesKeepStateSeparateTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);

	if (!TestNotNull(TEXT("Full engine isolation test should create engine A"), EngineA.Get())
		|| !TestNotNull(TEXT("Full engine isolation test should create engine B"), EngineB.Get()))
	{
		return false;
	}

	const FString AliasName = MakeIsolationName(TEXT("Alias"));
	const FString ToStringName = MakeIsolationName(TEXT("ToString"));
	FAngelscriptClassBind BindClass;
	BindClass.TypeName = MakeIsolationName(TEXT("BindDb"));
	int32 BaselineToStringCountA = 0;
	int32 BaselineBindDatabaseClassCountA = 0;
	int32 BaselineToStringCountB = 0;
	int32 BaselineBindDatabaseClassCountB = 0;

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		BaselineToStringCountA = FAngelscriptEngineIsolationTestAccess::GetToStringCount(*EngineA);
		BaselineBindDatabaseClassCountA = FAngelscriptEngineIsolationTestAccess::GetBindDatabaseClassCount(*EngineA);
	}

	{
		FAngelscriptEngineScope ScopeB(*EngineB);
		BaselineToStringCountB = FAngelscriptEngineIsolationTestAccess::GetToStringCount(*EngineB);
		BaselineBindDatabaseClassCountB = FAngelscriptEngineIsolationTestAccess::GetBindDatabaseClassCount(*EngineB);
	}

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		TSharedPtr<FAngelscriptType> IntType = FAngelscriptType::GetByAngelscriptTypeName(TEXT("int"));
		if (!TestTrue(TEXT("Full engine isolation test should resolve the built-in int type inside engine A"), IntType.IsValid()))
		{
			return false;
		}

		FAngelscriptType::RegisterAlias(AliasName, IntType.ToSharedRef());
		FAngelscriptBinds::AddSkipEntry(FName(TEXT("EngineIsolationActor")), FName(TEXT("OnlyEngineA")));
		FToStringHelper::Register(ToStringName, +[](void*, FString& OutString)
		{
			OutString = TEXT("EngineA");
		});
		FAngelscriptBindDatabase::Get().Classes.Add(BindClass);
	}

	{
		FAngelscriptEngineScope ScopeB(*EngineB);
		TestNull(TEXT("Engine B should not see aliases registered through engine A"), FAngelscriptType::GetByAngelscriptTypeName(AliasName).Get());
		TestFalse(TEXT("Engine B should not inherit skip entries registered through engine A"), FAngelscriptBinds::CheckForSkipEntry(FName(TEXT("EngineIsolationActor")), FName(TEXT("OnlyEngineA"))));
		TestEqual(TEXT("Engine B should keep its original ToString registry baseline"), FAngelscriptEngineIsolationTestAccess::GetToStringCount(*EngineB), BaselineToStringCountB);
		TestEqual(TEXT("Engine B should keep its original bind database baseline"), FAngelscriptEngineIsolationTestAccess::GetBindDatabaseClassCount(*EngineB), BaselineBindDatabaseClassCountB);
	}

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		TestNotNull(TEXT("Engine A should keep its alias registration"), FAngelscriptType::GetByAngelscriptTypeName(AliasName).Get());
		TestTrue(TEXT("Engine A should keep its skip entry registration"), FAngelscriptBinds::CheckForSkipEntry(FName(TEXT("EngineIsolationActor")), FName(TEXT("OnlyEngineA"))));
		TestEqual(TEXT("Engine A should retain its extra ToString registry entry"), FAngelscriptEngineIsolationTestAccess::GetToStringCount(*EngineA), BaselineToStringCountA + 1);
		TestEqual(TEXT("Engine A should retain its extra bind database class"), FAngelscriptEngineIsolationTestAccess::GetBindDatabaseClassCount(*EngineA), BaselineBindDatabaseClassCountA + 1);
	}

	return true;
}

bool FAngelscriptCloneSharesSourceStateTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("Clone shared-state test should create a source engine"), SourceEngine.Get()))
	{
		return false;
	}

	const FString AliasName = MakeIsolationName(TEXT("CloneAlias"));
	{
		FAngelscriptEngineScope SourceScope(*SourceEngine);
		TSharedPtr<FAngelscriptType> IntType = FAngelscriptType::GetByAngelscriptTypeName(TEXT("int"));
		if (!TestTrue(TEXT("Clone shared-state test should resolve the built-in int type inside the source engine"), IntType.IsValid()))
		{
			return false;
		}

		FAngelscriptType::RegisterAlias(AliasName, IntType.ToSharedRef());
		FAngelscriptBinds::AddSkipEntry(FName(TEXT("CloneIsolationActor")), FName(TEXT("SharedSkip")));
		FToStringHelper::Register(MakeIsolationName(TEXT("CloneToString")), +[](void*, FString& OutString)
		{
			OutString = TEXT("CloneShared");
		});
	}

	TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateCloneFrom(*SourceEngine, Config);
	if (!TestNotNull(TEXT("Clone shared-state test should create the clone engine"), CloneEngine.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope CloneScope(*CloneEngine);
		TestNotNull(TEXT("Clone engine should see aliases registered on the source engine"), FAngelscriptType::GetByAngelscriptTypeName(AliasName).Get());
		TestTrue(TEXT("Clone engine should share skip entries with the source engine"), FAngelscriptBinds::CheckForSkipEntry(FName(TEXT("CloneIsolationActor")), FName(TEXT("SharedSkip"))));
		TestTrue(TEXT("Clone engine should inherit the shared ToString registry"), FAngelscriptEngineIsolationTestAccess::GetToStringCount(*CloneEngine) > 0);
	}

	return true;
}

bool FAngelscriptMultipleFullEnginesCanCoexistTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();
	FIsolationContextStackGuard StackGuard;

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);

	if (!TestNotNull(TEXT("Multiple full engines test should create engine A"), EngineA.Get())
		|| !TestNotNull(TEXT("Multiple full engines test should create engine B"), EngineB.Get()))
	{
		return false;
	}

	TestNotEqual(TEXT("Multiple full engines test should create distinct engine wrappers"), EngineA.Get(), EngineB.Get());
	TestNotEqual(TEXT("Multiple full engines test should allocate distinct script engines"), EngineA->GetScriptEngine(), EngineB->GetScriptEngine());
	return TestNull(TEXT("Leaving the test without any engine scope should leave no ambient context engine"), FAngelscriptEngineContextStack::Peek());
}

bool FAngelscriptRequestContextUsesRequestedEngineTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);

	if (!TestNotNull(TEXT("RequestContext isolation test should create engine A"), EngineA.Get())
		|| !TestNotNull(TEXT("RequestContext isolation test should create engine B"), EngineB.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		asIScriptContext* ContextA = EngineA->GetScriptEngine()->RequestContext();
		if (!TestNotNull(TEXT("RequestContext isolation test should acquire a context from engine A"), ContextA))
		{
			return false;
		}

		TestTrue(TEXT("Requested context A should belong to engine A"), ContextA->GetEngine() == EngineA->GetScriptEngine());
		EngineA->GetScriptEngine()->ReturnContext(ContextA);
	}

	{
		FAngelscriptEngineScope ScopeB(*EngineB);
		asIScriptContext* ContextB = EngineB->GetScriptEngine()->RequestContext();
		if (!TestNotNull(TEXT("RequestContext isolation test should acquire a context from engine B"), ContextB))
		{
			return false;
		}

		const bool bMatchesRequestedEngine = TestTrue(
			TEXT("RequestContext should not recycle a context from another engine"),
			ContextB->GetEngine() == EngineB->GetScriptEngine());
		EngineB->GetScriptEngine()->ReturnContext(ContextB);
		return bMatchesRequestedEngine;
	}
}

bool FAngelscriptRequestContextReusedStartsUnpreparedTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("RequestContext reuse test should create an engine"), Engine.Get()))
	{
		return false;
	}

	const FString ModuleName = MakeIsolationName(TEXT("RequestContextReuse"));
	asIScriptFunction* Function = CompileIsolationFunction(*this, *Engine, ModuleName, "void Run() {}", "void Run()");
	if (!TestNotNull(TEXT("RequestContext reuse test should compile its helper function"), Function))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		Function->Release();
	};

	asIScriptContext* SeedRawContext = Engine->GetScriptEngine()->RequestContext();
	if (!TestNotNull(TEXT("RequestContext reuse test should acquire a seed context"), SeedRawContext))
	{
		return false;
	}

	const int32 PrepareResult = SeedRawContext->Prepare(Function);
	const int32 ExecuteResult = PrepareResult == asSUCCESS ? SeedRawContext->Execute() : PrepareResult;
	if (!TestEqual(TEXT("Seed RequestContext should prepare successfully"), PrepareResult, asSUCCESS)
		|| !TestEqual(TEXT("Seed RequestContext should execute successfully"), ExecuteResult, asEXECUTION_FINISHED))
	{
		Engine->GetScriptEngine()->ReturnContext(SeedRawContext);
		return false;
	}

	Engine->GetScriptEngine()->ReturnContext(SeedRawContext);

	asIScriptContext* ReusedContext = Engine->GetScriptEngine()->RequestContext();
	if (!TestNotNull(TEXT("RequestContext reuse test should reacquire a context"), ReusedContext))
	{
		return false;
	}

	const bool bReusedSameContext = TestTrue(
		TEXT("RequestContext reuse test should reacquire the pooled context"),
		ReusedContext == SeedRawContext);
	const bool bStartsUnprepared = TestEqual(
		TEXT("Reused RequestContext should start unprepared after pool reuse"),
		(int32)ReusedContext->GetState(),
		(int32)asEXECUTION_UNINITIALIZED);
	Engine->GetScriptEngine()->ReturnContext(ReusedContext);
	return bReusedSameContext && bStartsUnprepared;
}

bool FAngelscriptRequestContextAfterReturningUnpreparedScopedContextTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("RequestContext after unprepared scoped context test should create an engine"), Engine.Get()))
	{
		return false;
	}

	const FString ModuleName = MakeIsolationName(TEXT("RequestContextAfterUnpreparedScopedContext"));
	asIScriptFunction* Function = CompileIsolationFunction(*this, *Engine, ModuleName, "void Run() {}", "void Run()");
	if (!TestNotNull(TEXT("RequestContext after unprepared scoped context test should compile its helper function"), Function))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		Function->Release();
	};

	asIScriptContext* RequestedContext = nullptr;
	asIScriptContext* ReturnedScopedRawContext = nullptr;
	{
		FAngelscriptEngineScope Scope(*Engine);
		{
			FAngelscriptPooledContextBase UnpreparedContext;
			ReturnedScopedRawContext = ScriptContextOf(UnpreparedContext);
		}

		RequestedContext = Engine->GetScriptEngine()->RequestContext();
		if (!TestNotNull(TEXT("RequestContext after unprepared scoped context test should reacquire a context"), RequestedContext))
		{
			return false;
		}

		const bool bReusedReturnedScopedContext = TestTrue(
			TEXT("RequestContext after unprepared scoped context test should reuse the returned scoped context"),
			RequestedContext == ReturnedScopedRawContext);
		const int32 PrepareResult = RequestedContext->Prepare(Function);
		const int32 ExecuteResult = PrepareResult == asSUCCESS ? RequestedContext->Execute() : PrepareResult;
		Engine->GetScriptEngine()->ReturnContext(RequestedContext);
		return bReusedReturnedScopedContext
			&& TestEqual(TEXT("RequestContext after unprepared scoped context test should prepare successfully"), PrepareResult, asSUCCESS)
			&& TestEqual(TEXT("RequestContext after unprepared scoped context test should execute successfully"), ExecuteResult, asEXECUTION_FINISHED);
	}
}

bool FAngelscriptFullEngineCreateClearsThreadLocalPoolTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("Full engine create pool reset test should create engine A"), EngineA.Get()))
	{
		return false;
	}

	const FString ModuleNameA = MakeIsolationName(TEXT("FullCreatePoolResetA"));
	asIScriptFunction* FunctionA = CompileIsolationFunction(*this, *EngineA, ModuleNameA, "void Run() {}", "void Run()");
	if (!TestNotNull(TEXT("Full engine create pool reset test should compile function A"), FunctionA))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		FunctionA->Release();
	};

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		FAngelscriptPooledContextBase SeedContext;
		asIScriptContext* SeedScriptContext = ScriptContextOf(SeedContext);
		const int32 PrepareResult = SeedScriptContext->Prepare(FunctionA);
		const int32 ExecuteResult = PrepareResult == asSUCCESS ? SeedScriptContext->Execute() : PrepareResult;
		if (!TestEqual(TEXT("Full engine create pool reset test should seed engine A into the local pool"), PrepareResult, asSUCCESS)
			|| !TestEqual(TEXT("Full engine create pool reset test should execute the seeded function"), ExecuteResult, asEXECUTION_FINISHED))
		{
			return false;
		}
	}

	if (!TestTrue(
		TEXT("Full engine create pool reset test should leave a free pooled context for engine A before creating a new full engine"),
		FAngelscriptEngineIsolationTestAccess::GetLocalPooledContextCount(EngineA->GetScriptEngine()) > 0))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("Full engine create pool reset test should create engine B"), EngineB.Get()))
	{
		return false;
	}

	if (!TestEqual(
		TEXT("Creating a new full engine should clear stale free contexts from the thread-local pool"),
		FAngelscriptEngineIsolationTestAccess::GetLocalPooledContextCount(nullptr),
		0))
	{
		return false;
	}

	{
		FAngelscriptEngineScope ScopeB(*EngineB);
		FAngelscriptPooledContextBase FreshContext;
		return TestTrue(
			TEXT("Creating a new full engine should acquire a context bound to that engine"),
			ScriptContextOf(FreshContext)->GetEngine() == EngineB->GetScriptEngine());
	}
}

bool FAngelscriptContextPoolResetSequenceKeepsRequestedContextReusableTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();

	{
		TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
		if (!TestNotNull(TEXT("Sequence test should create engine A"), EngineA.Get()))
		{
			return false;
		}

		const FString ModuleNameA = MakeIsolationName(TEXT("SequenceFullCreatePoolResetA"));
		asIScriptFunction* FunctionA = CompileIsolationFunction(*this, *EngineA, ModuleNameA, "void Run() {}", "void Run()");
		if (!TestNotNull(TEXT("Sequence test should compile function A"), FunctionA))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			FunctionA->Release();
		};

		{
			FAngelscriptEngineScope ScopeA(*EngineA);
			FAngelscriptPooledContextBase SeedContext;
			asIScriptContext* SeedScriptContext = ScriptContextOf(SeedContext);
			const int32 PrepareResult = SeedScriptContext->Prepare(FunctionA);
			const int32 ExecuteResult = PrepareResult == asSUCCESS ? SeedScriptContext->Execute() : PrepareResult;
			if (!TestEqual(TEXT("Sequence test should seed engine A into the local pool"), PrepareResult, asSUCCESS)
				|| !TestEqual(TEXT("Sequence test should execute the seeded function"), ExecuteResult, asEXECUTION_FINISHED))
			{
				return false;
			}
		}

		if (!TestTrue(
			TEXT("Sequence test should leave a free pooled context for engine A before creating engine B"),
			FAngelscriptEngineIsolationTestAccess::GetLocalPooledContextCount(EngineA->GetScriptEngine()) > 0))
		{
			return false;
		}

		TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
		if (!TestNotNull(TEXT("Sequence test should create engine B"), EngineB.Get()))
		{
			return false;
		}

		if (!TestEqual(
			TEXT("Sequence test should clear stale free contexts when engine B starts"),
			FAngelscriptEngineIsolationTestAccess::GetLocalPooledContextCount(nullptr),
			0))
		{
			return false;
		}

		{
			FAngelscriptEngineScope ScopeB(*EngineB);
			FAngelscriptPooledContextBase FreshContext;
			if (!TestTrue(
				TEXT("Sequence test should acquire a context bound to engine B"),
				ScriptContextOf(FreshContext)->GetEngine() == EngineB->GetScriptEngine()))
			{
				return false;
			}
		}
	}

	if (!TestEqual(
		TEXT("Sequence test should leave no pooled contexts behind after the full-engine phase"),
		FAngelscriptEngineIsolationTestAccess::GetLocalPooledContextCount(nullptr),
		0))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("Sequence test should create the follow-up engine"), Engine.Get()))
	{
		return false;
	}

	const FString ModuleName = MakeIsolationName(TEXT("SequenceRequestContextAfterUnpreparedScopedContext"));
	asIScriptFunction* Function = CompileIsolationFunction(*this, *Engine, ModuleName, "void Run() {}", "void Run()");
	if (!TestNotNull(TEXT("Sequence test should compile the follow-up helper function"), Function))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		Function->Release();
	};

	{
		FAngelscriptEngineScope Scope(*Engine);
		asIScriptContext* ReturnedScopedRawContext = nullptr;
		{
			FAngelscriptPooledContextBase UnpreparedContext;
			ReturnedScopedRawContext = ScriptContextOf(UnpreparedContext);
		}

		asIScriptContext* RequestedContext = Engine->GetScriptEngine()->RequestContext();
		if (!TestNotNull(TEXT("Sequence test should reacquire a context"), RequestedContext))
		{
			return false;
		}

		const bool bReusedReturnedScopedContext = TestTrue(
			TEXT("Sequence test should reuse the returned scoped context"),
			RequestedContext == ReturnedScopedRawContext);
		const bool bContextTargetsCurrentEngine = TestTrue(
			TEXT("Sequence test should reacquire a context for the current engine"),
			RequestedContext->GetEngine() == Engine->GetScriptEngine());
		const int32 PrepareResult = RequestedContext->Prepare(Function);
		const int32 ExecuteResult = PrepareResult == asSUCCESS ? RequestedContext->Execute() : PrepareResult;
		Engine->GetScriptEngine()->ReturnContext(RequestedContext);
		return bReusedReturnedScopedContext
			&& bContextTargetsCurrentEngine
			&& TestEqual(TEXT("Sequence test should prepare successfully"), PrepareResult, asSUCCESS)
			&& TestEqual(TEXT("Sequence test should execute successfully"), ExecuteResult, asEXECUTION_FINISHED);
	}
}

bool FAngelscriptScopedPooledContextUsesScopedEngineTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);

	if (!TestNotNull(TEXT("Scoped pooled context test should create engine A"), EngineA.Get())
		|| !TestNotNull(TEXT("Scoped pooled context test should create engine B"), EngineB.Get()))
	{
		return false;
	}

	const FString ModuleNameA = MakeIsolationName(TEXT("ContextPoolA"));
	const FString ModuleNameB = MakeIsolationName(TEXT("ContextPoolB"));
	asIScriptFunction* FunctionA = CompileIsolationFunction(*this, *EngineA, ModuleNameA, "void Run() {}", "void Run()");
	asIScriptFunction* FunctionB = CompileIsolationFunction(*this, *EngineB, ModuleNameB, "void Run() {}", "void Run()");
	if (!TestNotNull(TEXT("Scoped pooled context test should compile function A"), FunctionA)
		|| !TestNotNull(TEXT("Scoped pooled context test should compile function B"), FunctionB))
	{
		if (FunctionA != nullptr)
		{
			FunctionA->Release();
		}
		if (FunctionB != nullptr)
		{
			FunctionB->Release();
		}
		return false;
	}

	ON_SCOPE_EXIT
	{
		FunctionA->Release();
		FunctionB->Release();
	};

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		FAngelscriptPooledContextBase SeedContext;
		asIScriptContext* SeedScriptContext = ScriptContextOf(SeedContext);
		const int32 SeedPrepareResult = SeedScriptContext->Prepare(FunctionA);
		if (!TestEqual(TEXT("Scoped pooled context test should seed engine A into the local pool"), SeedPrepareResult, asSUCCESS))
		{
			return false;
		}
	}

	{
		FAngelscriptEngineScope ScopeB(*EngineB);
		FAngelscriptPooledContextBase Context;
		asIScriptContext* ScriptContext = ScriptContextOf(Context);
		TestTrue(TEXT("Scoped pooled context should resolve to engine B under engine B scope"), ScriptContext->GetEngine() == EngineB->GetScriptEngine());

		const int32 PrepareResult = ScriptContext->Prepare(FunctionB);
		const int32 ExecuteResult = PrepareResult == asSUCCESS ? ScriptContext->Execute() : PrepareResult;
		TestEqual(TEXT("Scoped pooled context should prepare engine B function successfully"), PrepareResult, asSUCCESS);
		return TestEqual(TEXT("Scoped pooled context should execute engine B function successfully"), ExecuteResult, asEXECUTION_FINISHED);
	}
}

bool FAngelscriptReusedPooledContextStartsUnpreparedTest::RunTest(const FString& Parameters)
{
	ResetIsolationRuntime();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("Reused pooled context test should create an engine"), Engine.Get()))
	{
		return false;
	}

	const FString ModuleName = MakeIsolationName(TEXT("ReusedContext"));
	asIScriptFunction* Function = CompileIsolationFunction(*this, *Engine, ModuleName, "void Run() {}", "void Run()");
	if (!TestNotNull(TEXT("Reused pooled context test should compile its helper function"), Function))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		Function->Release();
	};

	asIScriptContext* SeedRawContext = nullptr;
	{
		FAngelscriptEngineScope Scope(*Engine);

		{
			FAngelscriptPooledContextBase SeedContext;
			SeedRawContext = ScriptContextOf(SeedContext);

			asIScriptContext* SeedScriptContext = ScriptContextOf(SeedContext);
			const int32 PrepareResult = SeedScriptContext->Prepare(Function);
			const int32 ExecuteResult = PrepareResult == asSUCCESS ? SeedScriptContext->Execute() : PrepareResult;
			if (!TestEqual(TEXT("Seed pooled context should prepare successfully"), PrepareResult, asSUCCESS)
				|| !TestEqual(TEXT("Seed pooled context should execute successfully"), ExecuteResult, asEXECUTION_FINISHED))
			{
				return false;
			}
		}

		if (!TestNull(TEXT("Reused pooled context test should clear the thread-local active context before reacquiring"), FAngelscriptEngineIsolationTestAccess::GetActiveContext()))
		{
			return false;
		}

		FAngelscriptPooledContextBase ReusedContext;
		TestTrue(TEXT("Reused pooled context test should reacquire the pooled context"), ScriptContextOf(ReusedContext) == SeedRawContext);
		// Go through the asIScriptContext* handle (obtained via the initial RequestContext call above)
		// instead of FAngelscriptPooledContextBase::operator->() which returns the incomplete asCContext* type.
		asIScriptContext* ReusedScriptContext = SeedRawContext;
		TestEqual(TEXT("Reused pooled context should start unprepared after pool reuse"), (int32)ReusedScriptContext->GetState(), (int32)asEXECUTION_UNINITIALIZED);

		const int32 PrepareResult = ReusedScriptContext->Prepare(Function);
		const int32 ExecuteResult = PrepareResult == asSUCCESS ? ReusedScriptContext->Execute() : PrepareResult;
		TestEqual(TEXT("Reused pooled context should prepare successfully"), PrepareResult, asSUCCESS);
		return TestEqual(TEXT("Reused pooled context should execute successfully"), ExecuteResult, asEXECUTION_FINISHED);
	}
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineLocalFlagsIsolationTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.EngineLocal.FlagsAreInstanceScoped",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEngineLocalFlagsIsolationTest::RunTest(const FString& Parameters)
{
	FIsolationContextStackGuard ContextGuard;

	FAngelscriptEngineConfig ConfigA;
	ConfigA.bSimulateCooked = true;
	ConfigA.bTestErrors = true;
	FAngelscriptEngineDependencies Deps = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateUncompiled(ConfigA, Deps);
	if (!TestNotNull(TEXT("Should create engine A with custom config"), EngineA.Get()))
	{
		return false;
	}

	FAngelscriptEngineConfig ConfigB;
	ConfigB.bSimulateCooked = false;
	ConfigB.bTestErrors = false;
	TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateUncompiled(ConfigB, Deps);
	if (!TestNotNull(TEXT("Should create engine B with different config"), EngineB.Get()))
	{
		return false;
	}

	EngineA->bGeneratePrecompiledData = true;
	EngineB->bGeneratePrecompiledData = false;

	TestTrue(TEXT("Engine A bSimulateCooked should be true"), EngineA->bSimulateCooked);
	TestTrue(TEXT("Engine A bTestErrors should be true"), EngineA->bTestErrors);
	TestFalse(TEXT("Engine B bSimulateCooked should be false"), EngineB->bSimulateCooked);
	TestFalse(TEXT("Engine B bTestErrors should be false"), EngineB->bTestErrors);
	TestTrue(TEXT("Engine A bGeneratePrecompiledData should be true"), EngineA->bGeneratePrecompiledData);
	TestFalse(TEXT("Engine B bGeneratePrecompiledData should be false"), EngineB->bGeneratePrecompiledData);

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		TestTrue(TEXT("IsSimulatingCookedForCurrentContext should reflect engine A"), FAngelscriptEngine::IsSimulatingCookedForCurrentContext());
		TestTrue(TEXT("IsTestingErrorsForCurrentContext should reflect engine A"), FAngelscriptEngine::IsTestingErrorsForCurrentContext());
		TestTrue(TEXT("IsGeneratingPrecompiledData should reflect engine A"), FAngelscriptEngine::IsGeneratingPrecompiledData());
	}
	{
		FAngelscriptEngineScope ScopeB(*EngineB);
		TestFalse(TEXT("IsSimulatingCookedForCurrentContext should reflect engine B"), FAngelscriptEngine::IsSimulatingCookedForCurrentContext());
		TestFalse(TEXT("IsTestingErrorsForCurrentContext should reflect engine B"), FAngelscriptEngine::IsTestingErrorsForCurrentContext());
		TestFalse(TEXT("IsGeneratingPrecompiledData should reflect engine B"), FAngelscriptEngine::IsGeneratingPrecompiledData());
	}

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineLocalTypeDatabaseIsolationTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.EngineLocal.TypeDatabaseIsInstanceScoped",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEngineLocalTypeDatabaseIsolationTest::RunTest(const FString& Parameters)
{
	FIsolationContextStackGuard ContextGuard;

	FAngelscriptEngineConfig Config;
	FAngelscriptEngineDependencies Deps = FAngelscriptEngineDependencies::CreateDefault();

	TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateUncompiled(Config, Deps);
	TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateUncompiled(Config, Deps);
	if (!TestNotNull(TEXT("Should create engine A"), EngineA.Get()) || !TestNotNull(TEXT("Should create engine B"), EngineB.Get()))
	{
		return false;
	}

	int32 TypeCountA = 0;
	int32 TypeCountB = 0;
	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		TypeCountA = FAngelscriptType::GetTypes().Num();
	}
	{
		FAngelscriptEngineScope ScopeB(*EngineB);
		TypeCountB = FAngelscriptType::GetTypes().Num();
	}

	TestTrue(TEXT("Both engines should have their own TypeDatabase with types"), TypeCountA > 0 && TypeCountB > 0);

	EngineA.Reset();

	{
		FAngelscriptEngineScope ScopeB(*EngineB);
		TestTrue(TEXT("Engine B TypeDatabase should survive after engine A destruction"), FAngelscriptType::GetTypes().Num() > 0);
	}

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineLocalBlueprintNamespaceSettingsIsolationTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.EngineLocal.BlueprintNamespaceSettingsAreInstanceScoped",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEngineLocalBlueprintNamespaceSettingsIsolationTest::RunTest(const FString& Parameters)
{
	FIsolationContextStackGuard ContextGuard;

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Deps = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateUncompiled(Config, Deps);
	TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateUncompiled(Config, Deps);
	if (!TestNotNull(TEXT("Namespace isolation should create engine A"), EngineA.Get())
		|| !TestNotNull(TEXT("Namespace isolation should create engine B"), EngineB.Get()))
	{
		return false;
	}

	TArray<FString> EngineAPrefixes = { TEXT("LongBlueprintPrefix"), TEXT("BP") };
	TArray<FString> EngineASuffixes = { TEXT("FunctionLibrary"), TEXT("Lib") };
	TArray<FString> EngineBPrefixes = { TEXT("OtherPrefix") };
	TArray<FString> EngineBSuffixes = { TEXT("OtherSuffix") };
	EngineA->SetBlueprintLibraryNamespaceSettingsForTesting(true, MoveTemp(EngineAPrefixes), MoveTemp(EngineASuffixes));
	EngineB->SetBlueprintLibraryNamespaceSettingsForTesting(false, MoveTemp(EngineBPrefixes), MoveTemp(EngineBSuffixes));

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		const TArray<FString>& Prefixes = FAngelscriptEngine::GetBlueprintLibraryNamespacePrefixesToStripForCurrentContext();
		const TArray<FString>& Suffixes = FAngelscriptEngine::GetBlueprintLibraryNamespaceSuffixesToStripForCurrentContext();
		TestTrue(TEXT("Engine A should use ScriptName metadata for blueprint library namespaces"), FAngelscriptEngine::ShouldUseScriptNameForBlueprintLibraryNamespacesForCurrentContext());
		if (!TestEqual(TEXT("Engine A should keep its own prefix count"), Prefixes.Num(), 2)
			|| !TestEqual(TEXT("Engine A should keep its own suffix count"), Suffixes.Num(), 2))
		{
			return false;
		}
		TestEqual(TEXT("Engine A should sort longer prefixes first"), Prefixes[0], FString(TEXT("LongBlueprintPrefix")));
		TestEqual(TEXT("Engine A should sort longer suffixes first"), Suffixes[0], FString(TEXT("FunctionLibrary")));
	}

	{
		FAngelscriptEngineScope ScopeB(*EngineB);
		const TArray<FString>& Prefixes = FAngelscriptEngine::GetBlueprintLibraryNamespacePrefixesToStripForCurrentContext();
		const TArray<FString>& Suffixes = FAngelscriptEngine::GetBlueprintLibraryNamespaceSuffixesToStripForCurrentContext();
		TestFalse(TEXT("Engine B should keep its own ScriptName namespace toggle"), FAngelscriptEngine::ShouldUseScriptNameForBlueprintLibraryNamespacesForCurrentContext());
		if (!TestEqual(TEXT("Engine B should keep its own prefix count"), Prefixes.Num(), 1)
			|| !TestEqual(TEXT("Engine B should keep its own suffix count"), Suffixes.Num(), 1))
		{
			return false;
		}
		TestEqual(TEXT("Engine B should not inherit engine A prefixes"), Prefixes[0], FString(TEXT("OtherPrefix")));
		TestEqual(TEXT("Engine B should not inherit engine A suffixes"), Suffixes[0], FString(TEXT("OtherSuffix")));
	}

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineLocalStaticNamesIsolationTest,
	"Angelscript.TestModule.CppTests.Engine.Isolation.EngineLocal.StaticNamesAreSharedStateScoped",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEngineLocalStaticNamesIsolationTest::RunTest(const FString& Parameters)
{
	FIsolationContextStackGuard ContextGuard;

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Deps = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateUncompiled(Config, Deps);
	TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateUncompiled(Config, Deps);
	if (!TestNotNull(TEXT("Static-name isolation should create engine A"), EngineA.Get())
		|| !TestNotNull(TEXT("Static-name isolation should create engine B"), EngineB.Get()))
	{
		return false;
	}

	const FName EngineAName(*MakeIsolationName(TEXT("StaticNameA")));
	const FName CloneName(*MakeIsolationName(TEXT("StaticNameClone")));
	int32 EngineANameIndex = INDEX_NONE;
	int32 CloneNameIndex = INDEX_NONE;
	int32 EngineABaselineCount = 0;

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		EngineABaselineCount = FAngelscriptEngine::GetStaticNameCount();
		EngineANameIndex = FAngelscriptEngine::GetOrAddStaticName(EngineAName);
		TestEqual(TEXT("Engine A should append its own static name"), FAngelscriptEngine::GetStaticNameCount(), EngineABaselineCount + 1);

		FName ResolvedName;
		TestTrue(TEXT("Engine A should resolve its static name by index"), FAngelscriptEngine::TryGetStaticName(EngineANameIndex, ResolvedName));
		TestEqual(TEXT("Engine A static-name index should resolve to the added name"), ResolvedName.ToString(), EngineAName.ToString());
	}

	{
		FAngelscriptEngineScope ScopeB(*EngineB);
		const int32 EngineBBaselineCount = FAngelscriptEngine::GetStaticNameCount();
		FName ResolvedName;
		const bool bEngineBSeesEngineAName = FAngelscriptEngine::TryGetStaticName(EngineANameIndex, ResolvedName) && ResolvedName == EngineAName;
		TestFalse(TEXT("Engine B should not see static names added through engine A"), bEngineBSeesEngineAName);
		TestEqual(TEXT("Engine B static-name count should stay isolated"), FAngelscriptEngine::GetStaticNameCount(), EngineBBaselineCount);
	}

	TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateCloneFrom(*EngineA, Config);
	if (!TestNotNull(TEXT("Static-name isolation should create a clone engine"), CloneEngine.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope CloneScope(*CloneEngine);
		FName ResolvedName;
		TestTrue(TEXT("Clone engine should resolve static names from its source shared state"), FAngelscriptEngine::TryGetStaticName(EngineANameIndex, ResolvedName));
		TestEqual(TEXT("Clone engine should see engine A static names"), ResolvedName.ToString(), EngineAName.ToString());
		CloneNameIndex = FAngelscriptEngine::GetOrAddStaticName(CloneName);
	}

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		FName ResolvedName;
		TestTrue(TEXT("Engine A should resolve static names added through its clone"), FAngelscriptEngine::TryGetStaticName(CloneNameIndex, ResolvedName));
		TestEqual(TEXT("Engine A should share static names with its clone"), ResolvedName.ToString(), CloneName.ToString());
	}

	return true;
}

#endif
