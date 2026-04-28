#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptComponent.h"
#include "Components/ActorTestSpawner.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"

// Test Layer: UE Functional
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_GC_AngelscriptGCTestCaseTests_Private
{
	using namespace AngelscriptFunctionalTestUtils;

	void InitializeGCTestCaseSpawner(FActorTestSpawner& Spawner)
	{
		Spawner.InitializeGameSubsystems();
	}

	template <typename ComponentType = UActorComponent>
	ComponentType* CreateGCTestCaseScriptComponent(
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

using namespace AngelscriptTest_GC_AngelscriptGCTestCaseTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestGCActorDestroyTest,
	"Angelscript.TestModule.GC.ActorDestroy",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestGCComponentDestroyTest,
	"Angelscript.TestModule.GC.ComponentDestroy",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestGCWorldTeardownTest,
	"Angelscript.TestModule.GC.WorldTeardown",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestGCActorDestroyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestGCActorDestroy"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestGCActorDestroy.as"),
		TEXT(R"AS(
UCLASS()
class ATestGCActorDestroy : AActor
{
}
)AS"),
		TEXT("ATestGCActorDestroy"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeGCTestCaseSpawner(Spawner);
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

	TestTrue(TEXT("TestCase GC actor destroy should complete without leaving a live actor reference"), !WeakActor.IsValid());
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptTestGCComponentDestroyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestGCComponentDestroy"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ComponentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestGCComponentDestroy.as"),
		TEXT(R"AS(
UCLASS()
class UTestGCComponentDestroy : UAngelscriptComponent
{
}
)AS"),
		TEXT("UTestGCComponentDestroy"));
	if (ComponentClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeGCTestCaseSpawner(Spawner);
	AActor& HostActor = Spawner.SpawnActor<AActor>();
	UActorComponent* Component = CreateGCTestCaseScriptComponent(*this, HostActor, ComponentClass, TEXT("GC.ComponentDestroy"));
	if (Component == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UActorComponent> WeakComponent = Component;
	Component->DestroyComponent();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);
	CollectGarbage(RF_NoFlags, true);

	TestTrue(TEXT("TestCase GC component destroy should complete without leaving a live component reference"), !WeakComponent.IsValid());
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptTestGCWorldTeardownTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestGCWorldTeardown"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ActorClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestGCWorldTeardown.as"),
		TEXT(R"AS(
UCLASS()
class ATestGCWorldTeardownActor : AActor
{
}

UCLASS()
class UTestGCWorldTeardownComponent : UAngelscriptComponent
{
}
)AS"),
		TEXT("ATestGCWorldTeardownActor"));
	if (ActorClass == nullptr)
	{
		return false;
	}

	UClass* ComponentClass = FindGeneratedClass(&Engine, TEXT("UTestGCWorldTeardownComponent"));
	if (!TestNotNull(TEXT("TestCase GC world-teardown component class should exist"), ComponentClass))
	{
		return false;
	}

	TWeakObjectPtr<UWorld> WeakWorld;
	TWeakObjectPtr<AActor> WeakActor;
	TWeakObjectPtr<UActorComponent> WeakComponent;
	{
		FActorTestSpawner Spawner;
	InitializeGCTestCaseSpawner(Spawner);
		WeakWorld = &Spawner.GetWorld();

		AActor* Actor = SpawnScriptActor(*this, Spawner, ActorClass);
		if (Actor == nullptr)
		{
			return false;
		}
		BeginPlayActor(Engine, *Actor);

	UActorComponent* Component = CreateGCTestCaseScriptComponent(*this, *Actor, ComponentClass, TEXT("GC.WorldTeardown"));
		if (Component == nullptr)
		{
			return false;
		}

		WeakActor = Actor;
		WeakComponent = Component;
	}

	CollectGarbage(RF_NoFlags, true);
	TestTrue(TEXT("TestCase GC world teardown should release the world after scope cleanup"), !WeakWorld.IsValid());
	TestTrue(TEXT("TestCase GC world teardown should release spawned actors after scope cleanup"), !WeakActor.IsValid());
	TestTrue(TEXT("TestCase GC world teardown should release spawned components after scope cleanup"), !WeakComponent.IsValid());
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
