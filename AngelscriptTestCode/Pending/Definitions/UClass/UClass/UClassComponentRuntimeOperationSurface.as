/**
 * @version v1
 * @summary Runtime NewObject/attach/detach/DestroyComponent on script components. After BeginPlay, DefaultSceneFoundByClass/DefaultLogicFoundByClass and the runtime created/attached/detached flags are set. Keep those UPROPERTY.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Runtime NewObject/attach/detach/DestroyComponent on script components. After BeginPlay, DefaultSceneFoundByClass/DefaultLogicFoundByClass and the runtime created/attached/detached flags are set. Keep those UPROPERTY.
 * @topic Baseline
 */
UCLASS()
class UCoverageUClassRuntimeSceneComponent : USceneComponent
{
	UPROPERTY()
	int Marker = 17;

	/**
	 * Observe the scene-component Marker default.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentRuntime
	 * @Inputs a freshly constructed scene component
	 * @Return Marker
	 */
	UFUNCTION()
	int MarkerDefault()
	{
		return Marker;
	}
}

UCLASS()
class UCoverageUClassRuntimeLogicComponent : UActorComponent
{
	UPROPERTY()
	int Marker = 23;

	/**
	 * Observe the logic-component Marker default.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentRuntime
	 * @Inputs a freshly constructed logic component
	 * @Return Marker
	 */
	UFUNCTION()
	int MarkerDefault()
	{
		return Marker;
	}
}

UCLASS()
class ACoverageUClassComponentRuntimeActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageUClassRuntimeSceneComponent DefaultScene;

	UPROPERTY(DefaultComponent)
	UCoverageUClassRuntimeLogicComponent DefaultLogic;

	UPROPERTY()
	UCoverageUClassRuntimeSceneComponent RuntimeScene;

	UPROPERTY()
	UCoverageUClassRuntimeLogicComponent RuntimeLogic;

	UPROPERTY()
	bool DefaultSceneFoundByClass = false;

	UPROPERTY()
	bool DefaultLogicFoundByClass = false;

	UPROPERTY()
	bool RuntimeSceneCreated = false;

	UPROPERTY()
	bool RuntimeLogicCreated = false;

	UPROPERTY()
	bool RuntimeSceneInitiallyDetached = false;

	UPROPERTY()
	bool RuntimeSceneAttached = false;

	UPROPERTY()
	bool RuntimeSceneDetached = false;

	UPROPERTY()
	bool RuntimeSceneRegistered = false;

	UPROPERTY()
	bool RuntimeSceneFoundByClass = false;

	UPROPERTY()
	bool RuntimeSceneIncludedInAllComponents = false;

	UPROPERTY()
	bool RuntimeLogicRegistered = false;

	UPROPERTY()
	bool RuntimeLogicFoundByClass = false;

	UPROPERTY()
	bool RuntimeLogicIncludedInAllComponents = false;

	UPROPERTY()
	bool RuntimeSceneDestroyed = false;

	UPROPERTY()
	bool RuntimeLogicDestroyed = false;

	/**
	 * WorldStory: BeginPlay finds default components, creates runtime ones, attaches, detaches, and destroys them.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.ComponentRuntime
	 * @Inputs DefaultScene, DefaultLogic, NewObject runtime components, Root
	 * @Return the FoundByClass/Created/Attached/Detached/Destroyed flags updated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DefaultSceneFoundByClass = Cast<UCoverageUClassRuntimeSceneComponent>(
			GetComponentByClass(UCoverageUClassRuntimeSceneComponent::StaticClass())) == DefaultScene;
		DefaultLogicFoundByClass = Cast<UCoverageUClassRuntimeLogicComponent>(
			GetComponentByClass(UCoverageUClassRuntimeLogicComponent::StaticClass())) == DefaultLogic;

		RuntimeScene = Cast<UCoverageUClassRuntimeSceneComponent>(
			NewObject(this, UCoverageUClassRuntimeSceneComponent::StaticClass(), n"CoverageRuntimeScene", true));
		RuntimeLogic = Cast<UCoverageUClassRuntimeLogicComponent>(
			NewObject(this, UCoverageUClassRuntimeLogicComponent::StaticClass(), n"CoverageRuntimeLogic", true));
		RuntimeSceneCreated = RuntimeScene != nullptr && RuntimeScene.GetOwner() == this && RuntimeScene.GetWorld() == GetWorld();
		RuntimeLogicCreated = RuntimeLogic != nullptr && RuntimeLogic.GetOwner() == this && RuntimeLogic.GetWorld() == GetWorld();
		if (RuntimeScene == nullptr || RuntimeLogic == nullptr)
		{
			return;
		}

		RuntimeSceneInitiallyDetached = !RuntimeScene.IsAttachedTo(Root);
		RuntimeScene.AttachToComponent(Root, n"RuntimeSocket",
			EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, false);
		RuntimeSceneAttached = RuntimeScene.IsAttachedTo(Root) &&
			RuntimeScene.GetAttachSocketName() == n"RuntimeSocket";

		RuntimeScene.DetachFromComponent(EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, false);
		RuntimeSceneDetached = !RuntimeScene.IsAttachedTo(Root);

		RuntimeScene.AttachToComponent(Root, NAME_None,
			EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, false);
		RuntimeSceneFoundByClass = Cast<UCoverageUClassRuntimeSceneComponent>(
			GetComponentByClass(UCoverageUClassRuntimeSceneComponent::StaticClass())) != nullptr;
		RuntimeLogicFoundByClass = Cast<UCoverageUClassRuntimeLogicComponent>(
			GetComponentByClass(UCoverageUClassRuntimeLogicComponent::StaticClass())) != nullptr;

		RuntimeScene.DestroyComponent();
		RuntimeLogic.DestroyComponent();
		RuntimeSceneDestroyed = RuntimeScene.IsBeingDestroyed();
		RuntimeLogicDestroyed = RuntimeLogic.IsBeingDestroyed();
	}

	/**
	 * Observe that an unset actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentRuntime
	 * @Inputs an unset ACoverageUClassComponentRuntimeActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassComponentRuntimeActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe runtime flags before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentRuntime
	 * @Inputs a freshly constructed actor
	 * @Return true when the four observed flags are false
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool FlagsDefaultFalse()
	{
		if (DefaultSceneFoundByClass)
		{
			return false;
		}
		if (RuntimeSceneCreated)
		{
			return false;
		}
		if (RuntimeSceneDestroyed)
		{
			return false;
		}
		return RuntimeLogicDestroyed == false;
	}
}
/** @end */
