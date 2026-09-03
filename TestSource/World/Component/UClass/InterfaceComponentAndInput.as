/**
 * GetComponentsByClass alongside GetInputComponent, EnableInput and DisableInput.
 * C++ calls CheckComponentsAndInput with a spawned player controller and expects 1.
 * The observers cover the local-construct default and the null-controller vector.
 *
 * @Theme World.Component
 * @Subject Component.InterfaceComponentAndInput
 * @Harness UClass
 * @Tag World.Component.InterfaceComponentAndInput
 * @Provenance Theme: World.Component. WorldStory: GetComponentsByClass plus
 * @Provenance GetInputComponent / EnableInput / DisableInput.
 * @Provenance C++: AngelscriptActorPropertyInterfaceTests.cpp::InterfaceComponentAndInput
 * @Provenance sha256=127133535ae859703b7d41c4466f76d906d2298f560f91811e03d9ab131ce2a6; lines 398-446.
 * @Provenance Oracle CheckComponentsAndInput returns 1 with a spawned PlayerController.
 * @Provenance Extra: local construct RootScene/ExtraScene null; GetInputComponent null.
 * @Provenance FixtureIsolated.
 */

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

	/**
	 * Walk the component queries and the input enable/disable round trip.
	 *
	 * @Kind Observe
	 * @Covers Component.InterfaceComponentAndInput
	 * @Inputs a player controller to enable input against
	 * @Return 1 on success; 10, 20, 30, 40 or 50 naming the step that failed
	 * @Param Controller the controller to enable and then disable input for
	 */
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

	/**
	 * Observe that a locally constructed actor has no components and no input component.
	 *
	 * @Kind Observe
	 * @Covers Component.InterfaceComponentAndInput
	 * @Inputs an actor that has not been spawned
	 * @Return true when both scene components and the input component are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (RootScene != nullptr)
		{
			return false;
		}
		if (ExtraScene != nullptr)
		{
			return false;
		}
		return GetInputComponent() == nullptr;
	}

	/**
	 * Observe the entrypoint result when no controller is supplied.
	 *
	 * @Kind Observe
	 * @Covers Component.InterfaceComponentAndInput
	 * @Inputs a null player controller
	 * @Return CheckComponentsAndInput(nullptr)
	 * @Boundary null controller
	 */
	UFUNCTION()
	int NullController()
	{
		return CheckComponentsAndInput(nullptr);
	}
}
