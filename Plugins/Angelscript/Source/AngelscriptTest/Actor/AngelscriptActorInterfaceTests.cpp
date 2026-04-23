#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptReflectiveAccess.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Components/SceneComponent.h"
#include "GameFramework/Controller.h"
#include "GameFramework/Pawn.h"
#include "GameFramework/PlayerController.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;
using namespace AngelscriptReflectiveAccess;

namespace AngelscriptTest_Actor_AngelscriptActorInterfaceTests_Private
{
	int32 CallScriptIntFunction(FAutomationTestBase& Test, AActor* Actor, FName FunctionName)
	{
		FFunctionInvoker Invoker(Test, Actor, FunctionName);
		if (!Invoker.IsValid())
		{
			return INDEX_NONE;
		}

		return Invoker.CallAndReturn<int32>(INDEX_NONE);
	}

	int32 CallScriptIntFunctionWithPlayerController(
		FAutomationTestBase& Test,
		AActor* Actor,
		FName FunctionName,
		APlayerController* PlayerController)
	{
		FFunctionInvoker Invoker(Test, Actor, FunctionName);
		if (!Invoker.IsValid())
		{
			return INDEX_NONE;
		}

		Invoker.AddParam<APlayerController*>(PlayerController);
		return Invoker.CallAndReturn<int32>(INDEX_NONE);
	}

	int32 CallScriptIntFunctionWithInstigator(
		FAutomationTestBase& Test,
		AActor* Actor,
		FName FunctionName,
		APawn* InstigatorPawn,
		AController* InstigatorController)
	{
		FFunctionInvoker Invoker(Test, Actor, FunctionName);
		if (!Invoker.IsValid())
		{
			return INDEX_NONE;
		}

		Invoker.AddParam<APawn*>(InstigatorPawn);
		Invoker.AddParam<AController*>(InstigatorController);
		return Invoker.CallAndReturn<int32>(INDEX_NONE);
	}
}

using namespace AngelscriptTest_Actor_AngelscriptActorInterfaceTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorInterfaceBoundMethodsTest,
	"Angelscript.TestModule.Actor.Interface.BoundMethods",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorInterfaceComponentAndInputTest,
	"Angelscript.TestModule.Actor.Interface.ComponentAndInput",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorInterfaceSpawnAndQueryTest,
	"Angelscript.TestModule.Actor.Interface.SpawnAndQuery",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestActorInterfaceBoundMethodsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorInterfaceBoundMethods"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorInterfaceBoundMethods.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorInterfaceBoundMethods : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UFUNCTION()
	int CheckBeforeBeginPlay()
	{
		if (!IsActorInitialized())
			return 10;
		if (HasActorBegunPlay())
			return 20;
		if (!IsHidden())
			return 30;
		if (!GetActorLocation().Equals(FVector(10.0, 20.0, 30.0)))
			return 40;
		if (!GetActorRotation().Equals(FRotator(5.0, 45.0, 15.0), 0.01))
			return 50;

		SetActorScale3D(FVector(2.0, 3.0, 4.0));
		SetActorTickInterval(0.25f);

		if (GetActorNameOrLabel().Len() <= 0)
			return 60;
		if (!IsValid(GetGameInstance()))
			return 70;

		return 1;
	}

	UFUNCTION()
	int CheckInstigator(APawn ExpectedPawn, AController ExpectedController)
	{
		if (GetActorInstigator() != ExpectedPawn)
			return 100;
		if (GetActorInstigatorController() != ExpectedController)
			return 110;

		return 1;
	}

	UFUNCTION()
	int CheckAfterBeginPlay()
	{
		if (!HasActorBegunPlay())
			return 80;
		if (!GetActorLocation().Equals(FVector(10.0, 20.0, 30.0)))
			return 90;

		return 1;
	}
}
)AS"),
		TEXT("ATestActorInterfaceBoundMethods"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(
		*this,
		Spawner,
		ScriptClass,
		FActorSpawnParameters(),
		FVector(10.0, 20.0, 30.0),
		FRotator(5.0, 45.0, 15.0));
	if (!TestNotNull(TEXT("Actor interface bound-method actor should spawn"), Actor))
	{
		break;
	}

	Actor->SetActorHiddenInGame(true);

	TestEqual(
		TEXT("AActor bound methods should report expected pre-BeginPlay state and mutate scale/tick interval"),
		CallScriptIntFunction(*this, Actor, TEXT("CheckBeforeBeginPlay")),
		1);
	TestTrue(
		TEXT("SetActorScale3D binding should update native actor scale"),
		Actor->GetActorScale3D().Equals(FVector(2.0, 3.0, 4.0)));
	TestTrue(
		TEXT("SetActorTickInterval binding should update native tick interval"),
		FMath::IsNearlyEqual(Actor->PrimaryActorTick.TickInterval, 0.25f));

	APawn& InstigatorPawn = Spawner.SpawnActor<APawn>();
	APlayerController& InstigatorController = Spawner.SpawnActor<APlayerController>();
	InstigatorController.Possess(&InstigatorPawn);
	Actor->SetInstigator(&InstigatorPawn);

	TestEqual(
		TEXT("AActor instigator bindings should return native instigator references"),
		CallScriptIntFunctionWithInstigator(*this, Actor, TEXT("CheckInstigator"), &InstigatorPawn, &InstigatorController),
		1);

	BeginPlayActor(Engine, *Actor);
	TestEqual(
		TEXT("AActor bound methods should report expected post-BeginPlay state"),
		CallScriptIntFunction(*this, Actor, TEXT("CheckAfterBeginPlay")),
		1);
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorInterfaceComponentAndInputTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorInterfaceComponentAndInput"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorInterfaceComponentAndInput.as"),
		TEXT(R"AS(
UCLASS()
class UTestActorInterfaceRootComponent : USceneComponent
{
}

UCLASS()
class UTestActorInterfaceExtraComponent : USceneComponent
{
}

UCLASS()
class ATestActorInterfaceComponentAndInput : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestActorInterfaceRootComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UTestActorInterfaceExtraComponent ExtraScene;

	UFUNCTION()
	int CheckComponentsAndInput(APlayerController Controller)
	{
		TArray<USceneComponent> SceneComponents;
		GetComponentsByClass(SceneComponents);
		if (SceneComponents.Num() != 2)
			return 10;

		TArray<UTestActorInterfaceExtraComponent> ExtraComponents;
		GetComponentsByClass(UTestActorInterfaceExtraComponent::StaticClass(), ExtraComponents);
		if (ExtraComponents.Num() != 1)
			return 20;

		TArray<UActorComponent> ActorComponents;
		GetComponentsByClass(USceneComponent::StaticClass(), ActorComponents);
		if (ActorComponents.Num() != 2)
			return 30;

		if (GetInputComponent() != nullptr)
			return 40;
		EnableInput(Controller);
		if (GetInputComponent() == nullptr)
			return 50;
		DisableInput(Controller);

		return 1;
	}
}
)AS"),
		TEXT("ATestActorInterfaceComponentAndInput"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Actor interface component actor should spawn"), Actor))
	{
		break;
	}

	APlayerController& PlayerController = Spawner.SpawnActor<APlayerController>();
	TestEqual(
		TEXT("AActor component and input bindings should operate from script"),
		CallScriptIntFunctionWithPlayerController(*this, Actor, TEXT("CheckComponentsAndInput"), &PlayerController),
		1);
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorInterfaceSpawnAndQueryTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorInterfaceSpawnAndQuery"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorInterfaceSpawnAndQuery.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorInterfaceSpawned : AActor
{
	default Tags.Add(n"ActorInterfaceSpawned");

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY()
	int Marker = 7;
}

UCLASS()
class ATestActorInterfaceSpawnAndQuery : AActor
{
	UFUNCTION()
	int RunSpawnAndQuery()
	{
		AActor NativeSpawned = AActor::Spawn(FVector(100.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfaceNativeSpawned");
		if (!IsValid(NativeSpawned))
			return 10;

		AActor GenericSpawned = SpawnActor(ATestActorInterfaceSpawned::StaticClass(), FVector(200.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfaceGenericSpawned");
		if (!IsValid(GenericSpawned))
			return 20;

		AActor DeferredSpawned = SpawnActor(ATestActorInterfaceSpawned::StaticClass(), FVector(300.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfaceDeferredSpawned", true);
		if (!IsValid(DeferredSpawned))
			return 30;
		FinishSpawningActor(DeferredSpawned);
		if (!DeferredSpawned.GetActorLocation().Equals(FVector(300.0, 0.0, 0.0)))
			return 40;

		AActor DeferredTransformSpawned = SpawnActor(ATestActorInterfaceSpawned::StaticClass(), FVector::ZeroVector, FRotator::ZeroRotator, n"ActorInterfaceDeferredTransformSpawned", true);
		if (!IsValid(DeferredTransformSpawned))
			return 45;
		FinishSpawningActor(DeferredTransformSpawned, FTransform(FRotator::ZeroRotator, FVector(350.0, 0.0, 0.0), FVector::OneVector));
		if (!DeferredTransformSpawned.GetActorLocation().Equals(FVector(350.0, 0.0, 0.0)))
			return 46;

		AActor PersistentSpawned = SpawnPersistentActor(ATestActorInterfaceSpawned::StaticClass(), FVector(400.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfacePersistentSpawned");
		if (!IsValid(PersistentSpawned))
			return 50;

		AActor PersistentDeferredSpawned = SpawnPersistentActor(ATestActorInterfaceSpawned::StaticClass(), FVector(450.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfacePersistentDeferredSpawned", true);
		if (!IsValid(PersistentDeferredSpawned))
			return 55;
		FinishSpawningActor(PersistentDeferredSpawned);
		if (!PersistentDeferredSpawned.GetActorLocation().Equals(FVector(450.0, 0.0, 0.0)))
			return 56;

		TArray<ATestActorInterfaceSpawned> TypedActors;
		GetAllActorsOfClass(TypedActors);
		if (TypedActors.Num() < 5)
			return 60;

		TArray<AActor> ExplicitClassActors;
		GetAllActorsOfClass(ATestActorInterfaceSpawned::StaticClass(), ExplicitClassActors);
		if (ExplicitClassActors.Num() < 5)
			return 70;

		TArray<AActor> TaggedActors;
		GetAllActorsOfClassWithTag(n"ActorInterfaceSpawned", TaggedActors);
		if (TaggedActors.Num() < 5)
			return 80;

		TArray<AActor> InternalClassActors;
		__Actor_GetAllByClass(ATestActorInterfaceSpawned::StaticClass(), InternalClassActors);
		if (InternalClassActors.Num() < 5)
			return 90;

		return 1;
	}
}
)AS"),
		TEXT("ATestActorInterfaceSpawnAndQuery"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Actor interface spawn/query harness should spawn"), Actor))
	{
		break;
	}

	BeginPlayActor(Engine, *Actor);
	TestEqual(
		TEXT("AActor spawn and world query bindings should operate from script"),
		CallScriptIntFunction(*this, Actor, TEXT("RunSpawnAndQuery")),
		1);
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

#endif
