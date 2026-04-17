#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Components/ActorTestSpawner.h"
#include "Engine/GameInstance.h"
#include "Engine/Level.h"
#include "Engine/World.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "Templates/Function.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptWorldBindingsTests_Private
{
	static constexpr ANSICHAR WorldBindingsModuleName[] = "ASWorldContextAndGlobalsCompat";

	enum EWorldBindingMismatch : int32
	{
		WorldContextMismatch = 1 << 0,
		CurrentWorldMismatch = 1 << 1,
		IsGameWorldMismatch = 1 << 2,
		PersistentLevelMismatch = 1 << 3,
		GameInstanceMismatch = 1 << 4,
		WorldTypeMismatch = 1 << 5,
		FrameNumberMismatch = 1 << 6,
	};

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

	bool SetArgDWordChecked(
		FAutomationTestBase& Test,
		asIScriptContext& Context,
		asUINT ArgumentIndex,
		const asDWORD Value,
		const TCHAR* ContextLabel)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should bind dword argument %u"), ContextLabel, static_cast<uint32>(ArgumentIndex)),
			Context.SetArgDWord(ArgumentIndex, Value),
			static_cast<int32>(asSUCCESS));
	}

	bool ExecuteIntFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const FString& FunctionDecl,
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
}

using namespace AngelscriptTest_Bindings_AngelscriptWorldBindingsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptWorldContextAndGlobalsBindingsTest,
	"Angelscript.TestModule.Bindings.WorldContextAndGlobalsCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptWorldContextAndGlobalsBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor& ContextActor = Spawner.SpawnActor<AActor>();
	UWorld* TestWorld = ContextActor.GetWorld();
	if (!TestNotNull(TEXT("World context bindings test should access the spawned test world"), TestWorld))
	{
		return false;
	}

	ULevel* PersistentLevel = TestWorld->PersistentLevel;
	UGameInstance* GameInstance = TestWorld->GetGameInstance();
	if (!TestNotNull(TEXT("World context bindings test should expose a persistent level"), PersistentLevel)
		|| !TestNotNull(TEXT("World context bindings test should expose a game instance"), GameInstance))
	{
		return false;
	}

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		WorldBindingsModuleName,
		TEXT(R"(
int VerifyWorldBindings(
	UObject ExpectedContext,
	UWorld ExpectedWorld,
	ULevel ExpectedPersistentLevel,
	UGameInstance ExpectedGameInstance,
	bool bExpectedIsGameWorld,
	uint ExpectedWorldType,
	uint ExpectedFrameNumber)
{
	int MismatchMask = 0;

	if (__WorldContext() != ExpectedContext)
		MismatchMask |= 1;

	UWorld CurrentWorld = GetCurrentWorld();
	if (CurrentWorld == null)
		return MismatchMask | 2 | 4 | 8 | 16 | 32 | 64;

	if (CurrentWorld != ExpectedWorld)
		MismatchMask |= 2;
	if (CurrentWorld.IsGameWorld() != bExpectedIsGameWorld)
		MismatchMask |= 4;
	if (CurrentWorld.GetPersistentLevel() != ExpectedPersistentLevel)
		MismatchMask |= 8;
	if (CurrentWorld.GetGameInstance() != ExpectedGameInstance)
		MismatchMask |= 16;
	if (uint(CurrentWorld.WorldType) != ExpectedWorldType)
		MismatchMask |= 32;
	if (GFrameNumber != ExpectedFrameNumber)
		MismatchMask |= 64;

	return MismatchMask;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	FScopedTestWorldContextScope WorldContextScope(&ContextActor);

	const bool bExpectedIsGameWorld = TestWorld->IsGameWorld();
	const asDWORD ExpectedWorldType = static_cast<asDWORD>(TestWorld->WorldType);
	const asDWORD ExpectedFrameNumber = static_cast<asDWORD>(GFrameNumber);

	int32 ResultMask = INDEX_NONE;
	if (!ExecuteIntFunction(
		*this,
		Engine,
		*Module,
		TEXT("int VerifyWorldBindings(UObject, UWorld, ULevel, UGameInstance, bool, uint, uint)"),
		[this, &ContextActor, TestWorld, PersistentLevel, GameInstance, bExpectedIsGameWorld, ExpectedWorldType, ExpectedFrameNumber](asIScriptContext& Context)
		{
			return SetArgObjectChecked(*this, Context, 0, &ContextActor, TEXT("VerifyWorldBindings"))
				&& SetArgObjectChecked(*this, Context, 1, TestWorld, TEXT("VerifyWorldBindings"))
				&& SetArgObjectChecked(*this, Context, 2, PersistentLevel, TEXT("VerifyWorldBindings"))
				&& SetArgObjectChecked(*this, Context, 3, GameInstance, TEXT("VerifyWorldBindings"))
				&& SetArgDWordChecked(*this, Context, 4, bExpectedIsGameWorld ? 1u : 0u, TEXT("VerifyWorldBindings"))
				&& SetArgDWordChecked(*this, Context, 5, ExpectedWorldType, TEXT("VerifyWorldBindings"))
				&& SetArgDWordChecked(*this, Context, 6, ExpectedFrameNumber, TEXT("VerifyWorldBindings"));
		},
		TEXT("VerifyWorldBindings"),
		ResultMask))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("World context bindings should preserve world context, world globals, persistent level, game instance, world type and frame number"),
		ResultMask,
		0);
	bPassed &= TestTrue(
		TEXT("World context bindings test should observe a game world in the spawned scenario world"),
		bExpectedIsGameWorld);
	bPassed &= TestEqual(
		TEXT("World context bindings test should use the native world type baseline"),
		static_cast<uint32>(ExpectedWorldType),
		static_cast<uint32>(TestWorld->WorldType));
	bPassed &= TestEqual(
		TEXT("World context bindings test should capture the current frame number baseline"),
		static_cast<uint32>(ExpectedFrameNumber),
		static_cast<uint32>(GFrameNumber));

	ASTEST_END_FULL
	return bPassed;
}

#endif
