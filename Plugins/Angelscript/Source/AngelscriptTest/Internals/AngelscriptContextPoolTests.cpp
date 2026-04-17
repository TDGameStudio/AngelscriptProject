#include "Angelscript/AngelscriptTestSupport.h"

#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Internals_AngelscriptContextPoolTests_Private
{
	struct FContextPoolEngineStackGuard
	{
		TArray<FAngelscriptEngine*> SavedStack;

		FContextPoolEngineStackGuard()
		{
			SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
		}

		~FContextPoolEngineStackGuard()
		{
			FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
		}
	};

	FString MakeContextPoolModuleName(const TCHAR* Prefix)
	{
		return FString::Printf(TEXT("%s_%s"), Prefix, *FGuid::NewGuid().ToString(EGuidFormats::Digits));
	}

	asIScriptFunction* CompileContextPoolFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FString& ModuleName,
		const ANSICHAR* Source,
		const ANSICHAR* Declaration)
	{
		FAngelscriptEngineScope EngineScope(Engine);

		asIScriptModule* Module = Engine.GetScriptEngine()->GetModule(TCHAR_TO_ANSI(*ModuleName), asGM_ALWAYS_CREATE);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("Context pool helper should create module '%s'"), *ModuleName),
				Module))
		{
			return nullptr;
		}

		asIScriptFunction* Function = nullptr;
		const int32 CompileResult = Module->CompileFunction(TCHAR_TO_ANSI(*ModuleName), Source, 0, 0, &Function);
		if (!Test.TestEqual(
				*FString::Printf(TEXT("Context pool helper should compile '%s'"), *ModuleName),
				CompileResult,
				asSUCCESS))
		{
			return nullptr;
		}

		Test.TestNotNull(
			*FString::Printf(TEXT("Context pool helper should resolve '%s'"), ANSI_TO_TCHAR(Declaration)),
			Function);
		return Function;
	}

	int32 GetLocalPooledContextCount(asIScriptEngine* ScriptEngine)
	{
		return FAngelscriptEngine::GetLocalPooledContextCountForTesting(ScriptEngine);
	}
}

using namespace AngelscriptTest_Internals_AngelscriptContextPoolTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptContextPoolReuseAndResetPerEngineTest,
	"Angelscript.TestModule.Internals.ContextPool.ReuseAndResetPerEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptContextPoolReuseAndResetPerEngineTest::RunTest(const FString& Parameters)
{
	FContextPoolEngineStackGuard ContextStackGuard;

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateForTesting(
		Config,
		Dependencies,
		EAngelscriptEngineCreationMode::Full);
	TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateForTesting(
		Config,
		Dependencies,
		EAngelscriptEngineCreationMode::Full);

	if (!TestNotNull(TEXT("ContextPool.ReuseAndResetPerEngine should create EngineA"), EngineA.Get())
		|| !TestNotNull(TEXT("ContextPool.ReuseAndResetPerEngine should create EngineB"), EngineB.Get()))
	{
		return false;
	}

	asIScriptFunction* RunFunction = CompileContextPoolFunction(
		*this,
		*EngineA,
		MakeContextPoolModuleName(TEXT("ContextPoolReuseAndResetPerEngine")),
		"void Run() {}",
		"void Run()");
	if (!TestNotNull(TEXT("ContextPool.ReuseAndResetPerEngine should compile the EngineA helper function"), RunFunction))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		RunFunction->Release();
	};

	bool bPassed = true;
	const int32 EngineABaselineCount = GetLocalPooledContextCount(EngineA->GetScriptEngine());
	bPassed &= TestEqual(
		TEXT("ContextPool.ReuseAndResetPerEngine should start EngineA with an empty local pool"),
		EngineABaselineCount,
		0);

	asIScriptContext* SeedContext = nullptr;
	{
		FAngelscriptEngineScope EngineScope(*EngineA);
		SeedContext = EngineA->GetScriptEngine()->RequestContext();
		if (!TestNotNull(TEXT("ContextPool.ReuseAndResetPerEngine should request a seed context from EngineA"), SeedContext))
		{
			return false;
		}

		bPassed &= TestEqual(
			TEXT("ContextPool.ReuseAndResetPerEngine should keep EngineA pool empty while the seed context is checked out"),
			GetLocalPooledContextCount(EngineA->GetScriptEngine()),
			0);

		const int32 PrepareResult = SeedContext->Prepare(RunFunction);
		bPassed &= TestEqual(
			TEXT("ContextPool.ReuseAndResetPerEngine should prepare the EngineA seed context successfully"),
			PrepareResult,
			asSUCCESS);

		const int32 ExecuteResult = PrepareResult == asSUCCESS ? SeedContext->Execute() : PrepareResult;
		bPassed &= TestEqual(
			TEXT("ContextPool.ReuseAndResetPerEngine should execute the EngineA seed context successfully"),
			ExecuteResult,
			asEXECUTION_FINISHED);

		EngineA->GetScriptEngine()->ReturnContext(SeedContext);
	}

	bPassed &= TestEqual(
		TEXT("ContextPool.ReuseAndResetPerEngine should pool the returned EngineA context"),
		GetLocalPooledContextCount(EngineA->GetScriptEngine()),
		1);

	asIScriptContext* ReusedContext = nullptr;
	{
		FAngelscriptEngineScope EngineScope(*EngineA);
		ReusedContext = EngineA->GetScriptEngine()->RequestContext();
		if (!TestNotNull(TEXT("ContextPool.ReuseAndResetPerEngine should request a reused context from EngineA"), ReusedContext))
		{
			return false;
		}

		bPassed &= TestTrue(
			TEXT("ContextPool.ReuseAndResetPerEngine should reuse the same pooled EngineA context"),
			ReusedContext == SeedContext);
		bPassed &= TestEqual(
			TEXT("ContextPool.ReuseAndResetPerEngine should pop EngineA pool count back to zero when re-borrowing"),
			GetLocalPooledContextCount(EngineA->GetScriptEngine()),
			0);
		bPassed &= TestEqual(
			TEXT("ContextPool.ReuseAndResetPerEngine should reset the reused EngineA context to the uninitialized state"),
			static_cast<int32>(ReusedContext->GetState()),
			static_cast<int32>(asEXECUTION_UNINITIALIZED));

		EngineA->GetScriptEngine()->ReturnContext(ReusedContext);
	}

	bPassed &= TestEqual(
		TEXT("ContextPool.ReuseAndResetPerEngine should restore EngineA pooled count after returning the reused context"),
		GetLocalPooledContextCount(EngineA->GetScriptEngine()),
		1);
	bPassed &= TestEqual(
		TEXT("ContextPool.ReuseAndResetPerEngine should keep EngineB baseline pool count at zero before it borrows a context"),
		GetLocalPooledContextCount(EngineB->GetScriptEngine()),
		0);

	{
		FAngelscriptEngineScope EngineScope(*EngineB);
		asIScriptContext* EngineBContext = EngineB->GetScriptEngine()->RequestContext();
		if (!TestNotNull(TEXT("ContextPool.ReuseAndResetPerEngine should request a context from EngineB"), EngineBContext))
		{
			return false;
		}

		bPassed &= TestTrue(
			TEXT("ContextPool.ReuseAndResetPerEngine should never hand EngineB the pooled EngineA context"),
			EngineBContext != SeedContext);

		EngineB->GetScriptEngine()->ReturnContext(EngineBContext);
	}

	bPassed &= TestEqual(
		TEXT("ContextPool.ReuseAndResetPerEngine should keep EngineA pooled count unchanged after EngineB returns its context"),
		GetLocalPooledContextCount(EngineA->GetScriptEngine()),
		1);
	bPassed &= TestEqual(
		TEXT("ContextPool.ReuseAndResetPerEngine should track EngineB pooled count independently after its own return"),
		GetLocalPooledContextCount(EngineB->GetScriptEngine()),
		1);

	return bPassed;
}

#endif
