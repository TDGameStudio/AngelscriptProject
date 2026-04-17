#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "Misc/StringOutputDevice.h"
#include "UObject/UObjectGlobals.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Actor_AngelscriptScriptSpawnedActorOverrideTests_Private
{
	constexpr float ScriptActorScenarioDeltaTime = 0.016f;
	constexpr int32 ScriptActorScenarioTickCount = 3;

	FAngelscriptEngine& AcquireFreshScriptActorEngine()
	{
		DestroySharedAndStrayGlobalTestEngine();
		return AcquireCleanSharedCloneEngine();
	}

	struct FSingleIntParam
	{
		int32 Value = 0;
	};

	void EnableScriptActorTick(AActor& Actor)
	{
		Actor.PrimaryActorTick.bCanEverTick = true;
		Actor.SetActorTickEnabled(true);
		Actor.RegisterAllActorTickFunctions(true, false);
	}

	UFunction* RequireGeneratedFunction(
		FAutomationTestBase& Test,
		UClass* OwnerClass,
		FName FunctionName,
		const TCHAR* Context)
	{
		UFunction* Function = FindGeneratedFunction(OwnerClass, FunctionName);
		Test.TestNotNull(
			*FString::Printf(TEXT("%s should find generated function '%s'"), Context, *FunctionName.ToString()),
			Function);
		return Function;
	}

	bool TryInvokeGeneratedFunction(FAngelscriptEngine& Engine, UObject* Object, UFunction* Function, void* Params = nullptr)
	{
		if (!::IsValid(Object) || Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope FunctionScope(Engine, Object);
		Object->ProcessEvent(Function, Params);
		return true;
	}

	bool SetObjectReferenceProperty(
		FAutomationTestBase& Test,
		UObject* Object,
		FName PropertyName,
		UObject* ReferencedObject,
		const TCHAR* Context)
	{
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should have a valid object"), Context), Object))
		{
			return false;
		}

		FObjectPropertyBase* Property = FindFProperty<FObjectPropertyBase>(Object->GetClass(), PropertyName);
		if (!Test.TestNotNull(
			*FString::Printf(TEXT("%s should expose object property '%s'"), Context, *PropertyName.ToString()),
			Property))
		{
			return false;
		}

		Property->SetObjectPropertyValue_InContainer(Object, ReferencedObject);
		return true;
	}
}

using namespace AngelscriptTest_Actor_AngelscriptScriptSpawnedActorOverrideTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptActorBeginPlayRunsInWorldTest,
	"Angelscript.TestModule.ScriptActor.BeginPlayRunsInWorld",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptActorNativeUFunctionCanBeInvokedTest,
	"Angelscript.TestModule.ScriptActor.NativeUFunctionCanBeInvoked",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptActorBeginPlayCallsAnotherScriptUFunctionTest,
	"Angelscript.TestModule.ScriptActor.BeginPlayCallsAnotherScriptUFunction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptActorTickRunsNTimesTest,
	"Angelscript.TestModule.ScriptActor.TickRunsNTimes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptActorCrossInstanceCallDoesNotLeakStateTest,
	"Angelscript.TestModule.ScriptActor.CrossInstanceCallDoesNotLeakState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptActorDestroyedActorInvocationFailsSafelyTest,
	"Angelscript.TestModule.ScriptActor.DestroyedActorInvocationFailsSafely",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptActorMissingFunctionReportsExplicitFailureTest,
	"Angelscript.TestModule.ScriptActor.MissingFunctionReportsExplicitFailure",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioScriptActorBeginPlayRunsInWorldTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptActorBeginPlayRunsInWorld"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptActorBeginPlayRunsInWorld.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptActorBeginPlayRunsInWorld : AActor
{
	UPROPERTY()
	int BeginPlayObserved = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayObserved = 1;
	}
}
)AS"),
		TEXT("AScenarioScriptActorBeginPlayRunsInWorld"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Scenario script-actor BeginPlay test should spawn the generated actor"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	int32 BeginPlayObserved = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("BeginPlayObserved"), BeginPlayObserved))
	{
		return false;
	}

	TestEqual(TEXT("Spawned script actor should observe BeginPlay when entering the test world"), BeginPlayObserved, 1);
	return true;
}

bool FAngelscriptScenarioScriptActorNativeUFunctionCanBeInvokedTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptActorNativeUFunctionCanBeInvoked"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptActorNativeUFunctionCanBeInvoked.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptActorNativeUFunctionCanBeInvoked : AActor
{
	UPROPERTY()
	int NativeInvokeObserved = 0;

	UPROPERTY()
	int LastNativeValue = 0;

	UFUNCTION()
	void ReceiveNativeValue(int Value)
	{
		NativeInvokeObserved = 1;
		LastNativeValue = Value;
	}
}
)AS"),
		TEXT("AScenarioScriptActorNativeUFunctionCanBeInvoked"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Scenario native-UFUNCTION actor should spawn"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	UFunction* Function = RequireGeneratedFunction(*this, Actor->GetClass(), TEXT("ReceiveNativeValue"), TEXT("Scenario native-UFUNCTION invocation"));
	if (Function == nullptr)
	{
		return false;
	}

	FSingleIntParam Params;
	Params.Value = 77;
	if (!TestTrue(TEXT("Scenario native-UFUNCTION invocation should succeed through ProcessEvent"), TryInvokeGeneratedFunction(Engine, Actor, Function, &Params)))
	{
		return false;
	}

	int32 NativeInvokeObserved = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("NativeInvokeObserved"), NativeInvokeObserved))
	{
		return false;
	}

	int32 LastNativeValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LastNativeValue"), LastNativeValue))
	{
		return false;
	}

	TestEqual(TEXT("Scenario native-UFUNCTION invocation should observe a reflected call into the script actor"), NativeInvokeObserved, 1);
	TestEqual(TEXT("Scenario native-UFUNCTION invocation should preserve the reflected integer argument"), LastNativeValue, 77);
	return true;
}

bool FAngelscriptScenarioScriptActorBeginPlayCallsAnotherScriptUFunctionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptActorBeginPlayCallsAnotherScriptUFunction"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptActorBeginPlayCallsAnotherScriptUFunction.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptActorBeginPlayCallsAnotherScriptUFunction : AActor
{
	UPROPERTY()
	int ScriptDispatchObserved = 0;

	UFUNCTION()
	void RecordDispatch()
	{
		ScriptDispatchObserved = 1;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RecordDispatch();
	}
}
)AS"),
		TEXT("AScenarioScriptActorBeginPlayCallsAnotherScriptUFunction"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Scenario script-dispatch actor should spawn"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	int32 ScriptDispatchObserved = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ScriptDispatchObserved"), ScriptDispatchObserved))
	{
		return false;
	}

	TestEqual(TEXT("Scenario script actor BeginPlay should dispatch into another script UFUNCTION"), ScriptDispatchObserved, 1);
	return true;
}

bool FAngelscriptScenarioScriptActorTickRunsNTimesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptActorTickRunsNTimes"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptActorTickRunsNTimes.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptActorTickRunsNTimes : AActor
{
	UPROPERTY()
	int LogicalTickCount = 0;

	UPROPERTY()
	float LastTickWorldTime = -1.0f;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		float CurrentTime = -1.0f;
		if (GetWorld() != null)
		{
			CurrentTime = GetWorld().TimeSeconds;
		}

		if (CurrentTime > LastTickWorldTime)
		{
			LogicalTickCount += 1;
			LastTickWorldTime = CurrentTime;
		}
	}
}
)AS"),
		TEXT("AScenarioScriptActorTickRunsNTimes"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	AActor* Actor = nullptr;
	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	Actor = Cast<AActor>(SpawnScriptActor(*this, Spawner, ScriptClass));
	if (!TestNotNull(TEXT("Scenario script-tick actor should spawn as an Angelscript actor"), Actor))
	{
		return false;
	}

	EnableScriptActorTick(*Actor);
	BeginPlayActor(Engine, *Actor);

	int32 InitialLogicalTickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LogicalTickCount"), InitialLogicalTickCount))
	{
		return false;
	}

	TickWorld(Engine, Spawner.GetWorld(), ScriptActorScenarioDeltaTime, ScriptActorScenarioTickCount);

	int32 FinalLogicalTickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LogicalTickCount"), FinalLogicalTickCount))
	{
		return false;
	}

	TestEqual(TEXT("Scenario script actor should advance one logical Tick per requested world tick"), FinalLogicalTickCount - InitialLogicalTickCount, ScriptActorScenarioTickCount);
	return true;
}

bool FAngelscriptScenarioScriptActorCrossInstanceCallDoesNotLeakStateTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptActorCrossInstanceCallDoesNotLeakState"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptActorCrossInstanceCallDoesNotLeakState.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptActorCrossInstanceCallDoesNotLeakState : AActor
{
	UPROPERTY()
	AScenarioScriptActorCrossInstanceCallDoesNotLeakState TargetActor;

	UPROPERTY()
	int LocalState = 0;

	UFUNCTION()
	void ReceiveSignal()
	{
		LocalState = 29;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		LocalState = 11;
		if (TargetActor != null)
		{
			TargetActor.ReceiveSignal();
		}
	}
}
)AS"),
		TEXT("AScenarioScriptActorCrossInstanceCallDoesNotLeakState"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* SourceActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	AActor* TargetActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Scenario cross-instance source actor should spawn"), SourceActor)
		|| !TestNotNull(TEXT("Scenario cross-instance target actor should spawn"), TargetActor))
	{
		return false;
	}

	if (!SetObjectReferenceProperty(
			*this,
			SourceActor,
			TEXT("TargetActor"),
			TargetActor,
			TEXT("Scenario cross-instance source actor")))
	{
		return false;
	}

	BeginPlayActor(Engine, *SourceActor);

	int32 SourceLocalState = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, SourceActor, TEXT("LocalState"), SourceLocalState))
	{
		return false;
	}

	int32 TargetLocalState = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, TargetActor, TEXT("LocalState"), TargetLocalState))
	{
		return false;
	}

	TestTrue(TEXT("Scenario cross-instance setup should produce distinct spawned actor instances"), SourceActor != TargetActor);
	TestEqual(TEXT("Scenario cross-instance source actor should retain its own local state"), SourceLocalState, 11);
	TestEqual(TEXT("Scenario cross-instance target actor should receive the dispatched state change without leaking back into the source"), TargetLocalState, 29);
	return true;
}

bool FAngelscriptScenarioScriptActorDestroyedActorInvocationFailsSafelyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptActorDestroyedActorInvocationFailsSafely"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptActorDestroyedActorInvocationFailsSafely.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptActorDestroyedInvocationTarget : AActor
{
	UPROPERTY()
	int InvocationValue = 0;

	UFUNCTION()
	void ReceiveInvocation(int Value)
	{
		InvocationValue = Value;
	}
}

UCLASS()
class AScenarioScriptActorDestroyedInvocationSource : AActor
{
	UPROPERTY()
	AScenarioScriptActorDestroyedInvocationTarget TargetActor;

	UPROPERTY()
	int FailedSafelyObserved = 0;

	UPROPERTY()
	int UnexpectedInvocationObserved = 0;

	UFUNCTION()
	void TriggerCallAfterDestroy()
	{
		if (TargetActor == null || !IsValid(TargetActor))
		{
			FailedSafelyObserved = 1;
			return;
		}

		TargetActor.ReceiveInvocation(33);
		UnexpectedInvocationObserved = 1;
	}
}
)AS"),
		TEXT("AScenarioScriptActorDestroyedInvocationSource"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	UClass* TargetClass = FindGeneratedClass(&Engine, TEXT("AScenarioScriptActorDestroyedInvocationTarget"));
	if (!TestNotNull(TEXT("Scenario destroyed-actor target class should be generated"), TargetClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* SourceActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	AActor* TargetActor = SpawnScriptActor(*this, Spawner, TargetClass);
	if (!TestNotNull(TEXT("Scenario destroyed-actor source actor should spawn"), SourceActor)
		|| !TestNotNull(TEXT("Scenario destroyed-actor target actor should spawn"), TargetActor))
	{
		return false;
	}

	if (!SetObjectReferenceProperty(
			*this,
			SourceActor,
			TEXT("TargetActor"),
			TargetActor,
			TEXT("Scenario destroyed-actor source actor")))
	{
		return false;
	}

	BeginPlayActor(Engine, *SourceActor);
	BeginPlayActor(Engine, *TargetActor);

	TWeakObjectPtr<AActor> WeakTargetActor = TargetActor;
	TargetActor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	if (!TestFalse(TEXT("Scenario destroyed actor should no longer be valid after teardown tick"), WeakTargetActor.IsValid()))
	{
		return false;
	}

	FStringOutputDevice Output;
	const bool bTriggeredSourceCall = SourceActor->CallFunctionByNameWithArguments(TEXT("TriggerCallAfterDestroy"), Output, nullptr, true);
	if (!TestTrue(TEXT("Scenario destroyed-actor source should still accept the trigger call after target teardown"), bTriggeredSourceCall))
	{
		return false;
	}

	int32 FailedSafelyObserved = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, SourceActor, TEXT("FailedSafelyObserved"), FailedSafelyObserved))
	{
		return false;
	}

	int32 UnexpectedInvocationObserved = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, SourceActor, TEXT("UnexpectedInvocationObserved"), UnexpectedInvocationObserved))
	{
		return false;
	}

	TestEqual(TEXT("Scenario destroyed actor call should fail safely inside script dispatch when the target was destroyed"), FailedSafelyObserved, 1);
	TestEqual(TEXT("Scenario destroyed actor call should not reach the destroyed target invocation body"), UnexpectedInvocationObserved, 0);
	return true;
}

bool FAngelscriptScenarioScriptActorMissingFunctionReportsExplicitFailureTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptActorMissingFunctionReportsExplicitFailure"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptActorMissingFunctionReportsExplicitFailure.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptActorMissingFunctionReportsExplicitFailure : AActor
{
	UPROPERTY()
	int StableValue = 1;
}
)AS"),
		TEXT("AScenarioScriptActorMissingFunctionReportsExplicitFailure"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Scenario missing-function test should spawn an actor"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	int32 StableValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("StableValue"), StableValue))
	{
		return false;
	}

	FStringOutputDevice Output;
	const bool bCallSucceeded = Actor->CallFunctionByNameWithArguments(TEXT("DoesNotExist"), Output, nullptr, true);

	TestEqual(TEXT("Scenario missing-function setup should keep the actor state readable before the failed invocation"), StableValue, 1);
	TestFalse(TEXT("Scenario missing-function invocation should return an explicit failure result when the named function does not exist"), bCallSucceeded);
	return true;
}

#endif
