#include "Shared/AngelscriptFunctionalTestUtils.h"
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
	using namespace AngelscriptFunctionalTestUtils;

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
	FAngelscriptTestComponentBeginPlayTest,
	"Angelscript.TestModule.Component.BeginPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestComponentTickTest,
	"Angelscript.TestModule.Component.Tick",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestComponentReceiveEndPlayTest,
	"Angelscript.TestModule.Component.ReceiveEndPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestComponentActorOwnerTest,
	"Angelscript.TestModule.Component.ActorOwner",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestDefaultComponentBasicTest,
	"Angelscript.TestModule.DefaultComponent.Basic",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestDefaultComponentMultipleTest,
	"Angelscript.TestModule.DefaultComponent.Multiple",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestDefaultComponentNativeTypesTest,
	"Angelscript.TestModule.DefaultComponent.NativeTypes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestComponentBeginPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestComponentBeginPlay"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestComponentBeginPlay.as"),
		TEXT(R"AS(
UCLASS()
class UTestComponentBeginPlay : UAngelscriptComponent
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
		TEXT("UTestComponentBeginPlay"));
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

bool FAngelscriptTestComponentTickTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestComponentTick"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestComponentTick.as"),
		TEXT(R"AS(
UCLASS()
class UTestComponentTick : UAngelscriptComponent
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
		TEXT("UTestComponentTick"));
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

bool FAngelscriptTestComponentReceiveEndPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestComponentReceiveEndPlay"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestComponentReceiveEndPlay.as"),
		TEXT(R"AS(
UCLASS()
class UTestComponentReceiveEndPlay : UAngelscriptComponent
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
		TEXT("UTestComponentReceiveEndPlay"));
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

bool FAngelscriptTestComponentActorOwnerTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestComponentActorOwner"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* OwnerActorClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestComponentActorOwner.as"),
		TEXT(R"AS(
UCLASS()
class ATestComponentOwnerActor : AActor
{
	UPROPERTY()
	int OwnerValue = 42;
}

UCLASS()
class UTestComponentActorOwner : UAngelscriptComponent
{
	UPROPERTY()
	int ReadOwnerValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ATestComponentOwnerActor OwnerActor = Cast<ATestComponentOwnerActor>(GetOwner());
		if (OwnerActor != null)
		{
			ReadOwnerValue = OwnerActor.OwnerValue;
		}
	}
}
)AS"),
		TEXT("ATestComponentOwnerActor"));
	if (OwnerActorClass == nullptr)
	{
		return false;
	}

	UClass* ComponentClass = FindGeneratedClass(&Engine, TEXT("UTestComponentActorOwner"));
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

bool FAngelscriptTestDefaultComponentBasicTest::RunTest(const FString& Parameters)
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
	static const FName ModuleName(TEXT("TestDefaultComponentBasic"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestDefaultComponentBasic.as"),
		TEXT(R"AS(
UCLASS()
class UTestDefaultComponentBasicRoot : USceneComponent
{
}

UCLASS()
class ATestDefaultComponentBasic : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestDefaultComponentBasicRoot RootScene;
}
)AS"),
		TEXT("ATestDefaultComponentBasic"));
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

	UClass* RootComponentClass = FindGeneratedClass(&Engine, TEXT("UTestDefaultComponentBasicRoot"));
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

bool FAngelscriptTestDefaultComponentMultipleTest::RunTest(const FString& Parameters)
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
	static const FName ModuleName(TEXT("TestDefaultComponentMultiple"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestDefaultComponentMultiple.as"),
		TEXT(R"AS(
UCLASS()
class UTestDefaultComponentMultipleRoot : USceneComponent
{
}

UCLASS()
class UTestDefaultComponentMultipleBillboard : UBillboardComponent
{
}

UCLASS()
class ATestDefaultComponentMultiple : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestDefaultComponentMultipleRoot RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UTestDefaultComponentMultipleBillboard Billboard;
}
)AS"),
		TEXT("ATestDefaultComponentMultiple"));
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

	UClass* RootSceneClass = FindGeneratedClass(&Engine, TEXT("UTestDefaultComponentMultipleRoot"));
	UClass* BillboardClass = FindGeneratedClass(&Engine, TEXT("UTestDefaultComponentMultipleBillboard"));
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

bool FAngelscriptTestDefaultComponentNativeTypesTest::RunTest(const FString& Parameters)
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
	static const FName ModuleName(TEXT("TestDefaultComponentNativeTypes"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestDefaultComponentNativeTypes.as"),
		TEXT(R"AS(
UCLASS()
class ATestDefaultComponentNativeTypes : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent Mesh;

	UPROPERTY(DefaultComponent, Attach = Mesh)
	UBillboardComponent Billboard;
}
)AS"),
		TEXT("ATestDefaultComponentNativeTypes"));
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

// ============================================================================
// Deep Attach Chain (3 layers: Root -> Mid -> Leaf)
// ============================================================================

namespace DeepAttachChainTest
{
	static const FName ModuleName(TEXT("ASComponent.DeepAttachChain"));
	static const FString ScriptFilename(TEXT("ASComponent_DeepAttachChain.as"));
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultComponentDeepAttachChainTest,
	"Angelscript.TestModule.Component.DefaultComponent.DeepAttachChain",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultComponentDeepAttachChainTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptTestSupport;

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DeepAttachChainTest::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DeepAttachChainTest::ModuleName,
		DeepAttachChainTest::ScriptFilename,
		TEXT(R"AS(
UCLASS()
class ADeepAttachActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USceneComponent MidScene;

	UPROPERTY(DefaultComponent, Attach = MidScene)
	USceneComponent LeafScene;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Deep attach chain should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("ADeepAttachActor"));
	if (!TestNotNull(TEXT("Class should be materialized"), GeneratedClass))
		return false;

	FProperty* MidProp = GeneratedClass->FindPropertyByName(TEXT("MidScene"));
	FProperty* LeafProp = GeneratedClass->FindPropertyByName(TEXT("LeafScene"));
	TestNotNull(TEXT("MidScene property should exist on class"), MidProp);
	TestNotNull(TEXT("LeafScene property should exist on class"), LeafProp);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// OverrideComponent multi-layer inheritance (A -> B -> C)
// ============================================================================

namespace OverrideMultiLayerTest
{
	static const FName ModuleName(TEXT("ASComponent.OverrideMultiLayer"));
	static const FString ScriptFilename(TEXT("ASComponent_OverrideMultiLayer.as"));
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptOverrideComponentMultiLayerTest,
	"Angelscript.TestModule.Component.DefaultComponent.OverrideComponentMultiLayerInheritance",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptOverrideComponentMultiLayerTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptTestSupport;

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*OverrideMultiLayerTest::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		OverrideMultiLayerTest::ModuleName,
		OverrideMultiLayerTest::ScriptFilename,
		TEXT(R"AS(
UCLASS()
class ABaseLayerActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USceneComponent BaseChild;
}

UCLASS()
class AMidLayerActor : ABaseLayerActor
{
	UPROPERTY(OverrideComponent = BaseChild)
	UStaticMeshComponent MidReplacement;
}

UCLASS()
class ATopLayerActor : AMidLayerActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent TopExtra;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Multi-layer OverrideComponent should compile"), bCompiled))
		return false;

	UClass* TopClass = FindGeneratedClass(&Engine, TEXT("ATopLayerActor"));
	TestNotNull(TEXT("Top layer class should be materialized"), TopClass);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Native actor (ACharacter) with extra script DefaultComponent
// ============================================================================

namespace NativeActorExtraComponentTest
{
	static const FName ModuleName(TEXT("ASComponent.NativeActorExtra"));
	static const FString ScriptFilename(TEXT("ASComponent_NativeActorExtra.as"));
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptNativeActorWithExtraComponentTest,
	"Angelscript.TestModule.Component.DefaultComponent.NativeActorWithExtraScriptComponent",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptNativeActorWithExtraComponentTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptTestSupport;

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*NativeActorExtraComponentTest::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		NativeActorExtraComponentTest::ModuleName,
		NativeActorExtraComponentTest::ScriptFilename,
		TEXT(R"AS(
UCLASS()
class AExtendedCharacter : ACharacter
{
	UPROPERTY(DefaultComponent)
	USceneComponent ExtraMarker;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Native actor with extra script component should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("AExtendedCharacter"));
	TestNotNull(TEXT("Extended character class should be materialized"), GeneratedClass);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// OverrideComponent metadata multi-layer verification
// ============================================================================

namespace OverrideMetadataMultiLayerTest
{
	static const FName ModuleName(TEXT("ASComponent.OverrideMetadataMultiLayer"));
	static const FString ScriptFilename(TEXT("ASComponent_OverrideMetadataMultiLayer.as"));
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptOverrideComponentMetadataMultiLayerTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.OverrideComponentMetadataMultiLayer",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptOverrideComponentMetadataMultiLayerTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptTestSupport;

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*OverrideMetadataMultiLayerTest::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		OverrideMetadataMultiLayerTest::ModuleName,
		OverrideMetadataMultiLayerTest::ScriptFilename,
		TEXT(R"AS(
UCLASS()
class AMetaBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USceneComponent MetaChild;
}

UCLASS()
class AMetaMidActor : AMetaBaseActor
{
	UPROPERTY(OverrideComponent = MetaChild)
	UStaticMeshComponent MidMetaReplacement;
}

UCLASS()
class AMetaTopActor : AMetaMidActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent TopMetaExtra;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Override metadata multi-layer should compile"), bCompiled))
		return false;

	UClass* TopClass = FindGeneratedClass(&Engine, TEXT("AMetaTopActor"));
	if (!TestNotNull(TEXT("Top class should exist"), TopClass))
		return false;

	UClass* MidClass = FindGeneratedClass(&Engine, TEXT("AMetaMidActor"));
	if (!TestNotNull(TEXT("Mid class should exist"), MidClass))
		return false;

	UClass* BaseClass = FindGeneratedClass(&Engine, TEXT("AMetaBaseActor"));
	if (!TestNotNull(TEXT("Base class should exist"), BaseClass))
		return false;

	TestTrue(TEXT("Top class should inherit from Mid"), TopClass->IsChildOf(MidClass));
	TestTrue(TEXT("Mid class should inherit from Base"), MidClass->IsChildOf(BaseClass));

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
