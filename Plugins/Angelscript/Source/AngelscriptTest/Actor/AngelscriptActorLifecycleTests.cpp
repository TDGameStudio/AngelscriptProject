#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;

namespace AngelscriptTest_Actor_AngelscriptActorLifecycleTests_Private
{
	constexpr float LifecycleScenarioDeltaTime = 0.016f;
}

using namespace AngelscriptTest_Actor_AngelscriptActorLifecycleTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorBeginPlayTest,
	"Angelscript.TestModule.Actor.BeginPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorTickTest,
	"Angelscript.TestModule.Actor.Tick",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorReceiveEndPlayTest,
	"Angelscript.TestModule.Actor.ReceiveEndPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorReceiveDestroyedTest,
	"Angelscript.TestModule.Actor.ReceiveDestroyed",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorResetTest,
	"Angelscript.TestModule.Actor.Reset",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestActorBeginPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
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
	int BeginPlayCalled = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCalled = 1;
	}
}
)AS"),
		TEXT("ATestActorBeginPlay"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}
	BeginPlayActor(Engine, *Actor);

	int32 BeginPlayCalled = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("BeginPlayCalled"), BeginPlayCalled))
	{
		return false;
	}

	TestEqual(TEXT("BeginPlay should run when the script actor is spawned into the test world"), BeginPlayCalled, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptTestActorTickTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
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
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount += 1;
	}
}
)AS"),
		TEXT("ATestActorTick"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = Cast<AActor>(SpawnScriptActor(*this, Spawner, ScriptClass));
	if (!TestNotNull(TEXT("Scenario tick actor should spawn as an AActor"), Actor))
	{
		return false;
	}

	Actor->PrimaryActorTick.bCanEverTick = true;
	Actor->SetActorTickEnabled(true);
	Actor->RegisterAllActorTickFunctions(true, false);
	BeginPlayActor(Engine, *Actor);
	TickWorld(Engine, Spawner.GetWorld(), LifecycleScenarioDeltaTime, 5);

	int32 TickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("TickCount"), TickCount))
	{
		return false;
	}

	TestTrue(TEXT("Tick should execute at least once per manual world tick"), TickCount >= 5);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptTestActorReceiveEndPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
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
	int EndPlayCalled = 0;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCalled = 1;
	}
}
)AS"),
		TEXT("ATestActorReceiveEndPlay"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);
	Actor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	int32 EndPlayCalled = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("EndPlayCalled"), EndPlayCalled))
	{
		return false;
	}

	TestEqual(TEXT("ReceiveEndPlay should run when the script actor is destroyed"), EndPlayCalled, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptTestActorReceiveDestroyedTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
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
	int DestroyedCalled = 0;

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCalled = 1;
	}
}
)AS"),
		TEXT("ATestActorReceiveDestroyed"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);
	Actor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	int32 DestroyedCalled = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("DestroyedCalled"), DestroyedCalled))
	{
		return false;
	}

	TestEqual(TEXT("ReceiveDestroyed should run when the script actor is destroyed"), DestroyedCalled, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptTestActorResetTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
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
	int ResetValue = 3;

	UFUNCTION(BlueprintOverride)
	void OnReset()
	{
		ResetValue = 7;
	}
}
)AS"),
		TEXT("ATestActorReset"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);
	FIntProperty* ResetValueProperty = FindFProperty<FIntProperty>(Actor->GetClass(), TEXT("ResetValue"));
	if (!TestNotNull(TEXT("Reset scenario property should exist"), ResetValueProperty))
	{
		return false;
	}
	ResetValueProperty->SetPropertyValue_InContainer(Actor, 99);
	Actor->Reset();

	int32 ResetValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ResetValue"), ResetValue))
	{
		return false;
	}

	TestEqual(TEXT("Reset should route through the script override and restore the expected value"), ResetValue, 7);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
