#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Engine/Engine.h"
#include "Engine/GameInstance.h"
#include "Engine/LocalPlayer.h"
#include "Engine/GameViewportClient.h"
#include "Engine/World.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/Package.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptGameInstanceLocalPlayerBindingsTests_Private
{
	static constexpr ANSICHAR GameInstanceLocalPlayerModuleName[] = "ASGameInstanceLocalPlayerCompat";
	static constexpr int32 LocalPlayerControllerId = 7;

	enum EGameInstanceLocalPlayerMismatch : int32
	{
		WorldLookupFailed = 1 << 0,
		GameInstanceLookupFailed = 1 << 1,
		InitialCountMismatch = 1 << 2,
		CreateLocalPlayerFailed = 1 << 3,
		OutErrorNotEmpty = 1 << 4,
		PostCreateCountMismatch = 1 << 5,
		PlayerByIndexMismatch = 1 << 6,
		PlayerByControllerIdMismatch = 1 << 7,
		FirstGamePlayerMismatch = 1 << 8,
		LocalPlayerGameInstanceMismatch = 1 << 9,
		LocalPlayerWorldMismatch = 1 << 10,
		ControllerIdMismatch = 1 << 11,
		UnexpectedFirstLocalPlayerController = 1 << 12,
		RemoveLocalPlayerFailed = 1 << 13,
		PostRemoveCountMismatch = 1 << 14,
		PostRemoveLookupMismatch = 1 << 15,
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

	struct FGameInstanceLocalPlayerFixture
	{
		~FGameInstanceLocalPlayerFixture()
		{
			Shutdown();
		}

		bool Initialize(FAutomationTestBase& Test)
		{
			if (!Test.TestNotNull(TEXT("GameInstance local-player bindings test should have a live GEngine"), GEngine))
			{
				return false;
			}

			const FName PackageName = MakeUniqueObjectName(
				nullptr,
				UPackage::StaticClass(),
				FName(TEXT("/Angelscript_Test_GameInstanceLocalPlayer")));
			Package = NewObject<UPackage>(GetTransientPackage(), PackageName, RF_Transient);
			if (!Test.TestNotNull(TEXT("GameInstance local-player bindings test should create a transient world package"), Package))
			{
				return false;
			}

			GameInstance = NewObject<UGameInstance>(GEngine, UGameInstance::StaticClass());
			if (!Test.TestNotNull(TEXT("GameInstance local-player bindings test should create a standalone game instance"), GameInstance))
			{
				return false;
			}

			GameInstance->InitializeStandalone(TEXT("AngelscriptGameInstanceLocalPlayerWorld"), Package);
			World = GameInstance->GetWorld();
			WorldContext = GameInstance->GetWorldContext();
			if (!Test.TestNotNull(TEXT("GameInstance local-player bindings test should initialize a standalone world"), World)
				|| !Test.TestNotNull(TEXT("GameInstance local-player bindings test should expose a world context"), WorldContext))
			{
				return false;
			}

			UClass* ViewportClass = GEngine->GameViewportClientClass != nullptr
				? GEngine->GameViewportClientClass.Get()
				: UGameViewportClient::StaticClass();
			GameViewport = NewObject<UGameViewportClient>(GEngine, ViewportClass);
			if (!Test.TestNotNull(TEXT("GameInstance local-player bindings test should create a viewport client"), GameViewport))
			{
				return false;
			}

			GameViewport->Init(*WorldContext, GameInstance, /*bCreateNewAudioDevice*/false);
			WorldContext->GameViewport = GameViewport;
			return true;
		}

		void Shutdown()
		{
			if (GameInstance == nullptr && World == nullptr)
			{
				return;
			}

			if (World != nullptr)
			{
				World->BeginTearingDown();
			}

			if (GameInstance != nullptr)
			{
				GameInstance->Shutdown();
			}

			if (WorldContext != nullptr)
			{
				WorldContext->GameViewport = nullptr;
			}

			if (World != nullptr)
			{
				World->DestroyWorld(false);
				if (GEngine != nullptr)
				{
					GEngine->DestroyWorldContext(World);
				}
			}

			GameViewport = nullptr;
			WorldContext = nullptr;
			World = nullptr;
			GameInstance = nullptr;
			Package = nullptr;
		}

		UPackage* Package = nullptr;
		UGameInstance* GameInstance = nullptr;
		UWorld* World = nullptr;
		FWorldContext* WorldContext = nullptr;
		UGameViewportClient* GameViewport = nullptr;
	};
}

using namespace AngelscriptTest_Bindings_AngelscriptGameInstanceLocalPlayerBindingsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameInstanceLocalPlayerCompatBindingsTest,
	"Angelscript.TestModule.Bindings.GameInstanceLocalPlayerCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGameInstanceLocalPlayerCompatBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	FGameInstanceLocalPlayerFixture Fixture;
	if (!Fixture.Initialize(*this))
	{
		return false;
	}

	UWorld* TestWorld = Fixture.World;
	UGameInstance* GameInstance = Fixture.GameInstance;
	if (!TestNotNull(TEXT("GameInstance local-player bindings test should access the spawned test world"), TestWorld)
		|| !TestNotNull(TEXT("GameInstance local-player bindings test should expose the spawned test game instance"), GameInstance))
	{
		return false;
	}

	const int32 InitialLocalPlayerCount = GameInstance->GetNumLocalPlayers();
	if (!TestEqual(
		TEXT("GameInstance local-player bindings test should start from a world without pre-existing local players"),
		InitialLocalPlayerCount,
		0))
	{
		return false;
	}

	if (!TestTrue(
		TEXT("GameInstance local-player bindings test should reserve controller id 7 before script execution"),
		GameInstance->FindLocalPlayerFromControllerId(LocalPlayerControllerId) == nullptr))
	{
		return false;
	}

	FString Script = TEXT(R"(
int VerifyGameInstanceLocalPlayerCompat(UWorld ExpectedWorld, UGameInstance GameInstance)
{
	int MismatchMask = 0;

	if (ExpectedWorld == null)
		MismatchMask |= 1;
	if (GameInstance == null)
		MismatchMask |= 2;
	if (MismatchMask != 0)
		return MismatchMask;

	if (GameInstance.GetNumLocalPlayers() != $INITIAL_COUNT$)
		MismatchMask |= 4;

	FString OutError;
	ULocalPlayer Created = GameInstance.CreateLocalPlayer($CONTROLLER_ID$, OutError, false);
	if (Created == null)
		return MismatchMask | 8;

	if (OutError.Len() != 0)
		MismatchMask |= 16;
	if (GameInstance.GetNumLocalPlayers() != ($INITIAL_COUNT$ + 1))
		MismatchMask |= 32;
	if (GameInstance.GetLocalPlayerByIndex($INITIAL_COUNT$) != Created)
		MismatchMask |= 64;
	if (GameInstance.FindLocalPlayerFromControllerId($CONTROLLER_ID$) != Created)
		MismatchMask |= 128;
	if (GameInstance.GetFirstGamePlayer() != Created)
		MismatchMask |= 256;
	if (Created.GetGameInstance() != GameInstance)
		MismatchMask |= 512;
	if (Created.GetWorld() != ExpectedWorld)
		MismatchMask |= 1024;
	if (Created.GetControllerId() != $CONTROLLER_ID$)
		MismatchMask |= 2048;
	if (GameInstance.GetFirstLocalPlayerController(ExpectedWorld) != null)
		MismatchMask |= 4096;

	if (!GameInstance.RemoveLocalPlayer(Created))
		return MismatchMask | 8192;

	if (GameInstance.GetNumLocalPlayers() != $INITIAL_COUNT$)
		MismatchMask |= 16384;
	if (GameInstance.FindLocalPlayerFromControllerId($CONTROLLER_ID$) != null)
		MismatchMask |= 32768;

	return MismatchMask;
}
)");
	Script.ReplaceInline(TEXT("$INITIAL_COUNT$"), *LexToString(InitialLocalPlayerCount));
	Script.ReplaceInline(TEXT("$CONTROLLER_ID$"), *LexToString(LocalPlayerControllerId));

	asIScriptModule* Module = BuildModule(*this, Engine, GameInstanceLocalPlayerModuleName, Script);
	if (Module == nullptr)
	{
		return false;
	}

	FScopedTestWorldContextScope WorldContextScope(TestWorld);

	asIScriptFunction* EntryFunction = GetFunctionByDecl(
		*this,
		*Module,
		TEXT("int VerifyGameInstanceLocalPlayerCompat(UWorld, UGameInstance)"));
	if (EntryFunction == nullptr)
	{
		return false;
	}

	FAngelscriptEngineScope EngineScope(Engine);
	asIScriptContext* Context = Engine.CreateContext();
	if (!TestNotNull(TEXT("GameInstance local-player bindings test should create an execution context"), Context))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		if (Context != nullptr)
		{
			Context->Release();
		}
	};

	const int PrepareResult = Context->Prepare(EntryFunction);
	if (!TestEqual(
		TEXT("GameInstance local-player bindings test should prepare the verification function"),
		PrepareResult,
		static_cast<int32>(asSUCCESS)))
	{
		return false;
	}

	if (!SetArgObjectChecked(*this, *Context, 0, TestWorld, TEXT("VerifyGameInstanceLocalPlayerCompat"))
		|| !SetArgObjectChecked(*this, *Context, 1, GameInstance, TEXT("VerifyGameInstanceLocalPlayerCompat")))
	{
		return false;
	}

	const int ExecuteResult = Context->Execute();
	if (!TestEqual(
		TEXT("GameInstance local-player bindings test should execute the verification function"),
		ExecuteResult,
		static_cast<int32>(asEXECUTION_FINISHED)))
	{
		return false;
	}

	const int32 ResultMask = static_cast<int32>(Context->GetReturnDWord());

	bPassed &= TestEqual(
		TEXT("GameInstance local-player bindings should preserve create, lookup, world/game-instance linkage and remove semantics"),
		ResultMask,
		0);
	bPassed &= TestEqual(
		TEXT("GameInstance local-player bindings test should restore the native local-player count after script removal"),
		GameInstance->GetNumLocalPlayers(),
		InitialLocalPlayerCount);
	bPassed &= TestTrue(
		TEXT("GameInstance local-player bindings test should remove the created controller-id lookup after script cleanup"),
		GameInstance->FindLocalPlayerFromControllerId(LocalPlayerControllerId) == nullptr);
	bPassed &= TestTrue(
		TEXT("GameInstance local-player bindings test should keep GetFirstLocalPlayerController native baseline at null when no controller is spawned"),
		GameInstance->GetFirstLocalPlayerController(TestWorld) == nullptr);

	ASTEST_END_FULL
	return bPassed;
}

#endif
