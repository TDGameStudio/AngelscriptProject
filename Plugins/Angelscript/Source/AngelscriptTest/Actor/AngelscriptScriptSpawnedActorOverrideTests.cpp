#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptReflectiveAccess.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "Misc/StringOutputDevice.h"

// Test Layer: UE Functional
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;
using namespace AngelscriptReflectiveAccess;

namespace AngelscriptTest_Actor_AngelscriptScriptSpawnedActorOverrideTests_Private
{
	constexpr float ScriptActorTestCaseDeltaTime = 0.016f;
	constexpr int32 ScriptActorTestCaseTickCount = 3;

	FAngelscriptEngine& AcquireFreshScriptActorEngine()
	{
		DestroySharedAndStrayGlobalTestEngine();
		return AcquireCleanSharedCloneEngine();
	}

	void EnableScriptActorTick(AActor& Actor)
	{
		Actor.PrimaryActorTick.bCanEverTick = true;
		Actor.SetActorTickEnabled(true);
		Actor.RegisterAllActorTickFunctions(true, false);
	}
}

using namespace AngelscriptTest_Actor_AngelscriptScriptSpawnedActorOverrideTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestScriptActorBeginPlayRunsInWorldTest,
	"Angelscript.TestModule.ScriptActor.BeginPlayRunsInWorld",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestScriptActorNativeUFunctionCanBeInvokedTest,
	"Angelscript.TestModule.ScriptActor.NativeUFunctionCanBeInvoked",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestScriptActorBeginPlayCallsAnotherScriptUFunctionTest,
	"Angelscript.TestModule.ScriptActor.BeginPlayCallsAnotherScriptUFunction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestScriptActorTickRunsNTimesTest,
	"Angelscript.TestModule.ScriptActor.TickRunsNTimes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestScriptActorCrossInstanceCallDoesNotLeakStateTest,
	"Angelscript.TestModule.ScriptActor.CrossInstanceCallDoesNotLeakState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestScriptActorDestroyedActorInvocationFailsSafelyTest,
	"Angelscript.TestModule.ScriptActor.DestroyedActorInvocationFailsSafely",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestScriptActorMissingFunctionReportsExplicitFailureTest,
	"Angelscript.TestModule.ScriptActor.MissingFunctionReportsExplicitFailure",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestScriptActorBeginPlayRunsInWorldTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("TestScriptActorBeginPlayRunsInWorld"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestScriptActorBeginPlayRunsInWorld.as"),
		TEXT(R"AS(
UCLASS()
class ATestScriptActorBeginPlayRunsInWorld : AActor
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
		TEXT("ATestScriptActorBeginPlayRunsInWorld"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("TestCase script-actor BeginPlay test should spawn the generated actor"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	return VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("BeginPlayObserved"), 1,
		TEXT("Spawned script actor should observe BeginPlay when entering the test world"));
}

bool FAngelscriptTestScriptActorNativeUFunctionCanBeInvokedTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("TestScriptActorNativeUFunctionCanBeInvoked"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestScriptActorNativeUFunctionCanBeInvoked.as"),
		TEXT(R"AS(
UCLASS()
class ATestScriptActorNativeUFunctionCanBeInvoked : AActor
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
		TEXT("ATestScriptActorNativeUFunctionCanBeInvoked"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("TestCase native-UFUNCTION actor should spawn"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	FFunctionInvoker Invoker(*this, Actor, FName(TEXT("ReceiveNativeValue")));
	if (!Invoker.IsValid())
	{
		return false;
	}
	Invoker.AddParam<int32>(77);
	if (!TestTrue(TEXT("TestCase native-UFUNCTION invocation should succeed through reflective invocation"), Invoker.Call()))
	{
		return false;
	}

	const bool bObserved = VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("NativeInvokeObserved"), 1,
		TEXT("TestCase native-UFUNCTION invocation should observe a reflected call into the script actor"));
	const bool bValue = VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("LastNativeValue"), 77,
		TEXT("TestCase native-UFUNCTION invocation should preserve the reflected integer argument"));
	return bObserved && bValue;
}

bool FAngelscriptTestScriptActorBeginPlayCallsAnotherScriptUFunctionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("TestScriptActorBeginPlayCallsAnotherScriptUFunction"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestScriptActorBeginPlayCallsAnotherScriptUFunction.as"),
		TEXT(R"AS(
UCLASS()
class ATestScriptActorBeginPlayCallsAnotherScriptUFunction : AActor
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
		TEXT("ATestScriptActorBeginPlayCallsAnotherScriptUFunction"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("TestCase script-dispatch actor should spawn"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	return VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("ScriptDispatchObserved"), 1,
		TEXT("TestCase script actor BeginPlay should dispatch into another script UFUNCTION"));
}

bool FAngelscriptTestScriptActorTickRunsNTimesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("TestScriptActorTickRunsNTimes"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestScriptActorTickRunsNTimes.as"),
		TEXT(R"AS(
UCLASS()
class ATestScriptActorTickRunsNTimes : AActor
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
		TEXT("ATestScriptActorTickRunsNTimes"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	AActor* Actor = nullptr;
	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	Actor = Cast<AActor>(SpawnScriptActor(*this, Spawner, ScriptClass));
	if (!TestNotNull(TEXT("TestCase script-tick actor should spawn as an Angelscript actor"), Actor))
	{
		return false;
	}

	EnableScriptActorTick(*Actor);
	BeginPlayActor(Engine, *Actor);

	int32 InitialLogicalTickCount = 0;
	if (!GetByPath<FIntProperty, int32>(*this, Actor, TEXT("LogicalTickCount"), InitialLogicalTickCount))
	{
		return false;
	}

	TickWorld(Engine, Spawner.GetWorld(), ScriptActorTestCaseDeltaTime, ScriptActorTestCaseTickCount);

	int32 FinalLogicalTickCount = 0;
	if (!GetByPath<FIntProperty, int32>(*this, Actor, TEXT("LogicalTickCount"), FinalLogicalTickCount))
	{
		return false;
	}

	return TestEqual(TEXT("TestCase script actor should advance one logical Tick per requested world tick"),
		FinalLogicalTickCount - InitialLogicalTickCount,
		ScriptActorTestCaseTickCount);
}

bool FAngelscriptTestScriptActorCrossInstanceCallDoesNotLeakStateTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("TestScriptActorCrossInstanceCallDoesNotLeakState"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestScriptActorCrossInstanceCallDoesNotLeakState.as"),
		TEXT(R"AS(
UCLASS()
class ATestScriptActorCrossInstanceCallDoesNotLeakState : AActor
{
	UPROPERTY()
	ATestScriptActorCrossInstanceCallDoesNotLeakState TargetActor;

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
		TEXT("ATestScriptActorCrossInstanceCallDoesNotLeakState"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* SourceActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	AActor* TargetActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("TestCase cross-instance source actor should spawn"), SourceActor)
		|| !TestNotNull(TEXT("TestCase cross-instance target actor should spawn"), TargetActor))
	{
		return false;
	}

	if (!SetObjectByPath(*this, SourceActor, TEXT("TargetActor"), TargetActor))
	{
		return false;
	}

	BeginPlayActor(Engine, *SourceActor);

	const bool bDistinctActors = TestTrue(TEXT("TestCase cross-instance setup should produce distinct spawned actor instances"), SourceActor != TargetActor);
	const bool bSourceState = VerifyByPath<FIntProperty, int32>(*this, SourceActor, TEXT("LocalState"), 11,
		TEXT("TestCase cross-instance source actor should retain its own local state"));
	const bool bTargetState = VerifyByPath<FIntProperty, int32>(*this, TargetActor, TEXT("LocalState"), 29,
		TEXT("TestCase cross-instance target actor should receive the dispatched state change without leaking back into the source"));
	return bDistinctActors && bSourceState && bTargetState;
}

bool FAngelscriptTestScriptActorDestroyedActorInvocationFailsSafelyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("TestScriptActorDestroyedActorInvocationFailsSafely"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestScriptActorDestroyedActorInvocationFailsSafely.as"),
		TEXT(R"AS(
UCLASS()
class ATestScriptActorDestroyedInvocationTarget : AActor
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
class ATestScriptActorDestroyedInvocationSource : AActor
{
	UPROPERTY()
	ATestScriptActorDestroyedInvocationTarget TargetActor;

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
		TEXT("ATestScriptActorDestroyedInvocationSource"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	UClass* TargetClass = FindGeneratedClass(&Engine, TEXT("ATestScriptActorDestroyedInvocationTarget"));
	if (!TestNotNull(TEXT("TestCase destroyed-actor target class should be generated"), TargetClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* SourceActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	AActor* TargetActor = SpawnScriptActor(*this, Spawner, TargetClass);
	if (!TestNotNull(TEXT("TestCase destroyed-actor source actor should spawn"), SourceActor)
		|| !TestNotNull(TEXT("TestCase destroyed-actor target actor should spawn"), TargetActor))
	{
		return false;
	}

	if (!SetObjectByPath(*this, SourceActor, TEXT("TargetActor"), TargetActor))
	{
		return false;
	}

	BeginPlayActor(Engine, *SourceActor);
	BeginPlayActor(Engine, *TargetActor);

	TWeakObjectPtr<AActor> WeakTargetActor = TargetActor;
	TargetActor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	if (!TestFalse(TEXT("TestCase destroyed actor should no longer be valid after teardown tick"), WeakTargetActor.IsValid()))
	{
		return false;
	}

	FStringOutputDevice Output;
	const bool bTriggeredSourceCall = SourceActor->CallFunctionByNameWithArguments(TEXT("TriggerCallAfterDestroy"), Output, nullptr, true);
	if (!TestTrue(TEXT("TestCase destroyed-actor source should still accept the trigger call after target teardown"), bTriggeredSourceCall))
	{
		return false;
	}

	const bool bFailedSafely = VerifyByPath<FIntProperty, int32>(*this, SourceActor, TEXT("FailedSafelyObserved"), 1,
		TEXT("TestCase destroyed actor call should fail safely inside script dispatch when the target was destroyed"));
	const bool bNoUnexpectedInvocation = VerifyByPath<FIntProperty, int32>(*this, SourceActor, TEXT("UnexpectedInvocationObserved"), 0,
		TEXT("TestCase destroyed actor call should not reach the destroyed target invocation body"));
	return bFailedSafely && bNoUnexpectedInvocation;
}

bool FAngelscriptTestScriptActorMissingFunctionReportsExplicitFailureTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AcquireFreshScriptActorEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("TestScriptActorMissingFunctionReportsExplicitFailure"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestScriptActorMissingFunctionReportsExplicitFailure.as"),
		TEXT(R"AS(
UCLASS()
class ATestScriptActorMissingFunctionReportsExplicitFailure : AActor
{
	UPROPERTY()
	int StableValue = 1;
}
)AS"),
		TEXT("ATestScriptActorMissingFunctionReportsExplicitFailure"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("TestCase missing-function test should spawn an actor"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	FStringOutputDevice Output;
	const bool bCallSucceeded = Actor->CallFunctionByNameWithArguments(TEXT("DoesNotExist"), Output, nullptr, true);

	const bool bStableValue = VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("StableValue"), 1,
		TEXT("TestCase missing-function setup should keep the actor state readable before the failed invocation"));
	const bool bMissingCallFailed = TestFalse(
		TEXT("TestCase missing-function invocation should return an explicit failure result when the named function does not exist"),
		bCallSucceeded);
	return bStableValue && bMissingCallFailed;
}

#endif
