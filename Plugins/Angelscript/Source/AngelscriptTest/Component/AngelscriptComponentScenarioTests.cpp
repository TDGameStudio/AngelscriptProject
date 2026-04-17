#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptComponent.h"
#include "Components/ActorTestSpawner.h"
#include "Components/BillboardComponent.h"
#include "Components/SceneComponent.h"
#include "Components/StaticMeshComponent.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Component_AngelscriptComponentScenarioTests_Private
{
	using namespace AngelscriptScenarioTestUtils;

	constexpr float ComponentScenarioDeltaTime = 0.016f;

	void InitializeComponentScenarioSpawner(FActorTestSpawner& Spawner)
	{
		Spawner.InitializeGameSubsystems();
	}

	template <typename ComponentType = UActorComponent>
	ComponentType* CreateComponentScenarioScriptComponent(
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

using namespace AngelscriptTest_Component_AngelscriptComponentScenarioTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioComponentBeginPlayTest,
	"Angelscript.TestModule.Component.BeginPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioComponentTickTest,
	"Angelscript.TestModule.Component.Tick",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioComponentReceiveEndPlayTest,
	"Angelscript.TestModule.Component.ReceiveEndPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioComponentActorOwnerTest,
	"Angelscript.TestModule.Component.ActorOwner",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioDefaultComponentBasicTest,
	"Angelscript.TestModule.DefaultComponent.Basic",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioDefaultComponentMultipleTest,
	"Angelscript.TestModule.DefaultComponent.Multiple",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioDefaultComponentNativeTypesTest,
	"Angelscript.TestModule.DefaultComponent.NativeTypes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioComponentBeginPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioComponentBeginPlay"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioComponentBeginPlay.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioComponentBeginPlay : UAngelscriptComponent
{
	UPROPERTY()
	bool bReady = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bReady = true;
	}
}
)AS"),
		TEXT("UScenarioComponentBeginPlay"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeComponentScenarioSpawner(Spawner);
	AActor& HostActor = Spawner.SpawnActor<AActor>();
	UActorComponent* Component = CreateComponentScenarioScriptComponent(*this, HostActor, ScriptClass, TEXT("Component.BeginPlay"));
	if (Component == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, HostActor);

	bool bReady = false;
	if (!ReadPropertyValue<FBoolProperty>(*this, Component, TEXT("bReady"), bReady))
	{
		return false;
	}

	TestTrue(TEXT("Scenario component BeginPlay should set the readiness flag"), bReady);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioComponentTickTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioComponentTick"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioComponentTick.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioComponentTick : UAngelscriptComponent
{
	UPROPERTY()
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}
)AS"),
		TEXT("UScenarioComponentTick"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeComponentScenarioSpawner(Spawner);
	AActor& HostActor = Spawner.SpawnActor<AActor>();
	UActorComponent* Component = CreateComponentScenarioScriptComponent(*this, HostActor, ScriptClass, TEXT("Component.Tick"));
	if (Component == nullptr)
	{
		return false;
	}

	Component->PrimaryComponentTick.bCanEverTick = true;
	Component->SetComponentTickEnabled(true);
	BeginPlayActor(Engine, HostActor);
	TickWorld(Engine, Spawner.GetWorld(), ComponentScenarioDeltaTime, 5);

	int32 TickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Component, TEXT("TickCount"), TickCount))
	{
		return false;
	}

	TestTrue(TEXT("Scenario component Tick should run during manual world ticking"), TickCount >= 5);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioComponentReceiveEndPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioComponentReceiveEndPlay"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioComponentReceiveEndPlay.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioComponentReceiveEndPlay : UAngelscriptComponent
{
	UPROPERTY()
	bool bCleanedUp = false;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		bCleanedUp = true;
	}
}
)AS"),
		TEXT("UScenarioComponentReceiveEndPlay"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeComponentScenarioSpawner(Spawner);
	AActor& HostActor = Spawner.SpawnActor<AActor>();
	UActorComponent* Component = CreateComponentScenarioScriptComponent(*this, HostActor, ScriptClass, TEXT("Component.ReceiveEndPlay"));
	if (Component == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, HostActor);
	HostActor.Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	bool bCleanedUp = false;
	if (!ReadPropertyValue<FBoolProperty>(*this, Component, TEXT("bCleanedUp"), bCleanedUp))
	{
		return false;
	}

	TestTrue(TEXT("Scenario component EndPlay should run when the owning actor is destroyed"), bCleanedUp);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioComponentActorOwnerTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioComponentActorOwner"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* OwnerActorClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioComponentActorOwner.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioComponentOwnerActor : AActor
{
	UPROPERTY()
	int OwnerValue = 42;
}

UCLASS()
class UScenarioComponentActorOwner : UAngelscriptComponent
{
	UPROPERTY()
	int ReadOwnerValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AScenarioComponentOwnerActor OwnerActor = Cast<AScenarioComponentOwnerActor>(GetOwner());
		if (OwnerActor != null)
		{
			ReadOwnerValue = OwnerActor.OwnerValue;
		}
	}
}
)AS"),
		TEXT("AScenarioComponentOwnerActor"));
	if (OwnerActorClass == nullptr)
	{
		return false;
	}

	UClass* ComponentClass = FindGeneratedClass(&Engine, TEXT("UScenarioComponentActorOwner"));
	if (!TestNotNull(TEXT("Scenario component owner-access class should be generated"), ComponentClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeComponentScenarioSpawner(Spawner);
	AActor* HostActor = SpawnScriptActor(*this, Spawner, OwnerActorClass);
	if (HostActor == nullptr)
	{
		return false;
	}

	UActorComponent* Component = CreateComponentScenarioScriptComponent(*this, *HostActor, ComponentClass, TEXT("Component.ActorOwner"));
	if (Component == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *HostActor);

	int32 ReadOwnerValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Component, TEXT("ReadOwnerValue"), ReadOwnerValue))
	{
		return false;
	}

	TestEqual(TEXT("Scenario component should read the owning script actor's property in BeginPlay"), ReadOwnerValue, 42);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioDefaultComponentBasicTest::RunTest(const FString& Parameters)
{
	DestroySharedTestEngine();
	FActorTestSpawner Spawner;
	InitializeComponentScenarioSpawner(Spawner);
	FAngelscriptEngine* ProductionEngine = RequireRunningProductionEngine(*this, TEXT("Default component scenario tests require a production engine after subsystem initialization."));
	if (ProductionEngine == nullptr)
	{
		return false;
	}
	FAngelscriptEngine& Engine = *ProductionEngine;
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioDefaultComponentBasic"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioDefaultComponentBasic.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioDefaultComponentBasicRoot : USceneComponent
{
}

UCLASS()
class AScenarioDefaultComponentBasic : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UScenarioDefaultComponentBasicRoot RootScene;
}
)AS"),
		TEXT("AScenarioDefaultComponentBasic"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	UClass* RootComponentClass = FindGeneratedClass(&Engine, TEXT("UScenarioDefaultComponentBasicRoot"));
	if (!TestNotNull(TEXT("Scenario default-component root class should be generated"), RootComponentClass))
	{
		return false;
	}

	USceneComponent* RootComponent = Actor->GetRootComponent();
	if (!TestNotNull(TEXT("Scenario actor should create a default root component"), RootComponent))
	{
		return false;
	}

	TestTrue(TEXT("Scenario actor root component should be the scripted default component"), RootComponent->IsA(RootComponentClass));
	return true;
}

bool FAngelscriptScenarioDefaultComponentMultipleTest::RunTest(const FString& Parameters)
{
	DestroySharedTestEngine();
	FActorTestSpawner Spawner;
	InitializeComponentScenarioSpawner(Spawner);
	FAngelscriptEngine* ProductionEngine = RequireRunningProductionEngine(*this, TEXT("Default component scenario tests require a production engine after subsystem initialization."));
	if (ProductionEngine == nullptr)
	{
		return false;
	}
	FAngelscriptEngine& Engine = *ProductionEngine;
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioDefaultComponentMultiple"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioDefaultComponentMultiple.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioDefaultComponentMultipleRoot : USceneComponent
{
}

UCLASS()
class UScenarioDefaultComponentMultipleBillboard : UBillboardComponent
{
}

UCLASS()
class AScenarioDefaultComponentMultiple : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UScenarioDefaultComponentMultipleRoot RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UScenarioDefaultComponentMultipleBillboard Billboard;
}
)AS"),
		TEXT("AScenarioDefaultComponentMultiple"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	UClass* RootSceneClass = FindGeneratedClass(&Engine, TEXT("UScenarioDefaultComponentMultipleRoot"));
	UClass* BillboardClass = FindGeneratedClass(&Engine, TEXT("UScenarioDefaultComponentMultipleBillboard"));
	if (!TestNotNull(TEXT("Scenario multi-default root class should be generated"), RootSceneClass)
		|| !TestNotNull(TEXT("Scenario multi-default child class should be generated"), BillboardClass))
	{
		return false;
	}

	USceneComponent* RootScene = Actor->GetRootComponent();
	if (!TestNotNull(TEXT("Scenario actor should create a scripted root scene component"), RootScene))
	{
		return false;
	}
	if (!TestTrue(TEXT("Scenario actor root component should use the scripted root component class"), RootScene->IsA(RootSceneClass)))
	{
		return false;
	}

	UBillboardComponent* Billboard = nullptr;
	for (UActorComponent* Component : Actor->GetComponents())
	{
		if (Component != nullptr && Component->IsA(BillboardClass))
		{
			Billboard = Cast<UBillboardComponent>(Component);
			break;
		}
	}
	if (!TestNotNull(TEXT("Scenario actor should create the attached billboard component"), Billboard))
	{
		return false;
	}

	TestTrue(TEXT("Scenario actor attached default component should preserve the scripted hierarchy"), Billboard->GetAttachParent() == RootScene);
	return true;
}

bool FAngelscriptScenarioDefaultComponentNativeTypesTest::RunTest(const FString& Parameters)
{
	DestroySharedTestEngine();
	FActorTestSpawner Spawner;
	InitializeComponentScenarioSpawner(Spawner);
	FAngelscriptEngine* ProductionEngine = RequireRunningProductionEngine(*this, TEXT("Default component scenario tests require a production engine after subsystem initialization."));
	if (ProductionEngine == nullptr)
	{
		return false;
	}
	FAngelscriptEngine& Engine = *ProductionEngine;
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioDefaultComponentNativeTypes"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioDefaultComponentNativeTypes.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioDefaultComponentNativeTypes : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent Mesh;

	UPROPERTY(DefaultComponent, Attach = Mesh)
	UBillboardComponent Billboard;
}
)AS"),
		TEXT("AScenarioDefaultComponentNativeTypes"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	USceneComponent* RootScene = Actor->GetRootComponent();
	if (!TestNotNull(TEXT("Scenario actor should create a native static mesh root component"), RootScene))
	{
		return false;
	}
	if (!TestTrue(TEXT("Scenario actor root component should use UStaticMeshComponent"), RootScene->IsA(UStaticMeshComponent::StaticClass())))
	{
		return false;
	}

	UBillboardComponent* Billboard = nullptr;
	for (UActorComponent* Component : Actor->GetComponents())
	{
		if (UBillboardComponent* TypedBillboard = Cast<UBillboardComponent>(Component))
		{
			Billboard = TypedBillboard;
			break;
		}
	}
	if (!TestNotNull(TEXT("Scenario actor should create the native billboard component"), Billboard))
	{
		return false;
	}

	TestTrue(TEXT("Scenario actor native billboard component should attach to the native mesh root"), Billboard->GetAttachParent() == RootScene);
	return true;
}

#endif
