#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Components/ActorTestSpawner.h"
#include "Engine/LevelStreamingDynamic.h"
#include "Engine/LevelStreaming.h"
#include "Engine/World.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "Templates/Function.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptWorldFunctionLibraryTests_Private
{
	static constexpr ANSICHAR ModuleName[] = "ASWorldStreamingNullGuards";
	static constexpr ANSICHAR WorldStreamingAccessModuleName[] = "ASWorldStreamingAccess";

	bool ExecuteIntFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel,
		int32& OutResult)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should execute successfully"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_FINISHED)))
		{
			return false;
		}

		OutResult = static_cast<int32>(Context->GetReturnDWord());
		return true;
	}

	bool SetArgObjectChecked(
		FAutomationTestBase& Test,
		asIScriptContext& Context,
		asUINT ArgumentIndex,
		void* Object,
		const TCHAR* ContextLabel)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should bind object argument %u"), ContextLabel, static_cast<uint32>(ArgumentIndex)),
			Context.SetArgObject(ArgumentIndex, Object),
			static_cast<int32>(asSUCCESS));
	}

	bool ExecuteBoolFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel,
		bool& OutResult)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should execute successfully"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_FINISHED)))
		{
			return false;
		}

		OutResult = Context->GetReturnByte() != 0;
		return true;
	}

	bool ExecuteFunctionExpectingException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel,
		FString& OutExceptionString)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should fail with a script exception"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_EXCEPTION)))
		{
			return false;
		}

		OutExceptionString = Context->GetExceptionString() != nullptr ? UTF8_TO_TCHAR(Context->GetExceptionString()) : TEXT("");
		return true;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptWorldFunctionLibraryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptWorldFunctionLibraryNullGuardsTest,
	"Angelscript.TestModule.FunctionLibraries.WorldStreamingNullGuards",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptWorldFunctionLibraryNullGuardsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedError(TEXT("Null pointer access"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("ASWorldStreamingNullGuards"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("int GetStreamingLevelCount(UWorld) | Line 4 | Col 2"), EAutomationExpectedErrorFlags::Contains, 1, false);
	AddExpectedError(TEXT("bool GetLevelVisibleInEditor(ULevelStreaming) | Line 9 | Col 2"), EAutomationExpectedErrorFlags::Contains, 1, false);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		ModuleName,
		TEXT(R"(
int GetStreamingLevelCount(UWorld World)
{
	return World.GetStreamingLevels().Num();
}

bool GetLevelVisibleInEditor(ULevelStreaming Level)
{
	return Level.GetShouldBeVisibleInEditor();
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor& ContextActor = Spawner.SpawnActor<AActor>();
	UWorld* TestWorld = ContextActor.GetWorld();
	if (!TestNotNull(TEXT("World function library test should access the spawned world"), TestWorld))
	{
		return false;
	}

	ULevelStreamingDynamic* StreamingLevel = NewObject<ULevelStreamingDynamic>(TestWorld, TEXT("FunctionLibraryStreamingLevel"));
	if (!TestNotNull(TEXT("World function library test should create a streaming level"), StreamingLevel))
	{
		return false;
	}

	TestWorld->AddStreamingLevel(StreamingLevel);
	ON_SCOPE_EXIT
	{
		if (TestWorld != nullptr && StreamingLevel != nullptr)
		{
			TestWorld->RemoveStreamingLevel(StreamingLevel);
		}
	};

#if WITH_EDITOR
	StreamingLevel->SetShouldBeVisibleInEditor(true);
#endif

	const int32 NativeStreamingLevelCount = TestWorld->GetStreamingLevels().Num();
	const bool bNativeEditorVisibility = StreamingLevel->GetShouldBeVisibleInEditor();

	int32 ScriptStreamingLevelCount = INDEX_NONE;
	if (!ExecuteIntFunction(
		*this,
		Engine,
		*Module,
		TEXT("int GetStreamingLevelCount(UWorld World)"),
		[this, TestWorld](asIScriptContext& Context)
		{
			return SetArgObjectChecked(*this, Context, 0, TestWorld, TEXT("GetStreamingLevelCount(valid)"));
		},
		TEXT("GetStreamingLevelCount(valid)"),
		ScriptStreamingLevelCount))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("GetStreamingLevels should preserve the native streaming-level count for a valid world"),
		ScriptStreamingLevelCount,
		NativeStreamingLevelCount);

	bool bScriptEditorVisibility = false;
	if (!ExecuteBoolFunction(
		*this,
		Engine,
		*Module,
		TEXT("bool GetLevelVisibleInEditor(ULevelStreaming Level)"),
		[this, StreamingLevel](asIScriptContext& Context)
		{
			return SetArgObjectChecked(*this, Context, 0, StreamingLevel, TEXT("GetLevelVisibleInEditor"));
		},
		TEXT("GetLevelVisibleInEditor"),
		bScriptEditorVisibility))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("GetShouldBeVisibleInEditor should match the native editor-visibility baseline for a valid level"),
		bScriptEditorVisibility,
		bNativeEditorVisibility);

	FString NullWorldException;
	if (!ExecuteFunctionExpectingException(
		*this,
		Engine,
		*Module,
		TEXT("int GetStreamingLevelCount(UWorld World)"),
		[this](asIScriptContext& Context)
		{
			return SetArgObjectChecked(*this, Context, 0, nullptr, TEXT("GetStreamingLevelCount(null)"));
		},
		TEXT("GetStreamingLevelCount(null)"),
		NullWorldException))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("GetStreamingLevels should report a stable null-pointer diagnostic for a null world receiver"),
		NullWorldException,
		FString(TEXT("Null pointer access")));

	FString NullLevelException;
	if (!ExecuteFunctionExpectingException(
		*this,
		Engine,
		*Module,
		TEXT("bool GetLevelVisibleInEditor(ULevelStreaming Level)"),
		[this](asIScriptContext& Context)
		{
			return SetArgObjectChecked(*this, Context, 0, nullptr, TEXT("GetLevelVisibleInEditor(null)"));
		},
		TEXT("GetLevelVisibleInEditor(null)"),
		NullLevelException))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("GetShouldBeVisibleInEditor should report a stable null-pointer diagnostic for a null level receiver"),
		NullLevelException,
		FString(TEXT("Null pointer access")));

	ASTEST_END_FULL
	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptWorldStreamingAccessTest,
	"Angelscript.TestModule.FunctionLibraries.WorldStreamingAccess",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptWorldStreamingAccessTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor& ContextActor = Spawner.SpawnActor<AActor>();
	UWorld* TestWorld = ContextActor.GetWorld();
	if (!TestNotNull(TEXT("World streaming access test should access the spawned world"), TestWorld))
	{
		return false;
	}

	if (!TestEqual(
		TEXT("World streaming access test should start from a world without pre-existing streaming levels"),
		TestWorld->GetStreamingLevels().Num(),
		0))
	{
		return false;
	}

	ULevelStreamingDynamic* FirstStreamingLevel = NewObject<ULevelStreamingDynamic>(TestWorld, TEXT("WorldStreamingAccess_First"));
	ULevelStreamingDynamic* SecondStreamingLevel = NewObject<ULevelStreamingDynamic>(TestWorld, TEXT("WorldStreamingAccess_Second"));
	if (!TestNotNull(TEXT("World streaming access test should create the first streaming level"), FirstStreamingLevel)
		|| !TestNotNull(TEXT("World streaming access test should create the second streaming level"), SecondStreamingLevel))
	{
		return false;
	}

	TestWorld->AddStreamingLevel(FirstStreamingLevel);
	TestWorld->AddStreamingLevel(SecondStreamingLevel);
	ON_SCOPE_EXIT
	{
		if (TestWorld != nullptr)
		{
			if (SecondStreamingLevel != nullptr)
			{
				TestWorld->RemoveStreamingLevel(SecondStreamingLevel);
			}
			if (FirstStreamingLevel != nullptr)
			{
				TestWorld->RemoveStreamingLevel(FirstStreamingLevel);
			}
		}
	};

#if WITH_EDITOR
	FirstStreamingLevel->SetShouldBeVisibleInEditor(true);
	SecondStreamingLevel->SetShouldBeVisibleInEditor(false);
#endif

	const TArray<ULevelStreaming*>& NativeStreamingLevels = TestWorld->GetStreamingLevels();
	if (!TestEqual(
		TEXT("World streaming access test should expose exactly the two streaming levels inserted by the fixture"),
		NativeStreamingLevels.Num(),
		2))
	{
		return false;
	}

	const bool bNativeFirstVisibility = FirstStreamingLevel->GetShouldBeVisibleInEditor();
	const bool bNativeSecondVisibility = SecondStreamingLevel->GetShouldBeVisibleInEditor();
	const bool bExpectedSecondVisibility = bNativeSecondVisibility;

	FString Script = TEXT(R"(
int VerifyWorldStreamingAccess(UWorld World, ULevelStreaming ExpectedFirst, ULevelStreaming ExpectedSecond)
{
	int MismatchMask = 0;

	if (World.GetStreamingLevels().Num() != $EXPECTED_COUNT$)
		MismatchMask |= 1;
	if (World.GetStreamingLevels().Num() <= 0 || World.GetStreamingLevels()[0] != ExpectedFirst)
		MismatchMask |= 2;
	if (World.GetStreamingLevels().Num() <= 1 || World.GetStreamingLevels()[1] != ExpectedSecond)
		MismatchMask |= 4;
	if (ExpectedFirst.GetShouldBeVisibleInEditor() != $EXPECTED_FIRST_VISIBLE$)
		MismatchMask |= 8;
	if (ExpectedSecond.GetShouldBeVisibleInEditor() != $EXPECTED_SECOND_VISIBLE$)
		MismatchMask |= 16;

	return MismatchMask;
}
)");
	Script.ReplaceInline(TEXT("$EXPECTED_COUNT$"), *LexToString(NativeStreamingLevels.Num()));
	Script.ReplaceInline(TEXT("$EXPECTED_FIRST_VISIBLE$"), bNativeFirstVisibility ? TEXT("true") : TEXT("false"));
	Script.ReplaceInline(TEXT("$EXPECTED_SECOND_VISIBLE$"), bExpectedSecondVisibility ? TEXT("true") : TEXT("false"));

	asIScriptModule* Module = BuildModule(*this, Engine, WorldStreamingAccessModuleName, Script);
	if (Module == nullptr)
	{
		return false;
	}

	FScopedTestWorldContextScope WorldContextScope(&ContextActor);

	int32 ResultMask = INDEX_NONE;
	if (!ExecuteIntFunction(
		*this,
		Engine,
		*Module,
		TEXT("int VerifyWorldStreamingAccess(UWorld, ULevelStreaming, ULevelStreaming)"),
		[this, TestWorld, FirstStreamingLevel, SecondStreamingLevel](asIScriptContext& Context)
		{
			return SetArgObjectChecked(*this, Context, 0, TestWorld, TEXT("VerifyWorldStreamingAccess"))
				&& SetArgObjectChecked(*this, Context, 1, FirstStreamingLevel, TEXT("VerifyWorldStreamingAccess"))
				&& SetArgObjectChecked(*this, Context, 2, SecondStreamingLevel, TEXT("VerifyWorldStreamingAccess"));
		},
		TEXT("VerifyWorldStreamingAccess"),
		ResultMask))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("World streaming function libraries should preserve streaming-level count, order and editor visibility"),
		ResultMask,
		0);
	bPassed &= TestTrue(
		TEXT("World streaming access test should keep the first streaming level editor-visible"),
		bNativeFirstVisibility);
	bPassed &= TestFalse(
		TEXT("World streaming access test should keep the second streaming level editor-hidden"),
		bNativeSecondVisibility);

	ASTEST_END_FULL
	return bPassed;
}

#endif
