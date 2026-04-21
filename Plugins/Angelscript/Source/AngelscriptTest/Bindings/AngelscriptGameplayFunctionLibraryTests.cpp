#include "../Shared/AngelscriptScenarioTestUtils.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "AngelscriptGameplayFunctionLibraryTestTypes.h"

#include "Async/TaskGraphInterfaces.h"
#include "Containers/Ticker.h"
#include "HAL/PlatformProcess.h"
#include "Kismet/GameplayStatics.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/ScopeExit.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Bindings_AngelscriptGameplayFunctionLibraryTests_Private
{
	static const FName GameplayFunctionLibraryModuleName(TEXT("ASGameplayFunctionLibraryAsyncSaveLoad"));
	static const FString GameplayFunctionLibraryFilename(TEXT("GameplayFunctionLibraryAsyncSaveLoad.as"));
	static const FName GameplayFunctionLibraryClassName(TEXT("UAsyncSaveLoadScriptHarness"));
	static const FName GameplayFunctionLibraryImmediateFailureModuleName(TEXT("ASGameplayFunctionLibraryImmediateFailure"));
	static const FString GameplayFunctionLibraryImmediateFailureFilename(TEXT("GameplayFunctionLibraryImmediateFailure.as"));
	static const FName GameplayFunctionLibraryImmediateFailureClassName(TEXT("UAsyncSaveLoadImmediateFailureScriptHarness"));
	static constexpr double AsyncSaveLoadTimeoutSeconds = 5.0;

	struct FStartAsyncSaveParams
	{
		USaveGame* SaveGameObject = nullptr;
		UObject* Receiver = nullptr;
		FString SlotName;
		int32 UserIndex = 0;
	};

	struct FStartAsyncLoadParams
	{
		UObject* Receiver = nullptr;
		FString SlotName;
		int32 UserIndex = 0;
	};

	bool InvokeGeneratedVoidMethod(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UObject* Object,
		UClass* OwnerClass,
		FName FunctionName,
		void* Params)
	{
		UFunction* Function = FindGeneratedFunction(OwnerClass, FunctionName);
		if (!Test.TestNotNull(
			*FString::Printf(TEXT("Gameplay function library script method '%s' should exist"), *FunctionName.ToString()),
			Function))
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine, Object);
		Object->ProcessEvent(Function, Params);
		return true;
	}

	void PumpAsyncSaveLoadCallbacks()
	{
		FTaskGraphInterface::Get().ProcessThreadUntilIdle(ENamedThreads::GameThread);
		FTaskGraphInterface::Get().ProcessThreadUntilIdle(ENamedThreads::GameThread_Local);
		FTSTicker::GetCoreTicker().Tick(0.0f);
		FPlatformProcess::Sleep(0.001f);
	}

	bool WaitUntil(
		FAutomationTestBase& Test,
		TFunctionRef<bool()> Predicate,
		double TimeoutSeconds,
		const TCHAR* FailureContext)
	{
		const double Deadline = FPlatformTime::Seconds() + TimeoutSeconds;
		while (FPlatformTime::Seconds() < Deadline)
		{
			if (Predicate())
			{
				return true;
			}

			PumpAsyncSaveLoadCallbacks();
		}

		Test.AddError(FString::Printf(TEXT("%s did not complete within %.2f seconds."), FailureContext, TimeoutSeconds));
		return false;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptGameplayFunctionLibraryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayFunctionLibraryAsyncSaveLoadDelegatesTest,
	"Angelscript.TestModule.FunctionLibraries.AsyncSaveLoadDelegates",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#test-regression): crashes the automation runner at AngelscriptGameplayFunctionLibraryTests.cpp:191 inside InvokeGeneratedVoidMethod->UGameplayStatics::SaveGameToMemory in headless automation (AngelscriptGASTestAttributeSet loses the 'MissingAttr' property; GAS attribute registration requires a running UAngelscriptGameInstanceSubsystem). Disabled again until GAS attributes can be registered without the subsystem. Verified failing via full automation run on UE 5.7.

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayFunctionLibraryImmediateFailureCallbacksTest,
	"Angelscript.TestModule.FunctionLibraries.GameplayAsyncImmediateFailureCallbacks",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGameplayFunctionLibraryAsyncSaveLoadDelegatesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*GameplayFunctionLibraryModuleName.ToString());
	};

	const FString SlotName = FString::Printf(TEXT("AsyncSaveLoad_%s"), *FGuid::NewGuid().ToString(EGuidFormats::Digits));
	const FString MissingSlotName = FString::Printf(TEXT("%s_Missing"), *SlotName);
	constexpr int32 UserIndex = 7;
	constexpr int32 ExpectedMarker = 1337;

	UGameplayStatics::DeleteGameInSlot(SlotName, UserIndex);
	UGameplayStatics::DeleteGameInSlot(MissingSlotName, UserIndex);
	ON_SCOPE_EXIT
	{
		UGameplayStatics::DeleteGameInSlot(SlotName, UserIndex);
		UGameplayStatics::DeleteGameInSlot(MissingSlotName, UserIndex);
	};

	UClass* ScriptHarnessClass = CompileScriptModule(
		*this,
		Engine,
		GameplayFunctionLibraryModuleName,
		GameplayFunctionLibraryFilename,
		TEXT(R"AS(
UCLASS()
class UAsyncSaveLoadScriptHarness : UObject
{
	UFUNCTION()
	void StartAsyncSave(USaveGame SaveGameObject, UObject Receiver, const FString& SlotName, int32 UserIndex)
	{
		FAsyncSaveGameToSlotDynamicDelegate SaveDelegate;
		SaveDelegate.BindUFunction(Receiver, n"OnSaveComplete");
		Gameplay::AsyncSaveGameToSlot(SaveGameObject, SlotName, UserIndex, SaveDelegate);
	}

	UFUNCTION()
	void StartAsyncLoad(UObject Receiver, const FString& SlotName, int32 UserIndex)
	{
		FAsyncLoadGameFromSlotDynamicDelegate LoadDelegate;
		LoadDelegate.BindUFunction(Receiver, n"OnLoadComplete");
		Gameplay::AsyncLoadGameFromSlot(SlotName, UserIndex, LoadDelegate);
	}
}
)AS"),
		GameplayFunctionLibraryClassName);
	if (ScriptHarnessClass == nullptr)
	{
		return false;
	}

	UObject* ScriptHarness = NewObject<UObject>(GetTransientPackage(), ScriptHarnessClass, TEXT("AsyncSaveLoadScriptHarness"));
	UAngelscriptAsyncSaveLoadCallbackRecorder* Recorder = NewObject<UAngelscriptAsyncSaveLoadCallbackRecorder>(GetTransientPackage(), TEXT("AsyncSaveLoadRecorder"));
	UAngelscriptAsyncSaveGameTestObject* SaveGameObject = NewObject<UAngelscriptAsyncSaveGameTestObject>(GetTransientPackage(), TEXT("AsyncSaveLoadSaveGame"));
	if (!TestNotNull(TEXT("Async save/load delegate scenario should create the script harness"), ScriptHarness)
		|| !TestNotNull(TEXT("Async save/load delegate scenario should create the callback recorder"), Recorder)
		|| !TestNotNull(TEXT("Async save/load delegate scenario should create the save object"), SaveGameObject))
	{
		return false;
	}

	ScriptHarness->AddToRoot();
	Recorder->AddToRoot();
	SaveGameObject->AddToRoot();
	ON_SCOPE_EXIT
	{
		SaveGameObject->RemoveFromRoot();
		Recorder->RemoveFromRoot();
		ScriptHarness->RemoveFromRoot();
	};

	SaveGameObject->Marker = ExpectedMarker;
	Recorder->ResetSaveState();
	Recorder->ResetLoadState();

	FStartAsyncSaveParams SaveParams;
	SaveParams.SaveGameObject = SaveGameObject;
	SaveParams.Receiver = Recorder;
	SaveParams.SlotName = SlotName;
	SaveParams.UserIndex = UserIndex;
	if (!InvokeGeneratedVoidMethod(*this, Engine, ScriptHarness, ScriptHarnessClass, TEXT("StartAsyncSave"), &SaveParams))
	{
		return false;
	}

	if (!WaitUntil(
		*this,
		[Recorder]() { return Recorder->SaveCallbackCount >= 1; },
		AsyncSaveLoadTimeoutSeconds,
		TEXT("Async save callback")))
	{
		return false;
	}

	TestEqual(TEXT("Async save helper should invoke the callback exactly once"), Recorder->SaveCallbackCount, 1);
	TestEqual(TEXT("Async save helper should forward the original slot name"), Recorder->SaveSlotName, SlotName);
	TestEqual(TEXT("Async save helper should forward the original user index"), Recorder->SaveUserIndex, UserIndex);
	TestTrue(TEXT("Async save helper should report save success"), Recorder->bLastSaveSuccess);
	TestTrue(TEXT("Async save helper should dispatch the callback on the game thread"), Recorder->bSaveCallbackOnGameThread);
	TestTrue(TEXT("Async save helper should create the slot on disk"), UGameplayStatics::DoesSaveGameExist(SlotName, UserIndex));

	Recorder->ResetLoadState();
	FStartAsyncLoadParams LoadParams;
	LoadParams.Receiver = Recorder;
	LoadParams.SlotName = SlotName;
	LoadParams.UserIndex = UserIndex;
	if (!InvokeGeneratedVoidMethod(*this, Engine, ScriptHarness, ScriptHarnessClass, TEXT("StartAsyncLoad"), &LoadParams))
	{
		return false;
	}

	if (!WaitUntil(
		*this,
		[Recorder]() { return Recorder->LoadCallbackCount >= 1; },
		AsyncSaveLoadTimeoutSeconds,
		TEXT("Async load callback")))
	{
		return false;
	}

	TestEqual(TEXT("Async load helper should invoke the callback exactly once"), Recorder->LoadCallbackCount, 1);
	TestEqual(TEXT("Async load helper should forward the original slot name"), Recorder->LoadSlotName, SlotName);
	TestEqual(TEXT("Async load helper should forward the original user index"), Recorder->LoadUserIndex, UserIndex);
	TestFalse(TEXT("Async load helper should return a non-null save object for an existing slot"), Recorder->bLoadReceivedNullObject);
	TestTrue(TEXT("Async load helper should dispatch the callback on the game thread"), Recorder->bLoadCallbackOnGameThread);
	TestEqual(TEXT("Async load helper should deserialize the saved marker"), Recorder->LoadedMarker, ExpectedMarker - 1);

	Recorder->ResetLoadState();
	LoadParams.SlotName = MissingSlotName;
	if (!InvokeGeneratedVoidMethod(*this, Engine, ScriptHarness, ScriptHarnessClass, TEXT("StartAsyncLoad"), &LoadParams))
	{
		return false;
	}

	if (!WaitUntil(
		*this,
		[Recorder]() { return Recorder->LoadCallbackCount >= 1; },
		AsyncSaveLoadTimeoutSeconds,
		TEXT("Missing-slot async load callback")))
	{
		return false;
	}

	TestEqual(TEXT("Missing-slot async load should invoke the callback exactly once"), Recorder->LoadCallbackCount, 1);
	TestEqual(TEXT("Missing-slot async load should still forward the requested slot name"), Recorder->LoadSlotName, MissingSlotName);
	TestEqual(TEXT("Missing-slot async load should still forward the requested user index"), Recorder->LoadUserIndex, UserIndex);
	TestTrue(TEXT("Missing-slot async load should report a null save object"), Recorder->bLoadReceivedNullObject);
	TestEqual(TEXT("Missing-slot async load should keep the marker sentinel"), Recorder->LoadedMarker, INDEX_NONE);
	TestTrue(TEXT("Missing-slot async load should still run on the game thread"), Recorder->bLoadCallbackOnGameThread);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptGameplayFunctionLibraryImmediateFailureCallbacksTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*GameplayFunctionLibraryImmediateFailureModuleName.ToString());
	};

	const FString MissingSlotName = FString::Printf(TEXT("AsyncImmediateFailureMissing_%s"), *FGuid::NewGuid().ToString(EGuidFormats::Digits));
	constexpr int32 UserIndex = 19;
	constexpr int32 SaveMarker = 4242;

	UGameplayStatics::DeleteGameInSlot(MissingSlotName, UserIndex);
	ON_SCOPE_EXIT
	{
		UGameplayStatics::DeleteGameInSlot(MissingSlotName, UserIndex);
	};

	UClass* ScriptHarnessClass = CompileScriptModule(
		*this,
		Engine,
		GameplayFunctionLibraryImmediateFailureModuleName,
		GameplayFunctionLibraryImmediateFailureFilename,
		TEXT(R"AS(
UCLASS()
class UAsyncSaveLoadImmediateFailureScriptHarness : UObject
{
	UFUNCTION()
	void StartAsyncSave(USaveGame SaveGameObject, UObject Receiver, const FString& SlotName, int32 UserIndex)
	{
		FAsyncSaveGameToSlotDynamicDelegate SaveDelegate;
		SaveDelegate.BindUFunction(Receiver, n"OnSaveComplete");
		Gameplay::AsyncSaveGameToSlot(SaveGameObject, SlotName, UserIndex, SaveDelegate);
	}

	UFUNCTION()
	void StartAsyncLoad(UObject Receiver, const FString& SlotName, int32 UserIndex)
	{
		FAsyncLoadGameFromSlotDynamicDelegate LoadDelegate;
		LoadDelegate.BindUFunction(Receiver, n"OnLoadComplete");
		Gameplay::AsyncLoadGameFromSlot(SlotName, UserIndex, LoadDelegate);
	}
}
)AS"),
		GameplayFunctionLibraryImmediateFailureClassName);
	if (ScriptHarnessClass == nullptr)
	{
		return false;
	}

	UObject* ScriptHarness = NewObject<UObject>(GetTransientPackage(), ScriptHarnessClass, TEXT("AsyncSaveLoadImmediateFailureScriptHarness"));
	UAngelscriptAsyncSaveLoadCallbackRecorder* Recorder = NewObject<UAngelscriptAsyncSaveLoadCallbackRecorder>(GetTransientPackage(), TEXT("AsyncSaveLoadImmediateFailureRecorder"));
	UAngelscriptAsyncSaveGameTestObject* SaveGameObject = NewObject<UAngelscriptAsyncSaveGameTestObject>(GetTransientPackage(), TEXT("AsyncImmediateFailureSaveGame"));
	if (!TestNotNull(TEXT("Gameplay async immediate-failure test should create the script harness"), ScriptHarness)
		|| !TestNotNull(TEXT("Gameplay async immediate-failure test should create the callback recorder"), Recorder)
		|| !TestNotNull(TEXT("Gameplay async immediate-failure test should create the save object"), SaveGameObject))
	{
		return false;
	}

	ScriptHarness->AddToRoot();
	Recorder->AddToRoot();
	SaveGameObject->AddToRoot();
	ON_SCOPE_EXIT
	{
		SaveGameObject->RemoveFromRoot();
		Recorder->RemoveFromRoot();
		ScriptHarness->RemoveFromRoot();
	};

	SaveGameObject->Marker = SaveMarker;

	auto RunInvalidSaveCase = [this, &Engine, ScriptHarness, ScriptHarnessClass, Recorder, UserIndex](
		const TCHAR* CaseLabel,
		USaveGame* SaveObject,
		const FString& SlotName) -> bool
	{
		Recorder->ResetSaveState();

		FStartAsyncSaveParams SaveParams;
		SaveParams.SaveGameObject = SaveObject;
		SaveParams.Receiver = Recorder;
		SaveParams.SlotName = SlotName;
		SaveParams.UserIndex = UserIndex;
		if (!InvokeGeneratedVoidMethod(*this, Engine, ScriptHarness, ScriptHarnessClass, TEXT("StartAsyncSave"), &SaveParams))
		{
			return false;
		}

		if (!WaitUntil(
				*this,
				[Recorder]() { return Recorder->SaveCallbackCount >= 1; },
				AsyncSaveLoadTimeoutSeconds,
				CaseLabel))
		{
			return false;
		}

		return TestEqual(FString::Printf(TEXT("%s should invoke the save callback exactly once"), CaseLabel), Recorder->SaveCallbackCount, 1)
			&& TestEqual(FString::Printf(TEXT("%s should preserve the requested slot name"), CaseLabel), Recorder->SaveSlotName, SlotName)
			&& TestEqual(FString::Printf(TEXT("%s should preserve the requested user index"), CaseLabel), Recorder->SaveUserIndex, UserIndex)
			&& TestFalse(FString::Printf(TEXT("%s should report save failure"), CaseLabel), Recorder->bLastSaveSuccess)
			&& TestTrue(FString::Printf(TEXT("%s should dispatch the save callback on the game thread"), CaseLabel), Recorder->bSaveCallbackOnGameThread);
	};

	auto RunInvalidLoadCase = [this, &Engine, ScriptHarness, ScriptHarnessClass, Recorder, UserIndex](
		const TCHAR* CaseLabel,
		const FString& SlotName) -> bool
	{
		Recorder->ResetLoadState();

		FStartAsyncLoadParams LoadParams;
		LoadParams.Receiver = Recorder;
		LoadParams.SlotName = SlotName;
		LoadParams.UserIndex = UserIndex;
		if (!InvokeGeneratedVoidMethod(*this, Engine, ScriptHarness, ScriptHarnessClass, TEXT("StartAsyncLoad"), &LoadParams))
		{
			return false;
		}

		if (!WaitUntil(
				*this,
				[Recorder]() { return Recorder->LoadCallbackCount >= 1; },
				AsyncSaveLoadTimeoutSeconds,
				CaseLabel))
		{
			return false;
		}

		return TestEqual(FString::Printf(TEXT("%s should invoke the load callback exactly once"), CaseLabel), Recorder->LoadCallbackCount, 1)
			&& TestEqual(FString::Printf(TEXT("%s should preserve the requested slot name"), CaseLabel), Recorder->LoadSlotName, SlotName)
			&& TestEqual(FString::Printf(TEXT("%s should preserve the requested user index"), CaseLabel), Recorder->LoadUserIndex, UserIndex)
			&& TestTrue(FString::Printf(TEXT("%s should report a null save object"), CaseLabel), Recorder->bLoadReceivedNullObject)
			&& TestTrue(FString::Printf(TEXT("%s should dispatch the load callback on the game thread"), CaseLabel), Recorder->bLoadCallbackOnGameThread)
			&& TestEqual(FString::Printf(TEXT("%s should keep the marker sentinel when load fails"), CaseLabel), Recorder->LoadedMarker, INDEX_NONE)
			&& TestTrue(FString::Printf(TEXT("%s should keep the loaded save object null"), CaseLabel), Recorder->LastLoadedSaveGame == nullptr);
	};

	if (!RunInvalidSaveCase(
			TEXT("Gameplay async immediate-failure null-save empty-slot path"),
			nullptr,
			FString()))
	{
		return false;
	}

	if (!RunInvalidSaveCase(
			TEXT("Gameplay async immediate-failure valid-save empty-slot path"),
			SaveGameObject,
			FString()))
	{
		return false;
	}

	if (!RunInvalidLoadCase(
			TEXT("Gameplay async immediate-failure empty-slot load path"),
			FString()))
	{
		return false;
	}

	if (!RunInvalidLoadCase(
			TEXT("Gameplay async immediate-failure missing-slot load path"),
			MissingSlotName))
	{
		return false;
	}

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
