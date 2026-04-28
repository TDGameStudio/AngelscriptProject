#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptReflectiveAccess.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Engine/EngineTypes.h"
#include "Engine/World.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Functional
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;
using namespace AngelscriptReflectiveAccess;

namespace AngelscriptTest_Actor_AngelscriptActorLifecycleTests_Private
{
	constexpr float LifecycleTestCaseDeltaTime = 0.016f;

	void EnableLifecycleActorTick(AActor& Actor)
	{
		Actor.PrimaryActorTick.bCanEverTick = true;
		Actor.SetActorTickEnabled(true);
		Actor.RegisterAllActorTickFunctions(true, false);
	}

	void TickWorldThroughTickManager(FAngelscriptEngine& Engine, UWorld& World, float DeltaTime, int32 NumTicks)
	{
		for (int32 TickIndex = 0; TickIndex < NumTicks; ++TickIndex)
		{
			FAngelscriptEngineScope WorldScope(Engine);
			World.Tick(ELevelTick::LEVELTICK_All, DeltaTime);
		}
	}
}

using namespace AngelscriptTest_Actor_AngelscriptActorLifecycleTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorBeginPlayTest,
	"Angelscript.TestModule.Actor.BeginPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorBeginPlayIdempotentTest,
	"Angelscript.TestModule.Actor.BeginPlayIdempotent",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorTickTest,
	"Angelscript.TestModule.Actor.Tick",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorTickRegisteredDispatchTest,
	"Angelscript.TestModule.Actor.TickRegisteredDispatch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorReceiveEndPlayTest,
	"Angelscript.TestModule.Actor.ReceiveEndPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorReceiveEndPlayReasonTest,
	"Angelscript.TestModule.Actor.ReceiveEndPlayReason",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorDestroyLifecycleOrderTest,
	"Angelscript.TestModule.Actor.DestroyLifecycleOrder",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorReceiveDestroyedTest,
	"Angelscript.TestModule.Actor.ReceiveDestroyed",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorConstructionScriptTest,
	"Angelscript.TestModule.Actor.ConstructionScript",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorResetTest,
	"Angelscript.TestModule.Actor.Reset",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestActorBeginPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorBeginPlay"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorBeginPlay.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorBeginPlay : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestActorBeginPlay"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("BeginPlay actor should spawn successfully"), Actor))
	{
		break;
	}
	BeginPlayActor(Engine, *Actor);

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), 1,
		TEXT("BeginPlay should run exactly once when the script actor is spawned"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorBeginPlayIdempotentTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorBeginPlayIdempotent"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorBeginPlayIdempotent.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorBeginPlayIdempotent : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestActorBeginPlayIdempotent"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("BeginPlay idempotent actor should spawn successfully"), Actor))
	{
		break;
	}

	BeginPlayActor(Engine, *Actor);
	BeginPlayActor(Engine, *Actor);

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), 1,
		TEXT("BeginPlay helper should not dispatch BeginPlay again after the actor has begun play"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorTickTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorTick"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorTick.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorTick : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastDeltaTime = 0.0f;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		EventCallCount += 1;
		LastDeltaTime = DeltaTime;
	}
}
)AS"),
		TEXT("ATestActorTick"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Tick actor should spawn successfully"), Actor))
	{
		break;
	}

	EnableLifecycleActorTick(*Actor);
	BeginPlayActor(Engine, *Actor);
	TickWorld(Engine, Spawner.GetWorld(), LifecycleTestCaseDeltaTime, 5);

	int32 EventCallCount = 0;
	if (!GetByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), EventCallCount))
	{
		break;
	}
	TestTrue(TEXT("Tick should execute at least once per manual world tick"), EventCallCount >= 5);

	double LastDeltaTime = 0.0;
	if (!GetByPath<FDoubleProperty, double>(*this, Actor, TEXT("LastDeltaTime"), LastDeltaTime))
	{
		break;
	}
	TestTrue(TEXT("Tick should receive a positive DeltaTime"), LastDeltaTime > 0.0);
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorTickRegisteredDispatchTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorTickRegisteredDispatch"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorTickRegisteredDispatch.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorTickRegisteredDispatch : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastDeltaTime = 0.0f;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		EventCallCount += 1;
		LastDeltaTime = DeltaTime;
	}
}
)AS"),
		TEXT("ATestActorTickRegisteredDispatch"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Registered tick dispatch actor should spawn successfully"), Actor))
	{
		break;
	}

	EnableLifecycleActorTick(*Actor);
	BeginPlayActor(Engine, *Actor);
	TestTrue(TEXT("Registered tick dispatch actor should have a registered PrimaryActorTick"),
		Actor->PrimaryActorTick.IsTickFunctionRegistered());

	constexpr int32 NumTicks = 3;
	TickWorldThroughTickManager(Engine, Spawner.GetWorld(), LifecycleTestCaseDeltaTime, NumTicks);

	int32 EventCallCount = 0;
	if (!GetByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), EventCallCount))
	{
		break;
	}
	TestTrue(TEXT("World tick manager should dispatch the registered script actor Tick at least once"), EventCallCount >= 1);

	double LastDeltaTime = 0.0;
	if (!GetByPath<FDoubleProperty, double>(*this, Actor, TEXT("LastDeltaTime"), LastDeltaTime))
	{
		break;
	}
	TestTrue(TEXT("World tick manager should pass a positive DeltaTime into the script actor Tick"), LastDeltaTime > 0.0);
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorReceiveEndPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorReceiveEndPlay"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorReceiveEndPlay.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorReceiveEndPlay : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestActorReceiveEndPlay"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("EndPlay actor should spawn successfully"), Actor))
	{
		break;
	}

	BeginPlayActor(Engine, *Actor);
	Actor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), 1,
		TEXT("EndPlay should run exactly once when the script actor is destroyed"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorReceiveEndPlayReasonTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorReceiveEndPlayReason"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorReceiveEndPlayReason.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorReceiveEndPlayReason : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	EEndPlayReason LastReason = EEndPlayReason::Quit;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		LastReason = Reason;
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestActorReceiveEndPlayReason"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("EndPlay reason actor should spawn successfully"), Actor))
	{
		break;
	}

	BeginPlayActor(Engine, *Actor);
	Actor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), 1,
		TEXT("EndPlay should run exactly once before capturing the destroy reason"));

	int64 LastReason = -1;
	if (!GetEnumByPath(*this, Actor, TEXT("LastReason"), LastReason))
	{
		break;
	}
	TestEqual(TEXT("EndPlay should receive EEndPlayReason::Destroyed when Destroy() is called"),
		LastReason,
		static_cast<int64>(EEndPlayReason::Destroyed));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorDestroyLifecycleOrderTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorDestroyLifecycleOrder"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorDestroyLifecycleOrder.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorDestroyLifecycleOrder : AActor
{
	UPROPERTY()
	int EndPlayCallCount = 0;

	UPROPERTY()
	int DestroyedCallCount = 0;

	UPROPERTY()
	int NextOrder = 0;

	UPROPERTY()
	int EndPlayOrder = 0;

	UPROPERTY()
	int DestroyedOrder = 0;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCallCount += 1;
		NextOrder += 1;
		EndPlayOrder = NextOrder;
	}

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCallCount += 1;
		NextOrder += 1;
		DestroyedOrder = NextOrder;
	}
}
)AS"),
		TEXT("ATestActorDestroyLifecycleOrder"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Destroy lifecycle order actor should spawn successfully"), Actor))
	{
		break;
	}

	BeginPlayActor(Engine, *Actor);
	Actor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EndPlayCallCount"), 1,
		TEXT("Destroy() should dispatch EndPlay exactly once"));
	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("DestroyedCallCount"), 1,
		TEXT("Destroy() should dispatch Destroyed exactly once"));
	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EndPlayOrder"), 1,
		TEXT("EndPlay should run before Destroyed during actor destruction"));
	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("DestroyedOrder"), 2,
		TEXT("Destroyed should run after EndPlay during actor destruction"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorReceiveDestroyedTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorReceiveDestroyed"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorReceiveDestroyed.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorReceiveDestroyed : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestActorReceiveDestroyed"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Destroyed actor should spawn successfully"), Actor))
	{
		break;
	}

	BeginPlayActor(Engine, *Actor);
	Actor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), 1,
		TEXT("Destroyed should run exactly once when the script actor is destroyed"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorConstructionScriptTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorConstructionScript"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorConstructionScript.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorConstructionScript : AActor
{
	UPROPERTY()
	int ConstructionCallCount = 0;

	UPROPERTY()
	int ValueA = 3;

	UPROPERTY()
	int ValueB = 4;

	UPROPERTY()
	int Product = 0;

	UFUNCTION(BlueprintOverride)
	void UserConstructionScript()
	{
		ConstructionCallCount += 1;
		Product = ValueA * ValueB;
	}
}
)AS"),
		TEXT("ATestActorConstructionScript"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("ConstructionScript actor should spawn successfully"), Actor))
	{
		break;
	}

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("ConstructionCallCount"), 1,
		TEXT("ConstructionScript should run once during actor spawn"));
	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("Product"), 12,
		TEXT("ConstructionScript should write derived property values during actor spawn"));

	if (!SetByPath<FIntProperty, int32>(*this, Actor, TEXT("ValueA"), 5)
		|| !SetByPath<FIntProperty, int32>(*this, Actor, TEXT("ValueB"), 6))
	{
		break;
	}

	{
		FAngelscriptEngineScope ActorScope(Engine, Actor);
		Actor->RerunConstructionScripts();
	}

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("ConstructionCallCount"), 2,
		TEXT("RerunConstructionScripts should dispatch the script ConstructionScript again"));
	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("Product"), 30,
		TEXT("RerunConstructionScripts should recompute derived property values from reflected state"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorResetTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorReset"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorReset.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorReset : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	int ResetValue = 3;

	UFUNCTION(BlueprintOverride)
	void OnReset()
	{
		ResetValue = 7;
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestActorReset"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Reset actor should spawn successfully"), Actor))
	{
		break;
	}

	BeginPlayActor(Engine, *Actor);
	if (!SetByPath<FIntProperty, int32>(*this, Actor, TEXT("ResetValue"), 99))
	{
		break;
	}
	Actor->Reset();

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), 1,
		TEXT("OnReset should run exactly once when Reset() is called"));
	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("ResetValue"), 7,
		TEXT("OnReset should write the expected sentinel value into ResetValue"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

#endif
