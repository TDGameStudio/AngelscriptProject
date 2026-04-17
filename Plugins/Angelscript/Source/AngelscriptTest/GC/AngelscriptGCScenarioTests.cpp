#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptComponent.h"
#include "Components/ActorTestSpawner.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_GC_AngelscriptGCScenarioTests_Private
{
	using namespace AngelscriptScenarioTestUtils;

	void InitializeGCScenarioSpawner(FActorTestSpawner& Spawner)
	{
		Spawner.InitializeGameSubsystems();
	}

	template <typename ComponentType = UActorComponent>
	ComponentType* CreateGCScenarioScriptComponent(
		FAutomationTestBase& Test,
		AActor& OwnerActor,
		UClass* ComponentClass,
		const TCHAR* Context)
	{
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should compile to a valid component class"), Context), ComponentClass))
		{
			return nullptr;
		}

		UActorComponent* Component = NewObject<UActorComponent>(&OwnerActor, ComponentClass);
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should instantiate a runtime component"), Context), Component))
		{
			return nullptr;
		}

		OwnerActor.AddInstanceComponent(Component);
		Component->OnComponentCreated();
		Component->RegisterComponent();
		Component->Activate(true);

		ComponentType* TypedComponent = Cast<ComponentType>(Component);
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should produce the expected component base type"), Context), TypedComponent))
		{
			return nullptr;
		}

		return TypedComponent;
	}
}

using namespace AngelscriptTest_GC_AngelscriptGCScenarioTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioGCActorDestroyTest,
	"Angelscript.TestModule.GC.ActorDestroy",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioGCComponentDestroyTest,
	"Angelscript.TestModule.GC.ComponentDestroy",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioGCWorldTeardownTest,
	"Angelscript.TestModule.GC.WorldTeardown",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioGCActorDestroyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioGCActorDestroy"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioGCActorDestroy.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioGCActorDestroy : AActor
{
}
)AS"),
		TEXT("AScenarioGCActorDestroy"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeGCScenarioSpawner(Spawner);
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}
	BeginPlayActor(Engine, *Actor);

	TWeakObjectPtr<AActor> WeakActor = Actor;
	Actor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);
	CollectGarbage(RF_NoFlags, true);

	TestTrue(TEXT("Scenario GC actor destroy should complete without leaving a live actor reference"), !WeakActor.IsValid());
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioGCComponentDestroyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioGCComponentDestroy"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ComponentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioGCComponentDestroy.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioGCComponentDestroy : UAngelscriptComponent
{
}
)AS"),
		TEXT("UScenarioGCComponentDestroy"));
	if (ComponentClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeGCScenarioSpawner(Spawner);
	AActor& HostActor = Spawner.SpawnActor<AActor>();
	UActorComponent* Component = CreateGCScenarioScriptComponent(*this, HostActor, ComponentClass, TEXT("GC.ComponentDestroy"));
	if (Component == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UActorComponent> WeakComponent = Component;
	Component->DestroyComponent();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);
	CollectGarbage(RF_NoFlags, true);

	TestTrue(TEXT("Scenario GC component destroy should complete without leaving a live component reference"), !WeakComponent.IsValid());
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioGCWorldTeardownTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioGCWorldTeardown"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ActorClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioGCWorldTeardown.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioGCWorldTeardownActor : AActor
{
}

UCLASS()
class UScenarioGCWorldTeardownComponent : UAngelscriptComponent
{
}
)AS"),
		TEXT("AScenarioGCWorldTeardownActor"));
	if (ActorClass == nullptr)
	{
		return false;
	}

	UClass* ComponentClass = FindGeneratedClass(&Engine, TEXT("UScenarioGCWorldTeardownComponent"));
	if (!TestNotNull(TEXT("Scenario GC world-teardown component class should exist"), ComponentClass))
	{
		return false;
	}

	TWeakObjectPtr<UWorld> WeakWorld;
	TWeakObjectPtr<AActor> WeakActor;
	TWeakObjectPtr<UActorComponent> WeakComponent;
	{
		FActorTestSpawner Spawner;
	InitializeGCScenarioSpawner(Spawner);
		WeakWorld = &Spawner.GetWorld();

		AActor* Actor = SpawnScriptActor(*this, Spawner, ActorClass);
		if (Actor == nullptr)
		{
			return false;
		}
		BeginPlayActor(Engine, *Actor);

	UActorComponent* Component = CreateGCScenarioScriptComponent(*this, *Actor, ComponentClass, TEXT("GC.WorldTeardown"));
		if (Component == nullptr)
		{
			return false;
		}

		WeakActor = Actor;
		WeakComponent = Component;
	}

	CollectGarbage(RF_NoFlags, true);
	TestTrue(TEXT("Scenario GC world teardown should release the world after scope cleanup"), !WeakWorld.IsValid());
	TestTrue(TEXT("Scenario GC world teardown should release spawned actors after scope cleanup"), !WeakActor.IsValid());
	TestTrue(TEXT("Scenario GC world teardown should release spawned components after scope cleanup"), !WeakComponent.IsValid());
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
