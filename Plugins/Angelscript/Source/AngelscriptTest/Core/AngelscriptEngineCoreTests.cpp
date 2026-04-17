#include "AngelscriptEngine.h"
#include "AngelscriptType.h"
#include "Angelscript/AngelscriptTestSupport.h"
#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "Misc/AutomationTest.h"
#include "UObject/Package.h"
#include "UObject/UnrealType.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_context.h"
#include "source/as_module.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

// Test Layer: Runtime Integration
#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptEngineCoreTests_Private
{
	struct FCoreTestContextStackGuard
	{
		TArray<FAngelscriptEngine*> SavedStack;
		FCoreTestContextStackGuard() { SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear(); }
		~FCoreTestContextStackGuard() { FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack)); }
		void DiscardSavedStack() { SavedStack.Reset(); }
	};
}

using namespace AngelscriptTest_Core_AngelscriptEngineCoreTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestModuleLifecycleTest,
	"Angelscript.TestModule.Engine.CreateDestroy",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestModuleCompileSnippetTest,
	"Angelscript.TestModule.Engine.CompileSnippet",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestModuleExecuteSnippetTest,
	"Angelscript.TestModule.Engine.ExecuteSnippet",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFullDestroyClearsTypeStateTest,
	"Angelscript.TestModule.Engine.LastFullDestroyClearsTypeState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFullDestroyAllowsCleanRecreateTest,
	"Angelscript.TestModule.Engine.FullDestroyAllowsCleanRecreate",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFullDestroyAllowsAnnotatedRecreateTest,
	"Angelscript.TestModule.Engine.FullDestroyAllowsAnnotatedRecreate",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFullDestroyAllowsAnnotatedSameNameRecreateTest,
	"Angelscript.TestModule.Engine.FullDestroyAllowsAnnotatedSameNameRecreate",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestModuleLifecycleTest::RunTest(const FString& Parameters)
{
	AngelscriptTestSupport::DestroySharedTestEngine();
	FAngelscriptEngineConfig Config;
	FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();

	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateForTesting(Config, Dependencies);
	if (!TestNotNull(TEXT("Test module should create an angelscript engine instance"), Engine.Get()))
	{
		return false;
	}

	Engine.Reset();
	TestTrue(TEXT("Resetting the test-owned engine should clear the pointer"), !Engine.IsValid());
	return true;
}

bool FAngelscriptTestModuleCompileSnippetTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	if (!TestNotNull(TEXT("Compile test should create an initialized engine"), &Engine))
	{
		return false;
	}
	FAngelscriptEngineScope GlobalScope(Engine);

	asIScriptModule* Module = Engine.GetScriptEngine()->GetModule("CompileSnippet", asGM_ALWAYS_CREATE);
	if (!TestNotNull(TEXT("Compile test should create a script module"), Module))
	{
		return false;
	}

	const char* Source = "int CompileOnly() { return 7; }";
	asIScriptFunction* Function = nullptr;
	const int CompileResult = Module->CompileFunction("CompileSnippet", Source, 0, 0, &Function);
	TestEqual(TEXT("Compile test should compile the snippet successfully"), CompileResult, asSUCCESS);
	const bool bCompiled = TestNotNull(TEXT("Compile test should receive a compiled function"), Function);
	if (Function != nullptr)
	{
		Function->Release();
	}
	bPassed = CompileResult == asSUCCESS && bCompiled;
	ASTEST_END_SHARE

	return bPassed;
}

bool FAngelscriptTestModuleExecuteSnippetTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	if (!TestNotNull(TEXT("Execute test should create an initialized engine"), &Engine))
	{
		return false;
	}
	FAngelscriptEngineScope GlobalScope(Engine);

	asIScriptModule* Module = Engine.GetScriptEngine()->GetModule("ExecuteSnippet", asGM_ALWAYS_CREATE);
	if (!TestNotNull(TEXT("Execute test should create a script module"), Module))
	{
		return false;
	}

	const char* Source = "int ReturnFortyTwo() { return 42; }";
	asIScriptFunction* Function = nullptr;
	const int CompileResult = Module->CompileFunction("ExecuteSnippet", Source, 0, 0, &Function);
	if (!TestEqual(TEXT("Execute test should compile the snippet successfully"), CompileResult, asSUCCESS))
	{
		return false;
	}

	if (!TestNotNull(TEXT("Execute test should find the compiled function"), Function))
	{
		return false;
	}

	asIScriptContext* Context = Engine.CreateContext();
	if (!TestNotNull(TEXT("Execute test should create a script context"), Context))
	{
		return false;
	}

	const int PrepareResult = Context->Prepare(Function);
	const int ExecuteResult = PrepareResult == asSUCCESS ? Context->Execute() : PrepareResult;
	TestEqual(TEXT("Execute test should prepare the function successfully"), PrepareResult, asSUCCESS);
	TestEqual(TEXT("Execute test should finish successfully"), ExecuteResult, asEXECUTION_FINISHED);
	TestEqual(TEXT("Execute test should receive the script return value"), static_cast<int>(Context->GetReturnDWord()), 42);
	Context->Release();
	Function->Release();
	bPassed = PrepareResult == asSUCCESS && ExecuteResult == asEXECUTION_FINISHED;
	ASTEST_END_SHARE

	return bPassed;
}

bool FAngelscriptFullDestroyClearsTypeStateTest::RunTest(const FString& Parameters)
{
	FCoreTestContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();
	ON_SCOPE_EXIT
	{
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	TUniquePtr<FAngelscriptEngine> FullEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("Last full destroy core test should create a full engine"), FullEngine.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope Scope(*FullEngine);
		if (!TestTrue(TEXT("Last full destroy core test should populate type metadata while the full engine is alive"), FAngelscriptType::GetTypes().Num() > 0))
		{
			return false;
		}
	}

	FullEngine.Reset();
	return TestEqual(TEXT("Last full destroy core test should clear type metadata after the final full owner is destroyed"), FAngelscriptType::GetTypes().Num(), 0);
}

bool FAngelscriptFullDestroyAllowsCleanRecreateTest::RunTest(const FString& Parameters)
{
	FCoreTestContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();
	ON_SCOPE_EXIT
	{
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	TUniquePtr<FAngelscriptEngine> FirstEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("Full destroy recreate core test should create the first full engine"), FirstEngine.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope Scope(*FirstEngine);
		if (!TestTrue(TEXT("Full destroy recreate core test should populate type metadata during the first epoch"), FAngelscriptType::GetTypes().Num() > 0))
		{
			return false;
		}
	}

	FirstEngine.Reset();
	if (!TestEqual(TEXT("Full destroy recreate core test should clear type metadata after the first epoch ends"), FAngelscriptType::GetTypes().Num(), 0))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> SecondEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("Full destroy recreate core test should create a second full engine after cleanup"), SecondEngine.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope Scope(*SecondEngine);
		if (!TestTrue(TEXT("Full destroy recreate core test should repopulate type metadata during the recreated epoch"), FAngelscriptType::GetTypes().Num() > 0))
		{
			return false;
		}
	}

	const bool bCompiled = AngelscriptTestSupport::CompileModuleFromMemory(
		SecondEngine.Get(),
		TEXT("RecreateCoreSnippet"),
		TEXT("RecreateCoreSnippet.as"),
		TEXT("int Entry() { return 17; }"));
	if (!TestTrue(TEXT("Full destroy recreate core test should compile a trivial module after recreation"), bCompiled))
	{
		return false;
	}

	int32 Result = 0;
	if (!TestTrue(TEXT("Full destroy recreate core test should execute the recreated module entry point"), AngelscriptTestSupport::ExecuteIntFunction(SecondEngine.Get(), TEXT("RecreateCoreSnippet"), TEXT("int Entry()"), Result)))
	{
		return false;
	}

	TestEqual(TEXT("Full destroy recreate core test should preserve the expected return value after recreation"), Result, 17);
	return true;
}

bool FAngelscriptFullDestroyAllowsAnnotatedRecreateTest::RunTest(const FString& Parameters)
{
	FCoreTestContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();
	ON_SCOPE_EXIT
	{
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	auto CompileAnnotatedActor = [this](FAngelscriptEngine* Engine, FName ModuleName, const TCHAR* Filename, const TCHAR* ScriptSource, const TCHAR* ExpectedClassName)
	{
		FAngelscriptEngineScope Scope(*Engine);
		if (!TestTrue(
			FString::Printf(TEXT("%s should compile after full-engine setup"), *ModuleName.ToString()),
			AngelscriptTestSupport::CompileAnnotatedModuleFromMemory(Engine, ModuleName, Filename, ScriptSource)))
		{
			return false;
		}

		UClass* GeneratedClass = AngelscriptTestSupport::FindGeneratedClass(Engine, ExpectedClassName);
		return TestNotNull(
			*FString::Printf(TEXT("%s should resolve the generated class after compile"), ExpectedClassName),
			GeneratedClass);
	};

	TUniquePtr<FAngelscriptEngine> FirstEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("Annotated recreate test should create the first full engine"), FirstEngine.Get()))
	{
		return false;
	}

	if (!CompileAnnotatedActor(
		FirstEngine.Get(),
		TEXT("RecreateAnnotatedActorA"),
		TEXT("RecreateAnnotatedActorA.as"),
		TEXT(R"(
UCLASS()
class ARecreateAnnotatedActorA : AActor
{
	UPROPERTY()
	int Value = 11;
}
)"),
		TEXT("ARecreateAnnotatedActorA")))
	{
		return false;
	}

	{
		FAngelscriptEngineScope Scope(*FirstEngine);
		FirstEngine->DiscardModule(TEXT("RecreateAnnotatedActorA"));
	}
	CollectGarbage(RF_NoFlags, true);
	FirstEngine.Reset();

	if (!TestEqual(TEXT("Annotated recreate test should clear type metadata after the first full engine exits"), FAngelscriptType::GetTypes().Num(), 0))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> SecondEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("Annotated recreate test should create the second full engine"), SecondEngine.Get()))
	{
		return false;
	}

	return CompileAnnotatedActor(
		SecondEngine.Get(),
		TEXT("RecreateAnnotatedActorB"),
		TEXT("RecreateAnnotatedActorB.as"),
		TEXT(R"(
UCLASS()
class ARecreateAnnotatedActorB : AActor
{
	UPROPERTY()
	int Value = 22;
}
)"),
		TEXT("ARecreateAnnotatedActorB"));
}

bool FAngelscriptFullDestroyAllowsAnnotatedSameNameRecreateTest::RunTest(const FString& Parameters)
{
	FCoreTestContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();
	ON_SCOPE_EXIT
	{
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	const FName ModuleName(TEXT("RecreateAnnotatedActor"));
	const FString ModuleNameString = ModuleName.ToString();
	const TCHAR* Filename = TEXT("RecreateAnnotatedActor.as");
	const FName GeneratedClassName(TEXT("ARecreateAnnotatedActor"));
	const FString FirstEpochSource = TEXT(R"(
UCLASS()
class ARecreateAnnotatedActor : AActor
{
	UPROPERTY()
	int Value = 11;
}
)");
	const FString SecondEpochSource = TEXT(R"(
UCLASS()
class ARecreateAnnotatedActor : AActor
{
	UPROPERTY()
	int Value = 22;
}
)");

	auto CompileAnnotatedActor = [this, ModuleName, Filename, GeneratedClassName](FAngelscriptEngine* Engine, const FString& ScriptSource, int32 ExpectedValue, UClass*& OutGeneratedClass)
	{
		FAngelscriptEngineScope Scope(*Engine);
		if (!TestTrue(
			FString::Printf(TEXT("%s should compile annotated source"), *ModuleName.ToString()),
			AngelscriptTestSupport::CompileAnnotatedModuleFromMemory(Engine, ModuleName, Filename, ScriptSource)))
		{
			return false;
		}

		UClass* GeneratedClass = AngelscriptTestSupport::FindGeneratedClass(Engine, GeneratedClassName);
		if (!TestNotNull(TEXT("Annotated same-name recreate test should resolve the generated class"), GeneratedClass))
		{
			return false;
		}

		FIntProperty* ValueProperty = FindFProperty<FIntProperty>(GeneratedClass, TEXT("Value"));
		if (!TestNotNull(TEXT("Annotated same-name recreate test should expose the generated Value property"), ValueProperty))
		{
			return false;
		}

		UObject* DefaultObject = GeneratedClass->GetDefaultObject();
		if (!TestNotNull(TEXT("Annotated same-name recreate test should expose a generated CDO"), DefaultObject))
		{
			return false;
		}

		TestEqual(TEXT("Annotated same-name recreate test should read the expected CDO Value"), ValueProperty->GetPropertyValue_InContainer(DefaultObject), ExpectedValue);
		OutGeneratedClass = GeneratedClass;
		return true;
	};

	TUniquePtr<FAngelscriptEngine> FirstEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("Annotated same-name recreate test should create the first full engine"), FirstEngine.Get()))
	{
		return false;
	}

	UClass* FirstGeneratedClass = nullptr;
	if (!CompileAnnotatedActor(FirstEngine.Get(), FirstEpochSource, 11, FirstGeneratedClass))
	{
		return false;
	}

	UPackage* FirstGeneratedPackage = FirstGeneratedClass->GetPackage();
	if (!TestNotNull(TEXT("Annotated same-name recreate test should resolve the first generated package"), FirstGeneratedPackage))
	{
		return false;
	}

	const FString FirstClassPath = FirstGeneratedClass->GetPathName();
	const FString FirstPackagePath = FirstGeneratedPackage->GetPathName();
	const uint32 FirstClassUniqueId = FirstGeneratedClass->GetUniqueID();

	{
		FAngelscriptEngineScope Scope(*FirstEngine);
		if (!TestTrue(TEXT("Annotated same-name recreate test should discard the first epoch module"), FirstEngine->DiscardModule(*ModuleNameString)))
		{
			return false;
		}
	}

	CollectGarbage(RF_NoFlags, true);
	FirstEngine.Reset();
	CollectGarbage(RF_NoFlags, true);

	if (!TestEqual(TEXT("Annotated same-name recreate test should clear type metadata after the first full engine exits"), FAngelscriptType::GetTypes().Num(), 0))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> SecondEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("Annotated same-name recreate test should create the second full engine"), SecondEngine.Get()))
	{
		return false;
	}

	UClass* SecondGeneratedClass = nullptr;
	if (!CompileAnnotatedActor(SecondEngine.Get(), SecondEpochSource, 22, SecondGeneratedClass))
	{
		return false;
	}

	UPackage* SecondGeneratedPackage = SecondGeneratedClass->GetPackage();
	if (!TestNotNull(TEXT("Annotated same-name recreate test should resolve the recreated generated package"), SecondGeneratedPackage))
	{
		return false;
	}

	TestEqual(TEXT("Annotated same-name recreate test should recreate the class at the same object path"), SecondGeneratedClass->GetPathName(), FirstClassPath);
	TestEqual(TEXT("Annotated same-name recreate test should recreate the package at the same object path"), SecondGeneratedPackage->GetPathName(), FirstPackagePath);
	TestNotEqual(TEXT("Annotated same-name recreate test should create a new UObject identity for the recreated class"), SecondGeneratedClass->GetUniqueID(), FirstClassUniqueId);
	TestEqual(TEXT("Annotated same-name recreate test should let global lookup resolve the recreated class"), FindObject<UClass>(nullptr, *FirstClassPath), SecondGeneratedClass);
	return true;
}

#endif
