// Theme: World.Component. WorldStory: GetComponentsByClass plus
// GetInputComponent / EnableInput / DisableInput.
// C++: AngelscriptActorPropertyInterfaceTests.cpp::InterfaceComponentAndInput
// sha256=127133535ae859703b7d41c4466f76d906d2298f560f91811e03d9ab131ce2a6; lines 398-446.
// Oracle CheckComponentsAndInput returns 1 with a spawned PlayerController.
// Extra: local construct RootScene/ExtraScene null; GetInputComponent null.
// FixtureIsolated.

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
		{
			return 10;
		}

		TArray<UTestActorInterfaceExtraComponent> ExtraComponents;
		GetComponentsByClass(UTestActorInterfaceExtraComponent::StaticClass(), ExtraComponents);
		if (ExtraComponents.Num() != 1)
		{
			return 20;
		}

		TArray<UActorComponent> ActorComponents;
		GetComponentsByClass(USceneComponent::StaticClass(), ActorComponents);
		if (ActorComponents.Num() != 2)
		{
			return 30;
		}

		if (GetInputComponent() != nullptr)
		{
			return 40;
		}
		EnableInput(Controller);
		if (GetInputComponent() == nullptr)
		{
			return 50;
		}
		DisableInput(Controller);

		return 1;
	}
}

bool Observe_InterfaceComponentAndInput_DefaultNull(ATestActorInterfaceComponentAndInput Actor)
{
	if (Actor is null)
	{
		throw("Test_InterfaceComponentAndInput setup: required Actor is null");
	}
	return Actor.RootScene == nullptr
		&& Actor.ExtraScene == nullptr
		&& Actor.GetInputComponent() == nullptr;
}

int Observe_InterfaceComponentAndInput_NullController(ATestActorInterfaceComponentAndInput Actor)
{
	if (Actor is null)
	{
		throw("Test_InterfaceComponentAndInput setup: required Actor is null");
	}
	return Actor.CheckComponentsAndInput(nullptr);
}
