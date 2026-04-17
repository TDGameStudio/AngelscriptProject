#include "Shared/AngelscriptScenarioTestUtils.h"

#include "Shared/AngelscriptNativeScriptTestObject.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/ScriptDelegates.h"
#include "UObject/UnrealType.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Delegate_AngelscriptDelegateScenarioTests_Private
{
	using namespace AngelscriptScenarioTestUtils;

	FAngelscriptEngine& AcquireFreshDelegateEngine()
	{
		DestroySharedAndStrayGlobalTestEngine();
		return AcquireCleanSharedCloneEngine();
	}

	struct FScenarioIntStringParams
	{
		int32 Value = 0;
		FString Label;
	};

	void InitializeDelegateScenarioSpawner(FActorTestSpawner& Spawner)
	{
		Spawner.InitializeGameSubsystems();
	}

	void ExpectDelegateSignatureMismatchLogs(
		FAutomationTestBase& Test,
		const TCHAR* ScenarioName,
		const TCHAR* DelegateCallSignature,
		const TCHAR* TriggerSignature)
	{
		Test.AddExpectedErrorPlain(TEXT("Signature mismatch while executing 'MarkNativeFlagFromDelegate': too many arguments were pushed."), EAutomationExpectedErrorFlags::Contains, -1);
		Test.AddExpectedErrorPlain(ScenarioName, EAutomationExpectedErrorFlags::Contains, -1);
		Test.AddExpectedErrorPlain(DelegateCallSignature, EAutomationExpectedErrorFlags::Contains, -1);
		Test.AddExpectedErrorPlain(TriggerSignature, EAutomationExpectedErrorFlags::Contains, -1);
	}
}

using namespace AngelscriptTest_Delegate_AngelscriptDelegateScenarioTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioDelegateUnicastTest,
	"Angelscript.TestModule.Delegate.Unicast",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioDelegateMulticastTest,
	"Angelscript.TestModule.Delegate.Multicast",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioDelegateUnicastSignatureMismatchTest,
	"Angelscript.TestModule.Delegate.UnicastSignatureMismatch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioDelegateMulticastSignatureMismatchTest,
	"Angelscript.TestModule.Delegate.MulticastSignatureMismatch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioDelegateUnicastTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshDelegateEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioDelegateUnicast"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioDelegateUnicast.as"),
		TEXT(R"AS(
delegate void FOnHealthChanged(int32 NewHealth, const FString& Label);

UCLASS()
class AScenarioDelegateUnicast : AActor
{
	UPROPERTY()
	FOnHealthChanged OnHealthChanged;

	UFUNCTION()
	void TriggerHealthChanged(int32 NewHealth, const FString& Label)
	{
		if (OnHealthChanged.IsBound())
		{
			OnHealthChanged.Execute(NewHealth, Label);
		}
	}
}
)AS"),
		TEXT("AScenarioDelegateUnicast"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeDelegateScenarioSpawner(Spawner);
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Scenario unicast delegate actor should spawn"), Actor))
	{
		return false;
	}
	BeginPlayActor(Engine, *Actor);

	UAngelscriptNativeScriptTestObject* NativeReceiver = NewObject<UAngelscriptNativeScriptTestObject>(GetTransientPackage());
	if (!TestNotNull(TEXT("Scenario unicast delegate test should create a native receiver"), NativeReceiver))
	{
		return false;
	}
	NativeReceiver->NameCounts.Reset();

	FDelegateProperty* DelegateProperty = FindFProperty<FDelegateProperty>(Actor->GetClass(), TEXT("OnHealthChanged"));
	if (!TestNotNull(TEXT("Scenario unicast delegate property should exist"), DelegateProperty))
	{
		return false;
	}

	FScriptDelegate BoundDelegate;
	BoundDelegate.BindUFunction(NativeReceiver, TEXT("SetIntStringFromDelegate"));
	*DelegateProperty->ContainerPtrToValuePtr<FScriptDelegate>(Actor) = BoundDelegate;

	UFunction* TriggerFunction = FindGeneratedFunction(ScriptClass, TEXT("TriggerHealthChanged"));
	if (!TestNotNull(TEXT("Scenario unicast trigger function should exist"), TriggerFunction))
	{
		return false;
	}

	FScenarioIntStringParams Params;
	Params.Value = 77;
	Params.Label = TEXT("Unicast");
	{
		FAngelscriptEngineScope ExecutionScope(Engine, Actor);
		Actor->ProcessEvent(TriggerFunction, &Params);
	}

	TestEqual(TEXT("Scenario unicast delegate should invoke the bound C++ callback"), NativeReceiver->NameCounts.FindRef(TEXT("Unicast")), 77);
	return true;
}

bool FAngelscriptScenarioDelegateMulticastTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshDelegateEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioDelegateMulticast"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioDelegateMulticast.as"),
		TEXT(R"AS(
event void FOnDamaged(int32 NewHealth, const FString& Label);

UCLASS()
class AScenarioDelegateMulticast : AActor
{
	UPROPERTY()
	FOnDamaged OnDamaged;

	UPROPERTY()
	int EventTriggerCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnDamaged.AddUFunction(this, n"HandleDamaged");
	}

	UFUNCTION()
	void HandleDamaged(int32 NewHealth, const FString& Label)
	{
		EventTriggerCount += 1;
	}
}
)AS"),
		TEXT("AScenarioDelegateMulticast"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeDelegateScenarioSpawner(Spawner);
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Scenario multicast delegate actor should spawn"), Actor))
	{
		return false;
	}
	BeginPlayActor(Engine, *Actor);

	int32 InitialEventTriggerCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("EventTriggerCount"), InitialEventTriggerCount))
	{
		return false;
	}

	FMulticastInlineDelegateProperty* MulticastProperty = FindFProperty<FMulticastInlineDelegateProperty>(Actor->GetClass(), TEXT("OnDamaged"));
	if (!TestNotNull(TEXT("Scenario multicast delegate property should exist"), MulticastProperty))
	{
		return false;
	}

	FMulticastScriptDelegate* MulticastDelegate = MulticastProperty->ContainerPtrToValuePtr<FMulticastScriptDelegate>(Actor);
	if (!TestNotNull(TEXT("Scenario multicast delegate storage should exist"), MulticastDelegate))
	{
		return false;
	}

	FScenarioIntStringParams Params;
	Params.Value = 33;
	Params.Label = TEXT("Multicast");
	{
		FAngelscriptEngineScope ExecutionScope(Engine, Actor);
		MulticastDelegate->ProcessMulticastDelegate<UObject>(&Params);
	}

	int32 EventTriggerCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("EventTriggerCount"), EventTriggerCount))
	{
		return false;
	}

	TestTrue(TEXT("Scenario multicast delegate should invoke the script handler when broadcast from C++"), EventTriggerCount > InitialEventTriggerCount);
	return true;
}

bool FAngelscriptScenarioDelegateUnicastSignatureMismatchTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshDelegateEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioDelegateUnicastSignatureMismatch"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioDelegateUnicastSignatureMismatch.as"),
		TEXT(R"AS(
delegate void FOnHealthChanged(int32 NewHealth, const FString& Label);

UCLASS()
class AScenarioDelegateUnicastSignatureMismatch : AActor
{
	UPROPERTY()
	FOnHealthChanged OnHealthChanged;

	UFUNCTION()
	void TriggerHealthChanged(int32 NewHealth, const FString& Label)
	{
		if (OnHealthChanged.IsBound())
		{
			OnHealthChanged.Execute(NewHealth, Label);
		}
	}
}
)AS"),
		TEXT("AScenarioDelegateUnicastSignatureMismatch"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeDelegateScenarioSpawner(Spawner);
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Scenario unicast mismatch actor should spawn"), Actor))
	{
		return false;
	}
	BeginPlayActor(Engine, *Actor);

	UAngelscriptNativeScriptTestObject* NativeReceiver = NewObject<UAngelscriptNativeScriptTestObject>(GetTransientPackage());
	if (!TestNotNull(TEXT("Scenario unicast mismatch test should create a native receiver"), NativeReceiver))
	{
		return false;
	}
	NativeReceiver->bNativeFlag = false;

	FDelegateProperty* DelegateProperty = FindFProperty<FDelegateProperty>(Actor->GetClass(), TEXT("OnHealthChanged"));
	if (!TestNotNull(TEXT("Scenario unicast mismatch delegate property should exist"), DelegateProperty))
	{
		return false;
	}

	FScriptDelegate BoundDelegate;
	BoundDelegate.BindUFunction(NativeReceiver, TEXT("MarkNativeFlagFromDelegate"));
	*DelegateProperty->ContainerPtrToValuePtr<FScriptDelegate>(Actor) = BoundDelegate;

	UFunction* TriggerFunction = FindGeneratedFunction(ScriptClass, TEXT("TriggerHealthChanged"));
	if (!TestNotNull(TEXT("Scenario unicast mismatch trigger function should exist"), TriggerFunction))
	{
		return false;
	}

	FScenarioIntStringParams Params;
	Params.Value = 91;
	Params.Label = TEXT("UnicastMismatch");
	ExpectDelegateSignatureMismatchLogs(
		*this,
		TEXT("ScenarioDelegateUnicastSignatureMismatch"),
		TEXT("void FOnHealthChanged::Execute(int, FString) const"),
		TEXT("void AScenarioDelegateUnicastSignatureMismatch::TriggerHealthChanged(int, FString)"));
	{
		FAngelscriptEngineScope ExecutionScope(Engine, Actor);
		Actor->ProcessEvent(TriggerFunction, &Params);
	}

	TestFalse(TEXT("Scenario unicast mismatch should not invoke a zero-argument native receiver"), NativeReceiver->bNativeFlag);
	return true;
}

bool FAngelscriptScenarioDelegateMulticastSignatureMismatchTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshDelegateEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioDelegateMulticastSignatureMismatch"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioDelegateMulticastSignatureMismatch.as"),
		TEXT(R"AS(
event void FOnDamaged(int32 NewHealth, const FString& Label);

UCLASS()
class AScenarioDelegateMulticastSignatureMismatch : AActor
{
	UPROPERTY()
	FOnDamaged OnDamaged;

	UFUNCTION()
	void TriggerDamaged(int32 NewHealth, const FString& Label)
	{
		OnDamaged.Broadcast(NewHealth, Label);
	}
}
)AS"),
		TEXT("AScenarioDelegateMulticastSignatureMismatch"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeDelegateScenarioSpawner(Spawner);
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Scenario multicast mismatch actor should spawn"), Actor))
	{
		return false;
	}
	BeginPlayActor(Engine, *Actor);

	UAngelscriptNativeScriptTestObject* NativeReceiver = NewObject<UAngelscriptNativeScriptTestObject>(GetTransientPackage());
	if (!TestNotNull(TEXT("Scenario multicast mismatch test should create a native receiver"), NativeReceiver))
	{
		return false;
	}
	NativeReceiver->bNativeFlag = false;

	FMulticastInlineDelegateProperty* MulticastProperty = FindFProperty<FMulticastInlineDelegateProperty>(Actor->GetClass(), TEXT("OnDamaged"));
	if (!TestNotNull(TEXT("Scenario multicast mismatch delegate property should exist"), MulticastProperty))
	{
		return false;
	}

	FMulticastScriptDelegate* MulticastDelegate = MulticastProperty->ContainerPtrToValuePtr<FMulticastScriptDelegate>(Actor);
	if (!TestNotNull(TEXT("Scenario multicast mismatch delegate storage should exist"), MulticastDelegate))
	{
		return false;
	}

	FScriptDelegate BoundDelegate;
	BoundDelegate.BindUFunction(NativeReceiver, TEXT("MarkNativeFlagFromDelegate"));
	MulticastDelegate->Add(BoundDelegate);

	UFunction* TriggerFunction = FindGeneratedFunction(ScriptClass, TEXT("TriggerDamaged"));
	if (!TestNotNull(TEXT("Scenario multicast mismatch trigger function should exist"), TriggerFunction))
	{
		return false;
	}

	FScenarioIntStringParams Params;
	Params.Value = 45;
	Params.Label = TEXT("MulticastMismatch");
	ExpectDelegateSignatureMismatchLogs(
		*this,
		TEXT("ScenarioDelegateMulticastSignatureMismatch"),
		TEXT("void FOnDamaged::Broadcast(int, FString) const"),
		TEXT("void AScenarioDelegateMulticastSignatureMismatch::TriggerDamaged(int, FString)"));
	{
		FAngelscriptEngineScope ExecutionScope(Engine, Actor);
		Actor->ProcessEvent(TriggerFunction, &Params);
	}

	TestFalse(TEXT("Scenario multicast mismatch should not invoke a zero-argument native receiver"), NativeReceiver->bNativeFlag);
	return true;
}

#endif
