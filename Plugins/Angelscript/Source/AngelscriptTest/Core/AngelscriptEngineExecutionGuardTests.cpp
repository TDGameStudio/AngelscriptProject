#include "AngelscriptEngine.h"
#include "Angelscript/AngelscriptTestSupport.h"
#include "Shared/AngelscriptTestUtilities.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_context.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Core_AngelscriptEngineExecutionGuardTests_Private
{
	struct FEngineExecutionGuardContextStackGuard
	{
		TArray<FAngelscriptEngine*> SavedStack;

		FEngineExecutionGuardContextStackGuard()
		{
			SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
		}

		~FEngineExecutionGuardContextStackGuard()
		{
			FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
		}

		void DiscardSavedStack()
		{
			SavedStack.Reset();
		}
	};

	template<typename TObjectType>
	struct TScopedAsRelease
	{
		TObjectType* Object = nullptr;

		explicit TScopedAsRelease(TObjectType* InObject)
			: Object(InObject)
		{
		}

		~TScopedAsRelease()
		{
			if (Object != nullptr)
			{
				Object->Release();
			}
		}
	};
}

using namespace AngelscriptTest_Core_AngelscriptEngineExecutionGuardTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPrepareContextLogsCrossEngineMismatchTest,
	"Angelscript.TestModule.Engine.Context.PrepareContextLogsCrossEngineMismatch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPrepareContextLogsCrossEngineMismatchTest::RunTest(const FString& Parameters)
{
	FEngineExecutionGuardContextStackGuard ContextGuard;
	DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();

	ON_SCOPE_EXIT
	{
		FAngelscriptEngineContextStack::SnapshotAndClear();
		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		DestroySharedTestEngine();
	};

	TUniquePtr<FAngelscriptEngine> EngineA = CreateFullTestEngine();
	TUniquePtr<FAngelscriptEngine> EngineB = CreateFullTestEngine();
	if (!TestNotNull(TEXT("PrepareContext cross-engine mismatch test should create the source full engine"), EngineA.Get())
		|| !TestNotNull(TEXT("PrepareContext cross-engine mismatch test should create the target full engine"), EngineB.Get()))
	{
		return false;
	}

	asIScriptModule* ModuleA = BuildModule(
		*this,
		*EngineA,
		"ASPrepareContextMismatchSource",
		TEXT("int Entry() { return 1; }"));
	if (!TestNotNull(TEXT("PrepareContext cross-engine mismatch test should compile the source module"), ModuleA))
	{
		return false;
	}

	asIScriptFunction* EntryA = GetFunctionByDecl(*this, *ModuleA, TEXT("int Entry()"));
	if (!TestNotNull(TEXT("PrepareContext cross-engine mismatch test should resolve the source Entry() function"), EntryA))
	{
		return false;
	}

	asIScriptContext* ContextB = EngineB->CreateContext();
	if (!TestNotNull(TEXT("PrepareContext cross-engine mismatch test should create a target-engine context"), ContextB))
	{
		return false;
	}

	TScopedAsRelease<asIScriptContext> ContextBScope(ContextB);

	AddExpectedErrorPlain(
		TEXT("Failed in call to function 'Prepare' with 'int Entry()' (Code: asINVALID_ARG"),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedErrorPlain(
		TEXT("Failed to prepare Angelscript context for 'Automation.PrepareMismatch'"),
		EAutomationExpectedErrorFlags::Contains,
		1);

	bool bMismatchPrepared = false;
	{
		FAngelscriptEngineScope PrepareScope(*EngineB);
		bMismatchPrepared = PrepareAngelscriptContextWithLog(
			ContextB,
			EntryA,
			TEXT("Automation.PrepareMismatch"));
	}
	if (!TestFalse(
			TEXT("PrepareContext cross-engine mismatch test should fail closed when a context prepares a function from another engine"),
			bMismatchPrepared))
	{
		return false;
	}

	const asEContextState MismatchState = ContextB->GetState();
	if (!TestTrue(
			TEXT("PrepareContext cross-engine mismatch test should not leave the mismatched context active or suspended"),
			MismatchState != asEXECUTION_ACTIVE && MismatchState != asEXECUTION_SUSPENDED))
	{
		return false;
	}

	if (!TestNull(
			TEXT("PrepareContext cross-engine mismatch test should not leak a current engine after the mismatch path"),
			FAngelscriptEngine::TryGetCurrentEngine()))
	{
		return false;
	}

	asIScriptModule* ModuleB = BuildModule(
		*this,
		*EngineB,
		"ASPrepareContextMismatchControl",
		TEXT("int Entry() { return 2; }"));
	if (!TestNotNull(TEXT("PrepareContext cross-engine mismatch test should compile the control module on the target engine"), ModuleB))
	{
		return false;
	}

	asIScriptFunction* EntryB = GetFunctionByDecl(*this, *ModuleB, TEXT("int Entry()"));
	if (!TestNotNull(TEXT("PrepareContext cross-engine mismatch test should resolve the control Entry() function"), EntryB))
	{
		return false;
	}

	asIScriptContext* ContextB2 = EngineB->CreateContext();
	if (!TestNotNull(TEXT("PrepareContext cross-engine mismatch test should create a fresh control context"), ContextB2))
	{
		return false;
	}

	TScopedAsRelease<asIScriptContext> ContextB2Scope(ContextB2);

	bool bControlPrepared = false;
	int32 ExecuteResult = asERROR;
	{
		FAngelscriptEngineScope PrepareAndExecuteScope(*EngineB);
		bControlPrepared = PrepareAngelscriptContextWithLog(
			ContextB2,
			EntryB,
			TEXT("Automation.PrepareControl"));
		if (bControlPrepared)
		{
			ExecuteResult = ContextB2->Execute();
		}
	}
	if (!TestTrue(
			TEXT("PrepareContext cross-engine mismatch test should still prepare a same-engine control function after the mismatch"),
			bControlPrepared))
	{
		return false;
	}

	if (!TestEqual(
			TEXT("PrepareContext cross-engine mismatch test should execute the control function successfully after the mismatch"),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_FINISHED)))
	{
		return false;
	}

	return TestEqual(
		TEXT("PrepareContext cross-engine mismatch test should preserve a working control context return value after the mismatch"),
		static_cast<int32>(ContextB2->GetReturnDWord()),
		2);
}

#endif
